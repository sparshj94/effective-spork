import { LightningElement, wire, track } from 'lwc';
import getAllDocuments from '@salesforce/apex/DocumentController.getAllDocuments';
import insertDocuments from '@salesforce/apex/DocumentController.insertDocuments';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import DOCUMENT_TYPE from "@salesforce/schema/Document__c.Document_Type__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const tableColumns = [
    { label: 'Title', fieldName: 'Name' },
    { label: 'Valid From', fieldName: 'ValidFromYear__c', type: 'text', sortable: true},
    { label: 'Valid Till', fieldName: 'ValidToYear__c', type: 'text', sortable:true },
    { label: 'Document Type', fieldName: 'Document_Type__c', type: 'text' },
    { label: 'Is Valid', fieldName: 'isActive__c', type: 'boolean' },
    {
        label: 'Preview',
        type: 'button-icon',
        typeAttributes: {
            iconName: 'utility:preview',
            name: 'preview',
            variant: 'bare',
            alternativeText: 'Preview'
        }
    }

];

const options = [
    { label: 'Identity', value: 'Identity' },
    { label: 'School', value: 'School' },
    { label: 'Company', value: 'Company' },
    { label: 'College', value: 'College' },
    { label: 'Property', value: 'Property' },
]
const validOptions = [
    {label:"All", value:'all'},
    {label:"Valid", value:'valid'},
    {label:"InValid", value:'invalid'},

]
export default class DapDocumentDashboard extends LightningElement {

    documents = [];
    groupedData = [];
    columns = tableColumns;
    @track sortBy;
    @track sortDirection;
    selectedRecordId;
    isModalOpen = false;
    isNewModalOpen = false;
    options = options;
    docName;
    docTypevalue;
    fromDateVal;
    toDateVal;
    dataToInsert = [];
    documentTypePicklist = []
    selectedDocType = 'all';
    selectedValid = 'all';
    validOptions = validOptions;
    @track filterData = [];
    isToChangeData = true;

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: DOCUMENT_TYPE })
    getDocumentTypoes({error, data}){
        if(data){
            this.documentTypePicklist = [...data.values, { "attributes": null, "label": "All", "validFor": [], "value": "all" }];
        }
    }



    @wire(getAllDocuments)
    getDocuments({ error, data }) {
        if (data) {
            this.documents = data.map(doc=>({
                ...doc,
                icon:'utility:preview'
            }));
            console.log('wired data', JSON.parse(JSON.stringify(data)));
            this.groupData(this.documents);
        }
        if(error){
            console.error(error);
        }
    }

    groupData(data) {

        const grouped = Object.groupBy(data, ({ ValidFromYear__c }) => ValidFromYear__c);

        const result = Object.entries(grouped).map(([key, value]) => ({
            year: key,
            docs: value 
        }));
        if(this.isToChangeData){
            this.groupedData = result;
            this.filterData = this.groupedData;
            this.isToChangeData = false;
        }
        else{
            this.filterData = result;
        }
        // console.log(this.groupedData);
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        const sortedData  = this.groupedData.map(group=>{
            let sortedDocs = [...group.docs].sort((a, b) => {
                let x = a[fieldname] ? a[fieldname]: ''; // handling null values
                let y = b[fieldname] ? b[fieldname] : '';
                x = Number(x)
                y = Number(y)
                // sorting values based on direction
                return isReverse * ((x > y) - (y > x));
            });
            return{
                ...group,
                docs:sortedDocs
            }
        });
        
        this.groupedData = sortedData;
    }

    handleFilterData(){
        console.log("Called Handle");
        if(this.selectedDocType==='all' && this.selectedValid==='all'){
            console.log('if');
            
            this.filterData = [...this.groupedData];
        }
        else{
            console.log('else');
            
            let filter2 = this.selectedValid==='valid' ? true : false;
            let testData = [];
            console.log('else2');
            let check = true;
            // if(this.selectedDocType==='all'){
            //     this.fil = [...this.groupedData];
            //     check = false;
            // } 
            this.groupedData.forEach(element2 => {
                element2.docs.forEach(element=>{
                        if(this.selectedDocType==='all'){
                            if(element.isActive__c == filter2){
                                testData = [...testData,element];
                            }
                        } else if(this.selectedValid==='all' && element.Document_Type__c===this.selectedDocType){
                            testData = [...testData,element];
                        } 
                        else if(element.Document_Type__c == this.selectedDocType && element.isActive__c == filter2){
                            console.log(JSON.stringify(element));
                            testData = [...testData,element];
                        }
                })
            });
            this.groupData(testData);
            console.log('else3');
            console.log('gd---', testData);
            // this.filterData = [...testData];
            // console.log('DS-->' + this.filterData);
            
            
            console.log("DAtaa---> " + JSON.stringify(testData));
            console.log("DAta---> " + JSON.stringify(this.filterData));
        }
        
    }

    handleDocTypeFilter(event){
        this.selectedDocType = event.detail.value;
        console.log(this.selectedDocType);
        this.handleFilterData();
    }

    handleValidTypeFilter(event){
        this.selectedValid = event.detail.value;
        this.handleFilterData();
    }

    
    handleIconClick(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if(actionName === 'preview'){
            this.selectedRecordId = row.Id;
            console.log('Record id', row.Id);
            this.isModalOpen = true;
        }
    }    
    closeModal(){
        this.isModalOpen = false;
    }
    handleSuccess(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Document updated successfully',
                variant: 'success'
            })
        );

        this.isModalOpen = false;
    }

    handleNewButton(){
        // this.filterData();
        this.isNewModalOpen = true;
    }
    handleName(event){
        this.docName = event.detail.value;
    }
    handleDocType(event){
        this.docTypevalue = event.detail.value;
    }
    handleToDate(event){
        this.toDateVal = event.detail.value;
    }
    handleFromDate(event){
        this.fromDateVal = event.detail.value
    }
    handleSubmitBtn(){
        const data = {Name:this.docName, Document_Type__c:this.docTypevalue, Valid_From_Date__c:this.fromDateVal, Valid_To_Date__c:this.toDateVal};
        this.dataToInsert = [...this.dataToInsert, data];
        console.log('d',this.dataToInsert);
        
        this.sendData();
        this.dataToInsert = [];
        this.isNewModalOpen =false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Document Inserted successfully',
                variant: 'success'
            })
        );

    }
    sendData(){
        return insertDocuments({"docList":this.dataToInsert}).then(data=>{
            console.log(data);
        }).catch(err=>{
            console.log(err);
        })
    }

}



[{"Id":"a0Pfj000001MbWbEAK","Name":"DL","Document_Type__c":"Identity","isActive__c":false,"ValidFromYear__c":"2011","ValidToYear__c":"2030","icon":"utility:preview"},{"Id":"a0Pfj000001KhMoEAK","Name":"Driving Licence","Document_Type__c":"Identity","isActive__c":false,"ValidFromYear__c":"2022","ValidToYear__c":"208","icon":"utility:preview"}]
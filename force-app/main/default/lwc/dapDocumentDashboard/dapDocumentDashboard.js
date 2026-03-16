import { LightningElement, wire, track } from 'lwc';
import getAllDocuments from '@salesforce/apex/DocumentController.getAllDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const tableColumns = [
    { label: 'Title', fieldName: 'Name' },
    { label: 'Valid From', fieldName: 'ValidFromYear__c', type: 'text', sortable: true},
    { label: 'Valid Till', fieldName: 'ValidToYear__c', type: 'text', sortable:true },
    { label: 'Document Type', fieldName: 'Document_Type__c', type: 'text' },
    { label: 'Is Valid', fieldName: 'isActive__c', type: 'text' },
    // { label: 'Icon', fieldName: 'icon', type:'icon',typeAttributes:{iconName:{fieldName:'icon'}, recordId:{fieldName:'Id'}}},
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

export default class DapDocumentDashboard extends LightningElement {

    documents = [];
    groupedData = [];
    columns = tableColumns;
    @track sortBy;
    @track sortDirection;
    selectedRecordId;
    isModalOpen = false;
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

        this.groupedData = result;

        // this.tempdata.forEach(el => {
        //     console.log('Year:', el.year);
        //     console.log('Documents:', JSON.parse(JSON.stringify(el.docs)));
        // });

        // console.log('Final grouped data', JSON.parse(JSON.stringify(this.tempdata)));
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

}
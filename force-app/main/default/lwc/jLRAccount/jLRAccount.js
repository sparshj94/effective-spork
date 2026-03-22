import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountContactController.getAccounts';
import getContacts from '@salesforce/apex/AccountContactController.getContacts';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import RATING_FIELD from "@salesforce/schema/Account.Rating"
import filemodal from './modal'

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Industry', fieldName: 'Industry' },
    { label: 'Ratings', fieldName: 'Rating'},
];
const contactcolumns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email' },
    {label:'Upload File', fieldName: 'file', type:'button'}
];


export default class JLRAccount extends LightningElement {

    @track accountData = [];
    @track accountCopy = [];
    @track tableData = [];
    contactData = [];
    ratingPickListValues = [];
    accountRowLimit = 3;
    offSet = 0;
    columns = columns
    contactcolumns = contactcolumns;
    isTableToDisplay = true;   
    filterMessage = '';
    isNewBtnToShow = false;
    accountId;
    contactRecordId;
    isContactTableToDisplay = false;

    // @wire(getAccounts, {limitSize:'$accountRowLimit', offSet:'$offSet'})
    // wiredAccounts({error, data}){
    //     if(data){
    //         this.accountData = data;
    //         this.accountCopy  = data;
    //         console.log('acc', data);
            
    //     }
    // }

    loadAccounts(){
        return getAccounts({"limitSize":this.accountRowLimit, "offSet":this.offSet}).then(el=>{
            this.accountData = [...this.accountData, ...el];
            this.accountCopy = this.accountData;
            this.accountCopy.map(el=>console.log(el.Name)
            )
        }).catch(err=>{
            console.log('acc err', err);
        })
    }
    connectedCallback() {
        this.loadAccounts();
    }
    // @wire(getContacts, {limitSize:'$accountRowLimit', offSet:'$offSet', accountId: '$accountId'})
    // getContact({error, data}){
    //     if(data){
    //         this.contactData = data;
    //     }
    // }

    loadContact(){
        return getContacts({"limitSize":this.accountRowLimit, "offSet":this.offSet, "accountId": this.accountId}).then(el=>{
            this.contactData = [...this.contactData, ...el];
        }).catch(err=>{
            console.log('err in contact imp call');
            
        })
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: RATING_FIELD })
    getPicklistVal({error, data}){
        if(data){
            this.ratingPickListValues = data;
            console.log('pick', data);
        }
    }
    handleClick(){
        // this.loadAccounts();
        const accName = this.template.querySelector('.accName').value ? this.template.querySelector('.accName').value.toLowerCase() : '';
        const accIndustry = this.template.querySelector('.accIndustry').value ? this.template.querySelector('.accIndustry').value.toLowerCase() : '';
        const accRating = this.template.querySelector('.accRating').value ? this.template.querySelector('.accRating').value.toLowerCase() : '';
        
        if(accName && accIndustry && accRating){
            console.log('n if');
            
            const data = this.accountCopy.filter(ele=>{
                console.log('in lop');
                console.log(ele.Name.toLowerCase() + ' ' + accName);
                
                ele.Name.toLowerCase() === accName;
                ele.Industry.toLowerCase() === accIndustry;
                ele.Rating.toLowerCase() === accRating;
            })
            data.forEach(el=>{
            console.log(el.Name);
            
            })
        }
        console.log('end');
        
        
        if(this.accountCopy.length<0){
            this.filterMessage = 'No Records Found'
            this.isNewBtnToShow = true;
        } else{
            console.log('display tab');
            this.isTableToDisplay = true;
        }
    }


    getSelectedName(event) {
        this.isContactTableToDisplay = true;
        const selectedRows = event.detail.selectedRows;
        console.log(selectedRows);
        console.log(selectedRows[0].Id);
        this.accountId = selectedRows[0].Id;
        this.loadContact()
    }
    getSelectedContactName(event){
        const selectedRows = event.detail.selectedRows;
        this.contactRecordId = selectedRows[0].Id;
        this.handleModal()
        
    }
    async handleModal(){
        const result  = await filemodal.open({
            size:'small',
            contactRecordId:this.contactRecordId
        })
    }
    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        console.log(uploadedFiles.length);
        
    }


}
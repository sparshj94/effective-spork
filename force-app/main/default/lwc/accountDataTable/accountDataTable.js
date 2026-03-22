import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountContactController.getAccounts'
import {MessageContext, publish} from 'lightning/messageService';
import COMPONENT_COMMUNICATION from '@salesforce/messageChannel/ComponentCommunication__c';
const actions = [
    { label: 'Show Contacts', name: 'show_contacts' },
];

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Industry', fieldName: 'Industry', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class AccountDataTable extends LightningElement {
    @wire(MessageContext)
    messageContext;

    accounts = [];
    error;
    columns = columns;
    rowLimit = 10;
    rowOffSet=0;

    connectedCallback() {
        this.loadData();
        console.log(this.accounts);
        
    }
    loadData(){
        return getAccounts({"limitSize":this.rowLimit, "offSet":this.rowOffSet}).then(result=>{
            console.log(result);
            
            let updatedRecords = [...this.accounts, ...result];
            this.accounts = updatedRecords;
            this.error = undefined;
        })
        .catch(error=>{
            this.error = error;
            this.accounts = undefined;
        })
    }
    loadMoreData(event){
        const currentRecords = this.accounts;
        const {target} = event;
        target.isLoading = true;
        this.rowOffSet = this.rowOffSet+this.rowLimit;
        this.loadData().then(()=>{target.isLoading = false;})
    }
    handleRowAction(event){
        const action = event.detail.action.name;
        const row = event.detail.row;
        console.log(row);
        
        const recordId  = row.Id;
        console.log(recordId);
        
        const payload = {message: recordId}
        publish(this.messageContext, COMPONENT_COMMUNICATION, payload);
    }
}
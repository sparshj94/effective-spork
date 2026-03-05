import { LightningElement, wire } from 'lwc';
import {MessageContext, subscribe} from 'lightning/messageService';
import COMPONENT_COMMUNICATION from '@salesforce/messageChannel/ComponentCommunication__c';
import getContacts from '@salesforce/apex/AccountContactController.getContacts'
const columns = [
    { label: 'Contact Name', fieldName: 'Name' },
    { label: 'Account Name', fieldName: 'AccountName' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
];
export default class ContactDataTable extends LightningElement {

    @wire(MessageContext)
    messageContext;
    subscription = null;
    recievedMsg=''
    contacts = [];
    error;
    columns = columns;
    rowLimit = 10;
    rowOffSet=0;
    enableInfiniteLoading = true;

    connectedCallback() {
        if(!this.subscription){
            this.subscription = subscribe(this.messageContext, COMPONENT_COMMUNICATION,(p)=>this.captureRowAction(p));
        }
        console.log("Connected callback");
        
    }
    captureRowAction(payload){
        console.log("Payload for contact",payload);
        this.recievedMsg = payload.message;
        this.contacts =[];
        this.rowOffSet=0;
        this.enableInfiniteLoading=true;
        this.loadData();
        console.log("Cpatured row action");
        
    }
    loadData(){
        return getContacts({"limitSize": this.rowLimit, "offSet":this.rowOffSet, "accountId":this.recievedMsg}).then(data=>{
            console.log('Data of contact',data);

            const updatedData = data.map(row => {
                return {
                    ...row,
                    AccountName: row.Account ? row.Account.Name : ''
                };
            });
            
            let updatedRecords = [...this.contacts, ...updatedData];
            this.contacts = updatedRecords;

            if(data.length < this.rowLimit){
                this.enableInfiniteLoading = false;
            }
            this.error = undefined;

            
        }).catch(err=>{
            this.contacts = undefined;
            this.error = err;
        })
    }
    loadMoreData(event){
        const currentRecords = this.contacts;
        const {target} = event;
        target.isLoading = true;
        this.rowOffSet = this.rowOffSet+this.rowLimit;
        this.loadData().then(()=>{target.isLoading = false;})
        console.log("Load more data");
    }
}
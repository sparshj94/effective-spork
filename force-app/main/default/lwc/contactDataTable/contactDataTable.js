import { LightningElement, wire } from 'lwc';
import {MessageContext, subscribe} from 'lightning/messageService';
import COMPONENT_COMMUNICATION from '@salesforce/messageChannel/ComponentCommunication__c';
export default class ContactDataTable extends LightningElement {

    @wire(MessageContext)
    messageContext;
    subscription = null;
    recievedMsg='No Message from A';

    connectedCallback() {
        if(!this.subscription){
            this.subscription = subscribe(this.messageContext, COMPONENT_COMMUNICATION,(p)=>this.captureRowAction(p));
        }
    }
    captureRowAction(payload){
        console.log(payload);
        this.recievedMsg = payload.message;
    }
}
import { LightningElement, wire } from 'lwc';
import {publish, MessageContext} from 'lightning/messageService';
import COMPONENT_COMMUNICATION from '@salesforce/messageChannel/ComponentCommunication__c';

export default class ComponentA extends LightningElement {
    @wire(MessageContext)
    messageContext;

    handle(){
        const msgInput = this.template.querySelector('lightning-input').value;
        const payload = {message : msgInput};
        publish(this.messageContext, COMPONENT_COMMUNICATION, payload);
    }
}
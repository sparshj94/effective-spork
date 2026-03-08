import { LightningElement, wire } from 'lwc';
import COMPONENT_COMMUNICATION from '@salesforce/messageChannel/ComponentCommunication__c';
import {MessageContext, subscribe} from 'lightning/messageService'
export default class OrderStatus extends LightningElement {

    @wire(MessageContext) messageContext;
    subscription = null;
    orderId = ''
    customerName =''
    quantity;
    item='';
    status='';
    isOrder = false;

    connectedCallback() {
        if(!this.subscription){
            this.subscription = subscribe(this.messageContext, COMPONENT_COMMUNICATION,
                (result) => {
                    console.log(result);
                    this.orderId = result.orderId;
                    this.customerName = result.customerName;
                    this.quantity =result.quantity;
                    this.item=result.item;
                    this.status = result.status;
                    this.isOrder = true;
                }
            );
        }

    }

}
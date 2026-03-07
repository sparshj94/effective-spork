import { LightningElement, wire } from 'lwc';
import ORDER_CHANNEL from '@salesforce/messageChannel/OrderCommunication__c';
import {MessageContext, subscribe} from 'lightning/messageService'
export default class OrderStatus extends LightningElement {

    @wire(MessageContext) messageContext;
    subscription = null;
    orderId = ''
    customerName =''
    quantity;
    item='';
    status='';

    connectedCallback() {
        if(!this.subscription){
            this.subscription = subscribe(this.messageContext, ORDER_CHANNEL,
                (result) => {
                    console.log(result);
                    this.orderId = result.orderId;
                    this.customerName = result.customerName;
                    this.quantity =result.quantity;
                    this.item=result.item;
                    this.status = result.status;
                }
            );
        }
    }

}
import { LightningElement, wire } from 'lwc';
import COMPONENT_COMMUNICATION from '@salesforce/messageChannel/ComponentCommunication__c';
import {MessageContext, subscribe} from 'lightning/messageService'
const columns = [
    { label: 'Order Id', fieldName: 'orderId' },
    { label: 'Customer Name', fieldName: 'customerName', type: 'text' },
    { label: 'Item', fieldName: 'item', type: 'text' },
    { label: 'Quantity', fieldName: 'quantity', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' }
];

export default class OrderSummary extends LightningElement {


    @wire(MessageContext) messageContext;
    subscription = null;
    totalOrders;
    orders = [];
    columns = columns;




    connectedCallback() {
        if(!this.subscription){
            this.subscription = subscribe(this.messageContext, COMPONENT_COMMUNICATION,
                (result) => {
                    console.log("from order summary",result);
                    this.orders = [...this.orders, result];
                    this.totalOrders = this.orders.length;
                }
            );
        }
    }

}
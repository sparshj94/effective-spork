import { LightningElement, wire } from 'lwc';
import ORDER_CHANNEL from '@salesforce/messageChannel/OrderCommunication__c';
import {MessageContext, publish} from 'lightning/messageService'
export default class OrderPlacement extends LightningElement {

    itemValue = ''
    customerName = ''
    quantity;

    @wire(MessageContext) messageContext;


    get options() {
        return [
            { label: 'Item 1', value: 'item1' },
            { label: 'Item 2' , value: 'item2' },
            { label: 'Item 3' , value: 'item3' },
        ];
    }
    handleChange(event){
        this.itemValue = event.detail.value;
    }
    handleOrder(){
        this.customerName = this.template.querySelector('.customerName').value;
        this.quantity = this.template.querySelector('.quantity').value;

        if(this.itemValue && this.customerName && this.quantity){
            const orderId = this.generateUniqueishId();
            const payload = {orderId : orderId, customerName:this.customerName , item:this.itemValue, quantity:this.quantity, status:'ORDER PLACED'};
            publish(this.messageContext, ORDER_CHANNEL, payload);
        }

    }

    generateUniqueishId(prefix = 'ORD') {
        const timestampPart = Date.now(); // Convert timestamp to base 36
        const randomPart = Math.random().toString(36).substring(2, 10); // Random alphanumeric part
        return `${prefix}${timestampPart}_${randomPart}`;
    }
}
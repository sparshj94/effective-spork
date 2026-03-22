import { LightningElement, track, api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled} from 'lightning/empApi';
export default class OrderDashboardPlatformEvent extends LightningElement {
    @track data = [];
    @track columns = [
        { label: 'Order Name', fieldName: 'Order_Name__c' },
        { label: 'Customer Name', fieldName: 'Customer_Name__c' },
        { label: 'Amount', fieldName: 'Amount__c' },
        { label: 'Message', fieldName: 'Message__c' },
        { label: 'Event Time', fieldName: 'Event_Time__c' }
    ];
 
    subscription = {};
    @api channelName = '/event/Order_Event__e';
 
    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
        console.log(JSON.stringify(this.data));
    }

    proxyToObj(obj){
        return JSON.parse(JSON.stringify(obj));
    }

    handleSubscribe() {
        console.log('handle subs called');


        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));


            const payload = response.data.payload;
            const orderName = payload.Order_Name__c;
            const customerName = payload.Customer_Name__c;
            const amount = payload.Amount__c;
            const message = payload.Message__c;
            const eventTime = payload.Event_Time__c;


            const newRow = {
                Order_Name__c: orderName,
                Customer_Name__c: customerName,
                Amount__c: amount,
                Message__c: message,
                Event_Time__c: eventTime,
            };

            this.data = [...this.data, newRow];


            console.log('Updated data:', JSON.stringify(this.data));
        };


        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }



    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleUnsubscribe() {
        // Revoke the subscription
        unsubscribe(this.subscription, response => {
            console.log('Successfully unsubscribed: ', response.channel);
        });
    }

    registerErrorListener() {
        // Invoked if the cometD connection drops or fails
        onError(error => {
            console.error('EMP API Error: ', JSON.stringify(error));
        });
    }


}
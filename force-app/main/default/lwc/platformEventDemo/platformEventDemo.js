import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled} from 'lightning/empApi';
export default class PlatformEventDemo extends LightningElement {
    @track data = [];
    @track columns = [
        { label: 'Id', fieldName: 'RecordId__c' },
        { label: 'Change Type', fieldName: 'Change_Type__c' }
    ];
 
    subscription = {};
    @api channelName = '/event/Account_Update__e';
 
    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
        console.log(JSON.stringify(this.data));
    }

    proxyToObj(obj){
        return JSON.parse(JSON.stringify(obj));
    }
 
    // handleSubscribe() {
    //     console.log('handle subs called');
        
    //     // const self = this;
    //     const messageCallback = function (response) {
    //         console.log('New message received 1: ', JSON.stringify(response));
    //         console.log('New message received 2: ', response);

    //         // var obj = JSON.parse(JSON.stringify(response));

    //         const payload = response.data.payload;
    //         const recordId = payload.RecordId__c;
    //         const chnageType = payload.Change_Type__c;


    //         // self.data = self.proxyToObj(self.data);
    //         // self.data.push({RecordId__c : recordId, Change_Type__c : chnageType});
    //         // console.log('this.data -> ' + JSON.stringify(self.data));
    //     };
 
    //     subscribe(this.channelName, -1, messageCallback).then(response => {
    //         console.log('Subscription request sent to: ', JSON.stringify(response.channel));
    //         this.subscription = response;
    //     });
    // }

    // 

    handleSubscribe() {
        console.log('handle subs called');


        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));


            const payload = response.data.payload;
            const recordId = payload.RecordId__c;
            const changeType = payload.Change_Type__c;


            const newRow = {
                RecordId__c: recordId,
                Change_Type__c: changeType
            };


            // Update datatable reactively
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
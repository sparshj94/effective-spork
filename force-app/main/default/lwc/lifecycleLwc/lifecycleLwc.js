import { LightningElement } from 'lwc';

export default class LifecycleLwc extends LightningElement {

    flag = true;
    
    handlee(){
        this.flag = false;
    }

    constructor(){
        super();
    }
    connectedCallback(){
        console.log("From parent component connected");
        
    }
    renderedCallback(){
        console.log("Parent component rendered");
    }
    disconnectedCallback(){
        console.log("From parent disconnect call");
    }
    errorCallback(){
        console.log("Error from parent");
    }
}
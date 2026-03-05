import { LightningElement } from 'lwc';

export default class LifecycleLwcTwo extends LightningElement {
    constructor(){
        super();
    }
    connectedCallback(){
        console.log("From child component connected");
        
    }
    renderedCallback(){
        console.log("child component rendered");
    }
    disconnectedCallback(){
        console.log("From child disconnect call");
    }
    errorCallback(){
        console.log("Error from child");
    }
}
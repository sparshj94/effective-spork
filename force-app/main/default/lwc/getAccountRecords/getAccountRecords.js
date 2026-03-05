import { LightningElement,wire } from 'lwc';
import getAccountRecord from '@salesforce/apex/Assignment.getAccount'; 
export default class GetAccountRecords extends LightningElement {

    // @wire(getAccountRecord) getAccFromApex
    getAccFromApex;

    renderedCallback(){
        console.log("Rendered");
    }
    handleClick(){
        let name = this.template.querySelector(".getname").value;
        console.log(name);
        
        getAccountRecord({"name":name}).then(data =>{
            console.log("Data", data);
            this.getAccFromApex = data;
        })
    }
}
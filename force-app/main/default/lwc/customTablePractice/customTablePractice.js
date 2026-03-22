import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountContactController.getAccountss'
export default class CustomTablePractice extends LightningElement {

    rowLimit = 10;
    offSet=0;
    accountData = [];
    tableCols = ["Name", "Phone", "Industry"];
    loadData(){
        return getAccounts({"limitSize":this.rowLimit, "offSet":this.offSet}).then(data=>{
            this.accountData = data;
            console.log(data);
            
        }).catch(err=>{
            console.log(err);
        })
    }
    connectedCallback() {
        this.loadData();
    }
    
}
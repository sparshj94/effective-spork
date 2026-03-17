import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountAndContact.getAccounts'
export default class CustomTablePractice extends LightningElement {

    rowLimit = 10;
    offSet=0;
    accountData = [];
    tableCols = [];
    loadData(){
        return getAccounts({"rowLimit":this.rowLimit, "offSet":this.offSet}).then(data=>{
            this.accountData = data;
            this.tableCols = [...data[0].Name];
            this.tableCols = [...data[0].Phone];
            this.tableCols = [...data[0].Industry];
        }).catch(err=>{
            console.log(err);
        })
    }
    connectedCallback() {
        this.loadData();
    }
    
}
import { LightningElement } from 'lwc';
import getOpenOpportunities from '@salesforce/apex/OpportunityController.getOpenOpportunity'

const columns = [
 { label: 'Name', fieldName: 'Name' },
 { label: 'Stage Name', fieldName: 'StageName' },
];


export default class OpportunityDataTable extends LightningElement {

    searchedKey ='';
    data = [];
    error = undefined;
    filteredData = [];
    columns = columns;
    rowLimit = 10;
    rowOffSet=0;
    isLoading  = true;
    enableInfiniteLoading = true;

    connectedCallback() {
        this.loadData();
        console.log("connected callback");
        console.log(this.data);
        
    }
    loadData() {
        this.isLoading = true;
        return getOpenOpportunities({ "limitSize": this.rowLimit, "offSet": this.rowOffSet })
            .then(result => {
                if (result.length > 0) {
                    // Append new data
                    let updatedData = [...this.data, ...result];
                    this.filteredData = updatedData;
                    this.data = updatedData;
                }
                
                // If returned records less than limit, no more data to load
                if (result.length < this.rowLimit) {
                    this.enableInfiniteLoading = false;
                }
                
                this.isLoading = false;
                this.error = undefined;
            })
            .catch(err => {
                this.error = err;
                this.data = undefined;
                this.isLoading = false;
            });
    }
    loadMoreData(event) {
        const {target} = event;
        target.isLoading = true;
        this.rowOffSet = this.rowOffSet+this.rowLimit;
        this.loadData().then(()=>{target.isLoading = false;})
        console.log("Load more data");
        
    }
    handleSearch(event){
        console.log("Handle search");
        let str = this.template.querySelector('lightning-input').value;
        
        this.searchedKey = str
        console.log("Seark ley",this.searchedKey);
        this.isLoadingg = true;
        if(this.searchedKey){
            this.filteredData = this.data.filter(row => 
                (row.Name && row.Name.toLowerCase().includes(this.searchedKey)) || 
                (row.StageName && row.StageName.toLowerCase.includes(this.searchedKey))
            );
            console.log("After filter");
            
            console.log(this.filteredData);
            
        } else{
            this.filteredData = [...this.data];
        }
        this.isLoadingg = false;
    }
}
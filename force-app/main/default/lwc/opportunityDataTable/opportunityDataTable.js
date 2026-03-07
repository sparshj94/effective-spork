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
                    this.data = updatedData;
                    if(this.searchedKey){
                        this.applySearch();
                    }
                    else{
                        this.filteredData = updatedData;
                    }
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
        let str = this.template.querySelector('lightning-input').value.toLowerCase();
        this.searchedKey = str
        if(this.searchedKey){
            this.enableInfiniteLoading = false;
        } else{
            this.enableInfiniteLoading = true;
        }
        this.applySearch();
    }
    applySearch(){
        if(this.searchedKey){
            this.filteredData = this.data.filter(row => 
                (row.Name && row.Name.toLowerCase().includes(this.searchedKey)) || 
                (row.StageName && row.StageName.toLowerCase().includes(this.searchedKey))
            );

            console.log("apply After filter");
            console.log(this.filteredData);
            
        } else{
            this.filteredData = [...this.data];
            this.enableInfiniteLoading = true;
            console.log("else filter data",this.filteredData);
            
        }
        this.isLoading = false;
        console.log("apply search end");
    }
}
import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/GenericSearchController.searchAccounts';

export default class DatatableSearchPractice extends LightningElement {

    columns = [
        { label:'Name', fieldName:'Name' },
        { label:'Industry', fieldName:'Industry' },
        { label:'Created Date', fieldName:'CreatedDate', type:'date' }
    ];

    data = [
        {Id:'1', Name:'Google', Industry:'Tech', CreatedDate:'2024-01-01'},
        {Id:'2', Name:'Amazon', Industry:'Ecommerce', CreatedDate:'2024-02-01'},
        {Id:'3', Name:'Microsoft', Industry:'Tech', CreatedDate:'2024-03-01'}
    ];

    @track filteredData = [...this.data];

    searchKey;
    field;
    value;

    startDate;
    endDate;

    connectedCallback(){
        this.filteredData = [...this.data];
    }

    // NORMAL SEARCH

    handleSearchKey(event){

        this.searchKey = event.target.value.toLowerCase();

        this.filteredData = this.data.filter(row =>
            row.Name.toLowerCase().includes(this.searchKey)
        );
    }

    // DYNAMIC SEARCH

    handleField(event){
        this.field = event.target.value;
    }

    handleValue(event){
        this.value = event.target.value;
    }

    handleDynamicSearch(){

        searchAccounts({
            field:this.field,
            value:this.value
        })

        .then(result=>{
            this.filteredData = result;
        })

        .catch(error=>{
            console.log(error);
        });

    }

    // DATE FILTER

    handleStartDate(event){
        this.startDate = event.target.value;
    }

    handleEndDate(event){
        this.endDate = event.target.value;
    }

    handleDateFilter(){

        let temp = [...this.data];

        if(this.startDate){

            temp = temp.filter(row =>
                row.CreatedDate >= this.startDate
            );

        }

        if(this.endDate){

            temp = temp.filter(row =>
                row.CreatedDate <= this.endDate
            );

        }

        this.filteredData = temp;
    }

}
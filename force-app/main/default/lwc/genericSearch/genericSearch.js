import { LightningElement, api, track } from 'lwc';

export default class GenericSearch extends LightningElement {

    @api enableTextSearch = false;
    @api enableDateFilter = false;
    @api enableDynamicQuery = false;

    @api searchFields = [];

    @track searchText = '';
    @track startDate;
    @track endDate;

    @track field;
    @track value;

    handleTextSearch(event){
        this.searchText = event.target.value;
    }

    handleStartDate(event){
        this.startDate = event.target.value;
    }

    handleEndDate(event){
        this.endDate = event.target.value;
    }

    handleFieldChange(event){
        this.field = event.target.value;
    }

    handleQueryValue(event){
        this.value = event.target.value;
    }

    handleSearch(){

        const searchParams = {

            text : this.searchText,
            startDate : this.startDate,
            endDate : this.endDate,
            field : this.field,
            value : this.value
        };

        this.dispatchEvent(
            new CustomEvent('search',{
                detail: searchParams
            })
        );
    }

    handleReset(){

        this.searchText = '';
        this.startDate = null;
        this.endDate = null;
        this.field = null;
        this.value = null;

        this.dispatchEvent(
            new CustomEvent('reset')
        );
    }

}
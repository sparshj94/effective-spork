import { LightningElement, track } from 'lwc';
import getFilteredContacts from '@salesforce/apex/FilterTableController.getFilteredContacts';


export default class MultiFilterDataTable extends LightningElement {

    @track filters = [{id:1}];
    @track data = [];
    @track selectedFields = ['CreatedDate'];

    conjunction = 'AND';

    fieldOptions = [
        {label:'First Name', value:'FirstName'},
        {label:'Last Name', value:'LastName'},
        {label:'Email', value:'Email'},
        {label:'Phone', value:'Phone'},
        {label:'Created Date', value:'CreatedDate'}
    ];

    conditionOptions = [
        {label:'Equals', value:'Equals'},
        {label:'Contains', value:'Contains'}
    ];

    conjunctionOptions = [
        {label:'AND', value:'AND'},
        {label:'OR', value:'OR'}
    ];

    columns = [];

    values=[];
    conditions=[];
    filterFields=[];

    handleFieldChange(event){
        this.selectedFields = event.detail.value;

        this.columns = this.selectedFields.map(field=>{
        return {
            label:field,
            fieldName:field,
            editable:true,
            sortable:true
            }
        });
        console.log(JSON.stringify(this.selectedFields));
        this.loadContacts();
        
    }

    addFilter(){
        this.filters = [...this.filters,{id:this.filters.length+1}];
    }

    handleValueChange(event){
        let i = event.target.dataset.index;
        this.values[i] = event.target.value;
    }

    handleConditionChange(event){
        let i = event.target.dataset.index;
        this.conditions[i] = event.target.value;
    }

    handleFieldFilterChange(event){
        let i = event.target.dataset.index;
        this.filterFields[i] = event.target.value;
    }

    handleConjunction(event){
        this.conjunction = event.detail.value;
    }

    connectedCallback(){
        this.loadContacts();
    }

    loadContacts(){
        getFilteredContacts({
                fields:this.selectedFields,
                conditions:this.conditions,
                values:this.values,
                filterFields:this.filterFields,
                conjunction:this.conjunction
            })
            .then(result=>{
                this.data = result;
                console.log(result);
                
            }).catch(err=>{
                console.log(err);
            })
    }

    handleSort(event){
        const { fieldName, sortDirection } = event.detail;

        let data = [...this.data];

        data.sort((a,b)=>{
            return sortDirection === 'asc'
                ? (a[fieldName] > b[fieldName] ? 1 : -1)
                : (a[fieldName] < b[fieldName] ? 1 : -1)
        });

        this.data = data;
    }

    handleSave(event){

        const updatedFields = event.detail.draftValues;

        updatedFields.forEach(draft=>{
            let record = this.data.find(r=>r.Id === draft.Id);
            Object.assign(record,draft);
        });
    }

}
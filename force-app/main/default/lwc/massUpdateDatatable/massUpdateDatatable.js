import { LightningElement, track } from 'lwc';
import updateAccounts from '@salesforce/apex/MassRecordController.updateAccounts';
import deleteAccounts from '@salesforce/apex/MassRecordController.deleteAccounts';

export default class MassUpdateDatatable extends LightningElement {

    columns = [
        { label:'Name', fieldName:'Name' },
        { label:'Industry', fieldName:'Industry' }
    ];

    data = [
        {Id:'1', Name:'Google', Industry:'Tech'},
        {Id:'2', Name:'Amazon', Industry:'Ecommerce'},
        {Id:'3', Name:'Microsoft', Industry:'Tech'}
    ];

    selectedRows = [];

    fieldName;
    fieldValue;

    handleRowSelection(event){

        const selected = event.detail.selectedRows;

        this.selectedRows = selected.map(row => row.Id);

    }

    handleFieldChange(event){
        this.fieldName = event.target.value;
    }

    handleValueChange(event){
        this.fieldValue = event.target.value;
    }

    // MASS UPDATE

    handleMassUpdate(){

        updateAccounts({
            recordIds : this.selectedRows,
            fieldName : this.fieldName,
            value : this.fieldValue
        })

        .then(()=>{
            console.log('Records Updated');
        })

        .catch(error=>{
            console.log(error);
        });

    }

    // MASS DELETE

    handleMassDelete(){

        deleteAccounts({
            recordIds : this.selectedRows
        })

        .then(()=>{
            console.log('Records Deleted');
        })

        .catch(error=>{
            console.log(error);
        });

    }

}
import { LightningElement, api, track } from 'lwc';

export default class GenericDataTable extends LightningElement {

    @api columns = [];
    @api data = [];

    @api enableRowSelection = false;
    @api enableInlineEdit = false;

    @track tableData = [];

    connectedCallback() {
        this.tableData = JSON.parse(JSON.stringify(this.data));
    }

    handleRowClick(event) {

        const rowId = event.currentTarget.dataset.id;

        const selectedRow = this.tableData.find(r => r.id === rowId);

        this.dispatchEvent(
            new CustomEvent('rowclick', {
                detail: selectedRow
            })
        );
    }

    handleRowSelect(event) {

        const rowId = event.target.dataset.id;
        const checked = event.target.checked;

        this.dispatchEvent(
            new CustomEvent('rowselection', {
                detail: { id: rowId, selected: checked }
            })
        );
    }

    enableEdit(event) {

        if(!this.enableInlineEdit) return;

        const rowId = event.currentTarget.dataset.id;

        this.tableData = this.tableData.map(row => {

            if(row.id === rowId){
                return {...row, isEditing:true};
            }

            return row;
        });
    }

    handleChange(event){

        const rowId = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.tableData = this.tableData.map(row => {

            if(row.id === rowId){
                row[field] = value;
            }

            return row;
        });
    }

    saveRow(event){

        const rowId = event.target.dataset.id;

        const row = this.tableData.find(r => r.id === rowId);

        row.isEditing = false;

        this.dispatchEvent(
            new CustomEvent('save', {
                detail: row
            })
        );
    }

    cancelRow(event){

        const rowId = event.target.dataset.id;

        this.tableData = this.tableData.map(row => {

            if(row.id === rowId){
                row.isEditing = false;
            }

            return row;
        });
    }
}
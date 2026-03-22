import { LightningElement, track } from 'lwc';


const MOCK_DATA = [
    { Id: '001A0000001', Name: 'Acme Corp', Phone: '555-0101' },
    { Id: '001A0000002', Name: 'Global Media', Phone: '555-0102' },
    { Id: '001A0000003', Name: 'Salesforce', Phone: '555-0103' }
];


export default class HtmlTable extends LightningElement {

    @track tableData = [];
    originalData = []; // Keeps the pristine data for the Cancel button
    draftValues = {};  // Stores only the changed fields for saving

    connectedCallback() {
        this.initializeData(MOCK_DATA);
    }

    // Wrap raw data with UI state properties
    initializeData(data) {
        this.originalData = JSON.parse(JSON.stringify(data)); // Deep copy
        this.tableData = data.map(record => ({
            ...record,
            isSelected: false,
            isEditingName: false,
            isEditingPhone: false
        }));
    }

    // --- ROW SELECTION LOGIC ---
    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.tableData.forEach(row => { row.isSelected = isChecked; });
    }

    handleRowSelection(event) {
        const recordId = event.target.dataset.id;
        const isChecked = event.target.checked;
        const row = this.tableData.find(r => r.Id === recordId);
        if (row) {
            row.isSelected = isChecked;
        }
    }

    // --- INLINE EDITING LOGIC ---
    handleDoubleClick(event) {
        const recordId = event.currentTarget.dataset.id;
        const fieldName = event.currentTarget.dataset.field;
        
        // Find the row and toggle the specific editing flag
        const row = this.tableData.find(r => r.Id === recordId);
        if (row) {
            row[`isEditing${fieldName}`] = true;
        }
    }

    handleInputChange(event) {
        const recordId = event.target.dataset.id;
        const fieldName = event.target.dataset.field;
        const newValue = event.target.value;

        // 1. Update the UI table data so the user sees their typing
        const row = this.tableData.find(r => r.Id === recordId);
        if (row) {
            row[fieldName] = newValue;
        }

        // 2. Track the change in draftValues
        if (!this.draftValues[recordId]) {
            this.draftValues[recordId] = { Id: recordId };
        }
        this.draftValues[recordId][fieldName] = newValue;
    }

    // Optional: Close input on blur (clicking away)
    handleBlur(event) {
        const recordId = event.target.dataset.id;
        const fieldName = event.target.dataset.field;
        const row = this.tableData.find(r => r.Id === recordId);
        if (row) {
            row[`isEditing${fieldName}`] = false;
        }
    }

    // --- ROW ACTION LOGIC ---
    handleRowAction(event) {
        const recordId = event.target.dataset.id;
        console.log('Action clicked for record:', recordId);
        // Dispatch event or navigate to record page
    }

    // --- SAVE & CANCEL LOGIC ---
    get hasDraftValues() {
        return Object.keys(this.draftValues).length > 0;
    }

    handleCancel() {
        // Revert UI data back to the original pristine data
        this.initializeData(this.originalData);
        // Clear draft tracking
        this.draftValues = {}; 
    }

    handleSave() {
        // Convert draftValues object to an array of records to pass to Apex
        const recordsToUpdate = Object.values(this.draftValues);
        
        console.log('Sending to Apex:', JSON.stringify(recordsToUpdate));

        // TO DO: Call your Apex method imperatively here, e.g.:
        // updateRecords({ records: recordsToUpdate })
        //   .then(() => {
        //       this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: 'Records Updated', variant: 'success' }));
        //       this.draftValues = {}; 
        //       // Refresh original data with new saved values
        //   })

        // Simulating a successful save for this example:
        this.originalData = JSON.parse(JSON.stringify(this.tableData));
        this.draftValues = {};
    }    
}
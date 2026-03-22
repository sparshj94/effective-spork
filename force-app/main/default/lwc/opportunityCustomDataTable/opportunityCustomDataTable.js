import {wire, track,LightningElement } from 'lwc'
import getOpenOpportunities from '@salesforce/apex/OpportunityController.getOpenOpportunity'
import { updateRecord } from 'lightning/uiRecordApi';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class OpportunityCustomDataTable extends LightningElement {

    
    
    @track draftValues = [];
    searchedKey ='';
    @track data = [];
    error = undefined;
    @track filteredData = [];
    rowLimit = 10;
    rowOffSet=0;
    isLoading  = true;
    enableInfiniteLoading = true;
    accountRecordTypeId ='';
    pickListValues  = [];
    selectedRows = []


    stageOptions = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Needs Analysis', value: 'Needs Analysis' },
        { label: 'Value Proposition', value: 'Value Proposition' },
        { label: 'Id. Decision Makers', value: 'Id. Decision Makers' },
        { label: 'Perception Analysis', value: 'Perception Analysis' },
        { label: 'Proposal/Price Quote', value: 'Proposal/Price Quote' },
        { label: 'Negotiation/Review', value: 'Negotiation/Review' },
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' },
    ];

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Stage Name', fieldName: 'StageName', type:"picklist", editable:true, 
            typeAttributes: {
                placeholder: 'Select Stage',
                options: this.stageOptions,
                value: { fieldName: 'StageName' },
                context: { fieldName: 'Id' }
            } 
        },
    ];
    

    connectedCallback() {
        this.loadData();
        console.log("connected callback");
        console.log(this.data);
        
    }
    loadData() {
        this.isLoading = true;
        return getOpenOpportunities({ "limitSize": this.rowLimit, "offSet": this.rowOffSet })
            .then(result => {
                console.log(result);
                
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

    getSelectedRow(event){
       this.selectedRows = event.detail.selectedRows;
    }
    handleCellChange(event) {
        const draftChanges = event.detail.draftValues;
        
        if (draftChanges.length === 0 || this.selectedRows.length <= 1) {
            return; 
        }

        const changedRow = draftChanges[0];
        const changedId = changedRow.Id;

        // Check if the row the user just edited is actually one of the selected rows
        const isEditedRowSelected = this.selectedRows.some(row => row.Id === changedId);

        if (isEditedRowSelected) {
            // Find out WHICH field they changed (e.g., 'StageName') and the new value
            const changedFieldName = Object.keys(changedRow).find(key => key !== 'Id');
            const newValue = changedRow[changedFieldName];

            // Create a Map of our existing draft values so we don't overwrite previous edits
            let currentDraftsMap = new Map(this.draftValues.map(draft => [draft.Id, draft]));

            // Loop through every selected row and apply the new value
            this.selectedRows.forEach(selectedRow => {
                // Get the existing draft for this row, or create a new one if it doesn't exist yet
                let draftUpdate = currentDraftsMap.get(selectedRow.Id) || { Id: selectedRow.Id };
                
                // Update the specific field (StageName) with the new bulk value
                draftUpdate[changedFieldName] = newValue;
                
                // Put it back in the map
                currentDraftsMap.set(selectedRow.Id, draftUpdate);
            });

            // Reassign the draftValues array to trigger the UI update (showing the yellow highlights)
            this.draftValues = Array.from(currentDraftsMap.values());
        }
    }

    handleSave(event) {
        // 1. Grab the array of edits from the datatable
        const draftValues = event.detail.draftValues;

        // 2. Format each edit into the { fields: {...} } structure that UI API requires
        const recordInputs = draftValues.map(draft => {
            // This takes {Id: '006...', StageName: 'Closed Won'} 
            // and turns it into { fields: {Id: '006...', StageName: 'Closed Won'} }
            return { fields: Object.assign({}, draft) };
        });

        // 3. Create an array of update tasks
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));

        // 4. Execute all update tasks simultaneously
        Promise.all(promises)
            .then(() => {
                // Success! Show a green toast message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunities updated successfully',
                        variant: 'success'
                    })
                );

                // 5. Wipe out the draft values to remove the yellow highlights
                this.draftValues = [];
                
                // Clear the checkboxes so the user starts fresh
                this.template.querySelector('c-custom-datatable').selectedRows = [];
                this.selectedRows = [];

                // 6. Refresh the table data to show the new values
                // Since you use imperative Apex, we reset the table and reload
                this.data = [];
                this.rowOffSet = 0;
                this.enableInfiniteLoading = true;
                this.loadData();
            })
            .catch(error => {
                // Uh oh, something went wrong (like a validation rule failed)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating records',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    })
                );
            });
    }

}
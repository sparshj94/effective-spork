import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExistingFiles from '@salesforce/apex/FileManagerController.getExistingFiles';
import linkFilesToRecord from '@salesforce/apex/FileManagerController.linkFilesToRecord';

const COLUMNS = [
    { label: 'File Name', fieldName: 'Title' },
    { label: 'Extension', fieldName: 'FileExtension' },
    { label: 'Upload Date', fieldName: 'CreatedDate', type: 'date' }
];

export default class FileManager extends LightningElement {
    @api recordId; // The ID of the record we are attaching files to
    
    // UI State
    isModalOpen = false;
    isSelectingExisting = false;
    
    // Data State
    @track selectedFiles = []; // The master list of files ready for attachment
    existingFilesData = [];
    columns = COLUMNS;
    
    // Temporary state for the datatable
    tempSelectedRows = []; 

    get modalTitle() {
        return this.isSelectingExisting ? 'Select Existing Files' : 'Attach Files';
    }

    get isUploadDisabled() {
        return this.selectedFiles.length === 0;
    }

    get preSelectedRowIds() {
        return this.selectedFiles.map(file => file.Id);
    }

    // --- MODAL CONTROLS ---
    openModal() {
        this.isModalOpen = true;
        this.selectedFiles = []; // Reset on open
    }

    closeModal() {
        this.isModalOpen = false;
        this.isSelectingExisting = false;
    }

    // --- UPLOAD NEW FILES LOGIC ---
    handleUploadFinished(event) {
        // Get the list of uploaded files from standard component
        const uploadedFiles = event.detail.files;
        
        // Map them to match our pill data structure and add to master list
        let newFiles = uploadedFiles.map(file => ({
            Id: file.documentId,
            Title: file.name
        }));

        // Prevent duplicates in case they somehow upload the exact same file twice
        this.mergeIntoSelectedFiles(newFiles);
    }

    // --- EXISTING FILES LOGIC ---
    @wire(getExistingFiles)
    wiredFiles({ error, data }) {
        if (data) {
            this.existingFilesData = data;
        } else if (error) {
            console.error('Error loading files', error);
        }
    }

    openExistingFilesView() {
        this.isSelectingExisting = true;
        this.tempSelectedRows = [];
    }

    closeExistingFilesView() {
        this.isSelectingExisting = false;
    }

    handleRowSelection(event) {
        // Track what they check in the datatable
        this.tempSelectedRows = event.detail.selectedRows;
    }

    confirmExistingSelection() {
        // Merge the selected rows from datatable into our master pill list
        this.mergeIntoSelectedFiles(this.tempSelectedRows);
        this.isSelectingExisting = false; // Go back to main view
    }

    // --- PILL MANAGEMENT ---
    mergeIntoSelectedFiles(newFilesArray) {
        let currentList = [...this.selectedFiles];
        
        newFilesArray.forEach(newFile => {
            // Only add if it doesn't already exist in our list
            if (!currentList.find(f => f.Id === newFile.Id)) {
                currentList.push({ Id: newFile.Id, Title: newFile.Title });
            }
        });
        
        this.selectedFiles = currentList;
    }

    handleRemovePill(event) {
        // The name attribute on the pill holds the Document ID
        const docIdToRemove = event.target.name;
        
        // Filter it out of our master list
        this.selectedFiles = this.selectedFiles.filter(file => file.Id !== docIdToRemove);
    }

    // --- FINAL UPLOAD (LINKING) ---
    handleFinalUpload() {
        // Extract just the IDs to send to Apex
        const documentIdsToLink = this.selectedFiles.map(file => file.Id);

        linkFilesToRecord({ recordId: this.recordId, documentIds: documentIdsToLink })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({ title: 'Success', message: 'Files successfully attached!', variant: 'success' })
                );
                this.closeModal();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({ title: 'Error attaching files', message: error.body.message, variant: 'error' })
                );
            });
    }
}
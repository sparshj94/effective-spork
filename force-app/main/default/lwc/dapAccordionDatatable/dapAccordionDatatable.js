import { LightningElement, wire, track } from 'lwc';
import getDocuments from '@salesforce/apex/DocumentController.getAllDocuments'
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import propertyType from "@salesforce/schema/Document__c.Document_Type__c";


const actions = [
    { label: 'Edit', name: 'edit' }
];

const columns = [
    { label: 'Title', fieldName: 'Name' },
    { label: 'Valid From', fieldName: 'ValidFromYear__c', type: 'text', sortable: true},
    { label: 'Valid Till', fieldName: 'ValidToYear__c', type: 'text', sortable:true },
    { label: 'Document Type', fieldName: 'Document_Type__c' },
    { label: 'Is Valid', fieldName: 'isActive__c', type: 'boolean' },
    { type: 'action', typeAttributes: { rowActions: actions } }
];
export default class DapAccordionDatatable extends LightningElement {

    columns = columns;

    allDocuments = []
    @track groupByFromYear = [];

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortBy;

    propertyTypePicklist = [{ label: "All Properties", value: "All" }];
    selectedType = 'All';

    validPicklist = [
        { label: 'All', value: 'All' },
        { label: 'Valid', value: 'true' },
        { label: 'Invalid', value: 'false' }
    ];
    selectedValid = 'All';

    @track isModalOpen = false;
    modalHeader = 'New Document';
    selectedRecordId = null;

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: propertyType })
    getPickListVal({error, data}){
        if(data){
            this.propertyTypePicklist = [... this.propertyTypePicklist, ...data.values];
        }
    }

    @wire(getDocuments)
    getDocument({error, data}){
        if(data){
            this.allDocuments  = data;
            this.applyFiltersAndGroup();
        }
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.applyFiltersAndGroup();
    }

    handleValidChange(event) {
        this.selectedValid = event.detail.value;
        this.applyFiltersAndGroup();
    }

    applyFiltersAndGroup() {
        let filteredData = this.allDocuments.filter(doc => {
            let matchType = this.selectedType === 'All' || doc.Document_Type__c === this.selectedType;
            let matchValid = this.selectedValid === 'All' || String(doc.isActive__c) === this.selectedValid;
            return matchType && matchValid;
        });

        this.groupData(filteredData);
    }
    groupData(dataToGroup){
        const grouped = dataToGroup.reduce((acc, obj) => {
            // Grouping directly by your text field
            let yearKey = obj.ValidFromYear__c || 'Unknown';

            if (!acc[yearKey]) {
                acc[yearKey] = { year: yearKey, items: [] };
            }
            acc[yearKey].items.push(obj);
            return acc;
        }, {});
        
        // Sorting alphabetically since years are now text strings (e.g., '2017' < '2018')
        this.groupedData = Object.values(grouped).sort((a, b) => String(a.year).localeCompare(String(b.year)));
    }

    onHandleSort(event) {
        const { fieldName: sortBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortBy = sortBy;

        let parseData = [...this.allDocuments];

        parseData.sort((a, b) => {
            let val1 = a[sortBy] ? a[sortBy] : '';
            let val2 = b[sortBy] ? b[sortBy] : '';
            let reverse = sortDirection === 'asc' ? 1 : -1;
            return val1 > val2 ? reverse : -reverse;
        });

        this.allDocuments = parseData;
        this.applyFiltersAndGroup(); 
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'edit') {
            this.selectedRecordId = row.Id;
            this.modalHeader = 'Edit Document';
            this.isModalOpen = true;
        }
    }

    openNewModal() {
        this.selectedRecordId = null;
        this.modalHeader = 'New Document';
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedRecordId = null;
    }

    handleSuccess() {
        this.closeModal();
        // Don't forget to use refreshApex() here later if you want the table to auto-update after a save!
    }
}
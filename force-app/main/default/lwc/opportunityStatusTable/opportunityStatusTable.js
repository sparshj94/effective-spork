import { LightningElement, track, api, wire } from 'lwc';
import getOpportunity from '@salesforce/apex/DapTestOpportunitiesController.getOpportunities';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import { updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { 
        label: 'Name', 
        fieldName: 'opportunityLink', 
        type: 'url', 
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, 
        sortable: true 
    },
    { 
        label: 'Account Name', 
        fieldName: 'AccountName', 
        type: 'text', 
        sortable: true 
    },
    { 
        label: 'Date', 
        fieldName: 'CreatedDate', 
        type: 'date', 
        sortable: true, 
        typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true } 
    },
    { label: 'Stage', fieldName: 'StageName', sortable: true },
    { label: 'Type', fieldName: 'Type', editable: true, sortable: true },
    { label: 'Qty', fieldName: 'TotalOpportunityQuantity', type: 'number', editable: true, sortable: true },
];

export default class OpportunityStatusTable extends LightningElement {
    @api tabFieldName = 'StageName'; // Configurable in App Builder
    
    @track tabs = [];
    @track allData = [];
    @track filteredData = [];
    @track activeTab = 'All';
    @track activeTabLabel = ''; // To show in the modal header
    
    columns = COLUMNS;
    draftValues = [];
    isNewModalOpen = false;
    isLoading = true;
    sortBy;
    sortDirection;

    @wire(getPicklistValuesByRecordType, { objectApiName: OPPORTUNITY_OBJECT, recordTypeId: '012000000000000AAA' })
    wiredPicklist({ error, data }) {
        if (data && data.picklistFieldValues[this.tabFieldName]) {
            const values = data.picklistFieldValues[this.tabFieldName].values;
            this.tabs = [{ label: 'All Opportunities', value: 'All' }, ...values];
        }
    }

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        this.isLoading = true;
        try {
            const result = await getOpportunity({ rowLimit: 50, rowOffSet: 0 });
            // Flatten Account.Name into AccountName for the table to "see" it
            this.allData = result.map(row => ({
                ...row,
                opportunityLink: `/${row.Id}`,
                AccountName: row.Account ? row.Account.Name : ''
            }));
            this.filterByTab();
        } catch (error) {
            this.showToast('Error', 'Failed to load data', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleTabSwitch(event) {
        this.activeTab = event.target.value;
        this.activeTabLabel = event.target.label;
        this.filterByTab();
    }

    filterByTab() {
        this.filteredData = this.activeTab === 'All' 
            ? [...this.allData] 
            : this.allData.filter(item => item[this.tabFieldName] === this.activeTab);
    }

    // --- SORTING LOGIC ---
    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = [...this.filteredData];
        let keyValue = (a) => a[fieldname];
        let isReverse = direction === 'asc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.filteredData = parseData;
    }

    // --- MODAL & REATION ---
    handleNewOpp() {
        this.isNewModalOpen = true;
    }

    // Getter to check if we should pre-populate the picklist in the modal
    get defaultTabValue() {
        return this.activeTab === 'All' ? '' : this.activeTab;
    }

    handleSuccess() {
        this.isNewModalOpen = false;
        this.showToast('Success', 'Opportunity Created', 'success');
        this.loadData(); // Refresh table
    }

    handleCancelBtn() { this.isNewModalOpen = false; }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
import { LightningElement, wire, track } from 'lwc';
import getDocuments from '@salesforce/apex/DocumentController.getAllDocuments'
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import propertyType from "@salesforce/schema/Document__c.Document_Type__c";

const columns = [
    { label: 'Title', fieldName: 'Name' },
    {
        label: 'Valid From',
        fieldName: 'ValidFromYear__c',
        type: 'number',
        // sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    { label: 'Valid Till', fieldName: 'ValidToYear__c', type: 'number', sortable:true },
];
export default class DapAccordionDatatable extends LightningElement {

    columns = columns;
    @track documentData = []
    @track groupByFromYear = [];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortBy;
    propertyTypePicklist = [ { "attributes": null, "label": "Select Property", "validFor": [], "value": "Select Property" }];
    propertyTypeSearchValue;
    selectedAccordian = '';

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: propertyType })
    getPickListVal({error, data}){
        if(data){
            this.propertyTypePicklist = data.values;
        }
    }

    @wire(getDocuments)
    getDocument({error, data}){
        if(data){
            this.documentData  = data;
            console.log(data);
            this.groupData();
                  
        }
    }

    filterDataTableVal(){
       
    }

    handleSectionToggle(event){
        const openSections = event.detail.openSections;
        // console.log(openSections);
        
    }
    
 
    groupData(){
        const grouped = Object.values(
        this.documentData.reduce((acc, obj) => {
            const key = obj.ValidFromYear__c;

            if (!acc[key]) {
                acc[key] = { year: key, items: [] };
            }

            acc[key].items.push(obj);

            return acc;
        }, {})
        );
        this.groupByFromYear = grouped;
        
        
    }

    handleChange(event) {
        this.propertyTypeSearchValue = event.detail.value;
        this.filterDataTableVal();
        console.log(this.propertyTypeSearchValue);
    }


    sortData(fieldName, direction) {
        let parseData = JSON.parse(JSON.stringify(this.documentData));


        parseData.sort((a, b) => {
            let val1 = a[fieldName] || '';
            let val2 = b[fieldName] || '';


            return direction === 'asc'
                ? val1 > val2 ? 1 : -1
                : val1 < val2 ? 1 : -1;
        });


        this.documentData = parseData;
        this.groupData(); // regroup after sorting
    }


    onHandleSort(event) {
        const { fieldName: sortBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortBy = sortBy;
        this.sortData(sortBy, sortDirection);
    }
}
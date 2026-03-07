import { LightningElement } from 'lwc';


const actions = [
    { label: 'Show Contacts', name: 'show_contacts' },
];

const columns = [
    { label: 'Case Id', fieldName: 'caseNumber', type:'number'},
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Description', fieldName: 'Description', type: 'text' },
    { label: 'Priority', fieldName: 'Priority', type: 'text' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class CaseTable extends LightningElement {
    cases=[]
}
import { LightningElement, wire } from 'lwc';
import editFormFile from './editForm'
import viewModalFile from './viewModal'
import deleteModal from './deleteModal';
import accountModal from './accountModal';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/ContactController.getContacts'
const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Account Name', type:'button', typeAttributes:{label:{fieldName:'AccountName'}, name:'account_view', variant:'base'}},
    { label: 'Lead Source', fieldName: 'LeadSource'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];



export default class ContactTableCyntexa extends NavigationMixin(LightningElement) {

    contacts=[];
    columns = columns;
    contact;
    isWantToViewRecord = false;
    isWantToEditRecord = false;
    isWantToDeleteRecord = false;
    rowLimit = 10;
    offSet = 0;
    error;
    recordId;
    objectApiName = 'Contact';
    accountRecordId;

    

    connectedCallback() {
        this.loadData();
    }

    loadData(){
        return getContacts({"rowLimit":this.rowLimit, "offSet":this.offSet}).then(data=>{
            const updatedData = data.map(row => {
                return {
                    ...row,
                    AccountName: row.Account ? row.Account.Name : '',
                    AccountId : row.Account ? row.Account.Id : null
                };
            });
            
            let updatedRecords = [...this.contacts, ...updatedData];
            this.contacts = updatedRecords;
            this.error = undefined;
            console.log('Imp call',this.contacts);
        }).catch(err=>{
            this.error = err;
            this.contacts = undefined;
        })
        
    }
    loadMoreData(event){
        const {target} = event;
        target.isLoading = true;
        this.offSet = this.offSet+this.rowLimit;
        this.loadData().then(()=>{target.isLoading = false;})
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'account_view':
                this.accountRecordId = row.AccountId;
                this.handleAccountModal();
                console.log("acc view link clicked");
                
                break;
            case 'delete':
                this.isWantToDeleteRecord = true;
                this.recordId = row.Id
                this.handleDeleteModal();
                
                break;
            case 'view':
                // this.showRowDetails(row);
                this.recordId = row.Id
                this.isWantToViewRecord = true;
                console.log('record if for view', this.recordId);
                
                this.handleViewModal(this.recordId);
                console.log('called handle view modal');
                
                break;
            case 'edit':
                this.isWantToEditRecord = true;
                this.recordId = row.Id;
                console.log('record if for edit', this.recordId);
                this.handleEditModal();
                
                console.log('Update clicked');
                break;
                // this.updateRow(row);
            default:
        }
    }

    handleNewContact(){
        console.log('new cont btn clicked');
        
        this[NavigationMixin.Navigate]({
            type:'standard__objectPage',
            attributes:{
                objectApiName : 'Contact',
                actionName:'new'
            }
        })
    }
    handleRecenltyView(){
        console.log('recent btm clicked');
        
        this[NavigationMixin.Navigate]({
            type:'standard__objectPage',
            attributes:{
                objectApiName:"Contact",
                actionName:'list'
            },
            state:{
                filterName:'Recent'
            }
        })
    }
    async handleAccountModal(){
        try {
            const result = await accountModal.open({
                size:"medium",
                recordId:this.accountRecordId
            })
            console.log('in acc view func');
            
        } catch (error) {
            console.log('error', error);
            
        }
    }

    async handleDeleteModal(){
        try {
            const result = await deleteModal.open({
                size:"medium",
                recordId:this.recordId
            })
            if(result==='deleted'){
                this.contacts = [];
                this.offSet =0;
                this.loadData();
                this.showToast('Success','Contact deleted successfully','success');
            }
        } catch (error) {
            this.showToast(
                'Error',
                'Something went wrong',
                'error'
            );
            console.log('error', error);
            
        }
    }

    async handleEditModal(){
        try{
            const result = await editFormFile.open({
                size: 'medium',
                recordId:this.recordId,
                objectApiName : 'Contact'
            });
            console.log('result from edit async func', result);
            if(result==='updated'){
                this.contacts = [];
                this.offSet =0;
                this.loadData();
                this.showToast('Success','Contact Updated successfully','success','View Record', '/'+this.recordId);
            }

        }catch(error){
            this.showToast(
                'Error',
                'Something went wrong',
                'error'
            );
            console.error('Modal Error:', error);
        }
    }
    async handleViewModal() {
        try {
            const result = await viewModalFile.open({
                // LightningModal
                size: 'medium',
                heading: 'View Contact Information',
                description: 'View the contact information',
                recordId:this.recordId
                
            });
            console.log('result from view asysnc func',result);
        } catch (error) {
            console.error('Modal Error:', error);
        }
        
    }

    showToast(title, message, variant, linkLabel, linkUrl) {
        let toastConfig = {
            title: title,
            message: message,
            variant: variant
        }
        if(linkLabel&&linkUrl){
            toastConfig.message = message + '{0}';
            toastConfig.messageData = [
                {
                    url:linkUrl,
                    label:linkLabel
                }
            ]
        }
        this.dispatchEvent( new ShowToastEvent(toastConfig));
    }
}
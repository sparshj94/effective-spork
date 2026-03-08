import LightningModal from 'lightning/modal';
import {api} from 'lwc'
import { deleteRecord } from 'lightning/uiRecordApi';


export default class deleteModal extends LightningModal{

    @api recordId

    handleDismiss(){
        this.close('cancel');
    }
    async handleDelete(){
        try {
            await deleteRecord(this.recordId);
            this.close('deleted')
        } catch (error) {
            console.log('Err from del func',error);
        }
    }
}
import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';
export default class editForm extends LightningModal{

    @api objectApiName ;
    @api recordId;
    handleSuccess(){
        this.close('updated');
    }
}
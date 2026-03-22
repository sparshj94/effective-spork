import {LightningElement, api} from 'lwc'
import LightningModal from 'lightning/modal';

export default class modal extends LightningModal{

    @api contactRecordId;

    handleUploadFinished(){
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        console.log(uploadedFiles.length);
        
    }
}
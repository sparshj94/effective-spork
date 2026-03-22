import { api ,wire} from 'lwc';
import LightningModal from 'lightning/modal';
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = [
    'Account.Name',
    'Account.Phone'
];

export default class accountModal extends LightningModal {

    @api recordId;
    accountName;
    accountPhone;   
    account
    heading = 'View Contact Information'


    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredAccountRecord({error,data}){
        if(data){
            this.account = data;
            this.accountName = data.fields.Name.value;
            this.accountPhone = data.fields.Phone.value;
        }
    }

    handleclose(){
        this.close('accRecord')
    }

}
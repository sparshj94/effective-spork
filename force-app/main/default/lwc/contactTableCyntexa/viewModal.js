import { api ,wire} from 'lwc';
import LightningModal from 'lightning/modal';
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = [
    'Contact.Name',
    'Contact.Phone'
];

export default class ViewModal extends LightningModal {

    @api recordId;
    contactName;
    contactPhone;   
    contact;
    heading = 'View Contact Information'

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredContactRecord({error, data}){
        if(data){
            this.contact = data;
            console.log("Wired Call from api",this.contact);
            
            this.contactName = this.contact.fields.Name.value;
            this.contactPhone = this.contact.fields.Phone.value;
        }
    }

}
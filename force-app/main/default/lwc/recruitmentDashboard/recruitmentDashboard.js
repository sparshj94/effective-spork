import { LightningElement, wire, track } from 'lwc';
import getRecruitmentData from '@salesforce/apex/RecruitmentController.getRecruitmentData';

export default class RecruitmentDashboard extends LightningElement {
    @track recruitmentData = [];

    columns = [
        { label: 'Student Name', fieldName: 'Name', type: 'text' },
        { label: 'Student Email', fieldName: 'Student_Email__c', type: 'email' },
        { label: 'Phone Number', fieldName: 'Student_Phone_Number__c', type: 'phone' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' }
    ];

    @wire(getRecruitmentData)
    wiredData({ error, data }) {
        if (data) {
            this.recruitmentData = data;
            console.log(this.recruitmentData);
            console.log(data);
            
        } else if (error) {
            console.error('Error fetching recruitment data:', error);
        }
    }
}
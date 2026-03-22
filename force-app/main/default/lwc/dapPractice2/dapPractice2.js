import { LightningElement, track, wire } from 'lwc';
import getOpportunity from '@salesforce/apex/Dap2OpportunityController.getOpportunitiesByStage'
import deleteOpportunity from '@salesforce/apex/Dap2OpportunityController.deleteOpportunity';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from "lightning/navigation";
export default class DapPractice2 extends NavigationMixin(LightningElement) {

    @track stageData = [];
    @track stages =[];
    result;
    showModal = false;
    recordId;
    activeStageName = 'Closed Lost'
    // wiredRes;

    // @wire(getOpportunity)
    // getOpp(res){
    //     this.wiredRes = res;
    //     if(res.data){
    //         this.result = res.data;
    //         console.log(data);
    //         // { key:[{}], []}
    //         this.processData(res.data);
    //     }
    // }

    connectedCallback() {
        this.loadData();
    }
    loadData(){
        return getOpportunity().then(res=>{
            this.result = res;
            this.processData(res);
            console.log(res);
            
        }).catch(err=>{
            console.log(err);
            
        })
    }

    processData(data){
        this.stageData = [];
        this.stages = Object.keys(data);
        this.stages.forEach(st=>{
            this.stageData.push({
                name:st,
                records:data[st].slice(0,6),
                open:false
            })
        })
    }

    handleEdit(event) {
        this.recordId = event.target.dataset.id;
        console.log(this.recordId);
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    async handleSuccess() {
        this.showModal = false;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record updated',
                variant: 'success'
            })
        );

        this.loadData();
    }

    async handleDelete(event) {
        let id = event.target.dataset.id;
        await deleteRecord(id);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Deleted',
                message: 'Account deleted',
                variant: 'success'
            })
        );
        this.loadData()
    }

    navigateToRecord(event) {
        let id = event.target.dataset.id;
        console.log(id);
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    handleSetActiveSectionC(event) {
        console.log('clik');
        let name = event.target.dataset.stage;
        this.activeStageName = name;
        console.log(this.activeStageName);
        
        // const accordion = this.template.querySelector('.example-acc');
        // accordion.activeSectionName = this.activeStageName;
        // console.log(this.activeStageName);
        
    }
}





/*





*/
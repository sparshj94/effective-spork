import { LightningElement, wire, track } from 'lwc';
import getOpportunitiesByStage from '@salesforce/apex/Dap2OpportunityController.getOpportunitiesByStage';
import deleteOpportunity from '@salesforce/apex/Dap2OpportunityController.deleteOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class Practice extends LightningElement {
     @track stageData = [];
    @track stages = [];
    wiredResult;

    showModal = false;
    recordId;

    @wire(getOpportunitiesByStage)
    wiredOpps(result) {
        this.wiredResult = result;
        if (result.data) {
            this.processData(result.data);
        }
    }

    processData(data) {
        this.stageData = [];
        this.stages = Object.keys(data);

        this.stages.forEach(stage => {
            this.stageData.push({
                name: stage,
                records: data[stage].slice(0, 5),
                open: false,
                icon: 'utility:add'
            });
        });
    }

    handleStageClick(event) {
        let selected = event.target.dataset.stage;

        this.stageData = this.stageData.map(s => {
            return {
                ...s,
                open: s.name === selected ? !s.open : false,
                icon: s.name === selected && !s.open ? 'utility:close' : 'utility:add'
            };
        });
    }

    toggleStage(event) {
        let selected = event.target.dataset.stage;

        this.stageData = this.stageData.map(s => {
            return {
                ...s,
                open: s.name === selected ? !s.open : false,
                icon: s.name === selected && !s.open ? 'utility:close' : 'utility:add'
            };
        });
    }

    handleEdit(event) {
        this.recordId = event.target.dataset.id;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleSuccess() {
        this.showModal = false;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record updated',
                variant: 'success'
            })
        );

        refreshApex(this.wiredResult);
    }

    handleDelete(event) {
        let id = event.target.dataset.id;

        deleteOpportunity({ oppId: id })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Deleted',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );

                refreshApex(this.wiredResult);
            });
    }

    navigateToRecord(event) {
        let id = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
}
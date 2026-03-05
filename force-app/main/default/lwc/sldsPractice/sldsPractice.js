import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class SldsPractice extends LightningElement {

    @track isBtnClicked = false
    @track isProceedClicked = false
    
    selectedObjApiName =''

    async handleObjSelection(e){
        this.selectedObjApiName = e.target.label;
        this.isBtnClicked = true;
        console.log(this.selectedObjApiName);
        
    }

    handleCancelBtn(){
        this.isProceedClicked = false;
        this.isBtnClicked = false
        console.log("Cancel",this.isProceedClicked);
        
    }
    handleProceedBtn(){
        this.isProceedClicked = true;
        this.isBtnClicked = false
        console.log("Proceed",this.isProceedClicked);
        
    }
    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Success', 
            message: `${this.selectedObjApiName} created successfully!`,
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
        this.handleCancelBtn();
    }


}
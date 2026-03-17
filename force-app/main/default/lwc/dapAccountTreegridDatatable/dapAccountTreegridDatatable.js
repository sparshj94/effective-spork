import { LightningElement, wire, track } from 'lwc';
import getAccData from '@salesforce/apex/AccountController.getAccounts';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { reduceErrors } from 'c/ldsUtils';
const actions = [
    { label: 'View', name: 'show_details' },
    { label: 'Delete', name: 'delete' },
];

const COLS = [
  { fieldName: "Name", label: "Account Name"},
  { fieldName: "NumberOfEmployees", label: "Number Of Employees"},
  { fieldName: "Phone", label: "Phone"},
  { fieldName: "OwnerId", label: "Owner.Name"},
  { fieldName: "BillingCity", label: "BillingCity"},
  { type: "action", typeAttributes: { rowActions: actions, menuAlignment: "right"}},
];



export default class DapAccountTreegridDatatable extends LightningElement {

    @track accountsData = [];
    columns = COLS
    recordId = '';
    objectApiName = 'Account';
    isRecordToView = false;
    rowLimit = 10;
    offSet = 0;

    connectedCallback() {
        this.loadData();
    }

    loadMoreData(event){
        const {target} = event;
        target.isLoading = true;
        this.offSet = this.offSet+this.rowLimit;
        this.loadData().then(()=>{target.isLoading = false;})
    }

    loadData(){
        return getAccData({"rowLimit":this.rowLimit, "offSet":this.offSet}).then(res=>{
            var strData = JSON.parse(JSON.stringify(res));
            strData.map((row,index)=>{
                if(row['ChildAccounts']){
                    row._children = row['ChildAccounts'];
                    delete row.ChildAccounts;
                }
            })
            this.accountsData = strData;
        })
    }

    // @wire(getAccData)
    // getAcountData({error, data}){
    //     if(data){
    //         var strData = JSON.parse(JSON.stringify(data));
    //         strData.map((row,index)=>{
    //             if(row['ChildAccounts']){
    //                 row._children = row['ChildAccounts'];
    //                 delete row.ChildAccounts;
    //             }
    //         })
    //         this.accountsData = strData;
    //     }
    //     console.log(JSON.stringify(this.accountsData));
    // }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row.Id;
        console.log('row==',row);
        
        switch (action) {
            case "show_details":
                this.showDetails(row);
                break;
            case "delete":
                this.deleteRow(row);
                break;
            default:
        }
    }
    async deleteRow(row) {
        try {
            await deleteRecord(row);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account deleted',
                    variant: 'success'
                })
            );
            await refreshApex(this.accountsData);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    // message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }
    }

    showDetails(row){
        this.recordId = row;
        this.isRecordToView = true;
    }
    closeModal(){
        this.isRecordToView = false;
    }
}




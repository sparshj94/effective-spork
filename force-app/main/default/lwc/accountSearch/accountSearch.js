import { LightningElement, track, wire } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountSearchController.searchAccounts';
import getContacts from '@salesforce/apex/AccountSearchController.getContacts';
import getRatings from '@salesforce/apex/AccountSearchController.getRatings';

export default class AccountSearch extends LightningElement {

    name;
    industry;
    rating;

    @track accounts;
    @track contacts;
    ratingOptions = [];

    sortedBy;
    sortedDirection;

    columns = [
        { label: 'Account Name', fieldName: 'Name', sortable: true },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Rating', fieldName: 'Rating' },
        { label: 'Website', fieldName: 'Website', type: 'url' }
    ];

    contactColumns = [
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Phone', fieldName: 'Phone' }
    ];


    @wire(getRatings)
    ratings({data,error}){
        if(data){
            this.ratingOptions = data.map(r => ({label:r,value:r}));
        }
    }


    handleName(event){
        this.name = event.target.value;
    }

    handleIndustry(event){
        this.industry = event.target.value;
    }

    handleRating(event){
        this.rating = event.detail.value;
    }


    searchAccounts(){

        searchAccounts({
            name:this.name,
            industry:this.industry,
            rating:this.rating
        })
        .then(result=>{
            this.accounts = result;
        });
    }


    handleSort(event){

        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;

        let cloneData = [...this.accounts];

        cloneData.sort((a,b)=>{
            let x = a[this.sortedBy] || '';
            let y = b[this.sortedBy] || '';

            return this.sortedDirection === 'asc'
                ? (x > y ? 1 : -1)
                : (x < y ? 1 : -1);
        });

        this.accounts = cloneData;
    }


    handleRowClick(event){

        const row = event.detail.row;

        getContacts({accountId: row.Id})
        .then(result=>{
            this.contacts = result;
        });

    }

}
import { LightningElement, track } from 'lwc';

export default class DemoParent extends LightningElement {

    columns = [
        {label:'Name', fieldName:'Name'},
        {label:'Created Date', fieldName:'CreatedDate'}
    ];

    searchFields = ['Name','Industry'];

    data = [
        {Id:'1', Name:'Google', CreatedDate:'2024-01-10'},
        {Id:'2', Name:'Amazon', CreatedDate:'2024-02-10'},
        {Id:'3', Name:'Microsoft', CreatedDate:'2024-03-10'}
    ];

    @track filteredData = [...this.data];

    handleSearch(event){

        const params = event.detail;

        let temp = [...this.data];

        if(params.text){

            temp = temp.filter(row =>
                row.Name.toLowerCase()
                .includes(params.text.toLowerCase())
            );
        }

        if(params.startDate){

            temp = temp.filter(row =>
                row.CreatedDate >= params.startDate
            );
        }

        if(params.endDate){

            temp = temp.filter(row =>
                row.CreatedDate <= params.endDate
            );
        }

        this.filteredData = temp;
    }

    handleReset(){

        this.filteredData = [...this.data];

    }

}
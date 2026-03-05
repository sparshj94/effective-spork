import { LightningElement ,api, track} from 'lwc';

export default class MyFirstComponent extends LightningElement {
    Name = "";
    @api recordId;
    @track objectc = {"Name":""};
    handle(){
        console.log(JSON.parse(JSON.stringify(this.objectc)));
        console.log(JSON.stringify(this.objectc));
        
        
        this.template.querySelector("c-second-componenet-child").getValue();
        let fn = this.template.querySelector('.name').value;
        this.objectc.Name = fn;
        console.log(fn);
        this.Name = fn;
        console.log("in");
        
        console.log(this.Name);
        console.log(JSON.parse(JSON.stringify(this.objectc)));
        console.log(JSON.stringify(this.objectc));
        
    }
    constructor(){
        super();
    }
    renderedCallback(){
        console.log("Parent component rendered");
        console.log("Record Id....");
        
        console.log("RecordId"+this.recordId); 
    }
    disconnectedCallback(){
        console.log("From parent disconnect call");
    }
    errorCallback(){
        console.log("Error from parent");
    }
}
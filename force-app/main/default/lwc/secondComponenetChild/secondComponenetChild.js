import { LightningElement,api } from 'lwc';

export default class SecondComponenetChild extends LightningElement {
    @api recieveData;
    @api getValue(){
        console.log("Methods of child need to call from parent");
        
    }
}
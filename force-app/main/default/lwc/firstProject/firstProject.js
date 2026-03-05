import { LightningElement } from 'lwc';

export default class FirstProject extends LightningElement {

    myFunc(event){
        console.log(event.target.dataset.arpit);
        let clicked = event.target.dataset.arpit;
        let element = this.template.querySelector(`[data-arpit="${clicked}"]`)
        console.log(element);
        console.log(element.textContent);

    }
}
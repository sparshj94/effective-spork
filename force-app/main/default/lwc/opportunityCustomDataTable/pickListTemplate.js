import { LightningElement, wire, track } from "lwc";


export default class pickListTemplate extends LightningElement{

    handleChange(event){
        const value = event.target.value;
        const context = event.target.dataset.id;
        this.dispatchEvent(
            new CustomEvent('pickListChange',{
                bubbles:true,
                composed:true,
                detail:{
                    value:value,
                    context:context
                }
            })
        )
    }
}
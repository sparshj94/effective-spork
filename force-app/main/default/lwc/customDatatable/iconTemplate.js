import {LightningElement, api} from 'lwc';


export default class IconTemplate extends LightningElement {
    @api typeAttributes;
    // @api rowKeyValue;

    handleIconClick(){
        // const recordId = event.currentTarget.dataset.id;
        // console.log('Child Rec id', recordId);
        
        const ev = new CustomEvent('rowaction', {
            bubbles:true,
            composed:true,
            detail:{
                action:{name:'preview'},
                row: {Id:this.typeAttributes.recordId}
            }
        });
        this.dispatchEvent(ev);
    }
}
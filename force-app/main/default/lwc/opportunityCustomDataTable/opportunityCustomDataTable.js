import LightningDatatable from 'lightning/datatable'
import pickListTemplate from './pickListTemplate.html';
export default class OpportunityCustomDataTable extends LightningDatatable {
    static customTypes = {
        pickListColumn :{
            template : pickListTemplate,
            standardCellLayout:true,
            typeAttributes : ['options', 'value', 'context']
        }
    }
}
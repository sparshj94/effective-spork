import LightningDatatable from 'lightning/datatable';
import picklistView from './pickListView'
import picklistEdit from './pickListEdit'
import iconTemplate from './iconTemplate.html'
export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: picklistView,
            editTemplate: picklistEdit,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context']
        },
        icon:{
            template : iconTemplate,
            standardCellLayout:false,
            typeAttributes:['iconName','recordId']
        }
    };
}
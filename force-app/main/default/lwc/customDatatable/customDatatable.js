import LightningDatatable from 'lightning/datatable';
import picklistView from './pickListView'
import picklistEdit from './pickListEdit'

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: picklistView,
            editTemplate: picklistEdit,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context']
        }
    };
}


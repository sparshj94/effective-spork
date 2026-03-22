import { LightningElement, track } from 'lwc';

export default class MultiSelectCombobox extends LightningElement {

    @track isOpen = false;
    @track selectedValues = [];



    options = [
        { label: 'Option 1', value: 'opt1' },
        { label: 'Option 2', value: 'opt2' },
        { label: 'Option 3', value: 'opt3' }
    ];

    // toggleDropdown() {
    //     this.isOpen = !this.isOpen;
    //     console.log(this.isOpen);
        
    // }

    get comboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${this.isOpen ? 'slds-is-open' : ''}`;
    }

    toggleDropdown(event) {
        event.stopPropagation();
        this.isOpen = !this.isOpen;
    }   


    handleSelect(event) {
        const value = event.target.value;

        if (event.target.checked) {
            this.selectedValues = [...this.selectedValues, value];
        } else {
            this.selectedValues = this.selectedValues.filter(v => v !== value);
        }
    }

    get selectedLabels() {
        return this.options
            .filter(opt => this.selectedValues.includes(opt.value))
            .map(opt => opt.label)
            .join(', ');
    }

    connectedCallback() {
        window.addEventListener('click', this.handleOutsideClick.bind(this));
    }

    handleOutsideClick() {
        this.isOpen = false;
    }

}
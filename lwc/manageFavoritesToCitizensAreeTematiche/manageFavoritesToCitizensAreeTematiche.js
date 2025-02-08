import { LightningElement, api, track } from 'lwc';
//CLASSES

//LABELS
import save from '@salesforce/label/c.manageFavorities_Save';
import next from '@salesforce/label/c.manageFavorities_Next';
import back from '@salesforce/label/c.manageFavorities_Back';
import esc from '@salesforce/label/c.manageFavorities_Esc';
import headerTable2 from '@salesforce/label/c.manageFavorities_HeaderTable2';

//CONS
const columnsForTable2 = [
    { label: headerTable2, fieldName: 'Name__c', sortable: 'false' }
];

export default class ManageFavoritesToCitizensAreeTematiche extends LightningElement {
    @api table2data;
    @api preselectedrowstable2;
    // @track textToSearch;
    @track tmpSelected = [];

    @track label = {
        esc,
        back,
        next,
        save,
        headerTable2
    }

    connectedCallback() {
        this.dataTable2 = this.table2data;
        this.columnsTable2 = columnsForTable2;
        if (this.preselectedrowstable2 != null && this.preselectedrowstable2.length > 0) {
            this.preselectedrowstable2 = this.preselectedrowstable2;
            this.tmpSelected.push(this.preselectedrowstable2);
        } else {
            this.preselectedrowstable2 = [];
        }
    }

    handleEsc(event) {
        const handleEscEvent = new CustomEvent('handleescorback', {
            detail: {
                action: 'esc'
            }
        });
        this.dispatchEvent(handleEscEvent);
    }

    handleBack(event) {
        const handleEscEvent = new CustomEvent('handleescorback', {
            detail: {
                action: 'back',
                updateSelected: this.tmpSelected
            }
        });
        this.dispatchEvent(handleEscEvent);
    }

    handleSaveOrNext(event) {
        var el = this.template.querySelector('lightning-datatable');
        var sel = el.getSelectedRows();

        const handleSaveOrNextEvent = new CustomEvent('handlesaveornext', {
            detail: {
                selectedItems: sel,
                numberNextStep: 2
            }
        });
        this.dispatchEvent(handleSaveOrNextEvent);
    }

    selectedRowsEvent() {
        // console.log('selectedRowHandler');
        var el = this.template.querySelector('lightning-datatable');
        var sel = el.getSelectedRows();
        // console.log('sel -> ', sel);
        if ( sel.length > 0 ) {
            let tmpList = [];
            sel.forEach(e=> {
                tmpList.push(e.Id);
            })
            this.tmpSelected = tmpList;
        } else {
            // console.log('empty table');
            this.tmpSelected = [];
        }
    }

}
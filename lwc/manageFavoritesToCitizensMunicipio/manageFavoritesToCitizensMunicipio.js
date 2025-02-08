import { LightningElement, api, track } from 'lwc';
//CLASSES

//LABELS
import save from '@salesforce/label/c.manageFavorities_Save';
import next from '@salesforce/label/c.manageFavorities_Next';
import back from '@salesforce/label/c.manageFavorities_Back';
import esc from '@salesforce/label/c.manageFavorities_Esc';
import headerTable1 from '@salesforce/label/c.manageFavorities_HeaderTable1';
//CONS
const columnsForTable1 = [
    { label: headerTable1, fieldName: 'Name__c', sortable: 'false' }
];

export default class ManageFavoritesToCitizensMunicipio extends LightningElement {
    @api table1data;
    @api preselectedrowstable1;    
    @track label = {
        esc,
        back,
        next,
        save,
        headerTable1
    }

    connectedCallback() {
        this.dataTable1 = this.table1data;
        this.columnsTable1 = columnsForTable1;
        if (this.preselectedrowstable1 != null && this.preselectedrowstable1.length > 0) {
            this.rowsTable1PreSelected = this.preselectedrowstable1;
        } else {
            this.rowsTable1PreSelected = [];
        }        
    }    
    
    handleEsc(event) {
        const handleEscEvent = new CustomEvent('handleescorback', {
            detail : {
                action: 'esc'
            }
        });
        this.dispatchEvent(handleEscEvent); 
    }

    handleBack(event) {
        const handleEscEvent = new CustomEvent('handleescorback', {
            detail : {
                action: 'back'
            }
        });
        this.dispatchEvent(handleEscEvent); 
    }

    handleSaveOrNext(event) {
        var el = this.template.querySelector('lightning-datatable');
        var sel = el.getSelectedRows();
        
        const handleSaveOrNextEvent = new CustomEvent('handlesaveornext', {
            detail : {
                selectedItems : sel,
                numberNextStep : 1
            }
        });            
        this.dispatchEvent(handleSaveOrNextEvent); 
    }

}
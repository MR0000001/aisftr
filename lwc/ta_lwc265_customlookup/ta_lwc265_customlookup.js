import { LightningElement, api, track } from 'lwc';
import fetchRecords from '@salesforce/apex/TA_LWCC265_CustomLookup.fetchRecords';
import noResultsFound from '@salesforce/label/c.TA_NoResultsFound';

export default class ta_lwc265_customlookup extends LightningElement {
   
    @api objectName;
    @api objectIdentifier;
    @api fieldName;
    @api value;
    @api condition;
    @api recordLimit;
    @api label;
    @api placeholder;
    @api className;
    @api required = false;
    @api minDigits = 0;
    @api defaultValue;
    @track searchString;
    @track selectedRecord;
    @track recordsList;
    @track message;
    @track showPill = false;
    @track showSpinner = false;
    @track showDropdown = false;
    @track inputTimeout;

    connectedCallback() {
        if(this.defaultValue) {
            this.selectedRecord = this.defaultValue;
            this.showPill = true;
        }
        if(this.value)
            this.fetchData();
    }

    searchRecords(event) {
        this.searchString = event.target.value;
        // FD 08/08/2022 - INC000091951624 - START
        window.clearTimeout(this.inputTimeout);
        this.inputTimeout = setTimeout(() => {           
            if(this.searchString) {
                this.fetchData();
            } else {
                this.showDropdown = false;
            } 
        }, 2000);
        // FD 08/08/2022 - INC000091951624 - END
    }

    selectItem(event) {
        if(event.currentTarget.dataset.key) {
    		var index = this.recordsList.findIndex(x => x.value === event.currentTarget.dataset.key)
            if(index != -1) {
                this.selectedRecord = this.recordsList[index];
                this.value = this.selectedRecord.value;
                this.showDropdown = false;
                this.showPill = true;            
                this.selectedEvent(this.selectedRecord.value)
            }
        }
    }

    removeItem() {
        this.showPill = false;
        this.value = '';
        this.selectedRecord = '';
        this.searchString = '';
    }

    showRecords() {
        if(this.recordsList && this.searchString) {
            this.showDropdown = true;
        }
    }

    blurEvent() {
        this.showDropdown = false;
    }

    fetchData() {
        
        this.message = '';
        this.recordsList = [];

        if(this.searchString.length < this.minDigits) return;
        this.showSpinner = true;

        fetchRecords({
            objectName : this.objectName,
            objectIdentifier : this.objectIdentifier,
            filterField : this.fieldName,
            searchString : this.searchString,
            value : this.value,
            condition : this.condition,
            recordLimit : this.recordLimit
        })
        .then(result => {
            if(result && result.length > 0) {
                if(this.value) {
                    this.selectedRecord = result[0];
                    this.showPill = true;
                } else {
                    this.recordsList = result;
                }
            } else {
                this.message = `${noResultsFound} ${this.searchString}`;
            }
            this.showSpinner = false;
        }).catch(error => {
            console.log('@@@ error', error);
            this.message = error.message;
            this.showSpinner = false;
        })
        if(!this.value) {
            this.showDropdown = true;
        }
    }

    selectedEvent(value) {
        const sEvent = new CustomEvent('selected', {detail: {value}});
        this.dispatchEvent(sEvent);
    }
                
}
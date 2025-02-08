import { LightningElement,api,track,wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//APEX METHODS
import getCurgetFavorities from '@salesforce/apex/ManageFavoritesToCitizensController.getFavorities';
import saveFavorities from '@salesforce/apex/ManageFavoritesToCitizensController.saveFavorities';
//FIELDS
import PersonContactId_field from '@salesforce/schema/Account.PersonContactId';
//LABELS
import title from '@salesforce/label/c.manageFavorities_Title';
import step0 from '@salesforce/label/c.manageFavorities_0Step';
import step1 from '@salesforce/label/c.manageFavorities_1Step';
import saveSuccess from '@salesforce/label/c.manageFavorities_SaveSuccess';
import saveError from '@salesforce/label/c.manageFavorities_SaveError';
//CONST

export default class manageFavoritesToCitizensWrapper extends LightningElement {
    @api recordId;
    @api isLoading;
    
    @track currentStep = "0";
    @track actualNumberStep = 0;
    @track itemsToDelete = [];
    @track itemsToInsert = [];
    @track textSaveOrNext;
    @api stepNumber0=false;
    @api stepNumber1=false;    
    @api table1data;
    @api preselectedrowstable1;
    @api table2data;
    @api preselectedrowstable2;
    @track fields = [PersonContactId_field];
    @track label = {
        title,
        step0,
        step1,
        saveSuccess,
        saveError
    }
    originalSelected =  [];
    finalSelected = [];
    PersonContactId;


    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (data) {
            // console.log("@@@data "+JSON.stringify(data));
            // console.log('PersonContactId -> ', data.fields.PersonContactId.value);
            this.PersonContactId = data.fields.PersonContactId.value;
            getCurgetFavorities({PersonContactId: data.fields.PersonContactId.value})
            .then(result =>{
                // console.log('result -> ',result);
                this.table1data=result[0];
                if( result[1].length > 0 ) {
                    this.preselectedrowstable1 = result[1];
                    this.originalSelected[0] = (result[1]);
                } else {
                    this.preselectedrowstable1 = [];
                    this.originalSelected[0] = [];
                }
                // console.log('this.preselectedrowstable1 -> ', this.preselectedrowstable1);

                this.table2data=result[2];
                if ( result[3].length > 0 ) {
                    this.preselectedrowstable2 = result[3];
                    this.originalSelected[1] = (result[3]);
                } else {
                    this.preselectedrowstable2 = [];
                    this.originalSelected[1] = [];
                }

                this.manageStepObjects(0);
                this.isLoading = false;
            });
        } else if (error) {
            // console.log("@@@error "+JSON.stringify(data));
            this.isLoading = false;
        }
    }

    connectedCallback() {
        this.isLoading = true;
    }

    handleEscOrBack(event) {
        let action = event.detail.action;
        // console.log('action -> ', action);
        // console.log('event.detail.updateSelected -> ', event.detail.updateSelected);
        if ( action == 'back' ) {
            this.actualNumberStep--;
            if ( this.actualNumberStep == 0 ) {
                //restore
                this.preselectedrowstable1 = this.finalSelected[this.actualNumberStep];
                //update
                if ( event.detail.updateSelected != undefined ) { 
                    this.preselectedrowstable2 = event.detail.updateSelected;
                }
            } if ( this.actualNumberStep == 1 ) {

            }
            this.manageStepObjects(this.actualNumberStep);
        } else if ( action == 'esc' ) {
            this.closeModal();
        }
    }

    closeModal() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    handleSaveOrNext(event){
        // console.log('handleSaveOrNext');
        let listToSave = event.detail.selectedItems;
        let tmpListToSave= [];
        if ( listToSave != undefined && listToSave.length > 0 ) {
            listToSave.forEach(e=> {
                tmpListToSave.push(e.Id);
            })
        }
        // console.log('this.actualNumberStep -> ', this.actualNumberStep);
        this.finalSelected[this.actualNumberStep] = tmpListToSave;
        let numberNextStep = event.detail.numberNextStep;
        this.manageStepObjects(numberNextStep);
    }

    manageStepObjects(stepNumber){
        if ( stepNumber == 0 ) {
            this.stepNumber0 = true;
            this.stepNumber1 = false;
            this.actualNumberStep = stepNumber;
            this.currentStep = "0";
        //save
        } else if ( stepNumber == 1 ) {
            this.stepNumber0 = false;
            this.stepNumber1 = true;
            this.actualNumberStep = stepNumber;
            this.currentStep = "1";
        } else {
            this.isLoading = true;
            this.saveChanges();
        }
    }

    saveChanges(){
        saveFavorities({ originalSelected: this.originalSelected, finalSelected : this.finalSelected, PersonContactId : this.PersonContactId })
        .then(result =>{
            // console.log('result -> ',result);
            this.showToast('Success', saveSuccess, 'success');
            this.isLoading = false;
            this.closeModal();            
        })
        .catch(error => {
            // console.log('error -> ', error);
            // console.log('error -> ', error.body.message);
            this.showToast('Errore', saveError + error.body.message, 'error');
            this.isLoading = false;
        });
    }
    
    showToast(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

}
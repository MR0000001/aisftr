import { LightningElement,api,wire, track} from 'lwc';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/XC_LWCC003_StrikeLookup.fetchLookupData';
import noRecordFound from '@salesforce/label/c.XC_CL_StrikeLookup_NoRecordFound';
const DELAY = 300; // dealy apex callout timing in miliseconds  
export default class Xc_LWC003_StrikeLookup extends LightningElement {
    label = {
        noRecordFound 
    }; 
     // public properties with initial default values 
     @api label = 'custom lookup label';
     @api placeholder = 'search...'; 
     @api iconName = 'standard:account';
     @api sObjectApiName = 'Account';
     @api accountNameToShow = '';
     @api defaultRecordId = '';
     @api keyToSearch = '';
     // private properties 
     lstResult = []; // to store list of returned records   
     @api hasRecords = false; 
     searchKey=''; // to store input field value    
     isSearchLoading = false; // to control loading spinner  
     delayTimeout;
     selectedRecord = {}; // to store selected lookup record in object formate 
     @track mapData= [];
    // initial function to populate default selected lookup record if defaultRecordId provided  
     connectedCallback(){
          /*if(this.defaultRecordId != ''){
             fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName })
             .then((result) => {
                 if(result != null){
                     this.selectedRecord = result;
                     this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                 }
             })*/
             /*.catch((error) => {
                 this.error = error;
                 this.selectedRecord = {};
             });
          }*/
     }
     // wire function property to fetch search record based on user input
     @wire(fetchLookupData, { searchKey: '$searchKey' , sObjectApiName : '$sObjectApiName', key : '$keyToSearch'})
      searchResult(value) {
         const { data, error } = value; // destructure the provisioned value
         this.isSearchLoading = false;
         this.mapData = [];
         this.lstResult = [];
         this.hasRecords = false;
         if (data) {
              console.log('test-->'+data.hasOwnProperty); 
              //this.lstResult = data; 
              for(var key in data){
                this.hasRecords = true;
                this.lstResult.push(data[key]);
                this.mapData.push({value:data[key], key:key}); //Here we are creating the array to show on UI.
             }
          }
         else if (error) {
             console.log('(error---> ' + JSON.stringify(error));
          }
     };
        
   // update searchKey property on input field change  
     handleKeyChange(event) {
         // Debouncing this method: Do not update the reactive property as long as this function is
         // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
         this.isSearchLoading = true;
         window.clearTimeout(this.delayTimeout);
         const searchKey = event.target.value;
         this.delayTimeout = setTimeout(() => {
         this.searchKey = searchKey;
         }, DELAY);
     }
     // method to toggle lookup result section on UI 
     toggleResult(event){
         const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
         const clsList = lookupInputContainer.classList;
         const whichEvent = event.target.getAttribute('data-source');
         switch(whichEvent) {
             case 'searchInputField':
                 clsList.add('slds-is-open');
                break;
             case 'lookupContainer':
                 clsList.remove('slds-is-open');    
             break;                    
            }
     }
    // method to clear selected lookup record  
    handleRemove(){
     this.searchKey = '';    
     this.selectedRecord = {};
     this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
     
     // remove selected pill and display input field again 
     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
      searchBoxWrapper.classList.remove('slds-hide');
      searchBoxWrapper.classList.add('slds-show');
      const pillDiv = this.template.querySelector('.pillDiv');
      pillDiv.classList.remove('slds-show');
      pillDiv.classList.add('slds-hide');
     }
     // method to update selected record from search result 
     handelSelectedRecord(event){   
         var objId = event.target.getAttribute('data-recid'); // get selected record Id 
         this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
         this.accountNameToShow = this.selectedRecord.Name;
         if(this.selectedRecord.XC_VAT_Number2__c != null || this.selectedRecord.XC_VAT_Number2__c != undefined){
            this.accountNameToShow = this.accountNameToShow + ' - ' + this.selectedRecord.XC_VAT_Number2__c;
          }else if (this.selectedRecord.XC_VAT_Number1__c != null || this.selectedRecord.XC_VAT_Number1__c != undefined){
            this.accountNameToShow = this.accountNameToShow + ' - ' + this.selectedRecord.XC_VAT_Number1__c;
          }else if (this.selectedRecord.IdentityNumber__c != null || this.selectedRecord.IdentityNumber__c != undefined){
            this.accountNameToShow = this.accountNameToShow + ' - ' + this.selectedRecord.IdentityNumber__c;
          }
         this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
         this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
     }
     /*COMMON HELPER METHOD STARTED*/
     handelSelectRecordHelper(){
         this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
         const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
         searchBoxWrapper.classList.remove('slds-show');
         searchBoxWrapper.classList.add('slds-hide');
         const pillDiv = this.template.querySelector('.pillDiv');
         pillDiv.classList.remove('slds-hide');
         pillDiv.classList.add('slds-show');     
     }
     // send selected lookup record to parent component using custom event
     lookupUpdatehandler(value){    
         const oEvent = new CustomEvent('lookupupdate',
         {
             'detail': {selectedRecord: value}
         }
         );
     this.dispatchEvent(oEvent);
     }
}
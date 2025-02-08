import { LightningElement, track, api } from 'lwc';
//import findRecords from '@salesforce/apex/CaseDetailsController.findRecords';
export default class CustomLookup extends LightningElement {
    @track records;
    @api instructorUser;
    @api allrecords;
    @api synonymMap;
    @track error;
    @api selectedrecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:picklist_type";
    @api clabel;
    @api disable;
    @track searchKey;
    @api dontShowRemove;
    @api bottomUp = false;
    @track alreadyFired = false;
   
    
    renderedCallback(){
        if(this.bottomUp && !this.alreadyFired && !this.selectedrecord){
            this.template.querySelector("c-search-taxonomy-l-w-c").addEventListener("click", this.showAll());
            this.alreadyFired = true;
        }        
   }

    handleOnchange(event){
        //event.preventDefault();
        var searchKey = String(event.detail.value).trim();
        var tempList=[];
        if(searchKey != "undefined" && searchKey != null && searchKey != '' && searchKey.length>2){    
            var searchKeyLC = searchKey.toLowerCase();
            if(this.allrecords != null) {
                tempList = this.allrecords.filter(item => item.Synonymous.toLowerCase().includes(searchKeyLC));
            }
            tempList = tempList.filter((v,i,a)=>a.findIndex(t=>(t.Name === v.Name))===i);
        }else{
            if((searchKey == "undefined" || searchKey == null || searchKey == '' || searchKey.length==0) && this.bottomUp){
                tempList = tempList.filter((v,i,a)=>a.findIndex(t=>(t.Name === v.Name))===i); 
            }
        } 
        this.records = tempList;
    }

    showAll(){
        if(this.bottomUp && this.allrecords!=undefined && !this.disable){
            var tempList=[];  
            tempList = this.allrecords.filter((v,i,a)=>a.findIndex(t=>(t.Name === v.Name))===i);
            this.records = tempList;
        }
    }
    handleSelect(event){
        var selectedrecordId = event.detail;
        /* eslint-disable no-console*/
        this.selectedrecord = this.records.find( record => record.Id === selectedrecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedrecordEvent = new CustomEvent(
            "selectedrec",
            {
                //detail : selectedrecordId
                detail : { recordId : selectedrecordId, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedrecordEvent);
    }

    handleRemove(event){
        event.preventDefault();
        this.selectedrecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedrecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedrecordEvent);
    }

    @api Remove(){
        this.selectedrecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        if(this.selectedrecord == false){
            this.template.querySelector("c-search-taxonomy-l-w-c").Remove();
        }
        
        const selectedrecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedrecordEvent);
    }


}
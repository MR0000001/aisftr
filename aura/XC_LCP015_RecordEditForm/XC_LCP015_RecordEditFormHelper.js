({	
    init : function(component, event) {
    
    let idToPass = component.get("v.IdFromMobile");
    if(component.get("v.recordId")===null){
        component.set("v.recordId", idToPass );
    }
    let action = component.get("c.getFieldsSetValues");
    let fieldset=component.get("v.fieldsSet");
    let object=component.get("v.typeObject");
    action.setParams({objName: object,
                      fieldsSetName: fieldset});
    action.setCallback(this, function(response) {
        let state = response.getState();
        let res = response.getReturnValue();
        
        if(state=='SUCCESS'){
            console.log('@@@res-->'+res);
            component.set("v.fields", res);
            this.populateFieldSet(component,event,'v.body');
        } else {
            console.log("Error: couldn't retrive fieldset");	
        }
    });
    
    $A.enqueueAction(action);
},
    handleCancelClick : function(component, event) {
      let disabled=component.get("v.disabled");
      component.set("v.disabled",!disabled);
      component.set('v.setReadOnly',true);
        
  },
    navigatePage : function(component, event) {
       location.reload(true); 
         

        
  },
  
  handleEditClick : function(component, event) {
      let disabled=component.get("v.disabled");
      component.set("v.disabled",!disabled);
      component.set('v.setReadOnly',false); 
  },
  
  showErrorOnField : function(component, fieldName){        
      let cmpTarget = component.find(fieldName);
      console.log('result.fieldName->' + fieldName);
      $A.util.addClass(cmpTarget, 'slds-has-error ');
  },
  
  removeRedBox : function(component, event){
      let mapField = component.get("v.fields");
      console.log('entrato in removeRedBox su' + mapField);
       for(let i=0;i<mapField.length;i++){
          let cmpTarget = component.find(mapField[i]); 
          console.log('rimuovo per->' + cmpTarget);
          $A.util.removeClass(cmpTarget, 'slds-has-error ');
      }
      
  },
  
  populateFieldSet : function(component, event, bodyName){
      let cmp = component; 
      let item = component.get("v.fields");
      console.log('@@@Item-->'+item);
      
      for(let i=0;i<item.length;i++){
          $A.createComponents([
              ["lightning:layoutItem",{
                  "flexibility":"auto", 
                  "size":"12",
                  "smallDeviceSize":"5",
                  "mediumDeviceSize":"5",
                  "largeDeviceSize":"6",
                  "padding" : "horizontal-small",
                  
              }],
              ["lightning:inputField",{
                  "aura:id": item[i],
                  "fieldName": item[i],
                  "disabled" : true
              }]
          ],
                              function(components, status, errorMessage){ 
                                  let layout = components[0];
                                  let input = components[1];  
                                  layout.set("v.body", input);
                                  let div1 = component.get(bodyName);
                                  div1.push(layout);                                       
                                  cmp.set(bodyName, div1);
                                  
                                  
                              } 
                             );
      }
      
  },
  
  setReadOnlyForInput : function(component, event){
      
      let item = component.get("v.fields");
      console.log('@@@setReadOnly-->'+component.get("v.setReadOnly"));
      if(component.get("v.setReadOnly")){
          
          for(let i=0;i<item.length;i++){
              console.log('itemmm = '+item[i]);
              component.find(item[i]).set("v.disabled",true);
          }    
      }else{
          for(let index=0;index<item.length;index++){
              console.log('itemmm = '+item[index]);
              component.find(item[index]).set("v.disabled",false);
          }    
          
      }
      
      
      
      
  },
  
  
  checkFieldsBeforeSave : function(component, event, mapField) {
      this.removeRedBox(component, event);
      console.log("@@@ fieldMap @@@ -->" + mapField );
      let checkFields = false;
      let country = (JSON.parse(mapField))["XC_Country__c"];
      let streetType = (JSON.parse(mapField))["XC_StreetType__c"];
      let address =  (JSON.parse(mapField))["XC_Address__c"];
      let streetNumber = (JSON.parse(mapField))["XC_StreetNumber__c"];
      let city = (JSON.parse(mapField))["XC_City__c"];
      let municipality = (JSON.parse(mapField))["XC_Municipality__c"];
      let zipCode = (JSON.parse(mapField))["XC_ZipCode__c"];
      let province = (JSON.parse(mapField))["XC_Province__c"];
      console.log('@@@Entrato in checkFieldsBeforeSave');
      console.log(streetType);
      console.log(address);
      
      if (( streetType != "" && address !== null && streetNumber !== null
           && city !== null && zipCode !== null && province != "" && country != ""
           && municipality !== null)  ||
          (streetType == "" && address === null && streetNumber === null
           && city === null && zipCode === null && province == "" && country == ""
           && municipality === null)){
          console.log('entrato in checkFields True');
          checkFields = true;
      }
      
      else {

          this.showErrorOnField(component, 'XC_StreetType__c');
          this.showErrorOnField(component, 'XC_Address__c');
          this.showErrorOnField(component, 'XC_StreetNumber__c');
          this.showErrorOnField(component, 'XC_City__c');
          this.showErrorOnField(component, 'XC_ZipCode__c');
          this.showErrorOnField(component, 'XC_AProvince__c');
          this.showErrorOnField(component, 'XC_Municipality__c');
          this.showErrorOnField(component, 'XC_Country__c');          

          
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
              title : $A.get("$Label.c.XC_CL_Warning"),
              message: $A.get("$Label.c.XC_CL_ErrorAddressFields"),
              duration:' 1000',
              key: 'info_alt',
              type: 'error',
              mode: 'pester'
          });
          toastEvent.fire();
      }
      
      return checkFields;
      
      
  },
  
  
  handleSave  : function(component, event) { 
      component.find("editForm").submit();
  },
  
  onSubmitHelper : function(component, event) {
      component.set("v.isOpen", false);
      this.removeRedBox(component, event);
      console.log("@@@ stringify @@@ :"+JSON.stringify(event.getParam("fields")));
      let checkFields = this.checkFieldsBeforeSave(component,event,JSON.stringify(event.getParam("fields")));
      if (checkFields){
          
          this.handleCancelClick(component,event);
          component.set("v.successMessage", $A.get("$Label.c.XC_CL_Address_Created"));
        
          this.toastSuccess(component);
          
          
      }
  },
    
  onValidate : function(component, event) {
      let item = component.get("v.fields");
      let map = {};
      for(let i=0;i<item.length;i++){
           
           map[item[i]] = component.find(item[i]).get("v.value");
       }    
      
      let checkFields = this.checkFieldsBeforeValidate(component,event,map);
      if (checkFields){
       
       this.callToAddressValidationAction(component, map);
          
      }
  },

  callToAddressValidationAction : function(component, map){
    let action = component.get("c.callToAddressValidationDC");
   
    action.setParams({
        //"leadId" : component.get("v.recordId"),
        "fieldMap": map
    });
    action.setCallback(this, function(response) {
        let state = response.getState();
        let res = response.getReturnValue();
        
        if(state=='SUCCESS'){
            
            if(res.success){
                 component.set("v.successMessage", $A.get("$Label.c.XC_CL_Address_ValidationOK"));
                 this.toastSuccess(component);
                  component.set('v.setReadOnly',true); 
                  component.set("v.validationOK",true);    
                
            }else{
                
                this.toastError(component, res.addressResult );
                if(!res.success){   //res.addressResult == $A.get("$Label.c.XC_CL_AddressOutServer")){
                         component.set("v.showCheckbox", true);
                     }
            }
          
        } else {
            console.log("Error: couldn't retrive this address");  
        }
    });
    
    $A.enqueueAction(action);
      
  },
  
  toastSuccess : function(component){
      console.log('success');
      let toastEvent = $A.get("e.force:showToast");
      if (toastEvent){
          toastEvent.setParams({
              title : 'Success',
              message: component.get("v.successMessage"),
              messageTemplate: 'Record {0} created! See it {1}!',
              duration: '100',
              key: 'info_alt',
              type: 'success',
              mode: 'pester'
          });
          toastEvent.fire();
      } else {    //toast implementation for a standalone app 
          component.set("v.isOpen", true);
          
      }
    
      
  },
      toastError : function(component,message){
      console.log('success');
      let toastEvent = $A.get("e.force:showToast");
      if (toastEvent){
          toastEvent.setParams({
              title : 'Warning!',
              message: message,
              messageTemplate: 'Record {0} created! See it {1}!',
              duration: '100',
              key: 'info_alt',
              type: 'error',
              mode: 'pester'
          });
          toastEvent.fire();
      } else {    //toast implementation for a standalone app 
          component.set("v.isOpen", true);
          
      }
    
      
  },
      
  checkFieldsBeforeValidate : function(component, event, map) {
      this.removeRedBox(component, event);
      
      let checkFields = false;
      let country = map['XC_Country__c'];
      let streetType = map['XC_StreetTypeText__c'];
      let address =  map['XC_Address__c'];
      let streetNumber = map['XC_StreetNumber__c'];
      let city = map['XC_City__c'];
      let zipCode = map['XC_ZipCode__c'];
      let province = map['XC_Province__c'];
      let municipality = map['XC_Municipality__c'];
      console.log('@@@Entrato in checkFieldsBeforeValidate');
      console.log(streetType);
      console.log(address);
      
      if (( streetType != "" && address !== null && streetNumber !== null
           && city !== null && zipCode !== null && province != "" && country != ""
           && municipality !== null)  ||
          (streetType == "" && address === null && streetNumber === null
           && city === null && zipCode === null && province == "" && country == ""
           && municipality === null)){
          
          console.log('entrato in checkFields True');
          checkFields = true;
      
      }
      
      else {

          this.showErrorOnField(component, 'XC_StreetTypeText__c');
          this.showErrorOnField(component, 'XC_Address__c');
          this.showErrorOnField(component, 'XC_StreetNumber__c');
          this.showErrorOnField(component, 'XC_City__c');
          this.showErrorOnField(component, 'XC_ZipCode__c');
          this.showErrorOnField(component, 'XC_Province__c');
          this.showErrorOnField(component, 'XC_Municipality__c');
          this.showErrorOnField(component, 'XC_Country__c');            
          
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
              title : $A.get("$Label.c.XC_CL_Warning"),
              message: $A.get("$Label.c.XC_CL_ErrorAddressFields"),
              duration:' 1000',
              key: 'info_alt',
              type: 'error',
              mode: 'pester'
          });
          toastEvent.fire();
      }
      
      return checkFields;
      
      
  },
    
  
 })
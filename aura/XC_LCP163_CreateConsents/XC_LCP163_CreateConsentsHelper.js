/**
 * Created by dpalamides on 14/10/2019.
 */
({
    init : function(component, event, helper) {
        
        var sObjectData = component.get("v.sObjectData");
        if(sObjectData){
            sObjectData.RecordTypeId = component.get("v.recordTypeId");
        }
        component.set("v.sObjectData", sObjectData);
        let recordId = component.get("v.recordId");
        //let legalEntitiesVar = JSON.parse(component.get("v.legalEntitiesStr"));
        if(recordId!=null && recordId.startsWith("001")){
            component.set("v.isAccount",true);
        }
        let action0 = component.get("c.getLegalEntitiesOptions");
        action0.setParam("recordId",recordId);
        action0.setParam("objectType",component.get("v.objectType"));
        action0.setParam("sObjectData",JSON.stringify(component.get("v.sObjectData")));
        action0.setCallback(this, function(response) {
            let state = response.getState();
            let chosenLE=component.get("v.chosenLE");

            if (state === "SUCCESS") {
                let apexLE = JSON.parse(response.getReturnValue());
                component.set("v.optionsLE",apexLE);
                //if((recordId==null) || (recordId!=null && recordId.startsWith('001'))){
                //    chosenLE.push(apexLE[0]);
                //}
                //component.get("v.optionsLE").splice(component.get("v.optionsLE").lastIndexOf(apexLE[0]), 1);
                this.initData(component, event, helper);
            }
        });
        $A.enqueueAction(action0);
    },
    initData : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        //let legalEntitiesVar = JSON.parse(component.get("v.legalEntitiesStr"));

        let action = component.get("c.getLegalEntities");
        action.setParam("recordId",recordId);
        action.setParam("objectType",component.get("v.objectType"));
        action.setParam("sObjectData",JSON.stringify(component.get("v.sObjectData")));
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = []; // response.getReturnValue();
            let chosenLE=component.get("v.chosenLE");
            let apexResponse = JSON.parse(response.getReturnValue());

            if (state === "SUCCESS") {
                let hasLE = null;
                apexResponse.forEach(function(element) {
                    if(element.legalEntityConsentId!=null){
                        hasLE=element.legalEntity;
                    }
                });
                if(hasLE!=null){
                    chosenLE.push(hasLE);
                }
                else {
                    if(component.get("v.objectType")=='Account'){
                        apexResponse.forEach(function(element) {
                            if(element.country.toUpperCase()==component.get("v.sObjectData").XC_Country__c.toUpperCase()){
                                chosenLE.push(element.legalEntity);
                            }
                        });
                    }else{
                        //chosenLE.push(apexResponse[0].legalEntity);
                        apexResponse.forEach(function(element) {
                            if(element.isPrimary == true){
                                chosenLE.push(element.legalEntity);
                            }
                        });
                     }
                }
                apexResponse.forEach(function(element) {
                  if((chosenLE.lastIndexOf(element.legalEntity)>=0) ||
                     (recordId!=null && !recordId.startsWith('001') && element.legalEntityConsentId!=null)){
                    if(element.confirmationByTheCustomer == undefined || element.confirmationByTheCustomer == null){
                        element.confirmationByTheCustomer = false;
                    }
                    retValue.push(element);
                    component.get("v.optionsLE").splice(component.get("v.optionsLE").lastIndexOf(element.legalEntity), 1);
                  }
                });
                component.set("v.legalEntitiesList",retValue);
                this.onChangeNewObject(component, event, helper);
            }
        });
        $A.enqueueAction(action);

    },
    onChangeAddLegalEntityWrapper : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let eventLE = component.get('v.selectedLE');

        if(eventLE==null || eventLE==undefined || eventLE == "" || eventLE == "null"){
            component.set("v.showLeSelection",!component.get("v.showLeSelection"));
            return;
        }
        let action = component.get("c.getLegalEntities");
        action.setParam("recordId",recordId);
        action.setParam("objectType",component.get("v.objectType"));
        action.setParam("sObjectData",JSON.stringify(component.get("v.sObjectData")));
        action.setCallback(this, function(response) {
            let state = response.getState();
            let apexResponse = JSON.parse(response.getReturnValue());

            if (state === "SUCCESS") {
                apexResponse.forEach(function(element) {
                  if(element.legalEntity==eventLE){
                    let arrLe = component.get("v.legalEntitiesList");
                    arrLe.push(element)
                    component.set("v.legalEntitiesList",arrLe);
                    component.get("v.optionsLE").splice(component.get("v.optionsLE").lastIndexOf(element), 1);
                    component.set("v.showLeSelection",!component.get("v.showLeSelection"));
                    this.onChangeNewObject(component, event, helper);
                  }
                });
            }
        });
        $A.enqueueAction(action);
    },
    removeLegalEntityConsent : function(component, event, helper) {

       let recordIndex= event.currentTarget.dataset.record;
       let recordData = component.get("v.legalEntitiesList")[recordIndex];

       component.get("v.optionsLE").push(recordData.legalEntity);
       component.set("v.selectedLE",'null');
       let arrSpliced = component.get("v.legalEntitiesList");
       let arrFull = [...arrSpliced];
       arrSpliced.splice(recordIndex,1);

       if(component.get("v.recordId")==null){
           var cmpEvent = component.get("e.saveConsents");
           component.set("v.legalEntitiesList",arrSpliced);
           cmpEvent.setParams({
                                "consentsWrapper" : component.get("v.legalEntitiesList")
                            });
           cmpEvent.fire();
       }else{
           component.set("v.legalEntitiesList",arrSpliced);
       }
    },
    save : function(component, event, helper) {
        let thirdPartyVar = (component.get("v.legalEntitiesList"))[0];
        let confirmationByTheCustomerVar = thirdPartyVar.confirmationByTheCustomer;
        /*if(confirmationByTheCustomerVar==true && (thirdPartyVar.thirdPartyValue == undefined || thirdPartyVar.thirdPartyValue == null || thirdPartyVar.thirdPartyValue == $A.get("$Label.c.XC_CL_None"))){
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                                 title : $A.get("$Label.c.XC_CL_Error"),
                                 message: 'Give data to third party is a mandatory field',
                                 key: 'info_alt',
                                 type: 'error'
                                 });
            toastEvent.fire();
        }*/
        if(component.get("v.recordId")==null){
            var cmpEvent = component.get("e.saveConsents");
            let recordIndex= event.currentTarget.dataset.record;
            let recordData = component.get("v.legalEntitiesList")[recordIndex];
            cmpEvent.setParams({
                                 "consentsWrapper" : component.get("v.legalEntitiesList")
                             });
            cmpEvent.fire();
        }else{

            component.set("v.toggleSpinner",true);
            let recordIndex= event.currentTarget.dataset.record;
            let recordData = component.get("v.legalEntitiesList")[recordIndex];

            let action = component.get("c.createLegalEntities");
            action.setParam("data",JSON.stringify(recordData));
            action.setCallback(this, function(response) {
                let state = response.getState();
                let retValue = response.getReturnValue();
                if (state === "SUCCESS") {
                    //alert('fatto');
                    let toastEvent = $A.get("e.force:showToast");
                    if(retValue==null){
                        toastEvent.setParams({
                                        title : $A.get("$Label.c.XC_CL_Success"),
                                        message: $A.get("$Label.c.XC_CL_Consent_SaveOK"),//$A.get("$Label.c.XC_CL_WorkOrder_SuccessUpdateStatus"),
                                        key: 'info_alt',
                                        type: 'success'
                                        });

                        if(component.get("v.isAccount")==true){
                                        $A.get("e.force:closeQuickAction").fire();
                        }
                    }
                    else{
                         toastEvent.setParams({
                                         title : $A.get("$Label.c.XC_CL_Error"),
                                         message: retValue,//$A.get("$Label.c.XC_CL_WorkOrder_SuccessUpdateStatus"),
                                         key: 'info_alt',
                                         type: 'error'
                                         });
                    }
                    toastEvent.fire();

                    helper.init(component, event, helper);
                    component.set("v.toggleSpinner",false);
                }
            });
            $A.enqueueAction(action);
        }

    },
    saveThirdParty : function(component, event, helper) {
        let thirdPartyValueVar = (component.get("v.legalEntitiesList"))[0].thirdPartyValue;
        //let confirmationByTheCustomerVar = (component.get("v.legalEntitiesList"))[0].confirmationByTheCustomer;
        if(thirdPartyValueVar!=null && thirdPartyValueVar!=undefined){
            component.get("v.legalEntitiesList").forEach(function(element) {
              element.thirdPartyValue = thirdPartyValueVar;
              //element.confirmationByTheCustomer = confirmationByTheCustomerVar;
            });
        }
        this.onChangeNewObject(component, event, helper);
    }
    ,
    onChangeNewObject : function(component, event, helper) {
            if(component.get("v.recordId")==null || component.get("v.recordId")==undefined){
                var cmpEvent = component.get("e.saveConsents");
                cmpEvent.setParams({
                                     "consentsWrapper" : component.get("v.legalEntitiesList")
                                 });
                cmpEvent.fire();
            }
    }
})
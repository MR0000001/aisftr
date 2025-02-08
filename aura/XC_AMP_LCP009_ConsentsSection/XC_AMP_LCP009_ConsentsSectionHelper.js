({
	doInit : function(component, event, helper) {
        let recordTypeId = component.get("v.recordTypeId");
        let fieldsList = component.get("v.fieldsList");
        let objectType = component.get("v.objectType");
		
		// component.set("v.spinnerControl", false);
    },
    
    validateData : function(component,event,helper){

        //validate data and send data event to main component once all data are valid
        let fieldList = component.get("v.fieldsList");
        let fieldApiNames = fieldList.map(field => field.fieldName);
        let inputCmps = component.find('field');

        //check if all fields are valid
        let isAllValid = true;
        if(Array.isArray(inputCmps)){
            isAllValid = inputCmps.reduce(function(validSoFar,currentInput){
                let validField = true;
                if(currentInput.get("v.required") && $A.util.isEmpty(currentInput.get("v.value"))){
                    validField = false;
                }
                return validSoFar && validField;
            },true);
        }else{
            if(inputCmps.get("v.required") && $A.util.isEmpty(inputCmps.get("v.value"))){
                isAllValid = false;
            }
        }



        console.log('VEHICLE CHECK FIELD VALIDITY ' + isAllValid);

        if(isAllValid === true){
            //send parent component event with all data
            helper.sendValidEventData(component,event,helper);
        }else{
            helper.invalidateSection(component,event,helper);
        }

    },

    sendValidEventData : function(component,event,helper){

        let inputCmps = component.find('field');

        let fieldData = {};

        if(Array.isArray(inputCmps)){
            inputCmps.forEach((currentInput)=>{
                let apiName = currentInput.get("v.fieldName");
                let value = currentInput.get("v.value");
                fieldData[apiName] = value;
            });
        }else{
            let apiName = inputCmps.get("v.fieldName");
            let value = inputCmps.get("v.value");
            fieldData[apiName] = value;
        }

        let eventObj = {
            "recordTypeId" : component.get("v.recordTypeId"),
            "sObjectName" : component.get("v.objectType"),
            "sectionName" : component.get("v.sectionName"),
            "isSectionValid" : true,
            "fields" : fieldData
        }

        helper.fireAMPEvent(component,eventObj);

    },

    invalidateSection : function(component,event,helper){
        let eventObj = {
            "recordTypeId" : component.get("v.recordTypeId"),
            "sObjectName" : component.get("v.objectType"),
            "sectionName" : component.get("v.sectionName"),
            "isSectionValid" : false,
            "fields" : {}
        }
        helper.fireAMPEvent(component,eventObj);
    },


    // consentChange : function(component,event,helper){
    //     let actualValue = event.getParam("checked");

    //     if(actualValue){
    //         component.set("v.accountRecord.XC_ConfirmationByCustomer__c",true);
    //         component.set("v.showConsentsCmp",true);
    //     }

    // }

})
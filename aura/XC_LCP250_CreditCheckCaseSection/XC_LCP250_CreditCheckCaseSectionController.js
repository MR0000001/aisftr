({
	doInit : function(component, event, helper) {
	    var action = component.get("c.retrieveInformation");
        action.setParams({ "recordId":  component.get("v.recordId") });  
        console.log('@@@ ' + component.get("v.recordId"));
        action.setCallback(this, function(response) {

        var state = response.getState();
        let result = response.getReturnValue();
        //Console.log(result);
        if(state === 'SUCCESS') {
               if(result.success){
                   //helper.showToastSuccess(component, result.resultMessage, $A.get("$Label.c.XC_CL_OperationCompleted"));
                   var mapFieldValue = result.mapFieldValue;
                   var mapFieldLabel = result.mapFieldLabel;
                   var listBillingModel = result.listBillingModel;
                   console.log(result);
                   console.log(result.mapFieldValue);
                   console.log('Identity'+mapFieldValue.IdentityNumber__c);
                   component.set("v.IdentityNumberLabel", mapFieldLabel.IdentityNumberLabel);
                   component.set("v.IdentityNumber", mapFieldValue.IdentityNumber__c);
                   component.set("v.contactDocumentNumberLabel", mapFieldLabel.contactDocumentNumberLabel);
                   component.set("v.ContactDocumentNumber", mapFieldValue.XC_ContactDocumentNumber__c);
                   component.set("v.XC_CapexFullLife_Label", mapFieldLabel.XC_CapexFullLife_Label);
                   component.set("v.XC_CapexFullLife_Value", mapFieldValue.XC_CapexFullLife_Value);
                   component.set("v.XC_RevenueFullLife_Label", mapFieldLabel.XC_RevenueFullLife_Label);
                   component.set("v.XC_RevenueFullLife_Value", mapFieldValue.XC_RevenueFullLife_Value);
                   component.set("v.XC_ResultCVP_Label", mapFieldLabel.XC_ResultCVP_Label);
                   component.set("v.ResultCVP_Value", mapFieldValue.ResultCVP_Value);
                   component.set("v.XC_ExecutionDateCVP_Label", mapFieldLabel.XC_ExecutionDateCVP_Label);
                   component.set("v.DateCVP_Value", mapFieldValue.DateCVP_Value);
                   
                   
                   component.set("v.listBillingModel", listBillingModel);
               }else if (!result.success){
                   //helper.showToastError(component,result.resultMessage,'ERROR');
               }           
               }
            


         });
          $A.enqueueAction(action);
		
	},
	
})
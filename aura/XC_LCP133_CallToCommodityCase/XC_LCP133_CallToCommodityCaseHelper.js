({
	doInit : function(component, event, helper) {
		//component.set('v.spinnerControl',true);
		/*let action = component.get("c.callCommodityReadCase");
		action.setParams({
            'recordId': component.get('v.recordId'),
            'sobjectType': component.get('v.sobjecttype')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var responseResult = response.getReturnValue();*/
        
        let commodityGlobalMessage = component.get("v.commodityGlobalMessage");
        if(commodityGlobalMessage){
            //helper.showToast(component, commodityGlobalMessage, 'error'); // Modifica temporanea S.A. 14/08/2019
            return;
        }

        var responseResult = component.get('v.caseCommodityObj');
        console.log('@@@ v.caseCommodityObj' + JSON.stringify(responseResult))
        if(responseResult && responseResult.success && responseResult.sections){
            /*let sections = responseResult.sections;
            if(sections !== null){*/
                //Sezione Contracts
            let caseSection = responseResult.sections['Case'];
            if(caseSection && caseSection.objectsRecordFields){
                for(let indexContact in caseSection.objectsRecordFields){
                    helper.createSectionFields(caseSection.objectsRecordFields[indexContact], component);
                }
                helper.createSectionComponent(component, helper, $A.get("$Label.c.XC_CL_Case"));
            } else {
                //helper.showToast(component, responseResult.resultMessage, 'error');   // Modifica temporanea S.A. 14/08/2019
            }
            //}
        } else {
            //helper.showToast(component, $A.get("$Label.c.XC_CL_NoCaseForDoc"), 'error');  // Modifica temporanea S.A. 14/08/2019
        }
            /*}
            setTimeout(function(){ component.set('v.spinnerControl',false); }, 2000);
        });
        $A.enqueueAction(action);*/
	}
})
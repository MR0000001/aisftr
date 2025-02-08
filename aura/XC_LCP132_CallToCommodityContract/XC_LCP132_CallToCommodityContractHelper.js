({
	doInit : function(component, event, helper) {
        let commodityGlobalMessage = component.get("v.commodityGlobalMessage");
        if(commodityGlobalMessage){
            //helper.showToast(component, commodityGlobalMessage, 'error');   // Modifica temporanea S.A. 14/08/2019
            return;
        }

        var responseResult = component.get('v.contractCommodityObj');
        console.log('@@@@ Contract: '+ JSON.stringify(responseResult));
        if(responseResult && responseResult.success && responseResult.sections){
            /*let sections = responseResult.sections;
            if(sections !== null){*/
                //Sezione Contracts
            let contactsSection = responseResult.sections['Contract'];
            if(contactsSection && contactsSection.objectsRecordFields){
                for(let indexContact in contactsSection.objectsRecordFields){
                    helper.createSectionFields(contactsSection.objectsRecordFields[indexContact], component);
                }
                helper.createSectionComponent(component, helper, $A.get("$Label.c.XC_CL_Contract"));
            } else {
                //helper.showToast(component, $A.get("$Label.c.XC_CL_NoContractForDoc"), 'error');    // Modifica temporanea S.A. 14/08/2019
            }
            //}
        } else {
            //helper.showToast(component, $A.get("$Label.c.XC_CL_NoContractForDoc"), 'error');  // Modifica temporanea S.A. 14/08/2019
            /*if(responseResult && responseResult.resultMessage){
                helper.showToast(component, responseResult.resultMessage, 'error');
            } else {
                helper.showToast(component, 'ERROR', 'error');
            }*/
        }
            /*}
            setTimeout(function(){ component.set('v.spinnerControl',false); }, 2000);
        });
        $A.enqueueAction(action);*/
	}
})
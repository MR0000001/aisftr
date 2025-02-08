({   
    doInit: function (component, event, helper) {
	 helper.getCurrentServiceAppointmentId(component, event, helper);
        component.set("v.viewOpp", true);
   },
    getCurrentServiceAppointmentId: function (component, event, helper){  
            var action = component.get("c.getCurrentServiceAppointment"); 
            action.setParams({
            'recordId': component.get("v.recordId")           
        }); 
        console.log('@@@ -> v.recordId', component.get("v.recordId"));
        action.setCallback(this, function (response) {
                var state = response.getState();
                let result = response.getReturnValue();
                if (state === 'SUCCESS') {
                   console.log('@@@ -> resultMessage', result.resultMessage);
                   if(!result.Success && result.resultMessage === 'ErrorServiceAppQuota'){ 
                     helper.showToast(component, 'This functionality is available only if the quotation request has been accepted.', 'Error');
                     helper.closeFunctinality(component, event, helper, resp.getError(), 'error');
                   }
                else if(!result.Success && result.resultMessage === 'ErrorServiceAppOpp'){
                     helper.showToast(component, 'This functionality is available only for business line eCity ITA and B2B or B2G segments.', 'Error');
                     helper.closeFunctinality(component, event, helper, resp.getError(), 'error');
                     }
                   else{
                    component.set('{!v.accountId}', response.getReturnValue().accountId);                    
                    console.log('@@@ -> v.accountId', component.get("v.accountId"));
                    let serviceId=component.get("v.recordId");
                    component.set('{!v.serviceId}',serviceId);
                    console.log('@@@ -> v.serviceId', component.get("v.serviceId"));
                    component.set('{!v.caseId}', response.getReturnValue().caseId);
                    console.log('@@@ -> v.caseId', component.get("v.caseId"));
                    component.set('{!v.workOrderId}', response.getReturnValue().workOrderId);
                    console.log('@@@ -> v.workOrderId', component.get("v.workOrderId"));
                }
             }
            });
      
            $A.enqueueAction(action);
   },
    
    closeFunctinality: function (component, event, helper, message, typeMessage) {
        component.set("v.spinner", false);
        helper.showToast(component, message, typeMessage);
        $A.get("e.force:closeQuickAction").fire();

        
        let ev = $A.get("e.c:XC_LCE015_ModalClosed");
        if (ev) {
            ev.setParams({ "modalName": $A.get("$Label.c.XC_CL_CreateOpportunityClosedEvent") });
            ev.fire();
        }
    },
    showToast: function (component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:closeQuickAction").fire();
    }
    
                           
 })
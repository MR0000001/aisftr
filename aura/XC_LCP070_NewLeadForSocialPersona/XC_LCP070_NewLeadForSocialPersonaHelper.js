({
	checkPossibilityToCreate : function(component, event, helper) {
        let action = component.get("c.checkLeadLookup");
        action.setParams({ 'recordId' : component.get("v.recordId") });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();
                if(result){
                   helper.callNewLead(component, event, helper) ;
                  
                   }
                else{
                     helper.showToast(component, event, helper, 'Lead already created!', 'error');
                     
                  
                }
            }
        });
        $A.enqueueAction(action);  
    },
    callNewLead : function(component, event, helper) {
        let navService = component.find("navService");
        let targetPageReference = {
            type: 'standard__component',
            attributes: {
                "componentName": "c__XC_LCP002_RedirectLead",
                "name": "c:XC_LCP002_RedirectLead"
            }, // "c:XC_LCP002_NewLead"
            state: {
                "c__socialPersonaId" : component.get("v.recordId"),
            }
        };
        navService.navigate(targetPageReference);
        
        
        
    },
		
	showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
})
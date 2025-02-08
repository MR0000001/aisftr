({
	doInit : function(component, event, helper) {
                var action = component.get("c.isMobileOrCommunityExperience");
                action.setCallback(this, function(response) {
                var state = response.getState();
                var retValue = response.getReturnValue();
                if (state === "SUCCESS"){
                        console.debug('>>>>>>>>> Redirect Accoutr - isCommunity='+retValue);
                        if(retValue==='isCommunity'){
                                component.set("v.isCommunity",true);
                        }
                        if(component.get("v.pageReference") && component.get("v.pageReference").state) {
                                var recordTypeId = component.get("v.pageReference").state.recordTypeId;
                                if(recordTypeId) {
                                        component.set('v.recordTypeId', recordTypeId);
                                        console.log('recordTypeId->'+recordTypeId);
                                }      
                        }
                        component.set('v.showComponent', true); 
                }
                }); 
                $A.enqueueAction(action);
        }
})
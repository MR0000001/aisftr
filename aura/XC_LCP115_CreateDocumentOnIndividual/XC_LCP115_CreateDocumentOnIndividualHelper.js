({
    /*init : function(component, event) {
        console.log('here');
        console.log('RECORD ID-->' + component.get("v.recordId"));
        var action = component.get("c.populateCongaField");
        console.log('action' + action);
        action.setParams({
            "individualId": component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var retValue = response.getReturnValue();
            console.log('retValue- - -->' + retValue);
            if(state=="SUCCESS" && retValue!=null && retValue !='There is no Contact or Lead related to this record.'){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url":  retValue 
                });
                urlEvent.fire();
            } 
            if(retValue == 'There is no Contact or Lead related to this record.'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'error',
                    mode: 'dismissible',
                    mode: 'pester',
                    duration : 20,
                    message: 'There is no Contact or Lead related to this record.'
                });
                toastEvent.fire(); 
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
            }
        });
        $A.enqueueAction(action);
    },*/
    init : function(component, event) {
        console.log('here for workflow');
        console.log('RECORD ID-->' + component.get("v.recordId"));
        var action = component.get("c.startWorkflowOnIndividual");
        console.log('action' + action);
        action.setParams({
            "individualId": component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var retValue = response.getReturnValue();
            console.log('retValue- - -->' + retValue);
            if(state=="SUCCESS" && retValue!=null && retValue =='The call to Conga has started. The document will be attached to the connected Lead.'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'success',
                    mode: 'dismissible',
                    mode: 'pester',
                    duration : 50,
                    message: retValue
                });
                toastEvent.fire(); 
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
            } else if(state=="SUCCESS" && retValue!=null && retValue =='The call to Conga has started. The document will be attached to the connected Contact.'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'success',
                    mode: 'dismissible',
                    mode: 'pester',
                    duration : 50,
                    message: retValue
                });
                toastEvent.fire(); 
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'error',
                    mode: 'dismissible',
                    mode: 'pester',
                    duration : 20,
                    message: retValue
                });
                toastEvent.fire(); 
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
            }
        });
        $A.enqueueAction(action);
    }
})
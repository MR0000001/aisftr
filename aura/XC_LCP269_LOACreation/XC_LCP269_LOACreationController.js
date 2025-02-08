({
    doInit : function(component, event, helper) {
        var action = component.get("c.getInitData");
        action.setParams({
            "accountid" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var resp = response.getReturnValue();                
                component.find("contractForm").set("v.recordTypeId", resp.recordTypeId);
                component.find("accountId").set("v.value", component.get("v.recordId"));
                component.find("contactId").set("v.value", resp.contactId);
                component.set("v.loading", false);
            }
        });
        $A.enqueueAction(action);
        component.set("v.formLoaded", true);
    },
    saveClick : function(component, event, helper) {
        component.set("v.loading", true);
        if(component.find("dualbox").reportValidity())
        {
            component.find('contractForm').submit();
        }
        else
        {
            component.find("message").setError($A.get("$Label.c.XC_CL_LCP269_DualBoxError"));
            component.set("v.loading", false);
        }
    },
    getServiceAccounts : function(component, event, helper){
        component.set("v.loading", true);
        var utId = component.find("utilityId").get("v.value");
        if(!$A.util.isEmpty(utId))
        {
            var action = component.get("c.getServAccounts");
            action.setParams({
                "accountId" : component.get("v.recordId"),
                "utilityId" : component.find("utilityId").get("v.value")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var resp = response.getReturnValue();                
                    component.set("v.options", resp.options);
                    component.set("v.loading", false);
                    if(!$A.util.isEmpty(resp.templateName))
                    {
                        component.find("loaTemplate").set("v.value", resp.templateName);
                    }
                    else
                    {
                        component.find("loaTemplate").set("v.value", "");
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            component.set("v.options", []);
            component.find("loaTemplate").set("v.value", "");
            component.set("v.loading", false);
        }
    },
    handleSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        var loaId = record.id;
        var selectedServiceAccounts = Array.from(component.find("dualbox").get("v.value"));
        if(!$A.util.isEmpty(selectedServiceAccounts))
        {
            var action = component.get("c.insertServiceAccounts");
            action.setParams({
                "contractId" : loaId,
                "serviceAccounts" : selectedServiceAccounts
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var resp = response.getReturnValue();                
                    if($A.util.isEmpty(resp))
                    {
                        helper.navigate(component, loaId);
                    }
                    else
                    {
                        component.find("message").setError(resp);
                    }
                }
                component.set("v.loading", false);
            });
            $A.enqueueAction(action);
        }
        
    },
    handleError : function(component, event, helper) {
    },
    cancelClick : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})
({
	doInit : function(component, event, helper) {
        console.log('recordId= '+component.get("v.recordId"));
        
        var action = component.get("c.retriveData");
        action.setParams({ 'recordId': component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            console.log('res='+res);

            if (state === "SUCCESS" && res!=null){
                var valueMap = JSON.parse(res);
                component.set("v.valueMap", valueMap);
                var opts = [];
                var opts2 = [];
                if(valueMap.contractRole){
                (valueMap.contractRole).forEach(function(entry) {
                    opts.push({
      				value: entry['key'],
      				label: entry['value']
    				});
                })
        		component.set('v.contractRole', opts);
                }
                if(valueMap.contactList){
                 (valueMap.contactList).forEach(function(entry) {
                    opts2.push({
      				value: entry['key'],
      				label: entry['value']
    				});
                })
        		component.set('v.contactList', opts2);
                }
              
            }
            }); 
          $A.enqueueAction(action);
                
		
	},
    
    createContactsOnContract : function(component, event, helper) {
        var valueMap =  component.get("v.valueMap");
         var action = component.get("c.createContactsOnContract");
        action.setParams({ 'stringValues': JSON.stringify(valueMap) });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            console.log('res='+res);

            if (state === "SUCCESS" && res.success){
                helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_Success") , 'success');
                this.close(component, event, helper);
               
            }else{
                if((res.resultMessage).isEmpty()){
                helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_Error") , 'error'); 
                }else{
                helper.showToast(component, event, helper, res.resultMessage, 'error');
                }
            }
         }); 
          $A.enqueueAction(action);
    },
    
     showToast : function(component, event, helper, message, mtype) {
       // component.set("v.spinnerControl",false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": mtype
        });
     },
    
    close : function(component, event, helper){
        /*
        var workspaceAPI = component.find("workspace");
		workspaceAPI.getFocusedTabInfo().then(function(response) {
        var focusedTabId = response.tabId;
		workspaceAPI.closeTab({tabId: focusedTabId});
})
         var navigateEvent = $A.get("e.force:navigateToSObject");
         navigateEvent.setParams({ "recordId": component.get("v.recordId"), "slideDevName": "related" });            
         navigateEvent.fire();
        */
         $A.get("e.force:closeQuickAction").fire();
         setTimeout(function(){
                                $A.get('e.force:refreshView').fire();
                            }, 400); 
         setTimeout(function(){
                                $A.get('e.force:refreshView').fire();
                            }, 300); 
    }
})
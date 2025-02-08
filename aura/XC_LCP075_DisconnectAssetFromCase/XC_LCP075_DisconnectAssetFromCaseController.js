({
    
    doInit : function(component, event, helper){
      helper.prepopulateSubtype(component, event, helper);
    },
    
	dis : function(component, event, helper){
        helper.disconnect(component,event,helper);  
    },
    
    handlePrimaryButtonClick : function(component, event, helper) {
        component.set("v.secondSpinner",true);
        helper.proceedDisconnection(component, event, helper);
    },
    
    handleSecondaryButtonClick: function(component, event, helper) {
        console.log('chiudo tutto');   
        
         let workspaceAPI = component.find("workspace2");
         workspaceAPI.getFocusedTabInfo().then(function(response) {
						let focusedTabId = response.tabId;
						workspaceAPI.closeTab({tabId: focusedTabId});
						})
    },

    onComplaintOptionChange: function(component, event, helper) {
        helper.checkNotBlank(component, event, helper);
        helper.selectComplaintDataByOption(component, event, helper);
    },

    callLegalText: function(component, event, helper) {
        helper.callLegalText(component, event, helper);
    }
    
    /*checkNotBlank: function(component, event, helper) {
        let subtype = component.find("subtype").get("v.value");
        console.log('entro con '+subtype); 
        if(subtype === '' || subtype === undefined){
            component.set("v.disabledSubmit",true);
        }else{
            component.set("v.disabledSubmit",false);
        }
    }*/
        
        
        
		
})
({
    
     doInit : function(component, event, helper){
      helper.prepopulateSubtype(component, event, helper);
    },
    
	dis : function(component, event, helper){
        component.set("v.secondSpinner",true);
        helper.disconnect(component,event,helper);  
    },
    checkNotBlank: function(component, event, helper) {
      let subtype = component.find("subtype").get("v.value");
      console.log('entro con '+subtype); 
                if(subtype=='' || subtype === undefined  ){
                    component.set("v.disabledSubmit",true);
                }else{
                    component.set("v.disabledSubmit",false);
                }
    },
    
     cancel : function(component, event, helper) {
          let workspaceAPI = component.find("workspace");
         workspaceAPI.getFocusedTabInfo().then(function(response) {
						let focusedTabId = response.tabId;
						workspaceAPI.closeTab({tabId: focusedTabId});
						})
     },

     callLegalText: function(component, event, helper) {
         helper.callLegalText(component, event, helper);
     }
		
})
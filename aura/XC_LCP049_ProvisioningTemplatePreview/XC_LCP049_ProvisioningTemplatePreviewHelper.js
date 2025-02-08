({
	init : function(component,event) {
        let workspaceAPI = component.find("workspace");
        
        workspaceAPI.openTab({
            url : '/lightning/n/XC_Provisioning_Template_Preview',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response ,
                label: "Provisioning Template Preview" 
            })
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: "utility:search"
            })
        }); 
        
        var action = component.get("c.getPickListValues"); 
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.picklistValues", result.pickListValuesList);
            component.set("v.BaseURL", result.baseURL);
        	console.log('url->'+result.baseURL);
        }) 
        $A.enqueueAction(action);
    },
    
    onChange : function(component,event) {
        console.log('variabile->'+component.get("v.showSchema"));
        component.set("v.showSchema","true");
        console.log('variabile dopo->'+component.get("v.showSchema"));

    }
})
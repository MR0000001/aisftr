({
	getSinglePositionCodeValuesData : function(component, event, helper) {
        var name=component.get("v.recordId");
        console.log('woli:'+name);
        var action=component.get("c.getSinglePositionCodeValues");
        action.setParams({
            "woli":name,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                
                var res=response.getReturnValue();
                component.set("v.result",res);
                component.set("v.getAllValue",res);
                console.log('options:'+res);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPosition : function(component, event, helper) {
        var name=component.find("positionValue").get("v.value");
    	component.set("v.getAllValue",name);
        
    }
    
})
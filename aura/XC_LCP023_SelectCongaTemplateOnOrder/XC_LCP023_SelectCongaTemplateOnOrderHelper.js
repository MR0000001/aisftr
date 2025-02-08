({
	doInit : function(component,event) {
        var action = component.get("c.getPickListValuesIntoList"); 
        action.setParams({
            "idOrder": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            component.set("v.picklistValues", list.listaName);
            component.set("v.picklistId",list.listaId);
        })
        $A.enqueueAction(action);
    },
    //Depracated
    /*doInitItem : function(component,event) {
        var action = component.get("c.getPickListValuesConfItem"); 
        action.setParams({
            "idOrder": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            component.set("v.picklistValuesItem", list.listaName);
            //component.set("v.picklistId",list.listaId);
        })
        $A.enqueueAction(action);
	},*/
    
    clickDownloadHelper : function(component,event) {
        var tempname = component.find("fieldSelect").get("v.value");
        var action = component.get("c.getIdValueAndSetUrl");
        action.setParams({
            "idOrder": component.get("v.recordId"),
            "templateName": tempname
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var retValue = response.getReturnValue();
            if(state=="SUCCESS"&&retValue!=null){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url":  retValue 
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})
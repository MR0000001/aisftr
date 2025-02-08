({
	doInit : function(component, event, helper) {
        
        
		
	},
    
    sendOnHandEvent : function(component, event, helper) {
        var onHand =  event.getParam("value");
        var pqidId = component.get("v.piqd").Id;
        var locationFrom = component.get("v.piqd").gii__Location__c;
        
        var cmpEvent = $A.get("e.c:Giic_LCE001_SendOnHand");
        cmpEvent.setParams({
            "pqidOnHand" : onHand,
            "pqidId" : pqidId,
            "locationFrom" : locationFrom
            
            
        }); 
        cmpEvent.fire();
    }
    
    
})
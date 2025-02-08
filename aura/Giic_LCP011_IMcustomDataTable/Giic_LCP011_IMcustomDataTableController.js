({
	doInit : function(component, event, helper) {
		//helper.init(component, event, helper);
	},
    
    closeModal :  function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    
    handleComponentEvent : function(component, event, helper) {
        var totalList = component.get("v.mapIdToOnHand");
        var listMapIdToLocFrom =  component.get("v.mapIdPiqdToLocationFrom"); 
        totalList[event.getParam("pqidId")]  = event.getParam("pqidOnHand");
        listMapIdToLocFrom[event.getParam("pqidId")] = event.getParam("locationFrom");
      	component.set("v.mapIdToOnHand" , totalList);
        component.set("v.mapIdPiqdToLocationFrom" , listMapIdToLocFrom);
        console.log('TOTALList = '+JSON.stringify(totalList));
    },
    
    saveAllPiqd :  function(component, event, helper) {
        component.set("v.showSpinner" , true);
    	helper.saveAllPiqd(component, event, helper);
    }
    
    
    
    
})
({
	createRecord : function (component, event, helper) {
    var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
        "entityApiName": "gii__PurchaseOrder__c"
      
    });
    createRecordEvent.fire();
        
}
    
    
})
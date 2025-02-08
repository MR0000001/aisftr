({
	setRecordType : function(component, event, helper) {
		
        
        var action = component.get("c.getRecordTypeIdByName");
        
        action.setParams({ "recordTypeName": "XC_ESP_Customer"});
        action.setCallback(this, function (response) {
            var status = response.getState();
            var res = response.getReturnValue();
            
            if (res != null) {
                console.log('RecordType ID = '+res);
                component.set('v.recordTypeId', res);
                component.set('v.initRedirect', true);
            }
            
        });
        
        $A.enqueueAction(action);
	}
    
})
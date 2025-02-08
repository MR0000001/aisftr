({
	init : function(component, event, helper) {
     	var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set('v.recordTypeId', recordTypeId);
        console.log('recordTypeId->'+recordTypeId);
	}
})
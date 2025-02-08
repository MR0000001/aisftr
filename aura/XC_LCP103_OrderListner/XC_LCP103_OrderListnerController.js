({
	selectUpdateCaseAction : function( component, event, helper) {
        var actionAPI = component.find("quickActionAPI");
        var args = { actionName :"NE__Order__c.XC_Payment" };
        actionAPI.selectAction(args).then(function(result) {
            // Action selected; show data and set field values
             $A.get('e.force:refreshView').fire(); 
        }).catch(function(e) {
            if (e.errors) {
                // If the specified action isn't found on the page, 
                // show an error message in the my component 
            }
        });
    },
})
({
    
    init : function(component, event, helper) {
        helper.doInit(component, helper);
    },
	changePick: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        component.set("v.productCategoryOfInterest", selectedOptionValue);
    },
    
    /*assignLeadChecked : function(component, event, helper) {
        helper.assignLeadCheckedHelper(component, event);
    },*/
    
    cancel :  function(component, event, helper) {
        helper.cancel(component, event, helper);   
        
    },
    confirm :  function(component, event, helper) {
        helper.createClone(component, event, helper) ;
    }
    
})
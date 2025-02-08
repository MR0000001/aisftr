({
	 closeModal : function(component, event, helper) {
        helper.close(component, event, helper);
    },
    
    init : function(component, event, helper) {
        
       helper.doInit(component, event, helper);
      
},
    createContacts : function (component, event,helper) {
        helper.createContactsOnContract(component, event,helper) ;
    },
    changeRole: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        component.set("v.roleValue", selectedOptionValue);
        component.set("v.valueMap.roleValue", selectedOptionValue );
        //checkForSubmit
        if(component.get("v.valueMap.contactValue")!=null && component.get("v.valueMap.roleValue")){
            component.set("v.disabledSubmit", false);
        }else{
            component.set("v.disabledSubmit", true);
        }
    },
    changeContact: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        component.set("v.contactValue", selectedOptionValue);
        component.set("v.valueMap.contactValue", selectedOptionValue );
        //checkForSubmit
        if(component.get("v.valueMap.contactValue")!=null && component.get("v.valueMap.roleValue")){
            component.set("v.disabledSubmit", false);
        }else{
            component.set("v.disabledSubmit", true);
        }
    }
})
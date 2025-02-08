({
    doInit : function(component, event, helper) {
       helper.doInit(component,event,helper);
    },

    updateCase:function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.updateCaseHelper(component,event,helper);
    },
    showNewBilling  :function (component, event, helper) {
    	 component.set("v.showNewZuoraBilling",true);
	},
    checkNotBlank: function(component,event,helper) {
        helper.checkNotBlank(component,event,helper);
    },

    goback: function(component,event,helper){

        helper.goBack(component,event,helper);
    },

    handleModalClosedEvent: function (component, event, helper) {
        let modalName = event.getParam("modalName");
        if (modalName == $A.get("$Label.c.XC_CL_ZuoraBillingCreationClosedEvent") ) {
            helper.handleSecondaryButtonClick(component, event, helper);
        }
    }
})
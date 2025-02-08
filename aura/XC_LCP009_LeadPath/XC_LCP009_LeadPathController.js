({
	doInit : function (component, event, helper) {
     console.log('STEP NAME DETAIL' + JSON.stringify(event.getParam("detail") ));
    },

    handleSelect : function (component, event, helper) {
    	helper.handleSelectHelper(component,event);
    } 
})
({
	doInit : function(component, event, helper) {
        let recordTypeId = component.get("v.recordTypeId");
        let fieldsList = component.get("v.fieldsList");
        let objectType = component.get("v.objectType");

        if(component.get("v.recordId")){
            component.set("v.showAddressCmp",false);
        }
		
		// component.set("v.spinnerControl", false);
    },

    handleAddressEvent : function(component,event,helper){
        let addressData = event.getParam("address");
        let wihoutValidate = event.getParam("withoutValidate")

        //send event once address has been validated
        if(addressData.validate===true || wihoutValidate===true){
            let eventObj = {
                "recordTypeId" : component.get("v.recordTypeId"),
                "sObjectName" : component.get("v.objectType"),
                "sectionName" : component.get("v.sectionName"),
                "isSectionValid" : true,
                "fields" : addressData
            }

            helper.fireAMPEvent(component,eventObj);

        }

    }

})
({
    init : function(component, event, helper) {
        helper.doInit(component,event,helper);
    },

    retrieveItems : function(component,event,helper){
        helper.retrieveItems(component,event,helper);
    },

    upsertItem : function(component,event,helper){
        helper.checkRemoveAndUpsert(component,event,helper);
    },

    saveConfiguration : function(component,event,helper){
        helper.finalSaveConfiguration(component,event,helper);
    },

    handleChildCmpEvent : function(component,event,helper){
        helper.handleChildCmpEvent(component,event,helper);
    },

    handleEnabledSectionDataChange : function(component,event,helper){
        helper.handleEnabledSectionDataChange(component,event,helper);
    },

    setEditableValidSection : function(component,event,helper){
        helper.setEditableValidSection(component,event,helper);
    },

    orderDataValidation : function(component,event,helper){
        if (component.find("callType")) {
            let currentSectionValidations = component.get("v.validSections");
            if($A.util.isEmpty(component.get("v.callType"))){
                currentSectionValidations['orderData'] = false;
            }else{
                currentSectionValidations['orderData'] = true;
            }
            component.set("v.validSections",currentSectionValidations);
            helper.submitValidation(component,event,helper);
        }
    }
})
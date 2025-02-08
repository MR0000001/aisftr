({
    goToSurvey : function(component, event, helper) {

        let surveyUrl = component.get("v.incentiveItem.creditAssignmentSurvey");
        component.set("v.surveyTaken",true);
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url" : surveyUrl
        });
        urlEvent.fire();
    },

    openFieldsModal : function(component,event,helper){
        component.set("v.showAdditionalFields",true);

        //open modal component
        let cmpTarget = component.find('Modalbox');
        let cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');


    },

    handleCancel : function(component,event,helper){

        //close modal

        component.set("v.showAdditionalFields",false);
        let cmpTarget = component.find('Modalbox');
        let cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 

    },


    handleOiFormSuccess : function(component,event,helper){

        console.log('Record Save successfully');

        //sending event to parent component in order to save data to other items
        let allowPropagation = component.get("v.allowFieldPropagation");
        if(allowPropagation){

            let cityCode = component.find("cityCode").get("v.value");
            let subordinate = component.find("subordinate").get("v.value");
            let houseType = component.find("houseType").get("v.value");
            let particle = component.find("particle").get("v.value");
            let sheet = component.find("sheet").get("v.value");
            let urbanSection = component.find("urbanSection").get("v.value");
            let updatedItemId = component.get("v.incentiveItem.recordId");

            let eventData = {
                cityCode : cityCode,
                subordinate : subordinate,
                houseType : houseType,
                particle : particle,
                sheet : sheet,
                urbanSection : urbanSection,
                updatedItemId : updatedItemId
            }

            let ev = component.getEvent("XC_LCE021_CreditTransferDataEvent");
            ev.setParam("Data",eventData);
            ev.fire();

        }

        //close the modal
        let cmpTarget = component.find('Modalbox');
        let cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 

        //show toast and update child items
        component.set("v.incentiveItem.hasAdditionalFieldsFilled",true);
        
        component.find('notifLib').showToast({
            "title": $A.get("$Label.c.XC_CL_Success"),
            "message": $A.get("$Label.c.XC_CL_LCP183FillOtherSuccess"),
            "mode": "pester",
            "variant": "success"
        });

        helper.fireToggleSpinnerEvent(component, false);
    },

    handleSubmit : function(component, event, helper) {
        console.log('TA_LCP245_CreditAssignmentViewChild >> Controller >> handleSubmit >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        console.log('TA_LCP245_CreditAssignmentViewChild >> Controller >> handleSubmit >> End');
    },

    handleError : function(component, event, helper) {
        console.log('TA_LCP245_CreditAssignmentViewChild >> Controller >> handleError >> Start');
        helper.error(component, event);
        console.log('TA_LCP245_CreditAssignmentViewChild >> Controller >> handleError >> End');
    }

})
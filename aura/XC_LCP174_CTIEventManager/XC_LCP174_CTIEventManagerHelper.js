({
    manageEvent: function (component, event, helper, eventPayload) {
        let currentUserId = $A.get("$SObjectType.CurrentUser.Id");
        if (eventPayload.XC_ContextUserId__c == currentUserId) {
            //check on event type and then open the phone bar
            if (eventPayload.XC_EventType__c == 'RECSTART') {
                helper.manageRecStartEvent(component, event, helper, eventPayload);
            } else if (eventPayload.XC_EventType__c == 'RECSTOP') {
                helper.manageRecStopEvent(component, event, helper, eventPayload);
            } else if (eventPayload.XC_EventType__c == 'CALLINIT' && eventPayload.XC_ShowPopup__c) {
                helper.manageOpenPhonePanel(component, event, helper);
            } else if (eventPayload.XC_EventType__c == 'RECCOMPLETED') {
                helper.manageRecCompletedEvent(component, event, helper, eventPayload);
            }
        }
    },

    manageOpenPhonePanel: function (component, event, helper, eventPayload) {
        let utilityBarAPI = component.find('utilitybar');
        utilityBarAPI.getAllUtilityInfo().then(function (response) {
            let allUtilityItems = response;
            console.log('UTILITY ITEMS LIST ON CTI EVENT:: ' + JSON.stringify(allUtilityItems));
            let ctiUtilityId = '';
            let isPoppedOut = false;
            for (let i = 0; i < allUtilityItems.length; i++) {
                let utilityItem = allUtilityItems[i];
                if (utilityItem.utilityLabel == 'Plug-in') {
                    ctiUtilityId = utilityItem.id;
                    isPoppedOut = utilityItem.utilityPoppedOut;
                }
            }
            if (!isPoppedOut) {
                utilityBarAPI.openUtility({
                    utilityId: ctiUtilityId
                });
            }
        });
    },

    manageRecStartEvent: function (component, event, helper, eventPayload) {
        component.find('notifLib').showToast({
            "title": "Start",
            "message": $A.get("$Label.c.XC_CL_CTI_RecStartMsg"),
            "mode": "pester",
            "variant": "success"
        });

        //ITALY REQUIREMENT, TO BE REMOVED IN FUTURE
        // if(eventPayload.XC_ObjectType__c == 'NE__Order__c'){
            component.find('notifLib').showToast({
                "title": "Warning",
                "message": $A.get("$Label.c.XC_CL_LCP174_WarningOnOtpOrder"),
                "mode" : 'sticky',
                "variant": "warning"
            });
        // }

    },

    manageRecStopEvent: function (component, event, helper, eventPayload) {
        component.find('notifLib').showToast({
            "title": "Stop",
            "message": $A.get("$Label.c.XC_CL_CTI_RecStopMsg"),
            "mode": "pester",
            "variant": "info"
        });
    },

    manageRecCompletedEvent: function (component, event, helper, eventPayLoad) {
        component.find('notifLib').showToast({
            "title": "Stop",
            "message": $A.get("$Label.c.XC_CL_CTI_RecSavedMsg"),
            "mode": "pester",
            "variant": "success"
        });
    }

})
({
    initialize : function(component, event, helper) {
        console.log('TA_LCP212_OrderSummary >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
        component.set('v.checkIcon', $A.get('$Resource.TA_Icons') +  '/xc-icons/check-white-bgp.svg');
        if(component.get('v.general').titleType == 'default') {
            component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        }
        if(component.get('v.general').description != null && component.get('v.general').description != '') {
            component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
        }

        let action = component.get('c.initialize');
        action.setParams({
            'workOrder' : component.get('v.workOrder'),
            'customSet' : JSON.stringify(component.get('v.custom'))
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP212_OrderSummary >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.infoBag', JSON.parse(response.getReturnValue()));
                component.set('v.isInitialized', true);
                this.fireSendInitStateEvt(component, true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP212_OrderSummary >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP212_OrderSummary >> Helper >> initialize >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP212_OrderSummary >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP212_OrderSummary",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP212_OrderSummary >> Helper >> fireSendInitStateEvt >> End');
    }
})
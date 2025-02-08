({
	initialize : function(component) {
        console.log('TA_LCP254_DynamicHomepage >> Helper >> initialize >> Start');
        let _helper = this;
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        _helper.getCustomLabels(component);
        console.log('TA_LCP254_DynamicHomepage >> Helper >> initialize >> End');
    },

    getCustomLabels : function(component) {
        console.log('TA_LCP254_DynamicHomepage >> Helper >> getCustomLabels >> Start');
        let tabs = component.get('v.custom').tabs;
        let customLabels = [];

        tabs.forEach(function(tab) {
            if (tab.name) customLabels.push(tab.name);
            if (tab.description) customLabels.push(tab.description);
        });

        let getCustomLabels = component.get('c.getCustomLabels');
        getCustomLabels.setParams({
            'customLabels' : customLabels
        });

        getCustomLabels.setCallback(this, function(response) {
            console.log('TA_LCP254_DynamicHomepage >> Helper >> initCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let tabs = component.get('v.custom').tabs;
                let mdtLabels = response.getReturnValue();

                mdtLabels.forEach(function(mdtLabel) {
                    tabs.forEach(function(tab) {
                        if(tab.name == mdtLabel.MasterLabel) {
                            tab.name = mdtLabel.TA_Label__c;
                        } else if(tab.description == mdtLabel.MasterLabel) {
                            tab.description = mdtLabel.TA_Label__c;
                        }
                    });
                });

                component.set('v.tabs', tabs);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set('v.isSpinnerVisible', false);
            console.log('TA_LCP254_DynamicHomepage >> Helper >> initCallback >> End');
        });

        $A.enqueueAction(getCustomLabels);

        console.log('TA_LCP254_DynamicHomepage >> Helper >> getCustomLabels >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP254_DynamicHomepage >> Helper >> closeModal >> Start');

        let action = event.getParam("action");
        if(action == 'closeModal'){
            component.set("v.showSelectAccountModal", false);
            component.set("v.showAppointmentToBeConfirmed", false);
        }

        console.log('TA_LCP254_DynamicHomepage >> Helper >> closeModal >> End');
    },
})
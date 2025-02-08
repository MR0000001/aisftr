({
    initialize : function(component, event, helper) {
        console.log('TA_LCP216_GeneratedReport >> Helper >> initialize >> Start');
        let workOrderId = component.get("v.workOrderId");
        let isRefresh = false;
        
        if(event.currentTarget){            
            isRefresh = event.currentTarget.name == 'refresh'? true:false;
            this.fireToggleSpinnerEvent(component, true);
        }        
        console.log('TA_LCP216_GeneratedReport isRefresh: ' + isRefresh);
        let action = component.get("c.init");
        action.setParams({"workOrderId": workOrderId,
                            "isRefresh" : isRefresh});

        action.setCallback(this, function(response) {
            let returnValue = response.getReturnValue();
            if(response.getState() === "SUCCESS") {
                component.set("v.infoBag", JSON.parse(returnValue));
                component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
                component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
                component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
                component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
                component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                component.set('v.isInitialized', true);
                component.set('v.isToBeSigned', component.get("v.custom").isToBeSigned === "true");
                this.fireSendInitStateEvt(component, true);
                this.fireToggleSpinnerEvent(component, false);     
                if(isRefresh) location.reload();           
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                this.fireToggleSpinnerEvent(component, false);
            }
        });

        $A.enqueueAction(action);
        console.log('TA_LCP216_GeneratedReport >> Helper >> initialize >> End');
    },

    manageGeneratedReportModal : function(component, event, helper) {
        console.log('TA_LCP216_GeneratedReport >> Helper >> manageGeneratedReportModal >> Start');
        component.set("v.showGeneratedReportModal", !component.get("v.showGeneratedReportModal"));
        component.set("v.contentDocumentId",event.currentTarget.id);
        console.log('TA_LCP216_GeneratedReport >> Helper >> manageGeneratedReportModal >> End');
    },

    manageSubmitSignedReportModal : function(component, event, helper) {
        console.log('TA_LCP216_GeneratedReport >> Helper >> manageSubmitSignedReportModal >> Start');
        if(component.get("v.isToBeSigned")) {
            component.set("v.showSubmitSignedReportModal", !component.get("v.showSubmitSignedReportModal"));
        } else {
            this.manageGeneratedReportModal(component, event, helper);
        }
        console.log('TA_LCP216_GeneratedReport >> Helper >> manageSubmitSignedReportModal >> End');
    },

    submitReport : function(component, event, helper) {
        console.log('TA_LCP216_GeneratedReport >> Helper >> submitReport >> Start');
        this.fireToggleSpinnerEvent(component, true);
        this.manageGeneratedReportModal(component, event, helper);
        this.manageSubmitSignedReportModal(component, event, helper);
        component.set("v.isReportSigned", true);
        component.set("v.isReportSignedDesctiption", "The report is signed.");
        component.set("v.buttonReportDesctiption", "Open report");
        this.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP216_GeneratedReport >> Helper >> submitReport >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP216_GeneratedReport >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP216_GeneratedReport",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP216_GeneratedReport >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP216_GeneratedReport >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP216_GeneratedReport",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP216_GeneratedReport >> Helper >> fireSendInitStateEvt >> End');
    }
})
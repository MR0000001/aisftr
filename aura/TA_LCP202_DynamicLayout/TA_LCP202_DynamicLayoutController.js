({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleInitialize >> End');
    },

    handleManageAccordion : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageAccordion >> Start');
        component.set('v.objWrapper.show', !component.get('v.objWrapper.show'));
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageAccordion >> End');
    },

    handleManageCheckbox : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageCheckbox >> Start');
        helper.manageCheckbox(component, event);
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageCheckbox >> End');
    },

    handleManageEditing : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageEditing >> Start');
        helper.manageEditing(component, event);
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageEditing >> End');
    },

    handleManageField : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageField >> Start');
        helper.manageField(component, event.getSource().get('v.name'), event.getSource().get('v.value'));
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageField >> End');
    },

    handleManageButtons : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageButtons >> Start');
        helper.manageButtons(component, event);
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageButtons >> End');
    },

    handleRefresh : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleRefresh >> Start');
        if(event.getParam("action") == 'dynamic-layout-initialize') {
            helper.fireSendInitStateEvt(component, false);
            helper.initialize(component);
        }
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleRefresh >> End');
    },

    handleRedirectToObject : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleRedirectToObject >> Start');
        helper.redirectToObject(component, event);
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleRedirectToObject >> End');
    },
})
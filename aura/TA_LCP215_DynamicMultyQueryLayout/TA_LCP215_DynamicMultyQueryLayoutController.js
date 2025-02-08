({
    handleInitialize: function (component, event, helper) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleInitialize >> End');
    },

    handleManageAccordion : function(component, event, helper) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageAccordion >> Start');
        component.set('v.objWrapper.show', !component.get('v.objWrapper.show'));
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageAccordion >> End');
    },

    handleManageCheckbox : function(component, event, helper) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageCheckbox >> Start');
        helper.manageCheckbox(component, event);
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageCheckbox >> End');
    },

    handleManageEditing : function(component, event, helper) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageEditing >> Start');
        helper.manageEditing(component, event);
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageEditing >> End');
    },

    handleManageEditingPencil : function(component, event, helper) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageEditingPencil >> Start');
        helper.ManageEditingPencil(component, event);
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageEditingPencil >> End');
    },

    handleManageUpdate : function(component, event, helper) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageUpdate >> Start');
        helper.manageUpdate(component, event.getSource().get('v.name'));
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Controller >> handleManageUpdate >> End');
    }
})
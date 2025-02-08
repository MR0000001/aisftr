({
    doInit: function (component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> doInit >> Start');
        helper.init(component);
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> doInit >> End');
    },

    handleManageAccordion : function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageAccordion >> Start');
        if(component.get('v.general.show') == 'true') component.set('v.general.show', 'false');
        else component.set('v.general.show', 'true');
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageAccordion >> End');
    },

    handleOpenModal: function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleOpenModal >> Start');
        component.set('v.showModal', !component.get('v.showModal'));
        let cmpTarget = component.find('Modalbox');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleOpenModal >> END');
    },

    handleManageButtons : function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageButtons >> Start');
        helper.manageButtons(component, event, helper);
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageButtons >> End');
    },

    handleRedirectToObject : function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleRedirectToObject >> Start');
        helper.redirectToObject(component, event);
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleRedirectToObject >> End');
    },

    handleManageCheckbox : function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageCheckbox >> Start');
        helper.manageCheckbox(component, event, helper);
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageCheckbox >> End');
    },

    handleManageField : function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageField >> Start');
        helper.manageField(component, event, helper, event.getSource().get('v.name'));
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleManageField >> End');
    },
    handleRedirectToObject : function(component,event,helper){
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleRedirectToObject >> Start');
        helper.redirectToObject(component, event);
        console.log('TA_LCP214_DynamicTableLayout >> Controller >> handleRedirectToObject >> End');
    }
})
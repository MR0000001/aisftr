({
    handleIsOpen : function(component, event, helper) {
        console.log('TA_LCP264_DynamicListView >> Controller >> handleInitialize >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        if(component.get("v.isOpen")) {
            helper.initialize(component, event);
        } else {
            helper.fireToggleSpinnerEvent(component, false);
        }
        console.log('TA_LCP264_DynamicListView >> Controller >> handleInitialize >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP264_DynamicListView >> Controller >> handleCloseModal >> Start');
        if(event.currentTarget.name == 'relatedWoBack') {
            component.set('v.showRelatedWorkOrders', false);
            component.set('v.showMainView', true);
        } else component.set('v.isOpen', false);
        console.log('TA_LCP264_DynamicListView >> Controller >> handleCloseModal >> End');
    },

    handleChangeView : function(component, event, helper) {
        console.log('TA_LCP264_DynamicListView >> Controller >> handleChangeView >> Start');
        if(component.get('v.selectedListViewId')) helper.changeView(component);
        console.log('TA_LCP264_DynamicListView >> Controller >> handleChangeView >> End');
    },

    handleRowSelection : function(component, event, helper) {
        console.log('TA_LCP264_DynamicListView >> Controller >> handleChangeView >> Start');
        helper.rowSelection(component, event.getParam('selectedRows')[0], event.getSource().getLocalId());
        console.log('TA_LCP264_DynamicListView >> Controller >> handleChangeView >> End');
    },

    handleRowAction : function(component, event, helper) {
        console.log('TA_LCP264_DynamicListView >> Controller >> handleRowAction >> Start');
        helper.rowAction(component, event.getParam('action').name, event.getParam('row'));
        console.log('TA_LCP264_DynamicListView >> Controller >> handleRowAction >> End');
    },

    handleSearchAccount : function(component, event, helper) {
        console.log('TA_LCP264_DynamicListView >> Controller >> handleSearchAccount >> Start');
        if(component.get('v.accountNameLike').length > 3) helper.searchAccount(component);
        console.log('TA_LCP264_DynamicListView >> Controller >> handleSearchAccount >> End');
    },

    handleChangeFilter : function(component, event, helper) {
        console.log('TA_LCP264_DynamicListView >> Controller >> handleChangeFilter >> Start');
        if(event.getSource().get('v.name') == 'selectWoType') component.set('v.selectedWoType', event.getSource().get('v.value'));
        if(event.getSource().get('v.name') == 'selectWoStatus') component.set('v.selectedWoStatus', event.getSource().get('v.value'));
        if(event.getSource().get('v.name') == 'selectFaultType') component.set('v.selectedFaultType', event.getSource().get('v.value'));
        helper.filterRelatedWorkOrders(component);
        console.log('TA_LCP264_DynamicListView >> Controller >> handleChangeFilter >> End');
    }
})
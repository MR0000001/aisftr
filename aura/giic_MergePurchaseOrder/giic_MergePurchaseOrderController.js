/**
    @description giic_MergePurchaseOrderController - Controller JavaScript
    @date Mod 07/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
*/

({
    
    doInit: function(component,event,helper){
        component.set("v.sortAsc",true);
        //component.set("v.pageSize",pageSize);
        helper.getDraftPOdata(component);	
    },
    
    Search: function(component, event, helper) {
        helper.searchDraftPOdata(component,event);		
    },
    
    Merge: function(component, event, helper) {
        helper.mergePOdata(component,event, helper);
    },

    next: function(component,event,helper){
        helper.next(component);
    },
    
    Refresh: function(component, event, helper) {
         helper.refreshPOdata(component);		
    },
    
    previous: function(component,event,helper){
        helper.previous(component);
    },

    sortField: function(component, event, helper) {
        let field = event.currentTarget.title;
        let Wrapfield = 'cwrapperpo'; //this is the name of wrapper list of PO in apex class
        helper.sortMethod(component,helper,field,Wrapfield);
    },

    First: function(component,event,helper){
        helper.First(component);
    },

    Last: function(component,event,helper){
        helper.Last(component);
    },

    doView: function(component, event, helper) {
        let editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": event.target.id
        });
        editRecordEvent.fire();
    },

    onCheck: function(component, event, helper) {
        helper.onCheckRow(component, event, helper);
    },     

    onSelectChange: function(component, event, helper) {
        component.set("v.pageSize",component.find("recordSize").get("v.value"));
        helper.paginate(component);
    },

    onSelectAll: function(component,event,helper){
        helper.SelectAll(component);
    },

    Cancel: function(component,event,helper){
        helper.navigatetoListView(component);
    },

    mergeCluster: function(component,event,helper){
        helper.mergeCluster(component);
    },

    onFilterCluster: function(component,event,helper){
        helper.onFilterCluster(component,event,helper);
        helper.getDraftPOdata(component);	
        console.log('@@@ Current filter cluster: ' + component.get('v.filterCluster'));
    },

    backMergeOperation: function(component,event,helper){
        component.set('v.showConfirmMerge', false);
    },

    goMergeOperation: function(component,event,helper){
        helper.goMergeOperation(component,event,helper);
    },
    
})
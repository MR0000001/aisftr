({
	doInit : function(component, event, helper) {
        console.log('@@@do Init');
        helper.init(component, event, helper);
        
		
	},
    RTSOnWH: function (component, event) {
      var changeValue = event.getParam("value");
      console.log('@@@@ RTS Wh:' + changeValue);
      component.set("v.RTSOnWarehouse", changeValue);
    },
    POonCW: function (component, event) {
      var changeValue = event.getParam("value");
      console.log('@@@@ PO 100%:' + changeValue);
      component.set("v.POonCentralWarehouse", changeValue);
    },
    
    POonWH: function (component, event) {
      var changeValue = event.getParam("value");
      console.log('@@@@ PO 100%:' + changeValue);
      component.set("v.POonWarehouse", changeValue);
    },
    
    onChangeReason: function (component, event, helper) {
        var val = event.getSource().get('v.value');
	    console.log('@@@@ reason:' + val);
		component.set("v.reason", val);

    },
    closeModal : function(component, event, helper) {
      
            $A.get("e.force:closeQuickAction").fire();
    },
    
    selectDisposition : function(component, event, helper){
        helper.SelectionRowDisposition(component, event, helper);
       
    },
    
    startReceipt : function(component, event, helper){
       helper.startProcessRTS(component,event, helper)
       
    },
    
     handleSaveLine : function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log('draftValues ='+JSON.stringify(draftValues));
    	helper.handleSaveEdition(component, event, helper, draftValues);
    },
    
})
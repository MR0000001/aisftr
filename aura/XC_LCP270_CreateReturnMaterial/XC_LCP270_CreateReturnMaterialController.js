({
    doInit : function(component, event, helper) {

    },

    
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
      var dismissActionPanel = $A.get("e.force:closeQuickAction");
      dismissActionPanel.fire();
   },

    onConfirm: function(component, event, helper) {
        
        helper.createReturnMaterialWoli(component, event, helper);
    }
})
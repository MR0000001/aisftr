({
    
  doInit  : function(component, event, helper) {
      helper.init(component, event, helper);
  },
  
checkRecordType : function(component, event, helper) {
  helper.checkRecordType(component, event, helper);
  },
  
  searchContactToSelect : function(component, event, helper) {
  helper.searchContactToSelect(component, event, helper);
  },

  //DeAv 01.07.2022 - NR2330 START
  createNewAddress : function(component, event, helper) {
    component.set("v.showNewAddress", true);
  },

  createCase : function(component, event, helper) {
    helper.createCase(component, event, helper);
  },

  closeNewAddress: function(component, event, helper){
    helper.handleCloseNewAddress(component, event, helper);
  }
  //DeAv 01.07.2022 - NR2330 END
  
})
({
    init: function (component, event, helper) {
        console.log('@@@fetchdtata');
        helper.getColumn(component, event, helper);
        helper.fetchData(component, event, helper);
        
    },

    selectAddress : function(component, event, helper){
        helper.SelectionRowAddress(component, event, helper);
       
    },
    
     closeModal : function(component, event, helper) {
      
            $A.get("e.force:closeQuickAction").fire();
    },
      
     updateAddressOnPO : function(component, event, helper){
       console.log('@@@@ updateAddressOn PO');
         helper.upgradeAddressOnPO(component,event, helper)
       
    },
    
});
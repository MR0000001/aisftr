({
	doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
	},
    
    sblockAddress : function(component, event, helper) {
       // helper.selectAvaibleAddress(component, event, helper);
        helper.setAddress(component, event, helper);
        component.set('v.addressDisabled', false);
    	helper.change(component, event,helper); 
    },
    
    change : function (component, event, helper) {
       helper.change(component, event, helper) ;
    },
    
    changeOpportunityData : function (component, event, helper) {
       helper.changeOpportunityData(component, event, helper) ;
    },
    
    closeModel : function(component, event, helper) {
        helper.closeModel(component, event, helper);
        
    },

    closeModal : function(component, event, helper) {
        //component.destroy() ;
        $A.get("e.force:closeQuickAction").fire();

        //lancio evento per il close della finestra
        let ev = component.getEvent("XC_LCE019_CloseChildComponent");
        if (ev) {
            ev.fire();
        }
        
    },

    handleModalClosedEvent : function(component, event, helper) {
        helper.closeModel(component, event, helper);
    },
    
    onConfirm :   function(component, event, helper) {
        helper.handleSubmit(component, event, helper) ;
    },

    createAsset : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.createAsset(component, event, helper) ;
    },

    createAddress : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.createAddress(component, event, helper);
    },
    
    createResidentialAddress : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.createResidentialAddress(component, event, helper);
    },

    showRequiredFields: function(component, event, helper){
        $A.util.removeClass(component.find("productCategory"), "none");
    },

    closeNewAddress: function(component, event, helper){
        helper.handleCloseNewAddress(component, event, helper);
    }, 
    populateAddress : function(component, event, helper){
    	helper.setAddress(component, event, helper);
    },
    
    prodTypeChange : function(component,event,helper){
        helper.prodTypeChange(component,event,helper);
    },
    //Start CR758
    searchForSedeLegale: function(component,event,helper) {        
		let b = component.get("v.searchForSedeLegale");
		component.set("v.searchForSedeLegale",!b);
        helper.setAddress(component,event,helper);
        console.log("@@@@ searchForSedeLegale: "+component.get("v.searchForSedeLegale"));
    }
    //End CR758

})
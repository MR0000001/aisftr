({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },

    setPickCountry  : function(component, event, helper) {
        let selectedOptionValue = event.getParam("value");
        helper.setPickCountry(component, selectedOptionValue);
    },

    setPickCategory  : function(component, event, helper) {
       let selectedOptionValue = event.getParam("value");
       component.set("v.address.category", selectedOptionValue);
    },

    setPickStreetType  : function(component, event, helper) {
       let selectedOptionValue = event.getParam("value");
       component.set("v.address.streetType", selectedOptionValue);
    },

    setPickProvince  : function(component, event, helper) {
       let selectedOptionValue = event.getParam("value");
       component.set("v.address.province", selectedOptionValue);
    },
    
    saveAddress : function(component, event, helper) {
        helper.handleSaveButtonClick(component, event, helper);
	},
    
    onValidate :  function(component, event, helper) {
		helper.checkFieldsBeforeValidate(component, event, helper);
    },
    
    cancel : function(component, event, helper) {
        helper.cancel(component, event,helper);
    },

    searchbyPod : function(component, event, helper) {
         helper.searchbyPod(component, event, helper);
    },

    handleSecondaryButtonClick : function(component, event, helper) { 
        component.set("v.showStrikeModal",false);
        component.set("v.showPods",false);
    },

    handlePrimaryButtonClick : function(component, event, helper) {
        helper.handlePrimaryButtonClick(component, event, helper);      
    },

    skipValidation : function(component, event, helper) {
        helper.skipValidation(component, event, helper);
    },

    /* ---------------------- Methods for autocompleting address ---------------------- */

    typingAddress : function(component, event, helper) {
		console.log('Input: --> '+component.get("v.address.address"));
		helper.setDeelay(component, helper, component.get("v.address.address"), helper.typingAddress);
	},

	typingCity : function(component, event, helper) {
		console.log('Input: --> '+component.get("v.address.city"));
        helper.setDeelay(component, helper, component.get("v.address.city"), helper.typingCity);
        console.log('while searching...');
	},

	typingZip : function(component, event, helper) {
		console.log('Input: --> '+component.get("v.address.postalCode"));
		helper.setDeelay(component, helper, component.get("v.address.postalCode"), helper.typingZip);
	},

	checkAddress : function(component, event, helper) {
		console.log('Clicked address search bar');
		helper.checkAddress(component, event, helper);
	},

	checkCity : function(component, event, helper) {
		console.log('Clicked city search bar');
		helper.checkCity(component, event, helper);
	},

	checkZip : function(component, event, helper) {
		console.log('Clicked zip search bar');
		helper.checkZip(component, event, helper);
	},

	checkNumber : function(component, event, helper) {
		console.log('Clicked street number field');
		//helper.checkNumber(component, event, helper);
    },

	selectAddress : function(component, event, helper) {
		var inputString = event.target.id;
        helper.selectAddress(component, event, helper, inputString); 
	},
	
	selectCity : function(component, event, helper) {
		var inputString = event.target.id;
        helper.selectCity(component, event, helper, inputString); 
	},
	
	selectZip : function(component, event, helper) {
		var inputString = event.target.id;
        helper.selectZip(component, event, helper, inputString); 
    },
    	
	selectCup : function(component, event, helper) {
        component.set("v.selectedCup", event.getParam("selectedRows"));
    },
    
    onModify :  function(component, event, helper) {
        console.log('onModify');
		helper.onModify(component, event, helper);
    },

    clearAddress : function(component, event, helper) {
        helper.clearAddress(component, event, helper);
    }, 

    editPressed : function(component, event, helper) {
		helper.editPressed(component, event, helper);
    },
    
})
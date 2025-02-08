/*
 * @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
 * @date Creation  09/10/2018
 * @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_LCP000_RedirectLogicNewSobject – Controller for component to redirect Login "New Sobject"
**/

({

	init : function(component, event, helper) { 
		helper.doInit(component, event);
	},

	verifyUser : function(component, event, helper) {
		helper.verifyUserHelper(component, event, helper);		
	},

	showBody : function(component, event, helper) {
		component.set('v.showBodyControl', true);		
	},

})
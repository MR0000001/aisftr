/**
  @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  @date 26/03/2021
  @description XC_AMP_LCP020_SimplifiedSalesController - Controller Javascript for AMP_LCP020
*/

({
    init : function(component, event, helper) {
        console.log('@@@ In component XC_AMP_LCP020_SimplifiedSales');
        helper.doInit(component, event, helper);
    },

    /*onBackButton : function(component, event, helper) {
        console.log('@@@ In component XC_AMP_LCP020_SimplifiedSales');
        helper.onBackButton(component, event, helper);
    },*/

    onNextButton : function(component, event, helper) {
        console.log('@@@ In component XC_AMP_LCP020_SimplifiedSales');
        helper.onNextButton(component, event, helper);
    },

    handleAMPCommunicationEvent : function(component, event, helper) {
        console.log('@@@ In component XC_AMP_LCP020_SimplifiedSales');
		helper.handleChildCommunicationEvent(component, event, helper);
	},
})
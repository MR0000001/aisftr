/** 
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date Creation 15/06/2021
  * @description Controller class for Component XC_LCP254_SelectInvoiceDeliveryPreference
*/

({
    init : function(component, event, helper) {
        helper.doInit(component, helper, event);
    },

    changePreference : function(component, event, helper) {
        helper.changePreference(component, helper, event);
    },

    onChangeValue : function(component, event, helper) {
        let newValue = component.find('selectPreference').get('v.value');
        component.set('v.preferenceSelected', newValue);
    },
})
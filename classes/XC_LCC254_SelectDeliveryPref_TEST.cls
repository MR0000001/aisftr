/** 
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date Creation 15/06/2021
  * @description XC_LCC254_SelectDeliveryPref_TEST - Test Class for XC_LCC254_SelectDeliveryPreference 
*/

@isTest
private class XC_LCC254_SelectDeliveryPref_TEST {

    @isTest
    static void onSelectPreference() {
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        Schema.DescribeFieldResult fieldResult = NE__Order__c.XC_InvoiceDeliveryPreference__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> options = new List<String>();
        for(Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }     

        order.XC_InvoiceDeliveryPreference__c = options[0];
        update order;

        Test.startTest();
        XC_LCC254_SelectDeliveryPreference.ResultWrapper resWrapper = XC_LCC254_SelectDeliveryPreference.loadPreferences(order.Id);
        resWrapper = XC_LCC254_SelectDeliveryPreference.savePreference(order.Id, options[1]);
        resWrapper = XC_LCC254_SelectDeliveryPreference.savePreference(order.Id, 'Test');
        Test.stopTest();
    }

}
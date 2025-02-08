/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date 24/05/2019
* @description  – Test Class for XC_UTIL_AddressValidation
*/
@isTest
private class XC_UTIL_AddressValidation_TEST {
    static testMethod void AddressValidTest(){
        Test.startTest();
        XC_UTIL_AddressValidation.getWr();
        XC_UTIL_AddressValidation  v = new XC_UTIL_AddressValidation();
       	System.assertEquals(true,v != null);
        Test.stopTest();
    }

}
/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 21/05/2019
* @description Test Class for XC_UTIL_Country
*/
@isTest
private class XC_UTIL_Country_TEST {
    static testMethod void countryTest(){
        Test.startTest();
        String retriveCountryCode = XC_UTIL_Country.retriveCountryCode('Spain');
        List<Map<String,String>> retriveCountryPicklistValues = XC_UTIL_Country.retriveCountryPicklistValues();
        
		System.assert(!String.isBlank(retriveCountryCode));
        System.assert(!retriveCountryPicklistValues.isEmpty());
        Test.stopTest();
    }

}
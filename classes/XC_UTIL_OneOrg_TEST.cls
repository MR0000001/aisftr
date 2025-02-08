/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 20/05/2019
* @description Test Class for XC_UTIL_OneOrg
*/
@isTest
private class XC_UTIL_OneOrg_TEST {
    static testMethod void isRightCountryTest(){
        Test.startTest();
        List<String> cList = new List<String>{'Spain'};
        Boolean isRight = XC_UTIL_OneOrg.isRightCountry('Spain');
        Boolean isRightCountry = XC_UTIL_OneOrg.isRightCountry(cList);
       
        System.assert(true,isRight);
        System.assert(true,isRightCountry);
        Test.stopTest();
    }
    static testMethod void isRightCountryTest1(){
        Test.startTest();
        List<String> cList = new List<String>{''};
        Boolean isRight = XC_UTIL_OneOrg.isRightCountry('');
        Boolean isRightCountry = XC_UTIL_OneOrg.isRightCountry(cList);
       
        System.assert(true,isRight);
        System.assert(true,isRightCountry);
        Test.stopTest();
    }
    static testMethod void isRightCountryTest2(){
        Test.startTest();
        List<String> cList = new List<String>{'Spain',''};
        Boolean isRight = XC_UTIL_OneOrg.isRightCountry('');
        Boolean isRightCountry = XC_UTIL_OneOrg.isRightCountry(cList);
       
        System.assert(true,isRight);
        System.assert(true,isRightCountry);
        Test.stopTest();
    }
    static testMethod void isRightCountryTest3(){
        Test.startTest();
		XC_Exception e = new XC_Exception();
        Test.stopTest();
    }
}
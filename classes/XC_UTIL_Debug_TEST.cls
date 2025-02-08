/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 21/05/2019
* @description Test Class for XC_UTIL_Debug
*/
@isTest
private class XC_UTIL_Debug_TEST {
    static testMethod void debugTest(){
        Test.startTest();
        XC_CS003_ApexDebugActive__c cs = new XC_CS003_ApexDebugActive__c();
        cs.name = 'NAME';
        cs.XC_ClassName__c = 'NAME';
        cs.XC_LogActive__c = true;
        insert cs;

        Boolean isActive = XC_UTIL_DEBUG.isActive('NAME');        
        XC_UTIL_Debug.debug(true,System.LoggingLevel.INFO,'message');
        XC_UTIL_Debug.debug(true,'message');
        System.assert(isActive);
        System.assert('message' != null);
        Test.stopTest();
    }

}
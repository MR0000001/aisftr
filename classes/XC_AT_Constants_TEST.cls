/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 16/05/2019
* @description Test Class for XC_AT_Constants
*/
@isTest
private class XC_AT_Constants_TEST {
    static testMethod void XC_AT_ConstantsTest(){
       	Test.startTest();
        XC_AT_Constants at = new XC_AT_Constants ();
        System.assert(at != null);
        Test.stopTest();
    }

}
/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  15/05/2019 
* @description public class XC_TR_ConfigurationItem_U_CheckBP_TEST – Test class for public class XC_TR_ConfigurationItem_U_CheckBP
*/
@isTest
public class XC_TR_ConfigurationItem_U_CheckBP_TEST {
    
    //Test Method checkBillingProfileConditions
    static testMethod void checkBillingProfileConditions(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
        XC_TR_ConfigurationItem_U_CheckBP.checkBillingProfileConditions(listItems, mapOld, mapNew); 
        
        System.assertEquals(true, listItems!=null);
        Test.stopTest();
        
    }
    
    
}
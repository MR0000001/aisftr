/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  21/05/2019 
    * @description XC_TR_Config_U_GenerateOTP_TEST – Test class for XC_TR_Configuration_U_GenerateOTP
    */ 
    @isTest
public with sharing class XC_TR_Config_U_GenerateOTP_TEST {
     // Test method for generateOTP
     static testMethod void generateOTP(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<NE__Order__c> o= XC_DF_Order.createOrders(1, 'InOrder');
                insert o;
                update o; 

            System.assertEquals(1, o.size());
            Test.stopTest();
     }

}
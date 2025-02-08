/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  21/05/2019 
    * @description XC_TR_ConfigItem_U_CheckCase_TEST – Test class for XC_TR_ConfigurationItem_U_CheckCase
    */ 
    @isTest

public with sharing class XC_TR_ConfigItem_U_CheckCase_TEST {
      // Test method for onUpdate 
     static testMethod void onUpdate(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<NE__OrderItem__c> oi = XC_DF_OrderItem.createOrderItems(1);
                insert oi; 
                oi[0].NE__Status__c='Active';
                update oi; 

            Test.stopTest();
     }

}
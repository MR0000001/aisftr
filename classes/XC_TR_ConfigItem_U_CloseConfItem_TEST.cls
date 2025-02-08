/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  21/05/2019 
    * @description XC_TR_ConfigItem_U_CloseConfItem_TEST – Test class for XC_TR_ConfigurationItem_U_CloseConfItem
    */ 
    @isTest
public with sharing class XC_TR_ConfigItem_U_CloseConfItem_TEST {
      // Test method for closeConfigurationItem 
     static testMethod void closeConfigurationItem(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                   List<NE__Order__c> conf = XC_DF_Order.createOrders(1, 'InOrder');
                   List<NE__OrderItem__c> confitem = XC_DF_OrderItem.createOrderItems(1);
                    insert confitem;
                    //confitem[0].NE__Status__c ='Completed';  
                    
                    String confitemId = confitem[0].Id;
                    XC_Provisioning_Step__c provstep= XC_DF_ProvisioningStep.createProvisioningStep(confitemId);
                    provstep.XC_Status__c='Completed OK';
                    insert provstep;
                    update confitem;
                    System.assertEquals(1, confitem.size());
            Test.stopTest();
     }


}
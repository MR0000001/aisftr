/**
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 22/06/2021
 * @description XC_SC058_RetryProvisioningSteps_TEST – Test class for XC_SC058_RetryProvisioningSteps 
 */

@isTest
private class XC_SC058_RetryProvisioningSteps_TEST {

    @isTest
    static void relauchStep() {
        List<NE__OrderItem__c> listOrderItems = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItems;
        NE__Order__c order = [SELECT Id FROM NE__Order__c LIMIT 1];
        order.XC_Status__c = 'In Provisioning';
        update order;
        XC_Provisioning_Step__c step1a = XC_DF_ProvisioningStep.createProvisioningStep(listOrderItems[0].Id); 
        step1a.XC_Status__c = 'Completed KO';
        step1a.XC_Flow_API_Name__c = 'flowAPIKO';
        step1a.XC_ErrorMessage__c = 'errorMessageKO';  
        XC_Provisioning_Step__c step1b = XC_DF_ProvisioningStep.createProvisioningStep(listOrderItems[0].Id); 
        step1b.XC_Status__c = 'Completed KO';
        step1b.XC_Flow_API_Name__c = 'flowAPIKO';
        step1b.XC_ErrorMessage__c = 'errorMessageKO';  
        step1b.XC_RelaunchCount__c = 3;
        XC_Provisioning_Step__c step2a = XC_DF_ProvisioningStep.createProvisioningStep(listOrderItems[0].Id); 
        step2a.XC_status__c = 'In Progress'; 
        step2a.XC_Flow_API_Name__c = 'flowAPIInProgress'; 
        XC_Provisioning_Step__c step2b = XC_DF_ProvisioningStep.createProvisioningStep(listOrderItems[0].Id); 
        step2b.XC_status__c = 'In Progress'; 
        step2b.XC_Flow_API_Name__c = 'flowAPIInProgress';  
        step2b.XC_RelaunchCount__c = 3;
        insert new List<XC_Provisioning_Step__c>{step1a, step1b, step2a, step2b};
        XC_SC058_RetryProvisioningSteps.createErrorLog('testError', step1a.Id);
        
        Test.startTest();  
        String chron = '0 0 23 * * ?';         
        System.schedule('Test Scheduling', chron, new XC_SC058_RetryProvisioningSteps());
        Test.stopTest();
    }   
}
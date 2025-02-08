/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 05/03/2019
* @description XC_SC035_EnqueueProvisioningSteps_TEST – Test class for XC_SC035_EnqueueProvisioningSteps
*/

@isTest
private class XC_SC035_EnqueueProvisioningSteps_TEST {

    @isTest
    static void onRunEvent() {
        List<NE__OrderItem__c> listOrderItems = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItems;
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(listOrderItems[0].Id);
        step.XC_ToBeRelaunched__c = true;
        step.XC_status__c = 'in progress';
        XC_Provisioning_Step__c step2 = XC_DF_ProvisioningStep.createProvisioningStep(listOrderItems[0].Id);
        step2.XC_ToBeRelaunched__c = true;
        step2.XC_status__c = 'in progress';
        XC_Provisioning_Step__c step3 = XC_DF_ProvisioningStep.createProvisioningStep(listOrderItems[0].Id);
        step3.XC_ToBeRelaunchedFuture__c = true; 
        step3.XC_status__c = 'in progress';
        insert new List<XC_Provisioning_Step__c>{step, step2, step3};

        Test.startTest();  
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, new XC_SC035_EnqueueProvisioningSteps());
        System.schedule('Test SchedF', chron, new XC_SC035_EnqueueProvisioningStepsFuture());
        Test.stopTest();
    }

}
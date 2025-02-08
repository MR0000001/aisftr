/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  02/10/2020 
* @description XC_LCC198_ReLaunchProvisioningStep_TEST – Test class for XC_LCC198_ReLaunchProvisioningStep
*/
@isTest
public class XC_LCC198_ReLaunchProvisioningStep_TEST {
    
    static testMethod void testingLCC198 (){
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        insert confItem;
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        step.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        insert step;
        Test.startTest();
        XC_LCC198_ReLaunchProvisioningStep.relaunchProvisioningStep(step.Id);
        Test.stopTest();        
    }
    
    static testMethod void testingNotInProgressLCC198 (){
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        insert confItem;
        XC_Provisioning_Step__c step = XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        insert step;
        Test.startTest();
        XC_LCC198_ReLaunchProvisioningStep.ResultWrapper wrapper = new XC_LCC198_ReLaunchProvisioningStep.ResultWrapper();
        XC_LCC198_ReLaunchProvisioningStep.relaunchProvisioningStep(step.Id);
        Test.stopTest();        
    }
}
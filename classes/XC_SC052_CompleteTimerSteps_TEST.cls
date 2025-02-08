/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 10/05/2021
* @description XC_SC052_CompleteTimerSteps_TEST – Test class for XC_SC052_CompleteTimerSteps
*/

@isTest
public class XC_SC052_CompleteTimerSteps_TEST {
    @isTest
    static void executeBatch() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        insert order;
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order);
        insert orderItem;
        XC_Provisioning_Step__c stepOne = XC_DF_ProvisioningStep.createProvisioningStep(orderItem.Id);
        stepOne.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        stepOne.XC_TimerStep__c = true;
        stepOne.XC_UnblockingDate__c = Date.today().addDays(-2);
        insert stepOne;
        Test.startTest();
        XC_SC052_CompleteTimerSteps myClass = new XC_SC052_CompleteTimerSteps(); 
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();

    }
}
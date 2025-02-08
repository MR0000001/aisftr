/**
 * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @date Creation  18/06/2019
 * @description XC_TR_ProvisioningStep_U_FinalStat_TEST – Test class for XC_TR_ProvisioningStep_U_StepFinalStatus
 */
@isTest
public with sharing class XC_TR_ProvisioningStep_U_FinalStat_TEST {
     @TestSetup
    static void setup(){
        Test.startTest();
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItems(1)[0];
        insert confItem;
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningExecutePayment_Flow;
        insert ps;
        insert XC_DF_ServiceAppointment.createServiceAppointment(2);
        Test.stopTest();
    }
    // Test method for onAfterUpdate
    static testMethod void onAfterUpdate(){
        Test.startTest();
		XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Configuration_Item__c!=null LIMIT 1];
      
        List<WorkOrder> woList = [SELECT Id, XC_Configuration_Item__c FROM WorkOrder];
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        for (WorkOrder wo : woList){
            wo.XC_Configuration_Item__c = ps.XC_Configuration_Item__c;
            wo.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
            woListToUpdate.add(wo);
        }
        update woListToUpdate;  
        ps.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        ps.XC_Step_Order__c = 1;
        update ps;
        delete ps;
        System.assertEquals(ps.XC_Status__c, Label.XC_CL_Step_CompletedKO);
        Test.stopTest();
    }
}
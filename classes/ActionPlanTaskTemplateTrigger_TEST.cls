/**
* @author
* @date Creation  07/12/2020 
* @description XC_TR_ProvisioningStep_U_PopFields_TEST – Test class for XC_TR_ProvisioningStep_U_PopFields
*/ 
@isTest
public class XC_TR_ProvisioningStep_U_PopFields_TEST {
     @TestSetup
    static void setup(){
        Test.startTest();
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        List<XC_Provisioning_Step__c> stepList = new List<XC_Provisioning_Step__c>();
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItems(1)[0];
        insert confItem;
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow;
        stepList.add(ps);
        XC_Provisioning_Step__c ps2= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);
        ps2.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningExecutePayment_Flow;
        stepList.add(ps2);
        insert stepList;
        Test.stopTest();
    }
    
        // Test method for onAfterUpdate
    static testMethod void onAfterUpdate(){
        Test.startTest();
		XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c WHERE XC_Configuration_Item__c!=null AND XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningCreateSubscription_Flow];
        ps.XC_MasterOfSubscription__c = false;
        update ps;
        Test.stopTest();
    }
}
@isTest
public class XC_TR_ProvisioningStep_Handler_TEST {
    public static testMethod void testTrigger1(){
        OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
        insert org;
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        XC_Provisioning_Step__c step  = XC_DF_ProvisioningStep.createProvisioningStep(orderItemList[0].id);
        test.startTest();
        insert step;
        update step;
        delete step;
        XC_TR_ProvisioningStep_Handler assetHandler =new XC_TR_ProvisioningStep_Handler();
       assetHandler.onAfterUnDelete(null); 
        test.stopTest();
    }
}
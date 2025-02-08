/**
* @author Salvatore Scarpato
* @date Creation 11/06/2019
* @description XC_TR_CompVerStatus_U_ParentToKO_TEST – Test class for XC_TR_CompVerStatus_U_ParentToKO
*/ 
@isTest
private class XC_TR_CompVerStatus_U_ParentToKO_TEST {
    @TestSetup 
    static void testSetup() {
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opport = oppList[0];
        opport.Name = 'TEST';
        opport.AccountId = accounts[0].Id;
        opport.StageName = 'Draft';
        opport.CloseDate = Date.today();
        opport.XC_LegalEntity__c = 'EndesaX';
        insert opport;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.NE__OptyId__c = opport.Id;
        insert order;
        
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        Asset asst = listAsset[0];
        asst.XC_Configuration_Item__c = ordIt.Id;
        insert asst;
        
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
        
        XC_ComplianceVerificationStatus__c complianceVerStatus = new XC_ComplianceVerificationStatus__c();
        complianceVerStatus.XC_ComplianceType__c = 'C1';
        complianceVerStatus.Name = 'DNI';
        complianceVerStatus.XC_Order__c = order.Id;
        insert complianceVerStatus;
        
    }
    
    static testMethod void onUpdate() {
        
        List<XC_ComplianceVerificationStatus__c> complianceVerificationStList  = [SELECT Id FROM XC_ComplianceVerificationStatus__c];
        
        complianceVerificationStList[0].XC_ComplianceStatus__c = Label.XC_CL_ComplianceVerificationStatus_KoFinal;
        update complianceVerificationStList;
        System.assertEquals(1, complianceVerificationStList.size());
        
    }
}
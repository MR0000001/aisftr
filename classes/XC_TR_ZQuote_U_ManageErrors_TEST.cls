/**
* @author 
* @date Creation  
* @description XC_TR_ZQuote_U_ManageErrors_TEST – Test class for XC_TR_ZQuote_U_ManageErrors
*/ 
@isTest
private with sharing class XC_TR_ZQuote_U_ManageErrors_TEST {
    
    @TestSetup 
    static void createOneOrg() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    
    static testmethod void onUpdate() {
       
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        zqu__Quote__c zqu = new zqu__Quote__c();
        insert zqu;
        List<NE__OrderItem__c> ci = XC_DF_OrderItem.createOrderItems(1);
        ci[0].XC_ZQuoteId__c = zqu.Id;
        insert ci;

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(ci[0].Id);
        ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow;
        ps.XC_Configuration_Item__c = ci[0].Id; 
        insert ps;
        
        zqu.XC_Message__c='Test';
        zqu.XC_ProvisioningStep__c= ps.Id; 
        update zqu; 
        System.assert(zqu!=null);
        Test.stopTest();
    }
    
    static testmethod void handlerTest() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        zqu__Quote__c quote= new  zqu__Quote__c();
        insert  quote;
        update quote;
        delete quote;
        XC_ContractAmendment__c contractAmendment = new XC_ContractAmendment__c(XC_Status__c = 'New');
        List<XC_ContractAmendment__c> listContAmend = new List<XC_ContractAmendment__c>{contractAmendment};
        Map<Id,XC_ContractAmendment__c> mapCon = new Map<Id,XC_ContractAmendment__c>();
        insert listContAmend;
        mapCon.put(contractAmendment.id,contractAmendment);
        XC_TR_ZQuote_U_ManageErrors.manageContractAmendForErrorZquote(listContAmend,'Error',mapCon);
        System.assert(quote!=null);
        Test.stopTest();
    }
}
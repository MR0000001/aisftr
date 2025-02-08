/**
 * The Class XC_IN060_ContractAmendmentActiva_TEST.
 *
 * @author            : Daniele Lico
 * @date Creation     : 
 * @date Modification : dd/mm/yyyy
 * @description       : XC_IN060_ContractAmendmentActiva_TEST
 **/

@isTest

public class XC_IN060_ContractAmendmentActiva_TEST {
    static testMethod void activateContractAmendment(){
        Test.startTest();
        List<Contact> cont =XC_DF_Contact.createResidentialContacts(1);
        insert cont;
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_NDADocumentNeeded__c=true;
        accList[0].	XC_ContactToNotify__c=cont[0].id;
        insert accList;
        List<NE__OrderItem__c> orderItem = XC_DF_OrderItem.createOrderItems(1);
        insert orderItem; 
         List<Asset> relatedAsset = XC_DF_Asset.createAssets(1);
        relatedAsset[0].XC_SubscriptionName__c= 'A-S-CL00000462';
        relatedAsset[0].XC_Configuration_Item__c= orderItem[0].id;
        insert relatedAsset;
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        step.XC_Configuration_Item__c = orderItem[0].id;
        step.XC_Step_Order__c=1;
        insert step;        
        XC_IN060_ContractAmendmentActivation.InputWrapper wrapper = new XC_IN060_ContractAmendmentActivation.InputWrapper();
        wrapper.stepId = step.id;
        XC_REST_RenewSubscription.WrapperRequest populateWrapperReq = new XC_REST_RenewSubscription.WrapperRequest();
        XC_IN060_ContractAmendmentActivation.activateContractAmendment(new List<XC_IN060_ContractAmendmentActivation.InputWrapper>{wrapper});
        System.assert(wrapper != NULL);
        Test.stopTest();
    }
}
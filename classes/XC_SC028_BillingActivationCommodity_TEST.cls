/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 17/03/2020
 * @description XC_SC028_BillingActivationCommodity_TEST - Test class for XC_SC028_BillingActivationCommodity
 */

@isTest
private class XC_SC028_BillingActivationCommodity_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC028_BillingActivationCommodity_TEST');

    @isTest
    static void onBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Contact cnt = XC_DF_Contact.createResidentialContacts(1)[0];
        insert cnt;
        NE__Billing_Profile__c billingProfile = XC_DF_BillingProfile.createBillingProfile(1)[0];
        XC_BillingProfileLineItem__c bpl = [SELECT Id FROM XC_BillingProfileLineItem__c WHERE XC_BillingProfile__c = :billingProfile.Id LIMIT 1];
        bpl.XC_DocumentType__c = 'CF';
        bpl.XC_DocumentNumber__c = 'MPRFNC93A28C858Y';
        bpl.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        bpl.XC_BillToContactId__c = cnt.Id;
        bpl.XC_SoldToContactId__c = cnt.Id;
        update bpl;
        billingProfile.NE__Payment__c = Label.XC_CL_Payment_CommodityBill;
        billingProfile.XC_Status__c = Label.XC_CL_BillingStatus_StatusActivation;
        billingProfile.XC_CommodityContractID__c = 'Test';
        update billingProfile;

        Test.startTest();
        Id batchId = Database.executeBatch(new XC_SC028_BillingActivationCommodity());
        System.assertNotEquals(null, batchId);
        Test.stopTest();
    }

}
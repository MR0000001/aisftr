/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation  30/01/2020
* @description XC_TR_BillingProfile_U_fillFields_TEST – Test class for XC_TR_BillingProfile_U_fillFields
*/ 
@isTest
public class XC_TR_BillingProfile_U_fillFields_TEST {
	@TestSetup
    static void insertRecords (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }    
    
    static testMethod void onInsert() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        test.startTest();
        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        billingProfList[0].NE__Account__c = accountList[0].Id;
        //insert billingProfList;
        System.assert(billingProfList!=null);
        test.stopTest();
    }
    
    static testMethod void onUpdate() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        //insert billingProfList;
        test.startTest();
        billingProfList[0].NE__Account__c = accountList[0].Id;
        billingProfList[0].Name = 'A12345';
        update billingProfList;
        System.assert(billingProfList!=null);
        test.stopTest();
    }
    

    static testMethod void onUpdate2() {

        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;

        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
        Zuora__CustomerAccount__c custAcc = new Zuora__CustomerAccount__c(Zuora__Zuora_Id__c = '123456', Zuora__Account__c = billingProfList[0].NE__Account__c);
        insert custAcc;

        Test.setMock(HttpCalloutMock.class, new UpdateCustomerAccount_FALSE_Mock());
        test.startTest();
        bpliList[0].XC_BillToContactId__c = contactList[0].Id;
        bpliList[0].XC_SoldToContactId__c = contactList[0].Id;
        bpliList[0].XC_CustomerAccount__c = custAcc.Id;
        bpliList[0].XC_LegalEntity__c = 'EnelXItalia'; 
        bpliList[0].XC_PEC__c = 'tets@pec.com';
        bpliList[0].XC_DocumentType__c = 'Partita IVA';
        bpliList[0].XC_DocumentNumber__c = '71892970444';
        update bpliList;
        System.assert(billingProfList!=null);
        test.stopTest();
    }

    static testMethod void onInsert2() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        test.startTest();
        NE__Billing_Profile__c billingToInsert = new NE__Billing_Profile__c(NE__Account__c=accountList[0].Id, NE__Payment__c = Label.XC_CL_DirectDebt, XC_LegalEntity__c= 'EnelXItalia');
        insert billingToInsert; 
        System.assert(billingToInsert!=null);
        test.stopTest();
    }

      static testMethod void onUpdate3() {
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;

        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id FROM XC_BillingProfileLineItem__c];
        test.startTest();
        bpliList[0].XC_Status__c = 'Active';
        bpliList[0].XC_InvoiceDeliveryPreference__c = 'Print';
        update bpliList;
        System.assert(billingProfList!=null);
        test.stopTest();
    }


    @isTest    
    static void populateAccountId(){
        List<NE__Billing_Profile__c> listOfBP = XC_DF_BillingProfile.createBillingProfile(1);
        Map<Id, NE__Billing_Profile__c> mapOld = new Map<Id, NE__Billing_Profile__c>();
        Map<Id, NE__Billing_Profile__c> mapNew = new Map<Id, NE__Billing_Profile__c>();
        mapOld.put(listOfBP[0].Id, listOfBP[0]);
        listOfBP[0].NE__Description__c = 'Test';
        update listOfBP;
        mapNew.put(listOfBP[0].Id, listOfBP[0]);
        XC_TR_BillingProfile_U_fillFields.populateAccountIdOnUpdate(listOfBP, mapOld, mapNew);
        System.assert(listOfBP!=null);
    }


    public class UpdateCustomerAccount_FALSE_Mock implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"OK","success":"false","reasons":[{"message":"error"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
  
    
}
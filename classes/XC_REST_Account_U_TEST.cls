@isTest
public with sharing class XC_REST_Account_U_TEST { 

    @TestSetup
	static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    }
    
    static testMethod void createBillingProfileResponseGET(){
    
    
        /*
        List<NE__Billing_Profile__c> billingProfileList = new List<NE__Billing_Profile__c>();
        NE__Billing_Profile__c bp = new NE__Billing_Profile__c();
        bp.XC_Token__c = '12345';
        NE__Billing_Profile__c bp1 = new NE__Billing_Profile__c();
        bp1.XC_Status__c = 'Active';
        bp1.name = 'asd';
        bp1.XC_Token__c = '12345';
        
        billingProfileList.add(bp);
        billingProfileList.add(bp1);*/

        XC_UTIL_Account.AccountIFWrapper accWR = new XC_UTIL_Account.AccountIFWrapper();
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        bpList[0].XC_Status__c = 'Active';
        bpList[0].Name = 'Test';
        update bpList;

        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id, XC_BillingProfile__c, XC_ExternalKey__c, XC_PEC__c, XC_RecipientCode__c, XC_BillToAddressText__c, XC_SoldToAddressText__c, XC_SoldToAddress__c, XC_BillToAddress__c, XC_LegalEntity__c FROM XC_BillingProfileLineItem__c];
        
        test.startTest();
        XC_REST_Account_U.createBillingProfileResponseGET(bpList, accWR, bpliList, 'XInstaller');
        test.stopTest();
    }
    
    static testMethod void manageContactDuplicationError(){
    	XC_REST_Account_W.WrapperRequest wrReq = new XC_REST_Account_W.WrapperRequest();

        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;

        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        insert conList;
        
        XC_UTIL_Account.ContactIFWrapper wrCon = new XC_UTIL_Account.ContactIFWrapper();
        wrCon.email = conList[0].Email;
        wrCon.IdentityType = 'NIF';
        wrCon.IdentityNumber = '45232922H';
        wrReq.contact = new List<XC_UTIL_Account.ContactIFWrapper>();
        wrReq.contact.add(wrCon);
        
        test.startTest();
        String isGuest = 'No';
        XC_REST_Account_U.manageContactDuplicationError(wrReq, wrResp, isGuest);

        isGuest = 'Yes';
        conList[0].XC_isGuestContact__c = 'Yes';
        update  conList;
        XC_REST_Account_U.manageContactDuplicationError(wrReq, wrResp, isGuest);
    
        
        test.stopTest();
    }
    

}
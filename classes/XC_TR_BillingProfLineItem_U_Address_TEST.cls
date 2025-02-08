/**
* @author Sara Miozza sara.miozza@nttdata.com
* @date Creation  21/05/2019 
* @description XC_TR_BillingProfLineItem_U_Address_TEST – Test class for XC_TR_BillingProfLineItem_U_Address
*/ 
@isTest
public class XC_TR_BillingProfLineItem_U_Address_TEST {
    
    @TestSetup
    static void setup(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__Billing_Profile__c> billingProfList = XC_DF_BillingProfile.createBillingProfile(1);
		billingProfList[0].XC_Segment__c =  'B2C';
		update billingProfList;
    }

    @isTest
    static void updateAdressFieldsTest(){
        
        List<XC_BillingProfileLineItem__c> billingProfLineItem = [SELECT Id,XC_BillingProfileName__c,XC_BillingProfile__c,XC_BillingAddress__c,XC_BillingAddressCopy__c,XC_SoldToAddress__c,XC_SoldToAddressCopy__c, XC_BillToAddress__c 
                                                                    FROM XC_BillingProfileLineItem__c LIMIT 1];
        Test.startTest();
        XC_TR_BillingProfileLineItem_U_Address.updateAdressFields(billingProfLineItem);
        billingProfLineItem[0].XC_BillingProfileName__c = 'Test';
        update billingProfLineItem;
        delete billingProfLineItem;
        Test.stopTest();
        System.assertequals(true, billingProfLineItem[0].XC_BillingProfile__c!= null, 'Wrong assert equals');
    }

    @isTest
    static void callZuoraFalse(){

        List<XC_BillingProfileLineItem__c> billingProfLineItem = [SELECT Id, XC_BillingProfile__r.NE__Account__c FROM XC_BillingProfileLineItem__c LIMIT 1];
        
        List<XC_Address__c> addressList = XC_DF_Address.createAddress(1);
        insert addressList;

        
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;

        Zuora__CustomerAccount__c custAcc = new Zuora__CustomerAccount__c(Zuora__Zuora_Id__c = '123456', Zuora__Account__c = billingProfLineItem[0].XC_BillingProfile__r.NE__Account__c);
        insert custAcc;

        //billingProfLineItem[0].XC_BillToAddress__c = addressList[0].Id;
        //billingProfLineItem[0].XC_SoldToAddress__c = addressList[0].Id;
        billingProfLineItem[0].XC_BillToContactId__c = contactList[0].Id;
        billingProfLineItem[0].XC_SoldToContactId__c = contactList[0].Id;
        billingProfLineItem[0].XC_CustomerAccount__c = custAcc.Id;
        billingProfLineItem[0].XC_LegalEntity__c = 'EndesaX';
        update billingProfLineItem[0];        

        Test.setMock(HttpCalloutMock.class, new UpdateCustomerAccount_FALSE_Mock());
        addressList[0].XC_Account__c=billingProfLineItem[0].XC_BillingProfile__r.NE__Account__c;
        update addressList;
        Test.startTest();
        billingProfLineItem[0].XC_BillToAddress__c = addressList[0].Id;
        update billingProfLineItem[0];
        Test.stopTest();

        System.assertequals(true, billingProfLineItem[0].XC_BillToAddress__c == addressList[0].Id, 'Wrong assert equals');
    }

    public class UpdateCustomerAccount_FALSE_Mock implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"OK","success":"false","reasons":[{"message":"testKO"}]}');
            res.setStatusCode(200);
            return res;
        }
    }

}
/**
*@author Sara Miozza - sara.miozza@nttdata.com
*@date Creation 20/05/2019
*@date Modification dd/MM/yyyy
*@description XC_LCC078_ChangePaymentMethod_TEST test class for XC_LCC078_ChangePaymentMethod
*/

@isTest
public class XC_LCC078_ChangePaymentMethod_TEST {

    @TestSetup
    static void testSetup(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        Contact contact = XC_DF_Contact.createResidentialContacts(accList)[0];
        contact.XC_PrimaryContact__c = true;
        insert contact;
        NE__Billing_Profile__c billingProf = new NE__Billing_Profile__c(NE__Account__c = accList[0].Id,XC_LegalEntity__c = 'EnelXItalia');
        insert billingProf;
        Account account = new Account(Id = accList[0].Id, XC_Country__c = 'Spain');
        update account;
        XC_BillingProfileLineItem__c billingProfileLineItem = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = billingProf.Id);
        billingProfileLineItem.XC_Status__c = 'Active';
        insert billingProfileLineItem;
        
    }

    @isTest
    static void checkToChangePaymentMethod1Test(){
        Test.startTest();
        NE__Billing_Profile__c billingProf = [SELECT Id FROM NE__Billing_Profile__c LIMIT 1];
        billingProf.NE__Payment__c = Label.XC_CL_DirectDebt;
        update billingProf;
        String recordId = billingProf.Id;
        try{
        XC_UTIL_ResultWrapper rw = XC_LCC078_ChangePaymentMethod.checkToChangePaymentMethod(recordId);
        System.assert(rw.success); 
        }catch (AuraHandledException e){
        }

        Test.stopTest();
    }

    @isTest
    static void checkToChangePaymentMethod2Test(){
         Test.startTest();
        NE__Billing_Profile__c billingProf = [SELECT Id FROM NE__Billing_Profile__c LIMIT 1];
        billingProf.NE__Payment__c = Label.XC_CL_Commodity_Bill;
        update billingProf;
        String recordId = billingProf.Id;
        try{
            XC_UTIL_ResultWrapper rw = XC_LCC078_ChangePaymentMethod.checkToChangePaymentMethod(recordId);
            System.assert(rw.success); 
        }catch (AuraHandledException e){
        }
        Test.stopTest(); 
    }
    @isTest
    static void createPaymentMethodTest(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        createZuoraPayment();
    } 
    @future(callout = true)
    public static void createZuoraPayment(){
        XC_CM_ZuoraOAuth__mdt cm = new XC_CM_ZuoraOAuth__mdt ();
        //cm.XC_EntityName__c  = 'UAT Spain B2C';
        //cm.XC_OrgId__c= '00D6E0000004ayBUAQ';
        
        
        String entityName = '%Spain%';        
        String paymentMethod = Label.XC_CL_DirectDebt;
        String res = XC_LCC078_ChangePaymentMethod.createPaymentMethod(paymentMethod, entityName);
        System.assert(!String.isBlank(res));
    }
    @isTest
    static void updatePaymentMethodTest(){
         Test.startTest();
        NE__Billing_Profile__c billingProf = [SELECT Id FROM NE__Billing_Profile__c LIMIT 1];
        billingProf.NE__Payment__c = Label.XC_CL_Commodity_Bill;
        update billingProf;
        String recordId = billingProf.Id;
        XC_LCC078_ChangePaymentMethod.updatePaymentMethod('{"accountId": "123456"}', recordId);
        Test.stopTest(); 
    }
    @future(callout = true)
    public static void linkPaymentMethodToAccountF1(){              
        String zuoraAccountId = '54674722';
        String paymentMethodId = '1232323323'; 
        String entityName = 'Spain';
        XC_LCC078_ChangePaymentMethod.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId, entityName,'');
	} 
    @isTest
    public static void  linkPaymentMethodToAccountTest(){    
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        linkPaymentMethodToAccountF1();       
    }
    @isTest
    public static void  updateCurrentBillingProfile(){
        NE__Billing_Profile__c billingProf = [SELECT Id FROM NE__Billing_Profile__c LIMIT 1];
        billingProf.NE__Payment__c = Label.XC_CL_Commodity_Bill;
        update billingProf;
        String recordId = billingProf.Id;
        Map<String, Object> mapBillingProfile = new Map<String, Object>();
        mapBillingProfile.put('bpId', recordId);
        mapBillingProfile.put('accountNumber', 123456);
        mapBillingProfile.put('mop', 'Direct Debt');
        mapBillingProfile.put('bic', 123456);
        mapBillingProfile.put('mandateType', 'Recurring');
        XC_LCC078_ChangePaymentMethod.updateCurrentBillingProfile(mapBillingProfile); 
        mapBillingProfile.put('mop', 'Credit Card');
        XC_LCC078_ChangePaymentMethod.updateCurrentBillingProfile(mapBillingProfile);
    }
    @isTest
    public static void  createChangePaymentMethodCaseTest(){
        NE__Billing_Profile__c billingProf = [SELECT Id FROM NE__Billing_Profile__c LIMIT 1];
        billingProf.NE__Payment__c = Label.XC_CL_Commodity_Bill;
        update billingProf;
        String recordId = billingProf.Id;
        XC_LCC078_ChangePaymentMethod.createChangePaymentMethodCase(recordId, null);
    }

    @isTest
    public static void getPaymentMethodsPicklistTest(){
        Test.startTest();
            XC_LCC078_ChangePaymentMethod.getPaymentMethodsPicklist();
        Test.stopTest();
    }    
    

}
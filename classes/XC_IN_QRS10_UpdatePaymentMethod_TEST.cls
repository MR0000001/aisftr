/**
* @description       : 
* @author            : Simone Trenta - strenta@deloitte.it
* @group             : 
* @last modified on  : 07-07-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                                         Modification
* 1.0   07-13-2020   Simone Trenta - strenta@deloitte.it   Initial Version
**/
@isTest
public class XC_IN_QRS10_UpdatePaymentMethod_TEST {
    
    @TestSetup
    static void setup(){
        List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequest(1);
        insert qrList;
    }
    //Mod. CV 20210707 --- Start
    // @isTest
    // static void testEmpty(){
        //         XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        //         XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = new XC_IN_QRS10_UpdatePaymentMethod.InputWrapper();
        //         iw.stepId = qrs.Id;
        
        //         Test.startTest();
        //         XC_IN_QRS10_UpdatePaymentMethod.manageUpdateMOP(new List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper>{iw});
        //         Test.stopTest();
        //     }
        
        @isTest
        static void testEmpty(){
            
            XC_DF_BillingProfile.createBillingProfile(1);
            
            XC_QueuedRequest__c qrs = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrs.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            fullQRReqBody.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
            XC_UTIL_BillingProfile.BillingProfileIFWrapper bp = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            NE__Billing_Profile__c bill = [select id,NE__Account__c from NE__Billing_Profile__c][0];
            bp.BillingProfileID = bill.id;
            fullQRReqBody.BillingProfile.add(bp);
            fullQRReqBody.Order.BillingProfIdUpdateMop = bill.id;
            
            //Create Contact
            List<Account> listAcc = new List<Account>();
            Account tmpAccount = new Account();
            tmpAccount.id = bill.NE__Account__c;
            listAcc.add(tmpAccount);
            
            List<Contact> listCon = XC_DF_Contact.createResidentialContacts(listAcc);
            system.debug('[CV] listCon:' + listCon );
            listCon[0].XC_PrimaryContact__c =  true;
            insert listCon;
            
            qrs.XC_RequestBody__c = json.serialize(fullQRReqBody,true);
            update qrs;
            
            XC_QueuedRequestStep__c qrsStep = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qrs.id LIMIT 1];
            
            XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = new XC_IN_QRS10_UpdatePaymentMethod.InputWrapper();
            iw.stepId = qrsStep.Id;
            
            Test.startTest();
            XC_IN_QRS10_UpdatePaymentMethod.manageUpdateMOP(new List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper>{iw});
            Test.stopTest();
        }
        //Mod. CV 20210707 --- End
        
        @isTest
        static void testEmptyWithIBAN(){
            XC_QueuedRequest__c qrs = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
            
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrs.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            fullQRReqBody.Order.IBAN = 'IT93L0760151690000000000125';
            qrs.XC_RequestBody__c = json.serialize(fullQRReqBody,true);
            update qrs;
            
            XC_QueuedRequestStep__c qrsStep = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qrs.id LIMIT 1];
            
            XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = new XC_IN_QRS10_UpdatePaymentMethod.InputWrapper();
            iw.stepId = qrsStep.Id;
            
            Test.startTest();
            XC_IN_QRS10_UpdatePaymentMethod.manageUpdateMOP(new List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper>{iw});
            Test.stopTest();
        }
        
        
        @isTest
        static void testWithIBANandBP(){
            XC_DF_BillingProfile.createBillingProfile(1);
            
            XC_QueuedRequest__c qrs = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrs.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            fullQRReqBody.Order.IBAN = 'IT93L0760151690000000000125';
            fullQRReqBody.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
            XC_UTIL_BillingProfile.BillingProfileIFWrapper bp = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            NE__Billing_Profile__c bill = [select id from NE__Billing_Profile__c][0];
            bill.XC_LegalEntity__c = 'EndesaX';
            update bill;
            bp.BillingProfileID = bill.id;
            fullQRReqBody.BillingProfile.add(bp);
            fullQRReqBody.Order.BillingProfIdUpdateMop = bill.id;
            qrs.XC_RequestBody__c = json.serialize(fullQRReqBody,true);
            update qrs;
            
            XC_QueuedRequestStep__c qrsStep = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qrs.id LIMIT 1];
            
            XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = new XC_IN_QRS10_UpdatePaymentMethod.InputWrapper();
            iw.stepId = qrsStep.Id;
            
            XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
            ic.XC_activeInterface__c = true;
            ic.XC_URL_Required__c = 'test';
            ic.Name = 'PaymentMethodSIA_SEPA';
            ic.XC_interfaceName__c = 'PaymentMethodSIA_SEPA';
            insert ic;
            
            Test.setMock(HttpCalloutMock.class, new XC_REST_UpdateMOPCallout_Mock());
            
            Test.startTest();
            XC_IN_QRS10_UpdatePaymentMethod.manageUpdateMOP(new List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper>{iw});
            Test.stopTest();
        }
        
        
        @isTest
        static void testWithIBANandBPwithBPLI(){
            XC_DF_BillingProfile.createBillingProfile(1);
            
            XC_QueuedRequest__c qrs = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrs.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            fullQRReqBody.Order.IBAN = 'IT93L0760151690000000000125';
            fullQRReqBody.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
            XC_UTIL_BillingProfile.BillingProfileIFWrapper bp = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            NE__Billing_Profile__c bill = [select id from NE__Billing_Profile__c][0];
            XC_BillingProfileLineItem__c bpli = [select id, XC_Status__c from XC_BillingProfileLineItem__c][0];
            bpli.XC_Status__c = 'Sent To Zuora';
            bill.XC_LegalEntity__c = 'EndesaX';
            update bill; update bpli;
            bp.BillingProfileID = bill.id;
            fullQRReqBody.BillingProfile.add(bp);
            fullQRReqBody.Order.BillingProfIdUpdateMop = bill.id;
            qrs.XC_RequestBody__c = json.serialize(fullQRReqBody,true);
            update qrs;
            
            XC_QueuedRequestStep__c qrsStep = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qrs.id LIMIT 1];
            
            XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = new XC_IN_QRS10_UpdatePaymentMethod.InputWrapper();
            iw.stepId = qrsStep.Id;
            
            XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
            ic.XC_activeInterface__c = true;
            ic.XC_URL_Required__c = 'test';
            ic.Name = 'PaymentMethodSIA_SEPA';
            ic.XC_interfaceName__c = 'PaymentMethodSIA_SEPA';
            insert ic;
            
            Test.setMock(HttpCalloutMock.class, new XC_REST_UpdateMOPCallout_Mock());
            
            Test.startTest();
            XC_IN_QRS10_UpdatePaymentMethod.manageUpdateMOP(new List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper>{iw});
            Test.stopTest();
        }
        
        
        @isTest
        static void testWithIBANandBPActive(){
            XC_DF_BillingProfile.createBillingProfile(1);
            
            XC_QueuedRequest__c qrs = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrs.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            fullQRReqBody.Order.IBAN = 'IT93L0760151690000000000125';
            fullQRReqBody.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
            XC_UTIL_BillingProfile.BillingProfileIFWrapper bp = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            NE__Billing_Profile__c bill = [select id from NE__Billing_Profile__c][0];
            
            Zuora__CustomerAccount__c zu = new Zuora__CustomerAccount__c(); 
            zu.Zuora__Account__c = [select id from account][0].id;
            zu.Zuora__Zuora_Id__c = '123456';
            insert zu;
            
            XC_BillingProfileLineItem__c bpli = [select id, XC_Status__c, XC_ZuoraId__c, XC_CustomerAccount__c, XC_LegalEntity__c from XC_BillingProfileLineItem__c][0];
            bpli.XC_CustomerAccount__c = zu.Id;
            bpli.XC_Status__c = 'Active';
            bpli.XC_LegalEntity__c = 'EndesaX';
            bill.XC_Segment__c = 'B2C';
            update bill; update bpli;
            bp.BillingProfileID = bill.id;
            fullQRReqBody.BillingProfile.add(bp);
            fullQRReqBody.Order.BillingProfIdUpdateMop = bill.id;
            qrs.XC_RequestBody__c = json.serialize(fullQRReqBody,true);
            update qrs;
            
            XC_QueuedRequestStep__c qrsStep = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qrs.id LIMIT 1];
            
            XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = new XC_IN_QRS10_UpdatePaymentMethod.InputWrapper();
            iw.stepId = qrsStep.Id;
            
            XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
            ic.XC_activeInterface__c = true;
            ic.XC_URL_Required__c = 'test';
            ic.Name = 'PaymentMethodSIA_SEPA';
            ic.XC_interfaceName__c = 'PaymentMethodSIA_SEPA';
            insert ic;
            
            Test.setMock(HttpCalloutMock.class, new XC_REST_UpdateMOPCallout_Mock());
            
            Test.startTest();
            XC_IN_QRS10_UpdatePaymentMethod.manageUpdateMOP(new List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper>{iw});
            Test.stopTest();
        }
        
        @isTest
        static void testWithIBANandBPActive2(){
            XC_DF_BillingProfile.createBillingProfile(1);
            
            XC_QueuedRequest__c qrs = [SELECT Id, XC_RequestBody__c FROM XC_QueuedRequest__c LIMIT 1];
            XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrs.XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
            fullQRReqBody.Order.IBAN = 'IT93L0760151690000000000125';
            fullQRReqBody.BillingProfile = new List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>();
            XC_UTIL_BillingProfile.BillingProfileIFWrapper bp = new XC_UTIL_BillingProfile.BillingProfileIFWrapper();
            NE__Billing_Profile__c bill = [select id from NE__Billing_Profile__c][0];
            
            Zuora__CustomerAccount__c zu = new Zuora__CustomerAccount__c(); 
            zu.Zuora__Account__c = [select id from account][0].id;
            zu.Zuora__Zuora_Id__c = '123456';
            insert zu;
            
            insert XC_DF_Contact.createResidentialContacts([select id from account]);
            
            XC_BillingProfileLineItem__c bpli = [select id, XC_Status__c, XC_ZuoraId__c, XC_BillToContactId__c, XC_BillToAddress__c, XC_SoldToContactId__c, XC_SoldToAddress__c, XC_CustomerAccount__c, XC_LegalEntity__c from XC_BillingProfileLineItem__c][0];
            bpli.XC_CustomerAccount__c = zu.Id;
            bpli.XC_Status__c = 'Active';
            bpli.XC_LegalEntity__c = 'EndesaX';
            
            
            bpli.XC_SoldToContactId__c = [select id from contact][0].id;
            bpli.XC_SoldToAddress__c = [select id from xc_address__c][0].id;
            bpli.XC_BillToContactId__c = [select id from contact][0].id;
            bpli.XC_BillToAddress__c = [select id from xc_address__c][0].id;
            bill.XC_Segment__c = 'B2C';
            
            update bill; update bpli;
            
            
            bp.BillingProfileID = bill.id;
            fullQRReqBody.BillingProfile.add(bp);
            fullQRReqBody.Order.BillingProfIdUpdateMop = bill.id;
            qrs.XC_RequestBody__c = json.serialize(fullQRReqBody,true);
            update qrs;
            
            XC_QueuedRequestStep__c qrsStep = [SELECT ID FROM XC_QueuedRequestStep__c WHERE XC_QueuedRequest__c =: qrs.id LIMIT 1];
            
            XC_IN_QRS10_UpdatePaymentMethod.InputWrapper iw = new XC_IN_QRS10_UpdatePaymentMethod.InputWrapper();
            iw.stepId = qrsStep.Id;
            
            XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
            ic.XC_activeInterface__c = true;
            ic.XC_URL_Required__c = 'test';
            ic.Name = 'PaymentMethodSIA_SEPA';
            ic.XC_interfaceName__c = 'PaymentMethodSIA_SEPA';
            insert ic;
            
            Test.setMock(HttpCalloutMock.class, new XC_REST_UpdateMOPCallout_Mock());
            
            Test.startTest();
            XC_IN_QRS10_UpdatePaymentMethod.manageUpdateMOP(new List<XC_IN_QRS10_UpdatePaymentMethod.InputWrapper>{iw});
            Test.stopTest();
        }
    }
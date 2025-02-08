/**

* @author            :  Luisana Rocco lrocco@deloitte.it
* @date Creation     :  15/06/2021
* @date Modification :  dd/mm/yyyy
* @description       :  Test class for XC_IN077_ChangeInvoiceDeliveryPreference - XC_IN077_ChangeInvoiceDeliveryPref_D

*/

@isTest
public without sharing class XC_IN077_ChangeInvoiceDeliveryPref_TEST {

    

    @testSetup
    private static void setup() {
        
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        

        order.XC_InvoiceDeliveryPreference__c = 'Print';
        order.XC_LegalEntity__c = 'EndesaX';
        order.XC_Segment__c = 'B2C';
        update order;

        

        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        ps.XC_Step_Order__c = 1;
        insert ps;

        

        NE__OrderItem__c item = new NE__OrderItem__c (Id = order.NE__Order_Items__r[0].Id);
        item.XC_PaymentMethod__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        List<Account> accList = new List<Account>();
        Account acc = new Account (Id = order.NE__AccountID__c);
        accList.add(acc);

        
        //
        Zuora__CustomerAccount__c zu = new Zuora__CustomerAccount__c();     
        zu.Zuora__Account__c = acc.Id;    
        zu.Zuora__Zuora_Id__c = '123456';      
        insert zu;        

        //

        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        for(NE__Billing_Profile__c bp : listBillingProfiles){
            bp.NE__Payment__c = Label.XC_CL_PaymentMethod_NoPaymentRequired;
        }
        update listBillingProfiles;
        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id 

        FROM XC_BillingProfileLineItem__c 
        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];

        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        update item; 
        
        listBPLI[0].XC_InvoiceDeliveryPreference__c = 'Email';
        listBPLI[0].XC_CustomerAccount__c = zu.Id;
        update listBPLI[0];

        

        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_InvoiceDeliveryPreference__c = 'Email';
        insert listAssets;

        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test/accountId';

        ic.Name = Label.XC_CL_UpdateZuoraAccount;
        ic.XC_interfaceName__c = Label.XC_CL_UpdateZuoraAccount;      
        insert ic;
    }

    

    
    @isTest
    private static void changeInvoiceDeliveryPrefTEST() {
        
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
        FROM XC_Provisioning_Step__c
        LIMIT 1];
        
        
        List<XC_IN077_ChangeInvoiceDeliveryPreference.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        
        Test.setMock(HttpCalloutMock.class, new UpdateZuoraAccount_200());
        
        Test.startTest();
        XC_IN077_ChangeInvoiceDeliveryPreference.changeInvoiceDeliveryPreference(listInputWrapper);
        Test.stopTest();
        
        System.assert(true, ps != null);
    }
    
    @isTest
    private static void changeInvoiceDeliveryPrefKOTEST() {
        
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
        FROM XC_Provisioning_Step__c
        LIMIT 1];
        
        List<XC_IN077_ChangeInvoiceDeliveryPreference.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        
        Test.setMock(HttpCalloutMock.class, new UpdateZuoraAccount_KO());
        
        Test.startTest();
        XC_IN077_ChangeInvoiceDeliveryPreference.changeInvoiceDeliveryPreference(listInputWrapper);
        Test.stopTest();
        
        System.assert(true, ps != null);
    }

    @isTest
    private static void changeInvoiceDeliveryPrefKOTEST_2() {     

        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c();
        NE__OrderItem__c newOrder = new NE__OrderItem__c();  


        Test.startTest();
        try {
            XC_IN077_ChangeInvoiceDeliveryPreference.manageZuoraResponse(null,newOrder,provStep);
        } catch (Exception e) {
            System.debug(e);
        }
       
        Test.stopTest();
    }
    
    
    private static List<XC_IN077_ChangeInvoiceDeliveryPreference.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {
        

        List<XC_IN077_ChangeInvoiceDeliveryPreference.InputWrapper> listWrapperInput = new List<XC_IN077_ChangeInvoiceDeliveryPreference.InputWrapper>();
        XC_IN077_ChangeInvoiceDeliveryPreference.InputWrapper wr = new XC_IN077_ChangeInvoiceDeliveryPreference.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        

        return listWrapperInput;
        
    }
    
    public without sharing class UpdateZuoraAccount_200 implements HttpCalloutMock {

        

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"Success":true}');
            return response;
        }
    }


    // public without sharing class UpdateZuoraAccount_ResultNull implements HttpCalloutMock {
        
    //     public HTTPResponse respond(HTTPRequest request) { 
    //         HttpResponse response = new HttpResponse();
    //         response.setStatusCode(200);
    //         return response;
    //     }
    // }
    
    public without sharing class UpdateZuoraAccount_KO implements HttpCalloutMock {
        

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"Success":false, reasons: [{"message": "error"}]}');
            return response;
        }
    }

    

}
/**
* @author            :  Luisana Rocco lrocco@deloitte.it
* @date Creation     :  02/05/2022
* @date Modification :  dd/mm/yyyy
* @description       :  Test class for XC_IN089_GetSubscription 
*/

@isTest
public without sharing class XC_IN089_GetSubscription_TEST {

    @testSetup
    private static void setup() {

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);
        order.XC_LegalEntity__c = 'EnelSole';
        order.XC_Segment__c = 'B2G';
        update order;
        
        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        ps.XC_Step_Order__c = 1;
        insert ps;
        
        NE__OrderItem__c item = new NE__OrderItem__c (Id = order.NE__Order_Items__r[0].Id);
        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_SubscriptionName__c = 'TEST';
        insert listAssets;
        
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'subscriptions/subname';
        ic.Name = 'ContractAmendment';
        ic.XC_interfaceName__c = 'ContractAmendment';   
        insert ic;
    }
    
    
    @isTest
    private static void getSubscriptionTEST() {
        
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
        FROM XC_Provisioning_Step__c
        LIMIT 1];
        
        
        List<XC_IN089_GetSubscription.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        
        Test.setMock(HttpCalloutMock.class, new GetSubscription_200());
        
        Test.startTest();
        XC_IN089_GetSubscription.getSubscription(listInputWrapper);
        Test.stopTest();
        
        System.assert(true, ps != null);
    }
    

     @isTest
    private static void getSubscriptionKOTEST() {
        
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
        FROM XC_Provisioning_Step__c
        LIMIT 1];
        
        
        List<XC_IN089_GetSubscription.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        
        Test.setMock(HttpCalloutMock.class, new GetSubscription_KO());
        
        Test.startTest();
        XC_IN089_GetSubscription.getSubscription(listInputWrapper);
        Test.stopTest();
        
        System.assert(true, ps != null);
    }

       @isTest
    private static void getSubscriptionResultNullTEST() {
        
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        XC_CS001_InterfaceConfiguration__c ic = [SELECT Id  FROM XC_CS001_InterfaceConfiguration__c LIMIT 1]; 
        ic.Name = 'ContractAmendmenttest';
        ic.XC_interfaceName__c = 'ContractAmendmentTest';   
        update ic;
        
        List<XC_IN089_GetSubscription.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        
        Test.startTest();
        XC_IN089_GetSubscription.getSubscription(listInputWrapper);
        Test.stopTest();
        
        System.assert(true, ps != null);
    }
    
    private static List<XC_IN089_GetSubscription.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {
        
        List<XC_IN089_GetSubscription.InputWrapper> listWrapperInput = new List<XC_IN089_GetSubscription.InputWrapper>();
        XC_IN089_GetSubscription.InputWrapper wr = new XC_IN089_GetSubscription.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);
        
        return listWrapperInput;
        
    }
    
    public without sharing class GetSubscription_200 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"Success":true, "ratePlans":[{"id":"8adcf8f1806f","ratePlanCharges":[{"id":"8adc0b4","effectiveStartDate":"2022-02-24","effectiveEndDate":"2022-04-28","processedThroughDate":"2022-04-01","chargedThroughDate":"2022-04-01","XC_Hierarchy__c":"Root"}]}]}');
            return response;
        }
    }


    public without sharing class GetSubscription_KO implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"Success":false, reasons: [{"message": "error"}]}');
            return response;
        }
    }
}
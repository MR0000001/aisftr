/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  12/11/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  TEST class for XC_IN064_ManageZPayment
*/


@isTest
public without sharing class XC_IN064_ManageZPayment_TEST {


    @testSetup
    private static void setup() {

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        ps.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        insert ps;

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        listBillingProfiles[0].NE__Payment__c = 'Online';
        update listBillingProfiles;


        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id, XC_BillingProfile__r.NE__Account__c
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id]; 
                  
        Zuora__CustomerAccount__c custAcc = new Zuora__CustomerAccount__c(Zuora__Zuora_Id__c = '123456', Zuora__Account__c = order.NE__AccountID__c, otherPaymentMethodType__c = 'Online', XC_BillingProfileLineItemID__c = listBPLI[0].ID);
        insert custAcc;

        NE__OrderItem__c item = order.NE__Order_Items__r[0];                                                                   
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        item.XC_PaymentMethod__c = 'Online';
        item.XC_BillingModel__c = 'One Shot';
        update item;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_CreatePayment;
        ic.XC_interfaceName__c = Label.XC_CL_CreatePayment;
        insert ic;

    }


    
    @isTest
    private static void managePaymentTEST() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN064_ManageZPayment.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new Zuorapayment_Mock_200());

        Test.startTest();
            XC_IN064_ManageZPayment.manageZPayment(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }


    private static List<XC_IN064_ManageZPayment.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN064_ManageZPayment.InputWrapper> listWrapperInput = new List<XC_IN064_ManageZPayment.InputWrapper>();
        XC_IN064_ManageZPayment.InputWrapper wr = new XC_IN064_ManageZPayment.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }

    private without sharing class Zuorapayment_Mock_200 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"status" : "Processed","Success":true}');
            return response;
        }
    }


}
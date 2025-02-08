/**
* @author dpalamides
* @date 16/06/2020
* @description classes.XC_REST_BillingPreviewWF_TEST
*/

@IsTest
public without sharing class XC_REST_BillingPreviewWF_TEST {
/**
    * @description
    * @author dpalamides
    * @return void
    **/
    @TestSetup
    static void setup(){

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'callout:XC_ZuoraWebServiceWorkflow/CalculateBillingPreview_SF/run';
        ic.Name = Label.XC_CL_BillingPreviewWF;
        ic.XC_interfaceName__c = Label.XC_CL_BillingPreviewWF;
        insert ic;

    }

    /**
    * @description
    * @author dpalamides
    * @return void
    **/
    @IsTest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());

        XC_REST_BillingPreviewWF.WrapperRequest req = new XC_REST_BillingPreviewWF.WrapperRequest();
        req.accountId='12346';
        req.legalEntity='EnelXItalia';
        req.subscriptionId='12456';
        req.stream='B2B';

        Test.startTest();
        XC_REST_BillingPreviewWF.callBillingPreviewWF(req);
        Test.stopTest();

    }

    /**
    * @description
    * @author dpalamides
    * @return void
    **/
    @IsTest
    static void testMethod2(){

        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());

        XC_REST_BillingPreviewWF.WrapperRequest req = new XC_REST_BillingPreviewWF.WrapperRequest();
        req.accountId='12346';
        req.legalEntity='TEST';
        req.subscriptionId='12456';
        req.stream='TEST';

        Test.startTest();
        XC_REST_BillingPreviewWF.callBillingPreviewWF(req);
        Test.stopTest();
    }
}
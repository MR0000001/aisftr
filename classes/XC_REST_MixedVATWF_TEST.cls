/**
 * @File Name          : XC_REST_MixedVATWF_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 21/4/2020, 11:44:57
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@IsTest
public class XC_REST_MixedVATWF_TEST {

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 21/4/2020 
    * @return void 
    **/
    @TestSetup
    static void setup(){

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'callout:XC_ZuoraWebServiceWorkflow/MixedVATSubscription/run';
        ic.Name = Label.XC_CL_MixedVATWF;
        ic.XC_interfaceName__c = Label.XC_CL_MixedVATWF;
        insert ic;
        
    }

    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 21/4/2020 
    * @return void 
    **/
    @IsTest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());

        XC_REST_MixedVATWF.WrapperRequest req = new XC_REST_MixedVATWF.WrapperRequest();
        req.accountId='12346';
        req.legalEntity='EnelXItalia';
        req.subscriptionId='12456';
        req.stream='B2C';

        Test.startTest();
            XC_REST_MixedVATWF.callMixedVATWF(req);
        Test.stopTest();

    }

    @IsTest
    static void testMethod2(){
        
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());

        XC_REST_MixedVATWF.WrapperRequest req = new XC_REST_MixedVATWF.WrapperRequest();
        req.accountId='12346';
        req.legalEntity='TEST';
        req.subscriptionId='12456';
        req.stream='TEST';

        Test.startTest();
            XC_REST_MixedVATWF.callMixedVATWF(req);
        Test.stopTest();
    }

}
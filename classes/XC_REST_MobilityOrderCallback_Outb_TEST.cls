/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  06/06/2019 
* @description XC_REST_MobilityOrderCallback_Outb_TEST – Test class for XC_REST_MobilityOrderCallback_Outbound
*/
@isTest
public class XC_REST_MobilityOrderCallback_Outb_TEST {

    @testSetup
    private static void setup() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_MobilityOrderCallback;
        ic.XC_interfaceName__c = Label.XC_CL_MobilityOrderCallback;
        insert ic;

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
       
        List<Account> listAcc = [SELECT Id FROM Account];

        List<Asset> a = XC_DF_Asset.createAssets(listAcc);
        insert a;
    }

    //Test Method callToMobility
    @isTest
    private static void callToMobilityActive(){
        XC_REST_MobilityOrderCallback_U.RequestWrapper wr = new XC_REST_MobilityOrderCallback_U.RequestWrapper();        

        Test.setMock(HttpCalloutMock.class, new XC_REST_MobilityOrderCallback_Mock());
        Test.startTest();
            XC_REST_MobilityOrderCallback_U.ResponseWrapper rw = XC_REST_MobilityOrderCallback_Outbound.callToMobility(wr,'test');
            System.assert(rw!=null);
        Test.stopTest();
        
    }
    
    @isTest
    private static void callToMobilityActive2(){
        
        NE__Order__c order = [SELECT Id FROM NE__Order__c LIMIT 1];

        XC_REST_MobilityOrderCallback_U.RequestWrapper wr = new XC_REST_MobilityOrderCallback_U.RequestWrapper();        
        wr.orderId = order.Id;

        Test.setMock(HttpCalloutMock.class, new XC_REST_MobilityOrderCallback_Mock());
        Test.startTest();
            XC_REST_MobilityOrderCallback_U.ResponseWrapper rw = XC_REST_MobilityOrderCallback_Outbound.callToMobility(wr,'test');
            System.assert(rw!=null);
        Test.stopTest();
        
    }
    
    //Test Method callToMobility
    static testMethod void callToMobilityInActive(){
        
        XC_REST_MobilityOrderCallback_U.RequestWrapper wr = new XC_REST_MobilityOrderCallback_U.RequestWrapper();
		wr.ZSubscriptionId = '5612531274317';
        wr.emobTransactionId = '213143242';
        
        Test.startTest();
            XC_REST_MobilityOrderCallback_Outbound.callToEMobilityCallback(wr,'test', 'oljnv');
            System.assert(wr!=null);
        Test.stopTest();
        
    }
    
    //Test Method generateTokenEMobility
    @isTest
    private static void generateTokenEMobility(){
        XC_CS006_eMobilityCredentials__c emCred = new XC_CS006_eMobilityCredentials__c();
        emCred.XC_ClientId__c = '1141313';
        emCred.XC_ClientSecret__c = 'oifwjf432ijroeijrew';
        emCred.XC_Email__c = 'test@email.com';
        emCred.XC_Password__c = '1141665313';
        emCred.XC_ServerURL__c = 'testServer';
        emCred.XC_Country__c = 'SPAIN';
        insert emCred;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_MobilityOrderCallback_Mock());
        Test.startTest();
            String rw = XC_REST_MobilityOrderCallback_Outbound.generateTokenEMobility('test');
            System.assert(rw!=null);
        Test.stopTest();
    }

    /*@isTest
    private static void EmobilityTokenQueueableTest(){        
        
        XC_REST_MobilityOrderCallback_U.RequestWrapper wrRequest = new XC_REST_MobilityOrderCallback_U.RequestWrapper();
        String endpointCallback = 'http://url.com';

        NE__Order__c order = [SELECT Id FROM NE__Order__c LIMIT 1];
        //delete order;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_MobilityOrderCallback_Mock());
        Test.startTest();
            XC_REST_MobilityOrderCallback_Outbound.callToMobility(wrRequest, endpointCallback);
        Test.stopTest();
    }*/
}
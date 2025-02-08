/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  04/06/2019 
* @description XC_REST_Rethinking_TEST – Test class for XC_REST_Rethinking
*/
@isTest
public with sharing class XC_REST_Rethinking_TEST {

    /*
	*@ Description manage active interface without legal entity
	*/
     static testMethod void manageRethinkingActive(){ 

        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Rethinking;
        ic.XC_interfaceName__c = Label.XC_CL_Rethinking;
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='test';
        zws.apiToken__c='11111';
        insert zws; 

        String subscriptionId ='111111';
        String entityName ='test';
        String stream ='test';

        Test.startTest();
        XC_REST_Rethinking.WrapperResponse result;
        try {
            result  =XC_REST_Rethinking.manageRethinking(subscriptionId, entityName, stream);
            System.assert(result!=null, 'Wrong assert equals');
        } catch(exception e){
            XC_UTIL_Debug.debug(true,'testKO');
        } 
        Test.stopTest();
    } 


    /*
	*@ Description manage active interface with legal entity and status code 200
	*/
    static testMethod void manageRethinkingActive2(){

        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Rethinking;
        ic.XC_interfaceName__c = Label.XC_CL_Rethinking;
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='test';
        zws.apiToken__c='11111';
        insert zws; 
        String subscriptionId ='111111';
        String entityName ='EndesaX';
        String stream = 'B2C';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallRethinking_Mock());
        XC_REST_Rethinking.WrapperResponse result;
        try {
            result  =XC_REST_Rethinking.manageRethinking(subscriptionId,entityName,stream);
            System.assert(result!=null, 'Wrong assert');
        } catch(exception e){
            XC_UTIL_Debug.debug(true,'testOK');
        } 
        Test.stopTest();
    } 


    /*
	*@ Description manage active interface with status code 0
	*/
    static testMethod void manageRethinkingActive3(){

        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test2';
        ic.Name = Label.XC_CL_Rethinking;
        ic.XC_interfaceName__c = Label.XC_CL_Rethinking;
        insert ic;
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c ='test';
        zws.apiToken__c='11111';
        insert zws; 

        String subscriptionId ='111111';
        String entityName ='EndesaX';
        String stream ='B2C';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallRethinking_Mock());
        XC_REST_Rethinking.WrapperResponse result;
        try {
            result  =XC_REST_Rethinking.manageRethinking(subscriptionId,entityName,stream);
            System.assert(result!=null, 'Wrong assert');
        } catch(exception e){
            XC_UTIL_Debug.debug(true,'testOK');
        } 
        Test.stopTest();
    } 

    
    /*
	*@ Description manage inactive interface
	*/
    static testMethod void manageRethinkingInActive(){

        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Rethinking;
        ic.XC_interfaceName__c = Label.XC_CL_Rethinking;
        insert ic;

        String subscriptionId ='111111';
        String entityName ='test';
        String stream ='test';
        
        Test.startTest(); 
        XC_REST_Rethinking.WrapperResponse result =XC_REST_Rethinking.manageRethinking(subscriptionId,entityName,stream);
            System.assert(result!=null, 'Wrong assert');
        Test.stopTest();
    } 


    /*
	*@ Description mock class to call rethinking
	*/
    public without sharing class CallRethinking_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().endsWith('test')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Id":"a0001", "Name":"A01807438", "reasons":null}');
                response.setStatusCode(200); 
            } else if(req.getEndpoint().endsWith('test2')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"Id":"a0001", "Name":"A01807438", "reasons":null}');
                response.setStatusCode(0); 
            } 
            return response;
        }
    }
}
/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  16/06/2021
 * @date Modification :  dd/mm/yyyy
 * @description       :  Test class for XC_REST_UpdateZuoraAccount 
*/

@isTest
public without sharing class XC_REST_UpdateZuoraAccount_TEST {

    @TestSetup
    static void testSetup(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;  
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_UpdateZuoraAccount;
        ic.XC_interfaceName__c = Label.XC_CL_UpdateZuoraAccount;      
        insert ic;
    }
    

    static testMethod void updateZuoraAccountActive(){

        Map<String,Object> bodyMap = new Map<String,Object>();
       
        bodyMap.put('legalEntity', 'EndesaX');
        bodyMap.put('stream', 'B2C');
        bodyMap.put('zuoraAccountId', 'test');

        Test.setMock(HttpCalloutMock.class, new UpdateZuoraAccount_200());
        Test.startTest(); 
        ZuoraWebService.CreateZuoraAccountResponse result = XC_REST_UpdateZuoraAccount.updateZuoraAccount(bodyMap);
        System.assert(result!=null);    
        Test.stopTest();
    } 


    static testMethod void updateZuoraAccountnotActive(){
        
        XC_CS001_InterfaceConfiguration__c ci = [SELECT id FROM XC_CS001_InterfaceConfiguration__c WHERE Name =: Label.XC_CL_UpdateZuoraAccount];
        ci.XC_activeInterface__c = false; 
        update ci;

        Map<String,Object> bodyMap = new Map<String,Object>();
        bodyMap.put('legalEntity', 'EndesaX');
        bodyMap.put('stream', 'B2C');
        bodyMap.put('zuoraAccountId', 'test');

        Test.setMock(HttpCalloutMock.class, new UpdateZuoraAccount_200());
        Test.startTest(); 
        ZuoraWebService.CreateZuoraAccountResponse result = XC_REST_UpdateZuoraAccount.updateZuoraAccount(bodyMap);
        System.assert(result!=null);    
        Test.stopTest();
    } 


   
    static testMethod void updateZuoraAccountWrongEntityName(){

        Map<String,Object> bodyMap = new Map<String,Object>();
        bodyMap.put('legalEntity', 'test');
        bodyMap.put('stream', 'B2C');
        bodyMap.put('zuoraAccountId', 'test');

        Test.setMock(HttpCalloutMock.class, new UpdateZuoraAccount_200());
        Test.startTest(); 
        ZuoraWebService.CreateZuoraAccountResponse result = XC_REST_UpdateZuoraAccount.updateZuoraAccount(bodyMap);
        System.assert(result!=null);    
        Test.stopTest();
    } 

    static testMethod void updateZuoraAccountStatusCode(){

        Map<String,Object> bodyMap = new Map<String,Object>();
        bodyMap.put('legalEntity', 'EndesaX');
        bodyMap.put('stream', 'B2C');
        bodyMap.put('zuoraAccountId', 'test');

        Test.setMock(HttpCalloutMock.class, new UpdateZuoraAccount_400());
        Test.startTest(); 
        ZuoraWebService.CreateZuoraAccountResponse result = XC_REST_UpdateZuoraAccount.updateZuoraAccount(bodyMap);
        System.assert(result!=null);    
        Test.stopTest();
    } 




    
    public without sharing class UpdateZuoraAccount_200 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"results":[{"Success":true}]}');
            return response;
        }
    }

     public without sharing class UpdateZuoraAccount_400 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"results":[{"Success":false}]}');
            return response;
        }
    }


}
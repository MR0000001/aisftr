/*****************************************************************************************************************
* @author :          : Simone Trenta - 
* @date Creation 	 : 26/07/2019
* @date Modification : 
* @description :     : XC_REST_CreateDocument - 
******************************************************************************************************************/
@isTest
public class XC_REST_CreateDocument_TEST {

    @isTest
    public static void sendRequesInactive(){
        test.startTest();
        XC_REST_CreateDocument.sendRequest('fileName', 'docId');
        test.stopTest();
    }
    
    @isTest
    public static void sendRequesActive(){
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'CreateDocument';
        ic.XC_interfaceName__c = 'CreateDocument';
        insert ic;
        
        test.startTest();
        XC_REST_CreateDocument.sendRequest('fileName', 'docId');
        test.stopTest();
    }
    
    @isTest
    public static void sendRequesActive1(){
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'CreateDocument';
        ic.XC_interfaceName__c = 'CreateDocument';
        insert ic;
        
        document d = new document();
        d.FolderId = [select id from folder where name = 'Public Folder'][0].id;
        d.name = 'test';
        d.body = blob.valueOf('ljdsadsajds dsakjdsjk');
        insert d;
        
        test.startTest();
        XC_REST_CreateDocument.sendRequest('fileName', d.id);
        test.stopTest();
    }
    
}
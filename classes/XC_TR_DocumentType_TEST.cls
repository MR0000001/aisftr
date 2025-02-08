/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com 
* @date Creation 10/03/2021
* @date Modification 
* @description XC_TR_DocumentType_U_CreateSRSkills_TEST – Test class for XC_TR_DocumentType_U_CreateSRSkills
*/  
@isTest
public class XC_TR_DocumentType_TEST {
    static testMethod void onInsert(){
        Test.startTest();
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = 'SF_PES_QUALIFICATION';
        insert documentType;
        Test.stopTest();
    }
    
    static testMethod void onUpdate(){
        Test.startTest();
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = 'SF_PES_QUALIFICATION';
        insert documentType;
        documentType.XC_ExpirationDate__c = System.Today();
        update documentType;
        Test.stopTest();
    } 
    
  	static testMethod void onDelete(){
        Test.startTest();
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = 'SF_PES_QUALIFICATION';
        insert documentType;
        delete documentType;
        Test.stopTest();
    } 
}
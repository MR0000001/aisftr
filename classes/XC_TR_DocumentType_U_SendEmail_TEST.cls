/*
* @author Giuseppe Di Bonito gdibonito@deloitte.it
* @date Creation 14/05/2020
* @description Test Class for XC_TR_DocumentType_U_SendEmail 
*/

@isTest
public without sharing class XC_TR_DocumentType_U_SendEmail_TEST {
    
    @isTest static void checkCieDoc(){
        Test.startTest();
        
        
        List<Opportunity> opplist = XC_DF_Opportunity.createOpportunity(1, false);
        insert opplist;
		NE__Order__c o = XC_DF_Order.createOrder('InOrder');
        o.NE__OptyId__c = opplist[0].id;
        update o;
        XC_DocumentType__c documentType = new XC_DocumentType__c();
        documentType.Category__c = 'SF_CREDIT_ASSIGNMENT_TO_SIGN';
        documentType.XC_DoxeeUrl__c = 'Url doxee';
        documentType.XC_Configuration__c = o.id;
        documentType.numberOfFiles__c = 1;
        insert documentType;
        
        XC_DocumentSignature__c ds = new XC_DocumentSignature__c();
        ds.XC_DossierId__c = 'NMT';
        insert ds;
        
        XC_DocumentSignatureItem__c dsi = new XC_DocumentSignatureItem__c();
        dsi.XC_DocumentSignature__c = ds.id;
        insert dsi;
        
        XC_DocumentType__c documentType2 = new XC_DocumentType__c();
        documentType2.Category__c = 'SF_CREDIT_ASSIGNMENT_SIGNED';
        documentType2.XC_DoxeeUrl__c = 'Url doxee';
        documentType2.numberOfFiles__c = 1;
        documentType2.XC_DossierId__c = 'NMT';
        documentType2.XC_Configuration__c = o.id;
        insert documentType2;
        
        System.assert(documentType!= null, documentType);
        Test.stopTest();   
    }
}
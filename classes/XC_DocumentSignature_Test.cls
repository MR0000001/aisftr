/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  02/04/2020 
* @description XC_DocumentSignature_Test – Test class for XC_DocumentSignature
*/
@isTest
public with sharing class XC_DocumentSignature_Test {
    public static testMethod void getDocumentSignatures(){
        NE__Order__c o=XC_DF_Order.createOrder('opty');   
        XC_DocumentSignature__c docSign=new XC_DocumentSignature__c();
        docSign.XC_Order__c=o.id;
        docSign.XC_SignerId__c=o.id;
        docSign.XC_Status__c='test';
        docSign.XC_Step__c='3';
        docSign.XC_DossierId__c='112';
        insert docSign;
      test.startTest();
        XC_DocumentSignature__c[] arrDocSign=XC_DocumentSignature.getDocumentSignatures(o.id);
        test.stopTest();
    }
    
    @isTest
    public static void getInitInformation(){
        XC_DF_OneOrg.createOneOrg('Spain');
    	NE__Order__c order = XC_DF_Order.createOrder('opty');
      	test.startTest();
        	XC_UTIL_ResultWrapper rw =XC_DocumentSignature.getInitInformation(order.id);
        	System.assert(rw.success);
        test.stopTest();
    }
}
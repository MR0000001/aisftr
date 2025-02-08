/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  15/05/2019 
* @description XC_LCC009_DocumentSignBuilder_TEST – Test class for XC_LCC009_DocumentSignBuilder
*/ 
@isTest
public with sharing class XC_LCC009_DocumentSignBuilder_TEST {
    //Test Method uploadSignature
    static testMethod void uploadSignature(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> c = XC_DF_Contact.createCondominiumContacts(1);
        insert c;
        String contactId  = c[0].Id;
        
        
        ContentVersion cv = new ContentVersion();
        cv.title='Test title';
        cv.VersionData=blob.valueof('New Bitmap Image.bmp'); 
        cv.PathOnClient = 'TEST';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        cv.VersionData=bodyBlob;    
        insert cv; 
        String b64SignData = String.valueOf( cv.VersionData) ;
        String result = XC_LCC009_DocumentSignBuilder.uploadSignature(contactId,b64SignData);  
        System.assert(String.isNotBlank(result));
        Test.stopTest();
    }
    
    //Test Method uploadSignature2
    static testMethod void uploadSignature2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> c = XC_DF_Contact.createCondominiumContacts(1);
        insert c;
        String contactId  = c[0].Id;
        ContentVersion cv = new ContentVersion();
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        String str = EncodingUtil.base64Encode(bodyBlob);
        String result = XC_LCC009_DocumentSignBuilder.uploadSignature(contactId, str);
        System.assertEquals('',result);
        Test.stopTest();
    }
}
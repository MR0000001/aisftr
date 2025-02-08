/**
* @author Emanuela Cacace  ecacace@deloitte.it 
* @date Creation  27/05/2019 
* @description XC_TR_ContentDocumentLink_U_Visibi_TEST – Test class for XC_TR_ContentDocumentLink_U_Visibility
*/ 
@isTest
public with sharing class XC_TR_ContentDocumentLink_U_Visibi_TEST {
 // Test method for setVisibiltyOnContentDocumentLink 
     static testMethod void setVisibiltyOnContentDocumentLink(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            account c = new account();
            c.PrimaryEmail__c = 'asd@asfdgdfgdasdd.it';
            c.name = 'test';
            insert c;
            ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

    
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = c.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            System.assert (cdl!=null); 
        Test.stopTest();

        
    }
}
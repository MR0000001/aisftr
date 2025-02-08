/**
* @author 
* @date Creation  
* @description XC_TR_ContentDocumentLink_U_CDoxee_TEST – Test class for XC_TR_ContentDocumentLink_U_CallDoxee
*/ 
@isTest
private with sharing class XC_TR_ContentDocumentLink_U_CDoxee_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestVersion',
            PathOnClient = 'test1.jpg - test2.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            XC_Category__c='Test',
            Description='Test'
        );
        insert contentVersion;
    }

    static testMethod void onInsertWithLinkedEntityIdAccount() {

        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        Test.startTest();
        List<Account> acct = XC_DF_Account.createResidentialAccounts(2);
        insert acct;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        User user = XC_DF_User.createUserAdmin();
        insert user;
        contentDocumentLink.LinkedEntityId = user.id;
        contentDocumentLink.ContentDocumentId=documents[0].id;
        contentDocumentLink.ShareType='V';
        ContentDocumentLink contentDocumentLink2 = new ContentDocumentLink();
        contentDocumentLink2.LinkedEntityId = acct[0].id;
        contentDocumentLink2.ContentDocumentId=documents[0].id;
        contentDocumentLink2.ShareType='V';
        listContentDocumentLink.add(contentDocumentLink);
        listContentDocumentLink.add(contentDocumentLink2);

        insert listContentDocumentLink;

        Test.stopTest();
		System.assertEquals(2, Limits.getDmlStatements());
        
    }
    
    static testMethod void onInsertWithLinkedEntityIdOrder() {
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        Test.startTest();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        User user = XC_DF_User.createUserAdmin();
        insert user;
        contentDocumentLink.LinkedEntityId = order.id;
        contentDocumentLink.ContentDocumentId=documents[0].id;
        contentDocumentLink.ShareType='V';
        ContentDocumentLink contentDocumentLink2 = new ContentDocumentLink();
        contentDocumentLink2.LinkedEntityId = user.id;
        contentDocumentLink2.ContentDocumentId=documents[0].id;
        contentDocumentLink2.ShareType='V';
        listContentDocumentLink.add(contentDocumentLink);
        listContentDocumentLink.add(contentDocumentLink2);

        insert listContentDocumentLink;
        Test.stopTest();
        System.assertEquals(2,  Limits.getDmlStatements());
    }
}
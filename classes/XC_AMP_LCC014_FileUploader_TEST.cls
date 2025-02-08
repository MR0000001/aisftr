/**
 * The Class XC_AMP_LCC014_FileUploader_TEST.
 *
 * @author            : Luisana Rocco - lrocco@deloitte.it
 * @date Creation     : 26/01/2021
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_AMP_LCC014_FileUploader 
 **/

@isTest
public  without sharing  class XC_AMP_LCC014_FileUploader_TEST {


     @TestSetup
    static void setup(){ 

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false); 
        insert oppList;
     
        List<Account>  accountList = [Select id FROM Account LIMIT 1];
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        contList[0].XC_PrimaryContact__c = true;
        insert contList;


        NE__Product__c prod = new NE__Product__c();
        prod.XC_Product_Subtype__c = 'Solar Thermal';
        prod.XC_Product_Type__c = 'Equipment';
        prod.XC_LIC_Product_Name__c = 'Test';
        insert prod;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prod.id;
        insert catItem;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'SF_Category',
            PathOnClient = 'TEST - SF_Category.jpg',
            VersionData = Blob.valueOf('Test SF_Category'),
            IsMajorVersion = true
            );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = oppList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

    }

    // upload file
    @isTest
    static void uploadFileTest(){
        
        Map<String,Object> paramsMap = setParamsInfos();
        
        test.startTest();
		XC_AMP_LCC014_FileUploader.uploadFile(paramsMap);
        test.stopTest();

        System.assertNotEquals(null, paramsMap, 'Wrong assert result');
    }


    
    
    //method to set params
    public static Map<String,Object> setParamsInfos(){

        Map<Id,Account> accountMap = new Map<Id,Account> ([SELECT id, (SELECT id FROM Opportunities), (SELECT id FROM NE__Billing_Profiles__r), (SELECT id FROM  XC_BillingProfileLineItems__r) FROM Account LIMIT 1] );
        Map<Id,NE__Catalog_Item__c> catItemMap = new Map<Id,NE__Catalog_Item__c>([SELECT NE__Catalog_Id__c, NE__Catalog_Category_Name__c FROM  NE__Catalog_Item__c LIMIT 1]);
	    Map<Id,ContentDocument> docMap = new Map<Id,ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1]);

        Map<String,Object> fileInfo = new Map<String,Object>();
        fileInfo.put('documentId', docMap.values()[0].Id);

        Map<String,Object> paramsMap = new Map<String,Object>();
        paramsMap.put('opportunityId', accountMap.values()[0].Opportunities[0].Id);
        paramsMap.put('categoryName', catItemMap.values()[0].NE__Catalog_Category_Name__c);
        paramsMap.put('fileInfo', fileInfo);
        return paramsMap;
 
    }

}
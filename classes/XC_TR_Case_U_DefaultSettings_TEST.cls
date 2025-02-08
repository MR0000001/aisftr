/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation  15/05/2019 
* @description XC_TR_Case_U_DefaultSettings_TEST – Test class for XC_TR_Case_U_DefaultSettings
*/
@isTest
public class XC_TR_Case_U_DefaultSettings_TEST {
    
    @TestSetup
    static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
    }

    @isTest
    static void createCase(){
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].Reason = 'XCMOT011';
        caseList[0].SubCause__c = 'ATCL010';
        caseList[0].XC_Segment__c = 'B2C';
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].Origin = 'CAN001';
        Test.startTest();
        	insert caseList;
        	System.assert(true);
        Test.stopTest();
    }
    
    
    @isTest
    static void updateCase(){
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, false);
        insert opp;

        List<NE__Bundle__c> blist = XC_DF_NE_Bundle.createBundleRecords(1);
        insert blist;
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Disconnection';
        order.NE__OptyId__c = opp[0].Id;
        order.XC_Subtype__c = Label.XC_CL_Configuration_SubtypeClaimServiceUsed ;
        order.NE__AccountId__c = opp[0].AccountId;
        order.XC_InstallationAddress__c = opp[0].XC_Address__c;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order); 
        item.XC_Installation_Address__c = order.XC_InstallationAddress__c;
        item.NE__Account__c = order.NE__AccountId__c;
        insert item;

        Asset assetToInsert = new Asset();
        assetToInsert.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetToInsert.Name = 'Baxi Neodens Plus 24_24 F Eco';
        assetToInsert.IsCompetitorProduct = true;
        assetToInsert.InstallDate = Date.newInstance(2019, 04, 13);
        assetToInsert.IsInternal = false;
        assetToInsert.Price = 104;
        assetToInsert.AccountId =opp[0].AccountId;
        assetToInsert.PurchaseDate = Date.newInstance(2019, 04, 05);
        assetToInsert.Quantity = 3;
        assetToInsert.NE__Order_Config__c = order.id;
        assetToInsert.XC_Configuration_Item__c= item.id;
        assetToInsert.NE__Bundle__c = blist[0].id;
        assetToInsert.NE__Status__c = 'Active';
        assetToInsert.UsageEndDate = Date.newInstance(2020, 12, 30);
        assetToInsert.NE__Commitment__c = false;
        assetToInsert.ContactId = opp[0].XC_Contact__c;
        assetToInsert.XC_ActivationDate__c = Date.today();
        insert assetToInsert;
        System.debug('Asset Inserted : '+ assetToInsert.ContactId);
        System.debug('Contact Id of the case : '+opp[0].XC_Contact__c);
        Case c = new Case();
        
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT009';
        c.SubCause__c = 'ATCL015';
        insert c;
        
        Test.startTest();
        	c.AssetId = assetToInsert.id;
        	update c;
        	System.assert(true);
        Test.stopTest();
    }

    @isTest
    private static void caseCreator_TEST() {
        List<Case> testCase = XC_DF_Case.createCases(1);
        String casesDescription = 'Testing creator profile name';
        for(Case c: testCase){
            c.SubCause__c = '';
            c.XC_description__c = casesDescription;
        }
        Test.startTest();
        insert testCase;
        Test.stopTest();

        String expectedName = [SELECT NAME FROM PROFILE WHERE ID = :UserInfo.getProfileId()].Name;
        List<Case> casesRetrieved = [SELECT XC_CreatorProfile__c FROM CASE WHERE XC_description__c = :casesDescription];
        System.debug('Expected: '+ expectedName);
        for(Case c : casesRetrieved){
            System.debug('Testing name: ' + c.XC_CreatorProfile__c);
        }
        System.assertNotEquals(casesRetrieved.size(), 0);
        System.assertEquals(casesRetrieved.size(), testCase.size());
        for(Case c : casesRetrieved){
            System.assertEquals(c.XC_CreatorProfile__c, expectedName);
        }
    }
}
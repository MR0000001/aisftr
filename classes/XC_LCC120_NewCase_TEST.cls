/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com   Valeria Martino - valeria.martino@nttdata.com
* @date Creation 21/06/2019 
* @description XC_LCC120_NewCase_TEST – Test class for XC_LCC120_NewCase
*/

@isTest
public with sharing class XC_LCC120_NewCase_TEST {

    @isTest
    static void onCaseReasonMapping_B2C() {
        Test.startTest();
        List<Contact> ctList = XC_DF_Contact.createResidentialContacts(1);
        ctList[0].XC_Segment__c = 'B2C';
        insert ctlist;  
        XC_LCC120_NewCase.getCaseRecordType('XCMOT09', 'B2C', ctlist[0].Id);
        List<Case> cases= XC_DF_Case.createCases(1); 
        cases[0].Status = 'ESTA001';
        cases[0].XC_LegalEntity__c = 'EnelXItalia';
        cases[0].XC_Segment__c = 'B2C';
        insert cases;
        XC_LCC120_NewCase.getCaseRecordType('XCMOT010', 'B2C', ctlist[0].Id);
        XC_LCC120_NewCase.getRelatedAccountId(ctlist[0].Id);
        Test.stopTest();  
    }
    
    @isTest
    static void onCaseReasonMapping_B2B() {
        Test.startTest();
        List<Contact> ctList = XC_DF_Contact.createResidentialContacts(1);
        ctList[0].XC_CountryLegalEntity__c = 'Italy';
        ctList[0].XC_MainLegalEntity__c = 'EnelXItalia';
        ctList[0].XC_Segment__c = 'B2B';
        insert ctlist;  
        ctList[0].XC_Segment__c = 'B2B';
        update ctlist;  
       // XC_LCC120_NewCase.getCaseRecordType('XCMOT09', 'B2B', ctList[0].Id);
        List<Case> cases= XC_DF_Case.createCases(1); 
        cases[0].Status = 'ESTA001';
        cases[0].XC_LegalEntity__c = 'EnelXItalia';
        cases[0].XC_Segment__c = 'B2B';
        insert cases;
       // XC_LCC120_NewCase.getCaseRecordType('XCMOT010', 'B2B', ctlist[0].Id);
        XC_LCC120_NewCase.getRelatedAccountId(ctlist[0].Id);
        Test.stopTest();  
    } 

    @isTest
    static void createB2BCase() {
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        accList[0].Name = accList[0].XC_LastName__c;
        accList[0].XC_Segment__c = 'B2B';
        insert accList;
        List<Contact> ctList = XC_DF_Contact.createResidentialContacts(accList);
        ctList[0].RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        ctList[0].XC_CountryLegalEntity__c = 'Italy';
        ctList[0].XC_MainLegalEntity__c = 'EnelXItalia';
        ctList[0].XC_Segment__c = 'B2B';
        insert ctlist;  
        XC_UTIL_ResultWrapper rw = XC_LCC120_NewCase.getConfigInformation(accList[0].Id, 'Account');
        System.assert(rw.success);
        Test.stopTest();
    }

    @isTest
    static void createB2BCaseFromAsset() {
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        accList[0].Name = accList[0].XC_LastName__c;
        accList[0].XC_Segment__c = 'B2B';
        insert accList;
        List<Contact> ctList = XC_DF_Contact.createResidentialContacts(accList);
        ctList[0].RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        ctList[0].XC_CountryLegalEntity__c = 'Italy';
        ctList[0].XC_MainLegalEntity__c = 'EnelXItalia';
        ctList[0].XC_Segment__c = 'B2B';
        ctList[0].XC_PrimaryContact__c = true;
        insert ctlist;
        
        
        Asset assetToInsert1 = new Asset();
        Asset assetToInsert2 = new Asset();
        assetToInsert1.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetToInsert2.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetToInsert1.Name = 'Baxi Neodens Plus 24_24 F Eco';
        assetToInsert2.Name = 'Baxi Neodens Plus 24_24 F Eco';
        assetToInsert1.IsCompetitorProduct = true;
        assetToInsert2.IsCompetitorProduct = true;
        assetToInsert1.InstallDate = Date.newInstance(2019, 04, 13);
        assetToInsert2.InstallDate = Date.newInstance(2019, 04, 13);
        assetToInsert1.IsInternal = false;
        assetToInsert2.IsInternal = false;
        assetToInsert1.Price = 104;
        assetToInsert2.Price = 104;
        assetToInsert1.AccountId = accList[0].Id;
        assetToInsert2.AccountId = accList[0].Id;
        assetToInsert1.PurchaseDate = Date.newInstance(2019, 04, 05);
        assetToInsert2.PurchaseDate = Date.newInstance(2019, 04, 05);
        assetToInsert1.Quantity = 3;
        assetToInsert2.Quantity = 3;
        assetToInsert1.NE__Status__c = 'Active';
        assetToInsert2.NE__Status__c = 'Active';
        assetToInsert1.UsageEndDate = Date.newInstance(2020, 12, 30);
        assetToInsert2.UsageEndDate = Date.newInstance(2020, 12, 30);
        assetToInsert1.NE__Commitment__c = false;
        assetToInsert2.NE__Commitment__c = false;
        assetToInsert1.ContactId = ctList[0].Id;
        assetToInsert2.ContactId = ctList[0].Id;
        assetToInsert1.XC_ActivationDate__c = Date.today();
        assetToInsert2.XC_ActivationDate__c = Date.today();
        assetToInsert2.TAM_IsLogical__c = true;
        assetToInsert1.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        assetToInsert1.XC_Segment__c  = 'B2B';
        assetToInsert2.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        assetToInsert2.XC_Segment__c  = 'B2B';
        insert new List<Asset> {assetToInsert1,assetToInsert2};
        
        XC_UTIL_ResultWrapper rw1 = XC_LCC120_NewCase.getConfigInformation(assetToInsert1.Id, 'Asset');
        XC_UTIL_ResultWrapper rw2 = XC_LCC120_NewCase.getConfigInformation(assetToInsert2.Id, 'Asset');
        System.assert(rw1.success && rw2.success);
        Test.stopTest();
    }

    @isTest
    static void createB2BCaseFromOpportunity() {
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        accList[0].Name = accList[0].XC_LastName__c;
        accList[0].XC_Segment__c = 'B2G';
        insert accList;
        List<Contact> ctList = XC_DF_Contact.createResidentialContacts(accList);
        ctList[0].RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        ctList[0].XC_CountryLegalEntity__c = 'Colombia';
        ctList[0].XC_MainLegalEntity__c = 'Codensa';
        ctList[0].XC_Segment__c = 'B2G';
        insert ctlist;
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, false);
        opp[0].AccountId = accList[0].Id;
        opp[0].XC_Contact__c = ctList[0].Id;
        opp[0].XC_Segment__c = 'B2G';
        opp[0].XC_LegalEntity__c = 'Codensa';
        opp[0].XC_ProductCategoryOfInterest__c = 'PV';
        opp[0].XC_Source__c = 'Mail';
        opp[0].XC_PipelineStatus__c = 'Opportunity Assigned';
        insert opp;
        XC_UTIL_ResultWrapper rw = XC_LCC120_NewCase.getConfigInformation(opp[0].Id, 'Opportunity');
        System.assert(rw.success);
        Test.stopTest();
    }

    @isTest
    static void utilMethod() {
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        List<Case> listCase = XC_DF_Case.createCases(1);
        insert listAsset;
        Test.startTest();
        //XC_LCC120_NewCase.getRelatedAccountAndContactId(listAsset[0].Id);
        XC_LCC120_NewCase.getCaseSegment(listCase[0].Id);
        Test.stopTest();
    }

    @isTest
    static void searchContactForAccount() {
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        XC_LCC120_NewCase.searchContactForAccount(accList[0].Id);
        Test.stopTest();
    }

    @isTest
    static void getInitInfo() {
        Test.startTest();
        XC_LCC120_NewCase.getInitInfo();
        Test.stopTest();
    }

}
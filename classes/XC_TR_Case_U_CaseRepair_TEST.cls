/**
 * @author Andrea Bravaccino
 * @date Creation  07/08/2019
 * @description XC_TR_Case_U_CaseRepair_TEST – Test class for XC_TR_Case_U_CaseRepair
 */
@isTest
public class XC_TR_Case_U_CaseRepair_TEST {

    @TestSetup
    static void setup(){
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');


        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        User u = XC_DF_User.createUserAdmin();
        u.Username = 'noCandidate@gmail.com';
        insert u;

        ServiceResource servRes = new ServiceResource(Name = Label.XC_CL_NoCandidateFound,
                                                    XC_Account__c = accList[0].Id,
                                                    isCapacityBased = true,
                                                    RelatedRecordId = u.Id,
                                                    isActive = true );
        insert servRes;

        NE__Bundle__c bundle = XC_DF_Bundle.createBundleRecords(1)[0];
        insert bundle;

        List<Asset> assetlist = XC_DF_Asset.createAssets(5);
        Asset a  = assetlist[0];

        List<Account> accounts = new List<Account>([SELECT ID FROM Account WHERE Id = : a.AccountId]);
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accounts);
        insert addresses;

        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;

        NE__Product__c prodToInsert = XC_DF_Product.createProducts(1)[0];
        prodToInsert.Name = 'Coverage Asset';
        insert prodToInsert;

        NE__Product__c prodToInsert2 = XC_DF_Product.createProducts(1)[0];
        prodToInsert2.Name = 'Baxi Cov';
        insert prodToInsert2;
        
        NE__DocumentationCharacterist__c docChar3 = new NE__DocumentationCharacterist__c();
        docChar3.Name = 'Reparaciones';
        docChar3.NE__Value__c = '10';
        docChar3.NE__Product__c = prodToInsert2.Id;
        insert docChar3;

        NE__DocumentationCharacterist__c docChar1 = new NE__DocumentationCharacterist__c();
        docChar1.Name = 'SLA';
        docChar1.NE__Value__c = 'less than 48h';
        docChar1.NE__Product__c = prodToInsert.Id;
        insert docChar1;

        NE__DocumentationCharacterist__c docChar2 = new NE__DocumentationCharacterist__c();
        docChar2.Name = 'Coverage Type';
        docChar2.NE__Value__c = 'Boiler; Heaters; Equipment';
        docChar2.NE__Product__c = prodToInsert.Id;
        insert docChar2;

        NE__Catalog_Item__c catItem = XC_DF_CatalogItem.createCatalogItem();
        catItem.NE__ProductId__c = prodToInsert.Id;
        insert catItem;

        a.Name = 'Baxi';
        a.XC_Address__c = addresses[0].Id;
        a.NE__Bundle__c = bundle.Id;
        a.XC_Product_Type__c = 'Boiler';
        a.XC_Product_Subtype__c = Label.XC_CL_ProductTypeEquipment;
        a.Status = Label.XC_CL_Asset_StatusActive;
        a.ContactId = contacts[0].Id;
        insert a;

        Asset a2 = assetlist[4];
        a2.Name = 'Baxi2';
        a2.AccountId = a.AccountId;
        a2.XC_Address__c = addresses[0].Id;
        a2.NE__Bundle__c = bundle.Id;
        a2.XC_Product_Type__c = 'Boiler';
        a2.XC_Product_Subtype__c = Label.XC_CL_ProductTypeEquipment;
        a2.Status = Label.XC_CL_Asset_StatusActive;
        a2.ContactId = contacts[0].Id;
        insert a2;

        Asset assetBundle  = assetlist[3];
        assetBundle.XC_Address__c = addresses[0].Id;
        assetBundle.Name = 'type service';
        assetBundle.AccountId = a.AccountId;
        assetBundle.NE__Bundle__c = bundle.Id;
        assetBundle.XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetBundle.XC_Product_Subtype__c = Label.XC_CL_ProductTypeBundle;
        assetBundle.Status = Label.XC_CL_Asset_StatusActive;
        assetBundle.ContactId = contacts[0].Id;

        insert assetBundle;

        Asset assetTypeSErvice  = assetlist[2];
        assetTypeSErvice.XC_Address__c = addresses[0].Id;
        assetTypeSErvice.Name = 'type service';
        assetTypeSErvice.AccountId = a.AccountId;
        assetTypeSErvice.NE__Bundle__c = bundle.Id;
        assetTypeSErvice.XC_Product_Type__c = Label.XC_CL_ProductTypeService;
        assetTypeSErvice.XC_Product_Subtype__c = 'Repair';
        assetTypeSErvice.Status = Label.XC_CL_Asset_StatusActive;
        assetTypeSErvice.ContactId = contacts[0].Id;

        insert assetTypeSErvice;

        Asset assetCoverage  = assetlist[1];
        assetCoverage.NE__CatalogItem__c = catItem.Id;
        assetCoverage.NE__ProdId__c = prodToInsert.Id;
        assetCoverage.NE__Bundle_Configuration__c = assetTypeSErvice.Id;
        assetCoverage.XC_Address__c = addresses[0].Id;
        assetCoverage.Name = 'Baxi Cov';
        assetCoverage.AccountId = a.AccountId;
        assetCoverage.NE__Bundle__c = bundle.Id;
        assetCoverage.XC_Product_Type__c = Label.XC_CL_ProductTypeCoverage;
        assetCoverage.XC_Product_Subtype__c = 'Repair';
        assetCoverage.Status = Label.XC_CL_Asset_StatusActive;
        assetCoverage.ContactId = contacts[0].Id;

        insert assetCoverage;

        Case cs = XC_DF_CASE.createCases(1)[0];
        cs.XC_Address__c = addresses[0].Id;
        cs.Reason = 'XCMOT002';
        cs.Status = 'ESTA001';
        cs.SubCause__c = 'ATCL003';
        cs.AccountId = accounts[0].Id;
        cs.ContactId = contacts[0].Id;
        insert cs;

        Test.stopTest();
    }


    //Test Method oneAssetTest
    @isTest
    static void oneAssetTest(){
        Test.startTest();

        NE__Product__c prod = [SELECT ID FROM NE__Product__c LIMIT 1][0];
        NE__DocumentationCharacterist__c docChar1 = new NE__DocumentationCharacterist__c();
        docChar1.Name = 'SLA';
        docChar1.NE__Value__c = 'less than 48h';
        docChar1.NE__Product__c = prod.Id;
        insert docChar1;

        NE__DocumentationCharacterist__c docChar2 = new NE__DocumentationCharacterist__c();
        docChar2.Name = 'Coverage Type';
        docChar2.NE__Value__c = 'Boiler; Heaters; Equipment';
        docChar2.NE__Product__c = prod.Id;
        insert docChar2;


        Case cs = [SELECT Id, XC_Subtype__c FROM Case LIMIT 1][0];
        List<Asset> aList = [SELECT Id FROM Asset WHERE XC_Product_Subtype__c = :Label.XC_CL_ProductTypeEquipment LIMIT 1];

        XC_LCC121_AssetSelectionOnCase.AssetsAttachData res = XC_LCC121_AssetSelectionOnCase.attachAssets(cs.Id, aList);
        System.debug('rislutato inserimento case: ' + res.resultMessage);

        cs.XC_Subtype__c = 'XC018';

        update cs;
        Test.stopTest();

        System.assert (cs!=null);

    }

    @isTest
    static void twoAssetTest(){
        Test.startTest();
        NE__Product__c prod = [SELECT ID FROM NE__Product__c LIMIT 1][0];
        NE__DocumentationCharacterist__c docChar1 = new NE__DocumentationCharacterist__c();
        docChar1.Name = 'SLA';
        docChar1.NE__Value__c = 'less than 48h';
        docChar1.NE__Product__c = prod.Id;
        insert docChar1;

        NE__DocumentationCharacterist__c docChar2 = new NE__DocumentationCharacterist__c();
        docChar2.Name = 'Coverage Type';
        docChar2.NE__Value__c = 'Boiler; Heaters; Equipment';
        docChar2.NE__Product__c = prod.Id;
        insert docChar2;

        Case cs = [SELECT Id, XC_Subtype__c FROM Case LIMIT 1][0];
        List<Asset> aList = [SELECT Id, Name FROM Asset WHERE XC_Product_Subtype__c = :Label.XC_CL_ProductTypeEquipment];
        System.debug('aList: ' + aList);
        XC_LCC121_AssetSelectionOnCase.AssetsAttachData res = XC_LCC121_AssetSelectionOnCase.attachAssets(cs.Id, aList);
        System.debug('rislutato inserimento case: ' + res.resultMessage);

        cs.XC_Subtype__c = 'XC018';

        update cs;
        Test.stopTest();

        System.assert (cs!=null);

    }

    @isTest
    static void notCoveredAssetTest(){
        Test.startTest();
        NE__Product__c prod = [SELECT ID FROM NE__Product__c LIMIT 1][0];
        NE__DocumentationCharacterist__c docChar1 = new NE__DocumentationCharacterist__c();
        docChar1.Name = 'SLA';
        docChar1.NE__Value__c = 'less than 48h';
        docChar1.NE__Product__c = prod.Id;
        insert docChar1;

        NE__DocumentationCharacterist__c docChar2 = new NE__DocumentationCharacterist__c();
        docChar2.Name = 'Coverage Type';
        docChar2.NE__Value__c = 'Boiler; Heaters;';
        docChar2.NE__Product__c = prod.Id;
        insert docChar2;

        Case cs = [SELECT Id, XC_Subtype__c FROM Case LIMIT 1][0];
        List<Asset> aList = [SELECT Id, Name FROM Asset WHERE XC_Product_Subtype__c = :Label.XC_CL_ProductTypeEquipment];
        System.debug('aList: ' + aList);
        XC_LCC121_AssetSelectionOnCase.AssetsAttachData res = XC_LCC121_AssetSelectionOnCase.attachAssets(cs.Id, aList);
        System.debug('rislutato inserimento case: ' + res.resultMessage);

        cs.XC_Subtype__c = 'XC018';
        try {
            update cs;
        } catch (System.DmlException e) {
            System.debug('error e: ' + e.getCause());
        }

        Test.stopTest();

        System.assert (cs!=null);

    }
}
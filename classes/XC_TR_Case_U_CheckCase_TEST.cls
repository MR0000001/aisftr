/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  27/05/2019 
* @description XC_TR_Case_U_CheckCase_TEST – Test class for XC_TR_Case_U_CheckCase
*/ 
@istest
public class XC_TR_Case_U_CheckCase_TEST {
    //Test Method assingSLA
    @testSetup
    static void assingSLA(){ 
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        /*List<Case> listc = XC_DF_Case.createCases(1);
        listc[0].Status = 'ESTA001';
        insert listc;
        update listc;*/
        List<XC_Address__c> addr= XC_DF_Address.createAddress(1);
        insert addr;
        
        XC_Address__c address = [SELECT Id, XC_Account__c, XC_IdAccount__c FROM XC_Address__c WHERE Id = :addr[0].Id LIMIT 1];
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Id = address.XC_Account__c));
        
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(accounts);
        insert listContact;
        
        List<Asset> assetList =XC_DF_Asset.createAssets(accounts);
        assetList[0].ContactId= listContact[0].Id;
        insert assetList;
        
        List<Case> listc = XC_DF_Case.createCases(2);
        listc[0].ContactId = listContact[0].Id;
        listc[0].AccountId = address.XC_Account__c;
        listc[0].XC_Address__c = address.Id;
        listc[0].AssetId=assetList[0].Id;
        listc[0].Status = 'ESTA001';
        listc[0].XC_Subtype__c = 'XC002';			
        listc[0].Reason = 'XCMOT011';
        listc[0].Subcause__c = 'ATCL002' ;
        listc[0].XC_LegalEntity__c = 'EndesaX';
        //listc[0].Status = 'ESTA007';
        listc[1].Subcause__c = XC_AT_Constants.TRIGGER_SUBCAUSE_ATCL028;
        listc[1].Reason = 'XCMOT007';
        listc[1].XC_LegalEntity__c = 'EndesaX';
        listc[1].XC_Description__c = 'Test no correct document';
        listc[1].XC_Subtype__c = 'XC181';
        insert listc;
        
        /*listc[0].XC_Resolution__c = 'R001';
        listc[0].XC_Result__c ='RS003';
        listc[0].CaseRemarks__c ='test';
        update listc;*/
        
        XC_CaseAsset__c caseAsset = new XC_CaseAsset__c();
        caseAsset.XC_Case__c = listc[0].Id;
        caseAsset.XC_Asset__c = assetList[0].Id;
        insert caseAsset;
        Test.stopTest();
        //System.debug('Lista di case Asset' + [SELECT Id, XC_Case__c, XC_Asset__c, XC_Asset__r.Name FROM XC_CaseAsset__c WHERE XC_Case__c = : listc[0].Id]);
        List<WorkOrder> listwo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        listwo[0].Status = 'New';
        listwo[0].CaseId = listc[0].Id;
        insert listwo;
        
        System.assertEquals(true, listc!=null);
        
    }
    
    //Test Method assingSLA1
    @isTest
    static void assingSLA1(){
        Test.startTest();
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(accounts);
        insert listContact;
        
        List<Case> listc = XC_DF_Case.createCases(1);
        listc[0].Status = 'ESTA001';
        //listc[0].XC_Subtype__c = 'XC077';
        listc[0].Reason = 'XCMOT002';
        listc[0].Subcause__c = 'ATCL003' ;
        listc[0].ContactId = listContact[0].Id;
        listc[0].AccountId = accounts[0].Id;
        listc[0].XC_LegalEntity__c = 'EndesaX';
       
        insert listc;
        update listc;
        
        XC_CM_Case_ESPAttentionTypes__mdt caseTypeSettingsMtd = [
            SELECT Id, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_SLAProcess__c
              FROM XC_CM_Case_ESPAttentionTypes__mdt][0];
        
        System.assertEquals(true, listc!=null);
        Test.stopTest();
        
    }
    
    
    //Test Method checkCaseAndAssignSLA
    static testMethod void checkCaseAndAssignSLA(){
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(accounts);
        insert listContact;
        
        Test.startTest();   
        List<Case> listc = XC_DF_Case.createCases(1);
        listc[0].XC_LegalEntity__c = 'EndesaX';
        listc[0].Status = 'ESTA001';
        listc[0].Reason = 'XCMOT010';
        listc[0].Subcause__c = 'ATCL070';
        listc[0].ContactId = listContact[0].Id;
        listc[0].AccountId = accounts[0].Id;
        insert listc;
        System.assertEquals(true, listc!=null);
        
        Test.stopTest(); 

    }
   
	@isTest
    static void checkCaseAndAssignSLA3(){
        Test.startTest(); 
        
        
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

        List<Account> accounts = new List<Account>([SELECT ID FROM Account WHERE Id = :a.AccountId]);
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(accounts);
        insert addresses;

        NE__Product__c prodToInsert = XC_DF_Product.createProducts(1)[0];
        prodToInsert.Name = 'Coverage Asset';
        insert prodToInsert;

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
        List<Asset> assetsToInsert = new List<Asset>();
        a.Name = 'Baxi';
        a.XC_Address__c = addresses[0].Id;
        a.NE__Bundle__c = bundle.Id;
        a.XC_Product_Type__c = 'Boiler';
        a.XC_Product_Subtype__c = Label.XC_CL_ProductTypeEquipment;
        a.Status = Label.XC_CL_Asset_StatusActive ;
		//insert a;
        assetsToInsert.add(a);

        Asset a2 = assetlist[4];
        a2.Name = 'Baxi2';
        a2.AccountId = a.AccountId;
        a2.XC_Address__c = addresses[0].Id;
        a2.NE__Bundle__c = bundle.Id;
        a2.XC_Product_Type__c = 'Boiler';
        a2.XC_Product_Subtype__c = Label.XC_CL_ProductTypeEquipment;
        a2.Status = Label.XC_CL_Asset_StatusActive ;
		//insert a2;
        assetsToInsert.add(a2);

        Asset assetBundle  = assetlist[3];
        assetBundle.XC_Address__c = addresses[0].Id;
        assetBundle.Name = 'type service';
        assetBundle.AccountId = a.AccountId;
        assetBundle.NE__Bundle__c = bundle.Id;
        assetBundle.XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetBundle.XC_Product_Subtype__c = Label.XC_CL_ProductTypeBundle;
        assetBundle.Status = Label.XC_CL_Asset_StatusActive ;
        
		//insert assetBundle;
        assetsToInsert.add(assetBundle);

        Asset assetTypeSErvice  = assetlist[2];
        assetTypeSErvice.XC_Address__c = addresses[0].Id;
        assetTypeSErvice.Name = 'type service';
        assetTypeSErvice.AccountId = a.AccountId;
        assetTypeSErvice.NE__Bundle__c = bundle.Id;
        assetTypeSErvice.XC_Product_Type__c = Label.XC_CL_ProductTypeService;
        assetTypeSErvice.XC_Product_Subtype__c = 'Repair';
        assetTypeSErvice.Status = Label.XC_CL_Asset_StatusActive ;
        
		//insert assetTypeSErvice;
        assetsToInsert.add(assetTypeSErvice);
        insert assetsToInsert;
        
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
        assetCoverage.Status = Label.XC_CL_Asset_StatusActive ;
        
		insert assetCoverage;

        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        insert contacts;
        
        List<Case> listc = [SELECT Id, ContactId, AccountId, XC_Address__c, XC_LegalEntity__c FROM Case WHERE XC_Subtype__c = 'XC002' AND AssetId!=NULL];
                
        List <NE__DocumentationCharacterist__c> docChar = new List<NE__DocumentationCharacterist__c>();

        NE__Product__c prod = [SELECT ID FROM NE__Product__c LIMIT 1][0];
        NE__DocumentationCharacterist__c docCharUno = new NE__DocumentationCharacterist__c();
        docCharUno.Name = 'SLA';
        docCharUno.NE__Value__c = 'less than 48h';
        docCharUno.NE__Product__c = prod.Id;
        docChar.add(docCharUno);
        //insert docCharUno;

        NE__DocumentationCharacterist__c docCharDue = new NE__DocumentationCharacterist__c();
        docCharDue.Name = 'Coverage Type';
        docCharDue.NE__Value__c = 'Boiler; Heaters; Equipment';
        docCharDue.NE__Product__c = prod.Id;
        docChar.add(docCharDue);
        //insert docCharDue;

        insert docChar;
        
        List<Asset> aList = [SELECT Id FROM Asset WHERE XC_Product_Subtype__c = :Label.XC_CL_ProductTypeEquipment LIMIT 1];

        XC_LCC121_AssetSelectionOnCase.AssetsAttachData res = XC_LCC121_AssetSelectionOnCase.attachAssets(listc[0].Id, aList);
		
        List<Account> accounts2 = new List<Account>([SELECT ID FROM Account WHERE Id =: listc[0].AccountId]);
        List<XC_Address__c> addresses2 = XC_DF_Address.createAddress(accounts2);
        insert addresses2;

        
        
        Case newCaso = new Case();
        newCaso.XC_Subtype__c = 'XC010';				
        newCaso.Reason = 'XCMOT002';
        newCaso.Subcause__c = 'ATCL003' ;
        newCaso.AccountId = listc[0].AccountId;
        newCaso.ContactId = listc[0].ContactId;
        newCaso.XC_LegalEntity__c = listc[0].XC_LegalEntity__c;
        newCaso.XC_Address__c = addresses2[0].Id;
        insert newCaso;
        
        //newCaso.XC_AssetAttached__c=true;
        newCaso.Status = 'ESTA003'; 
        update newCaso;
        System.assertEquals(true, newCaso!=null);
        
        Test.stopTest();
    }
   
	@isTest
    static void fillRecordType(){

        Test.startTest(); 
        Case caso = new Case();
        caso.Reason = 'XCMOT001';
        caso.XC_LegalEntity__c = 'EndesaX';
        caso.XC_Segment__c = 'B2C';
        
        XC_TR_Case_U_CheckCase.fillRecordType(new List<Case> {caso});
        System.assert(caso.RecordTypeId !=null);
        
        Test.stopTest();
    }
   
    @isTest
    public static void assingSLAeT(){
        Test.startTest();
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        
        List<Contact> listContact = XC_DF_Contact.createResidentialContacts(accounts);
        insert listContact;
        
        Case caso =new Case();
        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Management_Case').getRecordTypeId(); //VDB 14-04-22 CR 760
        caso.Recordtypeid=recordTypeId;
        caso.Reason = 'XCMOT002';
        caso.Subcause__c = 'ATCL003' ;
        caso.ContactId = listContact[0].Id;
        caso.AccountId = accounts[0].Id;
        caso.XC_LegalEntity__c = 'EnelXItalia';
        caso.XC_Subtype__c = 'XC199'; 
        caso.XC_DefectType__c='Altro IG';
        caso.XC_DefectDescription__c='IG_Apparecchio di illuminazione intermittente';
        caso.XC_FaultType__c='IG';
        caso.XC_Segment__c='B2G';
        insert caso;
        List<Case> caseList=new List<Case>();
        caseList.add(caso);
         XC_CM_Case_ESPAttentionTypes__mdt caseTypeSettingsMtd = [
        SELECT Id, XC_Case_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c, XC_SLAProcess__c,XC_AccountSLA__c
        FROM XC_CM_Case_ESPAttentionTypes__mdt where XC_AccountSLA__c=TRUE][0];
        List <SlaProcess> spList=[Select id,Name from SlaProcess where Name like'%SLAPROCESS_DEFAULT%' and isActive=true ];
        Entitlement et=new Entitlement();
        et.accountid=caso.accountId;
        et.SlaProcessId=spList[0].id;
        et.XC_EntitlmentCheck__c=false;
        et.name=caso.XC_FaultType__c;
        insert et;
        Map<String, Entitlement> slaMap = new  Map<String, Entitlement>();
        slaMap.put(spList[0].name,et);
        XC_TR_Case_U_CheckCase.assingSLA(caseList);
       
        Test.stopTest();
        
    }

    @isTest
    private static void checkPermittingStatus_test(){
       
        Test.startTest();
        List<Case> myCase = [SELECT ID, XC_Description__c, XC_Permitting_Status__c FROM CASE WHERE XC_Description__c = 'Test no correct document'];
        XC_DocumentType__c doc1 = new XC_DocumentType__c(Category__c = Label.XC_CL_DocumentType_Category_SF_RESULT_DOC, Case__c = myCase[0].Id);
        insert doc1;
        
        myCase[0].XC_Permitting_Status__c = 'Completed OK';
        
        update myCase;
        
        List<Case> cases = [SELECT ID, XC_Description__c, XC_Permitting_Status__c, Status, XC_Result__c, XC_Resolution__c FROM CASE WHERE XC_Description__c = 'Test no correct document'];
        System.assert(cases[0].Status=='ESTA007'); 
        System.assert(cases[0].XC_Result__c =='RS003' );
        System.assert(cases[0].XC_Resolution__c =='R001');
    
        Test.stopTest();
    }
    
    @isTest
    private static void checkPermittingStatus_NoCorrectDocument_test(){

        Test.startTest();

        List<Case> myCase = [SELECT ID, XC_Description__c, XC_Permitting_Status__c FROM CASE WHERE XC_Description__c = 'Test no correct document'];
        XC_DocumentType__c doc1 = new XC_DocumentType__c(Category__c = Label.XC_CL_DocumentType_Category_SF_ELECTRIC_CERT, Case__c = myCase[0].Id);
        insert doc1;
        myCase[0].XC_Permitting_Status__c = 'Completed OK';
        try{
            update myCase;
            System.assert(False);
            
        } catch(Exception ex){
            List<Case> cases = [SELECT ID, XC_Description__c, Status FROM CASE WHERE XC_Description__c = 'Test no correct document'];
            System.assert(cases[0].Status!='ESTA007');
        }
        Test.stopTest();
    }

}
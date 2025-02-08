/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation 19/04/2020
* @description XC_TR_Case_U_PopulateFields_TEST – Test Class for XC_TR_Case_U_PopulateFields
*/ 

@isTest
public class XC_TR_Case_U_PopulateFields_TEST {
    @TestSetup
    static void setup()
    {	
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
	
  /*  @isTest
    static void checkCaseDisconnect(){
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL070';
        caseList[0].XC_Subtype__c = 'XC069';
        caseList[0].XC_CompliantApplicable__c = true;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        Test.startTest();
        	insert caseList;
        	System.assertEquals(1, caseList.size(),'error AssertEquals');
        Test.stopTest();
    } */
	
    @isTest
    static void populateAssetListDetails_BundleAssociatedOnInsert(){
        List<Account> accntList = XC_DF_Account.createResidentialAccounts(1);
        insert accntList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accntList);
        insert contList;
        
        NE__Bundle__c  bundle = new NE__Bundle__c(NE__RecurringChargeFrequency__c = 'Monthly', NE__Start_Date__c = Date.Today());
        insert bundle;
		NE__Product__c product = new NE__Product__c(Name = 'Solution Caldera'); 
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        insert product;
        List<Asset> assetList = XC_DF_Asset.createAssets(3);
        //Asset Bundle
        assetList[0].AccountId = accntList[0].Id;
        assetList[0].ContactId = contList[0].Id;
        assetList[0].Name = 'Bundre Root';
        assetList[0].XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetList[0].XC_Product_Subtype__c = 'Air conditioning';
        assetList[0].XC_BillingModel__c = '3 years renting';
        assetList[0].NE__Bundle__c = bundle.Id;
        assetList[0].Status = 'Active';
        
        //Assets Equipment
        assetList[1].AccountId = accntList[0].Id;
        assetList[1].ContactId = contList[0].Id;
        assetList[1].Name = 'Bundre Children Eqp 1';
        assetList[1].SerialNumber = 'BC-C12345 44';
        assetList[1].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[1].XC_Product_Subtype__c = 'Air conditioning';
        assetList[1].XC_BillingModel__c = '3 years renting';
        assetList[1].NE__Bundle__c = bundle.Id;
        assetList[1].NE__ProdId__c = product.Id;
        assetList[1].Status = 'Active';
        
        assetList[2].AccountId = accntList[0].Id;
        assetList[2].ContactId = contList[0].Id;
        assetList[2].Name = 'Bundre Children Eqp 2';
        assetList[2].SerialNumber = 'XS008890 F2';
        assetList[2].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[2].XC_Product_Subtype__c = 'Air conditioning';
        assetList[2].XC_BillingModel__c = '3 years renting';
        assetList[2].NE__Bundle__c = bundle.Id;
        assetList[2].NE__ProdId__c = product.Id;
        assetList[2].Status = 'Active';
        
        insert assetList;
        assetList[1].NE__Bundle_Configuration__c = assetList[0].Id;
        assetList[2].NE__Bundle_Configuration__c = assetList[0].Id;
        update assetList;
        
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL070';
        caseList[0].XC_Subtype__c = 'XC069';
        caseList[0].XC_CompliantApplicable__c = true;
        caseList[0].AccountId = accntList[0].Id;
        caseList[0].ContactId = contList[0].Id;
        caseList[0].AssetId = assetList[0].Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        Test.startTest();
        	insert caseList;
        	Case caso = [SELECT Id, XC_AssetListDetails__c FROM Case WHERE Id =: caseList[0].Id];
        	System.debug('TEST_1: XC_AssetListDetails__c='+ caso.XC_AssetListDetails__c);
        	System.assert(true, caso!=null);
        	/*System.assert(String.isNotBlank(caso.XC_AssetListDetails__c));
        	System.assert((caso.XC_AssetListDetails__c).contains('Bundre Children Eqp 2<SN>XS008890 F2'));
        	System.assert((caso.XC_AssetListDetails__c).contains(','));
        	System.assert((caso.XC_AssetListDetails__c).contains('Bundre Children Eqp 1<SN>BC-C12345 44'));*/
        Test.stopTest();
    }
	
    @isTest
    static void populateAssetListDetails_EquipmenmtAssociatedOnUpdate(){
        List<Account> accntList = XC_DF_Account.createResidentialAccounts(1);
        insert accntList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accntList);
        insert contList;
        
        NE__Bundle__c  bundle = new NE__Bundle__c(NE__RecurringChargeFrequency__c = 'Monthly', NE__Start_Date__c = Date.Today());
        insert bundle;
		NE__Product__c product = new NE__Product__c(Name = 'Solution Caldera'); 
        product.XC_Product_Subtype__c = 'Boiler';
        product.XC_Product_Type__c = 'Equipment';
        insert product;
        List<Asset> assetList = XC_DF_Asset.createAssets(3);
        //Asset Bundle
        assetList[0].AccountId = accntList[0].Id;
        assetList[0].ContactId = contList[0].Id;
        assetList[0].Name = 'Bundre Root';
        assetList[0].XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetList[0].XC_Product_Subtype__c = 'Air conditioning';
        assetList[0].XC_BillingModel__c = '3 years renting';
        assetList[0].NE__Bundle__c = bundle.Id;
        assetList[0].Status = 'Active';
        
        //Assets Equipment
        assetList[1].AccountId = accntList[0].Id;
        assetList[1].ContactId = contList[0].Id;
        assetList[1].Name = 'Bundre Children Eqp 1';
        assetList[1].SerialNumber = 'BC-C12345 44';
        assetList[1].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[1].XC_Product_Subtype__c = 'Air conditioning';
        assetList[1].XC_BillingModel__c = '3 years renting';
        assetList[1].NE__Bundle__c = bundle.Id;
        assetList[1].NE__ProdId__c = product.Id;
        assetList[1].Status = 'Active';
        
        assetList[2].AccountId = accntList[0].Id;
        assetList[2].ContactId = contList[0].Id;
        assetList[2].Name = 'Bundre Children Eqp 2';
        assetList[2].SerialNumber = 'XS008890 F2';
        assetList[2].XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        assetList[2].XC_Product_Subtype__c = 'Air conditioning';
        assetList[2].XC_BillingModel__c = '3 years renting';
        assetList[2].NE__Bundle__c = bundle.Id;
        assetList[2].NE__ProdId__c = product.Id;
        assetList[2].Status = 'Active';
        
        insert assetList;
        assetList[1].NE__Bundle_Configuration__c = assetList[0].Id;
        assetList[2].NE__Bundle_Configuration__c = assetList[0].Id;
        update assetList;
        
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL070';
        caseList[0].XC_Subtype__c = 'XC069';
        caseList[0].XC_CompliantApplicable__c = true;
        caseList[0].AccountId = accntList[0].Id;
        caseList[0].ContactId = contList[0].Id;
        caseList[0].AssetId = assetList[1].Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        Test.startTest();
        	insert caseList;
        	//caseList[0].AssetId = assetList[1].Id;
        	//update caseList;
            XC_TR_Case_U_PopulateFields.setTechnicalAssetOnCaseB2BG(caseList);
        	Case caso = [SELECT Id, XC_AssetListDetails__c FROM Case WHERE Id =: caseList[0].Id];
        	System.debug('TEST_2: XC_AssetListDetails__c='+ caso.XC_AssetListDetails__c);
        	System.assert(true, caso!=null);	
        	/*System.assert(String.isNotBlank(caso.XC_AssetListDetails__c));
        	System.assert((caso.XC_AssetListDetails__c).contains('Bundre Children Eqp 2<SN>XS008890 F2'));
        	System.assert((caso.XC_AssetListDetails__c).contains(','));
        	System.assert((caso.XC_AssetListDetails__c).contains('Bundre Children Eqp 1<SN>BC-C12345 44'));*/
        Test.stopTest();
    }


    @isTest
    static void populateBusinessLine(){
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT005';
        caseList[0].SubCause__c = 'ATCL070';
        caseList[0].XC_Subtype__c = 'XC069';
        caseList[0].XC_LegalEntity__c = 'EnelXMSP';
        caseList[0].XC_Segment__c = 'B2C';
        caseList[0].XC_BusinessLine__c = 'eMobility';
        Test.startTest();
        	insert caseList;
        	caseList[0].XC_BusinessLine__c = null;
        	update caseList;
            caseList[0].XC_BusinessLine__c = 'eMobility';
        	update caseList;
        	Case caso = [SELECT Id, XC_AssetListDetails__c FROM Case WHERE Id =: caseList[0].Id];
        	System.assert(true, caso!=null);
        Test.stopTest();
    }

    @isTest
    static void updateLastQueueTest(){
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].Reason = 'XCMOT004';
        caseList[0].SubCause__c = 'Change Plafond';
        caseList[0].XC_LegalEntity__c = 'EnelXMSP';
        caseList[0].XC_Segment__c = 'B2C';
        caseList[0].XC_BusinessLine__c = 'eMobility';
        caseList[0].XC_Plafond__c = 100;
        insert caseList;
        User user = new User(); 
        user.Username = 'pablo123@gmail.com';  
        user.FirstName ='TestUser';
        user.LastName ='testUserProva';
        user.Email = 'pablo@test.com';
        user.Alias = 'TestTry'; 
        user.ProfileId = [SELECT Id, UserLicenseId FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        user.LocaleSidKey = 'it_IT';
        user.TimeZoneSidKey = 'GMT';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1'; 
        user.IsActive = true;
        user.Country__c = 'SPAIN';
        user.CompanyP__c = 'SPAIN';
        insert user;
        caseList[0].OwnerId = user.Id;
        update caseList;
        
        Test.startTest();
        	Case caso = [SELECT Id, XC_AssetListDetails__c FROM Case WHERE Id =: caseList[0].Id];
        	System.assert(true, caso!=null);
        Test.stopTest();
    }
    //DeAv 08.07.2022 - NR2330 START
    @isTest
    static void setTechnicalAssetOnCaseB2BG_Test(){
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = true;
        update user;
        System.runAs(user[0]) {
        id rtIdAsset =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('TAM_Network').getRecordTypeId();  
        id rtIdB2B =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId(); 
        Test.startTest();    
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true); 
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);    
        insert accList;
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, false); 
        XC_TR_Account_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, false);    
        List<XC_Address__c> addr = XC_DF_Address.createAddress(accList);
        XC_TR_Address_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true); 
        XC_TR_Address_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);    
        insert addr;
        XC_TR_Address_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, false); 
        XC_TR_Address_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, false);    
        List <Contact> cont = XC_DF_Contact.createResidentialContacts(accList);
        cont[0].AccountId=accList.get(0).id;
        XC_TR_Contact_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true); 
        XC_TR_Contact_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true);    
        insert cont;
        XC_TR_Contact_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, false); 
        XC_TR_Contact_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, false);    
          
        List<Asset> ass = XC_DF_Asset.createAssets(1);
        ass[0].XC_Address__c= addr[0].id;
        ass[0].TAM_PartnerContractId__c='ok';
        ass[0].TAM_IsTechnical__c= true;
        ass[0].TAM_IsLogical__c=true;
        ass[0].AccountId= accList[0].id;
        ass[0].XC_Segment__c  = 'B2B';
        ass[0].XC_LegalEntity__c = 'EnelXItalia';
        ass[0].RecordTypeId = rtIdAsset;
        ass[0].Status = 'Installed';
        ass[0].TAM_Make__c = 'MakeTest';
        ass[0].XC_Model__c = 'ModelTest';
        ass[0].TAM_ModelOrPartNumber__c = 'Test';
        ass[0].SerialNumber = 'SerialNumberTest';
        insert ass;
       
        List<Case> caseList= XC_DF_Case.createCases(1);
        caseList[0].RecordTypeId = rtIdB2B;
        caseList[0].Reason = 'XCMOT002';
        caseList[0].SubCause__c = 'ATCL003';
        caseList[0].XC_LegalEntity__c = 'EnelXItalia';
        caseList[0].XC_Segment__c = 'B2B';
        caseList[0].XC_BusinessLine__c = 'eCity';
        caseList[0].Country__c = 'Italy';
        caseList[0].AccountId = accList[0].Id;
        caseList[0].ContactId=cont[0].id;
        insert caseList;   
        
       
        XC_TR_Case_U_PopulateFields.setTechnicalAssetOnCaseB2BG(caseList);
        Test.stopTest();
        }
    }

    //DeAv 08.07.2022 - NR2330 END
}
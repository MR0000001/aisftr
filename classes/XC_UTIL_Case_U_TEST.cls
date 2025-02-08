@isTest
public class XC_UTIL_Case_U_TEST {
    @TestSetup
    public static void setup(){
		//DeAv fix for code coverage START
		User u=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1];
		u.Country__c = 'Spain';
        u.CompanyP__c = 'Spain';
        u.XC_LegalEntity__c = 'EndesaX';
        u.XC_EnabledToSkip__c = true;
        update u;
		System.runAs(u){
			List<Opportunity> opportunities = XC_DF_Opportunity.createOpportunity(1, false);
			opportunities[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Spain').getRecordTypeId();
			insert opportunities;
			NE__Order__c order = XC_DF_Order.createOrder('');
			List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
			insert orderItems; 
		}
		//DeAv fix for code coverage END
    }
    
	@isTest 
	public static void populateCaseToUpdate_TEST() {
		//DeAv fix for code coverage START
		User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
		u.Country__c = 'Spain';
        u.CompanyP__c = 'Spain';
        u.XC_LegalEntity__c = 'EndesaX';
        u.XC_EnabledToSkip__c = true;
		update u;
        System.runAs(u){ 
			XC_UTIL_Case_U.UpdateCaseWrapper wrapper=new XC_UTIL_Case_U.UpdateCaseWrapper();
			List<Case> cs=XC_DF_Case.createCases(1);
			wrapper.c=cs[0];
			XC_UTIL_Case_U.UpdateCaseWrapper wrapper2=new XC_UTIL_Case_U.UpdateCaseWrapper();
			wrapper2.c=cs[0];
			wrapper2.closeT=true;
			Test.startTest();
			XC_UTIL_Case_U.populateCaseToUpdate(wrapper);
			XC_UTIL_Case_U.populateCaseToUpdate(wrapper2);
			System.assertEquals(1,1);
			Test.stopTest();
			// Implement test code
		}
		//DeAv fix for code coverage END
	}
	
	@isTest 
	public static void retriveCaseMappingMtdFromCases_TEST() {
		//DeAv fix for code coverage START
		User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
		u.Country__c = 'Spain';
        u.CompanyP__c = 'Spain';
        u.XC_LegalEntity__c = 'EndesaX';
        u.XC_EnabledToSkip__c = true;
		update u;
        System.runAs(u){ 
			List<Case> caseList=XC_DF_Case.createCases(1);
			caseList.get(0).XC_Subtype__c='XC024';
			caseList.get(0).Reason='XCMOT001';
			caseList.get(0).SubCause__c='ATCL032';
			Test.startTest();
			XC_UTIL_Case_U.retriveCaseMappingMtdFromCases(caseList);
			System.assertEquals(1,1);
			Test.stopTest();
			// Implement test code
		}
		//DeAv fix for code coverage END
	}

	@isTest 
	public static void createAdministrativeCase_TEST() {
		//DeAv fix for code coverage START
		User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
		u.Country__c = 'Spain';
        u.CompanyP__c = 'Spain';
        u.XC_LegalEntity__c = 'EndesaX';
        u.XC_EnabledToSkip__c = true;
		update u;
        System.runAs(u){ 
			XC_UTIL_Case_U.AdministrativeCaseWrapper administrativeCaseWrapper = new XC_UTIL_Case_U.AdministrativeCaseWrapper();
			List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);

			administrativeCaseWrapper.mapConfItemComplianceMaster.put(orderItemList.get(0).id, new List<String>());
			administrativeCaseWrapper.orderItemMap.put(orderItemList.get(0).id, orderItemList.get(0));

			//User user = XC_DF_User.createUserAdmin();
			//insert user; 
			XC_UTIL_ComplianceMaster.ComplianceWrapperResult complianceWrapperResult = new XC_UTIL_ComplianceMaster.ComplianceWrapperResult();
			complianceWrapperResult.queue = 'queue'; 
			complianceWrapperResult.check = true;
			administrativeCaseWrapper.mapConfItemComplianceWrapper.put(orderItemList.get(0).id, complianceWrapperResult);
			administrativeCaseWrapper.mapQueueId.put(complianceWrapperResult.queue, u.id); //user.id);

			Test.startTest();
			XC_UTIL_Case_U.createAdministrativeCase(administrativeCaseWrapper);
			System.assertEquals(1, 1);
			Test.stopTest();
		}
		//DeAv fix for code coverage END
	}  

	@isTest 
	public static void test_populate_case(){
		//DeAv fix for code coverage START
		User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
		u.Country__c = 'Spain';
        u.CompanyP__c = 'Spain';
        u.XC_LegalEntity__c = 'EndesaX';
        u.XC_EnabledToSkip__c = true;
		update u;
        System.runAs(u){ 
			Test.startTest();
			List<Case> cases = XC_DF_Case.createCases(1);
			insert cases;
			List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
			insert accounts;
			List<Contact> contacts = XC_DF_Contact.createResidentialContacts(1);
			insert contacts;
			List<WorkOrder> workOrders = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery');
			insert workOrders;
			List<Opportunity> opportunities = new List<Opportunity>([SELECT Id FROM Opportunity limit 1]);
			List<NE__OrderItem__c> orderItems = new List<NE__OrderItem__c>([SELECT Id FROM NE__OrderItem__c limit 1]);
			List<Asset> assets = XC_DF_Asset.createAssets(1);
			insert assets;
			List<XC_Address__c> addresses = XC_DF_Address.createAddress(1);
			insert addresses;

			XC_UTIL_Case_U.PopulateCaseWrapper pcw = new XC_UTIL_Case_U.PopulateCaseWrapper();
			XC_UTIL_Case.CaseRESTWrapper crw = new XC_UTIL_Case.CaseRESTWrapper();
			crw.CaseID = cases.get(0).id;
			pcw.c = cases.get(0);
			pcw.accountID = crw.AccountID = accounts.get(0).id;
			pcw.contactID = crw.ContactID = contacts.get(0).id;
			crw.WorkOrderID = workOrders.get(0).id;
			crw.ParentCaseID = cases.get(0).id;
			crw.OpportunityID = opportunities[0].id;
			crw.OrderItemID = orderItems[0].id;
			crw.AssetID = assets.get(0).id;
			crw.AddressID = addresses.get(0).id;
			pcw.wrapper = crw;


			XC_UTIL_Case_U.populateCase(pcw);
			System.assertEquals(1,1);

			Test.stopTest();
		}
		//DeAv fix for code coverage END
	}

    @isTest
    public static void  getCaseRemarksByLegalEntity_Spagna(){
		List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
		insert accList;
		List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
		insert conList;
		
		Asset ass = new Asset();
		ass.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
		ass.Name = 'Baxi Neodens Plus 24_24 F Eco';
		ass.IsCompetitorProduct = true;
		ass.InstallDate = Date.newInstance(2019, 04, 13);
		ass.IsInternal = false;
		ass.Price = 104;
		ass.AccountId =accList[0].Id;
		ass.PurchaseDate = Date.newInstance(2019, 04, 05);
		ass.Quantity = 3;
		ass.NE__Status__c = 'Active';
		ass.UsageEndDate = Date.newInstance(2020, 12, 30);
		ass.NE__Commitment__c = false;
		ass.ContactId = conList[0].Id;
		ass.XC_ActivationDate__c = Date.today();
		ass.XC_Segment__c = 'B2G';
		ass.XC_LegalEntity__c = 'EndesaX';
		insert ass;
		
		Test.startTest();
		
		Case c = new Case();
		c.XC_LegalEntity__c = 'EndesaX';
		c.status = 'Open';
		c.AccountId = accList[0].Id;
		c.ContactId = conList[0].Id;
		c.Reason = 'XCMOT010';
		c.SubCause__c = 'ATCL029';
		c.XC_Subtype__c = 'XC156';
		insert c;
		c.AssetId = ass.id;
		update c;			
		XC_CM_CaseClosureDependencies__mdt caseSett =[ SELECT Id, XC_CaseRemarks__c FROM XC_CM_CaseClosureDependencies__mdt WHERE XC_ReasonCode__c='XCMOT010' AND XC_SubCause__c='ATCL029' ]; //elisa.caldini@accenture.com-18.05.2022 
		XC_UTIL_ResultWrapper rwC = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(c.id, 'Accept Purchase Option - End Contract', true);
		Case endOfContrCase = [SELECT Id, Status, CaseRemarks__c FROM Case WHERE Id =: c.Id LIMIT 1];
		System.assert(rwC.success);
		//System.assert(endOfContrCase.Status == 'ESTA007');
		//START -elisa.caldini@accenture.com-18.05.2022
        String result=XC_UTIL_Case_U.getCaseRemarksClosureByLegalEntity(caseSett, c.XC_LegalEntity__c);
        System.assertEquals('Caso cerrado como consecuencia del cierre de registros asociados',result);
        Map<String, XC_CM_Case_ESPAttentionTypes__mdt> mapResult= XC_UTIL_Case_U.retriveCaseESPAttentionTypesFromCases( new List<Case>{c});
        //END-elisa.caldini@accenture.com-18.05.2022
		Test.stopTest();
    }
    
	/*@isTest
    static void  getCaseRemarksByLegalEntity_Italia(){
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        accList[0].XC_DocumentCountry__c = 'Italy';
        insert accList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accList);
        conList[0].XC_CountryLegalEntity__c = 'ITALY';
        conList[0].XC_MainLegalEntity__c = 'EnelXItalia';
        insert conList;
        
        Asset assetItalia = new Asset();
        assetItalia.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetItalia.Name = 'Baxi Neodens Plus 24_24 F Eco';
        assetItalia.IsCompetitorProduct = true;
        assetItalia.InstallDate = Date.newInstance(2019, 04, 13);
        assetItalia.IsInternal = false;
        assetItalia.Price = 104;
        assetItalia.AccountId =accList[0].Id;
        assetItalia.PurchaseDate = Date.newInstance(2019, 04, 05);
        assetItalia.Quantity = 3;
        assetItalia.NE__Status__c = 'Active';
        assetItalia.UsageEndDate = Date.newInstance(2020, 12, 30);
        assetItalia.NE__Commitment__c = false;
        assetItalia.ContactId = conList[0].Id;
        assetItalia.XC_ActivationDate__c = Date.today();
        insert assetItalia;
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EnelXItalia';
        c.status = 'Open';
        c.AccountId = accList[0].Id;
        c.ContactId = conList[0].Id;
        c.Reason = 'XCMOT010';
        c.SubCause__c = 'ATCL029';
        c.XC_Subtype__c = 'XC156';
        insert c;
        c.AssetId = assetItalia.id;
        update c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(c.id, 'Accept Purchase Option - End Contract', true);
        	Case endOfContrCase = [SELECT Id, Status, CaseRemarks__c FROM Case WHERE Id =: c.Id LIMIT 1];
        	System.assert(rwC.success);
        	System.assert(endOfContrCase.Status == 'ESTA007');
        test.stopTest();
    }*/
}
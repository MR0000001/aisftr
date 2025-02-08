/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC073_DisconnectAsset_TEST test class for XC_LCC073_DisconnectAsset 
*/  
@isTest
public class XC_LCC073_DisconnectAsset_TEST {
    
    /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  TestSetup method
*/
    @TestSetup
    static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
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
        //assetToInsert.SerialNumber = '1ADG45R';
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
         //c.AssetId = assetToInsert.id;
        insert c;
        // c.ContactId = conList[0].id;
         c.AssetId = assetToInsert.id;
        update c;
        
    }
    
    
    
    
    static testMethod void test3(){       
        
        Test.startTest();
        List<Case> a = [SELECT Id,AssetId, Asset.RecordTypeId FROM Case where AssetId != null LIMIT 1];
        String recordId = a[0].Id;
       
         XC_UTIL_ResultWrapper rw =  XC_LCC073_DisconnectAsset.disconnectAssetFromCase(recordId, 'Substitution (Malfunction)', false);
        System.assert(rw!=null);
        test.stopTest();
        
    }
    
     static testMethod void testSoho(){       
        List<Account> accList = XC_DF_Account.createSohoAccounts(1);
        Test.startTest();
        XC_UTIL_ChangeOrder.ckeckIfValidSoho('XC_GLO_Account_Soho', 'Public Administration'); 
        System.assert(accList!=null);
        test.stopTest();
        
    }
    
    
    static testMethod void test4(){     
        
        Test.startTest();
        List<Case> a = [SELECT Id, AssetId, Asset.RecordTypeId FROM Case where AssetId != null LIMIT 1];
        String recordId = a[0].Id;
        
          XC_UTIL_ResultWrapper rw = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(recordId, 'Substitution (Malfunction)', false);
         System.assert(rw!=null);
        test.stopTest();
        
    }
    
    
    static testMethod void test4AssetInError(){
        
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        asset.NE__Order_Config__c = null;
        update asset;
        
        Test.startTest();
        List<Case> a = [SELECT Id, AssetId, Asset.RecordTypeId FROM Case where AssetId != null LIMIT 1];
        String recordId = a[0].Id;
        
          XC_UTIL_ResultWrapper rw = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(recordId, 'Substitution (Malfunction)', false);
         System.assert(rw!=null);
        test.stopTest();
        
    }
    
    static testMethod void test5(){       
        
        Test.startTest();
        List<Asset> a = [SELECT Id FROM Asset LIMIT 1];
        a[0].NE__Order_Config__c = null;
        update a[0];
       
          //XC_UTIL_ResultWrapper rw = XC_LCC073_DisconnectAsset.disconnectAsset(a[0].id , 'Substitution (Malfunction)'  );
         //System.assert(rw!=null);
        test.stopTest();
        
    }
    
   
    
   /* static testMethod void test6(){      
       
        Test.startTest();
        List<Asset> a = [SELECT Id FROM Asset LIMIT 1];
        a[0].NE__Status__c = Label.XC_CL_Asset_InProgress;
        update a[0];
       
          //XC_UTIL_ResultWrapper rw = XC_LCC073_DisconnectAsset.changeOrderAsset(a[0].id , 'Substitution (Malfunction)'  );
         //System.assert(rw!=null);
        test.stopTest();
        
    }*/
     
    static testMethod void test7() {   
        
        Test.startTest();
        List<Case> a = [SELECT Id FROM Case LIMIT 1];
        
        XC_UTIL_ResultWrapper rw =XC_LCC073_DisconnectAsset.populateSubtype(a[0].id,'Disconnect');
         //System.assert(rw.success);
        test.stopTest();
        
    }


    @isTest
    static void test_populateSubtypeCO(){   
       
        Test.startTest();
        List<Case> a = [SELECT Id FROM Case LIMIT 1];
        
        XC_UTIL_ResultWrapper rw =XC_LCC073_DisconnectAsset.populateSubtype(a[0].id,'ChangeOrder');
         //System.assert(rw.success);
        test.stopTest();
        
    }

    
    @isTest
    static void test_populateSubtypeCO_AssetActive(){ 
        List<NE__Bundle__c> blist = [SELECT Id FROM NE__Bundle__c];
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        NE__OrderItem__c item = [SELECT Id FROM NE__OrderItem__c][0];
        
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
        NE__Order__c order = [SELECT Id FROM NE__Order__c];
        assetToInsert.NE__Order_Config__c = order.id;
        assetToInsert.XC_Configuration_Item__c= item.id;
        assetToInsert.NE__Bundle__c = blist[0].id;
        //assetToInsert.SerialNumber = '1ADG45R';
        assetToInsert.NE__Status__c = 'Purchased';
        assetToInsert.Status = 'Active';
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
         //c.AssetId = assetToInsert.id;
        insert c;
        // c.ContactId = conList[0].id;
         c.AssetId = assetToInsert.id;
        update c;
       
        Test.startTest();
        
        XC_UTIL_ResultWrapper rw =XC_LCC073_DisconnectAsset.populateSubtype(c.id,'ChangeOrder');
         //System.assert(rw.success);
        test.stopTest();
        
    }


      @isTest
    static void test_populateSubtypeCO_ChangeOfOwnership(){ 
        List<NE__Bundle__c> blist = [SELECT Id FROM NE__Bundle__c];
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        NE__OrderItem__c item = [SELECT Id FROM NE__OrderItem__c][0];
        
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
        NE__Order__c order = [SELECT Id FROM NE__Order__c];
        assetToInsert.NE__Order_Config__c = order.id;
        assetToInsert.XC_Configuration_Item__c= item.id;
        assetToInsert.NE__Bundle__c = blist[0].id;
        //assetToInsert.SerialNumber = '1ADG45R';
        assetToInsert.NE__Status__c = 'Purchased';
        assetToInsert.Status = 'Active';
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
        c.Reason = 'XCMOT008';
        c.SubCause__c = 'ATCL060';
         //c.AssetId = assetToInsert.id;
        insert c;
        // c.ContactId = conList[0].id;
         c.AssetId = assetToInsert.id;
        update c;
       
        Test.startTest();
        XC_LCC073_DisconnectAsset_D.getAsset(assetToInsert.Id);
        XC_UTIL_ResultWrapper rw =XC_LCC073_DisconnectAsset.populateSubtype(c.id,'ChangeOrder');
         //System.assert(rw.success);
        test.stopTest();
        
    }
     

    static testMethod void test9(){       
      
        Test.startTest();
        List<Case> a = [SELECT Id FROM Case LIMIT 1];
        XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper wrapper = new XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper();
        wrapper.caso = a[0];
        XC_UTIL_ResultWrapper rw = XC_LCC073_DisconnectAsset.checkPenalityBeforeDisconnectCase(wrapper);
        System.assert(rw!=null);
        test.stopTest();
        
    }
    
     /* static testMethod void test11(){      
      
        Test.startTest();
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        Asset assetToInsert = new Asset();
        assetToInsert.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetToInsert.Name = 'Baxi Neodens Plus 24_24 F Eco';
        assetToInsert.IsCompetitorProduct = true;
        assetToInsert.InstallDate = Date.newInstance(2019, 04, 13);
        assetToInsert.IsInternal = false;
        assetToInsert.Price = 104;
        assetToInsert.AccountId =accList[0].id;
        assetToInsert.PurchaseDate = Date.newInstance(2019, 04, 05);
        assetToInsert.Quantity = 3;
       
        assetToInsert.NE__Status__c = 'Active';
        assetToInsert.UsageEndDate = Date.newInstance(2020, 12, 30);
        assetToInsert.NE__Commitment__c = false;
      
        assetToInsert.XC_ActivationDate__c = Date.today();
        insert assetToInsert;
        
        //XC_UTIL_ResultWrapper rw = XC_LCC073_DisconnectAsset.checkPenalityBeforeDisconnect(assetToInsert.id);
        System.assert(rw !=null);
        test.stopTest();
        
    }*/
        
     static testMethod void test12(){
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT008';
        c.SubCause__c = 'ATCL060';
        insert c;
        c.AssetId = ass.id;
        update c;
      
        Test.startTest();
        NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
        XC_UTIL_ResultWrapper rw = XC_LCC073_U_DisconnectAsset.manageIdOrder(ord.id, 'Substitution', c.Id);
        System.assert(rw !=null);
        test.stopTest();
    }
    
    @isTest
    static void callOperationfromCaseWithoutAsset(){
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        Case caso = new Case();        
        caso.XC_LegalEntity__c = 'EndesaX';
        caso.status = 'Open';
        caso.AccountId = acc[0].Id;
        caso.ContactId = cont[0].Id;
        caso.Reason = 'XCMOT009';
        insert caso;
       
        Test.startTest();
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.populateSubtype(caso.id,'ChangeOrder');
            XC_UTIL_ResultWrapper rwD =XC_LCC073_DisconnectAsset.populateSubtype(caso.id,'Disconnect');
        	System.assert(!rwC.success && !rwD.success);
        test.stopTest();
    }
    
    @isTest
    static void callOperationfromCaseClosed(){
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        Case caso = new Case();        
        caso.XC_LegalEntity__c = 'EndesaX';
        caso.status = 'Open';
        caso.AccountId = acc[0].Id;
        caso.ContactId = cont[0].Id;
        caso.Reason = 'XCMOT009';
        insert caso;
        
        caso.XC_Resolution__c = 'R001';
        caso.XC_Result__c = 'RS003';
        caso.CaseRemarks__c = 'chiusura';
        update caso;
       
        Test.startTest();
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.populateSubtype(caso.id,'ChangeOrder');
            XC_UTIL_ResultWrapper rwD =XC_LCC073_DisconnectAsset.populateSubtype(caso.id,'Disconnect');
        	System.assert(!rwC.success && !rwD.success);
        test.stopTest();
    }
    
    @isTest
    static void checkOrderSubtypeBeaforeChangeOrder_withoutAsset(){
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        
        Case caso = new Case();        
        caso.XC_LegalEntity__c = 'EndesaX';
        caso.status = 'Open';
        caso.AccountId = acc[0].Id;
        caso.ContactId = cont[0].Id;
        caso.Reason = 'XCMOT009';
        insert caso;
       
        Test.startTest();
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeChangeOrder(caso,'test','ChangeOrder');
        	System.assert(!rwC.success);
        test.stopTest();
    }
    
    @isTest
    static void checkOrderSubtypeBeaforeChangeOrder_withAsset(){
        
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
        
        Case caso = new Case();        
        caso.XC_LegalEntity__c = 'EndesaX';
        caso.status = 'Open';
        caso.AccountId = opp[0].AccountId;
        caso.ContactId = opp[0].XC_Contact__c;
        caso.Reason = 'XCMOT009';
        insert caso;
        caso.AssetId = ass.id;
        update caso;
       
        Test.startTest();
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeChangeOrder(caso,'test','ChangeOrder');
        	System.assert(!rwC.success);
        test.stopTest();
    }
    
    @isTest
    static void checkOrderSubtypeBeaforeOperation_ScheduleDeactivation(){
        
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT009';
        c.SubCause__c = 'ATCL040';
        insert c;
        c.AssetId = ass.id;
        update c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(c, Label.XC_CL_OrdersubTypeValue_ScheduleDeactivation, 'Disconnect');
        	System.assert(rwC.success);
        test.stopTest();
    }
    
    @isTest
    static void  changeOrderAssetFromCase_skipOrderCreation(){
        
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT010';
        c.SubCause__c = 'ATCL029';
        c.XC_Subtype__c = 'XC156';
        insert c;
        c.AssetId = ass.id;
        update c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(c.id, 'Accept Purchase Option - End Contract', true);
        	Case endOfContrCase = [SELECT Id, Status FROM Case WHERE Id =: c.Id LIMIT 1];
        	System.assert(rwC.success);
        	System.assert(endOfContrCase.Status == 'ESTA007');
        test.stopTest();
    }
    
    @isTest
    static void  changeOrderAssetFromCase_skipOrderCreation_mtdNull(){
        
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT009';
        c.SubCause__c = 'ATCL040';
        insert c;
        c.AssetId = ass.id;
        update c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(c.id, Label.XC_CL_OrdersubTypeValue_ScheduleDeactivation, true);
        	System.assert(rwC.success);
        test.stopTest();
    }
    @isTest
    public static void disconnectAssetTest_WithComplaintBadSale(){
      List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset]);
       List<Case> caseTest = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c,Origin FROM Case WHERE AssetId =:assetTest[0].id LIMIT 1]); 
        caseTest[0].ContactId = assetTest[0].ContactId;
        caseTest[0].AccountId = assetTest[0].AccountId; 
        update caseTest;
         Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ComplaintBadSale_CaseSettings});
        Case complCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings));
        complCase.AssetId = assetTest[0].id;
        complCase.ContactId = assetTest[0].ContactId;
        complCase.AccountId = assetTest[0].AccountId;
        complCase.SuppliedName = 'complCase';
        complCase.SubCause__c = 'ATCL069';
        complCase.XC_LegalEntity__c = 'EndesaX';
        complCase.XC_Segment__c = 'B2C';
        insert complCase;
        complCase.XC_Resolution__c = 'R133';
        complCase.XC_Result__c = Label.XC_CL_Case_Result001;
        complCase.CaseRemarks__c = 'test chiusura';
        complCase.Status = Label.XC_CL_Case_Status007;
        complCase.XC_SubType__c = 'XC014';
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.XC_Channel_Attribute__c = 'CA001';
        update complCase;
        List<Case> readComplCase = new List<Case>([SELECT Id, Reason, SubCause__c, Status, XC_Result__c, AssetId,Origin  FROM Case WHERE SuppliedName = 'complCase' LIMIT 1]);
      test.startTest();
        String orderSubtype = 'Claim';
        XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
       orderSubtype = 'Bad referral';
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
        orderSubType='Claim not applicable';
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
        orderSubtype = 'Claim applicable (service not used)';
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
        System.assertNotEquals(wrapper, null);     
        test.stopTest();
    }
    @isTest
    public static void disconnectAssetFromCase(){
     List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset]);
       List<Case> caseTestWithAsset = [SELECT Id,AssetId, Asset.RecordTypeId FROM Case where AssetId != null LIMIT 1];
       List<Case> caseTest=XC_DF_Case.createCases(1);
       caseTest[0].XC_LegalEntity__c = 'EndesaX';
       caseTest[0].XC_Segment__c = 'B2C';
        insert caseTest;
        list<case> caseList=[select id,AssetId from case where AssetId=null];
        String recordId = caseList[0].Id;
        String recordId2=caseTestWithAsset[0].id;
        test.startTest();
        XC_UTIL_ResultWrapper rw =  XC_LCC073_DisconnectAsset.disconnectAssetFromCase(recordId, 'Substitution (Malfunction)', false);
        XC_UTIL_ResultWrapper rw2=XC_LCC073_DisconnectAsset.disconnectAssetFromCase(recordId2, 'Substitution (Malfunction)', true);
        test.stopTest();    
    }
    @isTest
    public static void disconnectAssetTest_WithComplaintBadSaleNocomplCaseData(){
        List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset]);
       List<Case> caseTest = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c,Origin FROM Case WHERE AssetId =:assetTest[0].id LIMIT 1]); 
        caseTest[0].ContactId = assetTest[0].ContactId;
        caseTest[0].AccountId = assetTest[0].AccountId; 
        update caseTest;
        test.startTest();
         String orderSubtype='Claim applicable (service not used)';
    XC_UTIL_ResultWrapper  wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
      test.stopTest();
    }
    
    @isTest
    public  static void  checkOrderSubtypeBeaforeOperationChangeOrder(){
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT009';
        c.SubCause__c = 'ATCL040';
        insert c;
        c.AssetId = ass.id;
        update c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(c, Label.XC_CL_OrdersubTypeValue_ScheduleDeactivation, 'ChangeOrder');
        test.stopTest();
    } 
    
    @isTest
    public  static void  checkOrderSubtypeBeaforeOperation_Complaint(){
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT009';
        c.SubCause__c = 'ATCL040';
        c.XC_Type_Intermediary__c = 'TI002';
        c.AssetId = ass.id;
        insert c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC1 =XC_LCC073_DisconnectAsset.checkCallRecordingNeeded(c.Id);
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(c, Label.XC_CL_OrdersubTypeValue_Complaint, 'ChangeOrder');
        test.stopTest();
    }
    
    @isTest
    public  static void  checkOrderSubtypeBeaforeOperation_ChangeOfOwnership(){
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT009';
        c.SubCause__c = 'ATCL040';
        c.XC_Type_Intermediary__c = 'TI002';
        c.AssetId = ass.id;
        insert c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC1 =XC_LCC073_DisconnectAsset.checkCallRecordingNeeded(c.Id);
            XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(c, Label.XC_CL_ChangeOfOwnership, 'ChangeOrder');
        test.stopTest();
    }
    
    @isTest
    public  static void  checkCallRecordingNeeded(){
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
        XC_CTI_Interaction__c ctiInt = new XC_CTI_Interaction__c();
        insert ctiInt;
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT009';
        c.SubCause__c = 'ATCL040';
        c.XC_Type_Intermediary__c = 'TI002';
        c.AssetId = ass.id;
        c.XC_CTI_Interaction__c = ctiInt.Id;
        insert c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC1 =XC_LCC073_DisconnectAsset.checkCallRecordingNeeded(c.Id);
        test.stopTest();
    } 
    
    @isTest
    static void  changeOrderAssetFromCase_CaseRemarksSpagna(){
        
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT010';
        c.SubCause__c = 'ATCL029';
        c.XC_Subtype__c = 'XC156';
        insert c;
        c.AssetId = ass.id;
        update c;
        
        Test.startTest();
            XC_UTIL_ResultWrapper rwC = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(c.id, 'Accept Purchase Option - End Contract', true);
        	Case endOfContrCase = [SELECT Id, Status, CaseRemarks__c FROM Case WHERE Id =: c.Id LIMIT 1];
        	System.assert(rwC.success);
        	System.assert(endOfContrCase.Status == 'ESTA007');
        test.stopTest();
    }
    
    /*@isTest
    static void  changeOrderAssetFromCase_skipOrderCreation_CaseRemarksItalia(){
        
        /*List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];*/
        
        /*List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
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
        //assetItalia.NE__Order_Config__c = order.id;
        //assetItalia.XC_Configuration_Item__c= item.id;
        //assetItalia.NE__Bundle__c = blist[0].id;
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

    @isTest
    static void  testCheckIsToBlock(){
        Test.startTest();
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
         
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT008';
        c.SubCause__c = 'ATCL060';
        c.AssetId = ass.id;
        insert c;
        Case caseCompl = new Case();
        caseCompl.XC_LegalEntity__c = 'EndesaX';
        caseCompl.status = 'ESTA001';
        caseCompl.AccountId = opp[0].AccountId;
        caseCompl.ContactId = opp[0].XC_Contact__c;
        caseCompl.Reason = 'XCMOT005';
        caseCompl.SubCause__c = 'ATCL030';
        caseCompl.XC_Type_Intermediary__c = 'TI004';
        caseCompl.AssetId = ass.id;
        insert caseCompl;
        update ass;
        XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(c, Label.XC_CL_ChangeOfOwnership, 'ChangeOrder');
        System.assertEquals(false, rwC.success, 'ERROR');
        System.assertEquals('Action not allowed, pending activities in progress', rwC.resultMessage, 'ERROR');
        test.stopTest();
    }

    @isTest
    static void  testCheckIsToBlock2(){
        Test.startTest();
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
        Case caseCompl = new Case();
        caseCompl.XC_LegalEntity__c = 'EndesaX';
        caseCompl.status = 'ESTA001';
        caseCompl.AccountId = opp[0].AccountId;
        caseCompl.ContactId = opp[0].XC_Contact__c;
        caseCompl.Reason = 'XCMOT005';
        caseCompl.SubCause__c = 'ATCL030';
        caseCompl.XC_Type_Intermediary__c = 'TI004';
        caseCompl.AssetId = ass.id;
        insert caseCompl;
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'ESTA001';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT008';
        c.SubCause__c = 'ATCL060';
        c.AssetId = ass.id;
        Case retrCase =[SELECT Id, CaseNumber FROM Case LIMIT 1];
        c.Description=':['+retrCase.CaseNumber+'].';
        insert c;
        update ass;
        XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(c, Label.XC_CL_ChangeOfOwnership, 'ChangeOrder');
        System.assertEquals(false, rwC.success, 'ERROR');
        System.assertEquals('Action not allowed, pending activities in progress', rwC.resultMessage, 'ERROR');
        test.stopTest();
    }
    @isTest
    static void  testCheckIsToBlock3(){
        Test.startTest();
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
        Case caseInfo = new Case();
        caseInfo.XC_LegalEntity__c = 'EndesaX';
        caseInfo.status = 'ESTA001';
        caseInfo.AccountId = opp[0].AccountId;
        caseInfo.ContactId = opp[0].XC_Contact__c;
        caseInfo.Reason = 'XCMOT001';
        caseInfo.SubCause__c = 'ATCL005';
        caseInfo.AssetId = ass.id;
        insert caseInfo;
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'ESTA001';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT008';
        c.SubCause__c = 'ATCL060';
        c.AssetId = ass.id;
        Case retrCase =[SELECT Id, CaseNumber FROM Case LIMIT 1];
        c.Description=':['+retrCase.CaseNumber+'].';
        insert c;
        update ass;
        XC_UTIL_ResultWrapper rwC =XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(c, Label.XC_CL_ChangeOfOwnership, 'ChangeOrder');
        System.assertEquals(true, rwC.success, 'ERROR');
        System.assertEquals('Change of ownership', rwC.resultMessage, 'ERROR');
        test.stopTest();
    }
        @isTest
    static void  testCheckIsToBlock4(){
        Test.startTest();
        List<Opportunity> opp = [SELECT Id,AccountId,XC_Contact__c FROM Opportunity];
        //Asset ass = [SELECT Id FROM Asset LIMIT 1];
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
        //assetToInsert.SerialNumber = '1ADG45R';
        assetToInsert.NE__Status__c = 'Purchased';
        assetToInsert.Status = 'Active';
        assetToInsert.UsageEndDate = Date.newInstance(2020, 12, 30);
        assetToInsert.NE__Commitment__c = false;
        assetToInsert.XC_ActivationDate__c = Date.today();
        insert assetToInsert;
      	Case c = new Case();
        c.XC_LegalEntity__c = 'EndesaX';
        c.status = 'Open';
        c.AccountId = opp[0].AccountId;
        c.ContactId = opp[0].XC_Contact__c;
        c.Reason = 'XCMOT005';
        c.SubCause__c = 'ATCL030';
        c.AssetId = assetToInsert.id;
        insert c;
        Case caseCompl = new Case();
        caseCompl.XC_LegalEntity__c = 'EndesaX';
        caseCompl.status = 'ESTA001';
        caseCompl.AccountId = opp[0].AccountId;
        caseCompl.ContactId = opp[0].XC_Contact__c;
        caseCompl.Reason = 'XCMOT005';
        caseCompl.SubCause__c = 'ATCL030';
        caseCompl.XC_Type_Intermediary__c = 'TI004';
        caseCompl.AssetId = assetToInsert.id;
        insert caseCompl;
        //update ass;
        XC_UTIL_ResultWrapper rwC =XC_UTIL_ChangeOrder.manageChangeOrder(c);
        System.assertEquals(true, rwC.success, 'ERROR');
        test.stopTest();
    }
}
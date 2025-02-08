/**
*@author Federico Melella - fmelella@deloitte.it
*@date Creation 06/02/2020
*@date Modification 10/02/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
*@description XC_LCC073_U_DisconnectAsset_TEST - Test class for XC_LCC073_U_DisconnectAsset
*/

@isTest
public class XC_LCC073_U_DisconnectAsset_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC073_U_DisconnectAsset_TEST');

    @TestSetup
    static void makeData() {
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<NE__Order__c> orders = XC_DF_Order.createOrders(3,'InOrder');
        orders[0].XC_Country__c = 'Spain';
        orders[0].XC_LegalEntity__c = 'EndesaX';
        orders[0].XC_Segment__c = 'B2C';
        orders[1].XC_Country__c = 'Spain';
        orders[1].XC_LegalEntity__c = 'EndesaX';
        orders[1].XC_Segment__c = 'B2C';
        orders[2].XC_Country__c = 'Spain';
        orders[2].XC_LegalEntity__c = 'EndesaX';
        orders[2].XC_Segment__c = 'B2C';        
        insert orders;
        
        NE__OrderItem__c item0 = XC_DF_OrderItem.createOrderItem(orders[0]);
        NE__OrderItem__c item1 = XC_DF_OrderItem.createOrderItem(orders[1]);
        NE__OrderItem__c item2 = XC_DF_OrderItem.createOrderItem(orders[2]);
        insert new List<NE__OrderItem__c>{item0,item1,item2};
        
        NE__order__c order = orders[0]; //XC_DF_Order.createOrder('InOrder');
        NE__order__c order2 = orders[1]; //XC_DF_Order.createOrder('InOrder');
        NE__order__c order3 = orders[2]; //XC_DF_Order.createOrder('InOrder');
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(3);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        Test.startTest();
        List<Asset> listAsset = XC_DF_Asset.createAssets(6);
        listAsset[0].Name = 'AssetDisco01';
        listAsset[0].NE__Status__c = 'Inactive';
        listAsset[0].AccountId = accountList[0].Id;
        listAsset[0].ContactId = contList[0].Id;
        listAsset[0].XC_LegalEntity__c = 'EndesaX';
        listAsset[0].XC_Segment__c = 'B2C';
        listAsset[1].Name = 'AssetDisco02';
        listAsset[1].XC_Product_Type__c = 'Coverage';
        listAsset[1].AccountId = accountList[0].Id;
        listAsset[1].ContactId = contList[0].Id;
        listAsset[1].XC_LegalEntity__c = 'EndesaX';
        listAsset[1].XC_Segment__c = 'B2C';
        listAsset[2].Name = 'AssetDisco03';
        listAsset[2].AccountId = accountList[0].Id;
        listAsset[2].ContactId = contList[0].Id;
        listAsset[2].XC_LegalEntity__c = 'EndesaX';
        listAsset[2].XC_Segment__c = 'B2C';
        listAsset[3].Name = 'AssetDisco04';
        listAsset[3].NE__Status__c = '';
        listAsset[3].NE__Order_Config__c = order.Id;
        listAsset[3].NE__Root_Order_Item__c = null;
        listAsset[3].AccountId = accountList[0].Id;
        listAsset[3].ContactId = contList[0].Id;
        listAsset[3].XC_LegalEntity__c = 'EndesaX';
        listAsset[3].XC_Segment__c = 'B2C';
        listAsset[4].Name = 'AssetDisco05';
        listAsset[4].NE__Status__c = 'Active';
        listAsset[4].NE__Status__c = '';
        listAsset[4].NE__Order_Config__c = order2.Id;
        listAsset[4].NE__Root_Order_Item__c = null;
        listAsset[4].AccountId = accountList[2].Id;
        listAsset[4].ContactId = contList[2].Id;
        listAsset[4].XC_LegalEntity__c = 'EndesaX';
        listAsset[4].XC_Segment__c = 'B2C';
        listAsset[5].Name = 'AssetDisco06';
        listAsset[5].NE__Status__c = 'Active';
        listAsset[5].NE__Order_Config__c = order3.Id;
        listAsset[5].NE__Root_Order_Item__c = null;
        listAsset[5].AccountId = accountList[1].Id;
        listAsset[5].ContactId = contList[1].Id;
        listAsset[5].XC_LegalEntity__c = 'EndesaX';
        listAsset[5].XC_Segment__c = 'B2C';
        insert listAsset;
        List<Case> c = XC_DF_Case.createCases(3);
        c[0].SuppliedName = 'Case01';
        c[0].XC_LegalEntity__c = 'EndesaX';
        c[0].XC_Segment__c = 'B2C';
        c[1].SuppliedName = 'Case02';
        c[1].XC_LegalEntity__c = 'EndesaX';
        c[1].XC_Segment__c = 'B2C';
        c[2].SuppliedName = 'Case03';   
        c[2].XC_LegalEntity__c = 'EndesaX';
        c[2].XC_Segment__c = 'B2C'; 
        insert c;
        Test.stopTest();
    }

    @isTest
    public static void disconnectAssetTest() {
        List<Asset> assetTest = new List<Asset>([SELECT Id FROM Asset WHERE Name LIKE 'AssetDisco%']);
        List<Case> caseTest = new List<Case>([SELECT Id,Origin FROM Case WHERE SuppliedName = 'Case01' LIMIT 1]);
        String orderSubtype = '';
        // test status asset inactive
        Test.startTest();
        
        // status empty, order_config not null, root_order_item null
        // else branch: private method, orderSubtype claim
        orderSubtype = 'Claim';
        XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[3].id, orderSubtype, caseTest[0]);
        // else branch: private method, orderSubtype claim not applicable
        orderSubtype = 'Claim not applicable';
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[3].id, orderSubtype, caseTest[0]);
        // else branch: private method, orderSubtype bad referral
        orderSubtype = 'Bad referral';
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[3].id, orderSubtype, caseTest[0]);
        System.assertNotEquals(wrapper, null);
        Test.stopTest();
    }
    
    @isTest
    public static void disconnectAssetTest2() {
        List<Asset> assetTest = new List<Asset>([SELECT Id FROM Asset WHERE Name LIKE 'AssetDisco%']);
        List<Case> caseTest = new List<Case>([SELECT Id FROM Case WHERE SuppliedName = 'Case01' LIMIT 1]);
        String orderSubtype = '';
        // test status asset inactive
        Test.startTest();
        XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
        // test product type asset coverage
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[1].id, orderSubtype, caseTest[0]);
        // test big or branch
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[2].id, orderSubtype, caseTest[0]);
        test.stopTest();
    }
    
    @isTest
    public static void changeOrderAsset(){
        List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset WHERE Name = 'AssetDisco06']);
        List<Case> caseTest = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c FROM Case WHERE SuppliedName = 'Case03' LIMIT 1]);
        caseTest[0].AssetId = assetTest[0].id;
        caseTest[0].ContactId = assetTest[0].ContactId;
        caseTest[0].AccountId = assetTest[0].AccountId;
        caseTest[0].Reason = 'XCMOT008';
        caseTest[0].SubCause__c = 'ATCL073';
        caseTest[0].XC_Subtype__c = 'XC109';
        update caseTest;
        
        
        List<Asset> assetTest2 = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset WHERE Name = 'AssetDisco03']);
        assetTest[0].NE__Status__c = 'Active';        
        assetTest[0].NE__Root_Order_Item__c = assetTest2[0].Id;
        update assetTest;
        Test.startTest();
        XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.changeOrderAsset(assetTest[0].id, 'Change of coverage', caseTest[0].id);
        System.assertNotEquals(wrapper, null);
        
        assetTest[0].NE__Root_Order_Item__c = null;
        assetTest[0].NE__Order_Config__c = null;
        update assetTest;
        wrapper = XC_LCC073_U_DisconnectAsset.changeOrderAsset(assetTest[0].id, 'Change of coverage', caseTest[0].id);
        System.assertNotEquals(wrapper, null);
        Test.stopTest();
    }
    @isTest
    public static void changeOrderAsset2(){
        List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset WHERE Name = 'AssetDisco06']);
        List<Case> caseTest = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c FROM Case WHERE SuppliedName = 'Case03' LIMIT 1]);
        caseTest[0].AssetId = assetTest[0].id;
        caseTest[0].ContactId = assetTest[0].ContactId;
        caseTest[0].AccountId = assetTest[0].AccountId;
        caseTest[0].Reason = 'XCMOT008';
        caseTest[0].SubCause__c = 'ATCL073';
        caseTest[0].XC_Subtype__c = 'XC109';
        update caseTest;
        
        XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.changeOrderAsset(assetTest[0].id, 'Change of coverage', caseTest[0].id);
        System.assertNotEquals(wrapper, null);
        
        assetTest[0].NE__Status__c = Label.XC_CL_Asset_Disconnected;
        update assetTest;
        Test.startTest();
        wrapper = XC_LCC073_U_DisconnectAsset.changeOrderAsset(assetTest[0].id, 'Change of coverage', caseTest[0].id);
        System.assertNotEquals(wrapper, null);
        
        assetTest[0].NE__Status__c = Label.XC_CL_Asset_InProgress;
        update assetTest;
        wrapper = XC_LCC073_U_DisconnectAsset.changeOrderAsset(assetTest[0].id, 'Change of coverage', caseTest[0].id);
        System.assertNotEquals(wrapper, null);
        Test.stopTest();
    }

    @isTest
    public static void disconnectAssetTest_WithComplaintBadSale() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        Test.startTest();
        List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset WHERE Name = 'AssetDisco05']);
        assetTest[0].AccountId = accountList[0].Id;
        assetTest[0].ContactId = contList[0].Id;
        assetTest[0].XC_LegalEntity__c = 'EndesaX';
        update assetTest;
        
        
        List<Case> casesToupdate = new List<Case>();
        List<Case> caseTest = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c,Origin FROM Case WHERE SuppliedName = 'Case02' LIMIT 1]);
        caseTest[0].AssetId = assetTest[0].id;
        caseTest[0].ContactId = assetTest[0].ContactId;
        caseTest[0].AccountId = assetTest[0].AccountId;
        //update caseTest;
        casesToupdate.add(caseTest[0]);
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ComplaintBadSale_CaseSettings});
        Case complCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings));
        complCase.AssetId = assetTest[0].id;
        complCase.ContactId = assetTest[0].ContactId;
        complCase.AccountId = assetTest[0].AccountId;
        complCase.SuppliedName = 'complCase';
        complCase.SubCause__c = 'ATCL069';
        complCase.XC_SubType__c = 'XC066';
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.XC_Channel_Attribute__c = 'CA001';
        insert complCase;
        complCase.XC_Resolution__c = 'R133';
        complCase.XC_Result__c = Label.XC_CL_Case_Result001;
        complCase.CaseRemarks__c = 'test chiusura';
        complCase.Status = Label.XC_CL_Case_Status007;
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.XC_Channel_Attribute__c = 'CA001';
        //update complCase;
        casesToupdate.add(complCase);
        
        update casesToupdate;
        
        //List<Case> readComplCase = new List<Case>([SELECT Id, Reason, SubCause__c, Status, XC_Result__c, AssetId  FROM Case WHERE SuppliedName = 'complCase' LIMIT 1]);
        
        
            String orderSubtype = 'Claim applicable (service not used)';
            XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
            System.assertNotEquals(wrapper, null);
        test.stopTest();
    }

    @isTest
    public static void disconnectAssetTest_BadReferral_WithComplaintBadSale() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        Test.startTest();
        List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset WHERE Name = 'AssetDisco05']);
        assetTest[0].AccountId = accountList[0].Id;
        assetTest[0].ContactId = contList[0].Id;
        assetTest[0].XC_LegalEntity__c = 'EndesaX';
        update assetTest;
        
        List<Case> casesToupdate = new List<Case>();
        List<Case> caseTest = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c,Origin FROM Case WHERE SuppliedName = 'Case02' LIMIT 1]);
        caseTest[0].AssetId = assetTest[0].id;
        caseTest[0].ContactId = assetTest[0].ContactId;
        caseTest[0].AccountId = assetTest[0].AccountId;
        //update caseTest;
        casesToupdate.add(caseTest[0]);
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ComplaintBadSale_CaseSettings});
        Case complCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings));
        complCase.AssetId = assetTest[0].id;
        complCase.ContactId = assetTest[0].ContactId;
        complCase.AccountId = assetTest[0].AccountId;
        complCase.SuppliedName = 'complCase';
        complCase.SubCause__c = 'ATCL069';
        complCase.XC_SubType__c = 'XC066';
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.XC_Channel_Attribute__c = 'CA001';
        insert complCase;
        complCase.XC_Resolution__c = 'R133';
        complCase.XC_Result__c = Label.XC_CL_Case_Result001;
        complCase.CaseRemarks__c = 'test chiusura';
        complCase.Status = Label.XC_CL_Case_Status007;
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.XC_Channel_Attribute__c = 'CA001';
        //update complCase;
        casesToupdate.add(complCase);
        
        update casesToupdate;
        
        //List<Case> readComplCase = new List<Case>([SELECT Id, Reason, SubCause__c, Status, XC_Result__c, AssetId  FROM Case WHERE SuppliedName = 'complCase' LIMIT 1]);
        
        
            String orderSubtype = 'Bad referral';
            XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
            System.assertNotEquals(wrapper, null);
        test.stopTest();
    }
    
    @isTest
    public static void disconnectAssetTest_WithComplaintBadSale2() {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        insert contList;
        List<Asset> assetTest = new List<Asset>([SELECT Id, AccountId, ContactId FROM Asset WHERE Name = 'AssetDisco05']);
        assetTest[0].AccountId = accountList[0].Id;
        assetTest[0].ContactId = contList[0].Id;
        assetTest[0].XC_LegalEntity__c = 'EndesaX';
        update assetTest;
        Test.startTest();
        List<Case> caseTest = new List<Case>([SELECT Id, Reason, SubCause__c, XC_Subtype__c,Origin FROM Case WHERE SuppliedName = 'Case02' LIMIT 1]);
        caseTest[0].AssetId = assetTest[0].id;
        caseTest[0].ContactId = assetTest[0].ContactId;
        caseTest[0].AccountId = assetTest[0].AccountId;
        update caseTest;
        
        String orderSubtype = 'Claim';
        XC_UTIL_ResultWrapper wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
        System.assertNotEquals(wrapper, null);
        
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ComplaintBadSale_CaseSettings});
        Case complCase = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings));
        complCase.AssetId = assetTest[0].id;
        complCase.ContactId = assetTest[0].ContactId;
        complCase.AccountId = assetTest[0].AccountId;
        complCase.SuppliedName = 'complCase';
        complCase.SubCause__c = 'ATCL069';
        complCase.XC_SubType__c = 'XC066';
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.XC_Channel_Attribute__c = 'CA001';
        insert complCase;
        complCase.XC_Resolution__c = 'R133';
        complCase.XC_Result__c = Label.XC_CL_Case_Result001;
        complCase.CaseRemarks__c = 'test chiusura';
        complCase.Status = Label.XC_CL_Case_Status007;
        complCase.XC_Type_Intermediary__c = 'TI001';
        complCase.XC_Channel_Attribute__c = 'CA001';
        update complCase;
        
        //List<Case> readComplCase = new List<Case>([SELECT Id, Reason, SubCause__c, Status, XC_Result__c, AssetId,Origin  FROM Case WHERE SuppliedName = 'complCase' LIMIT 1]);
        
        wrapper = XC_LCC073_U_DisconnectAsset.disconnectAsset(assetTest[0].id, orderSubtype, caseTest[0]);
        System.assertNotEquals(wrapper, null);
        Test.stopTest();
    }

}
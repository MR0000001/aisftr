/**
* @author Edoardo Del Tosto, Leonardo Trinchieri - edoardo.del.tosto@accenture.com, leonardo.trinchieri@accenture.com
* @date Creation 13/10/2021
* @description  XC_TR_AffiliateBeneficiary_Test  – Test for XC_TR_AffiliateBeneficiary_Handler, XC XC_AffiliateBeneficiary_U and XC_TR_AffiliateBeneficiary
*/ 

@isTest
public with sharing class XC_TR_AffiliateBeneficiary_Test {

    @TestSetup

    public static void setup(){

        List<XC_AffiliateBeneficiaryConfiguration__c> listaAffBenconf = new List<XC_AffiliateBeneficiaryConfiguration__c>();

        XC_AffiliateBeneficiaryConfiguration__c conf = new XC_AffiliateBeneficiaryConfiguration__c();        
        conf.XC_ConfigurationType__c = 'Record Validation';
        conf.XC_RecordType__c = 'XC_Affiliate';
        conf.XC_ConfigurationCode__c = 'TestCode';
        conf.XC_ProductPlan__c = 'Basico';

        XC_AffiliateBeneficiaryConfiguration__c conf2 = new XC_AffiliateBeneficiaryConfiguration__c();
        conf2.XC_ConfigurationType__c = 'Record Validation';
        conf2.XC_RecordType__c = 'XC_Affiliate';
        conf2.XC_ConfigurationCode__c = 'TestCode2';
        conf2.XC_ProductPlan__c = 'Basico';

        conf2.XC_Relationship__c = 'Spouse';
        conf2.XC_MinAge__c = 144;
        conf2.XC_MaxAge__c = 228;

        listaAffBenconf.add(conf);
        listaAffBenconf.add(conf2);
        insert listaAffBenconf;

        List<NE__Order__c> listaOrder = XC_DF_Order.createOrders(2,'InOrder');
        Id ordRecTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        listaOrder[0].RecordTypeId = ordRecTypeId;
        listaOrder[0].XC_Status__c = 'Closed';
        listaOrder[0].NE__Type__c = 'InOrder';

        ListaOrder[1].RecordTypeId = ordRecTypeId;
        ListaOrder[1].XC_Status__c = 'In progress';
        listaOrder[1].NE__Type__c = 'InOrder';

        insert listaOrder;

        List<NE__OrderItem__c> listaOrderItem = XC_DF_OrderItem.createOrderItems(2);

        listaOrderItem[0].NE__OrderId__c = listaOrder[0].Id;
        listaOrderItem[0].NE__Qty__c = 123;

        listaOrderItem[1].NE__OrderId__c = listaOrder[1].Id;
        listaOrderItem[1].NE__Qty__c = 100;

        insert listaOrderItem;

        List<Asset> listaAsset = XC_DF_Asset.createAssets(2);
        listaAsset[0].Name = 'FirstTest';
        listaAsset[0].XC_Segment__c = 'B2C';

        listaAsset[1].Name = 'SecondTest';
        listaAsset[1].XC_Segment__c = 'B2C';
        listaAsset.get(1).NE__Order_Config__c = listaOrderItem[1].NE__OrderId__c;
        listaAsset[1].XC_Configuration_Item__c = listaOrderItem[1].Id;

        insert listaAsset;

        List<NE__AssetItemAttribute__c> listaAssetAttr = new List<NE__AssetItemAttribute__c>();
        NE__AssetItemAttribute__c assetAttr = new NE__AssetItemAttribute__c();

        assetAttr.Name = 'AffBen_Code';
        assetAttr.NE__Value__c = 'TestCode2';
        assetAttr.NE__Asset__c = listaAsset[1].id;

        NE__AssetItemAttribute__c assetAttr2 = new NE__AssetItemAttribute__c();

        assetAttr2.Name = 'Plan';
        assetAttr2.NE__Value__c = 'Basico';
        assetAttr2.NE__Asset__c = listaAsset[1].id;

        listaAssetAttr.add(assetAttr);
        listaAssetAttr.add(assetAttr2);

        insert listaAssetAttr;

        List<Contact> listaCon = XC_DF_Contact.createResidentialContacts(1);
        listaCon[0].XC_Segment__c = 'B2C';
        listaCon[0].AccountId = listaAsset[1].AccountId;
        insert listaCon;

        List<Case> listaCase = XC_DF_Case.createCases(1);
        listaCase[0].XC_LegalEntity__c = 'EndesaX';
        listaCase[0].AssetId =  listaAsset[1].Id;

    // listaCase[0].Reason =  XC_AffiliateBeneficiary_U.CASE_TYPIZATION.XC_CaseReason__c;

    // listaCase[0].SubCause__c =  XC_AffiliateBeneficiary_U.CASE_TYPIZATION.XC_SubCause__c;

        listaCase[0].Reason = 'XCMOT008';
        listaCase[0].SubCause__c = 'ATCL004';
        listaCase[0].AccountId = listaAsset[1].AccountId;
        listaCase[0].ContactId = listaCon[0].id;
        insert listaCase;
    }

 

    @isTest
    public static void insertRecord(){

        List<XC_Affiliate_Beneficiary__c> listaAffBen = new List<XC_Affiliate_Beneficiary__c>();
        List<NE__OrderItem__c> listaOrderItem = new List<NE__OrderItem__c>();
        List<Asset> listaAsset = new List<Asset>();      
        XC_Affiliate_Beneficiary__c affBen = new XC_Affiliate_Beneficiary__c();
        XC_Affiliate_Beneficiary__c affBen2 = new XC_Affiliate_Beneficiary__c();
        XC_Affiliate_Beneficiary__c affBenast = new XC_Affiliate_Beneficiary__c();
        XC_Affiliate_Beneficiary__c affBenast2 = new XC_Affiliate_Beneficiary__c();
        XC_Affiliate_Beneficiary__c affBen3 = new XC_Affiliate_Beneficiary__c();      
        XC_Affiliate_Beneficiary__c affBen4 = new XC_Affiliate_Beneficiary__c(); 

        Id aBRecTypeId = Schema.SObjectType.XC_Affiliate_Beneficiary__c.getRecordTypeInfosByName().get('Affiliate').getRecordTypeId();    

        listaOrderItem = [SELECT Id, NE__OrderId__c , NE__Qty__c, NE__Parent_Order_Item__c FROM NE__OrderItem__c /*WHERE NE__Qty__c IN (123,100) ORDER BY NE__Qty__c DESC*/ limit 2];

        listaAsset = [SELECT Id, XC_Segment__c, XC_Configuration_Item__c, AccountId FROM Asset WHERE XC_Segment__c = 'B2C' limit 2/*ORDER BY Name ASC*/];

        affBen.XC_OrderItem__c = listaOrderItem[0].Id;
        affBen.XC_Birthdate__c = Date.newInstance(2005, 10, 1);
        affBen.XC_FirstName__c = 'Mario';
        affBen.XC_LastName__c = 'Rossi';
        affBen.XC_Relationship__c = 'Sons';
        affBen.RecordTypeId = aBRecTypeId;

        affBen2.XC_OrderItem__c = listaOrderItem[1].Id;
        affBen2.XC_Birthdate__c = Date.newInstance(2002, 12, 3);
        affBen2.XC_FirstName__c = 'Giorgio';
        affBen2.XC_LastName__c = 'Bianchi';
        affBen2.XC_Relationship__c = 'Holder';  
        affBen2.RecordTypeId = aBRecTypeId;

        affBen3.XC_OrderItem__c = listaOrderItem[1].Id;
        affBen3.XC_Asset__c = listaAsset[1].Id;
        affBen3.XC_Birthdate__c = Date.newInstance(2002, 12, 3);
        affBen3.XC_FirstName__c = 'Gino';
        affBen3.XC_LastName__c = 'Verdi';
        affBen3.XC_Relationship__c = 'Holder'; 
        affBen3.RecordTypeId = aBRecTypeId; 

        affBen4.XC_OrderItem__c = listaAsset[1].XC_Configuration_Item__c;
        affBen4.XC_Birthdate__c = Date.newInstance(2000, 10, 3);
        affBen4.XC_FirstName__c = 'Giulio';
        affBen4.XC_LastName__c = 'Verde';
        affBen4.XC_Relationship__c = 'Holder'; 
        affBen4.RecordTypeId = aBRecTypeId; 

        affBenast.XC_Asset__c = listaAsset[0].Id;
        affBenast.XC_Birthdate__c = Date.newInstance(2012, 5, 3);
        affBenast.XC_FirstName__c = 'Luca';
        affBenast.XC_LastName__c = 'Rotti';
        affBenast.XC_Relationship__c = 'Holder';
        affBenast.RecordTypeId = aBRecTypeId;

        affBenast2.XC_Asset__c = listaAsset[1].Id;
        listaAsset[1].XC_Configuration_Item__c = listaOrderItem[1].Id;
        affBenast2.XC_BirthDate__c = Date.newInstance(2007, 12, 5);
        affBenast2.XC_FirstName__c = 'Giorgio';
        affBenast2.XC_LastName__c = 'Tosto';
        affBenast2.XC_Relationship__c = 'Spouse';
        affBenast2.RecordTypeId = aBRecTypeId;

        listaAffBen.add(affBenast);
        listaAffBen.add(affBenast2);
        listaAffBen.add(affBen);
        listaAffBen.add(affBen2);
        listaAffBen.add(affBen3);
        listaAffBen.add(affBen4);

        Test.startTest();
        insert listaAffBen;
        //XC_AffiliateBeneficiary_U.cloneAffBen(listaOrderItem);
        XC_AffiliateBeneficiary_U.associateAssetToAffBen(listaAsset);
        Test.stopTest();
    }

    @isTest

    public static void onBeforeUpdate(){
        Id aBRecTypeId = Schema.SObjectType.XC_Affiliate_Beneficiary__c.getRecordTypeInfosByName().get('Affiliate').getRecordTypeId();
        XC_Affiliate_Beneficiary__c affBen3 = new XC_Affiliate_Beneficiary__c();

        NE__OrderItem__c order1 = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
        affBen3.XC_OrderItem__c = order1.Id;
        affBen3.XC_Birthdate__c = Date.newInstance(2002, 12, 3);
        affBen3.XC_FirstName__c = 'Giorgio';
        affBen3.XC_LastName__c = 'Bianchi';
        affBen3.XC_Relationship__c = 'Holder';
        affBen3.RecordTypeId = aBRecTypeId;
        XC_Affiliate_Beneficiary__c affBen4 = new XC_Affiliate_Beneficiary__c();
        Asset ass1 = [SELECT Id FROM Asset WHERE Name = 'SecondTest' LIMIT 1];

        affBen4.XC_Asset__c = ass1.Id;
        affBen4.XC_BirthDate__c = Date.newInstance(2007, 12, 5);
        affBen4.XC_FirstName__c = 'Giorgio';
        affBen4.XC_LastName__c = 'Tosto';
        affBen4.XC_Relationship__c = 'Spouse'; 
        affBen4.RecordTypeId = aBRecTypeId; 

 
        List<XC_Affiliate_Beneficiary__c> listAff = new List<XC_Affiliate_Beneficiary__c>();
        listAff.add(affBen3);
        listAff.add(affBen4);

        Test.startTest();
        insert listAff;
        listAff.get(0).XC_FirstName__c = 'Pippo';
        listAff.get(0).XC_LastName__c = 'Franco';
        listAff.get(1).XC_FirstName__c = 'Gino';
        update listAff;
        Test.stopTest();
    }
    //vdb 22-12-2021
    @isTest
    public static void removeOldAffBen(){
        List<Asset> ass=[Select id from Asset limit 1];
        Test.startTest();
        XC_AffiliateBeneficiary_U.removeOldAffBen(ass);
        Test.stopTest();
    }

    @isTest

    public static void onBeforeDelete(){
        Id aBRecTypeId = Schema.SObjectType.XC_Affiliate_Beneficiary__c.getRecordTypeInfosByName().get('Affiliate').getRecordTypeId();

        XC_Affiliate_Beneficiary__c affBen4 = new XC_Affiliate_Beneficiary__c();

        affBen4.XC_Birthdate__c = Date.newInstance(2002, 12, 3);
        affBen4.XC_FirstName__c = 'Giorgio';
        affBen4.XC_LastName__c = 'Bianchi';
        affBen4.XC_Relationship__c = 'Holder';
        affBen4.RecordTypeId = aBRecTypeId;

        Asset ass1 = [SELECT Id FROM Asset LIMIT 1];

        affBen4.XC_Asset__c = ass1.Id;

        Test.startTest();
        insert affBen4;
        delete affBen4;
        Test.stopTest();

    }
    //vdb 22-12-2021
    /*@isTest
    public static void cloneAffBenTest(){
        system.debug('*** sono in cloneAffBenTest');
        List<User> user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId()];
        user[0].XC_EnabledToSkip__c = false;
        update user;
        system.debug('*** After update user');
        System.runAs(user[0]){
            system.debug('*** Sono in run as');
            List<NE__OrderItem__c> listaOrderItem = [SELECT Id, NE__OrderId__c ,  NE__Parent_Order_Item__c FROM NE__OrderItem__c  limit 1];
            List<XC_Affiliate_Beneficiary__c> listaAffBen = new List<XC_Affiliate_Beneficiary__c>();
            XC_Affiliate_Beneficiary__c affBen = new XC_Affiliate_Beneficiary__c();
            List<Asset> listaAsset = [SELECT Id, XC_Segment__c FROM Asset WHERE XC_Segment__c = 'B2C' limit 1];
            affBen.XC_Asset__c = listaAsset[0].Id;
            affBen.XC_Birthdate__c = Date.newInstance(2012, 5, 3);
            affBen.XC_FirstName__c = 'Luca';
            affBen.XC_LastName__c = 'Rotti';
            affBen.XC_Relationship__c = 'Holder';
            listaAffBen.add(affBen);
            insert listaAffBen;
            system.debug('*** after insert affben');
            Map<Id,Id> assetOrderItemMap = new Map<Id,Id>();
            assetOrderItemMap.put(listaOrderItem[0].NE__OrderId__c,listaOrderItem[0].id);
            Test.startTest();
            XC_AffiliateBeneficiary_U.cloneAffBen(listaOrderItem,assetOrderItemMap);
            Test.stopTest();
        }
    }*/

    @isTest

    public static void beforCloneAffBenTest(){
        
        Asset ass1 = [SELECT Id FROM Asset WHERE NE__Order_Config__c != null LIMIT 1];
        NE__Order__c ord1 = [SELECT Id FROM NE__Order__c WHERE XC_Status__c = 'Closed' LIMIT 1];
        ass1.ParentId = null;
        ass1.NE__Order_Config__c = ord1.Id;        

        Test.startTest();
        update ass1;
        Test.stopTest();

    } 

}
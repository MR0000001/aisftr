/** 
* @author Federico Manni - federico.manni@accenture.com
* @date Creation 10/10/2021
* @date Modification 27/10/2021 Denise Avolio - denise.avolio@accenture.com
* @description - XC_LCC_ValidateButton_Test – Test class for XC_LCC_ValidateButton
 */

@isTest
public with sharing class XC_LCC_ValidateButton_Test {
    
    @TestSetup
    public static void setup() {

        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;

        List<Asset> assetList = XC_DF_Asset.createAssets(2);
        assetList[0].AccountId = contactList[0].AccountId;
        insert assetList;

        List<String> listAttributes = new List<String> {XC_AffiliateBeneficiary_U.AFFBENCODE, XC_AffiliateBeneficiary_U.PLAN};
        List<NE__AssetItemAttribute__c> assetAttribList = XC_DF_Asset.createAssetItemAttributes(assetList, listAttributes);
        for(NE__AssetItemAttribute__c aia : assetAttribList){
            if(XC_AffiliateBeneficiary_U.AFFBENCODE.equalsIgnoreCase(aia.Name)){
                aia.NE__Value__c = 'TestCode 0';
            }else{
                aia.NE__Value__c = 'Basico';
            }
        }
        insert assetAttribList;    
        
        List<RecordType> rtCaseCOL = [SELECT id FROM RecordType WHERE DeveloperName='XC_B2C_COL_Management_Case' AND SObjectType = 'Case' LIMIT 1];
        
        Case cs = XC_DF_Case.createCaseFromType('XCMOT022','ATCL202', null);
        cs.AssetId =  assetList[0].Id;
        cs.AccountId = assetList[0].AccountId;
        cs.ContactId = contactList[0].id;
        cs.XC_LegalEntity__c = 'Codensa';
        if(!rtCaseCOL.isEmpty()){
            cs.RecordTypeId = rtCaseCOL.get(0).Id;
        }
        insert cs;

        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(4);
        for(Integer i=0; i<orderItemList.size(); i++){
            orderItemList[i].NE__Qty__c = 10 + i;
        }
        insert orderItemList;

        List<NE__Order_Item_Attribute__c> ordItemAttrList = new List<NE__Order_Item_Attribute__c>();
        NE__Order_Item_Attribute__c oia = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList.get(0), XC_AffiliateBeneficiary_U.AFFBENCODE, 'TestCode 0');
        NE__Order_Item_Attribute__c oia2 = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList.get(0), XC_AffiliateBeneficiary_U.PLAN, 'Basico');
        NE__Order_Item_Attribute__c oia3 = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList.get(2), XC_AffiliateBeneficiary_U.AFFBENCODE, 'TestCode');
        NE__Order_Item_Attribute__c oia4 = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList.get(2), XC_AffiliateBeneficiary_U.PLAN, 'Light');
        NE__Order_Item_Attribute__c oia5 = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList.get(3), XC_AffiliateBeneficiary_U.AFFBENCODE, 'TestCode 0');
        NE__Order_Item_Attribute__c oia6 = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItemList.get(3), XC_AffiliateBeneficiary_U.PLAN, 'Basico');
        
        ordItemAttrList.add(oia);
        ordItemAttrList.add(oia2);
        ordItemAttrList.add(oia3);
        ordItemAttrList.add(oia4);
        ordItemAttrList.add(oia5);
        ordItemAttrList.add(oia6);
        insert ordItemAttrList;

        List<XC_AffiliateBeneficiaryConfiguration__c> affBenConfList = createAffBenConfigs('TestCode 0', 'Basico');
        insert affBenConfList;

        List<XC_Affiliate_Beneficiary__c> affBenListWithOrdIt = createAffBen(orderItemList[0].Id, null, Date.newInstance(2007, 12, 5));
        List<XC_Affiliate_Beneficiary__c> aBListWithOrdIt = createAffBen(orderItemList[0].Id, null, Date.newInstance(2007, 12, 5));
        List<XC_Affiliate_Beneficiary__c> affBenListWithAsset = createAffBen(null, assetList[0].Id, Date.newInstance(2007, 12, 5));
        affBenListWithOrdIt.addAll(aBListWithOrdIt);
        affBenListWithOrdIt.addAll(affBenListWithAsset);
        insert affBenListWithOrdIt;
    }

    
    @isTest
    public static void validateAsset1(){
        List<Asset> assetList = [SELECT Id
                                 FROM Asset
                                 ORDER BY Name];
        String assId = assetList.get(0).Id;

        Test.startTest();
        XC_LCC_ValidateButton.WrapperResult wr = XC_LCC_ValidateButton.validate(assId);
        System.assertEquals(false, wr.errorResult, 'Asset Success');
        Test.stopTest();
    }

    @isTest
    public static void validateAsset2(){
        List<Asset> assetList = [SELECT Id
                                 FROM Asset
                                 ORDER BY Name];
        String assId = assetList.get(1).Id;

        Test.startTest();
        XC_LCC_ValidateButton.WrapperResult wr = XC_LCC_ValidateButton.validate(assId);
        System.assertEquals(true, wr.errorResult, 'Asset without Attributes or Case');
        Test.stopTest();
    }
    
    @isTest
    private static void validateOrderItem1(){
        NE__OrderItem__c orderItem = [SELECT Id
                                      FROM NE__OrderItem__c
                                      WHERE NE__Qty__c = 10];

        Test.startTest();
        XC_LCC_ValidateButton.WrapperResult wr = XC_LCC_ValidateButton.validate(orderItem.Id);
        System.assertEquals(true, wr.errorResult, 'More than one Holder affiliate and percentage greater than 100 for beneficiaries');
        Test.stopTest();
    }
    
    @isTest
    private static void validateOrderItem2(){
        NE__OrderItem__c orderItem = [SELECT Id
                                      FROM NE__OrderItem__c
                                      WHERE NE__Qty__c = 11];

        Test.startTest();
        XC_LCC_ValidateButton.WrapperResult wr = XC_LCC_ValidateButton.validate(orderItem.Id);
        System.assertEquals(true, wr.errorResult, 'No OrderItemAttribute');
        Test.stopTest();
    }

    @isTest
    private static void validateOrderItem3(){
        NE__OrderItem__c orderItem = [SELECT Id
                                      FROM NE__OrderItem__c
                                      WHERE NE__Qty__c = 12];

        Test.startTest();
        XC_LCC_ValidateButton.WrapperResult wr = XC_LCC_ValidateButton.validate(orderItem.Id);
        System.assertEquals(true, wr.errorResult, 'No Configuration retrieved');
        Test.stopTest();
    }

    @isTest
    private static void validateOrderItem4(){
        NE__OrderItem__c orderItem = [SELECT Id
                                      FROM NE__OrderItem__c
                                      WHERE NE__Qty__c = 13];

        Test.startTest();
        XC_LCC_ValidateButton.WrapperResult wr = XC_LCC_ValidateButton.validate(orderItem.Id);
        System.assertEquals(true, wr.errorResult, 'No affiliates and beneficiaries for this OrderItem');
        Test.stopTest();
    }
    /*
    @isTest
    private static void validateAsset(){
        List<Asset> assetList = [SELECT Id
                                 FROM Asset
                                 ORDER BY Name];
        SObject sobj = assetList[0].Id.getSObjectType().newSObject(assetList[0].Id);
        Test.startTest();
        XC_LCC_ValidateButton.WrapperResult wr = XC_LCC_ValidateButton.validate('Basico', 'TestCode 0', assetList[0].Id, 'Asset');
        System.assertEquals(true, wr.errorResult, 'Error');
        Test.stopTest();
    }
    
    @isTest
    private static void validateOrderItem(){
        //TODO
    }
    
    @isTest
    private static void checkAssetAtt(){
        //TODO
    }
    @isTest
    private static void retrieveConfigurations(){
        //TODO
    }
    */
    public static List<XC_AffiliateBeneficiaryConfiguration__c> createAffBenConfigs(String confCode, String prodPlan){
        List<XC_AffiliateBeneficiaryConfiguration__c> affBenConfList = new List<XC_AffiliateBeneficiaryConfiguration__c>();
        for (Integer i=0; i<2; i++){
			XC_AffiliateBeneficiaryConfiguration__c affBenConf = new XC_AffiliateBeneficiaryConfiguration__c();
            affBenConf.XC_ConfigurationType__c = 'Configuration Validation';
            affBenConf.XC_RecordType__c = (i==0) ? 'XC_Affiliate' : 'XC_Beneficiary';
            affBenConf.XC_ConfigurationCode__c = confCode;
            affBenConf.XC_ProductPlan__c = prodPlan;
            affBenConf.XC_MinNumberOfType__c = 1;
            affBenConf.XC_MaxNumberOfType__c = 2;
            affBenConfList.add(affBenConf);
        }
 		return affBenConfList;
    }

    public static List<XC_Affiliate_Beneficiary__c> createAffBen(String ordItId, String assetId, Date birthDate){
        List<XC_Affiliate_Beneficiary__c> affBenList = new List<XC_Affiliate_Beneficiary__c>();
        Id affRecTypeId = Schema.SObjectType.XC_Affiliate_Beneficiary__c.getRecordTypeInfosByName().get('Affiliate').getRecordTypeId();
        Id benRecTypeId = Schema.SObjectType.XC_Affiliate_Beneficiary__c.getRecordTypeInfosByName().get('Beneficiary').getRecordTypeId();
        for (Integer i=0; i<2; i++){
			XC_Affiliate_Beneficiary__c affBen = new XC_Affiliate_Beneficiary__c();
            affBen.XC_Birthdate__c = birthDate;
            affBen.RecordTypeId = (i==0) ? affRecTypeId : benRecTypeId;
            affBen.XC_Partecipation_Percentage__c = (i==0) ? null : 100;
            affBen.XC_FirstName__c = (i==0) ? 'AffName' : 'BenName';
            affBen.XC_LastName__c = (i==0) ? 'AffSurname' : 'BenSurname';
            affBen.XC_Relationship__c = (i==0) ? 'Holder' : 'Spouse';
            affBen.XC_OrderItem__c = !String.isEmpty(ordItId) ? ordItId : null;
            affBen.XC_Asset__c = !String.isEmpty(assetId) ? assetId : null;
            affBenList.add(affBen);
        }
 		return affBenList;
    }
}
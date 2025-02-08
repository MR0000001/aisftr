/**
* @author Nicola Mariniello nmariniello@deloitte.it
* @description XC_TR_BillingProfile_U_DiscAsset_TEST - Test Class for XC_TR_BillingProfile_U_DisconnectAsset
*/


@isTest
public without sharing class XC_TR_BillingProfile_U_DiscAsset_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

        List<NE__Product__c> prodList = new List<NE__Product__c>();

        NE__Product__c prodOC = new NE__Product__c();
        prodOC.XC_Product_Subtype__c = 'Tariff';
        prodOC.XC_Product_Type__c = 'Service';
        prodOC.XC_LIC_Product_Name__c = 'OpenCharge';
        prodOC.Name = 'OpenCharge';
        prodList.add(prodOC);

        NE__Product__c prodPPU = new NE__Product__c();
        prodPPU.XC_Product_Subtype__c = 'Tariff';
        prodPPU.XC_Product_Type__c = 'Service';
        prodPPU.XC_LIC_Product_Name__c = 'Pay Per Use';
        prodPPU.Name = 'Pay Per Use';
        prodList.add(prodPPU);

        insert prodList;

        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnConfigMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_OfferToActivate__c
                                                                                                                            FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                            WHERE XC_OrgId__c =: UserInfo.getOrganizationId() AND 
                                                                                                                                XC_LegalEntity__c = 'EnelXMSP' AND
                                                                                                                                XC_Stream__c =: 'B2C' AND
                                                                                                                                XC_OfferToActivate__c != null]);

        List<NE__Catalog_Item__c> catalogItemList = new List<NE__Catalog_Item__c>();

        NE__Catalog_Item__c catItemOC = XC_DF_CatalogItem.createCatalogItem();
        catItemOC.NE__Engine_Code__c = 'OpenCharge';
        catItemOC.NE__UsageCode__c = 'OpenCharge';
        catItemOC.NE__ProductId__c = prodOC.id;
        catalogItemList.add(catItemOC);

        NE__Catalog_Item__c catItemPPU = XC_DF_CatalogItem.createCatalogItem();
        catItemPPU.NE__Engine_Code__c = legalEnConfigMap.values()[0].XC_OfferToActivate__c;
        catItemPPU.NE__UsageCode__c = 'PPU';
        catItemPPU.NE__ProductId__c = prodPPU.id;
        catalogItemList.add(catItemPPU);

        insert catalogItemList;

        NE__Catalog__c catalog = [Select id from NE__Catalog__c LIMIT 1];
        catalog.XC_LIC_Name__c = 'eMobility MSP';
        update catalog;

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXMSP';
        insert order;

        NE__OrderItem__c itemOC = XC_DF_OrderItem.createOrderItem(order);
        itemOC.NE__CatalogItem__c = catItemOC.Id;
        insert itemOC;

        List<Asset> assetList = XC_DF_Asset.createAssets(2);
        assetList[0].XC_Configuration_Item__c = itemOC.Id;
        assetList[0].NE__Order_Config__c = order.Id;
        assetList[0].NE__CatalogItem__c = catItemOC.Id;
        assetList[0].XC_Segment__c = 'B2C';
        assetList[0].XC_LegalEntity__c = 'EnelXMSP';
        insert assetList;

        List<Account> accList = [SELECT Id FROM Account];
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1, accList);

        List<XC_BillingProfileLineItem__c> bpliList = [SELECT Id, XC_BillingProfile__r.NE__Payment__c FROM XC_BillingProfileLineItem__c];
        assetList[0].XC_BillingProfileLineItem__c = bpliList[0].Id;
        assetList[0].XC_PaymentMethod__c = bpliList[0].XC_BillingProfile__r.NE__Payment__c;
        assetList[0].Status = 'Active';
        update assetList;
        
        XC_CS005_Bit2WinChangeAPI__c b2wChangeCredentials = new XC_CS005_Bit2WinChangeAPI__c();
        b2wChangeCredentials.XC_Password__c = '143t25g3141';
        b2wChangeCredentials.XC_PasswordToken__c = '2647256726572';
        b2wChangeCredentials.XC_ServerURL__c = 'sFDSgdfgedWafdhaj';
        b2wChangeCredentials.XC_UserToken__c = 'ff135y4fd2';
        b2wChangeCredentials.XC_Country__c = 'SPAIN';
        insert b2wChangeCredentials;
    }


    @isTest
    private static void testOk() {
        
        List<NE__Billing_Profile__c> bpList = [SELECT Id FROM NE__Billing_Profile__c];
        for(NE__Billing_Profile__c bp : bpList) {
            bp.XC_Status__c = Label.XC_CL_BillingProfileStatus_Refused;
            bp.XC_StatusReason__c = Label.XC_CL_BillingProfile_StatusReason_Termination;
        }

        Test.startTest();
            update bpList;
        Test.stopTest();
        
        System.assertEquals(bpList!=null, true, 'Wrong assert equals');
    }
    
    
    @isTest
    private static void testOkB2B() {
        
        List<Asset> assetList = [SELECT Id FROM Asset];
        assetList[0].XC_Segment__c = 'B2B';
        update assetList;
        
        List<NE__Billing_Profile__c> bpList = [SELECT Id FROM NE__Billing_Profile__c];
        for(NE__Billing_Profile__c bp : bpList) {
            bp.XC_Status__c = Label.XC_CL_BillingProfileStatus_Refused;
            bp.XC_StatusReason__c = Label.XC_CL_BillingProfile_StatusReason_Termination;
        }

        Test.startTest();
            update bpList;
        Test.stopTest();
        
        System.assertEquals(bpList!=null, true, 'Wrong assert equals');
    }

}
/**
* @author Nicola Mariniello nmariniello@deloitte.it
* @description XC_IN073_ChangeToPPU_TEST - Test Class for XC_IN073_ChangeToPPU
*/
@isTest
public class XC_IN073_ChangeToPPU_TEST {

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

        NE__Product__c prodTemporary = new NE__Product__c();
        prodTemporary.XC_Product_Subtype__c = 'Tariff';
        prodTemporary.XC_Product_Type__c = 'Service';
        prodTemporary.XC_LIC_Product_Name__c = 'Temporary Offer';
        prodTemporary.Name = 'Temporary Offer';
        prodList.add(prodTemporary);

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

        NE__Catalog_Item__c catItemTemporary = XC_DF_CatalogItem.createCatalogItem();
        catItemTemporary.NE__Engine_Code__c = 'Temporary Offer';
        catItemTemporary.NE__UsageCode__c = 'Temporary Offer';
        catItemTemporary.NE__ProductId__c = prodTemporary.id;
        catalogItemList.add(catItemTemporary);

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

        NE__OrderItem__c itemTemporary = XC_DF_OrderItem.createOrderItem(order);
        itemTemporary.NE__CatalogItem__c = catItemTemporary.Id;
        insert itemTemporary;
        

        List<Asset> assetList = XC_DF_Asset.createAssets(2);
        assetList[0].XC_Configuration_Item__c = itemOC.Id;
        assetList[0].NE__Order_Config__c = order.Id;
        assetList[0].NE__CatalogItem__c = catItemOC.Id;
        assetList[1].XC_Configuration_Item__c = itemTemporary.Id;
        assetList[1].NE__Order_Config__c = order.Id;
        assetList[1].NE__CatalogItem__c = catItemTemporary.Id;
        insert assetList;

        XC_Provisioning_step__c step = XC_DF_ProvisioningStep.createProvisioningStep(itemOC.Id);
        insert step;
        
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
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN073_ChangeToPPU.InputWrapper> listInputWrapper = new List<XC_IN073_ChangeToPPU.InputWrapper>();
        XC_IN073_ChangeToPPU.InputWrapper input = new XC_IN073_ChangeToPPU.InputWrapper();
        input.stepId = ps.Id;
        listInputWrapper.add(input);

        Test.startTest();
            XC_IN073_ChangeToPPU.changeToPPU(listInputWrapper);
        Test.stopTest();
        
        System.assertEquals(listInputWrapper!=null, true, 'Wrong assert equals');
    }


    @isTest
    private static void noAssetTest() {

        Asset a =[SELECT Id FROM Asset WHERE NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c like '%Temporary Offer%'];
        delete a;
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN073_ChangeToPPU.InputWrapper> listInputWrapper = new List<XC_IN073_ChangeToPPU.InputWrapper>();
        XC_IN073_ChangeToPPU.InputWrapper input = new XC_IN073_ChangeToPPU.InputWrapper();
        input.stepId = ps.Id;
        listInputWrapper.add(input);

        Test.startTest();
            XC_IN073_ChangeToPPU.changeToPPU(listInputWrapper);
        Test.stopTest();
        
        System.assertEquals(listInputWrapper!=null, true, 'Wrong assert equals');
    }


    @isTest
    private static void noCustomMetadata() {

        Asset a =[SELECT Id FROM Asset WHERE NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c like '%Temporary Offer%'];
        a.XC_Segment__c = 'B2B';
        a.XC_LegalEntity__c = 'EnelXRomania';
        update a;
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN073_ChangeToPPU.InputWrapper> listInputWrapper = new List<XC_IN073_ChangeToPPU.InputWrapper>();
        XC_IN073_ChangeToPPU.InputWrapper input = new XC_IN073_ChangeToPPU.InputWrapper();
        input.stepId = ps.Id;
        listInputWrapper.add(input);

        Test.startTest();
            XC_IN073_ChangeToPPU.changeToPPU(listInputWrapper);
        Test.stopTest();
        
        System.assertEquals(listInputWrapper!=null, true, 'Wrong assert equals');
    }



}
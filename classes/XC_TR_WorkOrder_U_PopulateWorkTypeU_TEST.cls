/**
 * Created by dolombardi on 04/03/2021.
 */

@isTest
public with sharing class XC_TR_WorkOrder_U_PopulateWorkTypeU_TEST {
    static testMethod void onInsertWorkTypeLabelEmpty() {
        WorkOrder w = new WorkOrder();
        w.XC_Segment__c = 'B2C';
        w.XC_ProdCatOfInterestText__c = 'Donato';



        List<WorkOrder>listWo = new List<WorkOrder>{w};
        XC_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listWo);


    }
    static testMethod void onInsertWorkTypeAsset() {
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        insert ast;
        WorkOrder w = new WorkOrder();
        w.AssetId = ast.id;
        List<WorkOrder>listWo = new List<WorkOrder>{w};
        XC_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listWo);


    }
    static testMethod void onInsertWorkTypeConfItem() {
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        update o;
        List<NE__OrderItem__c> itemList = [SELECT id, NE__OrderId__r.XC_LegalEntity__c, NE__ProdId__r.XC_Product_Subtype__c,NE__CatalogItem__c,NE__OrderId__r.name, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        WorkOrder w = new WorkOrder();
        w.XC_Configuration_Item__c = itemList[0].id;
        List<WorkOrder>listWo = new List<WorkOrder>{w};
        XC_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listWo);


    }
    
    static testMethod void onInsertWorkTypeConfiguration() {
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        WorkOrder w = new WorkOrder();
        w.XC_Configuration__c = o.id;
        List<WorkOrder>listWo = new List<WorkOrder>{w};
        XC_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listWo);


    }

}
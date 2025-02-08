/**
 * @File Name          : XC_TR_DictamenItem_U_TechnicalQuote.cls
 * @description        : Util to handle the creation of the Technical Quote
 * @Author             : Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @Group              : 
 * @Last Modified By   : Roberta Cossiga - rcossiga@deloitte.it && Marco Rosa - marco.rosa@nttdata.com && Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @Last Modified On   : 24/10/2019, 11:37:20
**/
@isTest
public without sharing class XC_TR_DictamenItem_U_TechQuote_TEST {
    @TestSetup
    static void setup(){
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        
        a.Name = 'Baxi';
        a.XC_Address__c = addresses[0].Id;
        a.NE__Bundle__c = bundle.Id;
        a.XC_LegalEntity__c = 'EndesaX';
        a.XC_Product_Type__c = 'Boiler';
        a.XC_Product_Subtype__c = Label.XC_CL_ProductTypeEquipment;
        a.Status = Label.XC_CL_Asset_StatusActive ;
		insert a;

        Asset a2 = assetlist[4];
        a2.Name = 'Baxi2';
        a2.AccountId = a.AccountId;
        a2.XC_LegalEntity__c = 'EndesaX';
        a2.XC_Address__c = addresses[0].Id;
        a2.NE__Bundle__c = bundle.Id;
        a2.XC_Product_Type__c = 'Boiler';
        a2.XC_Product_Subtype__c = Label.XC_CL_ProductTypeEquipment;
        a2.Status = Label.XC_CL_Asset_StatusActive ;
		insert a2;

        Asset assetBundle  = assetlist[3];
        assetBundle.XC_Address__c = addresses[0].Id;
        assetBundle.Name = 'type service';
        assetBundle.AccountId = a.AccountId;
        assetBundle.NE__Bundle__c = bundle.Id;
        assetBundle.XC_Product_Type__c = Label.XC_CL_ProductTypeBundle;
        assetBundle.XC_Product_Subtype__c = Label.XC_CL_ProductTypeBundle;
        assetBundle.Status = Label.XC_CL_Asset_StatusActive ;
        
		insert assetBundle;

        Asset assetTypeSErvice  = assetlist[2];
        assetTypeSErvice.XC_Address__c = addresses[0].Id;
        assetTypeSErvice.Name = 'type service';
        assetTypeSErvice.AccountId = a.AccountId;
        assetTypeSErvice.NE__Bundle__c = bundle.Id;
        assetTypeSErvice.XC_Product_Type__c = Label.XC_CL_ProductTypeService;
        assetTypeSErvice.XC_Product_Subtype__c = 'Repair';
        assetTypeSErvice.Status = Label.XC_CL_Asset_StatusActive ;
        
		insert assetTypeSErvice;
        
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

        insert XC_DF_WorkType.createWorkTypeWithName('Repair', 'Repair - Gas');
        Test.stopTest();
    }

    @IsTest
    static void test(){
        
        
        List<ServiceResource> srList = XC_DF_ServiceResource.createServiceResources(1);
        //insert srList;
        System.debug('srList: ' + srList);

        List<ServiceTerritory> stList = XC_DF_ServiceTerritory.createServiceTerritories([SELECT Id, Name FROM Account WHERE Id = :srList[0].XC_Account__c]);
        insert stList;
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();   
        srtmemb.ServiceTerritoryId = stList[0].Id;
        srtmemb.ServiceResourceId = srList[0].Id;
        srtmemb.TerritoryType = 'P';
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = stList[0].OperatingHoursId;
        insert srtmemb; 

        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        

        listOfWo[0].AssetId = [SELECT Id FROM Asset WHERE XC_Product_Subtype__c = :Label.XC_CL_ProductTypeEquipment LIMIT 1].Id;
        listOfWo[0].XC_AssignedResource__c = srList[0].Id;
        listOfWo[0].Status = 'On Hold';
        listOfWo[0].XC_StatusReason__c = Label.XC_CL_PendingAcceptanceQuote;
        insert listOfWo;
        System.debug('query wo: ' + [SELECT Id, XC_AssignedResource__c,  XC_LegalEntity__c, Street, PostalCode, City, Country, XC_Address__c, ParentWorkOrderId, AssetId, WorkTypeId, XC_WorkTypeLabel__c FROM WorkOrder]);
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(listOfWo);
        saList[0].XC_WorkTypeLabel__c = 'Planned Maintenance';
        insert saList;
        System.debug('query wo: ' + [SELECT Id, XC_AssignedResource__c,  XC_LegalEntity__c, Street, PostalCode, City, Country, XC_Address__c, ParentWorkOrderId, AssetId FROM WorkOrder]);
		Test.startTest();
        XC_DictamenItem__c di = new XC_DictamenItem__c();
        di.XC_WorkOrder__c = listOfWo[0].Id;
        di.XC_Asset__c = listOfWo[0].AssetId;
        di.XC_Solvable__c = Label.XC_CL_Yesinthesamevisit;
        di.XC_IsPerformed__c = true;
        di.RecordTypeId = Schema.SObjectType.XC_DictamenItem__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_MaintenanceGas').getRecordTypeId();

        
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(di);
        XC_DictamenItem__c dictamenUpdate = [SELECT Id from XC_DictamenItem__c where XC_WorkOrder__c =: listOfWo[0].Id limit 1];
        dictamenUpdate.XC_ReparationStatus__c = Label.XC_CL_PendingQuoteAcceptance;
        System.debug('wr: ' + wr);
        update dictamenUpdate;
        dictamenUpdate.XC_ReparationStatus__c = Label.XC_CL_PendingSpareParts;
        update dictamenUpdate;
        System.assert(wr.success);
       
        Test.stopTest();
        
    }

}
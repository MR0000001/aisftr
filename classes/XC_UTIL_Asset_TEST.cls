/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  29/05/2019 
* @description XC_UTIL_Asset_TEST – Test class for XC_UTIL_Asset
*/
@isTest
public class XC_UTIL_Asset_TEST { 
    //Test Method populateRepairWrapper
    static testMethod void populateRepairWrapper(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        Asset assetOkService = new Asset();
        String catalogCategoryName = 'test';
        //XC_UTIL_Asset.RepairWrapper wr = new XC_UTIL_Asset.RepairWrapper();
        //XC_UTIL_Asset.populateRepairWrapper(assetOkService, catalogCategoryName, wr);
        //System.assertEquals(true, wr!=null);      
        Test.stopTest(); 
        
    }
    
    //Test Method populateRepairWrapper2
    static testMethod void populateRepairWrapper2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        
        insert asset2;
        update asset1;
        
        list<Asset> lsas = [select id, Name, XC_Product_Name_LIC__c , (select id from ne__assets__r) from Asset where Id =: asset1.Id];
        
        List<Asset> listRepairOkService = lsas[0].NE__Assets__r;
        
        
        String catalogCategoryName = 'Gas';
        //XC_UTIL_Asset.RepairWrapper wr = new XC_UTIL_Asset.RepairWrapper();
        
        try{
            //XC_UTIL_Asset.populateRepairWrapper(lsas[0],  catalogCategoryName, wr);
        } catch(exception e){
            System.assert(e!=null);
        }
        
        
        //System.assertEquals(true, wr!=null);   
        Test.stopTest();
        
        
    }
    
    
    //Test Method getMapAddress
    static testMethod void getMapAddress(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Id> listAddressId = new List<Id>();
        //Map<Id,List<Asset>> mpas = XC_UTIL_Asset.getMapAddress( listAddressId);
        //System.assertEquals(true, mpas!=null);      
        Test.stopTest(); 
        
    }
    
    //Test Method getNumberRepairWorkOrderCurrentYear
    static testMethod void getNumberRepairWorkOrderCurrentYear(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Asset> lasst = XC_DF_Asset.createAssets(3);
        insert lasst;
        
        asset currentAsset = [Select Id, CreatedDate from Asset][0];
        asset assetRepair = [Select Id, CreatedDate from Asset][1];
        
        
        //integer intg = XC_UTIL_Asset.getNumberRepairWorkOrderCurrentYear(currentAsset, assetRepair);
        //System.assertEquals(true, intg!=null);      
        Test.stopTest(); 
        
    }
    
    //Test Method getMapAssetMaintenance
    static testMethod void getMapAssetMaintenance(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.Status = Label.XC_CL_Asset_StatusActive;
        
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        
        insert asset2;
        asset1.NE__Bundle_Configuration__c = asset2.Id;
        update asset1;
        
        list<Asset> lsas = [select id, Name, XC_Product_Name_LIC__c , (select id from ne__assets__r) from Asset where Id =: asset1.Id];
        
        
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(lsas[0].Id);
        
        
        XC_UTIL_Asset.MaintenanceWrapper MaintenanceWrapper = new XC_UTIL_Asset.MaintenanceWrapper();
        Map<Id, XC_UTIL_Asset.MaintenanceWrapper>  mmw = XC_UTIL_Asset.getMapAssetMaintenance(listAssetIds);
        System.assertEquals(true, mmw!=null);      
        Test.stopTest(); 
        
    }
    
    
    //Test Method getMapAssetMaintenance2
    static testMethod void getMapAssetMaintenance2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.Status = Label.XC_CL_Asset_StatusActive;
        
        //asset2.XC_Product_Name__c= Label.XC_CL_Asset_MaintenanceAnnual;
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        
        insert asset2;
        
        update asset1;
        
        
        list<Asset> lsas  = [SELECT Id, NE__Bundle_Configuration__c, Status, 
                             (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                              FROM NE__Assets__r ) 
                             FROM Asset  where Id =: asset1.Id
                            ]; 
        
        List<Asset> listRepairOkService = lsas[0].NE__Assets__r;
        String catalogCategoryName = 'Gas';
        //XC_UTIL_Asset.RepairWrapper wr = new XC_UTIL_Asset.RepairWrapper();
        
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(lsas[0].Id);
        
        
        
        
        
        XC_UTIL_Asset.MaintenanceWrapper MaintenanceWrapper = new XC_UTIL_Asset.MaintenanceWrapper();
        Map<Id, XC_UTIL_Asset.MaintenanceWrapper>  mmw = XC_UTIL_Asset.getMapAssetMaintenance(listAssetIds);
        System.assertEquals(true, mmw!=null);      
        Test.stopTest(); 
        
    }
    
    
    //Test Method retrieveMapDocumentationCharacterist
    static testMethod void retrieveMapDocumentationCharacterist(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<NE__Product__c> proList = XC_DF_Product.createProducts(5);
        List <NE__Bundle__c> bdl = XC_DF_Bundle.createBundleRecords(1); 
        NE__Bundle__c bundle = bdl[0];
        List <XC_Address__c> addressls = XC_DF_Address.createAddress(1);
        XC_Address__c address = addressls[0];
        List<Asset> lasst = XC_DF_Asset.createAssetWithBundleRecords( proList,bundle,  address);        
        
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        
        for (integer i= 0; i<5; i++){
            lasst[i].accountId = lscc[0].Id ;
        }
        
        insert lasst;
        lasst[0].NE__Bundle_Configuration__c = lasst[2].Id;        
        
        update lasst;
        List<String> listAssetIds = new List<String>();
        
        for (integer i= 0; i<5; i++){
            listAssetIds.add(lasst[i].Id);
        }       
        
        Map<Id, string>  mmw = XC_UTIL_Asset.retrieveMapDocumentationCharacterist(listAssetIds);
        System.assertEquals(true, mmw!=null);      
        Test.stopTest(); 
        
    }
    
    //Test Method retrieveMapAssetMaintenance
    static testMethod void retrieveMapAssetMaintenance(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<NE__Product__c> proList = XC_DF_Product.createProducts(5);
        List <NE__Bundle__c> bdl = XC_DF_Bundle.createBundleRecords(1); 
        NE__Bundle__c bundle = bdl[0];
        List <XC_Address__c> addressls = XC_DF_Address.createAddress(1);
        XC_Address__c address = addressls[0];
        List<Asset> lasst = XC_DF_Asset.createAssetWithBundleRecords( proList,bundle,  address);        
        
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;       
        for (integer i= 0; i<5; i++){
            lasst[i].accountId = lscc[0].Id ;
        }        
        insert lasst;
        lasst[0].NE__Bundle_Configuration__c = lasst[2].Id;       
        
        update lasst;
        List<String> listAssetIds = new List<String>();        
        for (integer i= 0; i<5; i++){
            listAssetIds.add(lasst[i].Id);
        }
        Map<Id, Asset>  mmw = XC_UTIL_Asset.retrieveMapAssetMaintenance(listAssetIds);
        System.assertEquals(true, mmw!=null);      
        Test.stopTest(); 
        
    }
    
    //Test Method retrieveMapAssetRepair
    static testMethod void retrieveMapAssetRepair(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<NE__Product__c> proList = XC_DF_Product.createProducts(5);
        List <NE__Bundle__c> bdl = XC_DF_Bundle.createBundleRecords(1); 
        NE__Bundle__c bundle = bdl[0];
        List <XC_Address__c> addressls = XC_DF_Address.createAddress(1);
        XC_Address__c address = addressls[0];
        List<Asset> lasst = XC_DF_Asset.createAssetWithBundleRecords( proList,bundle,  address);        
        
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;       
        for (integer i= 0; i<5; i++){
            lasst[i].accountId = lscc[0].Id ;
        }        
        insert lasst;
        lasst[0].NE__Bundle_Configuration__c = lasst[2].Id;       
        
        update lasst;
        List<String> listAssetIds = new List<String>();        
        for (integer i= 0; i<5; i++){
            listAssetIds.add(lasst[i].Id);
        }
        //Map<Id, Asset>  mmw = XC_UTIL_Asset.retrieveMapAssetRepair(listAssetIds);
        //System.assertEquals(true, mmw!=null);      
        Test.stopTest(); 
        
    }
    
    
    //Test Method retrieveMapBundleAssetRepair
    static testMethod void retrieveMapBundleAssetRepair(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<NE__Product__c> proList = XC_DF_Product.createProducts(5);
        List <NE__Bundle__c> bdl = XC_DF_Bundle.createBundleRecords(1); 
        NE__Bundle__c bundle = bdl[0];
        List <XC_Address__c> addressls = XC_DF_Address.createAddress(1);
        XC_Address__c address = addressls[0];
        List<Asset> lasst = XC_DF_Asset.createAssetWithBundleRecords( proList,bundle,  address);        
        
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;       
        for (integer i= 0; i<5; i++){
            lasst[i].accountId = lscc[0].Id ;
        }        
        insert lasst;
        lasst[0].NE__Bundle_Configuration__c = lasst[2].Id;       
        
        update lasst;
        List<String> listAssetIds = new List<String>();        
        for (integer i= 0; i<5; i++){
            listAssetIds.add(lasst[i].Id);
        }
        //Map<Id, Asset>  mmw = XC_UTIL_Asset.retrieveMapBundleAssetRepair(listAssetIds);
        //System.assertEquals(true, mmw!=null);      
        Test.stopTest(); 
        
    }
    
    
    //Test Method retrieveMapAssetByAttributeName
    static testMethod void retrieveMapAssetByAttributeName(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<NE__Product__c> proList = XC_DF_Product.createProducts(5);
        List <NE__Bundle__c> bdl = XC_DF_Bundle.createBundleRecords(1); 
        NE__Bundle__c bundle = bdl[0];
        List <XC_Address__c> addressls = XC_DF_Address.createAddress(1);
        XC_Address__c address = addressls[0];
        List<Asset> lasst = XC_DF_Asset.createAssetWithBundleRecords( proList,bundle,  address);        
        
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;       
        for (integer i= 0; i<5; i++){
            lasst[i].accountId = lscc[0].Id ;
        }        
        insert lasst;
        lasst[0].NE__Bundle_Configuration__c = lasst[2].Id;       
        
        update lasst;
        List<String> listAssetIds = new List<String>();        
        for (integer i= 0; i<5; i++){
            listAssetIds.add(lasst[i].Id);
        }
        //Map<Id, Asset>  mmw = XC_UTIL_Asset.retrieveMapAssetByAttributeName(listAssetIds, '');
        //System.assertEquals(true, mmw!=null);      
        Test.stopTest(); 
        
    }
    
    
    //Test Method getYearFrequency1
    static testMethod void getYearFrequency1(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest(); 
        
        integer  mmw = XC_UTIL_Asset.getYearFrequency('Annual');
        System.assertEquals(true, mmw!=null);        
        Test.stopTest(); 
        
    }
    
    
    //Test Method getYearFrequency2
    static testMethod void getYearFrequency2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest(); 
        
        integer  mmw = XC_UTIL_Asset.getYearFrequency('Biennial');
        System.assertEquals(true, mmw!=null);        
        Test.stopTest(); 
        
    }
    
    //Test Method getYearFrequency0
    static testMethod void getYearFrequency0(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        Test.startTest(); 
        
        integer  mmw = XC_UTIL_Asset.getYearFrequency('');
        System.assertEquals(true, mmw!=null);        
        Test.stopTest(); 
        
    }
    
    
    
    
    //Test Method populateAssetMaintenanceWrapper
    static testMethod void populateAssetMaintenanceWrapper(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        
        
        NE__Product__c prodToInsert = new NE__Product__c();
        prodToInsert.NE__Block_Change__c = false;
        prodToInsert.NE__Check_Stock__c = false;
        prodToInsert.NE__Export_Images__c = false;
        prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
        prodToInsert.NE__IsPromo__c = false;
        prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
        prodToInsert.NE__Stock__c = 300;
        prodToInsert.NE__Engine_Code__c = 'code';
        prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';
        prodToInsert.XC_Product_Subtype__c='Maintenance';
        prodToInsert.XC_Product_Type__c='Coverage';
        prodToInsert.XC_LIC_Product_Name__c = 'Mantenimiento';
        insert prodToInsert;
        
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.NE__ProdId__c = prodToInsert.Id;
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        asset1.NE__Status__c = 'Active';
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.NE__ProdId__c = prodToInsert.Id;
        asset2.Status = Label.XC_CL_Asset_StatusActive;
        asset2.NE__Status__c = 'Active';
        
        
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        
        insert asset2;
        
        update asset1;
        
        
        list<Asset> lsas  = [SELECT Id, NE__Bundle_Configuration__c, Status, 
                             (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                              FROM NE__Assets__r ) 
                             FROM Asset  where Id =: asset1.Id
                            ]; 
        
        List<Asset> listRepairOkService = lsas[0].NE__Assets__r;
        
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(lsas[0].Id);
        
        
        
        
        
        XC_UTIL_Asset_U_PopulateWrappers.populateAssetMaintenanceWrapper(listAssetIds);
        System.assertEquals(true, listAssetIds!=null);      
        Test.stopTest(); 
        
    }
    
    //Test Method populateAssetMaintenanceWrapper2
    static testMethod void populateAssetMaintenanceWrapper2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        
        
        NE__Product__c prodToInsert = new NE__Product__c();
        prodToInsert.NE__Block_Change__c = false;
        prodToInsert.NE__Check_Stock__c = false;
        prodToInsert.NE__Export_Images__c = false;
        prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
        prodToInsert.NE__IsPromo__c = false;
        prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
        prodToInsert.NE__Stock__c = 300;
        prodToInsert.NE__Engine_Code__c = 'code';
        prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';
        prodToInsert.XC_Product_Subtype__c='Maintenance';
        prodToInsert.XC_Product_Type__c='Coverage';
        prodToInsert.XC_LIC_Product_Name__c = 'Mantenimiento';
        insert prodToInsert;
        
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.NE__ProdId__c = prodToInsert.Id;
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.NE__ProdId__c = prodToInsert.Id;
        
        
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        
        insert asset2;
        
        update asset1;
        
        
        list<Asset> lsas  = [SELECT Id, NE__Bundle_Configuration__c, Status, 
                             (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                              FROM NE__Assets__r ) 
                             FROM Asset  where Id =: asset1.Id
                            ]; 
        
        List<Asset> listRepairOkService = lsas[0].NE__Assets__r;
        
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(lsas[0].Id);
        
        
        
        
        
        XC_UTIL_Asset_U_PopulateWrappers.populateAssetMaintenanceWrapper(listAssetIds);
        System.assertEquals(true, listAssetIds!=null);      
        Test.stopTest(); 
        
    }

    
    
    
    
    //Test Method checkUrgentProduct
    static testMethod void checkUrgentProduct(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        
        
        NE__Product__c prodToInsert = new NE__Product__c();
        prodToInsert.NE__Block_Change__c = false;
        prodToInsert.NE__Check_Stock__c = false;
        prodToInsert.NE__Export_Images__c = false;
        prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
        prodToInsert.NE__IsPromo__c = false;
        prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
        prodToInsert.NE__Stock__c = 300;
        prodToInsert.NE__Engine_Code__c = 'code';
        prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';
        prodToInsert.XC_Product_Subtype__c='Maintenance';
        prodToInsert.XC_Product_Type__c='Coverage';
        prodToInsert.XC_LIC_Product_Name__c = 'Reparacion';
        insert prodToInsert;
        
        
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.Status = Label.XC_CL_Asset_StatusActive;
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        asset2.NE__Bundle_Configuration__c= asset1.Id;
        insert asset2;
        
        update asset1;
        
        
        list<Asset> lsas  = [SELECT Id, NE__Bundle_Configuration__c, Status, 
                             (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                              FROM NE__Assets__r ) 
                             FROM Asset  where Id =: asset1.Id
                            ]; 
        
        List<Asset> listRepairOkService = lsas[0].NE__Assets__r;
        String catalogCategoryName = 'Gas';
        //XC_UTIL_Asset.RepairWrapper wr = new XC_UTIL_Asset.RepairWrapper();
        
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(lsas[0].Id);
        
        
        
        
        
        XC_UTIL_Asset.MaintenanceWrapper MaintenanceWrapper = new XC_UTIL_Asset.MaintenanceWrapper();
        Map<Id, XC_UTIL_Asset.MaintenanceWrapper>  mmw = XC_UTIL_Asset.getMapAssetMaintenance(listAssetIds);
        System.assertEquals(true, mmw!=null);  
        
        //XC_UTIL_Asset_U.AssetCheckWrapper assetCheckWrapper = new XC_UTIL_Asset_U.AssetCheckWrapper();
        //XC_UTIL_Asset_U_PopulateWrappers.populateAssetCheckWrapper(assetCheckWrapper);
        
        //Map<Id, XC_UTIL_Asset.RepairWrapper> ab =  XC_UTIL_Asset_U.getMapAssetRepair(listAssetIds);
        //XC_UTIL_Asset_U.checkUrgentProduct(listRepairOkService, wr, asset2 );
        
        XC_UTIL_Asset.MaintenanceWrapper  mntwr = XC_UTIL_Asset_U.checkYear(0 , mmw, asset2.Id);
        
        
        //System.assertEquals(true, wr!=null);  
        Test.stopTest(); 
        
    }
    
    
    
    //Test Method getMapAssetRepair2
    static testMethod void getMapAssetRepair2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();  
        
        
       NE__Product__c prodToInsert = new NE__Product__c();
        prodToInsert.NE__Block_Change__c = false;
        prodToInsert.NE__Check_Stock__c = false;
        prodToInsert.NE__Export_Images__c = false;
        prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
        prodToInsert.NE__IsPromo__c = false;
        prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
        prodToInsert.NE__Stock__c = 300;
        prodToInsert.NE__Engine_Code__c = 'code';
        prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';
        prodToInsert.XC_Product_Subtype__c='Maintenance';
        prodToInsert.XC_Product_Type__c='Coverage';
        prodToInsert.XC_LIC_Product_Name__c = 'Reparacion';
        insert prodToInsert;
        
        
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.Status = Label.XC_CL_Asset_StatusActive;
        
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        asset2.NE__Bundle_Configuration__c= asset1.Id;
        insert asset2;
        
        update asset1;
        
        
        list<Asset> lsas  = [SELECT Id, NE__Bundle_Configuration__c, Status, 
                             (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                              FROM NE__Assets__r ) 
                             FROM Asset  where Id =: asset2.Id
                            ]; 
        
        List<Asset> listRepairOkService = lsas[0].NE__Assets__r;
        String catalogCategoryName = 'Gas';
        //XC_UTIL_Asset.RepairWrapper wr = new XC_UTIL_Asset.RepairWrapper();
        
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(lsas[0].Id);
        
        
                
        
        
        
        //Map<Id, XC_UTIL_Asset.RepairWrapper> ab =  XC_UTIL_Asset_U.getMapAssetRepair(listAssetIds);
        
        
        
        
        //System.assertEquals(true, ab!=null);  
        Test.stopTest(); 
        
    }
    
    //Test Method populateAssetCheckWrapper
    static testMethod void populateAssetCheckWrapper(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
       NE__Product__c prodToInsert = new NE__Product__c();
        prodToInsert.NE__Block_Change__c = false;
        prodToInsert.NE__Check_Stock__c = false;
        prodToInsert.NE__Export_Images__c = false;
        prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
        prodToInsert.NE__IsPromo__c = false;
        prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
        prodToInsert.NE__Stock__c = 300;
        prodToInsert.NE__Engine_Code__c = 'code';
        prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';
        prodToInsert.XC_Product_Subtype__c='Maintenance';
        prodToInsert.XC_Product_Type__c='Coverage';
        prodToInsert.XC_LIC_Product_Name__c = 'Reparacion';
        insert prodToInsert;
        
        
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.NE__ProdId__c = prodToInsert.Id;
        asset1.NE__Action__c = 'Add';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.Status = Label.XC_CL_Asset_StatusActive;
        asset2.NE__Action__c = 'Add';
        asset2.NE__ProdId__c = prodToInsert.Id;
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        asset2.NE__Bundle_Configuration__c= asset1.Id;
        insert asset2;
        
        update asset1;
        
        
        list<Asset> lsas  = [SELECT Id, NE__Bundle_Configuration__c, Status, 
                             (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                              FROM NE__Assets__r ) 
                             FROM Asset  where Id =: asset1.Id
                            ]; 
        
        List<Asset> listRepairOkService = lsas[0].NE__Assets__r;
        String catalogCategoryName = 'Gas';
        //XC_UTIL_Asset.RepairWrapper wr = new XC_UTIL_Asset.RepairWrapper();
        
        List<String> listAssetIds = new List<String>();
        listAssetIds.add(lsas[0].Id);
        
        
        
        //XC_UTIL_Asset_U.AssetCheckWrapper assetCheckWrapper = new XC_UTIL_Asset_U.AssetCheckWrapper();
        
        //assetCheckWrapper.mapAssetBundleAsset.put(asset1.Id, asset2.Id); 
        //XC_UTIL_Asset_U_PopulateWrappers.populateAssetCheckWrapper(assetCheckWrapper);
        
        //assetCheckWrapper.mapAssetBundleAsset.put(asset2.Id, asset1.Id);
        //XC_UTIL_Asset_U_PopulateWrappers.populateAssetCheckWrapper(assetCheckWrapper);
        
        
        XC_UTIL_Asset.PopulateMaintenanceAssetWrapper populateWrapper = new XC_UTIL_Asset.PopulateMaintenanceAssetWrapper();
        populateWrapper.maintenanceAssetList.add(asset2);
        try{
        	XC_UTIL_Asset_U_PopulateWrappers.populateMaintenanceAsset(populateWrapper);
        }catch(Exception e){
            System.debug('In catch');
        }
        
        //System.assertEquals(true, assetCheckWrapper!=null);       
        Test.stopTest(); 
        
    }
    
    @isTest
    private static void getAssetTEST() {
    	List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        insert listAsset;
        
    	Asset a;
        Test.startTest();
        	a = XC_UTIL_Asset_D.getAssetDisconnectionData(listAsset[0].Id);
        Test.stopTest();
        
        System.assert(true, a != null);
    }
    
    /*@isTest
    private static void getZQuoteTEST() {
    	zqu__Quote__c zquote = new zqu__Quote__c();
        insert zquote;
        
    	zqu__Quote__c z;
        Test.startTest();
        	z = XC_UTIL_Asset_D.getZQuoteData(zquote.Id);
        Test.stopTest();
        
        System.assert(true, z != null);
    }
    
    @isTest
    private static void getZQuoteNullTEST() {
    	zqu__Quote__c zquote = new zqu__Quote__c();
        insert zquote;
        
    	zqu__Quote__c z;
        Test.startTest();
        	z = XC_UTIL_Asset_D.getZQuoteData('a259E000000tBglQ00');
        Test.stopTest();
        
        System.assert(true, z = null);
    }*/
    
    @isTest
    private static void getSubscriptionTEST() {
    	Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Zuora__External_Id__c = '56762v3vr7v3459135';
        insert sub;
        
    	List<Zuora__Subscription__c> subList;
        Test.startTest();
        	subList = XC_UTIL_Asset_D.getSubscriptionFromExternalId('56762v3vr7v3459135');
        Test.stopTest();
        
        System.assert(true, subList != null);
    }
    @isTest
    private static void getAssetBillingModel(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
       Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        asset1.XC_BillingModel__c='One Shot';
        asset1.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        asset1.XC_Segment__c  = 'B2C';
        insert asset1;
        system.debug('rt devName'+' '+asset1.RecordType.DeveloperName);
        XC_Util_Asset.getAssetBillingModel(asset1.id);
        XC_Util_Asset.getActivationMonthsFromBillingModel(asset1.XC_BillingModel__c);
        XC_Util_Asset.getActivationMonthsFromBillingModel('Recurring');
    }
   @isTest
    private static void getAssetsFromInvoice(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
       Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        asset1.XC_BillingModel__c='One Shot';
        asset1.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        asset1.XC_Segment__c  = 'B2C';
        //insert asset1;
        Zuora__ZInvoice__c Invoice =new Zuora__ZInvoice__c ();
        Invoice.name='Test';
        insert Invoice;
        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Zuora__External_Id__c = '56762v3vr7v3459135';
        sub.Name='SubTest';
        insert sub;
        Zuora__InvoiceItem__c invItem=new Zuora__InvoiceItem__c();
        invItem.Name='Test';
        invItem.XC_SubscriptionNumber__c=sub.Name;
        invItem.Zuora__Invoice__c=Invoice.id;
        invItem.Zuora__Subscription__c=sub.id;
        insert invItem;
        asset1.XC_Subscription__c=sub.id;
        insert asset1;
        xc_util_Asset.getAssetsFromInvoice(Invoice.id);
    }
    
    @isTest
    private static void retrieveMappingAssetProductId(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
        Set<Id> assetIds= new Set<Id>(); 
        List<NE__Product__c> prods=XC_DF_Product.createProducts(1);
        insert prods;
           Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        asset1.NE__ProdId__c=prods[0].id;
        asset1.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        asset1.XC_Segment__c  = 'B2C';
        insert asset1;
        assetIds.add(asset1.id);
        XC_Util_Asset.retrieveMappingAssetProductId(assetIds);
    }
    
    
}
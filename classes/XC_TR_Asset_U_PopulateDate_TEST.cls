/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  13/05/2019 
* @description XC_TR_Asset_U_PopulateDate_TEST – Test class for XC_TR_Asset_U_PopulateDate
*/ 
@isTest
public class XC_TR_Asset_U_PopulateDate_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    
    @isTest
    public static void onInsert() {
        List<Asset> assetList  = XC_DF_Asset.createAssets(10);
        insert assetList;
        System.assertEquals(10, assetList.size());
    }
    @isTest
    public static void onUpdate() {
        Integer n = 5;
        List<Asset> assetList  = XC_DF_Asset.createAssets(n);
        List<Contract> contractList = XC_DF_Contract.createContracts(n);
        List<Asset> assetListFirstLookup = XC_DF_Asset.createAssets(n);
        List<Asset> assetListSecondLookup = XC_DF_Asset.createAssets(n);
        
        insert assetList;
        insert contractList;
        insert assetListFirstLookup;
        insert assetListSecondLookup;        
        
        List<Asset> assetListOk = [SELECT Id, Status,NE__Parent_Order_Item__c,NE__Root_Order_Item__c  FROM Asset];
        for(Integer i=0; i < n; i++){
            assetList[i].Status = Label.XC_CL_Asset_StatusInstalled;
            assetList[i].NE__Parent_Order_Item__c = assetListFirstLookup[i].Id;
            assetList[i].NE__Root_Order_Item__c = assetListSecondLookup[i].Id;  
        }
        
        update assetList;
        
        System.assertEquals(n, assetList.size());
    }
    
    @isTest
    public static void populateDates() {
        Integer n = 1;
        List<Asset> assetList  = XC_DF_Asset.createAssets(n);
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(n);
        insert orderItemList;
        
        for(Asset a : assetList){
        	a.XC_Configuration_Item__c = orderItemList[0].Id;
        }
        insert assetList;
        
        List<Asset> assetListOk = [SELECT Id, Status,NE__Parent_Order_Item__c,NE__Root_Order_Item__c  FROM Asset];
        for(Integer i=0; i < n; i++){
            assetList[i].Status = Label.XC_CL_Asset_StatusActive; 
        }
        
        update assetList;
        
        System.assertEquals(n, assetList.size());
    }

    /**
     * @author Mario Scopino mascopino@deloitte.it
     * @date 10/11/2021
     * @description This method set asset start date(NR1652)
     * 
     */
    @isTest
    public static void updateStartDate() {
        Test.startTest();
        Date testDate=date.ValueOf('2021-01-21');
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(10);
        for (Integer i=0;i<10;i++){
            orderItemList[i].NE__StartDate__c=testDate.addMonths(Integer.valueof((Math.random() * 10)));
        }
        insert orderItemList;
        List<Asset> assets = XC_DF_Asset.createAssets(10);
        
        for (Integer i=0;i<10;i++){
            assets[i].XC_Configuration_Item__c=orderItemList[i].Id;
        }
        insert assets;
        
        assets=[SELECT Id, NE__StartDate__c, XC_Configuration_Item__r.NE__StartDate__c FROM Asset];
        Test.stopTest();
        for(Integer i=0;i<10;i++){
            System.assertEquals(assets[i].XC_Configuration_Item__r.NE__StartDate__c,assets[i].NE__StartDate__c , 'Wrong asset start date!');
        }   
    }
}
@isTest
public with sharing class TA_LCC262_Geolocalization_TEST {
   @TestSetup
   static void makeData(){
      Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
      insert accountToInsert;

      Schema.Location loc = new Schema.Location();
      loc.Name = 'test';
      loc.Latitude = 1;
      loc.Longitude = 2;
      //loc.XC_Accuracy__c = currentAccuracy; TO BE REPLACED WHEN CRM CREATE DECIMAL FIELD
      insert loc;  

      Asset assetTest = XC_DF_Asset.createAssets(1)[0];
      assetTest.AccountId = accountToInsert.Id; 
      assetTest.LocationId = loc.id;
      insert assetTest;

      WorkOrder wo = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];       
      wo.AssetId = assetTest.Id;
      wo.AccountId = accountToInsert.Id;
      insert wo;
   }    

   @isTest
   static void getAssetCoordinates(){
      WorkOrder wo = [Select Id FROM WorkOrder LIMIT 1];
      Test.startTest();
      TA_LCC262_Geolocalization.getAssetCoordinates(wo.Id);
      Test.stopTest();
   }

   @isTest
   static void updateCoordinates(){
      Test.startTest();
      TA_LCC262_Geolocalization.updateCoordinates(
         [SELECT Id FROM WorkOrder LIMIT 1].Id, 
         String.valueOf(21412.14142), 
         String.valueOf(124124.24112), 
         null);
      Test.stopTest();
   }

   @isTest
   static void updateCoordinates_2(){
      Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
      insert accountToInsert;

      Asset assetTest = XC_DF_Asset.createAssets(1)[0];
      assetTest.AccountId = accountToInsert.Id; 
      insert assetTest;

      WorkOrder wo = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];       
      wo.AssetId = assetTest.Id;
      wo.AccountId = accountToInsert.Id;
      insert wo;   
      
      Test.startTest();
      TA_LCC262_Geolocalization.updateCoordinates(
         wo.Id, 
         String.valueOf(21412.14142), 
         String.valueOf(124124.24112), 
         null);
      Test.stopTest();
   }

   @isTest
   static void searchAsset() {
      Test.startTest();
      TA_LCC262_Geolocalization.searchAsset('Account.Name', [SELECT Name FROM Account LIMIT 1].Name, null);
      Test.stopTest();
   }

}
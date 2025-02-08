/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  16/05/2019 
* @description XC_LCC025_AssetPath_TEST – Test class for XC_LCC025_AssetPath
*/ 
@isTest
public with sharing class XC_LCC025_AssetPath_TEST {
     //Test Method updateDB
    static testMethod void updateDB(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    List<Asset> a= XC_DF_Asset.createAssets(1);
    insert a;
    String recordId= a[0].Id;
    String assetStatus= a[0].Status; 
    XC_LCC025_AssetPath.updateDB(recordId,assetStatus);
    System.assertEquals(1,a.size());
    Test.stopTest();
    }

}
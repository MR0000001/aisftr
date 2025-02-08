/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  11/03/2020 
* @description XC_TR_Asset_Handler_Test – Test class for XC_TR_Asset_Handler
*/

@isTest
public with sharing class XC_TR_Asset_Handler_Test {
    public static testMethod void testTrigger1(){
        OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
        insert org;
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, 'InOrder');
        insert listOrder;
        NE__Order__c order = listOrder[0];
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;
        List<Asset> assetList  = XC_DF_Asset.createAssets(1);
        assetList[0].XC_Configuration_Item__c = ordIt.Id;
        test.startTest();
        insert assetList;
        update assetList;
        delete assetList;
        XC_TR_Asset_Handler assetHandler =new XC_TR_Asset_Handler();
       assetHandler.onAfterUnDelete(null); 
        test.stopTest();
    }

}
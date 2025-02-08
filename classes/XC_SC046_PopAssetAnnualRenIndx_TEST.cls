/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 22/03/2021
* @description XC_SC046_PopAssetAnnualRenIndx_TEST – Test class for XC_SC046_PopulateAssetAnnualRenewIndex
*/

@isTest
public without sharing class XC_SC046_PopAssetAnnualRenIndx_TEST {


    @isTest
    static void executeBatch() {
        Test.startTest(); 
        Date firstOfLastMonthDate = Date.today().addMonths(-1).addYears(-1).toStartOfMonth();
        Date firstOfNextMonthDate = firstOfLastMonthDate.addMonths(2);
        List<Asset> listOfAsset =  XC_DF_Asset.createAssets(1);
        listOfAsset[0].XC_ContractEndDate__c = Date.today().addYears(2);
        listOfAsset[0].XC_ContractStartDate__c = Date.today().addYears(-1);
        listOfAsset[0].XC_Product_Type__c = 'Service';
        listOfAsset[0].Status = 'Active';
        listOfAsset[0].XC_ActivationDate__c = Date.today().addYears(-1);
        insert listOfAsset;
        System.debug('###listOfAsset --->'+listOfAsset);
        String query = 'SELECT Id, XC_AnnualRenewalDate__c, XC_AnnualRenewalDateIndex__c FROM Asset WHERE Status <> \'' +'Inactive' + '\' AND XC_ContractEndDate__c != null AND((XC_ContractStartDate__c >= ' + String.valueOf(firstOfLastMonthDate) +' AND XC_ContractStartDate__c < ' + String.valueOf(firstOfNextMonthDate) +') OR (XC_AnnualRenewalDateIndex__c >= ' + String.valueOf(firstOfLastMonthDate) +' AND XC_AnnualRenewalDateIndex__c < ' + String.valueOf(firstOfNextMonthDate) +' )) AND XC_AnnualRenewalDate__c != null AND XC_CheckAnnualRenewalDate__c = false AND ( XC_Product_Type__c IN (\'' +'Service' + '\',\'' +'Equipment' + '\') OR ( XC_Product_Type__c = \''+'Bundle'+'\' AND XC_Product_Subtype__c <> \''+'Parameter'+'\' AND XC_BillingModel__c LIKE \''+'%renting%'+'\' AND NE__Bundle_Configuration__c = null) OR ( XC_Product_Type__c = \''+'Coverage'+'\' AND XC_Segment__c = \''+'B2C'+'\' AND XC_LegalEntity__c = \''+'EnelXItalia'+'\' AND XC_BillingModel__c = \''+'Recurring'+'\' ))';
        System.debug('###Databasequery-->'+Database.query(query));
        XC_SC046_PopulateAssetAnnualRenewIndex myClass = new XC_SC046_PopulateAssetAnnualRenewIndex();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }
}
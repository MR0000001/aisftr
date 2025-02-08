/**
* @author FirstName : Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
* @date Creation 27/01/2020
* @date Modification dd/mm/yyyy
* @description Gii_LC014_Doxee_TEST
*/

@isTest(SeeAllData=false)
public class Giic_LC014_Doxee_TEST {
 
   @isTest static  void setupData() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__SerialControlled__c=true;
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        update objProdRef;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Test.startTest();
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr = Gii_LCC014_Doxee.FetchUser(giic_UtilityClass_Test.objPO.Id);
        Test.stopTest();
   }
}
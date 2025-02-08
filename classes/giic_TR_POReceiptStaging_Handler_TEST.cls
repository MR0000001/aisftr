/**
* @author FirstName : Patrizia Arcidiacono - patrizia.arcidiacono@nttdata.com
* @date Creation 28/01/2020
* @date Modification dd/mm/yyyy
* @description giic_TR_POReceiptStaging_Handler_TEST
*/

@isTest(SeeAllData=false)
public class giic_TR_POReceiptStaging_Handler_TEST {

       // Methods for testing
   private static testMethod void setupData() {
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
        system.debug('@@@@ Aftere creation po');
        gii__PurchaseOrderReceiptStaging__c POStaging= new gii__PurchaseOrderReceiptStaging__c(giic_IntegrationOperation__c='Cancellation Request', giic_IntegrationStatus__c='Not Started', giic_PurchaseOrder__c=giic_UtilityClass_Test.objPO.Id);
        insert POStaging;
        
        system.debug('@@@@ insert POSTagin:' + POStaging);
     
        POStaging.giic_IntegrationStatus__c='Ready to Integrate';
        update POStaging;
        system.debug('@@@@ update POSTagin:' + POStaging);
        List<gii__PurchaseOrderReceiptStaging__c> POStagingDel=[Select id from gii__PurchaseOrderReceiptStaging__c where id =:POStaging.Id];
         Test.startTest();
        delete POStagingDel;
        system.debug('@@@@ del POSTaging1');
        Test.StopTest();
        undelete POStaging;
        system.debug('@@@@ undel POSTaging2');
       
   }  
}
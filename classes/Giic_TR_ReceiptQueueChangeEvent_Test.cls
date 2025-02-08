/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TR_POChangeEvent_Test – Test Class  for Change Event Trigger for INtegration User Stories.
*/
@isTest
public class Giic_TR_ReceiptQueueChangeEvent_Test {
  @isTest static void testNewPO() {
    Test.enableChangeDataCapture();
 Giic_UtilityClass_Test.systemPolicyCreation();
      Giic_UtilityClass_Test.gloviaSystemSettingCreation();
      Giic_UtilityClass_Test.accountCreation();
      Giic_UtilityClass_Test.wareHouseGroupCreation();
      Giic_UtilityClass_Test.warehouseCreation();
      Giic_UtilityClass_Test.locationCreation();
       Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
      Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[1].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        update Giic_UtilityClass_Test.lstWh;
     gii__Product2Add__c[] objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c];
       System.assertEquals(true, objProdRef.size()>0);
     Giic_UtilityClass_Test.transferOrderCreation();
      Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWh,objProdRef);
        Giic_UtilityClass_Test.tOLineCreation(objProdRef[0]);
        Giic_UtilityClass_Test.inventoryReserveCreation(objProdRef[0],Giic_UtilityClass_Test.lstProductInventory[0]);
        Giic_UtilityClass_Test.receiptQCreation(Giic_UtilityClass_Test.lstProductInventory[0]);
       Test.getEventBus().deliver();
       Giic_UtilityClass_Test.objRecQueue.giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate; 
       Giic_UtilityClass_Test.objRecQueue.giic_TargetSystem__c=System.Label.giic_TargetSystemAFC;
       Giic_UtilityClass_Test.objRecQueue.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate;
       update  Giic_UtilityClass_Test.objRecQueue;
        Test.getEventBus().deliver();
  
  }   

}
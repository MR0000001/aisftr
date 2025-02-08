/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
* @date Creation 03/07/2019
* @date Modification 04/07/2019
* @description Giic_TR_POChangeEvent_Test – Test Class  for Change Event Trigger for INtegration User Stories.
*/
@isTest
public class Giic_TR_TOChangeEvent_Test {
  @isTest static void testNewPO() {
    Test.enableChangeDataCapture();
      Giic_UtilityClass_Test.systemPolicyCreation();
      Giic_UtilityClass_Test.gloviaSystemSettingCreation();
      Giic_UtilityClass_Test.accountCreation();
      Giic_UtilityClass_Test.wareHouseGroupCreation();
      Giic_UtilityClass_Test.warehouseCreation();
      Giic_UtilityClass_Test.locationCreation();
      Giic_UtilityClass_Test.productCreation();
      Giic_UtilityClass_Test.transferOrderCreation();
       gii__Product2Add__c[] objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
       System.assertEquals(true, objProdRef.size()>0);
       Test.getEventBus().deliver();
      Giic_UtilityClass_Test.objTO.giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate;
      Giic_UtilityClass_Test.objTO.giic_Approved__c= true;
      Giic_UtilityClass_Test.objTO.giic_TargetSystem__c=System.Label.giic_TargetSystem3PL;
      Giic_UtilityClass_Test.objTO.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate;
     update Giic_UtilityClass_Test.objTO;
      Test.getEventBus().deliver();
  
  }   
}
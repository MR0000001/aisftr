/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description Giic_BA001_UpdateToAfterMerge_Test – for Giic_BA001_TOcreateROPBatch test class
*/
@isTest(SeeAllData=false)
public class Giic_BA004_UpdateToAfterMerge_Test {
/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_BA001_UpdateToAfterMerge_Test.
*/
    public static testMethod void testReceiveData(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
       
        Giic_UtilityClass_Test.productCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.pricebookCreation();
        Giic_UtilityClass_Test.purchaseOrderCreation();
        gii__Product2Add__c[] objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1
                                         ];
        System.assertEquals(true, objProdRef.size()>0);
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
        Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.tOLineCreation(objProdRef[0]);
        Set<Id> toIDs= new Set<Id>();
        toIDs.add(Giic_UtilityClass_Test.objTO.Id);
      Id batchJobId = Database.executeBatch(new Giic_BA004_UpdateTOAfterMerge(toIDs), 20);
     
    }
}
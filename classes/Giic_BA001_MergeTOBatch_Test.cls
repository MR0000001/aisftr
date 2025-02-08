/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description Giic_BA001_TOcreateROPBatch_Test – for Giic_BA001_TOcreateROPBatch test class
*/
@isTest(SeeAllData=false)
public class Giic_BA001_MergeTOBatch_Test {
/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 17/06/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_BA001_TOCreateROPBatch.
*/
    public static testMethod void processMergeForTOTest(){
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
        Giic_UtilityClass_Test.insertTO(); 
        List<gii__TransferOrder__c> listTO=new List<gii__TransferOrder__c>();    
        listTO=[SELECT Id,giic_status__c,giic_IntegrationStatus__c, giic_Approved__c FROM gii__TransferOrder__c];
        for(gii__TransferOrder__c objTO : listTO)
        {
            objTO.giic_Approved__c=True;
            objTO.giic_status__c='Open'; 
            objTO.giic_IntegrationStatus__c='Not Started';
        }
        System.assertEquals(true, listTO.size()>0);
        update listTO; 
        List<gii__Product2Add__c> listProdRef = [select id,gii__ProductReference__c,gii__ProductCode__c from gii__Product2Add__c];
        Giic_UtilityClass_Test.tOLineCreationLST(listProdRef);
        Giic_BA001_MergeTOBatch batchobj = new Giic_BA001_MergeTOBatch();
        Id batchId=DataBase.executeBatch(batchobj); 
         String sch = '0 0 0 * * ?'; 
        system.schedule('Test Territory Check', sch, batchobj); 
    }
}
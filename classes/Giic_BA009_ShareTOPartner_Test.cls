/**
* @author FirstName : Lorenzo Orlanducci
* @date Creation 24/01/2020
* @date Modification dd/mm/yyyy
* @description Giic_BA009_ShareTOPartner_Test– Test class for Giic_BA009_ShareTOPartner class
*/
@isTest(SeeAllData=false)
public class Giic_BA009_ShareTOPartner_Test {

     @isTest static void testReceiveData(){
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
        List<gii__TransferOrder__c> toList = new  List<gii__TransferOrder__c>();
        toList.add(Giic_UtilityClass_Test.objTO);
         
        Giic_BA009_ShareTOPartner batchobj = new Giic_BA009_ShareTOPartner();
        Id batchId=DataBase.executeBatch(batchobj); 
     
    }
    
    @isTest static void manualShareReadTest(){
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
        List<gii__TransferOrder__c> toList = new  List<gii__TransferOrder__c>();
        toList.add(Giic_UtilityClass_Test.objTO);
        User u = XC_DF_User.createUserAdmin();
        List<Id> userId = new List<Id>();
        userId.add(u.Id);
        map<Id,List<Id>> transferOrdIdTouserOrGroupId = new map<Id,List<Id>>();
        transferOrdIdTouserOrGroupId.put(Giic_UtilityClass_Test.objTO.Id, userId);
        giic_UTIL_TransferOrderSharing.manualShareRead(transferOrdIdTouserOrGroupId);
     
    }
}
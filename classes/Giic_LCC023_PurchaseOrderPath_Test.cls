@isTest
public class Giic_LCC023_PurchaseOrderPath_Test {
    
    @isTest
    static void saveStatusApprovedTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        gii__PurchaseOrderLine__c pol = Giic_UtilityClass_Test.objPOLine;
        po.giic_status__c = 'Open';
        update po;
        Giic_UtilityClass_Test.objPO.giic_status__c = 'Sent To Supplier';
        update po;
        po.giic_status__c = 'Reviewed';
        po.giic_Note__c = 'Reviewed';
        update po;
		po.giic_PurchasingGroup__c = 'K';
		po.giic_PurchasingOrganization__c = 'P';
        pol.giic_AccountAssignmentCategory__c = 'K';
        pol.giic_Plant__c = 'P';
        update po;
        update pol;
        po.giic_Status__c = 'Approved';
        update po;
        System.debug('@@@toal lines' +po.gii__TotalLines__c);
        System.debug('@@@toal filled lines' +po.giic_TotalFilledLines__c);
        test.startTest();
        String recordId = Giic_UtilityClass_Test.objPO.Id;
        String stepName = Giic_UtilityClass_Test.objPO.giic_Status__c;
        Giic_LCC023_PurchaseOrderPath.saveStatus(recordId, stepName);
        User currentUser = [SELECT Id, XC_EnabledToSkip__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        Giic_LCC023_PurchaseOrderPath.checkIfApprover(recordId,currentUser);
        test.stopTest();
    }
    

    
     @isTest
    static void saveStatusApprovedITATest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);    
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.purchaseOrderLineCreation(prodRefObj);
        gii__PurchaseOrder__c po = Giic_UtilityClass_Test.objPO;
        
        po.giic_legalEntity__c = 'EnelXItalia';
        update po;
        test.startTest();
        String recordId = Giic_UtilityClass_Test.objPO.Id;
        String stepName = Giic_UtilityClass_Test.objPO.giic_Status__c;
        Giic_LCC023_PurchaseOrderPath.saveStatus(recordId, stepName);
        User currentUser = [SELECT Id, XC_EnabledToSkip__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        Giic_LCC023_PurchaseOrderPath.checkIfApprover(recordId,currentUser);
        test.stopTest();
    }

}
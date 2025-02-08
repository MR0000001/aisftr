/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Massimiliano Avallone - massimiliano.avallone@nttdata.com & Andrea Bravaccino
* @date Creation 07/08/2019
* @description XC_TR_WorkOrder_U_ManageSATO_TEST – Tst class for XC_TR_WorkOrder_U_ManageSATO
*/

@isTest
private class XC_TR_WorkOrder_U_ManageSATO_TEST {

    @TestSetup
    static void setup() {
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(2);
        User u = XC_DF_User.createUserAdmin();
        u.Username = 'noCandidate@gmail.com';
        insert u;
        ServiceResource servRes = new ServiceResource(Name = Label.XC_CL_NoCandidateFound, 
                                                      XC_Account__c = accList[0].Id, 
                                                      isCapacityBased = true,
                                                      RelatedRecordId = u.Id, 
                                                      isActive = true );
        insert servRes;
        Account partnerAccount = accList[1];
        partnerAccount.XC_SATO__c = true;
        partnerAccount.XC_Brand__c = 'test brand';
        update partnerAccount;
        NE__Catalog_Item__c ci = XC_DF_CatalogItem.createCatalogItem();
        ci.XC_Brand__c = 'test brand';
        insert ci;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__CatalogItem__c = ci.Id;
        insert assetList;
        Account acc = [SELECT ID FROM Account WHERE Id = :assetList[0].AccountId][0];
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Repair - SATO', 'Repair');
        listWorkOrder[0].XC_SerialNumber__c = '0123456789';
        listWorkOrder[0].AccountId = acc.Id;
        listWorkOrder[0].AssetId = assetList[0].Id;
        listWorkOrder[0].XC_Digitized__c = true;
        listWorkOrder[0].XC_ToBeManuallyDigitalized__c = true;
        listWorkOrder[0].XC_LegalEntity__c = 'EndesaX';
        listWorkOrder[0].XC_Segment__c = 'B2C';
        insert listWorkOrder; 
        Test.stopTest();
    }

    @isTest
    static void manageSatoWithouSA() {
        Test.startTest();
        WorkOrder wo = [SELECT ID, XC_StatusReason__c FROM WorkOrder][0];
        wo.XC_StatusReason__c = Label.XC_CL_WorkOrder_SATObreakdown;
        wo.XC_Digitized__c = true;
        wo.XC_ToBeManuallyDigitalized__c = true;
        update wo;
        Test.stopTest();        
    }

    @isTest
    static void manageSatoWithSA() {
        Test.startTest();
        WorkOrder wo = [SELECT Id, XC_StatusReason__c FROM WorkOrder][0];
        List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(new List<WorkOrder>{wo});
        insert sa;
        wo.XC_Digitized__c = true;
        wo.XC_ToBeManuallyDigitalized__c = true;
        wo.XC_StatusReason__c = Label.XC_CL_WorkOrder_SATObreakdown;
        update wo;
        Test.stopTest();      
    }

}
/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 22/01/2020
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_UpdStatusChild_TEST – Test Class of XC_TR_WorkOrder_U_updateStatusChildWO
*/
@isTest
public class XC_TR_WorkOrder_U_UpdStatusChild_TEST {
	@TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        /*List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
        ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = 'No Candidate Found';
        serviceRes.XC_Account__c = accountList[0].Id;
        serviceRes.IsActive = true;
        serviceRes.IsCapacityBased = true;
        serviceRes.XC_AutomaticDeactivation__c = true;
        serviceRes.RelatedRecordId = usersList[1].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
        serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;*/
    }
    
    static testMethod void updateStatusOnChildTest() {
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        for(Asset a : assetList){
            a.XC_LegalEntity__c = 'EndesaX';
            a.XC_Address__c = addressList[0].Id;
        }
        insert assetList; 
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, 'Substitution');
        for(WorkOrder wo : woList){
            wo.AssetId = assetList[0].Id;
            wo.Status = 'Assigned';
        }
        insert woList;
        List<WorkOrder> woListChildren =  XC_DF_WorkOrder.createWorkOrders(1, 'Return');
        for(WorkOrder wo : woListChildren){
            wo.ParentWorkOrderId = woList[0].Id;
            wo.Status = 'Assigned';
        }
        insert woListChildren;
        Test.startTest();
        woList[0].Status = 'In Progress';
        update woList;
        System.assertEquals(1, woListChildren.size());
        Test.stopTest();
    }
}
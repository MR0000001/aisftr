/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification 11/05/2022 - GDB - PERFORMANCE IMPROVEMENT - MAY2022
* @description XC_TR_WorkOrder_U_SetCaseStatus_TEST – Test Class of XC_TR_WorkOrder_U_SetParentCaseStatus
*/ 

@isTest
public class XC_TR_WorkOrder_U_SetCaseStatus_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
		
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        insert contList;
        List<Account> accList = [SELECT Id FROM Account];
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Active';
        assetList[0].ContactId = contList[0].Id;
        assetList[0].AccountId = accList[0].Id;
        insert assetList;
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].AssetId = assetList[0].Id;
        caseList[0].ContactId = contList[0].Id;
        caseList[0].AccountId = contList[0].AccountId; //accList[0].Id;
        caseList[0].Status = 'ESTA001';
        insert caseList;
    }
    
    static testMethod void onInsert(){
        
        List<Case> listInsertedCase = [SELECT Id FROM Case];
        listInsertedCase[0].Status = 'ESTA003';
        update listInsertedCase;
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        woRepair[0].CaseId = listInsertedCase[0].Id;
        
        Test.startTest();
        insert woRepair;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onUpdate(){
        
        Test.startTest(); 
        User u = XC_DF_User.createUserAdmin();
        insert u;    
        List<Case> listInsertedCase = [SELECT Id FROM Case];
        
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        woRepair[0].CaseId = listInsertedCase[0].Id;
        woRepair[0].Status = 'Assigned';
        insert woRepair;
        
        woRepair[0].Status = 'In Progress';
        woRepair[0].OwnerId =  u.Id;   
        
        update woRepair;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
}
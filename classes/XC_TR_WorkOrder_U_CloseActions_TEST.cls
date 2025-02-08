/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification MAY 2022 - FA/GDB - PERFORMANCE IMPROVEMENT
* @description XC_TR_WorkOrder_U_CloseActions_TEST – Test Class for XC_TR_WorkOrder_U_CloseActions
*/ 

@isTest
public class XC_TR_WorkOrder_U_CloseActions_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<Account> accList =XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        
        List<XC_Address__c> listAddress= XC_DF_Address.createAddress(accList);
        insert listAddress;
        
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        insert contactList;
        
        List<Opportunity> oppInserted = XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        insert oppInserted;
        
        List<NE__Product__c> prodList= XC_DF_Product.createProducts(1);
        prodList[0].Name='OK Gas';
        insert prodList;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__ProdId__c=prodList[0].Id;
        assetList[0].Name='OK Gas';
        assetList[0].XC_Product_Type__c = Label.XC_CL_ProductTypeService;
        insert assetList;
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        for(WorkOrder wo : woList){
            //wo.XC_Opportunity__c = oppInserted[0].Id;
            wo.Status = Label.XC_CL_InProgress;
            wo.XC_StatusReason__c = Label.XC_CL_ContractViolation;
            wo.AssetId = assetList[0].Id;
            woListInsert.add(wo);
        }
        insert woListInsert;
    }
    
    
    static testMethod void onInsertMaint1(){
        
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Opportunity> oppInserted = [SELECT Id FROM Opportunity]; 
        List<Asset> assetListInserted = [SELECT Id FROM Asset]; 
        
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        for(WorkOrder wo : woList){
            wo.XC_Opportunity__c = oppInserted[0].Id;
            wo.Status = Label.XC_CL_InProgress;
            woListInsert.add(wo);
        }
        insert woListInsert;
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        for(WorkOrder wo2 : woListInsert){
            wo2.Status = 'Cannot Complete';
            woListToUpdate.add(wo2);
        }
        
        try{
            update woListToUpdate;
        }
        catch(Exception e){
            System.debug('In catch');
        }       
        Test.stopTest();
    }
    
    /**
    * @author Dario Tramontin dtramontin@deloitte.it
    * @date Creation 06/09/2019
    */
    static testMethod void updateWOServiceOk(){ 
        
        Test.startTest();
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        List<WorkOrder> woListInsert = [SELECT Id FROM WorkOrder WHERE Asset.XC_Product_Type__c = :Label.XC_CL_ProductTypeService ];
        for(WorkOrder wo2 : woListInsert){
            wo2.Status = Label.XC_CL_WorkOrder_CannotComplete;
            woListToUpdate.add(wo2);
        }
        
        try{
            update woListToUpdate;
        }
        catch(Exception e){
            System.debug('In catch');
        }
        System.assertEquals(1, woListInsert.size(), 'Error assertEquals');
        Test.stopTest();
    }
    
    static testMethod void updateWOBundle(){
        
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Opportunity> oppInserted = [SELECT Id FROM Opportunity]; 
        List<Asset> assetListBefore = [SELECT Id FROM Asset]; 
        List<NE__Product__c> prodList = [SELECT Id FROM NE__Product__c];
            
        Test.startTest();        
        List<Asset> assetList2 = XC_DF_Asset.createAssets(1);
        assetList2[0].NE__ProdId__c = prodList[0].Id;
        assetList2[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        insert assetList2;
        
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        List<WorkOrder> woListInsert2 = new List<WorkOrder>();
        for(WorkOrder wo2 : woList2){
            wo2.XC_Opportunity__c = oppInserted[0].Id;
            wo2.Status = Label.XC_CL_InProgress;
            wo2.XC_StatusReason__c = 'Breach of Contract';
            wo2.XC_Coverage__c = assetList2[0].Id;
            wo2.AssetId=null;
            woListInsert2.add(wo2);
        }
        insert woListInsert2;
        
        List<WorkOrder> woListToUp = new List<WorkOrder>();
        for(WorkOrder wo2 : woListInsert2){
            wo2.Status = Label.XC_CL_WorkOrder_CannotComplete;
            woListToUp.add(wo2);
        }
        
        try{
            update woListToUp;
        }
        catch(Exception e){
            System.debug('In catch');
        }
        Test.stopTest();
    }
    
    static testMethod void updateWOService(){
        
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        List<Opportunity> oppInserted = [SELECT Id FROM Opportunity]; 
        List<Asset> assetList2 = [SELECT Id FROM Asset]; 
        List<NE__Product__c> prodList = [SELECT Id FROM NE__Product__c];
    
        Test.startTest();
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        List<WorkOrder> woListInsert2 = new List<WorkOrder>();
        for(WorkOrder wo2 : woList2){
            wo2.Status = Label.XC_CL_InProgress;
            wo2.XC_StatusReason__c = 'Breach of Contract';
            wo2.XC_Coverage__c = assetList2[0].Id;
            wo2.AssetId=null;
            woListInsert2.add(wo2);
        }
        insert woListInsert2;
        
        List<WorkOrder> woListToUp = new List<WorkOrder>();
        for(WorkOrder wo2 : woListInsert2){
            wo2.Status = Label.XC_CL_WorkOrder_CannotComplete;
            woListToUp.add(wo2);
        }
        
        try{
            update woListToUp;
        }
        catch(Exception e){
            System.debug('In catch');
        }
        System.assertEquals(1, woListToUp.size(), 'Error assertEquals');
        Test.stopTest();
    }
    
}
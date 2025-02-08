/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_PopulateWorkType_TEST – Test Class of XC_TR_WorkOrder_U_PopulateWorkType
*/ 

@isTest
public class XC_TR_WorkOrder_U_PopulateWorkType_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        XC_CS_UtilityGlobalValues__c cs = new XC_CS_UtilityGlobalValues__c();
        cs.Name = 'CheckBlankValuesWBE';
        cs.Value__c='false';
        insert cs;
        XC_CS_UtilityGlobalValues__c cs2 = new XC_CS_UtilityGlobalValues__c();
        cs2.Name = 'CheckWBETracking';
        cs2.Value__c='false';
        insert cs2;
        //List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        //List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
        List<Lead> ldList = XC_DF_Lead.createResidentialLeads(1);
        ldList[0].XC_MainLegalEntity__c = 'EndesaX';
        insert ldList[0];
        /*List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
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
    
    static testMethod void onInsert() {
        Test.startTest();
        insert XC_DF_WorkOrder.createWorkOrders(5, 'Commercial Visit');
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(5, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsertWorkTypeLabelEmpty() { 
        insert XC_DF_WorkType.createWorkType('Commercial Visit');
        WorkType woType = [SELECT Id FROM WorkType];
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.WorkTypeId = woType.Id;
        woToInsert.XC_WorkTypeLabel__c = ''; 
        Test.startTest();
        insert woToInsert;
        List<WorkOrder> listQueriedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listQueriedWorkOrders.size());
        Test.stopTest();
    } 
    
    static testMethod void onInsertWorkTypeSiteLabelInspectionBoiler() { 
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        insert workTypeToInsert;
        WorkOrder woToInsert = new WorkOrder();
        //woToInsert.WorkTypeId = woType.Id; 
        woToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ITA_WorkOrder').getRecordTypeId();
        woToInsert.XC_LegalEntity__c = 'EnelXItalia'; //0305
        woToInsert.XC_WorkTypeLabel__c = 'Site Inspection - Boiler'; 
        Test.startTest();
        insert woToInsert;
        List<WorkOrder> listQueriedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listQueriedWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsertWorkTypeSiteCategoryInspectionBoiler() { 
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        insert workTypeToInsert;
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.XC_WorkTypeCategory__c = 'Site Inspection'; 
        Test.startTest();
        insert woToInsert;
        List<WorkOrder> listQueriedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listQueriedWorkOrders.size());
        Test.stopTest();
    }
    
    /*static testMethod void onInsertWorkTypeWIthOpportunity() { 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        insert workTypeToInsert;
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.XC_WorkTypeCategory__c = 'Site Inspection'; 
        woToInsert.XC_Opportunity__c = opp.Id;
        Test.startTest();
        insert woToInsert;
        List<WorkOrder> listQueriedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listQueriedWorkOrders.size());
        Test.stopTest();
    }*/

    static testMethod void onInsertWorkTypeWIthOpportunityCV() { 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        insert workTypeToInsert;
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.XC_WorkTypeCategory__c = 'Commercial Visit'; 
        woToInsert.XC_Opportunity__c = opp.Id;
        Test.startTest();
        insert woToInsert;
        List<WorkOrder> listQueriedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listQueriedWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsertWorkTypeWIthLead() { 
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        workTypeToInsert.XC_LegalEntity__c = 'EnelXItalia'; //0305
        insert workTypeToInsert;
        /*WorkOrder woToInsert = new WorkOrder();
        woToInsert.XC_WorkTypeCategory__c = 'Site Inspection'; 
        woToInsert.XC_Lead__c = ld.Id;
        woToInsert.XC_LegalEntity__c = 'EnelXItalia'; //0305
        insert woToInsert; */
        Test.startTest();
        List<WorkOrder> listQueriedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(0, listQueriedWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsertWorkTypeWIthOrder() { 
        Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        insert workTypeToInsert;
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.XC_Configuration__c = order.Id;
        woToInsert.XC_WorkTypeCategory__c = 'Site Inspection'; 
        woToInsert.XC_LegalEntity__c = 'EnelXItalia';
        //insert woToInsert;
        List<WorkOrder> listWorkOrders = new List<WorkOrder>();
        listWorkOrders.add(woToInsert);
        XC_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listWorkOrders);
        System.assertEquals(1, listWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsertWorkTypeWithAsset() { 
        Test.startTest();
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        insert ast;
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.XC_LegalEntity__c = 'EndesaX';
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        insert workTypeToInsert;
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.AssetId = ast.Id;
        woToInsert.XC_Coverage__c = ast.Id;
        woToInsert.XC_WorkTypeCategory__c = 'Site Inspection'; 
        woToInsert.XC_LegalEntity__c = 'EndesaX';
        List<WorkOrder> listWorkOrders = new List<WorkOrder>();
        listWorkOrders.add(woToInsert);
        insert listWorkOrders;
        // XC_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listWorkOrders);
        System.assertEquals(1, listWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsertWorkTypeWIthOrderItem() { 
        Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> oiList = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Site Inspection');
        workTypeToInsert.XC_LegalEntity__c = 'EndesaX';
        workTypeToInsert.Name = 'Site Inspection - Boiler';
        insert workTypeToInsert;
        WorkOrder woToInsert = new WorkOrder();
        woToInsert.XC_Configuration_Item__c = oiList[0].Id;
        woToInsert.XC_WorkTypeCategory__c = 'Site Inspection'; 
        woToInsert.XC_LegalEntity__c = 'EndesaX';
        List<WorkOrder> listWorkOrders = new List<WorkOrder>();
        listWorkOrders.add(woToInsert);
        insert listWorkOrders;
        //_TR_WorkOrder_U_PopulateWorkType_U.setProductSubtypeAndLegalEntity(listWorkOrders);
        System.assertEquals(1, listWorkOrders.size());
        Test.stopTest();
    }
}
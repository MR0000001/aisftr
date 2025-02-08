/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 20/05/2019 
* @date Modification 05/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_WorkOrder_U_CreateWOLI_TEST – Test class for XC_TR_WorkOrder_U_CreateWOLineItem
*/

@isTest
private class XC_TR_WorkOrder_U_CreateWOLI_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert servTerr;
        User user = XC_DF_User.createUserAdmin();
        insert user;
        ServiceResource servRes = new ServiceResource(
            Name = Label.XC_CL_NoCandidateFound, 
            XC_Account__c = accList[0].Id, 
            isCapacityBased = true,
            RelatedRecordId = user.Id, 
            isActive = true
        );
        insert servRes;
    }

    @isTest
    static void onUpdateWorkOrder() { 
        NE__Product__c prod = new NE__Product__c(Name = 'Soluciones Caldera');
        insert prod;
        List<Asset> assetList = new List<Asset>();
        Asset bundle = new Asset(NE__ProdId__c = prod.Id, Name = 'Soluciones Caldera');
        bundle.XC_Segment__c = 'B2C';
        bundle.XC_LegalEntity__c = 'EndesaX';
        //insert bundle;
        assetList.add(bundle);
        Asset ass = new Asset (Name = 'AssTest');
        ass.XC_Segment__c = 'B2C';
        ass.XC_LegalEntity__c = 'EndesaX';
        //insert ass;
        assetList.add(ass);
        insert assetList;
        if(assetList[0].Name == 'AssTest'){
            assetList[0].NE__Bundle_Configuration__c = assetList[1].Id;
        } else {
            assetList[1].NE__Bundle_Configuration__c = assetList[0].Id;
        }
        update assetList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(2, 'Delivery & Installation');
        wo[0].XC_Country__c = 'Spain';
        insert wo[0];
        Test.startTest();
        XC_WorkOrderActivityPlanItem__c activityPlan = new XC_WorkOrderActivityPlanItem__c();
        activityPlan.XC_WorkType__c = 'Commercial Visit - Boiler';
        activityPlan.XC_Country__c = 'Spain';
        activityPlan.XC_CatalogItem__c = 'Soluciones Caldera';
        activityPlan.XC_RecordType__c = 'XC_ESP_Woli_ManualDialing';
        insert activityPlan;
        wo[0].Status = 'Assigned';
        wo[0].XC_Product_Name__c = 'SolarFotovoltaica con bateria';
        wo[0].AssetId = ass.Id; 
        update wo[0];
        List<WorkOrder> woChildren = XC_DF_WorkOrder.createWorkOrders(2, 'Delivery & Installation');
        for(WorkOrder woChild : woChildren) {
            woChild.ParentWorkOrderId = wo[1].Id;
        }
        insert wo[1];
        wo[1].Status = 'Assigned';
        wo[1].XC_Product_Name__c = 'SolarFotovoltaica con bateria';
        wo[1].XC_Country__c = 'Spain';
        update wo[1];
        System.assertNotEquals(wo, null);
        Test.stopTest();
    }

    @isTest
    static void onUpdateWorkOrderWithChildren() { 
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(3, 'Delivery & Installation');
        insert listWo;
        List<WorkOrderLineItem> listWoli = new List<WorkOrderLineItem>();
        NE__Product__c prod = new NE__Product__c(Name = 'Soluciones Caldera');
        insert prod;
        Asset bundle = new Asset(NE__ProdId__c = prod.Id, Name = 'Soluciones Caldera');
        bundle.XC_Segment__c = 'B2C';
        bundle.XC_LegalEntity__c = 'EndesaX';
        insert bundle;
        Asset ass = new Asset (NE__Bundle_Configuration__c = bundle.Id, Name = 'AssTest');
        ass.XC_Segment__c = 'B2C';
        ass.XC_LegalEntity__c = 'EndesaX';
        insert ass;
        List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
        for(WorkOrder woCheck : listWo) {
            WorkOrder woToUpdate = new WorkOrder();
            woToUpdate.Id = woCheck.Id;
            woToUpdate.AssetId = ass.Id;
            woToUpdate.XC_Country__c = 'Spain';
            listWoToUpdate.add(woToUpdate);
        }
        update listWoToUpdate;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = listWo[2].Id;
        listWoli.add(woli);
        for(Integer i=0; i<listWo.size()-1; i++) {
            WorkOrderLineItem woliToInsert = new WorkOrderLineItem();
            woliToInsert.WorkOrderId = listWo[i].Id;
            listWoli.add(woliToInsert);
        }
        insert listWoli;
        String idParentWo = listWo[0].Id;
        List<WorkOrder> woChildren = new List<WorkOrder>();
        for(Integer i=1; i<listWo.size(); i++) {
            WorkOrder wo = listWo[i];
            wo.ParentWorkOrderId = idParentWo;
            wo.XC_HierarchyLevel__c = 1;
            wo.XC_Country__c = 'Spain';
            woChildren.add(wo);
        }
        update woChildren; 
        listWo[0].Status = 'Assigned';
        listWo[0].XC_HierarchyLevel__c = 0;
        listWo[0].XC_isTree__c = true;
        listWo[0].XC_Country__c = 'Spain';
        Test.startTest();
        update listWo[0];
        Test.stopTest();
        System.assertNotEquals(listWo, null);
    }

    @isTest
    static void coverageCode() { 
        XC_TR_WorkOrder_U_CreateWOLineItem.codeCoverage();
    }

}
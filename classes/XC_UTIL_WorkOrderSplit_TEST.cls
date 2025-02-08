/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 09/08/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_WorkOrderSplit_TEST for XC_UTIL_WorkOrderSplit     
*/
@isTest
public class XC_UTIL_WorkOrderSplit_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;   
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResources(1);
        listServiceResource[0].Name = Label.XC_CL_NoCandidateFound;
        update listServiceResource;        
    } 

    @isTest
    static void splitWorkOrder() {
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert listWorkOrder;

        List<WorkOrder> listWorkOrderSon = XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_CommercialVisit);
        listWorkOrderSon[0].ParentWorkOrderId = listWorkOrder[0].id;
        insert listWorkOrderSon;  

        List<SkillRequirement> skillReqList = XC_DF_WorkOrder.createWorkOrderSkillRequirement (listWorkOrder);
        insert skillReqList;
        
        Test.startTest();
        Map<String, List<WorkOrder>> mapListWorkOrder = XC_UTIL_WorkOrderSplit.splitWorkOrdersByTechSkill(listWorkOrder);
        XC_UTIL_WorkOrderSplit.splitWorkOrdersByTechSkill(skillReqList);
        Test.stopTest();
        System.assert(mapListWorkOrder!=null);
    }
    @isTest
    static void insertMiddleWorkOrder() {
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(1);
        insert addresses;

        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(4, Label.XC_CL_CommercialVisit);
        listWorkOrder[1].XC_HierarchyLevel__c = 1;
        listWorkOrder[1].PostalCode = '28280';
        listWorkOrder[1].City = 'Madrid';
        listWorkOrder[1].Country = 'Spain';
        listWorkOrder[1].XC_NumberWorkOrdersDI__c = 2;
        listWorkOrder[1].XC_Address__c = addresses[0].id;
        insert listWorkOrder;
        List<String> listIdFather = new List<String>();
        for(WorkOrder father : listWorkOrder) {
            listIdFather.add(father.id);
        }

        List<Asset> listAsset =XC_DF_Asset.createAssets(5);
        insert listAsset;

        listAsset[0].NE__Bundle_Configuration__c = listAsset[3].id;
        listAsset[1].NE__Bundle_Configuration__c = listAsset[4].id;
        update listAsset;

        List<WorkOrder> listWorkOrderSon = XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_CommercialVisit);
        listWorkOrderSon[0].ParentWorkOrderId = listWorkOrder[0].id;
        listWorkOrderSon[1].ParentWorkOrderId = listWorkOrder[0].id;
        listWorkOrderSon[0].AssetId = listAsset[0].id;
        listWorkOrderSon[1].AssetId = listAsset[1].id;
        insert listWorkOrderSon;

        List<SkillRequirement> skillReqList = XC_DF_WorkOrder.createWorkOrderSkillRequirement (listWorkOrder);
        insert skillReqList;

        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>();
        List<WorkOrder> workOrder = [SELECT Id, (SELECT Id, Asset.NE__Bundle_Configuration__c FROM ChildWorkOrders)  FROM WorkOrder WHERE Id IN :listIdFather];   
        mapWorkOrder.put(listAsset[3].id, workOrder[0]);

        Test.startTest();     
        XC_UTIL_ResultWrapper resultWrapper = XC_UTIL_WorkOrderSplit.getBundleMapInsertMiddleWorkOrder(new XC_UTIL_ResultWrapper(), listWorkOrder[1], mapWorkOrder);       
        System.debug('errorMessage' + resultWrapper.resultMessage);    
        Test.stopTest();
        System.assert(resultWrapper.success);
    }

     @isTest
    static void insertWorkOrder() {
        List<XC_Address__c> addresses = XC_DF_Address.createAddress(1);
        insert addresses;

        List<Asset> listAsset =XC_DF_Asset.createAssets(5);
        insert listAsset;
        listAsset[0].NE__Bundle_Configuration__c = listAsset[3].id;
        listAsset[1].NE__Bundle_Configuration__c = listAsset[4].id;
        update listAsset;

        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(4, Label.XC_CL_CommercialVisit);
        insert listWorkOrder;

        List<String> listIdFather = new List<String>();
        for(WorkOrder father : listWorkOrder) {
            listIdFather.add(father.id);
        }
        listWorkOrder[1].XC_HierarchyLevel__c = 1;
        listWorkOrder[1].PostalCode = '28280';
        listWorkOrder[1].City = 'Madrid';
        listWorkOrder[1].Country = 'Spain';
        listWorkOrder[1].XC_NumberWorkOrdersDI__c = 2;
        listWorkOrder[1].XC_Address__c = addresses[0].id;
        update listWorkOrder;

        List<WorkOrder> listWorkOrderSon = XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_CommercialVisit);
        listWorkOrderSon[0].ParentWorkOrderId = listWorkOrder[0].id;
        insert listWorkOrderSon;
        
        listWorkOrderSon[0].AssetId = listAsset[0].id;
        update listWorkOrderSon;

        List<SkillRequirement> skillReqList = XC_DF_WorkOrder.createWorkOrderSkillRequirement (listWorkOrder);
        insert skillReqList;

        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>();
        List<WorkOrder> workOrder = [SELECT Id, (SELECT Id, Asset.NE__Bundle_Configuration__c FROM ChildWorkOrders)  FROM WorkOrder WHERE Id IN :listIdFather];   
        mapWorkOrder.put(listAsset[3].id, workOrder[0]);

        Test.startTest();       
        XC_UTIL_ResultWrapper resultWrapper = XC_UTIL_WorkOrderSplit.getBundleMapInsertMiddleWorkOrder(new XC_UTIL_ResultWrapper(), listWorkOrder[1], mapWorkOrder);       
        System.debug('errorMessage' + resultWrapper.resultMessage);    
        Test.stopTest();
        System.assert(resultWrapper.success);

    }
}
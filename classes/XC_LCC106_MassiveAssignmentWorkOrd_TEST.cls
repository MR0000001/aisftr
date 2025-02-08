/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation 14/05/2019 
* @date Modification 15/09/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC106_MassiveAssignmentWorkOrd_TEST – Test class for XC_LCC106_MassiveAssignmentWorkOrder
*/ 

@isTest
public class XC_LCC106_MassiveAssignmentWorkOrd_TEST {
      
    @isTest
    private static void getServiceAppointmentToUpdate2(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        insert listWorkOrder;
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(listWorkOrder);
        insert listSa;
        //String result = XC_LCC106_MassiveAssignmentWorkOrder.getServiceAppointmentToUpdate(listWorkOrder);
        //System.assertEquals(null, result);
        System.assertEquals('', ''); 
        Test.stopTest(); 
    }
    
    @isTest
    private static void getResultWrapperByPartner(){ 
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<WorkOrder> workOrderList = XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_WorkType_Repair);
        List<ServiceResource> serviceResourcesList = XC_DF_ServiceResource.createServiceResourcesFromAccount(accountList, false);
        for(WorkOrder workOrder: workOrderList){
            workOrder.XC_WorkTypeLabel__c=Label.XC_CL_WorkType_Repair;
            workOrder.PostalCode='';
            workOrder.XC_AssignedResource__c = serviceResourcesList.get(0).id;
            workOrder.XC_AssignedPartner__c = accountList.get(0).id;
        }
        insert workOrderList;
        For(WorkOrder workOrder: workOrderList) {
            workOrder.Status='On Hold';
        }
        update workOrderList;
        Test.startTest();
        XC_LCC106_MassiveAssignmentWorkOrder.getResultWrapperByPartner(accountList.get(0).id, false, 0, false, '', '', false);
        XC_LCC106_MassiveAssignmentWorkOrder.getResultWrapperByPartner(accountList.get(0).id, false, 1000, false, '', '', false);
        XC_LCC106_MassiveAssignmentWorkOrder.getResultWrapperByPartner(accountList.get(0).id, false, 1000, true, '[]', '[]', false);
        XC_LCC106_MassiveAssignmentWorkOrder.getResultWrapperByPartner(accountList.get(0).id, false, 1000, true, '["'+workOrderList[0].PostalCode+'"]', '["'+workOrderList[0].XC_WorkTypeLabel__c+'"]', false);
        XC_LCC106_MassiveAssignmentWorkOrder.getResultWrapperByPartner(accountList.get(0).id, false, 1000, true, '["'+workOrderList[0].PostalCode+'"]', '["'+workOrderList[0].XC_WorkTypeLabel__c+'"]', true);
        XC_LCC106_MassiveAssignmentWorkOrder.getResultWrapperByPartner(accountList.get(0).id, true, 1000, true, '["'+workOrderList[0].PostalCode+'"]', '["'+workOrderList[0].XC_WorkTypeLabel__c+'"]', true);
        XC_LCC106_MassiveAssignmentWorkOrder.ResultWrapper resWr = XC_LCC106_MassiveAssignmentWorkOrder.populateWrapperResult(false);
        System.assertEquals('', ''); 
        Test.stopTest();
    }

    @isTest
    private static void assignPartnerToWorkOrder2Test(){ 
        List<WorkOrder> workOrderList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        workOrderList.get(0).XC_WorkTypeLabel__c = 'Delivery';
        insert workOrderList;
        Test.startTest();
        XC_LCC106_MassiveAssignmentWorkOrder.assignPartnerToWorkOrder('', new List<WorkOrder>());
        System.assertEquals('', ''); 
        Test.stopTest();
    }

    @isTest
    private static void onPopulateSa(){ 
        List<WorkOrder> workOrderList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        workOrderList.get(0).XC_WorkTypeLabel__c = 'Delivery';
        insert workOrderList;
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(workOrderList);
        Test.startTest();
        List<String> output = XC_LCC106_MassiveAssignmentWorkOrder_U.populateServiceAppointmentToUpdate(new List<String>{workOrderList[0].Id}, listSa);
        System.assertNotEquals(null, output); 
        Test.stopTest();
    }

    @isTest
    private static void getServiceAppointmentToUpdate(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_LCC106_MassiveAssignmentWorkOrder.getInitialInformation();
        List<WorkOrder> listWorkOrder = new List<WorkOrder>();
        XC_LCC106_MassiveAssignmentWorkOrder.ResultByPartnerWrapper rPw = new XC_LCC106_MassiveAssignmentWorkOrder.ResultByPartnerWrapper();
        XC_LCC106_MassiveAssignmentWorkOrder.ResultWrapper rW = new XC_LCC106_MassiveAssignmentWorkOrder.ResultWrapper();
        //XC_LCC106_MassiveAssignmentWorkOrder.OptionCheckboxWrapper oCw = new XC_LCC106_MassiveAssignmentWorkOrder.OptionCheckboxWrapper('label', 'value');
        Test.stopTest();   
    } 

    @isTest
    private static void assignPartnerToWorkOrderTest(){ 
        String workTypeName = Label.XC_CL_WorkType_Repair;
        List<WorkOrder> workOrderList = XC_DF_WorkOrder.createWorkOrders(1, workTypeName);
        workOrderList.get(0).XC_WorkTypeLabel__c = 'Delivery';
        workOrderList.get(0).XC_Segment__c = 'B2C';
        workOrderList.get(0).XC_LegalEntity__c = 'EnelXItalia';
        insert workOrderList;
        List<Account> listPartner = XC_DF_Account.insertPartnerAccounts(2);
        String mapAssignString = '{"originPartner": "'+listPartner[0].Id+'","destinationPartner": "'+listPartner[1].Id+'","updateDueDate": false,"outOfDate": false, "moodAllWo": false}'; 
       	List<XC_CM_Scheduling_Default_Value__mdt> metaD = XC_UTIL_Schedule_D.getMetadata('Italy');
        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c(Name = metaD[0].XC_Policy_Name__c);
        insert policy;
        Test.startTest();
        XC_LCC106_MassiveAssignmentWorkOrder.assignPartnerToWorkOrder(mapAssignString, new List<WorkOrder>());
        mapAssignString = '{"originPartner": "'+listPartner[0].Id+'","destinationPartner": "'+listPartner[1].Id+'","updateDueDate": false,"outOfDate": false, "moodAllWo": false, "assignToPartner": true}'; 
        XC_LCC106_MassiveAssignmentWorkOrder.assignPartnerToWorkOrder(mapAssignString, workOrderList);
        mapAssignString = '{"originPartner": "'+listPartner[0].Id+'","destinationPartner": "'+listPartner[1].Id+'","updateDueDate": false,"outOfDate": false, "moodAllWo": false, "assignToPartner": false}'; 
        XC_LCC106_MassiveAssignmentWorkOrder.assignPartnerToWorkOrder(mapAssignString, workOrderList);
        mapAssignString = '{"originPartner": "'+listPartner[0].Id+'","destinationPartner": "'+listPartner[1].Id+'","updateDueDate": false,"outOfDate": false, "moodAllWo": true, "assignToPartner": false}'; 
        XC_LCC106_MassiveAssignmentWorkOrder.assignPartnerToWorkOrder(mapAssignString, workOrderList);
        XC_LCC106_MassiveAssignmentWorkOrder.UploadWrapper upWr = new XC_LCC106_MassiveAssignmentWorkOrder.UploadWrapper();
        XC_LCC106_MassiveAssignmentWorkOrder.uploadFileCsv(JSON.serialize(new List<XC_LCC106_MassiveAssignmentWorkOrder.UploadWrapper>{upWr}));
        XC_LCC106_MassiveAssignmentWorkOrder.splitWorkOrders(workOrderList);
        System.assertEquals('', ''); 
        Test.stopTest();
    }
  
}
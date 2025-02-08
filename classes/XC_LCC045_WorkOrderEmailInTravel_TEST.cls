/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC045_WorkOrderEmailInTravel_TEST – Test Class of XC_LCC045_WorkOrderEmailInTravel
*/

@isTest
public class XC_LCC045_WorkOrderEmailInTravel_TEST {
    static testMethod void checkPossibilityToSendTest(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.SchedStartTime = Datetime.now();
            sa.SchedEndTime = Datetime.now().addHours(2);
            saToUpdate.add(sa);
        }
        insert saToUpdate;

        Test.startTest();
        System.debug('WorkTypeName-->' + woList[0].XC_WorkTypeCategory__c);
        XC_UTIL_ResultWrapper resWrapper = XC_LCC045_WorkOrderEmailInTravel.checkPossibilityToSend(woList[0].Id);
        System.assertEquals(resWrapper.success , true);
        Test.stopTest();
    }
    
        static testMethod void checkPossibilityToSendTestDue(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.SchedStartTime = Datetime.now();
            sa.SchedEndTime = Datetime.now().addHours(2);
            saToUpdate.add(sa);
        }
        insert saToUpdate;

        Test.startTest();
        System.debug('WorkTypeName-->' + woList[0].XC_WorkTypeCategory__c);
        XC_UTIL_ResultWrapper resWrapper = XC_LCC045_WorkOrderEmailInTravel.checkPossibilityToSend(woList[0].Id);
        System.assertEquals(resWrapper.success , false);
        Test.stopTest();
    }
    
    
    static testMethod void checkPossibilityToSendTestTre(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;

        Test.startTest();
        System.debug('WorkTypeName-->' + woList[0].XC_WorkTypeCategory__c);
        XC_UTIL_ResultWrapper resWrapper = XC_LCC045_WorkOrderEmailInTravel.checkPossibilityToSend(woList[0].Id);
        System.assertEquals(resWrapper.success , false);
        Test.stopTest();
    }
    
   static testMethod void checkPossibilityToSendTestQuattro(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.SchedStartTime = Datetime.now().addhours(12);
            sa.SchedEndTime = Datetime.now().addHours(14);
            saToUpdate.add(sa);
        }
        insert saToUpdate;

        Test.startTest();
        System.debug('WorkTypeName-->' + woList[0].XC_WorkTypeCategory__c);
        XC_UTIL_ResultWrapper resWrapper = XC_LCC045_WorkOrderEmailInTravel.checkPossibilityToSend(woList[0].Id);
        System.assertEquals(resWrapper.success , false);
        Test.stopTest();
    }
    
      static testMethod void updateServiceAndSendTest(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.SchedStartTime = Datetime.now().addhours(12);
            sa.SchedEndTime = Datetime.now().addHours(14);
            saToUpdate.add(sa);
        }
        insert saToUpdate;
		Map<String,Object> values = new Map<String,Object>();
        values.put('customerType', 'WorkOrder_StartTravel');
        values.put('delay', '1');
        values.put('workorderId',woList[0].Id);
        Test.startTest();
        //System.debug('WorkTypeName-->' + woList[0].XC_WorkTypeCategory__c);
        XC_UTIL_ResultWrapper resWrapper = XC_LCC045_WorkOrderEmailInTravel.updateServiceAndSend(JSON.serialize(values));
        System.assertEquals(resWrapper.success , false);
        Test.stopTest();
    }

    @IsTest
    static void testInsertCI(){
        
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.SchedStartTime = Datetime.now().addhours(12);
            sa.SchedEndTime = Datetime.now().addHours(14);
        }
        insert saList;

        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_ServiceAppointmentId__c = saList[0].Id;
        ci.XC_WorkOrderId__c = woList[0].Id;
        ci.XC_Communication_Type__c = Label.XC_CL_CustomerInteraction_WorkOrder_StartTravel;
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(ci);
        System.assert(wr.success);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testInsertCI2(){
        
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Opportunity> opList = XC_DF_Opportunity.createOpportunity(1, false);
        insert opList;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woList[0].XC_Opportunity__c = opList[0].Id;
        insert woList;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.SchedStartTime = Datetime.now().addhours(12);
            sa.SchedEndTime = Datetime.now().addHours(14);
        }
        insert saList;

        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_ServiceAppointmentId__c = saList[0].Id;
        ci.XC_WorkOrderId__c = woList[0].Id;
        ci.XC_Communication_Type__c = Label.XC_CL_CustomerInteraction_WorkOrder_StartTravel;
        XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.insertRecord(ci);
        System.assert(wr.success);
        Test.stopTest();
        
    }

}
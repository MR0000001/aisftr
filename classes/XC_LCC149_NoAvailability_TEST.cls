/**
* @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation  16/09/2019 
* @description XC_LCC149_NoAvailability_TEST – Test class for XC_LCC149_NoAvailability
*/
@istest
public class XC_LCC149_NoAvailability_TEST {
     
    //Test Method updateFLS
    @isTest
    static void updateFLS(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert woList;
        woList[0].status = Label.XC_CL_OnHold;
        update woList;

        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert listSa;
        XC_UTIL_ResultWrapper rw = XC_LCC149_NoAvailability.updateFLS(woList[0].Id);

        System.assertEquals(true, woList!=null);
        Test.stopTest();
    }

    //Test Method updateFLS when non-compliant worktype
        @isTest
        static void updateFLSErrorWT(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Installation');
        insert woList;
        woList[0].status = Label.XC_CL_OnHold;
        update woList;

        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert listSa;
        XC_UTIL_ResultWrapper rw = XC_LCC149_NoAvailability.updateFLS(woList[0].Id);

        System.assertEquals(true, woList!=null);
        Test.stopTest();
    }

    //Test Method updateFLS when work order haven't service appointment
    @isTest
    static void updateFLSWithoutSA(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert woList;
        woList[0].status = Label.XC_CL_OnHold;
        update woList;  
        XC_UTIL_ResultWrapper rw = XC_LCC149_NoAvailability.updateFLS(woList[0].Id);

        System.assertEquals(true, woList!=null);
        Test.stopTest();
    }
}
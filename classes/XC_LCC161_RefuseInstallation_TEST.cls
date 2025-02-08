/**
* @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation  09/10/2019 
* @description XC_LCC161_RefuseInstallation_TEST – Test class for XC_LCC161_RefuseInstallation
*/
@IsTest
public class XC_LCC161_RefuseInstallation_TEST {
    
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
        XC_UTIL_ResultWrapper rw = XC_LCC161_RefuseInstallation.updateFLS(woList[0].Id);

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
        XC_UTIL_ResultWrapper rw = XC_LCC161_RefuseInstallation.updateFLS(woList[0].Id);

        System.assertEquals(true, woList!=null);
        Test.stopTest();
    }

    //Test Method updateFLS when status work order is not on hold
    @isTest
    static void updateFLSErrorStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();         
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        insert woList;

        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert listSa;
        XC_UTIL_ResultWrapper rw = XC_LCC161_RefuseInstallation.updateFLS(woList[0].Id);

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
        XC_UTIL_ResultWrapper rw = XC_LCC161_RefuseInstallation.updateFLS(woList[0].Id);

        System.assertEquals(true, woList!=null);
        Test.stopTest();
    }
}
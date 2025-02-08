/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 10/10/2019
* @date Modification:
* @description XC_LCC162_CustomerRetained_TEST - Test class for XC_LCC162_CustomerRetained
*/
@isTest
public class XC_LCC162_CustomerRetained_TEST {
    @isTest
    static void customerRetained() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
      
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1,label.XC_CL_WorkType_PlannedMaintenance);
        insert listServiceAppointment;
        String saId = listServiceAppointment[0].id;   
        List<WorkOrder> woList = new List<WorkOrder>([    
        SELECT Id
        FROM WorkOrder
        WHERE Id =: listServiceAppointment[0].ParentRecordId
        ]);
        String woId = woList[0].id;
        Test.startTest();
		XC_LCC162_CustomerRetained.ResultWrapper wrapper = XC_LCC162_CustomerRetained.updateFLS(woId);
        System.assertEquals(wrapper.success, true);
        Test.stopTest();        
    }
    
	@isTest
    static void customerRet() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
      
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1,label.XC_CL_WorkType_Repair);
        insert listServiceAppointment;
        String saId = listServiceAppointment[0].id;   
        List<WorkOrder> woList = new List<WorkOrder>([    
        SELECT Id
        FROM WorkOrder
        WHERE Id =: listServiceAppointment[0].ParentRecordId
        ]);
        String woId = woList[0].id;
        Test.startTest();
		XC_LCC162_CustomerRetained.ResultWrapper wrapper = XC_LCC162_CustomerRetained.updateFLS(woId);
        System.assertEquals(wrapper.success, false);
        Test.stopTest();        
    }
}
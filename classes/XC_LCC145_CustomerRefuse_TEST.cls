/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 06/09/2019
* @date Modification:
* @description XC_LCC145_CustomerRefuse_TEST - Test class for XC_LCC145_CustomerRefuse
*/
@isTest
public without sharing class XC_LCC145_CustomerRefuse_TEST {
    @isTest
    static  void customerRefuseSAWO() {
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1,label.XC_CL_WorkType_PlannedMaintenance); 
        insert listServiceAppointment;
        String woId = listServiceAppointment[0].ParentRecordId;
        Test.startTest();
        XC_LCC145_CustomerRefuse.updateFLS(woId); 
        List<WorkOrder> listWo = XC_UTIL_Sobject.selectAllFields(woId);
        XC_LCC145_CustomerRefuse.updateWoAfterSA(listWo[0]);
        Test.stopTest();        
    } 
    
    @isTest
    static void customerRefuseWO() {
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1,label.XC_CL_WorkType_PlannedMaintenance); 
        insert listWo; 
        Test.startTest();
        XC_LCC145_CustomerRefuse.updateFLS(listWo[0].Id); 
        Test.stopTest();        
    }  
}
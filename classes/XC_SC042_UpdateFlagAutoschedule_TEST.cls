/**
* @author FSL Team: Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 16/03/2021
* @description XC_SC042_UpdateFlagAutoschedule_TEST – TEST class for XC_SC042_UpdateFlagAutoschedule
*/


@isTest
private class XC_SC042_UpdateFlagAutoschedule_TEST {

    @TestSetup
    static void makeData(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_PlannedMaintenance);
        listServiceAppointment[0].Status = Label.XC_CL_ServiceAppointment_None;
        listServiceAppointment[0].XC_LegalEntity__c = 'EndesaX';   
        insert listServiceAppointment;
        
    }

    @isTest
    static void executeBatch() {
        Test.startTest();          
        XC_SC042_UpdateFlagAutoschedule myClass = new XC_SC042_UpdateFlagAutoschedule();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }

}
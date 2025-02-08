/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 16/05/2019
* @description XC_SC009_AutoSchedMaintenance_TEST – Test class for XC_SC009_AutoSchedMaintenance
*/ 

@isTest
private class XC_SC009_AutoSchedMaintenance_TEST {
    
    @TestSetup
    static void extecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_PlannedMaintenance);
        listServiceAppointment[0].Status = Label.XC_CL_ServiceAppointment_None;
        listServiceAppointment[0].XC_LegalEntity__c = 'EndesaX';
        Group dispatcherQueue = new Group (Name = 'XC_ESP_DispatcherQueue');
        insert dispatcherQueue;
        Test.stopTest();
        insert listServiceAppointment;
    }

    @IsTest
    static void test(){
        XC_SC009_AutoScheduleMaintenance.insertBatchError(null, 'Test', 'Test');
        Test.startTest();
        XC_SC009_AutoScheduleMaintenance myClass = new XC_SC009_AutoScheduleMaintenance();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass); 
        //Database.executeBatch(new XC_SC009_AutoScheduleMaintenance(), 50);
        Test.stopTest();
        
    }
}
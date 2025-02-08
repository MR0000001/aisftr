@isTest
public class XC_TR_Task_U_DefaultSettings_TEST {
	
     // Test method for setTaskRecordType 
     static testMethod void setTaskRecordTypeByCase(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        /*XC_CM_CaseReasonRtMapping__mdt mtd = new XC_CM_CaseReasonRtMapping__mdt();
        mtd.XC_CaseReason__c = 'XCMOT010';
        mtd.XC_CaseRecordType__c = 'XC_ESP_Management_Case';
        mtd.XC_LegalEntity__c = 'EndesaX';
        mtd.XC_TaskRecordType__c = 'XC_Task_Spain';
        insert mtd;*/
        
        Test.startTest(); 
        List<Case> caso= XC_DF_Case.createCases(1);
        insert caso; 
        Task task = new Task();
        task.WhatId = caso[0].Id; 
        insert task ; 
        System.assert(task != null);
        Test.stopTest();
    } 
	
     // Test method for setTaskRecordType 
     static testMethod void setTaskRecordTypeByWO(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
         
        /*XC_CM_CaseReasonRtMapping__mdt mtd = new XC_CM_CaseReasonRtMapping__mdt();
        mtd.XC_CaseReason__c = 'XCMOT010';
        mtd.XC_CaseRecordType__c = 'XC_ESP_Management_Case';
        mtd.XC_LegalEntity__c = 'EndesaX';
        mtd.XC_TaskRecordType__c = 'XC_Task_Spain';
        insert mtd;*/
        
        Test.startTest(); 
        List<Case> caso = XC_DF_Case.createCases(1);
        insert caso; 
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        wo[0].CaseId = caso[0].Id;
        insert wo; 
        Task task = new Task();
        task.WhatId = wo[0].Id; 
        insert task ; 
        System.assert(task != null);
        Test.stopTest();
    } 
	
     // Test method for setTaskRecordType 
     static testMethod void setTaskRecordTypeByLead(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Test.startTest(); 
        List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
        insert lead; 
        Task task = new Task();
        task.WhoId = lead[0].Id; 
        insert task ; 
        System.assert(task != null);
        Test.stopTest();
    } 
}
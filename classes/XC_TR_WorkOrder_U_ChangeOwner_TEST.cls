/**
* @author D.Lombardi
* @date Creation 22/03/2021
* @date Modification MAY 2022 - FA/GDB - PERFORMANCE IMPROVEMENT
* @description Test class for XC_TR_WorkOrder_U_ChangeOwner
*/
@isTest
public with sharing class XC_TR_WorkOrder_U_ChangeOwner_TEST {
    
    static testMethod void changePartner(){
    	
        
        Map<Id,WorkOrder> mapWorkOrderOld = new Map<Id,WorkOrder>();
        WorkOrder workOrderOld = new WorkOrder();
        workOrderOld.XC_PreferredPartner__c = '0017a00001G2WaUAAV';
        workOrderOld.id = '0WO0D000000PuWxWAK';
        workOrderOld.XC_Segment__c = 'B2G';
        mapWorkOrderOld.put(workOrderOld.id,workOrderOld);
        Map<Id,WorkOrder> mapWorkOrderNew = new Map<Id,WorkOrder>();
        WorkOrder woNew = new WorkOrder();
        woNew.XC_PreferredPartner__c = '0010D00000SGEeVQAX';
        woNew.id = '0WO0D000000PuWxWAK';
        woNew.XC_Segment__c = 'B2G';
        mapWorkOrderNew.put(woNew.id,woNew);
        XC_TR_WorkOrder_U_ChangeOwner.isChangePreferedPartner(mapWorkOrderNew.values(), mapWorkOrderOld, mapWorkOrderNew);
    }
    
    static testMethod void changeResources(){
    
        Map<Id,WorkOrder> mapWorkOrderOld = new Map<Id,WorkOrder>();
        WorkOrder workOrderOld = new WorkOrder();
        workOrderOld.XC_AssignedResource__c = '0017a00001G2WaUAAV';
        workOrderOld.id = '0WO0D000000PuWxWAK';
        workOrderOld.XC_Segment__c = 'B2G';
        mapWorkOrderOld.put(workOrderOld.id,workOrderOld);
        Map<Id,WorkOrder> mapWorkOrderNew = new Map<Id,WorkOrder>();
        WorkOrder woNew = new WorkOrder();
        woNew.XC_AssignedResource__c = '0010D00000SGEeVQAX';
        woNew.id = '0WO0D000000PuWxWAK';
        woNew.XC_Segment__c = 'B2G';
        mapWorkOrderNew.put(woNew.id,woNew);
        XC_TR_WorkOrder_U_ChangeOwner.isChangeAssignedResources(mapWorkOrderNew.values(), mapWorkOrderOld, mapWorkOrderNew);
    }
    
    static testMethod void updateTriggersOFFtest(){
		
        Test.startTest();
		List<ServiceAppointment> salist = XC_DF_ServiceAppointment.createServiceAppointment(1);        
        insert salist;
        XC_TR_WorkOrder_U_ChangeOwner.updateTriggersOFF(salist);
        Test.stopTest();
    }
}
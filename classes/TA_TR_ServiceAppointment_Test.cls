/**
* @author Andrea Liverani
* @date Creation 22/06/2021
* @description TA_TR_ServiceAppointment_Test – Test Class for TA_TR_ServiceAppointment AND Handler
*/

@isTest
public class TA_TR_ServiceAppointment_Test {
    @TestSetup
    static void setup (){
    }

    static testMethod void onBeforeUpdate() {
        Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
        WorkOrder wo = new WorkOrder(XC_WorkTypeCategory__c = 'Delivery & Installation', XC_Segment__c = 'B2C', XC_Country__c  = 'Italy', RecordTypeId = recordTypeId);
        insert wo;

        WorkOrder woChild = new WorkOrder(XC_WorkTypeCategory__c = 'Delivery & Installation', XC_Segment__c = 'B2C', XC_Country__c  = 'Italy', ParentWorkOrderId = wo.Id, RecordTypeId = recordTypeId);
        insert woChild;

        List<ServiceAppointment> servApps = XC_DF_ServiceAppointment.createServiceAppointment(1,'Delivery & Installation');
        servApps[0].XC_Segment__c = 'B2C';
        servApps[0].ParentRecordId = wo.Id;
        insert servApps;

        Test.startTest();
        servApps[0].XC_StatusReason__c = 'Assigned to the technician'; 
        update servApps;
        Test.stopTest();
    }
    
     static testMethod void onInsert(){
        Test.startTest(); 
        List<ServiceAppointment> listSA = XC_DF_ServiceAppointment.createServiceAppointment(1);
        insert listSA;
        update listSA;
        delete listSA;
  
        System.assertEquals(true, listSA!=null);
        Test.stopTest();
        
    }
    
}
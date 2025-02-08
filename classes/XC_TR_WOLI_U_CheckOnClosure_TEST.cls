/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation  07/11/2019 
* @description XC_TR_WOLI_U_CheckOnClosure_TEST – Test class for XC_TR_WorkOrderLineItem_U_CheckOnClosure
*/
@isTest
public class XC_TR_WOLI_U_CheckOnClosure_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    @isTest
    static void onUpdate(){
        Id recordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_ESP_Woli_Photo').getRecordTypeId();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.RecordTypeId = recordTypeId;
        insert woli;
        Test.startTest();
        try {
        woli.Status = 'Closed';
        update woli;
        }catch(Exception ex){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' ,ex.getDmlStatusCode(0));
        }
        delete woli;
        Test.stopTest();

    }
    
    @isTest
    static void onUpdate2(){
        Id recordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_ESP_Woli_ManualDialing').getRecordTypeId();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.RecordTypeId = recordTypeId;
        insert woli;
        Test.startTest();
        try {
        woli.XC_MeasurementValueOne__c = 2;
        update woli;
        }catch(Exception ex){
            System.debug('In catch');
        }
        Test.stopTest();

    }
    
    @isTest
    static void onUpdateDate(){
        Id recordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_ESP_Woli_ManualDialing').getRecordTypeId();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        wo[0].XC_Segment__c = 'B2C';
        insert wo; 
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo[0].Id; 
        woli.RecordTypeId = recordTypeId;
        woli.XC_UploadNeeded__c = false;
        insert woli;
        Test.startTest();
        try {
            woli.Status = 'Closed';
            update woli;
        }catch(Exception ex){
            System.debug('In catch');
        }
        Test.stopTest();
    }
}
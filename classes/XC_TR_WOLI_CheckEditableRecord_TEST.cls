/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 01-02-2022
 * @last modified date  : 01-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Test class for XC_TR_WOLI_CheckEditableRecord
**/

@isTest
public class XC_TR_WOLI_CheckEditableRecord_TEST {

    @TestSetup
    public static void setup(){
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders (1, 'Organizer');
        Id rtIdWO = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId();
        woList.get(0).RecordTypeId = rtIdWO;
        woList.get(0).XC_LegalEntity__c = 'EnelXItalia';
        woList.get(0).XC_Segment__c = 'B2G';
        insert woList;

        List<WorkOrderLineItem> woliList = createWoli(4, woList.get(0).Id);
        insert woliList;  
    }

    @isTest
    public static void checkBeforeUpdateRecords_Test(){  
        Test.startTest();    
        Map<Id, WorkOrderLineItem> woliMap = new Map<Id, WorkOrderLineItem>([SELECT Id, Status, XC_WOLIType__c, RecordTypeId, XC_OwnerWorkOrder__c FROM WorkOrderLineItem]);
        XC_TR_WOLI_CheckEditableRecord.checkBeforeUpdateRecords(woliMap, woliMap);
        Test.stopTest();
    }

    @isTest
    public static void checkBeforeDeleteRecords_Test(){  
        Test.startTest();    
        Map<Id, WorkOrderLineItem> woliMap = new Map<Id, WorkOrderLineItem>([SELECT Id, Status, XC_WOLIType__c, RecordTypeId FROM WorkOrderLineItem]);
        XC_TR_WOLI_CheckEditableRecord.checkBeforeDeleteRecords(woliMap);
        Test.stopTest();
    }

    public static List<WorkOrderLineItem> createWoli(Integer n, Id woId){
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        Id rtIdWOLIPE = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_PE_WOLI').getRecordTypeId();
        Id rtIdWOLIGI = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Good_Issue').getRecordTypeId();
        Id rtIdWOLIPP = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2GEnelXItaliaPartnerPayment').getRecordTypeId();
        Id rtIdWOLIMS = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_MR_WOLI').getRecordTypeId();
        for (Integer i=0; i<4; i++){
			WorkOrderLineItem woli = new WorkOrderLineItem();
            woli.Status = i<=2 ? 'Completed' : 'Approved';
            woli.XC_WOLIType__c = i==0 ? 'Partner Engagement' : i==1 ? 'Good Issue' : i==2 ? 'Material Supply' : i==3 ? 'Partner Payment' : '';
            woli.RecordTypeId = i==0 ? rtIdWOLIPE : i==1 ? rtIdWOLIGI : i==2 ? rtIdWOLIMS : i==3 ? rtIdWOLIPP : '';
            woli.XC_LCLDocument__c = i==0 ? 'Chiusura Lavori' : ''; 
            woli.WorkOrderId = woId;
            woliList.add(woli);
        }
 		return woliList;
    }
}
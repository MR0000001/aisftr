/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 01-02-2022
 * @last modified date  : 01-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Test class for XC_TR_ProductConsumed_CheckEditable
**/

@isTest
public class XC_TR_ProductConsumed_CheckEditable_TEST {

    @TestSetup
    public static void setup(){

        User user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1];
        user.XC_EnabledToSkip__c = true;
        update user;
        
        System.runAs(user){
            List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders (1, 'Organizer');
            Id rtIdWO = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId();
            woList.get(0).RecordTypeId = rtIdWO;
            woList.get(0).XC_LegalEntity__c = 'EnelXItalia';
            woList.get(0).XC_Segment__c = 'B2G';
            insert woList;

            List<WorkOrderLineItem> woliList = createWoli(4, woList.get(0).Id);
            insert woliList; 
            
            List<XC_ProductConsumed__c> pcList = createProductConsumed(4, woliList, woList);
            insert pcList;
        }
    }

    @isTest
    public static void checkBeforeUpdateRecords_Test(){  
        Test.startTest();    
        Map<Id, XC_ProductConsumed__c> pcMap = new Map<Id, XC_ProductConsumed__c>([SELECT Id, XC_WorkOrderLineItem__c, XC_WorkOrderLineItem__r.Status, XC_WorkOrderLineItem__r.XC_WOLIType__c, XC_WorkOrderLineItem__r.RecordTypeId FROM XC_ProductConsumed__c]);
        XC_TR_ProductConsumed_CheckEditable.checkBeforeUpdateRecords(pcMap, pcMap);
        Test.stopTest();
    }

    @isTest
    public static void checkBeforeDeleteRecords_Test(){  
        Test.startTest();    
        Map<Id, XC_ProductConsumed__c> pcMap = new Map<Id, XC_ProductConsumed__c>([SELECT Id, XC_WorkOrderLineItem__c, XC_WorkOrderLineItem__r.Status, XC_WorkOrderLineItem__r.XC_WOLIType__c, XC_WorkOrderLineItem__r.RecordTypeId FROM XC_ProductConsumed__c]);
        XC_TR_ProductConsumed_CheckEditable.checkBeforeDeleteRecords(pcMap);
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

    public static List<XC_ProductConsumed__c> createProductConsumed(Integer n, List<WorkOrderLineItem> woliList, List<WorkOrder> woList){
        List<XC_ProductConsumed__c> pcList = new List<XC_ProductConsumed__c>();
        for (Integer i=0; i<n; i++){
			XC_ProductConsumed__c pc = new XC_ProductConsumed__c();
            pc.XC_WorkOrderLineItem__c = woliList.get(i).Id;
            pc.XC_WorkOrder__c = woList.get(0).Id;
            pcList.add(pc);
        }
 		return pcList;
    }
}
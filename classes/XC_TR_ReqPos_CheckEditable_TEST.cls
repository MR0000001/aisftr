/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 01-02-2022
 * @last modified date  : 01-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Test class for XC_TR_RequiredPosition_CheckEditable
**/

@isTest
public class XC_TR_ReqPos_CheckEditable_TEST {

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
            
            List<XC_RequiredPosition__c> rpList = createRequiredPosition(4, woliList);
            insert rpList;
        }
    }

    @isTest
    public static void checkBeforeUpdateRecords_Test(){  
        Test.startTest();    
        Map<Id, XC_RequiredPosition__c> rpMap = new Map<Id, XC_RequiredPosition__c>([SELECT Id, XC_WorkOrderLineItem__c, XC_WorkOrderLineItem__r.Status, XC_WorkOrderLineItem__r.XC_WOLIType__c, XC_WorkOrderLineItem__r.RecordTypeId FROM XC_RequiredPosition__c]);
        XC_TR_RequiredPosition_CheckEditable.checkBeforeUpdateRecords(rpMap, rpMap);
        Test.stopTest();
    }

    @isTest
    public static void checkBeforeDeleteRecords_Test(){  
        Test.startTest();    
        Map<Id, XC_RequiredPosition__c> rpMap = new Map<Id, XC_RequiredPosition__c>([SELECT Id, XC_WorkOrderLineItem__c, XC_WorkOrderLineItem__r.Status, XC_WorkOrderLineItem__r.XC_WOLIType__c, XC_WorkOrderLineItem__r.RecordTypeId FROM XC_RequiredPosition__c]);
        XC_TR_RequiredPosition_CheckEditable.checkBeforeDeleteRecords(rpMap);
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

    public static List<XC_RequiredPosition__c> createRequiredPosition(Integer n, List<WorkOrderLineItem> woliList){
        List<XC_RequiredPosition__c> rpList = new List<XC_RequiredPosition__c>();
        for (Integer i=0; i<n; i++){
            XC_RequiredPosition__c rp = new XC_RequiredPosition__c();
            rp.XC_WorkOrderLineItem__c = woliList.get(i).Id;
            rpList.add(rp);
        }
        return rpList;
    }
}
/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 02-02-2022
 * @last modified date  : 02-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Test class for XC_TR_RequiredPosition_Handler
**/

@isTest
public class XC_TR_RequiredPosition_Handler_TEST {

    @TestSetup
    public static void setup(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders (1, 'Organizer');
        Id rtIdWO = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId();
        woList.get(0).RecordTypeId = rtIdWO;
        woList.get(0).XC_LegalEntity__c = 'EnelXItalia';
        woList.get(0).XC_Segment__c = 'B2G';
        insert woList;

        List<WorkOrderLineItem> woliList = createWoli(1, woList.get(0).Id);
        insert woliList;
    }

    @isTest
    public static void trigger_Test(){  
        Test.startTest();
        List<WorkOrderLineItem> woliList = [SELECT Id FROM WorkOrderLineItem];    
        List<XC_RequiredPosition__c> rpList = createRequiredPosition(1, woliList);
        insert rpList;
        rpList.get(0).XC_PositionCode__c = 'Test';
        update rpList;
        delete rpList;
        Map<Id, SObject> mapNew = new Map<Id, SObject>();
        mapNew.put(rpList.get(0).Id,rpList.get(0));
        (new XC_TR_RequiredPosition_Handler()).onAfterUnDelete(mapNew);
        Test.stopTest();
    }

    public static List<WorkOrderLineItem> createWoli(Integer n, Id woId){
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        for (Integer i=0; i<n; i++){
            WorkOrderLineItem woli = new WorkOrderLineItem();
            woli.Status = 'In Progress';
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
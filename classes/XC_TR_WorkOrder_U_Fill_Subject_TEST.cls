/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 01-02-2022
 * @last modified date  : 01-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Test class for XC_TR_WorkOrder_U_Fill_Subject
**/

@isTest
public class XC_TR_WorkOrder_U_Fill_Subject_TEST {

    @TestSetup
    public static void setup(){

        User user=[SELECT Id FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1];
        user.XC_EnabledToSkip__c = true;
        update user;
        
        System.runAs(user){
			Id rtIdOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2G_Opportunity_Italy').getRecordTypeId();
            List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
            oppList.get(0).XC_LegalEntity__c = 'EnelXItalia';
            oppList.get(0).XC_Source__c = 'Web';
			oppList.get(0).RecordTypeId = rtIdOpp;
            insert oppList;

            List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders (1, 'Organizer');
            Id rtIdWO = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_WorkOrder').getRecordTypeId();
            woList.get(0).RecordTypeId = rtIdWO;
            woList.get(0).XC_LegalEntity__c = 'EnelXItalia';
            woList.get(0).XC_Segment__c = 'B2G';
            woList.get(0).XC_WorkTypeLabel__c = 'Organizer';
            woList.get(0).XC_Opportunity__c = oppList.get(0).Id;
            insert woList;            
        }
    }

    @isTest
    public static void populateSubjectFromOpportunity_Test(){  
        Test.startTest();    
        List<WorkOrder> woList = [SELECT Id, Subject, XC_Opportunity__c, RecordTypeId, XC_WorkTypeLabel__c FROM WorkOrder];
        XC_TR_WorkOrder_U_Fill_Subject.populateSubjectFromOpportunity(woList);
        Test.stopTest();
    }
}
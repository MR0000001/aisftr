/**
* @author Andrea Di Cicco
* @date 26/10/2020
* @description Test Class for XC_TR_Event_SetLeadStatus
*/
@isTest
public class XC_TR_Event_SetLeadStatus_TEST {
	 /**
     * @author Andrea Di Cicco
     * @date Creation 26/10/2020
     * @description when an event is created, the lead stauts is set to AppointmentScheduled
     * @param listEvent
     */
    static testMethod void setLeadInAppointmentScheduled(){
        Lead l = XC_DF_Lead.createCondominiumLead();
        l.RecordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        l.XC_Segment__c = 'B2B';
        l.XC_LeadSource__c = 'Web';
        l.XC_GiveDataTo__c = true;
      
     
        insert l;
        
        List<Event> listEvent = new List<Event>();
        Event ev = new Event();
        ev.XC_Status__c = 'In Progress';
        ev.WhoId = l.id;
        listEvent.add(ev);
        
        Test.startTest();
        	XC_TR_Event_SetLeadStatus.setLeadInAppointmentScheduled(listEvent);
         	ev.XC_Status__c ='Cancelled';
        	listEvent.add(ev);
        	XC_TR_Event_SetLeadStatus.setLeadInPendingScheduling(listEvent);
        Test.stopTest();
    }
}
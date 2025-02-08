/**
* @author Andrea Di Cicco
* @date Creation 11/06/2020
* @description This class is used to manage the lead status by event status
*/
public with sharing class XC_TR_Event_SetLeadStatus {
    /**
     * @author Andrea Di Cicco
     * @date Creation 11/06/2020
     * @description when an event is created, the lead stauts is set to AppointmentScheduled
     * @param listEvent
     */
    public static void setLeadInAppointmentScheduled(List<Event> listEvent){
        List<Id> leadId = new List<Id>();
        List<Lead> leadList = new List<Lead>();
        for(Event ev : listEvent){
            if( ev.XC_Status__c =='In Progress' && ev.WhoId != null && ev.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
                leadId.add(ev.WhoId);
            }
        }

        if(!leadId.isEmpty() && Schema.sObjectType.Lead.isAccessible()){
            leadList = [SELECT Status FROM Lead WHERE XC_Segment__c != 'B2C' AND Id IN : leadId];
        }

        if(!leadList.isEmpty()){
            for(Lead le : leadList){
                le.Status = 'Appointment Scheduled';
            }
            XC_UTIL_DML.updateRecords(leadList);
        }
    }

    /**
     * @author Andrea Di Cicco
     * @date Creation 11/06/2020
     * @description when an event is cancelled, the lead stauts is set to Pending Scheduling
     * @param listEvent
     */
    public static void setLeadInPendingScheduling(List<Event> listEvent){
        List<Id> leadId = new List<Id>();
        List<Lead> leadList = new List<Lead>();
        for(Event ev : listEvent){
            if( ev.XC_Status__c =='Cancelled' && ev.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
                leadId.add(ev.WhoId);
            }
        }

        if(!leadId.isEmpty() && Schema.sObjectType.Lead.isAccessible()){
            leadList = [SELECT Status FROM Lead WHERE XC_Segment__c != 'B2C' AND Id IN : leadId];
        }

        if(!leadList.isEmpty()){
            for(Lead le : leadList){
                le.Status = 'Pending Scheduling';
            }
            XC_UTIL_DML.updateRecords(leadList);
        }
    }
}
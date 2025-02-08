/**
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 19/04/2019
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_Schedule_D – Dao class XC_UTIL_Schedule
 */
 
public without sharing class XC_UTIL_Schedule_D {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Schedule');

    /**
    @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    *@description Retrive Scheduling Default Values from metadata
    *@param country
    *@return listMetadata list of metadata
    **/

    public static List<XC_CM_Scheduling_Default_Value__mdt> getMetadata(String country){ 
        String countryForQuery = country.toUpperCase();
        List<XC_CM_Scheduling_Default_Value__mdt> listMetadata = new List<XC_CM_Scheduling_Default_Value__mdt>();
        listMetadata = [SELECT XC_Days_for_Due_Date__c, XC_Operating_Hours_Name__c, XC_Policy_Name__c,XC_Policy_Name_NoAvailability__c,XC_Use_Glovia__c
                                                                FROM XC_CM_Scheduling_Default_Value__mdt
                                                                WHERE XC_Country__c = :countryForQuery LIMIT 1];                                                     
        return listMetadata;
    } 

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Method to manage due date
     * @param startDate date time
     * @param n integer
     * @return Datetime
    **/

    public static Datetime getDueDate(DateTime startDate, Integer n){
        if(n!=null){
            return startDate.addDays(n); 
        }else{
            return startDate.addDays(30); 
        }
    } 

    /**
    *@author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    *@description Returns Timeslot fields for the current OperatingHours
    *@param opId the id of opportunity
    *@param opName the Name of opportinuty
    *@return OperatingHours
    **/

    public static OperatingHours getOperatingHours(Id opId, String opName){
        if(opId != null){
            return getOperatingHoursById(opId);
        }
        return getOperatingHoursByName(opName);
    }

    /**
    *@author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    *@description getOperatingHoursById
    *@param opId the id of opportunity
    *@return OperatingHours
    **/
    public static OperatingHours getOperatingHoursById(Id opId){ 
        Map<Id,OperatingHours> operatingHoursMap = new Map<Id,OperatingHours>([SELECT Name, Id, 
                    (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) 
                FROM OperatingHours 
                WHERE Id =: opId LIMIT 1]);  
        List<OperatingHours> operatingHoursList = operatingHoursMap.values();  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL operatingHours--' + operatingHoursList[0]);     
        return operatingHoursList[0];
    }

    /**
    *@author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    *@description getOperatingHoursByName
    *@param opName the name of operating hour
    *@return OperatingHours
    **/
    public static OperatingHours getOperatingHoursByName(String opName){ 
        Map<Id,OperatingHours> operatingHoursMap = new Map<Id,OperatingHours>([SELECT Name, Id, 
                    (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) 
                FROM OperatingHours 
                WHERE Name =: opName LIMIT 1]);
        List<OperatingHours> operatingHours = operatingHoursMap.values();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL operatingHours--' + operatingHours[0]);   
        return operatingHours[0];
    }

    /**
    *@author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    *@description Retrive FSL__Scheduling_Policy__c Object by Name
    *@param pName name of policy
    *@return schedulePolicyList
    **/
    public static FSL__Scheduling_Policy__c getPolicy(String pName){
        Map<Id, FSL__Scheduling_Policy__c> schedulePolicyMap = new Map<Id, FSL__Scheduling_Policy__c>([SELECT Id, Name FROM FSL__Scheduling_Policy__c WHERE Name =: pName LIMIT 1]);
        List<FSL__Scheduling_Policy__c> schedulePolicyList = schedulePolicyMap.values();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@FSL policy.Id--' + schedulePolicyList[0].Id);
        return schedulePolicyList[0];
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Retrive Existing Appointment     
     * @param appointmentId - Id
     * @return ServiceAppointment  
     **/ 
    public static ServiceAppointment getExistingAppointment(Id appointmentId){
        List<ServiceAppointment> listSa = new List<ServiceAppointment>([
            SELECT Id, DueDate, ParentRecordId, AccountId, WorkType.Name, EarliestStartTime 
            FROM ServiceAppointment 
            WHERE Id = :appointmentId
        ]);
        if(listSa.isEmpty()) {
            return null;
        }
        return listSa[0];
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Retrive Existing Opportunity     
     * @param opportunityId - opportunity Id
     * @return Opportunity  
     **/ 

    public static Opportunity getExistingOpportunity(Id opportunityId){
        if(!Schema.sObjectType.Opportunity.isAccessible()){
            return null;
        }  
        Opportunity opp = [SELECT Id, AccountId,XC_Contact__c FROM Opportunity WHERE Id = : opportunityId LIMIT 1];
        return opp;
    }
}
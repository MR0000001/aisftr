/**
 * @description       : Class to compute data to be used for the Safety Culture KPI
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 29-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_BA006_KPISafetyCultureCalc_U {

    /**
    * @description compute numerator for participation rate KPI
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param eventId 
    * @param accountId 
    * @return Decimal 
    **/
    public static Decimal computeNumKPIparticipationRate(Id eventId, Id accountId){
        Decimal num = 0;
        List<XC_SafetyCultureParticipant__c> lstSafetyCultureParticipants = [SELECT Id
                                                                             FROM XC_SafetyCultureParticipant__c 
                                                                             WHERE XC_EffectiveParticipation__c = true 
                                                                             AND XC_SafetyCultureEventName__c = :eventId
                                                                             AND XC_Safety_Culture_Account_Participant__r.XC_Account__c = :accountId];

        num = lstSafetyCultureParticipants.size();
        return num;
    }

    /**
    * @description compute denominator for participation rate KPI
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param eventId 
    * @param accountId 
    * @return Decimal 
    **/
    public static Decimal computeDenomParticipationRate(Id eventId, Id accountId){
        Decimal denom = 0;
        List<XC_SafetyCultureParticipant__c> lstSafetyCultureParticipants = [SELECT Id
                                                                             FROM XC_SafetyCultureParticipant__c 
                                                                             WHERE XC_SafetyCultureEventName__c = :eventId
                                                                             AND XC_Safety_Culture_Account_Participant__r.XC_Account__c = :accountId];
        
        denom = lstSafetyCultureParticipants.size();
        return denom;
    }

    /**
    * @description compute numerator for participation outcome KPI
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param eventId 
    * @param accountId 
    * @return Decimal 
    **/
    public static Decimal computeNumKPIparticipationOutcome(Id eventId, Id accountId){
        List<XC_SafetyCultureParticipant__c> lstSafetyCultureParticipants = [SELECT Id
                                                                             FROM XC_SafetyCultureParticipant__c 
                                                                             WHERE XC_EffectiveParticipation__c = true
                                                                             AND XC_Overcoming__c = 'Passed' 
                                                                             AND XC_SafetyCultureEventName__c = :eventId
                                                                             AND XC_Safety_Culture_Account_Participant__r.XC_Account__c = :accountId];

        return lstSafetyCultureParticipants.size();
    }

    /**
    * @description compute denominator for participation outcome KPI
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param eventId 
    * @param accountId 
    * @return Decimal 
    **/
    public static Decimal computeDenomParticipationOutcome(Id eventId, Id accountId){
        Decimal denom = 0;
        List<XC_SafetyCultureParticipant__c> lstSafetyCultureParticipants = [SELECT Id
                                                                             FROM XC_SafetyCultureParticipant__c 
                                                                             WHERE XC_SafetyCultureEventName__c = :eventId
                                                                             AND XC_Safety_Culture_Account_Participant__r.XC_Account__c = :accountId];
        
        denom = lstSafetyCultureParticipants.size();
        return denom;
    }


    /**
    * @description create a KPI Safety Culture detail record
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param requestId 
    * @param accountId 
    * @param country 
    * @return XC_KPISafetyCultureRequestDetail__c 
    **/
    public static XC_KPISafetyCultureRequestDetail__c createKPISafetyCultureDetail(Id requestId, XC_Safety_Culture_Account_Participant__c accountPart, String country) {
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id,XC_Safety_Culture_Event__c,XC_Safety_Culture_Event__r.XC_Name_of_the_Initiative__c, XC_Request_Details__c, 
                                                    XC_Request_Status__c,XC_User__c,XC_Request_Date__c 
                                                    FROM XC_KPI_Safety_Culture_Request__c WHERE Id = :requestId];

        Decimal numParticipationRate = computeNumKPIparticipationRate(request.XC_Safety_Culture_Event__c, accountPart.XC_Account__c);
        Decimal denomParticipationRate = computeDenomParticipationRate(request.XC_Safety_Culture_Event__c, accountPart.XC_Account__c);

        Decimal numParticipationOutcome = computeNumKPIparticipationOutcome(request.XC_Safety_Culture_Event__c, accountPart.XC_Account__c);
        Decimal denomParticipationOutcome = computeDenomParticipationOutcome(request.XC_Safety_Culture_Event__c, accountPart.XC_Account__c);
        
        XC_KPISafetyCultureRequestDetail__c kpi = new XC_KPISafetyCultureRequestDetail__c();
        kpi.XC_KPI_Safety_Culture_Request__c = requestId;
        kpi.XC_Account__c = accountPart.XC_Account__c;
        kpi.XC_Participation_Rate__c = denomParticipationRate != 0 ? (numParticipationRate / denomParticipationRate) : null;
        kpi.XC_Participation_Outcome__c = denomParticipationOutcome != 0 ? (numParticipationOutcome / denomParticipationOutcome) : null;
        kpi.XC_SPs_Added__c = denomParticipationRate != 0 && denomParticipationOutcome != 0 ? XC_UTIL_SafetyCultureKPI.computeBonusMalus(kpi.XC_Participation_Rate__c,kpi.XC_Participation_Outcome__c,accountPart.XC_ParticipationReason__c,country) : XC_UTIL_SafetyCultureKPI.computeBonusMalus(null,null,null,country);
        kpi.XC_User__c = request.XC_User__c;
        kpi.XC_Request_Date__c = request.XC_Request_Date__c;
        kpi.XC_Request_Status__c = 'To Be Applied';
        
        return kpi;
    }

    /**
    * @description create a KPI Safety Culture detail record with status = Error
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param requestId 
    * @param accountId 
    * @param country 
    * @param message 
    * @return XC_KPISafetyCultureRequestDetail__c 
    **/
    public static XC_KPISafetyCultureRequestDetail__c createKPISafetyCultureDetailError(String requestId, String accountId, String country, String message) {
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id,XC_Safety_Culture_Event__c, XC_Request_Details__c, 
                                                    XC_Request_Status__c,XC_User__c,XC_Request_Date__c 
                                                    FROM XC_KPI_Safety_Culture_Request__c WHERE Id = :requestId];
        
        XC_KPISafetyCultureRequestDetail__c kpi = new XC_KPISafetyCultureRequestDetail__c();
        kpi.XC_KPI_Safety_Culture_Request__c = requestId;
        kpi.XC_Account__c = accountId;
        kpi.XC_User__c = request.XC_User__c;
        kpi.XC_Request_Date__c = request.XC_Request_Date__c; 
        kpi.XC_Request_Status__c = 'Error';
        kpi.XC_Request_Details__c = message;

        return kpi;
    }
}
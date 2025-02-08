/**
 * @description       : Batch Class to perform the massive Safety Culture KPI calculation
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 29-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_BA006_KPISafetyCultureCalc implements Database.Batchable<SObject>, Database.StateFul{

    private static final String TO_BE_APPLIED = 'To Be Applied';
    private static final String ERROR = 'Error';

    private Set<String> accountIds = new Set<String>();
    private Integer nextTry = 1;
    private String requestEventId;
    private String requestId;
    private String country;

    public XC_BA006_KPISafetyCultureCalc(Set<String> accountIds,String requestEventId,String requestId, String country, Integer nextTry){
        this.accountIds = accountIds;
        this.requestEventId = requestEventId;
        this.requestId = requestId;
        this.country = country;
        this.nextTry = nextTry;
    }

    public XC_BA006_KPISafetyCultureCalc(String requestEventId,String requestId, String country){
        this.requestEventId = requestEventId;
        this.requestId = requestId;
        this.country = country;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT id,XC_Account__c, XC_AwarenessCampaign__c, XC_CompanyName__c, XC_Name_of_the_Initiative__c, '+
        'XC_Participation_Rate__c, XC_ParticipationReason__c, XC_ParticipationResult__c FROM XC_Safety_Culture_Account_Participant__c '+
        'WHERE XC_AwarenessCampaign__c = :requestEventId ';
        if (!accountIds.isEmpty()) {
            query += 'AND XC_Account__c IN :accountIds';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope){
        List<XC_Safety_Culture_Account_Participant__c> lstAccountParticipants = (List<XC_Safety_Culture_Account_Participant__c>) scope;
        XC_KPISafetyCultureRequestDetail__c requestDetail = new XC_KPISafetyCultureRequestDetail__c();
        
        for (XC_Safety_Culture_Account_Participant__c accountParticipant : lstAccountParticipants) {
            Savepoint sp = Database.setSavepoint();

            try {
                requestDetail = XC_BA006_KPISafetyCultureCalc_U.createKPISafetyCultureDetail(requestId, accountParticipant, country); 
                requestDetail.XC_RetryNumber__c = nextTry;
                insert requestDetail;
            } catch (Exception e) {
                Database.rollback(sp);
                requestDetail = XC_BA006_KPISafetyCultureCalc_U.createKPISafetyCultureDetailError(requestId, accountParticipant.XC_Account__c, country,  e.getMessage() + ': ' + e.getStackTraceString());
                requestDetail.XC_RetryNumber__c = nextTry;
                insert requestDetail;
            }
        }
        
    }

    public void finish(Database.BatchableContext bc){
        List<XC_KPISafetyCultureRequestDetail__c> errorDetails = [
            SELECT Id
            FROM XC_KPISafetyCultureRequestDetail__c
            WHERE XC_KPI_Safety_Culture_Request__c = :requestId AND XC_Request_Status__c = 'Error' AND XC_RetryNumber__c = :nextTry
        ];
        
        List<String> errorIds = new List<String>();
        for(XC_KPISafetyCultureRequestDetail__c d : errorDetails) {
            errorIds.add(d.Id);
        }

        XC_KPI_Safety_Culture_Request__c req = new XC_KPI_Safety_Culture_Request__c();
        req.Id = requestId;

        if(errorDetails.isEmpty()) {
            req.XC_Request_Status__c = TO_BE_APPLIED;
            req.XC_Request_Details__c = '';
        } else {
            req.XC_Request_Status__c = ERROR;
            req.XC_Request_Details__c = String.valueOf(errorDetails.size()) + ' Safety Culture KPI Request Detail failed: ' + String.join(errorIds, ', ');
        }
        update req;
    }
}
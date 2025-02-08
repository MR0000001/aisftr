/**
 * @description       : This class is called from the XC_FL_KPISafetyCulture flow 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 29-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_IN090_KPISafetyCultureRequest {
    
    private static final Integer CHUNK_SIZE = 1;
    private static final String IN_PROGRESS = 'In Progress';
    private static final String ERROR = 'Error';

    public class FlowInputs{
        
        @InvocableVariable
        public String requestId;
        
    }

    /**
    * @description method to launch the batch that computes Safety culture KPI. The batch execute 1 record at a time to handle errors on KPI calculation
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param flowInputs inputs coming from the XC_FL_KPISafetyCulture flow
    **/
    @InvocableMethod
    public static void computeSafetyCultureKPI(List<FlowInputs> flowInputs){
        if (!flowInputs.isEmpty()) {
            XC_KPI_Safety_Culture_Request__c safetyCultureRequest = [SELECT Id,XC_Country__c,XC_Safety_Culture_Event__c,XC_Request_Status__c FROM XC_KPI_Safety_Culture_Request__c WHERE Id = :flowInputs[0].requestId];
            if(String.isBlank(safetyCultureRequest.XC_Country__c)) { return; }
            if(IN_PROGRESS.equals(safetyCultureRequest.XC_Request_Status__c)) {
                Database.executeBatch(new XC_BA006_KPISafetyCultureCalc(safetyCultureRequest.XC_Safety_Culture_Event__c,safetyCultureRequest.Id, safetyCultureRequest.XC_Country__c), CHUNK_SIZE);
            } else if(ERROR.equals(safetyCultureRequest.XC_Request_Status__c)) {
                List<XC_KPISafetyCultureRequestDetail__c> errorDetails = [
                    SELECT Id,XC_Account__c,XC_RetryNumber__c
                    FROM XC_KPISafetyCultureRequestDetail__c
                    WHERE XC_KPI_Safety_Culture_Request__c = :safetyCultureRequest.Id AND XC_Request_Status__c = :ERROR
                    ORDER BY XC_RetryNumber__c DESC
                ];
                Set<String> accountIds = new Set<String>();
                Integer lastRetry;
                for(XC_KPISafetyCultureRequestDetail__c d : errorDetails) {
                    if(lastRetry == null) {
                        lastRetry = Integer.valueOf(d.XC_RetryNumber__c);
                    }
                    if(lastRetry == Integer.valueOf(d.XC_RetryNumber__c)) {
                        accountIds.add(d.XC_Account__c);
                    }
                }
                Database.executeBatch(new XC_BA006_KPISafetyCultureCalc(accountIds,safetyCultureRequest.XC_Safety_Culture_Event__c,safetyCultureRequest.Id, safetyCultureRequest.XC_Country__c,lastRetry + 1), CHUNK_SIZE);
            }
        } 
    }
}
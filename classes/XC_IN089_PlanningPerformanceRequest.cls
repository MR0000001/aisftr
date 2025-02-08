/**
 * @author            :  Alessandro Catto alessandro11.catto@nttdata.com
 * @date Creation     :  09/05/2022
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN089_PlanningPerformanceRequest - This class is called from the XC_FL_PlanningPerformanceKPIcalculation flow 
*/
public without sharing class XC_IN089_PlanningPerformanceRequest {

    private static final Integer CHUNK_SIZE = 1;
    private static final String IN_PROGRESS = 'In Progress';
    private static final String ERROR = 'Error';

     /**     
    * The Class InputWrapper.
    * @description InputWrapper
    */
    public class InputWrapper{
        @Invocablevariable     
        public String requestId;       
    }

     /**
    * @param inputWrapperList inputs coming from the XC_FL_PlanningPerformanceKPIcalculation flow
    * @description method to launch the batch that computes Planning Performance KPI. The batch execute 1 record at a time to handle errors on KPI calculation, on SPW updates and on history tracking
    */
    @InvocableMethod 
    public static void computePlanningPerformances(List<InputWrapper> inputList) {
        if(!inputList.isEmpty()) {
            InputWrapper input = inputList.get(0);
            XC_KPI_Planning_Performance__c request = [SELECT Id, XC_Country__c, XC_Request_Status__c FROM XC_KPI_Planning_Performance__c WHERE Id = :input.requestId LIMIT 1];
            if(String.isBlank(request.XC_Country__c)) { return; }
            if(IN_PROGRESS.equals(request.XC_Request_Status__c)) {
                Database.executeBatch(new XC_BA004_PlanningPerfKPICalc(request.Id, request.XC_Country__c), CHUNK_SIZE);
            } else if(ERROR.equals(request.XC_Request_Status__c)) {
                List<XC_KPI_Planning_Performance_Detail__c> errorDetails = [
                    SELECT Id, XC_Account__c, XC_RetryNumber__c
                    FROM XC_KPI_Planning_Performance_Detail__c
                    WHERE XC_KPI_Planning_Performance__c = :request.Id AND XC_Request_Status__c = :ERROR
                    ORDER BY XC_RetryNumber__c DESC
                ];
                Set<String> accountIds = new Set<String>();
                Integer lastRetry;
                for(XC_KPI_Planning_Performance_Detail__c d : errorDetails) {
                    if(lastRetry == null) {
                        lastRetry = Integer.valueOf(d.XC_RetryNumber__c);
                    }
                    if(lastRetry == Integer.valueOf(d.XC_RetryNumber__c)) {
                        accountIds.add(d.XC_Account__c);
                    }
                }
                Database.executeBatch(new XC_BA004_PlanningPerfKPICalc(accountIds, request.Id, request.XC_Country__c, lastRetry + 1), CHUNK_SIZE);
            }
        }
    }
}
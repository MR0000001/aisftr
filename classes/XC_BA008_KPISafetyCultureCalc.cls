public without sharing class XC_BA008_KPISafetyCultureCalc implements Database.Batchable<SObject> {
    
    private class NoWalletException extends Exception {}
    
    private static final String SAFETY_CULTURE = 'Safety Culture';
    private static final String COMPLETED = 'Completed';
    private static final String ERROR = 'Error';
    private static final String TO_BE_APPLIED = 'To Be Applied';
    
    private String requestId;
    
    public XC_BA008_KPISafetyCultureCalc(String requestId) {
    this.requestId = requestId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,XC_Account__c,XC_SPs_Added__c, XC_Participation_Outcome__c, XC_Participation_Rate__c, XC_KPI_Safety_Culture_Request__r.XC_Safety_Culture_Event__c FROM XC_KPISafetyCultureRequestDetail__c WHERE XC_Request_Status__c = :TO_BE_APPLIED AND XC_KPI_Safety_Culture_Request__c = :requestId';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<XC_KPISafetyCultureRequestDetail__c> detailsList) {
        for(XC_KPISafetyCultureRequestDetail__c detail : detailsList){
            safetyCultureApplyKPI(detail);
        }
        
    }
    
    public static void safetyCultureApplyKPI(XC_KPISafetyCultureRequestDetail__c requestDetail){
        Account acc = [SELECT Id,XC_SafetyPointLicenseActivationDate__c FROM Account WHERE Id =: requestDetail.XC_Account__c];
        XC_Safety_Culture_Account_Participant__c accParticipant = [SELECT Id, XC_ParticipationReason__c, XC_Account__c, XC_AwarenessCampaign__c FROM XC_Safety_Culture_Account_Participant__c WHERE XC_Account__c = :acc.Id 
        AND XC_AwarenessCampaign__c = :requestDetail.XC_KPI_Safety_Culture_Request__r.XC_Safety_Culture_Event__c];
        Savepoint sp = Database.setSavepoint();
        try{
            if(accParticipant.XC_ParticipationReason__c == 'Point Tank Reset'){
                if(requestDetail.XC_Participation_Outcome__c == 1 && requestDetail.XC_Participation_Rate__c == 1){
                    Map<String, Object> params = new Map<String, Object>();
                    params.put('accountId', acc.Id);
                    params.put('detailKPIInputId', requestDetail.Id);
                    params.put('KPIType', SAFETY_CULTURE);
                    System.debug('params = '+params);
                    Flow.Interview.XC_FL_RenewSafetyPointWallet_Autolaunched renewWalletFlow = new Flow.Interview.XC_FL_RenewSafetyPointWallet_Autolaunched(params);
                    renewWalletFlow.start();
                    requestDetail.XC_Request_Status__c = COMPLETED;
                    if(renewWalletFlow.getVariableValue('messageMaxReached') != null){
                        requestDetail.XC_Request_Status__c = ERROR;
                        requestDetail.XC_Request_Details__c = (String) renewWalletFlow.getVariableValue('messageMaxReached');
                    }                   
                } else {
                    requestDetail.XC_Request_Status__c = COMPLETED;
                }
                update requestDetail;
            } else {
        	    List<XC_SafetyPointWallet__c> wallets = XC_UTIL_SafetyPointsWalletManagement.getUsableWallets(acc.Id);
        	    if(!wallets.isEmpty()) {
				    Map<String, Object> params = new Map<String, Object>();
				    params.put('walletIdInput', wallets.get(0).Id);
				    params.put('detailKPIInputId', requestDetail.Id);
				    params.put('pointsToAdd', requestDetail.XC_SPs_Added__c);
				    params.put('KPIType', SAFETY_CULTURE);
				    System.debug('params = '+params);
				    Flow.Interview.XC_FL_UpsertSafetyPointWallet upsertWalletFlow = new Flow.Interview.XC_FL_UpsertSafetyPointWallet(params);
				    upsertWalletFlow.start();
                    requestDetail.XC_Request_Status__c = COMPLETED;
                    update requestDetail;
    		    } else {                
                    throw new NoWalletException('No Active or Suspended wallet');
                }
            }                    
        }
        catch(NoWalletException ex){
            requestDetail.XC_Request_Status__c = ERROR;
            requestDetail.XC_Request_Details__c = ex.getMessage();
            update requestDetail;
        }
        catch(Exception ex) {
            Database.rollback(sp);
            requestDetail.XC_Request_Status__c = ERROR;
            requestDetail.XC_Request_Details__c = ex.getMessage() + ' ' + ex.getStackTraceString();
            update requestDetail;
        }
	}
    
    public void finish(Database.BatchableContext bc) {        
        List<XC_KPISafetyCultureRequestDetail__c> errorDetails = [            
            SELECT Id
            FROM XC_KPISafetyCultureRequestDetail__c
            WHERE XC_KPI_Safety_Culture_Request__c = :requestId AND XC_Request_Status__c = :ERROR
            ];
        List<String> errorIds = new List<String>();
        for(XC_KPISafetyCultureRequestDetail__c d : errorDetails) {
            errorIds.add(d.Id);
        }
        XC_KPI_Safety_Culture_Request__c req = new XC_KPI_Safety_Culture_Request__c();
        req.Id = requestId;
        if(errorDetails.isEmpty()) {
            req.XC_Request_Status__c = COMPLETED;
            req.XC_Request_Details__c = '';
        } else {
            req.XC_Request_Status__c = ERROR;
            req.XC_Request_Details__c = String.valueOf(errorDetails.size()) + ' Safety Culture Request Detail failed: ' + String.join(errorIds, ', ');
        }
        update req;
        
    }

}
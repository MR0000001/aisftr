/**
 * @description       : Batch Class to perform the Good Behavior Bonus KPI calculation
 * @author            : rui.pedroteixeira@nttdata.com
 * @last modified on  : 21-06-2022
 * @last modified by  : rui.pedroteixeira@nttdata.com
**/
public without sharing class XC_BA007_KPIGoodBehaviorBonus implements Schedulable, Database.Batchable<SObject>,Database.StateFul  {


    private static final String ACCOUNT_PARTNER_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
    private static final String GOOD_BEHAVIOR = 'Good Behavior';
    private static final String COMPLETED = 'Completed';
    private static final String ERROR = 'Error';
    private String query;
    private Set<String> countrys;
    private String requestId;
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        XC_KPI_Good_Behavior_Request__c kpiGbr = XC_BA007_KPIGoodBehaviorBonus_U.createKPIRequest();
        insert kpiGbr;
        this.requestId = kpiGbr.id;

        this.countrys = XC_BA007_KPIGoodBehaviorBonus_U.getCountrysWithKPIGoodBehaviorBonusEnabled();

        String query ='SELECT Id,XC_Account__c,XC_SPW_Status__c,XC_SPW_Balance__c ' +
        ' FROM XC_SafetyPointWallet__c '+ 
        ' WHERE XC_Account__r.Country__c IN :countrys '+
        ' AND XC_Account__r.RecordTypeId = :ACCOUNT_PARTNER_RT '+
        ' AND XC_To_Compute_Good_Behaviour__c = true '+
        ' AND XC_SPW_ActivationDate__c < LAST_N_DAYS:1 ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope){
        XC_KPI_Good_Behavior_Request_Detail__c gbrd = new XC_KPI_Good_Behavior_Request_Detail__c();
        List<XC_SafetyPointWallet__c> lstSafetyPointWallet = (List<XC_SafetyPointWallet__c>) scope;
        Map<Id,XC_SafetyPointWallet__c> mapAccountsWallet = new Map<Id,XC_SafetyPointWallet__c>();

        for (XC_SafetyPointWallet__c safetyPointWallet : lstSafetyPointWallet) {
            mapAccountsWallet.put(safetyPointWallet.XC_Account__c, safetyPointWallet);
        }
       
        if(mapAccountsWallet != null){
            Map<Id, Map<String,Integer>> mapAccountsTotalQualityChecks = XC_BA007_KPIGoodBehaviorBonus_U.getAccountTotalQualityChecks(mapAccountsWallet.keyset());

           
            for (Id acc : mapAccountsTotalQualityChecks.keyset()) {
                Savepoint sp = Database.setSavepoint();
                try {

                    Map<String,Integer> mapFieldsTotal = new Map<String,Integer>();
                    mapFieldsTotal = mapAccountsTotalQualityChecks.get(acc);
                    gbrd = XC_BA007_KPIGoodBehaviorBonus_U.createKPIDetail(this.requestId, acc, mapFieldsTotal);
                    insert gbrd;

                    Integer total = 0;

                    for (String fields : mapFieldsTotal.keySet()) {
                        total = total + mapFieldsTotal.get(fields);
                    }

                    if (total == 0 || total == 1) {
                        Map<String, Object> params = new Map<String, Object>();
                            params.put('walletIdInput', mapAccountsWallet.get(acc).id);
                            params.put('detailKPIInputId', gbrd.id );
                            params.put('pointsToAdd', 10);
                            params.put('KPIType', GOOD_BEHAVIOR);
                            Flow.Interview.XC_FL_UpsertSafetyPointWallet upsertWalletFlow = new Flow.Interview.XC_FL_UpsertSafetyPointWallet(params);
                            upsertWalletFlow.start();
                    }
                } catch (Exception e) {
                    System.debug('Exception caught: ' + e.getMessage() + ' ' + e.getStackTraceString());
                    Database.rollback(sp);
                    gbrd = XC_BA007_KPIGoodBehaviorBonus_U.createKPIDetailError(this.requestId, acc, e.getMessage() + ': ' + e.getStackTraceString());
                    insert gbrd;
                }
            }
        } 
    }

    public void execute(SchedulableContext sc){
        XC_BA007_KPIGoodBehaviorBonus goodBehaviorBonusBatch = new XC_BA007_KPIGoodBehaviorBonus ();
        Database.executeBatch(goodBehaviorBonusBatch, 1);
    }

    public void finish(Database.BatchableContext bc){
        List<XC_KPI_Good_Behavior_Request_Detail__c> errorDetails = [
            SELECT Id,KPI_Good_Behavior_Request__c
            FROM XC_KPI_Good_Behavior_Request_Detail__c
            WHERE KPI_Good_Behavior_Request__c = :requestId AND XC_Request_Status__c = 'Error'
        ];
        List<String> errorIds = new List<String>();
        for(XC_KPI_Good_Behavior_Request_Detail__c d : errorDetails) {
            errorIds.add(d.Id);
        }
        XC_KPI_Good_Behavior_Request__c req = [
            SELECT Id
            FROM XC_KPI_Good_Behavior_Request__c
            WHERE id = :requestId
            LIMIT 1
        ];
        if(errorDetails.isEmpty()) {
            req.XC_Request_Status__c = COMPLETED;
            req.XC_Request_Details__c = '';
        } else {
            req.XC_Request_Status__c = ERROR;
            req.XC_Request_Details__c = String.valueOf(errorDetails.size()) + ' Planning Performance Request Detail failed: ' + String.join(errorIds, ', ');
        }
        update req;
    }
}
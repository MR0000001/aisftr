/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 07/12/2021
 * @date Modification dd/mm/yyyy
 * @description XC_SC063_CheckObsoleteQueuedRequest – Class to check queued request steps duplicated and to be considered as obsolete
 */

public class XC_SC063_CheckObsoleteQueuedRequest implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC063_CheckObsoleteQueuedRequest');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC063_CheckObsoleteQueuedRequest());
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start batch XC_SC063_CheckObsoleteQueuedRequest');
        String addCondition = String.valueOf(Label.XC_CL_SC063Conditions);
        String query = 'SELECT Id, CreatedDate, XC_DuplicationId__c, LastModifiedDate, XC_IntegrationId__c FROM XC_QueuedRequest__c ' + 
                            ' WHERE XC_Obsolete__c = false AND XC_ProcessedByBatch__c = false ';
        //query +=  addCondition ;
        String dateTimeToFilter = '';
        String limitRecords = '';
        String conditionFilter = '';
        if(Test.isRunningTest()){
            addCondition = 'AND LastModifiedDate =: LAST_N_DAYS:300  LIMIT 20000';
        }
        if(addCondition.contains('LastModifiedDate')){
            conditionFilter = 'AND LastModifiedDate >';
        } else if(addCondition.contains('CreatedDate')){
            conditionFilter = 'AND CreatedDate >';
        } 
        if(addCondition.contains('LAST_MONTH')){
            dateTimeToFilter = String.valueOf (System.now().addDays(-30) );
            dateTimeToFilter = dateTimeToFilter.replace(' ', 'T');
            dateTimeToFilter+='.000+00:00';
        } else if(addCondition.contains('LAST_N_DAYS:') ){
            Integer i1 = addCondition.lastIndexOfIgnoreCase('LAST_N_DAYS:');
            Integer daysNumber = Integer.valueOf(addCondition.mid(i1+12, 3));
            dateTimeToFilter = String.valueOf (System.now().addDays(-daysNumber) );
            dateTimeToFilter = dateTimeToFilter.replace(' ', 'T');
            dateTimeToFilter+='.000+00:00';
        } else if(addCondition.contains('LAST_WEEK')) {
            dateTimeToFilter = String.valueOf (System.now().addDays(-7) );
            dateTimeToFilter = dateTimeToFilter.replace(' ', 'T');
            dateTimeToFilter+='.000+00:00';
        }
        if(addCondition.contains('LIMIT')){
            Integer i1 = addCondition.lastIndexOfIgnoreCase('LIMIT');
            Integer finalCharacter = addCondition.length();
            Integer limitNumber = Integer.valueOf(addCondition.mid(i1 + 6, finalCharacter));
            limitRecords = ' LIMIT ' + limitNumber;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_SC063_CheckObsoleteQueuedRequest: limitRecords ---> ' + limitRecords);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_SC063_CheckObsoleteQueuedRequest: dateTimeToFilter ---> ' + dateTimeToFilter);
        query += conditionFilter + dateTimeToFilter + ' ORDER BY XC_DuplicationId__c desc ' + limitRecords;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_SC063_CheckObsoleteQueuedRequest: QUERY ---> ' + query);
        System.debug('@@@debug query --> '+ query);
        return Database.getQueryLocator(query);
                                       
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_QueuedRequest__c> scope){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute batch XC_SC063_CheckObsoleteQueuedRequest');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_SC063_CheckObsoleteQueuedRequest: scope ---> ' + scope);
        List<XC_QueuedRequest__c> queuedRequestToUpdate = new List<XC_QueuedRequest__c>();
        Map<String, List<XC_QueuedRequest__c>> queuedRequestsMap = getObsoleteQueuedRequests(scope);
        Set<String> queuedRequestsId = new Set<String>();
        for(String keyQr : queuedRequestsMap.keyset()){
            XC_QueuedRequest__c lastQr = new XC_QueuedRequest__c();
            if(queuedRequestsMap.get(keyQr) == null){
                continue;
            }
            for(XC_QueuedRequest__c qr : queuedRequestsMap.get(keyQr) ){
                if(String.isEmpty(lastQr.Id)) {
                    lastQr = qr;
                    continue;
                }
                if(qr.CreatedDate > lastQr.CreatedDate){
                    lastQr = qr;
                }
            }
            for(XC_QueuedRequest__c qr : queuedRequestsMap.get(keyQr) ){
                if(queuedRequestsId.contains(qr.Id)){
                    continue;
                }
                queuedRequestsId.add(qr.Id);
                qr.XC_ProcessedByBatch__c = true;
                if(qr != lastQr){
                    qr.XC_Obsolete__c = true;
                }
                queuedRequestToUpdate.add(qr);
            }
        }

        XC_TR_QueuedRequest_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_QueuedRequest_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(queuedRequestToUpdate);
        XC_TR_QueuedRequest_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_QueuedRequest_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>(); 
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = insertLogError(wr);
            }
        }
        if(!errorLog.isEmpty()){
            XC_UTIL_Sobject.insertListRecords(errorLog);
        }
    }    
    /**
    * @description retrieve the old and duplicated queued requests
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12-02-2021 
    * @param keySet 
    * @param newIdSet 
    * @return Map<String, List<XC_QueuedRequest__c>> 
    **/
    private static Map<String, List<XC_QueuedRequest__c>> getObsoleteQueuedRequests(List<XC_QueuedRequest__c> scope) {
        Set<String> keySet = new Set<String>();
        for(XC_QueuedRequest__c qr : scope ){
            if(!String.isEmpty(qr.XC_DuplicationId__c) && !String.isEmpty(qr.XC_IntegrationId__c) ){
                keySet.add(qr.XC_DuplicationId__c);
            }    
        }
        List<XC_QueuedRequest__c> oldQueuedStepList = new List<XC_QueuedRequest__c>([SELECT Id, XC_Obsolete__c, XC_DuplicationId__c, CreatedDate
                                                                    FROM XC_QueuedRequest__c
                                                                    WHERE XC_DuplicationId__c IN: keySet 
                                                                    ORDER BY CreatedDate DESC ]);
        Map<String, List<XC_QueuedRequest__c>> queuedRequestsMap = new Map<String, List<XC_QueuedRequest__c>>();
        for(XC_QueuedRequest__c qr : oldQueuedStepList){
            if(!queuedRequestsMap.containsKey(qr.XC_DuplicationId__c) ){
                queuedRequestsMap.put(qr.XC_DuplicationId__c, new List<XC_QueuedRequest__c>());
            }
            queuedRequestsMap.get(qr.XC_DuplicationId__c).add(qr);
        }
        return queuedRequestsMap;
    }
    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ finish XC_SC063_CheckObsoleteQueuedRequest');
    }
    
    /**
    * @description insert error logs
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12-02-2021 
    **/
    @TestVisible
    private static XC_BatchErrorLog__c insertLogError(XC_UTIL_Sobject.WrapperResult wr){
        XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
        bel.Name = 'XC_SC063_CheckObsoleteQueuedRequest';
        bel.XC_ErrorMessage__c = wr.errorMessage;
        bel.XC_TypeOfOperation__c = 'Update obsolete QueuedRequest';
        bel.XC_RecordId__c = wr.errorObjectId; 
        return bel;
    }    
}
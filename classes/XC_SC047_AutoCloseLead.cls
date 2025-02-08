/**
* @author Marco Ottaviano - mottaviano@deloitte.it
* @date Creation 29/03/2021
* @date Modification 
* @date Modification 
* @description XC_SC047_AutoCloseLead – Batch used to automatically close a lead based on the LastModifyDate and XC_EnOldLeads_AutoClosure__c field on XC_CM_LegalEntity_Configuration__mdt records
*                                      
*/

public without sharing class XC_SC047_AutoCloseLead implements Schedulable, Database.Batchable<sObject>,Database.Stateful {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC047_AutoCloseLead');
    private final static Integer NDAY = 40;
    private Map<String,Boolean> mapLegalEntityAutomaticClosure; 
    
    /**
	* @description execute method
	* @param sc - SchedulableContext 
	*/ 
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC047_AutoCloseLead(),50);
    }

    public XC_SC047_AutoCloseLead() {
        this.mapLegalEntityAutomaticClosure = populateAutomaticClosurMap();
    } 
    
    /**
    * @description start method
    * @param bc - BatchableContext 
    * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC047_AutoCloseLead'); 
      
        Id userId = UserInfo.getUserId();
        String query = 'SELECT Id, XC_MainLegalEntity__c,XC_Segment__c,XC_Why_not_converted__c, XC_LeadToBeClosed__c, Status ' + 
            'FROM Lead WHERE Status != \'' + Label.XC_CL_Lead_ClosedNotConverted + '\' AND Status != \'' + Label.XC_CL_Lead_ClosedConverted + '\'';/*+  
            ' AND CreatedById !=:userId';*/

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query ---> ' + query); 
        String nDays = 'LAST_N_DAYS:' + NDAY.format();

        if(!Test.isRunningTest()) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Is not a TEST'); 
            query += ' AND XC_Lead_DaysSinceModify__c > ' + NDAY + ' order by LastModifiedDate asc';
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Final Query ---> ' + query); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method for batch XC_SC047_AutoCloseLead'); 
        System.debug('Query' + query);
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<Lead> scope) {   
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Enter in execute method');
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        List<Lead> listLeadToProcess = new List<Lead>();
        for(Lead ld : scope) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Lead ---> ' + ld); 
            System.debug('Lead' + ld);
            
            String keyAccessMap = (String.isNotBlank(ld.XC_MainLegalEntity__c) && String.isNotBlank(ld.XC_Segment__c)) ? ld.XC_MainLegalEntity__c + ld.XC_Segment__c : null;
            if(String.isNotBlank(keyAccessMap) && mapLegalEntityAutomaticClosure.containsKey(keyAccessMap) && mapLegalEntityAutomaticClosure.get(keyAccessMap)) {
                ld.XC_Why_not_converted__c = Label.XC_CL_Lead_ClosedFromBatch;
                ld.Status = Label.XC_CL_Lead_ClosedNotConverted;
                listLeadToProcess.add(ld);
            } 
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listLeadToProcess ---> ' + listLeadToProcess); 
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listLeadToProcess, false);
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = getErrorLog(wr.errorMessage, wr.errorObjectId);
                errorLog.add(bel);
            }
        }
        XC_UTIL_Sobject.insertListRecords(errorLog);
        
    }   
    
    /**
    * @description finish method
    * @param bc - BatchableContext 
    */
    public void finish(Database.batchablecontext bc) {        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC001_AutoCloseLead');
    }

    private static Map<String,Boolean> populateAutomaticClosurMap() {
        Map<String,Boolean> mapreturned = new Map<String,Boolean>();
        List<XC_CM_LegalEntity_Configuration__mdt> listConfigEnabled= [SELECT Id,XC_LegalEntity__c, XC_Stream__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: UserInfo.getOrganizationId() AND XC_EnOldLeads_AutoClosure__c = true];
        if(!listConfigEnabled.isEmpty()) {
            for(XC_CM_LegalEntity_Configuration__mdt config : listConfigEnabled) {
                if(String.isNotBlank(config.XC_Stream__c) && String.isNotBlank(config.XC_LegalEntity__c)) {
                    mapreturned.put(config.XC_LegalEntity__c + config.XC_Stream__c,true);
                }
            }
        }
        return mapreturned;
    }

    public static XC_BatchErrorLog__c getErrorLog(String errorMessage, String errorObjectId) {
        XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
        bel.Name = 'XC_SC047_AutoCloseLead';
        bel.XC_ErrorMessage__c = errorMessage;
        bel.XC_TypeOfOperation__c = 'Close Lead based on LastModifyDate';
        bel.XC_RecordId__c = errorObjectId;
        return bel;
    }

 
}
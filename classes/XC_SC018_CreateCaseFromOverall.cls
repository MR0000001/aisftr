/**
* @author Chiara Turco - cturco@deloitte.it
* @date Creation 18/07/2019
* @description XC_SC018_CreateCaseFromOverall – Create case from Service Resource Document
*/
public with sharing class XC_SC018_CreateCaseFromOverall implements Database.Batchable<sObject> {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC018_CreateCaseFromOverall');
    
    /**
     * @author Chiara Turco - cturco@deloitte.it
     * @description start
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */

public Database.QueryLocator start(Database.BatchableContext bc) {
    if(!Schema.sObjectType.Case.isAccessible()){
        return null;
    }
    String query =  'SELECT Id,XC_ServiceResource__r.XC_Account__c, XC_ServiceResource__r.XC_Contact__c, XC_OverallResult__c' + 
                    ' FROM XC_ServiceResourceDocument__c ' +
                    ' WHERE XC_OverallResult__c= \'' + Label.XC_CL_NotCredit + '\'';                    
    XC_UTIL_Debug.debug(DEBUGACTIVE, 'query' + query);              
    return Database.getQueryLocator(query);
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<XC_ServiceResourceDocument__c> scope) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'scope ' + scope); 
        List<Case> listCase = new List<Case>();
        Map<String,XC_ServiceResourceDocument__c> partnerDocuments = new Map<String,XC_ServiceResourceDocument__c>();
         Map<Id,Group> boQueueMap = new Map<Id,Group> ([SELECT Id, DeveloperName
                               FROM Group
                               WHERE DeveloperName ='XC_ESP_BO_Administrative_Queue']);
        List<Group> boQueueList = boQueueMap.values();
        for(XC_ServiceResourceDocument__c doc : scope){
            partnerDocuments.put(doc.XC_ServiceResource__r.XC_Contact__c,doc);
        }
         Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_OverallResult});
         XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_OverallResult);
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_OverallResult}));
        }
        for(XC_ServiceResourceDocument__c doc:partnerDocuments.values()){
            Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
            c.ContactId = doc.XC_ServiceResource__r.XC_Contact__c;
            c.OwnerId = boQueueList[0].Id;
            listCase.add(c);
        }
        // XC_UTIL_Sobject.insertListRecords(listCase);

    
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.insertListRecords(listCase);
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){ 
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC018_CreateCaseFromOverall';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Create Case from Service Resource Document';
                errorLog.add(bel);
            }
        }
		XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC018_CreateCaseFromOverall ID');        
    }


}
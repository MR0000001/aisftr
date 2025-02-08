/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 17/07/2019
* @description XC_SC017_DeactivatePartnerFromOverall – Deactivate the Partner if a certain amount of time has passed
*/
public with sharing class XC_SC017_DeactivatePartnerFromOverall implements Schedulable, Database.Batchable<sObject> {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC017_DeactivatePartnerFromOverall');
    
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @description start
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.Case.isAccessible()){
            return null;
        }
        String query =  'SELECT Id, AccountId, CreatedDate, Account.XC_Status__c, Status' + 
                        ' FROM Case ' +
                        ' WHERE Contact.RecordType.DeveloperName= \'' + Label.XC_CL_Contact_Partner + '\''+
                        ' AND Status != \'' + Label.XC_CL_Case_Status007 + '\'' +
                        ' AND Account.XC_Status__c = \'' + Label.XC_CL_AccountActive + '\'';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'query' + query);              
        return Database.getQueryLocator(query);
    }

    /**
     * @description execute method
     * @param sc - SchedulableContext
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC017_DeactivatePartnerFromOverall());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC017_DeactivatePartnerFromOverall ' + batchId); 
	}

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'scope ' + scope); 
        List<Id> accountIds = XC_UTIL_Sobject.getIds(scope);
        Map<String,XC_CM_Case_Type_Setting__mdt> caseTypeSettingsMtd =  new Map<String,XC_CM_Case_Type_Setting__mdt>([
                                                                    SELECT Id, XC_DaysForRectify__c 
                                                                    FROM XC_CM_Case_Type_Setting__mdt 
                                                                    WHERE DeveloperName =: Label.XC_CL_CMD_OverallResult]);                                                                  
        List<XC_CM_Case_Type_Setting__mdt> caseTypeSetting = caseTypeSettingsMtd.values();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'caseTypeSetting' + caseTypeSetting);
        List<Account> accListToUpdate = new List<Account>();
        Integer daysToRectify = (Integer)(caseTypeSetting[0].XC_DaysForRectify__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'daysToRectify' + daysToRectify);
        for(Case c : scope){
            Map<String, String> mapCaseAccount = new Map<String, String>();
            mapCaseAccount.put(c.Id, c.AccountId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapCaseAccount' + mapCaseAccount);
            if(DateTime.now() > c.CreatedDate.addDays(daysToRectify)){
                Account acc = new Account();
                acc.Id = mapCaseAccount.get(c.Id);
                acc.XC_Status__c = Label.XC_CL_Account_StatusInactive;
                accListToUpdate.add(acc);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.updateListRecords(accListToUpdate);
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC017_DeactivatePartnerFromOverall';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Deactivate Partner Account';
                bel.XC_RecordId__c = wr.errorObjectId;
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
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC017_DeactivatePartnerFromOverall ID');
    }

}
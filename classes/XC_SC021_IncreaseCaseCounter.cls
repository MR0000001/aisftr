/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 05/08/2019
* @date Modification dd/mm/yyyy
* @description XC_SC021_IncreaseCaseCounter – batch for increase counter field of Case
*/


public without sharing class XC_SC021_IncreaseCaseCounter implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC021_IncreaseCaseCounter');

    /**
	* @description execute method
	* @param sc - SchedulableContext 
	*/ 
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC021_IncreaseCaseCounter());
    }
    
    /**
    * @description start method
    * @param bc - BatchableContext 
    * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC021_IncreaseCaseCounter');

        String recordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Complaint_Case').getRecordTypeId();
        String query = 'SELECT Id, XC_CustomerCounter__c, XC_EnelXcounter__c, XC_OthersCounter__c, XC_TotalCounter__c, Status, XC_SubStatus__c'
                    + ' FROM Case '
                    + ' WHERE RecordTypeId =: recordType';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Query ---> ' + query);
					

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method for batch XC_SC021_IncreaseCaseCounter'); 
        return Database.getQueryLocator(query);
    }


    /**
    * @description execute method
    * @param bc - BatchableContext 
    * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<Case> scope) {   
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Enter in execute method');
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();

        List<Case> listCaseToProcess = new List<Case>();
        for(Case c : scope) {
            listCaseToProcess.add(manageStatusCase(c));
        }

        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listCaseToProcess, false);
        for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                errorLog.add(createBatchError(wr, 'XC_SC021_IncreaseCaseCounter', 'Increase Counter fields of Case'));
            }
        }

        XC_UTIL_Sobject.insertListRecords(errorLog);       
    }

    //metodo per dividere il codice a causa del PMD
    public Case manageStatusCase(Case c){
        // if is INPROGRESS or if is OPEN increase enelXCounter
        if( c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA001 || c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA003){
            System.debug('Increase enelX');
            if(c.XC_EnelXcounter__c == null){
                c.XC_EnelXcounter__c = 0;
            }
            c.XC_EnelXcounter__c = c.XC_EnelXcounter__c + 1;
        //Pending
        }else if( c.Status== XC_AT_Constants.TRIGGER_STATUS_ESTA002){
            manageSubStatus(c);
        //OnHold
        }else if(c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA004 ){
            //Administration || Customer
            if( c.XC_SubStatus__c ==  XC_AT_Constants.CASE_SUBSTATUS_SUB002|| c.XC_SubStatus__c == XC_AT_Constants.CASE_SUBSTATUS_SUB001){
                if(c.XC_CustomerCounter__c == null ){
                    c.XC_CustomerCounter__c = 0;
                }
                c.XC_CustomerCounter__c = c.XC_CustomerCounter__c + 1;
            }
        }
        c.XC_TotalCounter__c = c.XC_CustomerCounter__c + c.XC_OthersCounter__c + c.XC_EnelXcounter__c;
        return c;
    }

    //divide code for PMD
    public Case manageSubStatus(Case c){
        //Market ||Other team
        if( c.XC_SubStatus__c == XC_AT_Constants.CASE_SUBSTATUS_SUB004 || c.XC_SubStatus__c == XC_AT_Constants.CASE_SUBSTATUS_SUB006 ){
            if( c.XC_CustomerCounter__c == null){
                c.XC_CustomerCounter__c = 0;
            }
            c.XC_EnelXcounter__c = c.XC_EnelXcounter__c + 1;
            //Banck ||Other partner
        }else if( c.XC_SubStatus__c == XC_AT_Constants.CASE_SUBSTATUS_SUB003 || c.XC_SubStatus__c ==XC_AT_Constants.CASE_SUBSTATUS_SUB007 ){
            if( c.XC_OthersCounter__c == null ){
                c.XC_OthersCounter__c = 0;
            }
            
            c.XC_OthersCounter__c = c.XC_OthersCounter__c + 1;
        }
        return c;
    }


    /**
    * @description finish method
    * @param bc - BatchableContext 
    */
    public void finish(Database.batchablecontext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC021_IncreaseCaseCounter');
    }

    public static XC_BatchErrorLog__c createBatchError(XC_UTIL_Sobject.WrapperResult wr, String name, String operation) {

        XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
        bel.Name = name;
        bel.XC_ErrorMessage__c = wr.errorMessage;
        bel.XC_TypeOfOperation__c = operation;
        bel.XC_RecordId__c = wr.errorObjectId;

        return bel;
    }

}
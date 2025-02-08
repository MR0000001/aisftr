/**
 * The Class XC_UTIL_InsertNewLead.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 14/05/2019
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_InsertNewLead – Util on insert new Leads
 */
public without sharing class XC_UTIL_InsertNewLead {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC002_NewLead');

    /**
     * @description Check for RollBack
     * @param newLead - Lead
     * @param beforeInsertSavepoint - Savepoint  
     * @return RollBackWrapper
     */
    public static XC_LCC002_NewLead_W.RollBackWrapper checkForInsertRollBack(Lead newLead, System.Savepoint beforeInsertSavepoint) {
        XC_LCC002_NewLead_W.RollBackWrapper rollBackWrapper = new XC_LCC002_NewLead_W.RollBackWrapper();
        XC_UTIL_Sobject.WrapperResult wrapResult = XC_UTIL_Sobject.insertRecord(newLead);
        if(!wrapResult.success){
            rollBackWrapper.isRollBack = true;
            rollBackWrapper.resultWrapper = doRollback(wrapResult, beforeInsertSavepoint); 
            return rollBackWrapper;
        }
        /*if(XC_UTIL_Lead.isResidential(newLead.recordTypeId)){ 
            XC_UTIL_Sobject.WrapperResult docDmlResult = XC_LCC002_NewLead_U.insertDocuments(newLead);
            if(!docDmlResult.success){
                rollBackWrapper.isRollBack = true;
                rollBackWrapper.resultWrapper = doRollback(docDmlResult, beforeInsertSavepoint); 
                return rollBackWrapper;
            }
        }*/
        return rollBackWrapper;
    }

    /**
     * @description populate InsertResultWrapper from WrapperResult
     * @param dmlResult the dml operation result
     * @param beforeInsertSavepoint
     * @return the insert result wrapper
     */
    public static XC_LCC002_NewLead_W.InsertResultWrapper doRollback(XC_UTIL_Sobject.WrapperResult dmlResult, System.Savepoint beforeInsertSavepoint){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@LEAD creation Rollback@@@');
        Database.rollback(beforeInsertSavepoint);
        return new XC_LCC002_NewLead_W.InsertResultWrapper(dmlResult.errorMessage, dmlResult.errorfieldName);
    }

    /**
     * @description Create the Address for Lead in input
     * @param newLead the lead obj
     * @return the XC_UTIL_Sobject.WrapperResult result
     */
    public static XC_UTIL_Sobject.WrapperResult createLeadAddress(Lead newLead){
        XC_UTIL_Sobject.WrapperResult addressResult = new XC_UTIL_Sobject.WrapperResult();
        addressResult.success = true;
        List<Lead> newLeadAllFields = XC_UTIL_Sobject.selectAllFields(newLead.Id);
        if(!String.isBlank(newLead.XC_Address__c) && !String.isBlank(newLead.XC_Country__c) && newLead.XC_Country__c != null){
            addressResult = XC_LCC002_NewLead_U.insertAddress(newLeadAllFields[0]);
        }
        return addressResult;
    }

    /**
     * @description Set the result error wrapper.
     * @param recordId the source Lead id
     * @return the List<XC_LegalEntityConsent__c> of LeadId in input
     */
    public static List<XC_LegalEntityConsent__c> retrieveLegalEntityConsents(String recordId){
        String indId = XC_UTIL_Sobject.getFieldValue('Lead', 'IndividualId', recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'retrieveLegalEntityConsents - IndividualId = '+indId);
        
        String query = XC_UTIL_SObject.selectAllFieldsGetSelect('XC_LegalEntityConsent__c');
        query += ' FROM XC_LegalEntityConsent__c WHERE XC_Individual__c =: indId';
        
        List<XC_LegalEntityConsent__c> leList = Database.query(query);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'leList = '+leList);
        return leList;
    }

    /**
     * DEPRECATED : NOW IN BEFORE INSERT
     * @description Call Lead assigment
     * @param newLead the new Lead
     * @param executeAssignment the execute assignment flag
     */
    /*public static void processLeadAssignment(Lead newLead, Boolean executeAssignment){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'assignLead->' + executeAssignment);
        if(executeAssignment){
            List<XC_LegalEntityConsent__c> leConsents = XC_UTIL_InsertNewLead.retrieveLegalEntityConsents(newLead.Id);
            Map<String,List<XC_LegalEntityConsent__c>> leData = new Map<String,List<XC_LegalEntityConsent__c>>();
            leData.put(String.valueOf(newLead.Id),leConsents);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'CALL assignLead -> leConsents:' + leConsents);
            //XC_UTIL_LeadAssignment.assignLead(new List<Lead>{newLead}, leData); //leData <<< TODO >>> Aggiungere secondo parametro
        }
    }*/
}
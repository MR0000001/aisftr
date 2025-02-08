/**
 * The Class XC_LCC051_CloneLead.
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation dd/mm/yyyy
 * @date Modification dd/mm/yyyy
 * @description ClassName – Describe the functionality
 */
public without sharing class XC_LCC051_CloneLead {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC002_NewLead');

    /**
     * @description Clone new lead.
     *
     * @param recordId the record id
     * @param productCategoryOfInterest the product category of interest
     * @param executeAssignment the execute assignment
     * @return the XC UTIL result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper cloneNewLead(String recordId, String productCategoryOfInterest, Boolean executeAssignment){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '######### INIT cloneNewLead from -> ' + recordId+' - New ProductCategoryOfInterest='+productCategoryOfInterest);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '######### executeAssignment= ' + executeAssignment);
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();

        Lead leadClone = getCloneLead(recordId, productCategoryOfInterest);
        XC_LCC002_NewLead_W.RollBackWrapper rollBackWrapper = XC_UTIL_InsertNewLead.checkForInsertRollBack(leadClone, beforeInsertSavepoint);
        if(rollBackWrapper.isRollBack) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Clone Lead Error -> ' + rollBackWrapper.resultWrapper);
            return checkAndSetInsertErrorWrapper(rollBackWrapper);
            //return rollBackWrapper.resultWrapper;
        } 
        //XC_UTIL_Sobject.WrapperResult sobjectResult = XC_UTIL_Sobject.insertRecord(leadClone);

        XC_UTIL_Sobject.WrapperResult addressWR = XC_UTIL_InsertNewLead.createLeadAddress(leadClone);
        if(!addressWR.success){
            return  new XC_UTIL_ResultWrapper(XC_UTIL_InsertNewLead.doRollback(addressWR, beforeInsertSavepoint));
        }
        if(addressWR.recordId!=null && String.isNotBlank(addressWR.recordId)){
            leadClone.XC_LeadAddress__c = addressWR.recordId;
        }

        XC_UTIL_ResultWrapper cloneResult = cloneLegalEntityConsents(leadClone, recordId, beforeInsertSavepoint);
        if(!cloneResult.success){
            return cloneResult;
        }

        // XC_UTIL_InsertNewLead.processLeadAssignment(leadClone, executeAssignment); Deprecated : Now in before insert

        XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(leadClone);
        if(!updateResult.success){
            return new XC_UTIL_ResultWrapper(XC_UTIL_InsertNewLead.doRollback(updateResult, beforeInsertSavepoint));
        }

        return new XC_UTIL_ResultWrapper(true);
    }

    /**
     * @description Returns a new obj lead cloned from input lead recordId.
     *
     * @param recordId the record id
     * @param productCategoryOfInterest the product category of interest
     * @return the cloned new Lead to insert
     */
    private static Lead getCloneLead(String recordId, String productCategoryOfInterest){
        List<Lead> leads = XC_UTIL_Sobject.selectAllFields(recordId);
        Lead leadClone = leads[0].clone(false,false,false,false);
        leadClone.XC_DuplicateNotConvertedFlag__c  = '';
        leadClone.XC_ProductCategoryOfInterest__c = productCategoryOfInterest;
        leadClone.Status = Label.XC_CL_Lead_Assigned;
        return leadClone;
    }

    /**
     * @description Set the result error wrapper.
     * @param leadClone the new Lead clone
     * @param recordId the source Lead id
     * @param beforeInsertSavepoint point to rollback if needs
     * @return the XC UTIL result wrapper
     */
    private static XC_UTIL_ResultWrapper cloneLegalEntityConsents(Lead leadClone, String recordId, System.Savepoint beforeInsertSavepoint){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ cloneLegalEntityConsents');
        List<XC_LegalEntityConsent__c> consentsToClone = XC_UTIL_InsertNewLead.retrieveLegalEntityConsents(recordId);
        if(consentsToClone.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'No Legal Entity Consents to clone');
            new XC_UTIL_ResultWrapper(true);
        }
        
        String indiId = XC_UTIL_Sobject.getFieldValue('Lead', 'IndividualId', leadClone.Id);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ leadClone.IndividualId = '+indiId);
        List<XC_LegalEntityConsent__c> newLEconsents = new List<XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c le : consentsToClone){
            XC_LegalEntityConsent__c leClone = le.clone(false,false,false,false);
            leClone.XC_Individual__c = indiId;
            newLEconsents.add(leClone);
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ newLEconsents to create = '+newLEconsents);
        List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_DML.insertRecords(newLEconsents);
        XC_UTIL_Sobject.WrapperResult leDmlResult = XC_UTIL_Sobject.getGlobalDMLResults(dmlResult);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ insertLegalEntityConsents - leDmlResult = '+ leDmlResult);
        if (!leDmlResult.success){
            return new XC_UTIL_ResultWrapper(XC_UTIL_InsertNewLead.doRollback(leDmlResult, beforeInsertSavepoint));
        }
        
        return new XC_UTIL_ResultWrapper(true);
    }
    
    /**
     * @description Set the result error wrapper.
     * @param rollBackWrapper the rollBack Wrapper result
     * @return the XC UTIL result wrapper
     */
    private static XC_UTIL_ResultWrapper checkAndSetInsertErrorWrapper(XC_LCC002_NewLead_W.RollBackWrapper rollBackWrapper){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Clone Lead > Insert Error -> ' + rollBackWrapper.resultWrapper);
        XC_LCC002_NewLead_W.InsertResultWrapper insertRW = rollBackWrapper.resultWrapper;
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper(insertRW);
        if(rw.resultMessage.startsWith('DUPLICATES_DETECTED')){
            rw.resultMessage = Label.XC_ErrorOnCloneLead;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkAndSetInsertErrorWrapper output ='+rw);
        return rw;
    }
    
    /**
     * @description Checks if is system admin.
     *
     * @return the boolean
     */
    @AuraEnabled
    public static Boolean isSystemAdmin(){
        return XC_UTIL_Environment.isSystemAdmin();
    }
    
}
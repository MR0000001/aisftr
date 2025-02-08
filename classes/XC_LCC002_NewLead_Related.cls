/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 28/06/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC002_NewLead_Related – Class that manage related Objects for XC_LCC002_NewLead
*/
public without sharing class XC_LCC002_NewLead_Related {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC002_NewLead');

    /**
     * @description Insert the Social Persona association and record. 
     * @param newLead the new lead
     * @param inputData  
     * @param beforeInsertSavepoint
     * @return the insert result wrapper
     */
    public static XC_LCC002_NewLead_W.InsertResultWrapper saveSocialPersonaAndConsents(Lead newLead, XC_LCC002_NewLead_W.LeadInputDataWrapper inputData, System.Savepoint beforeInsertSavepoint){
        XC_UTIL_Sobject.WrapperResult spDmlResult =  XC_LCC002_NewLead_U.associateSocialPersonaWithLead(newLead.Id, newLead.XC_SocialPersonaId__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@Social_Persona_DmlResult@@@' + spDmlResult);
        if (!spDmlResult.success){
            return doRollback(spDmlResult, beforeInsertSavepoint);
        }

        /*XC_UTIL_Sobject.WrapperResult indiDmlResult =  XC_LCC002_NewLead_U.saveConsentsOnIndividual(newLead.IndividualId, inputData.thirdPartiesCheck);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@Individual_DmlResult@@@' + indiDmlResult);
        if (!indiDmlResult.success){
            return doRollback(indiDmlResult, beforeInsertSavepoint);
        }*/

        XC_UTIL_Sobject.WrapperResult leDmlResult =  XC_LCC002_NewLead_U.insertLegalEntityConsents(newLead.IndividualId, inputData.consentsLE, newLead);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@leDmlResult@@@' + leDmlResult);
        if (!leDmlResult.success){
            return doRollback(leDmlResult, beforeInsertSavepoint);
        }

        XC_UTIL_Sobject.WrapperResult indiResult = updateIndividual(newLead.IndividualId, inputData);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@indiResult@@@' + indiResult);
        if (!indiResult.success){
            return doRollback(indiResult, beforeInsertSavepoint);
        }

        return new XC_LCC002_NewLead_W.InsertResultWrapper(newLead.Id);
    }
    
    /** 
    * @description Insert legal entity consents
    * @param individualId individual Id
    * @param inputData obj
    * @return XC_UTIL_Sobject.WrapperResult
    */
    @TestVisible
    private static XC_UTIL_Sobject.WrapperResult updateIndividual(Id individualId, XC_LCC002_NewLead_W.LeadInputDataWrapper inputData){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ NewLead > updateIndividual -> IndividualId = '+ individualId);
        Individual indiToUpd = new Individual();
        indiToUpd.Id = individualId;
        indiToUpd.XC_GiveDataToThirdParties__c = inputData.thirdPartiesCheckNew;
        indiToUpd.XC_RobinsonCustomer__c = inputData.robinsonCustomer;
        indiToUpd.XC_ThirdPartyConsentVersion__c = inputData.thirdPartiesVersion;
        
        List<XC_UTIL_Sobject.WrapperResult> indiResult = XC_UTIL_DML.updateRecords(new List<Individual> {indiToUpd});
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ indiResult = '+ indiResult);
        return indiResult[0];
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

}
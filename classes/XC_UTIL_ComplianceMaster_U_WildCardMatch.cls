/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ComplianceMaster_U_WildCardMatch ---- Util class for XC_UTIL_ComplianceMaster for Wild Card Match
*/

public class XC_UTIL_ComplianceMaster_U_WildCardMatch {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ComplianceMaster_U_WildCardMatch');

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description checkComplianceMasterWildCardMatch() --- This method matches all the field of the Wrapper with all the fields of a XC_ComplianceMaster__c or with the wildcard '*' for certain fields
    * @param wrapperCheck - ComplianceWrapperCheck
    **/ 
    public static void checkComplianceMasterWildCardMatch(XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck) {
        XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr = new XC_UTIL_ComplianceMaster.ComplianceWrapperResult();
        XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper = wrapperCheck.mapConfItemIdWrapper.get(wrapperCheck.confItem.Id);            
        if(!wrapperCheck.listCompliances.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ComplianceWrapper ----->' + wrapper);
            populateComplianceMasterWildCardMatch(cwr, wrapper, wrapperCheck);
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '##@@##@@@##@@## NOT FOUND 2');
            wrapperCheck.mapConfItemTemplateName.put(wrapperCheck.confItem.Id, cwr);                
        } 
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Populate with WildCard 
    * @param cwr - ComplianceWrapperResult
    * @param wrapper - ComplianceWrapper
    * @param wrapperCheck - ComplianceWrapperCheck
    **/
    private static void populateComplianceMasterWildCardMatch(XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck) {
       XC_UTIL_ComplianceMaster_WildCardMatch_V.populateComplianceMasterWildCardMatch(cwr, wrapper, wrapperCheck);
    }


    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check with WildCard for C1
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/
    public static void checkComplianceMasterWildCardMatchC1C5(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        if( XC_UTIL_ComplianceMaster_U_CheckField.checkFieldComplianceType(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldProductCategory(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldCountry(populateWrapper) 
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldSalesPartner(populateWrapper)
            && checkOriginAndReceivingChannel(populateWrapper)
            && populateWrapper.wrapper.probabilityChecked
            // && TBD - All scenarios WITH new fields: Audit/Probability  
        ){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Match With Wild or null ---> OK');
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.mandatory = populateWrapper.complianceMaster.XC_Mandatory__c;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C1;
            populateWrapper.cwr.complianceMaster =  populateWrapper.complianceMaster;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.jump = true;
        }
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check with WildCard for C2
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/
    public static void checkComplianceMasterWildCardMatchC2(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkComplianceMasterWildCardMatchC2  populateWrapper---> ' + populateWrapper);
        if( XC_UTIL_ComplianceMaster_U_CheckField.checkFieldComplianceType(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldProductCategory(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldCountry(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldSalesPartner(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldPaymentMethod(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldBillingModel(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkExtracost(populateWrapper)
            && checkOriginAndReceivingChannel(populateWrapper)
            && populateWrapper.wrapper.probabilityChecked
        ){
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.mandatory = populateWrapper.complianceMaster.XC_Mandatory__c;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C2;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.cwr.complianceMaster =  populateWrapper.complianceMaster;
            populateWrapper.jump = true;
        }
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check with WildCard for C3
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/
    public static void checkComplianceMasterWildCardMatchC3(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        if( 
            XC_UTIL_ComplianceMaster_U_CheckField.checkFieldComplianceType(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldProductCategory(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldCountry(populateWrapper) 
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldPaymentMethod(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldBillingModel(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldInstallerPartner(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkExtracost(populateWrapper)
            && checkOriginAndReceivingChannel(populateWrapper)
            && populateWrapper.wrapper.probabilityChecked
            // && TBD - All scenarios WITH new fields: Audit/Energy/Probability
        ){
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.mandatory = populateWrapper.complianceMaster.XC_Mandatory__c;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C3;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.cwr.complianceMaster =  populateWrapper.complianceMaster;
            populateWrapper.jump = true;                     
        }
    }

    /** 
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description Check with WildCard for C4
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/ 
    public static void checkComplianceMasterWildCardMatchC4(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkComplianceMasterWildCardMatchC4  populateWrapper---> ' + populateWrapper);
        if( XC_UTIL_ComplianceMaster_U_CheckField.checkFieldComplianceType(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldProductCategory(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldCountry(populateWrapper)
            && checkOriginAndReceivingChannel(populateWrapper)
            && populateWrapper.wrapper.probabilityChecked
        ){
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C4;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.jump = true;
        }
    }

    private static Boolean checkOriginAndReceivingChannel(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper){
        if(XC_UTIL_ComplianceMaster_U_CheckField.checkFieldOrigin(populateWrapper)
            && XC_UTIL_ComplianceMaster_U_CheckField.checkFieldReceivingChannel(populateWrapper)){
            return true;
        }
        return false;
    }
}
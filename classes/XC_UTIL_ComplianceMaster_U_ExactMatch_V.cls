/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com - Anna Maria Rosanova - annamaria.rosanova@nttdata.com
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ComplianceMaster_U_ExactMatch_V ---- Util class for XC_UTIL_ComplianceMaster for Exact Match
*/

public class XC_UTIL_ComplianceMaster_U_ExactMatch_V {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ComplianceMaster_U_ExactMatch_V');
    /** 
    * @author Domenico Del Prete - domenico.delprete@nttdata.com - Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description 
    * @param cwr XC_UTIL_ComplianceMaster.ComplianceWrapperResult -
    * @param wrapperCheck XC_UTIL_ComplianceMaster.ComplianceWrapperCheck 
    * @param wrapper XC_UTIL_ComplianceMaster.ComplianceWrapper 
    */
    public static void populateComplianceResultWrapper(XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck, XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper) {
        Boolean found = false;
        for(XC_ComplianceMaster__c complianceMaster : wrapperCheck.listCompliances){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'complianceMaster ----->' + complianceMaster);
            XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper = new XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper();
            populateWrapper.cwr = cwr;
            populateWrapper.wrapper = wrapper;
            populateWrapper.wrapperCheck = wrapperCheck;
            populateWrapper.complianceMaster = complianceMaster;
            populateWrapper.wrapper.probabilityChecked = XC_UTIL_ComplianceMaster_U_ExactMatch.checkProbability(complianceMaster.XC_Probability__c);
            if(wrapperCheck.type == Label.XC_CL_Compliance_C1 || wrapperCheck.type == Label.XC_CL_Compliance_C5){
               populateComplianceResultWrapperC1C5(populateWrapper, cwr, wrapperCheck);
            }
            if(wrapperCheck.type == Label.XC_CL_Compliance_C2){
               populateComplianceResultWrapperC2(populateWrapper, cwr, wrapperCheck);
            }
            if(wrapperCheck.type == Label.XC_CL_Compliance_C3){
                populateComplianceResultWrapperC3(populateWrapper, cwr, wrapperCheck);
            }
            if(wrapperCheck.type == Label.XC_CL_Compliance_C4){
                populateComplianceResultWrapperC4(populateWrapper, cwr, wrapperCheck);
            }
            if(populateWrapper.jump) {
                break;
            }
            if(!found){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '##@@##@@@##@@## NOT FOUND');
                wrapperCheck.mapConfItemTemplateName.put(wrapperCheck.confItem.Id, cwr);  
            }                 
        }   
    }

    private static void populateComplianceResultWrapperC1C5(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck) {
        XC_UTIL_ComplianceMaster_U_ExactMatch.populateComplianceResultWrapperC1C5(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }
    private static void populateComplianceResultWrapperC2(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck) {
        XC_UTIL_ComplianceMaster_U_ExactMatch.populateComplianceResultWrapperC2(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }
    private static void populateComplianceResultWrapperC3(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck) {
        XC_UTIL_ComplianceMaster_U_ExactMatch.populateComplianceResultWrapperC3(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }
    private static void populateComplianceResultWrapperC4(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck) {
        XC_UTIL_ComplianceMaster_U_ExactMatch.populateComplianceResultWrapperC4(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }
}
/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ComplianceMaster_WildCardMatch_V ---- Util class for XC_UTIL_ComplianceMaster for Wild Card Match
*/ 
public without sharing class XC_UTIL_ComplianceMaster_WildCardMatch_V {  
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ComplianceMaster_WildCardMatch_V');

    /**
    * @description
    * @author Del Prete Domenico | 31/07/2019
    * @param cwr XC_UTIL_ComplianceMaster.ComplianceWrapperResult 
    * @param wrapper XC_UTIL_ComplianceMaster.ComplianceWrapper 
    * @param wrapperCheck XC_UTIL_ComplianceMaster.ComplianceWrapperCheck 
    */
    public static void populateComplianceMasterWildCardMatch(XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck){
        Boolean found = false; 
        for(XC_ComplianceMaster__c complianceMaster : wrapperCheck.listCompliances){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Compliance Master ---> ' + complianceMaster);
            XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper = new XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper();
            populateWrapper.cwr = cwr;
            populateWrapper.wrapper = wrapper;
            populateWrapper.wrapperCheck = wrapperCheck;
            populateWrapper.complianceMaster = complianceMaster;
            if(wrapperCheck.type == Label.XC_CL_Compliance_C1 || wrapperCheck.type == Label.XC_CL_Compliance_C5) {
                checkComplianceMasterWildCardMatchC1C5(populateWrapper, cwr, wrapperCheck);
            }
            if(wrapperCheck.type == Label.XC_CL_Compliance_C2){
                checkComplianceMasterWildCardMatchC2(populateWrapper, cwr, wrapperCheck);
            }
            if(wrapperCheck.type == Label.XC_CL_Compliance_C3){
                checkComplianceMasterWildCardMatchC3(populateWrapper, cwr, wrapperCheck);
            } 
            if(wrapperCheck.type == Label.XC_CL_Compliance_C4){
                checkComplianceMasterWildCardMatchC4(populateWrapper, cwr, wrapperCheck);
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

    private static void checkComplianceMasterWildCardMatchC1C5(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck){
        XC_UTIL_ComplianceMaster_U_WildCardMatch.checkComplianceMasterWildCardMatchC1C5(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }

    private static void checkComplianceMasterWildCardMatchC2(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck){
        XC_UTIL_ComplianceMaster_U_WildCardMatch.checkComplianceMasterWildCardMatchC2(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }

    private static void checkComplianceMasterWildCardMatchC3(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck){
        XC_UTIL_ComplianceMaster_U_WildCardMatch.checkComplianceMasterWildCardMatchC3(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }

    private static void checkComplianceMasterWildCardMatchC4(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper, XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck){
        XC_UTIL_ComplianceMaster_U_WildCardMatch.checkComplianceMasterWildCardMatchC4(populateWrapper);
        cwr = populateWrapper.cwr;
        wrapperCheck = populateWrapper.wrapperCheck;
    }
}
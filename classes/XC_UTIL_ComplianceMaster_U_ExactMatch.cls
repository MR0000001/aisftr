/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ComplianceMaster_U_ExactMatch ---- Util class for XC_UTIL_ComplianceMaster for Exact Match
*/

public class XC_UTIL_ComplianceMaster_U_ExactMatch {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ComplianceMaster_U_ExactMatch');
    
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description checkComplianceMaster() --- This method matches all the field of the Wrapper with all the fields of a XC_ComplianceMaster__c
    * @param wrapperCheck
    **/
    public static void checkComplianceMasterExactMatch(XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck) {
        XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr = new XC_UTIL_ComplianceMaster.ComplianceWrapperResult();
        XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper = wrapperCheck.mapConfItemIdWrapper.get(wrapperCheck.confItem.Id);            
        if(!wrapperCheck.listCompliances.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ComplianceWrapper ------>' + wrapper);
            populateComplianceResultWrapper(cwr, wrapperCheck, wrapper);
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '##@@##@@@ NOT FOUND 2');
            wrapperCheck.mapConfItemTemplateName.put(wrapperCheck.confItem.Id, cwr);                
        } 
    }


    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Method to populate result wrapper
    * @param cwr - ComplianceWrapperResult
    * @param wrapperCheck - ComplianceWrapperCheck
    * @param wrapper - ComplianceWrapper
    **/
    private static void populateComplianceResultWrapper(XC_UTIL_ComplianceMaster.ComplianceWrapperResult cwr, XC_UTIL_ComplianceMaster.ComplianceWrapperCheck wrapperCheck, XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper) {
        XC_UTIL_ComplianceMaster_U_ExactMatch_V.populateComplianceResultWrapper(cwr, wrapperCheck, wrapper);
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Method to populate Compliance Wrapper Result where type=C1
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/
    public static void populateComplianceResultWrapperC1C5(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '##@@##@@@##@@##populateWrapper -->' + populateWrapper);
        if( populateWrapper.wrapper.type == populateWrapper.complianceMaster.XC_ComplianceType__c
            && populateWrapper.wrapper.productCategory == populateWrapper.complianceMaster.XC_ProductCategory__c
            && populateWrapper.wrapper.country == populateWrapper.complianceMaster.XC_Country__c  
            && populateWrapper.wrapper.salesPartner == populateWrapper.complianceMaster.XC_SalesPartnerId__c 
            && originAndReceivingChannelCheck(populateWrapper)  
            && populateWrapper.wrapper.probabilityChecked
            // && populateWrapper.wrapper.audit == populateWrapper.complianceMaster.XC_Audit__c  
             
            ){
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.mandatory = populateWrapper.complianceMaster.XC_Mandatory__c;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C1;
            populateWrapper.cwr.complianceMaster =  populateWrapper.complianceMaster;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.jump = true;
        }
        else {
            populateWrapper.wrapperCheck.listConfItemNotChecked.add(populateWrapper.wrapperCheck.confItem);
        }
    }


    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Method to populate Compliance Wrapper Result where type=C2
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/
    public static void populateComplianceResultWrapperC2(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '##@@##@@@##@@##populateWrapper -->' + populateWrapper);
        if( populateWrapper.wrapper.type == populateWrapper.complianceMaster.XC_ComplianceType__c
            && populateWrapper.wrapper.productCategory == populateWrapper.complianceMaster.XC_ProductCategory__c
            && populateWrapper.wrapper.country == populateWrapper.complianceMaster.XC_Country__c    
            && populateWrapper.wrapper.salesPartner == populateWrapper.complianceMaster.XC_SalesPartnerId__c
            && populateWrapper.wrapper.paymentMethod == populateWrapper.complianceMaster.XC_PaymentMethod__c
            && populateWrapper.wrapper.billingModel == populateWrapper.complianceMaster.XC_BillingModel__c
            && populateWrapper.wrapper.extraCost > populateWrapper.complianceMaster.XC_ExtrasCost__c
            && originAndReceivingChannelCheck(populateWrapper)  
            && populateWrapper.wrapper.probabilityChecked
            // && populateWrapper.wrapper.audit == populateWrapper.complianceMaster.XC_Audit__c  
            // && populateWrapper.wrapper.energy == populateWrapper.complianceMaster.XC_Energy__c 
            // && populateWrapper.wrapper.signatureAgent = populateWrapper.complianceMaster.XC_SignaturePartner__c  
        ){
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.mandatory = populateWrapper.complianceMaster.XC_Mandatory__c;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C2;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.cwr.complianceMaster =  populateWrapper.complianceMaster;
            populateWrapper.jump = true;
        }
        else {
            populateWrapper.wrapperCheck.listConfItemNotChecked.add(populateWrapper.wrapperCheck.confItem);
        }
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 05/04/2019
    * @date Modification dd/mm/yyyy
    * @description Method to populate Compliance Wrapper Result where type=C3
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/
    public static void populateComplianceResultWrapperC3(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '##@@##@@@##@@##populateWrapper -->' + populateWrapper);
        if(populateWrapper.wrapper.type == populateWrapper.complianceMaster.XC_ComplianceType__c
            && populateWrapper.wrapper.productCategory == populateWrapper.complianceMaster.XC_ProductCategory__c
            && populateWrapper.wrapper.country == populateWrapper.complianceMaster.XC_Country__c  
            //&& populateWrapper.wrapper.salesPartner == populateWrapper.complianceMaster.XC_SalesPartnerId__c
            && populateWrapper.wrapper.paymentMethod == populateWrapper.complianceMaster.XC_PaymentMethod__c
            && populateWrapper.wrapper.billingModel == populateWrapper.complianceMaster.XC_BillingModel__c
            && populateWrapper.wrapper.installerPartner == populateWrapper.complianceMaster.XC_InstallerPartnerId__c
            && populateWrapper.wrapper.extraCost > populateWrapper.complianceMaster.XC_ExtrasCost__c
            && originAndReceivingChannelCheck(populateWrapper)              
            && populateWrapper.wrapper.probabilityChecked
            // && populateWrapper.wrapper.audit == populateWrapper.complianceMaster.XC_Audit__c  
            // && populateWrapper.wrapper.energy == populateWrapper.complianceMaster.XC_Energy__c
            // && populateWrapper.wrapper.probability = populateWrapper.complianceMaster.XC_Probability__c
            // && populateWrapper.wrapper.signatureAgent = populateWrapper.complianceMaster.XC_SignaturePartner__c   
        ){
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.mandatory = populateWrapper.complianceMaster.XC_Mandatory__c;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C3;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.cwr.complianceMaster =  populateWrapper.complianceMaster;
            populateWrapper.jump = true;                    
        }
        else {
            populateWrapper.wrapperCheck.listConfItemNotChecked.add(populateWrapper.wrapperCheck.confItem);
        }
    }

    /** 
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com 
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description Method to populate Compliance Wrapper Result where type=C4
    * @param populateWrapper - PopulateComplianceResultWrapper
    **/
    public static void populateComplianceResultWrapperC4(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '##@@##@@@##@@##populateWrapper -->' + populateWrapper);
        if( populateWrapper.wrapper.type == populateWrapper.complianceMaster.XC_ComplianceType__c
            && populateWrapper.wrapper.productCategory == populateWrapper.complianceMaster.XC_ProductCategory__c
            && populateWrapper.wrapper.country == populateWrapper.complianceMaster.XC_Country__c  
            && originAndReceivingChannelCheck(populateWrapper)            
            && populateWrapper.wrapper.probabilityChecked
        ){
            populateWrapper.cwr.check = true;
            populateWrapper.cwr.queue = populateWrapper.complianceMaster.XC_Queue__c;
            populateWrapper.cwr.complianceType = Label.XC_CL_Compliance_Reason_C4;
            populateWrapper.wrapperCheck.mapConfItemTemplateName.put(populateWrapper.wrapperCheck.confItem.Id, populateWrapper.cwr); 
            populateWrapper.cwr.complianceMaster =  populateWrapper.complianceMaster;
            populateWrapper.jump = true;
        }
        else {
            populateWrapper.wrapperCheck.listConfItemNotChecked.add(populateWrapper.wrapperCheck.confItem);
        }
    }

    private static Boolean originAndReceivingChannelCheck(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper){
        if(populateWrapper.wrapper.origin == populateWrapper.complianceMaster.XC_Source__c  
            && populateWrapper.wrapper.receivingChannel == populateWrapper.complianceMaster.XC_ReceivingChannel__c  ){
            return true;
        } 
        return false;
    }
    /**
    * @description checkProbability
    * @author Andrea Bravaccino | 29/7/2019
    * @param probability Decimal
    * @return Boolean
    */
    public static Boolean checkProbability(Decimal probability){
        Decimal randomNumber = Decimal.valueof((Math.random() * 100));
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@checkProbability: number ' + randomNumber);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@checkProbability: Boolean ' + (probability <= randomNumber && probability != 0.0) );
        return probability >= randomNumber && probability != 0.0;
    }
}
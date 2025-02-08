/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ComplianceMaster_U_CheckField --- Util class for XC_UTIL_ComplianceMaster for check field
*/

public without sharing class XC_UTIL_ComplianceMaster_U_CheckField {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ComplianceMaster_U_CheckField');

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for ComplianceType
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldComplianceType(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE TYPE->' + populateWrapper.wrapper.type);
        if( (populateWrapper.wrapper.type == populateWrapper.complianceMaster.XC_ComplianceType__c || populateWrapper.complianceMaster.XC_ComplianceType__c == '*')) {
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for ProductCategory
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldProductCategory(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE PRODUCT CATEGORY->' + populateWrapper.wrapper.productCategory);
        if( populateWrapper.wrapper.productCategory == populateWrapper.complianceMaster.XC_ProductCategory__c){
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for Country
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldCountry(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE COUNTRY->' + populateWrapper.wrapper.country);
        if( populateWrapper.wrapper.country == populateWrapper.complianceMaster.XC_Country__c ) {
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for Origin
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldOrigin(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE ORIGIN ->' + populateWrapper.wrapper.origin);
        if( populateWrapper.wrapper.origin == populateWrapper.complianceMaster.XC_Source__c || populateWrapper.complianceMaster.XC_Source__c == null) {
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for PaymentMethod
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldPaymentMethod(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE PAYMENT METHOD ->' + populateWrapper.wrapper.paymentMethod);
        if( populateWrapper.wrapper.paymentMethod == populateWrapper.complianceMaster.XC_PaymentMethod__c || populateWrapper.complianceMaster.XC_PaymentMethod__c == null ) {
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for BillingModel
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldBillingModel(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE BILLING MODEL ->' + populateWrapper.wrapper.billingModel);
        if( populateWrapper.wrapper.billingModel == populateWrapper.complianceMaster.XC_BillingModel__c || populateWrapper.complianceMaster.XC_BillingModel__c == null ) {
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for InstallerPartner
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldInstallerPartner(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE INSTALLER PARTNER ->' + populateWrapper.wrapper.installerPartner);
        if( populateWrapper.wrapper.installerPartner == populateWrapper.complianceMaster.XC_InstallerPartnerId__c || populateWrapper.complianceMaster.XC_InstallerPartnerId__c == null) {
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for SalesPartner
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldSalesPartner(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE SALES PARTNER ->' + populateWrapper.wrapper.salesPartner);
        if(populateWrapper.wrapper.salesPartner == populateWrapper.complianceMaster.XC_SalesPartnerId__c || populateWrapper.complianceMaster.XC_SalesPartnerId__c == null) {
            return true;                
        }
        return false;
    }

    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date Creation 18/04/2019
    * @date Modification dd/mm/yyyy
    * @description Check condition for Receiving Channel
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkFieldReceivingChannel(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE RECEIVING CHANNEL ->' + populateWrapper.wrapper.receivingChannel);
        if(populateWrapper.wrapper.receivingChannel == populateWrapper.complianceMaster.XC_ReceivingChannel__c || populateWrapper.complianceMaster.XC_ReceivingChannel__c == null) {
            return true;                
        }
        return false;
    }
    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to populate ComplianceWrapper
    * @param type
    * @param wrapper - ComplianceWrapper
    * @param orderItem - NE__OrderItem__c
    **/
    public static void populateComplianceWrapper(String type, XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper, NE__OrderItem__c orderItem) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE populateComplianceWrapper ->' + wrapper);
        if(checkCompliance(type)){
            wrapper.type = type;
            wrapper.country = orderItem.XC_CountryFormula__c;     
            wrapper.productCategory = orderItem.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c;
            wrapper.origin = orderItem.NE__OrderId__r.NE__OptyId__r.XC_Source__c;   
            wrapper.receivingChannel = orderItem.NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c;
            // wrapper.audit = ? TBD 
        }
        if(type == Label.XC_CL_Compliance_C2 || type == Label.XC_CL_Compliance_C3){
            populateComplianceWrapperC2C3(wrapper, orderItem);
        }
        if(type == Label.XC_CL_Compliance_C3){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTRA QUI UTIL_COMPLIANCEMASTER - case type C3');
            if(orderItem.Assets__r != null){
                for(Asset asset : orderItem.Assets__r){
                    wrapper.installerPartner = asset.XC_InstallationAssignedResource__r.XC_Account__c;
                } 
            }
            // wrapper.syncStockGlovia = ? TBD
        }
    }

    /**
    * @description Method for Populace Compliance Wrapper where type is C2 or C3 (for cyclomatic complexity warning)
    * @param wrapper - ComplianceWrapper
    * @param orderItem - NE__OrderItem__c
    **/
    public static void populateComplianceWrapperC2C3(XC_UTIL_ComplianceMaster.ComplianceWrapper wrapper, NE__OrderItem__c orderItem) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE payment method ->' + wrapper.paymentMethod);
        wrapper.paymentMethod = orderItem.XC_PaymentMethod__c;
        wrapper.billingModel = orderItem.XC_BillingModel__c;
        //wrapper.extraCost = extracost; DONE IN xc_util_compliance.createMapConfItemIdWrapper
        //wrapper.energy = ? TBD
        //wrapper.signatureAgent = ? TBD
    }

    private static Boolean checkCompliance(String type){
        return (type == Label.XC_CL_Compliance_C1 || type == Label.XC_CL_Compliance_C2 || type == Label.XC_CL_Compliance_C3 || type == Label.XC_CL_Compliance_C4 || type == Label.XC_CL_Compliance_C5);
    }

    /** 
    * @author Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 20/11/2019
    * @date Modification dd/mm/yyyy
    * @description Check extracost
    * @param populateWrapper - XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper
    * @return Boolean
    **/
    public static Boolean checkExtracost(XC_UTIL_ComplianceMaster.PopulateComplianceResultWrapper populateWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ COMPLIANCE SALES PARTNER ->' + populateWrapper.wrapper.salesPartner);
        if(populateWrapper.complianceMaster.XC_ExtrasCost__c == null || populateWrapper.wrapper.extraCost > populateWrapper.complianceMaster.XC_ExtrasCost__c || populateWrapper.complianceMaster.XC_ExtrasCost__c == 0) {
            return true;                
        }
        return false;
    }
}
/**
 * The Class XC_REST_Account_ZZ.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 09/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account
 * 
 */


public without sharing class XC_REST_Account_ZZ {

        /**
     * ValidateRequestBillingProfilesPOST.
     *
     * @param billingProfileList the billing profile list
     * @param addressList the address list
     * @param clientSystem the client System
     * @return the wrapper result
     * @description Method to verify if Billing Profile required parameters are correctly filled for POST callout
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestBillingProfilesPOST(List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList, List<XC_UTIL_Address.AddressWrapper> addressList, String clientSystem) {
            
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();
        Boolean checkNewAddress = false;

        Integer i = 1;
        for(XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr : billingProfileList) {
            wr = checkInsertBillingProfile(bpWr, i, clientSystem);
            if(wr.errorFlag) {
                return wr;
            }
            i++;
        }

        if(addressList != null){
            checkNewAddress = XC_REST_Account_Z.validateAddressForBillingProfile(addressList, clientSystem, wr);
            if(wr.errorFlag) {
                return wr;
            }
        }

        if(!checkNewAddress){
            wr.errorMessage = 'Address section is mandatory if new BillingProfile section is populated';
            wr.errorFlag = true;
        }

        return wr;
    }


    /**
     * ValidateRequestBillingProfilesPUT.
     *
     * @param inputsMap the inputs map
     * @param clientSystem the client System
     * @return the wrapper result
     * @description Method to verify if Billing Profile required parameters are correctly filled for PUT callout
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestBillingProfilesPUT(Map<String, Object> inputsMap, String clientSystem) {
            
        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();

        List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billingProfileList = (List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>) inputsMap.get('billingProfileList');
        List<XC_UTIL_Address.AddressWrapper> addressList = (List<XC_UTIL_Address.AddressWrapper>) inputsMap.get('addressList');
        List<XC_UTIL_Account.ContactIFWrapper> conList = (List<XC_UTIL_Account.ContactIFWrapper>) inputsMap.get('conList');
        
        Boolean checkNewBillingProfile = false;
        Boolean checkNewAddress = false;

        Integer i = 1;
        for(XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr : billingProfileList) {
            
            if(String.isBlank(bpWr.BillingProfileID)) {
                wr = checkInsertBillingProfile(bpWr, i, clientSystem);
                checkNewBillingProfile = true;
            } else {
                wr = checkUpdateBillingProfile(bpWr, i);
            }

            if(wr.errorFlag) {
                return wr;
            }
            i++;
        }

        /*if(conList != null){
            validateContactForBillingProfile(conList, checkNewBillingProfile, wr);
            if(wr.errorFlag) {
                return wr;
            }
        } else if (checkNewBillingProfile) {
            wr.errorMessage = 'Contact section is mandatory if new BillingProfile section is populated';
            wr.errorFlag = true;
            return wr;
        }

        if(addressList != null){
            checkNewAddress = XC_REST_Account_Z.validateAddressForBillingProfile(addressList, clientSystem, wr);
        }
        
        if(!checkNewAddress && checkNewBillingProfile){
            wr.errorMessage = 'Address section is mandatory if new BillingProfile section is populated';
            wr.errorFlag = true;
        }*/
        
        return wr;
    }


    /**
     * CheckInsertBillingProfile.
     *
     * @param bpWr the billing profile wrapper
     * @param i the counter
     * @param clientSystem the client System
     * @return the wrapper result
     * @description Method to verify if Billing Profile required parameters are correctly filled to insert it
     */
    public static XC_UTIL_Integration.WrapperResult checkInsertBillingProfile(XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr, Integer i, String clientSystem) {

        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();

        if (String.isBlank(bpWr.PaymentMethod)){
            wr.errorMessage = 'Missing mandatory field: BillingProfile.PaymentMethod in ' + i + '-th BillingProfile';
            wr.errorFlag = true;
            return wr;
        }

        if (String.isBlank(bpWr.InvoicePreferredLanguage)){
            wr.errorMessage = 'Missing mandatory field: BillingProfile.InvoicePreferredLanguage in ' + i + '-th BillingProfile';
            wr.errorFlag = true;
            return wr;
        }

        if (String.isBlank(bpWr.InvoiceDeliveryPref)){
            wr.errorMessage = 'Missing mandatory field: BillingProfile.InvoiceDeliveryPref in ' + i + '-th BillingProfile';
            wr.errorFlag = true;
            return wr;
        }   

        if((clientSystem == 'XRecharge' || clientSystem == 'XInstaller' || clientSystem == 'E-Commerce' || clientSystem == 'Partner') && String.isBlank(bpWr.LegalEntity)){
            wr.errorMessage = ' Missing mandatory field BillingProfile.LegalEntity in ' + i + '-th BillingProfile';
            wr.errorFlag = true;
            return wr;
        }

        if(bpWr.LegalEntity == Label.XC_CL_LegalEntity_Italy){ 

            if(String.isBlank(bpWr.CertifiedEmail) && String.isBlank(bpWr.RecipientCode)){
                wr.errorMessage = 'Missing mandatory field: BillingProfile.CertifiedEmail or  BillingProfile.RecipientCode in ' + i + '-th BillingProfile';
                wr.errorFlag = true;
                return wr;
            }

            if(bpWr.PaymentMethod == Label.XC_CL_Payment_CommodityBill && String.isBlank(bpWr.CommodityCupsID)){
                wr.errorMessage = 'Missing mandatory field: BillingProfile.CommodityCupsID in ' + i + '-th BillingProfile';
                wr.errorFlag = true;
                return wr;
            }
        
        }

        wr.errorMessage = '';
        wr.errorFlag = false;
        return wr;
    }


    /**
     * CheckUpdateBillingProfile.
     *
     * @param bpWr the billing profile wrapper
     * @param i the counter
     * @returnthe the wrapper result
     * @description Method to verify if Billing Profile required parameters are correctly filled to update it
     */
    public static XC_UTIL_Integration.WrapperResult checkUpdateBillingProfile(XC_UTIL_BillingProfile.BillingProfileIFWrapper bpWr, Integer i) {

        XC_UTIL_Integration.WrapperResult wr = new XC_UTIL_Integration.WrapperResult();

        if (bpWr.PaymentMethod != null && bpWr.PaymentMethod.isWhitespace()){
            wr.errorMessage = 'BillingProfile.PaymentMethod in ' + i + '-th BillingProfile cannot be empty';
            wr.errorFlag = true;
            return wr;
        }

        if (bpWr.InvoicePreferredLanguage != null && bpWr.InvoicePreferredLanguage.isWhitespace()){
            wr.errorMessage = 'BillingProfile.InvoicePreferredLanguage in ' + i + '-th BillingProfile cannot be empty';
            wr.errorFlag = true;
            return wr;
        }

        if (bpWr.InvoiceDeliveryPref != null && bpWr.InvoiceDeliveryPref.isWhitespace()){
            wr.errorMessage = 'BillingProfile.InvoiceDeliveryPref in ' + i + '-th BillingProfile cannot be empty';
            wr.errorFlag = true;
            return wr;
        }   

        wr.errorMessage = '';
        wr.errorFlag = false;
        return wr;
    }


    /**
     * ValidateContactForBillingProfile.
     *
     * @param conList the contact list
     * @param checkNewBillingProfile the boolean of check
     * @param wr the wrapper result
     * @description Method to validate contact for billing profile
     */
    public static void validateContactForBillingProfile(List<XC_UTIL_Account.ContactIFWrapper> conList, Boolean checkNewBillingProfile, XC_UTIL_Integration.WrapperResult wr) {

        Integer i = 1;
        for(XC_UTIL_Account.ContactIFWrapper conWr: conList){
            if(checkNewBillingProfile && (!conWr.ShippingContact || !conWr.BillingContact)) {
                wr.errorMessage = 'Contact.ShippingContact and Contact.BillingContact must be set to true in ' + i + '-th Contact';
                wr.errorFlag = true;
                return;
            }
            i++;
        }
    }

}
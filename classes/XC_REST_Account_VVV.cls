/**
 * The Class XC_REST_Account_VVV.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account
 * 
 */


public without sharing class XC_REST_Account_VVV {


        /**
         * ValidateRequestContactsPOST.
         *
         * @param inputsMap the inputs map
         * @return the wrapper result
         * @description Method to verify if Contact required parameters are correctly filled for POST callout
         */
        public static XC_UTIL_Integration.WrapperResult validateRequestContactsPOST(Map<String, Object> inputsMap) {
                
                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                List<XC_UTIL_Account.ContactIFWrapper> conList = (List<XC_UTIL_Account.ContactIFWrapper>) inputsMap.get('conList');
                List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> billigProfList = (List<XC_UTIL_BillingProfile.BillingProfileIFWrapper>) inputsMap.get('billigProfList');
                String type = (String) inputsMap.get('type');
                String clientSystem = (String) inputsMap.get('clientSystem');

                Boolean checkPrimaryContact = false;

                Integer i = 1;
                for(XC_UTIL_Account.ContactIFWrapper conWr : conList) {
                        
                        // For Commodity 
                        if(clientSystem == Label.XC_CL_CommoditySpainB2C && conWr.PrimaryContact != true){
                                continue; 
                        }
                                        
                        conWr.ShippingContact = (conWr.ShippingContact == null) ? false : conWr.ShippingContact;
                        conWr.BillingContact = (conWr.BillingContact == null) ? false : conWr.BillingContact;

                        if(String.isNotBlank(conWr.LastName)){
                                conWr.LastName = XC_UTIL_String.removeDiacritics(conWr.LastName);
                                conWr.LastName = conWr.LastName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
                                conWr.LastName = conWr.LastName.normalizeSpace();
                                if(conWr.LastName.length() == 1){
                                        conWr.LastName = conWr.LastName + conWr.LastName;
                                }
                        }
                        if(String.isNotBlank(conWr.FirstName)){
                                conWr.FirstName = XC_UTIL_String.removeDiacritics(conWr.FirstName);
                                conWr.FirstName = conWr.FirstName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
                                conWr.FirstName = conWr.FirstName.normalizeSpace();
                                if(conWr.FirstName.length() == 1){
                                        conWr.FirstName = conWr.FirstName + conWr.FirstName;
                                }
                        }

                        validateResult = checkInsertContact(conWr, type, clientSystem);
                        if(validateResult.errorFlag) {
                                String errorMessage = validateResult.errorMessage;
                                errorMessage = errorMessage.replace('+i+', String.valueOf(i));
                                validateResult.errorMessage = errorMessage;
                                return validateResult;
                        }

                        if(billigProfList != null && !billigProfList.isEmpty() && (!conWr.ShippingContact || !conWr.BillingContact)) {
                                validateResult.errorMessage = 'Contact.ShippingContact and Contact.BillingContact must be set to true in ' + i + '-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }

                        if(!checkPrimaryContact){
                                checkPrimaryContact = (conWr.PrimaryContact != null) ? conWr.PrimaryContact : false;
                        }
                        
                        i++;
                }

                if(!checkPrimaryContact) {
                        validateResult.errorMessage = Label.XC_CL_Contact_NotValid;
                        validateResult.errorFlag = true;
                        return validateResult;
                }

                return validateResult;
        }


        /**
         * ValidateRequestContactsPUT.
         *
         * @param conList the con list
         * @param type the account type
         * @param clientSystem the client System
         * @return the wrapper result
         * @description Method to verify if Contact required parameters are correctly filled for PUT callout
         *              It returns a map with WrappeResult(errorMessage, errorFlag) as key and ContactIFWrapper as value
         */
        public static XC_UTIL_Integration.WrapperResult validateRequestContactsPUT(List<XC_UTIL_Account.ContactIFWrapper> conList, String type, String clientSystem) {
                
                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
                  

                Integer i = 1;
                for(XC_UTIL_Account.ContactIFWrapper conWr : conList) {
                        conWr.ShippingContact = (conWr.ShippingContact == null) ? false : conWr.ShippingContact;
                        conWr.BillingContact = (conWr.BillingContact == null) ? false : conWr.BillingContact;

                        if(String.isNotBlank(conWr.LastName)){
                                conWr.LastName = XC_UTIL_String.removeDiacritics(conWr.LastName);
                                conWr.LastName = conWr.LastName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
                                conWr.LastName = conWr.LastName.normalizeSpace();
                                if(conWr.LastName.length() == 1){
                                        conWr.LastName = conWr.LastName + conWr.LastName;
                                }
                        }
                        if(String.isNotBlank(conWr.FirstName)){
                                conWr.FirstName = XC_UTIL_String.removeDiacritics(conWr.FirstName);
                                conWr.FirstName = conWr.FirstName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
                                conWr.FirstName = conWr.FirstName.normalizeSpace();
                                if(conWr.FirstName.length() == 1){
                                        conWr.FirstName = conWr.FirstName + conWr.FirstName;
                                }
                        }

                        if(String.isBlank(conWr.ContactID)) {
                                
                                if(clientSystem == 'CommoditySpainB2C' && (!conWr.ShippingContact || !conWr.BillingContact)){
                                        validateResult.errorMessage = 'Contact.ShippingContact and Contact.BillingContact must be set to true in ' + i + '-th Contact';
                                        validateResult.errorFlag = true;
                                        return validateResult;
                                }

                                validateResult = checkInsertContact(conWr, type, clientSystem);

                        } else {
                                validateResult = XC_REST_Account_VVVV.checkUpdateContact(conWr, type, clientSystem);
                        }   


                        if(validateResult.errorFlag) {
                                String errorMessage = validateResult.errorMessage;
                                errorMessage = errorMessage.replace('+i+', String.valueOf(i));
                                validateResult.errorMessage = errorMessage;
                                return validateResult;
                        }
                        i++;
                }

                return validateResult;
        }



        /**
         * CheckInsertContact.
         *
         * @param conWr the contact wrapper
         * @param type the account type
         * @param clientSystem the client system
         * @return the wrapper result
         * @description method to verify if Contact required parameters are correctly filled to insert it
         */
        public static XC_UTIL_Integration.WrapperResult checkInsertContact(XC_UTIL_Account.ContactIFWrapper conWr, String type, String clientSystem) {
                
                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                if(String.isBlank(conWr.LastName)) {
                        validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.LastName in +i+-th Contact';
                        validateResult.errorFlag = true;
                        return validateResult;
                }
                if(String.isBlank(conWr.FirstName)) {
                        validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.FirstName in +i+-th Contact';
                        validateResult.errorFlag = true;
                        return validateResult;
                }        
                
                if(type != 'Partner') {
                                
                        validateResult = checkInsertContactForNoPartner(conWr, clientSystem);
                        if(validateResult.errorFlag) {
                        return validateResult;
                }

                } else if(type == 'Partner' && String.isBlank(conWr.Role)){
                        validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.Role in +i+-th Contact';
                        validateResult.errorFlag = true;
                        return validateResult;
                }

                if((type == 'B2B' && !'CommodityItalyB2C'.equalsIgnoreCase(clientSystem) ) || type == 'B2G') {//ACERRA CR-NR2063 B2B 08.11.2021 add CommodityItalyB2C
                        if(String.isBlank(conWr.Salutation)){
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.Salutation in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }
                        if(String.isBlank(conWr.PreferenceLanguage)){
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.PreferenceLanguage in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }
                }

                validateResult = checkInsertContactDocument(conWr, clientSystem);
                if(validateResult.errorFlag) {
                        return validateResult;
                }
                
                validateResult = checkInsertContactGDPR(conWr);
                return validateResult;
        }
        /**
         * checkInsertContactDocument.
         *
         * @param conWr the contact wrapper
         * @param clientSystem the client system
         * @return the wrapper result
         * @description method to verify if Contact required parameters are correctly filled to insert it
         */
        public static XC_UTIL_Integration.WrapperResult checkInsertContactDocument(XC_UTIL_Account.ContactIFWrapper conWr, String clientSystem) {

                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                /*if(clientSystem != 'XRecharge') {
                        
                        if((String.isBlank(conWr.IdentityType) || String.isBlank(conWr.IdentityNumber))) {
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.IdentityType and Contact.IdentityNumber in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }
                        
                }*/

                if(clientSystem == Label.XC_CL_CommoditySpainB2C && conWr.IdentityType == 'NIE' && String.isBlank(conWr.ContactID)) {
                        conWr.ReleaseDate = (String.isBlank(conWr.ReleaseDate)) ? String.valueOf(Date.Today()) : conWr.ReleaseDate;
                        conWr.ExpiryDate = (String.isBlank(conWr.ExpiryDate)) ? String.valueOf(Date.Today().addYears(100)) : conWr.ExpiryDate;
                }
                
                return validateResult;
        }



        /**
         * CheckInsertContactForNoPartner.
         *
         * @param conWr the contact wrapper
         * @param clientSystem the client system
         * @return the wrapper result
         * @description method to verify if Contact required parameters are correctly filled to insert it
         */
        public static XC_UTIL_Integration.WrapperResult checkInsertContactForNoPartner(XC_UTIL_Account.ContactIFWrapper conWr, String clientSystem) {

                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                if(clientSystem == 'CommoditySpainB2C') {
                                               
                        if(String.isBlank(conWr.Email) && String.isBlank(conWr.MainPhone) && String.isBlank(conWr.ContactID)){
                                conWr.MainPhonePrefix = '+34';
                                conWr.MainPhone = '000000000';
                                /*validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.Email or Contact.MainPhone in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;*/
                        }
                        if(String.isBlank(conWr.MainPhonePrefix) && String.isNotBlank(conWr.MainPhone)) { 
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.MainPhonePrefix in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }
                }else if(!String.isBlank(clientSystem) && (clientSystem.equalsIgnoreCase('CommodityRomaniaB2C') || clientSystem.equalsIgnoreCase('CommodityItalyB2C') || clientSystem.equalsIgnoreCase('MKChile') || clientSystem.equalsIgnoreCase('MKColombia') || 'ThirdPartyB2C'.equalsIgnoreCase(clientSystem))){ //[2021-09-30 :: TP :: Third Party Billing :: Check Contact Email]

                        if(String.isBlank(conWr.Email) && String.isBlank(conWr.MainPhone) && String.isBlank(conWr.ContactID)){
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.Email or Contact.MainPhone in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }//[BEGIN ACERRA CR B2B 05.11.2021]
                        if(String.isBlank(conWr.Email) && 'B2B'.equalsIgnoreCase(conWr.Type)){
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.Email';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }
                        //[END ACERRA CR B2B 05.11.2021]

                } else if(String.isBlank(conWr.Email)){
                        validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.Email in +i+-th Contact';
                        validateResult.errorFlag = true;
                        return validateResult;
                }

                return validateResult;
        }


        /**
         * CheckInsertContactGDPR.
         *
         * @param conWr the contact wrapper
         * @return the wrapper result
         * @description method to verify if Contact required parameters, in particular GDPR, are correctly filled to insert it
         */
        public static XC_UTIL_Integration.WrapperResult checkInsertContactGDPR(XC_UTIL_Account.ContactIFWrapper conWr) {

                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                if(conWr.GDPR == null) {
                        validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.GDPR in +i+-th Contact';
                        validateResult.errorFlag = true;
                        return validateResult;
                }
                if(conWr.GDPR.LegalEntity == null || conWr.GDPR.LegalEntity.size() == 0) {
                        validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.GDPR.LegalEntity in +i+-th Contact';
                        validateResult.errorFlag = true;
                        return  validateResult;
                }

                for (XC_UTIL_Account.LegalEntityWrapper conGDPRWr : conWr.GDPR.LegalEntity){
                        if(String.isBlank(conGDPRWr.LegalEntity)) {
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.GDPR.LegalEntity.LegalEntity in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        }
                        if(String.isBlank(conGDPRWr.GiveDataToLegalEntity)) {
                                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact.GDPR.LegalEntity.GiveDataToLegalEntity in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        } 
                        if(conGDPRWr.GiveDataToLegalEntity != 'Y') {
                                validateResult.errorMessage = 'Contact.GDPR.LegalEntity.GiveDataToLegalEntity must be Y in +i+-th Contact';
                                validateResult.errorFlag = true;
                                return validateResult;
                        } 
                }

                validateResult.errorFlag = false;
                validateResult.errorMessage = '';
                return validateResult;
        }

}
/**
 * The Class XC_REST_Account_VVVV.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account
 * 
 */


public without sharing class XC_REST_Account_VVVV {


        /**
         * CheckUpdateContact.
         *
         * @param conWr the con wr
         * @param type the account type
         * @param clientSystem the client system
         * @return the wrapper result
         * @description Method to verify if Contact required parameters are correctly filled to update it
         */
        public static XC_UTIL_Integration.WrapperResult checkUpdateContact(XC_UTIL_Account.ContactIFWrapper conWr, String type, String clientSystem) {

                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                Map<String, String> requiredParameters = new Map<String, String>{'LastName' => conWr.LastName, 
                                                                                'FirstName' => conWr.FirstName
                                                                                };
                for(String key : requiredParameters.keySet()){
                        if(requiredParameters.get(key) != null && requiredParameters.get(key).isWhitespace()) {
                                validateResult.errorMessage = 'Contact.' + key + ' in +i+-th Contact '+Label.XC_CL_CanNotEmpty;
                                validateResult.errorFlag = true;
                                return validateResult;
                        }
                }

                if(type != 'Partner') {

                        validateResult = checkUpdateContactForNoPartner(conWr, clientSystem);
                        if(validateResult.errorFlag) {
                                return validateResult;
                        }

                } else if(type == 'Partner' && conWr.Role != null && conWr.Role.isWhitespace()){
                        validateResult.errorMessage = 'Contact.Role in +i+-th Contact '+Label.XC_CL_CanNotEmpty;
                        validateResult.errorFlag = true;
                        return validateResult;
                }

                validateResult = checkUpdateContactGDPR(conWr);
                return validateResult;
        }


        /**
         * CheckUpdateContactForNoPartner.
         *
         * @param conWr the contact wrapper
         * @param clientSystem the client system
         * @return the wrapper result
         * @description method to verify if Contact required parameters are correctly filled to update it
         */
        public static XC_UTIL_Integration.WrapperResult checkUpdateContactForNoPartner(XC_UTIL_Account.ContactIFWrapper conWr, String clientSystem) {

                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                if(clientSystem == 'CommoditySpainB2C') {

                        validateResult = checkUpdateContactForNoPartnerCommodity(conWr);
                        if(validateResult.errorFlag) {
                                return validateResult;
                        }
                        
                } else if(conWr.Email != null && conWr.Email.isWhitespace()){
                        validateResult.errorMessage = 'Contact.Email in +i+-th Contact '+Label.XC_CL_CanNotEmpty;
                        validateResult.errorFlag = true;
                        return validateResult;
                }

                return validateResult;
        }


        /**
         * CheckUpdateContactForNoPartnerCommodity.
         *
         * @param conWr the contact wrapper
         * @return the wrapper result
         * @description method to verify if Contact required parameters are correctly filled to update it
         */
        public static XC_UTIL_Integration.WrapperResult checkUpdateContactForNoPartnerCommodity(XC_UTIL_Account.ContactIFWrapper conWr) {

                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

                if(conWr.Email != null && conWr.Email.isWhitespace() &&  conWr.MainPhone != null && conWr.MainPhone.isWhitespace()){
                        validateResult.errorMessage = 'Contact.Email or Contact.MainPhone in +i+-th Contact '+Label.XC_CL_CanNotEmpty;
                        validateResult.errorFlag = true;
                        return validateResult;
                }
                if(conWr.MainPhonePrefix != null && conWr.MainPhonePrefix.isWhitespace() && String.isNotBlank(conWr.MainPhone)) {
                        validateResult.errorMessage = 'Contact.MainPhonePrefix in +i+-th Contact '+Label.XC_CL_CanNotEmpty;
                        validateResult.errorFlag = true;
                        return validateResult;
                }

                return validateResult;
        }


        /**
         * CheckUpdateContactGDPR.
         *
         * @param conWr the contact wrapper
         * @return the wrapper result
         * @description method to verify if Contact required parameters, in particular GDPR, are correctly filled to update it
         */
        public static XC_UTIL_Integration.WrapperResult checkUpdateContactGDPR(XC_UTIL_Account.ContactIFWrapper conWr) {

                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        
                if(conWr.GDPR != null && conWr.GDPR.LegalEntity != null && conWr.GDPR.LegalEntity.size() > 0) {
                        for (XC_UTIL_Account.LegalEntityWrapper conGDPRWr : conWr.GDPR.LegalEntity){
                                if(conGDPRWr.LegalEntity != null && conGDPRWr.LegalEntity.isWhitespace()) {
                                        validateResult.errorMessage = 'Contact.GDPR.LegalEntity.LegalEntity in +i+-th Contact '+Label.XC_CL_CanNotEmpty;
                                        validateResult.errorFlag = true;
                                        return validateResult;
                                }
                                if(conGDPRWr.GiveDataToLegalEntity != null && conGDPRWr.GiveDataToLegalEntity.isWhitespace()) {
                                        validateResult.errorMessage = 'Contact.GDPR.LegalEntity.GiveDataToLegalEntity in +i+-th Contact cannot be empty';
                                        validateResult.errorFlag = true;
                                        return validateResult;
                                } 
                                if(conGDPRWr.GiveDataToLegalEntity != null && conGDPRWr.GiveDataToLegalEntity != 'Y') {
                                        validateResult.errorMessage = 'Contact.GDPR.LegalEntity.GiveDataToLegalEntity must be Y in +i+-th Contact';
                                        validateResult.errorFlag = true;
                                        return validateResult;
                                } 
                        }
                }

                validateResult.errorFlag = false;
                validateResult.errorMessage = '';
                return validateResult;
        }


        /**
         * ValidateRequestAddressesPOST.
         *
         * @param addressList the address list
         * @param type the account type
         * @param clientSystem the header map
         * @return the wrapper result
         * @description method to verify if Address required parameters are correctly filled for POST callout
         */
        public static XC_UTIL_Integration.WrapperResult validateRequestAddressesPOST(List<XC_UTIL_Address.AddressWrapper> addressList, String type, String clientSystem) {
                
                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
                
                Integer i = 1;
                for(XC_UTIL_Address.AddressWrapper addWr : addressList) {

                        //For Commodity
                        if(clientSystem == Label.XC_CL_CommoditySpainB2C && addWr.AddressValidated != true){
                                continue; 
                        }

                        validateResult = XC_REST_Account_Z.checkInsertAddress(addWr, type, clientSystem);
                        if(validateResult.errorFlag) {
                                String errorMessage = validateResult.errorMessage;
                                errorMessage = errorMessage.replace('+i+', String.valueOf(i));
                                validateResult.errorMessage = errorMessage;
                                return validateResult;
                        }
                }
                
                return validateResult;
        }


        /**
         * ValidateRequestAddressesPUT.
         *
         * @param addressList the address list
         * @param type the account type
         * @param clientSystem the client System
         * @return the wrapper result
         * @description method to verify if Address required parameters are correctly filled for PUT callout
         */
        public static XC_UTIL_Integration.WrapperResult validateRequestAddressesPUT(List<XC_UTIL_Address.AddressWrapper> addressList, String type, String clientSystem) {
                
                XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
                
                Integer i = 1;
                for(XC_UTIL_Address.AddressWrapper addWr : addressList) {
                        if(String.isBlank(addWr.AddressID)){
                                validateResult = XC_REST_Account_Z.checkInsertAddress(addWr, type, clientSystem);
                        } else {
                                validateResult = XC_REST_Account_Z.checkUpdateAddress(addWr, type);
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

}
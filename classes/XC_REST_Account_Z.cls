/**
 * The Class XC_REST_Account_Z.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 09/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account
 * 
 */


public without sharing class XC_REST_Account_Z {

    
    /**
     * CheckInsertAddress.
     *
     * @param addWr the add wr
     * @param type the account type
     * @param clientSystem the client System
     * @return the wrapper result
     * @description Method to verify if Address required parameters are correctly filled to insert it
     */
    public static XC_UTIL_Integration.WrapperResult checkInsertAddress(XC_UTIL_Address.AddressWrapper addWr, String type, String clientSystem) {
            
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        Map<String, String> requiredParameters = new Map<String, String>{'StreetType' => addWr.StreetType,
                                                                        'Address' => addWr.Address,
                                                                        'StreetNumber' => addWr.StreetNumber, 
                                                                        'ZipCode' => addWr.ZipCode,
                                                                        'City' => addWr.City,
                                                                        'Country' => addWr.Country
                                                                        };
        for(String key : requiredParameters.keySet()){
            if((key == 'StreetType' || key == 'StreetNumber') && clientSystem == Label.XC_CL_CommoditySpainB2C){
                continue; // for Commodity 
            } else if(String.isBlank(requiredParameters.get(key))) {
                validateResult.errorMessage = 'Missing mandatory field: Address.' + key + ' in +i+-th Address';
                validateResult.errorFlag = true;
                return validateResult;
            }
        }

        if(clientSystem == 'CommoditySpainB2C' && (addWr.DeliveryAddress == null || addWr.BillingAddress == null)) {
            validateResult.errorMessage = 'Missing mandatory field: Address.ShippingAddress, Address.BillingAddress in +i+-th Address';
            validateResult.errorFlag = true;
            return validateResult;
        }

        // POS
        if(addWr.PointOfService != null && !addWr.PointOfService.isEmpty()){
            checkPOS(addWr.PointOfService, validateResult);
            if(validateResult.errorFlag) {
                return validateResult;
            }
        } else if(type == 'B2B' || type == 'B2G'){
            validateResult.errorMessage = 'Address.PointOfService section in +i+-th Address cannot be empty';
            validateResult.errorFlag = true;
            return validateResult;
        }

        validateResult.errorFlag = false;
        validateResult.errorMessage = '';
        return validateResult;
    }


    /**
     * CheckUpdateAddress.
     *
     * @param addWr the add wr
     * @param type the account type
     * @return the wrapper result
     * @description method to verify if Address required parameters are correctly filled to update it
     */
    public static XC_UTIL_Integration.WrapperResult checkUpdateAddress(XC_UTIL_Address.AddressWrapper addWr, String type) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        Map<String, String> requiredParameters = new Map<String, String>{'StreetType' => addWr.StreetType,
                                                                        'Address' => addWr.Address,
                                                                        'StreetNumber' => addWr.StreetNumber,
                                                                        'ZipCode' => addWr.ZipCode,
                                                                        'City' => addWr.City,
                                                                        'Country' => addWr.Country
                                                                        };
        for(String key : requiredParameters.keySet()){
            if(requiredParameters.get(key) != null && requiredParameters.get(key).isWhitespace()) {
                validateResult.errorMessage = 'Address.' + key + ' in +i+-th Address cannot be empty';
                validateResult.errorFlag = true;
                return validateResult;
            }
        }
        
        // POS
        if(addWr.PointOfService != null && !addWr.PointOfService.isEmpty()){
            checkPOS(addWr.PointOfService, validateResult);
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }

        validateResult.errorFlag = false;
        validateResult.errorMessage = '';
        return validateResult;
    }


    /**
     * CheckPOS.
     *
     * @param posList the pos list
     * @param validateResult the result
     * @description method to verify if POS required parameters are correctly filled
     */
    public static void checkPOS(List<XC_UTIL_Address.PosWrapper> posList, XC_UTIL_Integration.WrapperResult validateResult) {

        Integer j = 1;
        for(XC_UTIL_Address.PosWrapper pos : posList){
            if(String.isBlank(pos.POSID)) {
                checkInsertPOS(pos, j, validateResult);
            } else {
                checkUpdatePOS(pos, j, validateResult);
            }
            j++;
        }
    }


    /**
     * CheckInsertPOS.
     *
     * @param pos the pos
     * @param j the counter
     * @param validateResult the result
     * @description method to verify if POS required parameters are correctly filled to insert it
     */
    public static void checkInsertPOS(XC_UTIL_Address.PosWrapper pos, Integer j, XC_UTIL_Integration.WrapperResult validateResult) {

        if (String.isBlank(pos.POSType)){
            validateResult.errorMessage = 'Missing mandatory field: Address.PointOfService.POSType in ' + j + '-th PointOfService';
            validateResult.errorFlag = true;
            return;
        }
        if (String.isBlank(pos.POS)){
            validateResult.errorMessage = 'Missing mandatory field: Address.PointOfService.POS in ' + j + '-th PointOfService';
            validateResult.errorFlag = true;
            return;
        }
    }


    /**
     * CheckUpdatePOS.
     *
     * @param pos the pos
     * @param j the counter
     * @param validateResult the result
     * @description method to verify if POS required parameters are correctly filled to update it
     */
    public static void checkUpdatePOS(XC_UTIL_Address.PosWrapper pos, Integer j, XC_UTIL_Integration.WrapperResult validateResult) {

        if (pos.POSType.isWhitespace()){
            validateResult.errorMessage = 'Address.PointOfService.POSType in ' + j + '-th PointOfService cannot be empty';
            validateResult.errorFlag = true;
            return;
        }
        if (pos.POS.isWhitespace()){
            validateResult.errorMessage = 'Address.PointOfService.POS in ' + j + '-th PointOfService cannot be empty';
            validateResult.errorFlag = true;
            return;
        }
    }


    /**
     * ValidateAddressForBillingProfile.
     *
     * @param addressList the address list
     * @param clientSystem the client System
     * @param wr the wrapper result
     * @return the boolean
     * @description Method to validate address for billing profile
     */
    public static Boolean validateAddressForBillingProfile(List<XC_UTIL_Address.AddressWrapper> addressList, String clientSystem, XC_UTIL_Integration.WrapperResult wr) {

        Boolean checkNewAddress = false;

        for(XC_UTIL_Address.AddressWrapper addwr: addressList){
            if(String.isBlank(addwr.AddressID)){
                checkNewAddress = true; 
                if((clientSystem == 'XRecharge' || clientSystem == 'XInstaller' || clientSystem == 'E-Commerce' || clientSystem == 'Partner')
                    && (addwr.BillingAddress == null || addWr.DeliveryAddress == null)) {
                        wr.errorMessage = ' Missing mandatory field Address.Shipping Address and Address.BillingAddress';
                        wr.errorFlag = true;
                }
            }
        }

        return checkNewAddress;
    }

}
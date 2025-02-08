/**
 * The Class XC_UTIL_CommodityAccount. 
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.it
 * @date Creation 06/06/2019
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_CommodityAccount
 */
public class XC_UTIL_CommodityAccount {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_ReadAccont');

    /*private static final String CUPS_TYPE_GAS_STRING = 'Gas';
    private static final String CUPS_TYPE_LIGHT_STRING1 = 'Light';
    private static final String CUPS_TYPE_LIGHT_STRING2 = 'Electricidad';*/
    private static final List<String> CUPS_TYPE_GAS_VALUES = new List<String>{'02','Gas'};
    private static final List<String> CUPS_TYPE_LIGHT_VALUES = new List<String>{'01','Light','Electricidad'};

    /**
     * @description populateWrapperResponseAddress
     * @param account account commodity response wrapper
     * @return List<XC_LCC011_U_NewAddress.WrapperResponseAddress> result
     */
    public static List<XC_LCC011_U_NewAddress.WrapperResponseAddress> populateWrapperResponseAddress(XC_UTIL_Account.AccountIFWrapper account){
        List<XC_LCC011_U_NewAddress.WrapperResponseAddress> rwList = new List<XC_LCC011_U_NewAddress.WrapperResponseAddress>();
        if(account == null || account.Address == null){
            return rwList;
        }
        XC_LCC011_U_NewAddress.WrapperResponseAddress wrAddr;
        for(XC_UTIL_Address.AddressWrapper address : account.Address){
            populateCUPSFields(address);
            convertCountry(address);
            address.StreetTypeText = address.StreetType;
            wrAddr = new XC_LCC011_U_NewAddress.WrapperResponseAddress();
            wrAddr.address = JSON.serialize(address);
            wrAddr.addressName =  address.getFullName();
            rwList.add(wrAddr);
        }
        return rwList;
    }

    /**
     * @description convertCountry
     * @param address address commodity response wrapper
     */
    private static void convertCountry(XC_UTIL_Address.AddressWrapper address){
        String country = address.Country;
        address.Country = getConvertedCountry(country);
    }

    /**
     * @description populateCUPSFields
     * @param address address commodity response wrapper
     */
    private static void populateCUPSFields(XC_UTIL_Address.AddressWrapper address){
        List<XC_UTIL_Address.PoSWrapper> posList = address.PointOfService;
        if(posList == null || posList.isEmpty()){
            return;
        }
        for(XC_UTIL_Address.PoSWrapper wrPos : posList){
            Map<String, Object> posParameters = new Map<String, Object>
            {
                'Type' => wrPos.POSType,
                'Pos'  => wrPos.POS
            };
            //if(CUPS_TYPE_LIGHT_STRING1.equals((String)posParameters.get('Type')) || CUPS_TYPE_LIGHT_STRING2.equals((String)posParameters.get('Type'))){
            if(CUPS_TYPE_LIGHT_VALUES.contains((String)posParameters.get('Type'))){
                address.electricCUPS = (String)posParameters.get('Pos');
            }
            else if(CUPS_TYPE_GAS_VALUES.contains((String)posParameters.get('Type'))){ //if(CUPS_TYPE_GAS_STRING.equals((String)posParameters.get('Type'))){
                address.gasCUPS = (String)posParameters.get('Pos');
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ electricCUPS = '+address.electricCUPS);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ gasCUPS = '+address.gasCUPS);
    }

    /**
     * @description importAddressFromCommodity.
     * @param recordId Account Id
     * @param addressValues addressValue
     * @return the populated Address Wrapper
     */
    /*public static XC_UTIL_Address.AddressWrapper populateAddressFromCommodityFieldsNEW(String recordId, List<Map<String,Object>> addressValues, List<List<Map<String,Object>>> posValues){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> populateAddressFromCommodityFields - addressValues = '+addressValues);
       
        List<String> txtFildKyes = new List<String>{'StreetType','Address','ZipCode','City','MunicipalityCode','Province','StreetNumber','Door','Floor','Stair'};
        List<String> booleanFildKyes = new List<String>{'InstallationAddress','ShippingAddress','BillingAddress'};
        
        XC_UTIL_Address.AddressWrapper addressWrapper = new XC_UTIL_Address.AddressWrapper();
        addressWrapper.accountId = recordId;
        for(Map<String,Object> field : addressValues){
            String key = (String)field.get('fieldKey');
            if('Country'.equals(key)){
                String commCountry = (String)field.get('fieldValue');
                addressWrapper.country = getConvertedCountry(commCountry);
            }
            else if(txtFildKyes.contains(key)) {
                //addressWrapper.put(key,(String)field.get('fieldValue'));
            }
            else if(booleanFildKyes.contains(key)) {
                Boolean value = (field.get('fieldValue') != null) ? Boolean.valueOf(field.get('fieldValue')) : false;
                //addressWrapper.put(key,value);
            }

            /*else if('StreetType'.equals(field.get('fieldKey'))) {addressWrapper.streetTypeText = (String)field.get('fieldValue');}
            else if('Address'.equals(field.get('fieldKey'))) {addressWrapper.address = (String)field.get('fieldValue');}
            else if('ZipCode'.equals(field.get('fieldKey'))) {addressWrapper.zipCode = (String)field.get('fieldValue');}
            else if('City'.equals(field.get('fieldKey'))) {addressWrapper.city = (String)field.get('fieldValue');}
            else if('MunicipalityCode'.equals(field.get('fieldKey'))) {addressWrapper.province = (String)field.get('fieldValue');}
            else if('Province'.equals(field.get('fieldKey'))) {addressWrapper.province = (String)field.get('fieldValue');}
            else if('StreetNumber'.equals(field.get('fieldKey'))) {addressWrapper.streetNumber = (String)field.get('fieldValue');}
            else if('Door'.equals(field.get('fieldKey'))) {addressWrapper.door = (String)field.get('fieldValue');}
            else if('Floor'.equals(field.get('fieldKey'))) {addressWrapper.floor = (String)field.get('fieldValue');}
            else if('Stair'.equals(field.get('fieldKey'))) {addressWrapper.stair = (String)field.get('fieldValue');}
            else if('InstallationAddress'.equals(field.get('fieldKey'))) {
                addressWrapper.installationAddress = (field.get('fieldValue') != null) ? Boolean.valueOf(field.get('fieldValue')) : false;
            }
            else if('ShippingAddress'.equals(field.get('fieldKey'))) {
                addressWrapper.deliveryAddress = (field.get('fieldValue') != null) ? Boolean.valueOf(field.get('fieldValue')) : false;
            }
            else if('BillingAddress'.equals(field.get('fieldKey'))) {
                addressWrapper.billingAddress = (field.get('fieldValue') != null) ? Boolean.valueOf(field.get('fieldValue')) : false;
            }* /
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> populateAddressFromCommodityFields - posValues = '+posValues);
        for(List<Map<String,Object>> posFilds : posValues){
            String posType;
            String pos;
            for(Map<String,Object> posFild : posFilds){
                if('POSType'.equals(posFild.get('fieldKey'))) {
                    posType = (String)posFild.get('fieldValue');
                }
                if('POS'.equals(posFild.get('fieldKey'))) {
                    pos = (String)posFild.get('fieldValue');
                }
            }
            if('Gas'.equals(posType)){
                addressWrapper.gasCUPS = pos;
            } else if('Light'.equals(posType) || 'Electricidad'.equals(posType)){
                addressWrapper.electricCUPS = pos;
            }
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ addressWrapper to insert = '+addressWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ electricCUPS = '+addressWrapper.electricCUPS);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ gasCUPS = '+addressWrapper.gasCUPS);
        return addressWrapper;
    }*/

    /**
     * @description importAddressFromCommodity.
     * @param addressWrapper addressWrapper to set
     * @param addressValues addressValue
     */
    private static void setAddressfields(XC_UTIL_Address.AddressWrapper addressWrapper, List<Map<String,Object>> addressValues){
        for(Map<String,Object> field : addressValues){
            if('Country'.equals(field.get('fieldKey'))){
                String commCountry = (String)field.get('fieldValue');
                addressWrapper.country = getConvertedCountry(commCountry);
            }
            else if('Category'.equals(field.get('fieldKey'))) {
                addressWrapper.category = (String)field.get('fieldValue');
            }
            else if('StreetType'.equals(field.get('fieldKey'))) {addressWrapper.streetTypeText = (String)field.get('fieldValue');}
            else if('Address'.equals(field.get('fieldKey'))) {addressWrapper.address = (String)field.get('fieldValue');}
            else if('ZipCode'.equals(field.get('fieldKey'))) {addressWrapper.zipCode = (String)field.get('fieldValue');}
            else if('City'.equals(field.get('fieldKey'))) {addressWrapper.city = (String)field.get('fieldValue');}
            else if('MunicipalName'.equals(field.get('fieldKey'))) {addressWrapper.municipality = (String)field.get('fieldValue');}
            else if('Province'.equals(field.get('fieldKey'))) {addressWrapper.province = (String)field.get('fieldValue');}
            else if('StreetNumber'.equals(field.get('fieldKey'))) {addressWrapper.streetNumber = (String)field.get('fieldValue');}
            else if('Door'.equals(field.get('fieldKey'))) {addressWrapper.door = (String)field.get('fieldValue');}
            else if('Floor'.equals(field.get('fieldKey'))) {addressWrapper.floor = (String)field.get('fieldValue');}
            else if('Stair'.equals(field.get('fieldKey'))) {addressWrapper.stair = (String)field.get('fieldValue');}
        }
    }

    /**
     * @description importAddressFromCommodity.
     * @param recordId Account Id
     * @param addressValues addressValue
     * @param posValues posValue
     * @return the populated Address Wrapper
     */
    public static XC_UTIL_Address.AddressWrapper populateAddressFromCommodityFields(String recordId, List<Map<String,Object>> addressValues, List<List<Map<String,Object>>> posValues){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> populateAddressFromCommodityFields - addressValues = '+addressValues);
        XC_UTIL_Address.AddressWrapper addressWrapper = new XC_UTIL_Address.AddressWrapper();

        boolean fromAccount = (XC_UTIL_Sobject.getObjectType(recordId)=='Account');
        if(fromAccount){
            addressWrapper.accountId = recordId;

        } else {
            addressWrapper.LeadId = recordId;

        }
        
        addressWrapper.installationAddress = true;
        addressWrapper.deliveryAddress =true;
        addressWrapper.billingAddress = true;
        setAddressfields(addressWrapper, addressValues);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> populateAddressFromCommodityFields - posValues = '+posValues);
        for(List<Map<String,Object>> posFilds : posValues){
            String posType;
            String pos;
            for(Map<String,Object> posFild : posFilds){
                if('POSType'.equals(posFild.get('fieldKey'))) {
                    posType = (String)posFild.get('fieldValue');
                }
                if('POS'.equals(posFild.get('fieldKey'))) {
                    pos = (String)posFild.get('fieldValue');
                }
            }
            if(CUPS_TYPE_GAS_VALUES.contains(posType)){ //CUPS_TYPE_GAS_STRING.equals(posType)                
                addressWrapper.gasCUPS = pos;
            } else if(CUPS_TYPE_LIGHT_VALUES.contains(posType)){ //CUPS_TYPE_LIGHT_STRING1.equals(posType) || CUPS_TYPE_LIGHT_STRING2.equals(posType)
                addressWrapper.electricCUPS = pos;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ addressWrapper to insert = '+addressWrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ electricCUPS = '+addressWrapper.electricCUPS);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ gasCUPS = '+addressWrapper.gasCUPS);
        return addressWrapper;
    }

    /**
     * @description getConvertCountry
     * @param commCountry 
     * @return converted Country (input if mapping not exists)
     */
    private static String getConvertedCountry(String commCountry){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ getConvertCountry - input = ' + commCountry);
        if(String.isBlank(commCountry)){
            return '';
        }
        Map<String, String> countryConversionMap = new Map<String, String> {'SPAIN'  => 'Spain',
																	        'ESPAÑA' => 'Spain',
																	        'SPAGNA' => 'Spain'};

        String commCountryUpp = commCountry.toUpperCase();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ getConvertCountry - conversion = ' + countryConversionMap.get(commCountryUpp));
        return (countryConversionMap.get(commCountryUpp) != null) ? countryConversionMap.get(commCountryUpp) : commCountry;
    }

    /**
     * @description populateAddressFieldsOnLead.
     * @param recordId lead Id
     * @param addressValues addressValue
     * @return the lead 
     */
    public static Lead populateAddressFieldsOnLead(String recordId, List<Map<String,Object>> addressValues){
		Lead l = new Lead();
		l.id = recordId;
 		
		for(Map<String,Object> field : addressValues){

            if('Country'.equals(field.get('fieldKey'))){
                String commCountry = (String)field.get('fieldValue');
                l.XC_Country__c = getConvertedCountry(commCountry);
            }

            //else if('Category'.equals(field.get('fieldKey'))) {l.XC_Category__c = (String)field.get('fieldValue');}
            else if('Address'.equals(field.get('fieldKey'))) {l.XC_Address__c = (String)field.get('fieldValue');}
			//else if('StreetType'.equals(field.get('fieldKey'))) {l.XC_StreetTypeText__c = (String)field.get('fieldValue');}
            else if('ZipCode'.equals(field.get('fieldKey'))) {l.XC_ZipCode__c = (String)field.get('fieldValue');}
            else if('City'.equals(field.get('fieldKey'))) {l.XC_City__c = (String)field.get('fieldValue');}
            else if('Province'.equals(field.get('fieldKey'))) {l.XC_Province__c = (String)field.get('fieldValue');}
			else if('Municipality Code'.equals(field.get('fieldKey'))) {l.XC_Municipality__c = (String)field.get('fieldValue');}
            else if('StreetNumber'.equals(field.get('fieldKey'))) {l.XC_StreetNumber__c = (String)field.get('fieldValue');}
            else if('Door'.equals(field.get('fieldKey'))) {l.XC_Door__c = (String)field.get('fieldValue');}
            else if('Floor'.equals(field.get('fieldKey'))) {l.XC_Floor__c = (String)field.get('fieldValue');}
            else if('Stair'.equals(field.get('fieldKey'))) {l.XC_Stair__c = (String)field.get('fieldValue');}
        }

		return l;
	}
    
}
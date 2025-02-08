/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation 09/04/2019
* @date Modification 05/06/2020
* @description Contains wrappers related the Account Commodity object
*/
public  without sharing class XC_UTIL_CommodityAccountRelated {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC005_AccountCallToCommodity');

	/**
     * @description commodityToAccountRecordTypeMapping
     **/
	private static Map<String,String> commodityToAccountRecordTypeMapping = new Map<String,String>
	{
		'Residential'    => 'XC_GLO_Account_Residential',
		'Small Business' => 'XC_GLO_Account_Soho',
		'Condominium'    => 'XC_GLO_Account_Condominium',
		'Partner'        => 'XC_Account_Partner'
	};

	/**
     * @description commodityToLeadRecordTypeMapping
     **/
	private static Map<String,String> commodityToLeadRecordTypeMapping = new Map<String,String>
	{
		'Residential'    => 'XC_GLO_Lead_Residential',
		'Small Business' => 'XC_GLO_Lead_Soho',
		'Condominium'    => 'XC_GLO_Lead_Condominium'
	};

	/**
     * @description checkCommodityAccountRecordType
	 * @param objType
	 * @param rtAccountName
	 * @param commodityAccountType
	 * @return true if match, else false
     **/
	public static Boolean checkCommodityAccountRecordType(String objType, String rtAccountName, String commodityAccountType){
        if(commodityAccountType == null){
            return true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ checkCommodityAccountRecordType -> objType='+objType);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ rtAccountName='+rtAccountName +' - commodityAccountType='+commodityAccountType);
		String mappedRT = '';
		if('Account'.equals(objType)){
			mappedRT = commodityToAccountRecordTypeMapping.get(commodityAccountType);
		} else if('Lead'.equals(objType)){
			mappedRT = commodityToLeadRecordTypeMapping.get(commodityAccountType);
		}
		return (mappedRT!= null && mappedRT.equals(rtAccountName));
	}

	/**
     * @description checkExcentionCommodityMapping
	 * @param objType
	 * @param rtAccountName
	 * @param commodityAccount
	 * @return true if there is an exception mapping, else false
     **/
	public static Boolean checkExcentionCommodityMapping(String objType, String rtAccountName, XC_UTIL_Account.AccountIFWrapper commodityAccount){
        if(commodityAccount == null){
            return false;
        }
		if('Account'.equals(objType)){
			if( rtAccountName == 'XC_GLO_Account_Soho' && String.isBlank(commodityAccount.FirstName)){
				commodityAccount.AccountType = 'Small Business';
				return true;
			}
		}
		return false;
	}

}
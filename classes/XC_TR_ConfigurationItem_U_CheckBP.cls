/**
 * @description The Class XC_TR_ConfigurationItem_U_CheckBP.
 */
public class XC_TR_ConfigurationItem_U_CheckBP {
private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_AT_Constants');

    /**
     * @description Check billing profile conditions.
     * @param listItems the list items
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkBillingProfileConditions(List<NE__OrderItem__c> listItems, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
    XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_AT_Constants');
    }

}
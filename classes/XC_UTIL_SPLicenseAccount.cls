/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 17/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_SPLicenseAccount – Util class to perform logic on partenr Accounts for Safety Points License
 */
public without sharing class XC_UTIL_SPLicenseAccount {

    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description check if the license activation date is included in the range passed as input
    *@param a Account to be checked
    *@param startDate lower threshold
    *@param endDate upper threshold
    *@return true if activation date is inside the range, false otherwise
    **/
    public static Boolean checkActivationDateBetweenRange(Account a, Date startDate, Date endDate) {
        Boolean insideRange = false;
        if(startDate <= a.XC_SafetyPointLicenseActivationDate__c.dateGMT() && endDate >= a.XC_SafetyPointLicenseActivationDate__c.dateGMT()) {
            insideRange = true;
        }
        return insideRange;
    }
}
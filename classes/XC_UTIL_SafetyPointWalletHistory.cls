/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 16/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_SafetyPointWalletHistory – Util class for Safety Point Wallet History
 */
public without sharing class XC_UTIL_SafetyPointWalletHistory {

    private static final String HISTORY_LICENSE_CHANGES_RT = Schema.SObjectType.XC_Safety_Point_Wallet_History__c.getRecordTypeInfosByDeveloperName().get('XC_SPW_History_License_Changes').getRecordTypeId();
    
    public class DateRanges {
        private final List<DateRange> dateRanges;

        public DateRanges(List<DateRange> dateRanges) {
            this.dateRanges = dateRanges;
        }

        public List<DateRange> values() {
            return dateRanges;
        }

        public Boolean isInsideRange(Datetime timestamp) {
            Boolean insideRange = false;
            for(DateRange dr : dateRanges) {
                if(dr.startDate < timestamp && dr.endDate > timestamp) {
                    insideRange = true;
                }
            }
            return insideRange;
        }
    }

    public class DateRange {
        public final Datetime startDate;
        public final Datetime endDate;

        public DateRange(Datetime startDate, Datetime endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }

    /**
    *@author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description Identifies license suspension ranges for an account
    *@param accountId account id to be analyzed
    *@return List of suspension data ranges
    **/
    public static DateRanges getSuspensionRanges(String accountId) {
        List<DateRange> dateRanges = new List<DateRange>();
        List<XC_Safety_Point_Wallet_History__c> histories = [
            SELECT Id, CreatedDate, XC_Previous_SafetyPointLicense_Suspended__c, XC_Actual_Safety_Point_License_Suspended__c
            FROM XC_Safety_Point_Wallet_History__c
            WHERE XC_Account__c = :accountId AND RecordTypeId = :HISTORY_LICENSE_CHANGES_RT
            ORDER BY CreatedDate
        ];
        Datetime startDate;
        Datetime endDate;
        for(XC_Safety_Point_Wallet_History__c h : histories) {
            if(!h.XC_Previous_SafetyPointLicense_Suspended__c && h.XC_Actual_Safety_Point_License_Suspended__c) {
                startDate = h.CreatedDate;
            }
            if(h.XC_Previous_SafetyPointLicense_Suspended__c && !h.XC_Actual_Safety_Point_License_Suspended__c) {
                endDate = h.CreatedDate;
            }
            if(startDate != null && endDate != null) {
                dateRanges.add(new DateRange(startDate, endDate));
                startDate = null;
                endDate = null;
            }
        }
        if(startDate != null) {
            dateRanges.add(new DateRange(startDate, System.now()));
        }
        return new DateRanges(dateRanges);
    }
}
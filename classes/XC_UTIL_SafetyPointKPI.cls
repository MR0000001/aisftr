/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_SafetyPointKPI – Class to manage Safety Point KPI custom setting
 */
public without sharing class XC_UTIL_SafetyPointKPI {

    public class ThresholdData {
        public final Decimal lowerThreshold;
        public final Decimal upperThreshold;
        public final Decimal bonusMalus;

        public ThresholdData(Decimal lowerThreshold, Decimal upperThreshold, Decimal bonusMalus) {
            this.lowerThreshold = lowerThreshold;
            this.upperThreshold = upperThreshold;
            this.bonusMalus = bonusMalus;
        }
    }
    
    /**
    @author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description Compute Bonus/Malus according to inputs
    *@param kpi
    *@param kpiType
    *@param legalEntity
    *@param country
    *@return Bonus/Malus points to be applied on Safety Points License
    **/
    public static ThresholdData computeBonusMalus(Decimal kpi, String kpiType, String country) {
        ThresholdData data;
        List<XC_CS015_SafetyPoint_KPI__c> thresholds = XC_CS015_SafetyPoint_KPI__c.getAll().values();
        for(XC_CS015_SafetyPoint_KPI__c s : thresholds) {
            if(s.XC_Country__c.equals(country) 
                && kpiType.equals(s.XC_KPI_Type__c)
                && (kpi > s.XC_Min__c || s.XC_Min__c == null) && kpi <= s.XC_Max__c) {
                data = new ThresholdData(s.XC_Min__c, s.XC_Max__c, s.XC_Points__c);
            }
        }
        return data;
    }
}
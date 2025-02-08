/**
 * @description       : Class to manage Safety Culture KPI custom setting
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 29-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_UTIL_SafetyCultureKPI {
    
    /**
    * @description get bonus to apply to a safety point wallet 
    * @author pedro.danielalmeida@nttdata.com | 29-06-2022 
    * @param kpiRate 
    * @param kpiOutcome 
    * @param typeOfIniative 
    * @param country 
    * @return Decimal 
    **/
    public static Decimal computeBonusMalus(Decimal kpiRate,Decimal kpiOutcome, String typeOfIniative, String country) {
        Decimal points = 0;
        List<XC_CS_KPISafetyCulture__c> thresholds = XC_CS_KPISafetyCulture__c.getall().values();
        for(XC_CS_KPISafetyCulture__c s : thresholds) {
            if(s.XC_Country__c.equals(country) && 
                typeOfIniative == s.XC_Type_of_Iniative__c && 
                check(kpiOutcome, s.XC_Participation_Outcome__c, s.XC_Participation_Outcome_Operator__c) &&
                check(kpiRate, s.XC_Participation_Rate__c, s.XC_Participation_Rate_Operator__c)) {
                points = s.XC_Points__c;
            }
        }
        return points;
    } 

    public static Boolean check(Decimal kpi, Decimal kpiFromSetting, String operator) {
        Boolean result = false;
        if(kpiFromSetting == null || operator == null) {
            result = true;
        }
        else if(operator.equalsIgnoreCase('equals')) {
            result = (kpi == kpiFromSetting);
        }        
        else if(operator.equalsIgnoreCase('lower than')) {
            result = (kpi < kpiFromSetting);
        } 
              
        return result;
    }
}
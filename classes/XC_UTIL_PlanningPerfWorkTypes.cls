/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_PlanningPerfWorkTypes – Class to manage Planning Performance KPI products custom setting
 */
public without sharing class XC_UTIL_PlanningPerfWorkTypes {

    /**
    @author Alessandro Catto - alessandro11.catto@nttdata.com
    *@description get workTypes configured for the inputs
    *@param legalEntity
    *@param country
    *@return set of products available for the inputs
    **/
    public static Set<String> getProducts(String country) {
        List<XC_CS013_PlanningPerformanceWorkTypes__c> workTypesSettings = XC_CS013_PlanningPerformanceWorkTypes__c.getAll().values();
        Set<String> products = new Set<String>();
        for(XC_CS013_PlanningPerformanceWorkTypes__c s : workTypesSettings) {
            if(s.XC_Country__c.equals(country)) {
                products.add(s.XC_WorkTypeName__c);
            }
        }
        return products;
    }
}
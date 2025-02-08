/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/07/2019
* @description XC_LCC127_SkillResourcePartner – Util class for XC_LCP127_SkillResourcePartner 
*/

public with sharing class XC_LCC127_SkillResourcePartner {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC127_SkillResourcePartner');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 05/07/2019
    * @description Method to retrieve Partner and information about skills of Service Resource
    * @return List<Map<String, String>>
    */
    @AuraEnabled
    public static List<Map<String, String>> retrievePartners() {
        List<Map<String, String>> listResult = new List<Map<String, String>>();
        List<AggregateResult> listAggregateResult = new List<AggregateResult>([
            SELECT COUNT(Id) CountActiveSkill, ServiceResource.XC_Account__r.Id AccountId, ServiceResource.XC_Account__r.Name AccountName
            FROM ServiceResourceSkill 
            WHERE XC_IsSkillActive__c = true 
            GROUP BY ServiceResource.XC_Account__r.Name, ServiceResource.XC_Account__r.Id
        ]);
        List<AggregateResult> listServiceResourceSkill = new List<AggregateResult>([
            SELECT COUNT(Id) totSkill, ServiceResource.XC_Account__r.Id AccountId  
            FROM ServiceResourceSkill
            GROUP BY ServiceResource.XC_Account__r.Id 
        ]);
        Map<String, Integer> mapServiceResourceCount = new Map<String, Integer>();
        for(AggregateResult srs : listServiceResourceSkill) {
            mapServiceResourceCount.put(String.valueOf(srs.get('AccountId')), Integer.valueOf(srs.get('totSkill')));
        }

        for(AggregateResult result : listAggregateResult) {
            Map<String, String> mapResult = new Map<String, String>();
            mapResult.put('id', String.valueOf(result.get('AccountId')));
            mapResult.put('url', '/one/one.app?#/sObject/' + String.valueOf(result.get('AccountId')) +  + '/view');
            mapResult.put('namePartner', String.valueOf(result.get('AccountName')));
            String status = 'action:new_case';
            if(Integer.valueOf(result.get('CountActiveSkill')) == 0) {
                status = 'action:close';
            } else if(Integer.valueOf(result.get('CountActiveSkill')) == mapServiceResourceCount.get(String.valueOf(result.get('AccountId')))) {
                status = 'action:approval';
            }
            mapResult.put('status', status);
            listResult.add(mapResult);
        }

        return listResult;
    }

}
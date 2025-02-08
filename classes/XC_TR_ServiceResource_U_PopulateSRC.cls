/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  03/03/2021 
* @description XC_TR_ServiceResource_U_PopulateSRC – Copy the data from Partner Coverage to Service Resource Coverage
*/

public without sharing class XC_TR_ServiceResource_U_PopulateSRC {
    
    /**
     * @description Copy the data from Partner Coverage to Service Resource Coverage
     * @param listNew
     */
    public static void populateServiceResourceCoverage(Map<Id, Sobject> mapOld, Map<Id, Sobject> mapNew) {
        List<ServiceResource> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Account__c'}, mapOld, mapNew);
        List<ServiceResource> listToManage = new List<ServiceResource>();
        for (Serviceresource sr : listChanged){
            if(!String.isBlank(sr.XC_Account__c) && sr.ResourceType == 'C'){
                listToManage.add(sr);
            }
        }
        if(!listToManage.isEmpty()){
            copySRCFromParent(listToManage);
        }
    }
    
    /**
     * @description Copy the data from Partner Coverage to Service Resource Coverage
     * @param listNew
     */
    private static void copySRCFromParent(List<ServiceResource> listToManage) {
        List<String> listAccountIds = XC_UTIL_SObject.getListFieldValues(listToManage, 'XC_Account__c');
        Map<Id, Account> mapAccount = new Map<Id, Account>([
            SELECT Id,
                (
                    SELECT Id, XC_ZipCodeWorkType__c, XC_WorkType__c, XC_ZipCode__c 
                    FROM Partner_Coverages__r
                    WHERE XC_ZipCodeWorkType__c != null 
                    LIMIT 49000
                )
            FROM Account
            WHERE Id IN:listAccountIds   
        ]); 
        List<XC_ServiceResourceCoverage__c> listSrcToInsert = new List<XC_ServiceResourceCoverage__c>();
        for(ServiceResource sr : listToManage){
            List<XC_PartnerCoverage__c> listPC = mapAccount.get(sr.XC_Account__c).Partner_Coverages__r;
            for(XC_PartnerCoverage__c pc : listPC){
                XC_ServiceResourceCoverage__c src = new XC_ServiceResourceCoverage__c();
                src.XC_ServiceResourceId__c = sr.Id;
                src.XC_ZipCodeWorkTypeId__c = pc.XC_ZipCodeWorkType__c;
                src.XC_WorkTypeId__c = pc.XC_WorkType__c;
                src.XC_InheritedFromParent__c = true;
                src.XC_ZipCodeText__c = pc.XC_ZipCode__c;
                src.XC_WorkTypeId__c = pc.XC_WorkType__c;
                src.XC_ExternalIdForDuplication__c = sr.Id+'_'+pc.XC_ZipCode__c+'_'+pc.XC_WorkType__c;
                listSrcToInsert.add(src);
            }
        }
        Map<Integer, List<XC_ServiceResourceCoverage__c>> mapIndexedCoveragesToInsert = new Map<Integer, List<XC_ServiceResourceCoverage__c>>();
        for(Integer k=0; k<listSrcToInsert.size(); k++) {
            if(!mapIndexedCoveragesToInsert.containsKey(Integer.valueOf(k/9000))) {
                mapIndexedCoveragesToInsert.put(Integer.valueOf(k/9000), new List<XC_ServiceResourceCoverage__c>());
            }
            mapIndexedCoveragesToInsert.get(Integer.valueOf(k/9000)).add(listSrcToInsert[k]);
        }
        for(Integer key : mapIndexedCoveragesToInsert.keySet()) {
            System.enqueueJob(new XC_LCC114_MassiveAssignmentWorkType_U.XC_Queueable_CreateSRC(mapIndexedCoveragesToInsert.get(key)));
        }
    }
}
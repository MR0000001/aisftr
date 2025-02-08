/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/09/2019
* @description XC_TR_ServiceCrew_U_FillFields – Util class for ServiceCrewMember Trigger for fill fields
*/

public without sharing class XC_TR_ServiceCrew_U_FillFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceCrew_U_FillFields');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/09/2019
     * @description Method to fill Account field from Service Resource 'T'
     * @param listNew - List<ServiceCrew>
     * @param mapOld - Map<Id, ServiceCrew>
     * @param mapNew - Map<Id, ServiceCrew>
    */
    public static void fillAccountField(List<ServiceCrew> listNew, Map<Id, ServiceCrew> mapOld, Map<Id, ServiceCrew> mapNew) {  
        List<ServiceCrew> listServiceCrew = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_NumberOfMembers__c'}, mapOld, mapNew);
        List<String> listIdServiceCrew = XC_UTIL_Sobject.getListFieldValues(listServiceCrew, 'Id');
        List<ServiceCrewMember> listSrm = new List<ServiceCrewMember>([
            SELECT Id, ServiceCrewId, ServiceResourceId, ServiceResource.XC_Account__c
            FROM ServiceCrewMember
            WHERE ServiceCrewId IN :listIdServiceCrew AND ServiceResource.ResourceType = 'T'
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listSrm --> ' + listSrm);

        Map<String, String> mapServiceCrewIdAccountName = new Map<String, String>();
        for(ServiceCrewMember scm : listSrm) {
            mapServiceCrewIdAccountName.put(scm.ServiceCrewId, scm.ServiceResource.XC_Account__c);
        }

        List<ServiceCrew> listCrewWithChild = new List<ServiceCrew>([
            SELECT Id,
                (SELECT Id 
                FROM ServiceResources 
                WHERE ServiceResource.ResourceType = 'C')
            FROM ServiceCrew
            WHERE Id IN :listNew
        ]);
        Map<String, String> mapServiceCrewIdServiceResourceCId = new Map<String, String>();
        for(ServiceCrew sc : listCrewWithChild) {
            for(ServiceResource sr : sc.ServiceResources) {
                mapServiceCrewIdServiceResourceCId.put(sc.Id, sr.Id);
            }
        }

        List<ServiceResource> listCrewToUpdate = new List<ServiceResource>();
        for(ServiceCrew sc : listNew) {
            String idServiceCrew = mapServiceCrewIdServiceResourceCId.get(sc.Id);
            String accountName = mapServiceCrewIdAccountName.get(sc.Id);
            ServiceResource srToUpdate = new ServiceResource(
                Id = idServiceCrew,
                XC_Account__c = accountName
            );
            listCrewToUpdate.add(srToUpdate);
        } 
        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.updateListRecords(listCrewToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(listWr)) {
            listNew[0].addError(listWr[0].errorMessage);
        }
    }
	


}
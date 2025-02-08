/**
* @author Roberta Cossiga rcossiga@deloitte.it | Emanuela Cacace ecacace@deloitte.it
* @date Creation 03/07/2019
* @date Modification dd/mm/yyyy
* @description  XC_TR_ServiceResource_U_WorkingForEndesa
*/
public without sharing class XC_TR_ServiceResource_U_WorkingForEndesa {
    /**
     *
     * @param resList the res list 
     * @param mapOld the old map of ServiceResource
     * @param mapNew the new map of ServiceResource
     * @description  checkResourceWorkingForEndesa
     */
    public static void checkResourceWorkingForEndesa(List<ServiceResource> resList, Map<Id,ServiceResource> mapOld, Map<Id,ServiceResource> mapNew){
        List<String> fieldList = new List<String>{'XC_WorkingForEndesa__c'};
        List<ServiceResource> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            deactiveResources(listChanged);
        }
    }

    /**
     *
     * @param listChanged the changed list 
     * @description  checkResourceWorkingForEndesa
     */
    public static void deactiveResources (List<ServiceResource> listChanged){
        for (ServiceResource sr : listChanged){
            sr.IsActive = sr.XC_WorkingForEndesa__c;   
            }
        }
}
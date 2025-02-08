/**
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date 23/01/2020
 * @description XC_TR_ServiceTerritoryMember_U_Check - Util class to check new Service Territory Member
**/

public without sharing class XC_TR_ServiceTerritoryMember_U_Check {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceTerritoryMember_U_Check');

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date 23/01/2020
    * @description Check if territory can be inserted
    * @param listNew - List<ServiceTerritoryMember>
    **/
    public static void checkTerritoryOnInsert(List<ServiceTerritoryMember> listNew){ 
        List<ServiceTerritoryMember> listToManage = new List<ServiceTerritoryMember>();
        Map<Id, ServiceTerritoryMember> mapSTM = new Map<Id,ServiceTerritoryMember>([
            SELECT ServiceResource.XC_IsManager__c, ServiceTerritoryId, ServiceResource.XC_Account__c
            FROM ServiceTerritoryMember 
            WHERE Id IN: listNew               
        ]);
        for(ServiceTerritoryMember stm : listNew){
            if(!mapSTM.get(stm.Id).ServiceResource.XC_IsManager__c){
                listToManage.add(stm);
            }
        }
        if(listToManage.isEmpty()){
            return;
        }

        List<Id> listAccountId = new List<Id>();
        for(ServiceTerritoryMember stm : listToManage){
            listAccountId.add(mapSTM.get(stm.Id).ServiceResource.XC_Account__c);
        }
        List<ServiceResource> listManagers = new List<ServiceResource>([
            SELECT Id,XC_Account__c, 
                (SELECT Id, ServiceTerritoryId FROM ServiceTerritories)
            FROM ServiceResource 
            WHERE XC_IsManager__c = true AND XC_Account__c IN: listAccountId
        ]);

        Map<Id, List<Id>> mapAccountIdListTerritoryId = populateMapAccountIdListTerritoryId(listManagers);

        if(mapAccountIdListTerritoryId.isEmpty()){
            return;
        }

        for(ServiceTerritoryMember stm : listToManage){
            Id accountId = mapSTM.get(stm.Id).ServiceResource.XC_Account__c;
            List<Id> listTerritoryId = mapAccountIdListTerritoryId.get(accountId);
            if(!listTerritoryId.isEmpty() && !listTerritoryId.contains(mapSTM.get(stm.Id).ServiceTerritoryId)){
                stm.addError(Label.XC_CL_TerritoryMemberError);
            }
        }
    }

    @TestVisible
    private static Map<Id, List<Id>> populateMapAccountIdListTerritoryId (List<ServiceResource> listManagers){
        Map<Id, List<Id>> mapAccountIdListTerritoryId = new Map<Id, List<Id>>();
        for(ServiceResource sr: listManagers) {
            List<ServiceTerritoryMember> listSTM = sr.ServiceTerritories;
            for(ServiceTerritoryMember stm : listSTM){
                if(!mapAccountIdListTerritoryId.containsKey(sr.XC_Account__c)){
                     mapAccountIdListTerritoryId.put(sr.XC_Account__c, new List<Id>());
                }
                mapAccountIdListTerritoryId.get(sr.XC_Account__c).add(stm.ServiceTerritoryId);  
            }
        }
        return mapAccountIdListTerritoryId;
    }
	

    
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date 04/01/2022
    * @description Add the operating hour name on Service Resource
    * @param listNew - List<ServiceTerritoryMember>
    **/
    public static void addOperatingHoursOnInsert(List<ServiceTerritoryMember> listNew){ 
        Map<String,String> srIdOperatingHourName = new Map<String,String>();
        List<ServiceTerritoryMember> listSTMQueried = getInfo(listNew);
        for(ServiceTerritoryMember stm : listSTMQueried){
            if(!String.isBlank(stm.ServiceResourceId) && !String.isBlank(stm.OperatingHours.Name) ){
                srIdOperatingHourName.put(stm.ServiceResourceId, stm.OperatingHours.Name);
            }
        }
        if(!srIdOperatingHourName.isEmpty()){
            updateServiceResource(srIdOperatingHourName);
        }
    }

        /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date 04/01/2022
    * @description Add the operating hour name on Service Resource
    * @param listNew - List<ServiceTerritoryMember>
    **/
    public static void addOperatingHoursOnUpdate(List<ServiceTerritoryMember> listNew, Map<Id, ServiceTerritoryMember> mapOld, Map<Id, ServiceTerritoryMember> mapNew){ 
        List<String> fieldList = new List<String>{'XC_OperatingHoursNameSR__c','OperatingHoursId'};
        List<ServiceTerritoryMember> serviceTerritoryMemberList = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(serviceTerritoryMemberList.isEmpty()){
            return;
        }
        Map<String,String> srIdOperatingHourName = new Map<String,String>();
        List<ServiceTerritoryMember> listSTMQueried = getInfo(serviceTerritoryMemberList);
        for(ServiceTerritoryMember stm : listSTMQueried){
            if(!String.isBlank(stm.ServiceResourceId) && !String.isBlank(stm.OperatingHours.Name) && (stm.XC_OperatingHoursNameSR__c || (mapOld.get(stm.Id).OperatingHoursId != mapNew.get(stm.Id).OperatingHoursId ) )){
                srIdOperatingHourName.put(stm.ServiceResourceId, stm.OperatingHours.Name);
            }
        }
        if(!srIdOperatingHourName.isEmpty()){
            updateServiceResource(srIdOperatingHourName);
        }
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date 04/01/2022
    * @description update Service Resource
    * @param listNew - List<ServiceTerritoryMember>
    **/
    private static void updateServiceResource(Map<String,String> srIdOperatingHourName){ 
        List<ServiceResource> srToUpdateList = new List<ServiceResource>();
        for(String serviceResourdeId : srIdOperatingHourName.keySet() ){
            if(srIdOperatingHourName.containsKey(serviceResourdeId) && !String.isEmpty(srIdOperatingHourName.get(serviceResourdeId))){
                ServiceResource srToUpdate = new ServiceResource(Id = serviceResourdeId, XC_OperatingHoursName__c = srIdOperatingHourName.get(serviceResourdeId));
                srToUpdateList.add(srToUpdate);
            }
        }
        XC_TR_ServiceResource_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ServiceResource_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
        XC_UTIL_Sobject.updateListRecords(srToUpdateList);
        XC_TR_ServiceResource_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ServiceResource_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @date 04/01/2022
    * @description get needed Info
    * @param SerTerrMemList - List<ServiceTerritoryMember>
    **/ 
    private static List<ServiceTerritoryMember> getInfo(List<ServiceTerritoryMember> SerTerrMemList){ 
        String legalEntityString = Label.XC_CL_OperatingHoursName_LegalEntities;
        String segmentString = Label.XC_CL_OperatingHoursName_Segments;
        List<String> legalEntityList = new List<String>();
        List<String> segmentList = new List<String>();
        if(legalEntityString.contains(';')){
            legalEntityList = legalEntityString.split(';');
        } else {
            legalEntityList.add(legalEntityString);
        }
        if(segmentString.contains(';')){
            segmentList = segmentString.split(';');
        } else {
            segmentList.add(segmentString);
        }
        List<String> stmIdList = XC_UTIL_Sobject.getIds(SerTerrMemList);
        List<ServiceTerritoryMember> listSTM = new List<ServiceTerritoryMember>([
            SELECT ServiceResourceId, OperatingHours.Name, ServiceResource.XC_LegalEntity__c, XC_OperatingHoursNameSR__c, OperatingHoursId
            FROM ServiceTerritoryMember 
            WHERE Id IN: stmIdList AND ServiceResource.XC_LegalEntity__c IN: legalEntityList AND (ServiceResource.Account.XC_Segment__c IN: segmentList OR ServiceResource.Account.XC_Segment__c = '') AND ServiceResource.RelatedRecord.IsActive =: true        
        ]);
        return listSTM;
    }
}
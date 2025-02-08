/**
* @author Federico Amici - federico.amici1@nttdata.com
* @date Creation 17/06/2019
* @date Modification:
* @description XC_TR_ServiceAppointment_U_OptySubSt - Manage substatus on opportunity substatus
*/
public with sharing class XC_TR_ServiceAppointment_U_OptySubSt {
   
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 07/06/2019
    * @param listNew the list of opportunity to insert
    * @param mapOld the map of old opportunity versions to update
    * @param mapNew the map of new opportunity versions to update
    * @description updateSubstatusPicklist the substatus field if condition matches
    */
    public static void updateSubstatusPicklist(List<ServiceAppointment> listNew, Map<Id, ServiceAppointment> mapOld, Map<Id, ServiceAppointment> mapNew) {

        listNew = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listNew.isEmpty()) {
            return;
        }

        Map<String, Opportunity> mapSAWithOpty = getSAWithOpty(listNew);
        if(mapSAWithOpty.values().isEmpty()) {
            return;
        }

        //List<String> listOpportunityIds = getOpportunityIds(listSAWithOpty);
        //Map<Id, Opportunity> mapOpportunity = XC_TR_ServiceAppointment_U_OptySubSt_D.getOpportunityByIdList(listOpportunityIds);
        //mapOpportunity = getMapSAIdToOpportunity(listNew, mapOpportunity);
        Opportunity opp;
        List<Opportunity> listOpportunityToUpdate = new List<Opportunity>();

        for(String saId : mapSAWithOpty.keySet()) {
            opp = new Opportunity(Id = mapSAWithOpty.get(saId).Id);
            if(mapNew.get(saId).Status == Label.XC_CL_ServiceAppointment_Scheduled) {
                opp.XC_Substatus__c = Label.XC_CL_Opportunity_PendingCommVisit;
                listOpportunityToUpdate.add(opp);
            } else if(mapNew.get(saId).Status == Label.XC_CL_ServiceAppointment_In_Progress) {
                opp.XC_Substatus__c = Label.XC_CL_Opportunity_QuoteOrderTBC;
                listOpportunityToUpdate.add(opp);
            }
        }
       
        XC_UTIL_SObject.updateListRecords(listOpportunityToUpdate);
    }
	
    @TestVisible
    private static List<String> getOpportunityIds(List<ServiceAppointment> listSA) {

        List<String> listOpportunityIds = new List<String>();

        for(ServiceAppointment sa : listSA) {
           listOpportunityIds.add(sa.ParentRecordId);
        }
        return listOpportunityIds;

    }

    private static Map<String, Opportunity> getSAWithOpty(List<ServiceAppointment> listNew) {
        Map<String, String> mapSAIdWOId = new Map<String, String>();

        for(ServiceAppointment sa : listNew) {    
            if(sa.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit) {
                mapSAIdWOId.put(sa.Id, sa.parentRecordId);
            }
        }
        
        if(mapSAIdWOId.values().isEmpty()) {
            return new Map<String, Opportunity>();
        }

        Map<Id, WorkOrder> mapWorkOrder = XC_TR_ServiceAppointment_U_OptySubst_D.getOppFromWO(mapSAIdWOId.values());
        if(mapWorkOrder.values().isEmpty()) {
            return new Map<String, Opportunity>();
        }

        Map<String, Opportunity> mapRet = new Map<String, Opportunity>();
        Opportunity opp;
        WorkOrder wo;

        for(String saId : mapSAIdWOId.keySet()) {
            wo = mapWorkOrder.get(mapSAIdWOId.get(saId));
            opp = new Opportunity(Id = wo.XC_Opportunity__c);
            mapRet.put(saId, opp);
        }

        return mapRet;
    }

}
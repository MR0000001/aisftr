/**
 * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
 * @date  : 10/09/2019
 * @description Populate the Preferred Resource (Required) of the Work Order.
**/

public without sharing class XC_TR_WorkOrder_U_RequiredResMgmt {

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
     * @description Method to populate the Preferred Resources (Required) for each Work Order
     * @param listNew - list Id of new records
     * @return List<XC_UTIL_Sobject.WrapperResult>
     */

    public static List<XC_UTIL_Sobject.WrapperResult> manageRequiredResourcesOnInsert(List<WorkOrder> listNew) { 
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = getRequiredResources(listNew, null);
        if(!mapWorkOrderListServiceResources.isEmpty()){   
            return XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(mapWorkOrderListServiceResources);
        }
        return new List<XC_UTIL_Sobject.WrapperResult>();
    } 
    
    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
     * @description Method to get the Preferred Resources (Required) for each Work Order
     * @param listNew - list Id of new records
     * @param preferredAccountId - accountId to force preferences
     * @return Map<Id, Set<Id>>
     */
         
    public static Map<Id, Set<Id>> getRequiredResources(List<WorkOrder> listNew, String preferredAccountId) { 
        List<WorkOrder> workOrdersToPreAssign = XC_TR_WorkOrder_U_RequiredResMgmt_U.getWorkOrderToApplyPreferences(listNew);
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = getRequiredResourcesForWorkOrders(workOrdersToPreAssign, preferredAccountId);
        return mapWorkOrderListServiceResources;
    }

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
     * @description Method to retrieve a map that associates to each WorkOrder the list of Ids of Service Resources to be inserted as Required
     * @param listWorkOrder - list Id of new records
     * @param preferredAccountId - accountId to force preferences
     * @return Map<Id, Set<Id>>
     */

    private static Map<Id, Set<Id>> getRequiredResourcesForWorkOrders(List<WorkOrder> listWorkOrder, String preferredAccountId) { 
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
        
        Map<Id, Id> mapWorkOrderPreferredResourceAccount = XC_TR_WorkOrder_U_RequiredResMgmt_U.getMapWorkOrderPreferredResourceAccount(listWorkOrder, preferredAccountId);
        Map<Id, List<ServiceResource>> mapAccountListServiceResources = XC_TR_WorkOrder_U_RequiredResMgmt_D.retrieveMapAccountListServiceResources(mapWorkOrderPreferredResourceAccount.values());
        
        List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
        for(WorkOrder wo : listWorkOrder){
            if(!mapWorkOrderPreferredResourceAccount.containsKey(wo.Id)){
                continue;
            } 
            Id accountId = mapWorkOrderPreferredResourceAccount.get(wo.Id); 
            WorkOrder woToUpdate = new WorkOrder();
            woToUpdate.Id = wo.Id;
            woToUpdate.XC_RequiredPartnerId__c = accountId;
            listWoToUpdate.add(woToUpdate);
            if(!mapAccountListServiceResources.containsKey(accountId)){
                continue;
            }
            List<ServiceResource> listServiceResources = mapAccountListServiceResources.get(accountId);
            if(!listServiceResources.isEmpty()){
                List<Id> listSRIds = XC_UTIL_Sobject.getIds(listServiceResources);
                mapWorkOrderListServiceResources.put(wo.Id, new Set<Id>(listSRIds));
            } 
        } 
       
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(listWoToUpdate);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        
        return mapWorkOrderListServiceResources;
    }
}
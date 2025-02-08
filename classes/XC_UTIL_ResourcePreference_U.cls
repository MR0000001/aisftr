/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 19/04/2019
* @description XC_UTIL_ResourcePreference_U - Methods for XC_UTIL_ResourcePreference_U
**/

public without sharing class XC_UTIL_ResourcePreference_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ResourcePreference_U'); 

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it
    * @param workOrderToChange
    * @param partnerIdCurrentResource
    * @description method to excludeDispatcher
    */         
    public static void excludeDispatcher(WorkOrder workOrderToChange, String partnerIdCurrentResource){
        List<ResourcePreference> rpList = new List<ResourcePreference>();
        if(Schema.SObjectType.ResourcePreference.isAccessible() && Schema.sObjectType.ResourcePreference.fields.Id.isAccessible() && Schema.sObjectType.ResourcePreference.fields.ServiceResourceId.isAccessible() && Schema.sObjectType.ResourcePreference.fields.PreferenceType.isAccessible()){
            rpList = [
                SELECT Id, ServiceResourceId, PreferenceType 
                FROM ResourcePreference
                WHERE RelatedRecordId =: workOrderToChange.Id
                AND PreferenceType = 'Required'
                AND ServiceResource.XC_Account__c =: partnerIdCurrentResource
            ];
        }
        for(ResourcePreference rp : rpList){            
            rp.PreferenceType = 'Excluded';  
        }
        XC_UTIL_Sobject.updateListRecords(rpList);
    }

    
    /**
    * @description this method get all children's shared Resource Preferences
    * @author Andrea Bravaccino | 30/7/2019
    * @param woParentList List<WorkOrder> 
    * @return Map<Id, Set<Id>>
    */
    public static Map<Id, Set<Id>> getResPrefFromChildren(List<WorkOrder> woParentList){
        List<Id> parentIds = XC_UTIL_Sobject.getIds(woParentList);
        List<WorkOrder> parentList = new List<WorkOrder>();
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([SELECT Id, ParentWorkOrderId, (SELECT Id, ServiceResourceId, ServiceResource.Name, PreferenceType from ResourcePreferences), (SELECT ID FROM ChildWorkOrders) FROM WorkOrder WHERE ParentWorkOrderId IN :parentIds OR ID IN :parentIds]);
        List<WorkOrder> woList = new List<WorkOrder>();
        system.debug('@@@woList -> ' + woList);

        for (Id parentId : parentIds) {
            parentList.add(woMap.get(parentId));
            woMap.remove(parentId);
        }
        woList.addAll(woMap.values());
        Map<Id, List<Id>> woParentRpChildren = new Map<Id, List<Id>>();
        Map<Id, Set<Id>> woParentRpToInsert = new Map<Id, Set<Id>>();


        for (WorkOrder wo : woList) {
            List<Id> rpList = new List<Id>();
            for (ResourcePreference rp : wo.ResourcePreferences) {
                rpList.add(rp.ServiceResourceId);
            }
            List<Id> listOfResPrefForEachWO = woParentRpChildren.get(wo.ParentWorkOrderId) != null ? woParentRpChildren.get(wo.ParentWorkOrderId) : new List<Id>();
            listOfResPrefForEachWO.addAll(rpList);
            woParentRpChildren.put(wo.ParentWorkOrderId, listOfResPrefForEachWO);
        }
        system.debug('@@@woParentRpChildren -> ' + woParentRpChildren);
        system.debug('@@@woParentRpToInsert -> ' + woParentRpToInsert);
        for (WorkOrder parentWo : parentList) {
            Set<Id> rpToAdd = new Set<Id>();
            List<Id> listOfResPrefForEachWO = woParentRpChildren.get(parentWo.Id);
            if (listOfResPrefForEachWO != null){
                Map<Id, Integer> numberOccurrence = countOccurrenceInList(listOfResPrefForEachWO);
                Integer numberOfChildren = parentWo.ChildWorkOrders.size();
                for (Id rpId : numberOccurrence.keySet()) {
                    if (numberOccurrence.get(rpId) == numberOfChildren){
                        rpToAdd.add(rpId);
                    }
                }
            }
            
            woParentRpToInsert.put(parentWo.Id, rpToAdd);
        system.debug('@@@woParentRpToInsert -> ' + woParentRpToInsert);
        system.debug('@@@listOfResPrefForEachWO -> ' + listOfResPrefForEachWO);
        }
        return woParentRpToInsert;
    }

    private static Map<Id, Integer> countOccurrenceInList(List<Id> idToCount){
        Map<Id,Integer> occurrence = new Map<Id,Integer>();
        for(Id key : idToCount){
            if(!occurrence.containsKey(key)){
            occurrence.put(key,0);
            }
            Integer currentInt = occurrence.get(key)+1;
            occurrence.put(key,currentInt);
        }
        return occurrence;
    }
}
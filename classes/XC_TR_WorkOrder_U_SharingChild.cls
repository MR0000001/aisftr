/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
 * @date 31/03/2020
 * @description XC_TR_WorkOrder_U_SharingChild - Class to share child Work Order
 */

public without sharing class XC_TR_WorkOrder_U_SharingChild {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_SharingChild');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
     * @date 31/03/2020
     * @description Method to share child Work Order with territory of Parent Work Order
     */
    public static void shareChildOnInsert(List<WorkOrder> listWo) {
        // Calculate a list of Child Work Orders:
        List<WorkOrder> listWoChild = new List<WorkOrder>();
        for(WorkOrder wo : listWo) {
            if(String.isNotBlank(wo.ParentWorkOrderId)) {
                listWoChild.add(wo);
            }
        }
        /*if(listWoChild.isEmpty()) {
            return;
        }*/

        // Retrieve territory and group to share:
        Set<String> setTerritoryName = new Set<String>();
        List<WorkOrder> listChildWithParent = new List<WorkOrder>();
        List<WorkOrder> listWoToManage = new List<WorkOrder>();
        if(!listWoChild.isEmpty()) {
            listChildWithParent = new List<WorkOrder>([
                SELECT Id, ParentWorkOrder.ServiceTerritory.Name, AssetId
                FROM WorkOrder
                WHERE Id IN :listWoChild
            ]);
            for(WorkOrder wo : listChildWithParent) {
                if(String.isNotBlank(wo.ParentWorkOrder.ServiceTerritory.Name)) {
                    setTerritoryName.add(wo.ParentWorkOrder.ServiceTerritory.Name);
                    listWoToManage.add(wo);
                }
            }
            if(setTerritoryName.isEmpty()) {
                return;
            }
        }

        // Insert Group Automotive and query groups:
        List<XC_CM_LegalEntity_Configuration__mdt> listLEconfiguration = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_GroupAutomotive__c, XC_LegalEntity__c, XC_Stream__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :XC_UTIL_Sobject.getListFieldValues(listWo, 'XC_LegalEntity__c') and XC_Stream__c IN :XC_UTIL_Sobject.getListFieldValues(listWo, 'XC_Segment__c') and XC_GroupAutomotive__c != null 
        ]);
        Map<String, String> mapKeyGroup = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt leConf : listLEconfiguration) {
            if(!mapKeyGroup.containsKey(leConf.XC_LegalEntity__c+leConf.XC_Stream__c)) {
                mapKeyGroup.put(leConf.XC_LegalEntity__c+leConf.XC_Stream__c, leConf.XC_GroupAutomotive__c);
            }
        }
        for(WorkOrder wo : listWo) {
            String key = wo.XC_LegalEntity__c+wo.XC_Segment__c;
            if(mapKeyGroup.containsKey(key)) {
                setTerritoryName.add(mapKeyGroup.get(key));
            }
        }
        List<Group> listGroup = new List<Group>([
            SELECT Id, Name  
            FROM Group  
            WHERE Name IN :setTerritoryName
        ]);

        // Create a Map: NameGroup -> Ids
        Map<String, String> mapGroupIds = new Map<String, String>();
        for(Group grp : listGroup) {
            mapGroupIds.put(grp.Name, grp.Id);
        }

        // Share Child Work Orders:
        List<WorkOrderShare> listWoShare = new List<WorkOrderShare>();
        List<AssetShare> listAssetShare = new List<AssetShare>();

        if(!listWoChild.isEmpty()) {
            for(WorkOrder woChild : listWoToManage) {
                String territoryName = woChild.ParentWorkOrder.ServiceTerritory.Name;
                if(mapGroupIds.containsKey(territoryName)) {
                    WorkOrderShare wos = new WorkOrderShare(
                        ParentId = woChild.Id,
                        UserOrGroupId = mapGroupIds.get(territoryName),
                        AccessLevel = 'Edit',
                        RowCause = 'Manual'
                    );
                    listWoShare.add(wos);
                    if(woChild.AssetId != null){
                        AssetShare asS = new AssetShare(
                            AssetId = woChild.AssetId,
                            UserOrGroupId = mapGroupIds.get(territoryName),
                            AssetAccessLevel = 'Read',
                            RowCause = 'Manual'
                        ); 
                        listAssetShare.add(asS);
                    }
                }
            }
        }

        // Share Parent Object Opportunity (for automotive partner)
        Map<Id, WorkOrder> mapParentWoWithOpportunity = new Map<Id, WorkOrder>([
            SELECT Id 
            FROM WorkOrder  

            WHERE Id IN :XC_UTIL_Sobject.getIds(listWo) AND XC_Opportunity__r.XC_ReceivingChannel__c =: Label.XC_CL_RecChannelAutomotivePartner
        ]);
        for(WorkOrder parentWo : listWo) {
            String key = parentWo.XC_LegalEntity__c+parentWo.XC_Segment__c;
            if(mapParentWoWithOpportunity.containsKey(parentWo.Id) && mapKeyGroup.containsKey(key) && mapGroupIds.containsKey(mapKeyGroup.get(key))) {

                WorkOrderShare wos = new WorkOrderShare(
                    ParentId = parentWo.Id,
                    UserOrGroupId = mapGroupIds.get(mapKeyGroup.get(key)),
                    AccessLevel = 'Edit',
                    RowCause = 'Manual'
                );
                listWoShare.add(wos);
            }
        }

        // DML Operation:
        List<XC_UTIL_Sobject.WrapperResult> listResult = XC_UTIL_Sobject.insertListRecords(listWoShare);
        if(!XC_UTIL_Sobject.checkDMLResults(listResult)) {
            listWoChild[0].addError(listResult[0].errorMessage);
        }
        List<XC_UTIL_Sobject.WrapperResult> listResultAs = XC_UTIL_Sobject.insertListRecords(listAssetShare);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
     * @date 31/03/2020
     * @description Method to share child Work Order with territory of Parent Work Order
     */
    public static void shareChildOnUpdate(Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<String> listFieldChanged = new List<String>{'XC_AssignedResource__c', 'ServiceTerritoryId', 'OwnerId'};
        List<WorkOrder> listWoFiltered = XC_UTIL_Sobject.getListChanged(listFieldChanged, mapOld, mapNew);
        if(listWoFiltered.isEmpty()) {
            return;
        }
        shareChildOnInsert(listWoFiltered);
    }

}
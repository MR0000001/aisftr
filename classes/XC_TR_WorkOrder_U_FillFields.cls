/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 09/08/2019
* @description XC_TR_WorkOrder_U_FillFields – Util class for trigger on WorkOrder
*/

public without sharing class XC_TR_WorkOrder_U_FillFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_FillFields');

    /**
     * @description Fill Segment field from Lead or Contact before WorkOrder insert
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @param listNew - List<WorkOrder>
     */
    public static void fillSegment(List<WorkOrder> listNew) {
        /*Set<Id> leadIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'XC_Lead__c');
        Map<Id, String> leadIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(leadIds, 'Lead');
        Set<Id> assetIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'AssetId');
        Map<Id, String> assetIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(assetIds, 'Asset');
        Set<Id> confItemIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'XC_Configuration_Item__c');
        Map<Id, String> confItemIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(confItemIds, 'NE__OrderItem__c');
        Set<Id> oppIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'XC_Opportunity__c');
        Map<Id, String> oppIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(oppIds, 'Opportunity');*/
        Set<Id> assetIds = new Set<Id>();
        Set<Id> confItemIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        for(WorkOrder wo : listNew) {
            if(String.isNotBlank(wo.XC_Lead__c)) {
                leadIds.add(wo.XC_Lead__c);
            } else if(String.isNotBlank(wo.AssetId)) {
                assetIds.add(wo.AssetId);
            } else if(String.isNotBlank(wo.XC_Configuration_Item__c)) {
                confItemIds.add(wo.XC_Configuration_Item__c);
            } else if(String.isNotBlank(wo.XC_Opportunity__c)) {
                oppIds.add(wo.XC_Opportunity__c);
            } 
        }

        Map<Id, String> leadIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(leadIds, 'Lead');
        Map<Id, String> assetIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(assetIds, 'Asset');
        Map<Id, String> confItemIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(confItemIds, 'NE__OrderItem__c');
        Map<Id, String> oppIdSegmentMap = XC_SegmentUtilities.getSegmentFromObject(oppIds, 'Opportunity');
        
        for(WorkOrder wo : listNew) {
            if(String.isNotBlank(wo.XC_Lead__c)) {
                wo.XC_Segment__c = leadIdSegmentMap.get(wo.XC_Lead__c);
            } else if(String.isNotBlank(wo.AssetId)) {
                wo.XC_Segment__c = assetIdSegmentMap.get(wo.AssetId);
            } else if(String.isNotBlank(wo.XC_Configuration_Item__c)) {
                wo.XC_Segment__c = confItemIdSegmentMap.get(wo.XC_Configuration_Item__c);
            } else if(String.isNotBlank(wo.XC_Opportunity__c)) {
                wo.XC_Segment__c = oppIdSegmentMap.get(wo.XC_Opportunity__c);
            } 
        }
    }

    /**
    * @author Dario Tramontin - dtramontin@deloitte.it
    * @date Creation 04/12/2019
    * @description Encrypt Id
    * @param listNew - List WorkOrder
    */
    public static void encryptWorkOrderIds(List<WorkOrder> listNew) {
        System.debug('Debug IN XC_TR_WorkOrder_U_FillFields - encryptWorkOrderIds ');
        List<WorkOrder> woToUpdate = new List<WorkOrder>();
        for(WorkOrder wo: listNew){
            WorkOrder woUpdate= new WorkOrder(Id=wo.Id);
            woUpdate.XC_EncryptedId__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(wo.Id);
            woToUpdate.add(woUpdate);
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(woToUpdate); 
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 06/04/2020
    * @description Method to concat Address on Work Order
    * @param listNew - List<WorkOrder>
    */
    public static void concatAddress(List<WorkOrder> listNew) {
        List<String> listAddressId = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Address__c');
        Map<Id, XC_Address__c> mapAddress = new Map<Id, XC_Address__c>([
            SELECT Id, XC_Address__c, XC_StreetTypeText__c,XC_Municipality__c, XC_StreetNumber__c, XC_City__c, XC_AddressCountry__c, XC_PostalCode__c, XC_AddressProvince__c,XC_Region__c
            FROM XC_Address__c
            WHERE Id IN :listAddressId
        ]);
        for(WorkOrder wo : listNew) {
            if(mapAddress.containsKey(wo.XC_Address__c)) {
                XC_Address__c address = mapAddress.get(wo.XC_Address__c);
                wo.City = address.XC_City__c;
                wo.Country = address.XC_AddressCountry__c;
                wo.PostalCode = address.XC_PostalCode__c;
                wo.State = address.XC_AddressProvince__c;// != null ? address.XC_AddressProvince__c : address.XC_Region__c;
                wo.XC_Municipality__c = address.XC_Municipality__c;
                String tempAddress = '';
                if(String.isNotBlank(address.XC_StreetTypeText__c)) {
                    tempAddress = address.XC_StreetTypeText__c + ' ';
                }
                if(String.isNotBlank(address.XC_Address__c)) {
                    tempAddress += address.XC_Address__c + ' ';
                    if(String.isNotBlank(address.XC_StreetNumber__c)) {
                        tempAddress += address.XC_StreetNumber__c;
                    }
                } 
                wo.Street = tempAddress;
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/09/2020
    * @description Method to fill key FSL to book appointment
    * @param listNew - List<WorkOrder>
    */
    public static void fillFSLKeyAppointment(List<WorkOrder> listNew) {
        List<XC_CM_LegalEntity_Configuration__mdt> listLE = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_FSLAssignmentKey__c, XC_LegalEntity__c, XC_Stream__c 
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_LegalEntity__c') AND XC_Stream__c IN :XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Segment__c')
        ]);
        Map<String, String> mapLEKey = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : listLE) {
            mapLEKey.put(cm.XC_LegalEntity__c+'_'+cm.XC_Stream__c, cm.XC_FSLAssignmentKey__c);
        }
        for(WorkOrder wo : listNew) {
            String key = mapLEKey.containsKey(wo.XC_LegalEntity__c+'_'+wo.XC_Segment__c) ? mapLEKey.get(wo.XC_LegalEntity__c+'_'+wo.XC_Segment__c) : 'PostalCode';
            wo.XC_FSLAssignmentKey__c = (String.isBlank(key) || wo.get(key)==null) ? (String) wo.PostalCode : (String) wo.get(key);
            if(wo.State == null && (wo.XC_Segment__c == 'B2B' || wo.XC_Segment__c == 'B2G')){
                wo.State =  wo.XC_FSLAssignmentKey__c != null ? wo.XC_FSLAssignmentKey__c : wo.XC_Municipality__c;
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/09/2020
    * @description Method to update key FSL to book appointment
    * @param listNew - List<WorkOrder>
    * @param mapOld - Map<Id, WorkOrder>
    * @param mapNew - Map<Id, WorkOrder>
    */
    public static void updateFSLKeyAppointment(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<XC_CM_LegalEntity_Configuration__mdt> listLE = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_FSLAssignmentKey__c, XC_LegalEntity__c, XC_Stream__c 
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_LegalEntity__c') AND XC_Stream__c IN :XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Segment__c')
        ]);
        Map<String, String> mapLEKey = new Map<String, String>();
        Map<String, Map<Id, WorkOrder>> mapWorkorderToProcc = new Map<String, Map<Id, WorkOrder>>();
        for(WorkOrder wo : listNew) {
            if(String.isNotBlank(wo.XC_LegalEntity__c) && String.isNotBlank(wo.XC_Segment__c)) {
                for(XC_CM_LegalEntity_Configuration__mdt cm : listLE) {
                    if(cm.XC_LegalEntity__c == wo.XC_LegalEntity__c && cm.XC_Stream__c == wo.XC_Segment__c) {
                        String key = String.isNotBlank(cm.XC_FSLAssignmentKey__c) ? cm.XC_FSLAssignmentKey__c : 'PostalCode';
                        if(!mapWorkorderToProcc.containsKey(key)) {
                            mapWorkorderToProcc.put(key, new Map<Id, WorkOrder>());
                        }
                        mapWorkorderToProcc.get(key).put(wo.Id, wo);
                        mapLEKey.put(cm.XC_LegalEntity__c+'_'+cm.XC_Stream__c, cm.XC_FSLAssignmentKey__c);
                        break;
                    }
                }
            }
        }
        if(mapWorkorderToProcc.keySet().isEmpty()) {
            return;
        }
        List<WorkOrder> listWoChanged = new List<WorkOrder>();
        for(String key : mapWorkorderToProcc.keySet()) {
            List<WorkOrder> listToAdd = XC_UTIL_Sobject.getListChanged(new List<String>{key}, mapOld, mapWorkorderToProcc.get(key));
            if(!listToAdd.isEmpty()) {
                listWoChanged.addAll(listToAdd);
            }
        }
        if(listWoChanged.isEmpty()) {
            return;
        }
        for(WorkOrder wo : listWoChanged) {
            String key = mapLEKey.containsKey(wo.XC_LegalEntity__c+'_'+wo.XC_Segment__c) ? mapLEKey.get(wo.XC_LegalEntity__c+'_'+wo.XC_Segment__c) : 'PostalCode';
            mapNew.get(wo.Id).XC_FSLAssignmentKey__c = (String.isBlank(key) || wo.get(key)==null) ? (String) mapNew.get(wo.Id).get('PostalCode') : (String) wo.get(key);
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/09/2020
    * @description Method to update fields for Service Appointment
    * @param listNew - List<WorkOrder>
    * @param mapOld - Map<Id, WorkOrder>
    * @param mapNew - Map<Id, WorkOrder>
    */
    public static void updateServiceApp(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<WorkOrder> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_FSLAssignmentKey__c'}, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        List<ServiceAppointment> listSa = new List<ServiceAppointment>([
            SELECT Id, ParentRecordId  
            FROM ServiceAppointment
            WHERE ParentRecordId IN :XC_UTIL_Sobject.getIds(listChanged)
        ]);
        if(listSa.isEmpty()) {
            return;
        }
        for(ServiceAppointment sa : listSa) {
            sa.XC_FSLAssignmentKey__c = mapNew.get(sa.ParentRecordId).XC_FSLAssignmentKey__c;
        }
        XC_UTIL_Sobject.updateListRecords(listSa);
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 07/05/2021
    * @description Method to fill Last Site Inspection on Order
    * @param listNew - List<WorkOrder>
    */
    public static void updateOrderWithLastSiteInspection(List<WorkOrder> listNew) {
        List<WorkOrder> listWoToProcess = new List<WorkOrder>();
        List<String> listConfigurationId = new List<String>();
        for(WorkOrder wo : listNew){
            if(!String.isBlank(wo.XC_Segment__c) && wo.XC_Segment__c == 'B2C' && 
                !String.isBlank(wo.XC_Configuration__c) && !String.isBlank(wo.XC_WorkTypeCategory__c) 
                && wo.XC_WorkTypeCategory__c.equals('Site Inspection')){
                listWoToProcess.add(wo);
                listConfigurationId.add(wo.XC_Configuration__c);
            }
        }
        if(listWoToProcess.isEmpty()){
            return;
        }
        List<NE__Order__c> listOrderToUpdate = new List<NE__Order__c>();
        for(WorkOrder wo : listWoToProcess){
            NE__Order__c ord = new NE__Order__c(Id = wo.XC_Configuration__c , XC_LastSiteInspection__c = wo.Id);
            listOrderToUpdate.add(ord);
        }
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(listOrderToUpdate); 
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);   
    }
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 09/08/2019
    * @description Method to fill RecordType for WorkOrder By CM
    * @param listNew - List<WorkOrder>
    */
    /*public static void populateRecordType(List<WorkOrder> listNew) {
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id,XC_LegalEntity__c, CaseId, Case.XC_LegalEntity__c, XC_Opportunity__c, XC_Lead__c, AssetId, XC_Configuration__c, XC_Opportunity__r.XC_LegalEntity__c, XC_Lead__r.XC_MainLegalEntity__c, Asset.XC_LegalEntity__c, XC_Configuration__r.XC_LegalEntity__c
            FROM WorkOrder
            WHERE Id IN :listNew
        ]);
        Map<String, String> mapIdWorkOrderLegalEntity = new Map<String, String>();

        for(Integer i=0; i<listWorkOrder.size(); i++) {
            if(!String.isBlank(listWorkOrder[i].CaseId) || listWorkOrder[i].CaseId != null) {
                mapIdWorkOrderLegalEntity.put(listWorkOrder[i].Id, listWorkOrder[i].Case.XC_LegalEntity__c);
            } 
            else if(!String.isBlank(listWorkOrder[i].XC_Opportunity__c) || listWorkOrder[i].XC_Opportunity__c != null) {
                mapIdWorkOrderLegalEntity.put(listWorkOrder[i].Id, listWorkOrder[i].XC_Opportunity__r.XC_LegalEntity__c);              
            }
            else if(!String.isBlank(listWorkOrder[i].XC_Lead__c) || listWorkOrder[i].XC_Lead__c != null) {
                mapIdWorkOrderLegalEntity.put(listWorkOrder[i].Id, listWorkOrder[i].XC_Lead__r.XC_MainLegalEntity__c);
            }
            else if(!String.isBlank(listWorkOrder[i].AssetId) || listWorkOrder[i].AssetId != null) {
                mapIdWorkOrderLegalEntity.put(listWorkOrder[i].Id, listWorkOrder[i].Asset.XC_LegalEntity__c);
            }
            else if(!String.isBlank(listWorkOrder[i].XC_Configuration__c) || listWorkOrder[i].XC_Configuration__c != null) {
                mapIdWorkOrderLegalEntity.put(listWorkOrder[i].Id, listWorkOrder[i].XC_Configuration__r.XC_LegalEntity__c);
            }
            else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ERROR: WorkOrder has not a Parent of type Case, Oppportunity, Lead, Asset ot Order.');
                return;
            }
        }

        String orgId = UserInfo.getOrganizationId();
        List<XC_CM_LegalEntity_Configuration__mdt> listCountry = new List<XC_CM_LegalEntity_Configuration__mdt>([
                SELECT XC_LegalEntity__c, XC_Country__c 
                FROM XC_CM_LegalEntity_Configuration__mdt
                WHERE XC_LegalEntity__c IN :mapIdWorkOrderLegalEntity.values() AND XC_OrgId__c =: orgId
        ]);
        Map<String, String> mapLegalEntityCountry = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : listCountry) {
            mapLegalEntityCountry.put(cm.XC_LegalEntity__c, cm.XC_Country__c);           
        }

        for(WorkOrder wo : listWorkOrder) {
            wo.RecordTypeId = XC_UTIL_WorkOrder.getWorkOrderRecordTypeByCountry(mapLegalEntityCountry.get(mapIdWorkOrderLegalEntity.get(wo.Id)));
            if(mapIdWorkOrderLegalEntity.containsKey(wo.Id) && String.isEmpty(wo.XC_LegalEntity__c)){
                wo.XC_LegalEntity__c = mapIdWorkOrderLegalEntity.get(wo.Id);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listWorkOrder);
    }*/

    /**
    * @description set status to on hold and status reason to KO Validated if Validation status is KO
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 2/10/2019 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    **/
    /*public static void checkValidation(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){
        List<String> fieldList = new List<String>{'XC_ValidationStatus__c'};
        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            for(WorkOrder wo : listChanged){
                if (wo.XC_ValidationStatus__c == Label.XC_CL_KO){
                    wo.Status = Label.XC_CL_OnHold;
                    wo.XC_StatusReason__c = Label.XC_CL_StatusReason_KOvalidated;
                }
            }
        }
    }*/

        /**
    * @description fill the field description on workorder based on the same field on the related case
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 2/10/2019 
    * @param listNew 
    **/
    public static void populateDescriptionFromCase(List<WorkOrder> listNew){
        List<WorkOrder> woWithCasesList = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(!String.isEmpty(wo.CaseId)){
                woWithCasesList.add(wo);
            }
        }
        if(woWithCasesList.isEmpty()){
            return;
        }
        List<String> caseIds = XC_UTIL_Sobject.getListFieldValues(woWithCasesList, 'CaseId');
        Map<Id, Case> caseQueriedMap = new Map<Id, Case>([SELECT Id, Description 
                                                                        FROM Case
                                                                        WHERE Id IN: caseIds]);
        for(WorkOrder wo : woWithCasesList){
            if(caseQueriedMap.containsKey(wo.CaseId) && !String.isEmpty(caseQueriedMap.get(wo.CaseId).Description) && String.isEmpty(wo.Description)){
                wo.Description = caseQueriedMap.get(wo.CaseId).Description;
            }
        }
    }

    public static void updateWBE( /*List<WorkOrder> trigger_new*/ Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        Set<Id> assetId = new Set<Id>();
        Map<Id, String> mapaAssetTypeOfService = new Map<Id, String>();

        for(Id mapNewId : mapNew.keyset()){
            if(((mapOld?.isEmpty() && !String.isBlank(mapNew.get(mapNewId)?.XC_TypeOfService__c)) || mapOld.get(mapNewId)?.XC_TypeOfService__c != mapNew.get(mapNewId)?.XC_TypeOfService__c) &&
            (mapNew.get(mapNewId)?.XC_WorkTypeLabel__c == 'Repair - Appliance' && mapNew.get(mapNewId)?.XC_Country__c == 'Portugal'
            && (mapNew.get(mapNewId)?.XC_LegalEntity__c == 'EndesaX' || mapNew.get(mapNewId)?.XC_LegalEntity__c == 'EnelXMobilitySpain') && mapNew.get(mapNewId)?.XC_Segment__c == 'B2C')){
                assetId.add( mapNew.get(mapNewId)?.AssetId );
            }
        }
        
        if(assetId.isEmpty()){
            return;
        }

        List<Asset> assets = [SELECT Id, XC_WBE__c FROM Asset WHERE Id IN :assetId];

        for(WorkOrder wo : mapNew.values()){
            mapaAssetTypeOfService.put(wo.AssetId, wo.XC_TypeOfService__c);
        }

        for(Asset asset : assets){
            asset.XC_WBE__c = mapaAssetTypeOfService.get(asset.Id);
        }

        update assets;
    }

    // public static Map<String, String> woServiceTypeMap() {
    //     Map<String, String> woServiceTypeMap = new Map<String, String>();
    //     Schema.DescribeFieldResult describeServiceType = WorkOrder.Service_Type__c.getDescribe();
    //     List<Schema.PicklistEntry> serviceTypeList = describeServiceType.getPicklistValues();
    //     for ( Schema.PicklistEntry entry : serviceTypeList ) {
    //         woServiceTypeMap.put( entry.getValue(), entry.getLabel() );
    //     }
    //     return woServiceTypeMap;
    // }

}
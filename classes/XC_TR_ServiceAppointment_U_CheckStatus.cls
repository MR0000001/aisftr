/**
* @author Martina Barone - marbarone@deloitte.it, Fabrizio Antonioli - fabrizio.antonioli@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 7/11/2018
* @date Modification 26/06/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ServiceAppointment_U_CheckStatus - Check Status for Work Order in order to respect business logic
*/

public without sharing class XC_TR_ServiceAppointment_U_CheckStatus {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceAppointment_U_CheckStatus');

    /**
     * @author Martina Barone marbarone@deloitte.it
     * @date Modification 26/06/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listNew - List<ServiceAppointment>
     * @param mapOld - Map<Id,ServiceAppointment>
     * @param mapNew - Map<Id,ServiceAppointment>
     * @description Method to populate/check fields for Service Appointment
     */
    public static void manageChangeStatus(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew) {
        List<String> fieldList = new List<String>{'Status'};
        List<ServiceAppointment> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            // For WorkOrder D&I:
            List<ServiceAppointment> listServiceAppDI = XC_UTIL_WorkType.filterSAByWorkTypeCategory(listChanged, new List<String>{Label.XC_CL_WorkType_Installation, Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_Substitution});
            if(!listServiceAppDI.isEmpty()) {
                checkWOSerialNumber(listServiceAppDI);
            }
            // For WorkOrder Commercial Visit:
            List<ServiceAppointment> listServiceAppCommercialVisit = XC_UTIL_WorkType.filterSAByWorkTypeCategory(listChanged, new List<String>{Label.XC_CL_CommercialVisit});
            if(!listServiceAppCommercialVisit.isEmpty()) {
                XC_TR_ServiceAppointment_U_FillFieldByWO.changeLeadStatus(listServiceAppCommercialVisit);
            }
            // For Status from Scheduled to None:
            for(ServiceAppointment sa : listNew) {
                if(mapOld.get(sa.Id).Status == Label.XC_CL_ServiceAppointment_Scheduled && mapNew.get(sa.Id).Status  == Label.XC_CL_ServiceAppointment_None) {
                    sa.XC_AssignedPartner__c = null;
                    sa.XC_AssignedResource__c = null;
                    sa.ServiceTerritoryId = null;
                    sa.FSL__Scheduling_Policy_Used__c = null;
                }
            }
        }
    } 

    /**
     * @author Fabrizio Antonioli - fabrizio.antonioli@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listNew - List<ServiceAppointment>
     * @description Method to check if is allowed to create a new Service Appointment on a Work Order, taking the verification from the method below
     */
    public static void checkInsertServiceAppointment(List<ServiceAppointment> listNew) {
        List<String> workOrderIdList = new List<String>();
        for(ServiceAppointment sa : listNew){
            workOrderIdList.add(sa.ParentRecordId);
        }
        Map<String,Boolean> mapChecked = checkOnStatus(workOrderIdList);
        for(ServiceAppointment sa : listNew){
            if(sa.ParentRecordId != null){
                addErrorForServiceAppointment(sa, mapChecked);
            }  
        }
    }

    /** 
     * @description Add Error for Service Appointment for OpenSA and WOFInalStatus status
     * @param sa - ServiceAppointment
     * @param mapChecked - Map<String, Boolean>
     */
    private static void addErrorForServiceAppointment(ServiceAppointment sa, Map<String,Boolean> mapChecked){
        if(mapChecked.containsKey(sa.ParentRecordId)){
            if(!mapChecked.get(sa.ParentRecordId) ){
                sa.addError(label.XC_CL_ServiceAppointment_OpenSA);
            }
        }
        else {
            sa.addError(label.XC_CL_ServiceAppointment_WOFinalStatus);
        } 
    }

    /**
     * @author Fabrizio Antonioli - fabrizio.antonioli@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method takes in input e list of Work Order and return a Map<WorkOrderId, boolean>. The boolean is a check on the
     *                         possibility to create a new Service Appointment: if there's a Service Appointment in a non final status or the work
     *                         order father is in a final status, it's not allowed to create a new SA on the same Work Order (the key of the returned map).
     * @param woList - List<String>
     * @return Map<String, Boolean>
     */
    public static Map<String,Boolean> checkOnStatus(List<String> woList){
        Map<String,Boolean> mapWorkOrderBoolean = new Map<String,Boolean>();
        List<WorkOrder> listWo = new List<WorkOrder>();
        if(!woList.isEmpty()){
            Map<Id, WorkOrder> mapWo = new Map<Id, WorkOrder>([
                SELECT Id,Status,XC_Check_Final_Status__c,
                    (SELECT Id,XC_Check_Final_Status__c 
                    FROM ServiceAppointments) 
                FROM WorkOrder 
                WHERE Id IN: woList
            ]);
            listWo = mapWo.values();   
        }
        for(WorkOrder wo : listWo){
            Boolean check = false;
            if(!wo.XC_Check_Final_Status__c){        
                if(wo.ServiceAppointments.isEmpty()){
                    check = true;
                } else {
                    for(ServiceAppointment sa : wo.ServiceAppointments){
                        if(!sa.XC_Check_Final_Status__c){
                            check = false;
                            break;
                        }
                        else {
                            check = true;
                        }
                    }
                }
                mapWorkOrderBoolean.put(wo.Id,check);
            } else {
                check = false;
                mapWorkOrderBoolean.put('FinalStatus',check);
            }
        }
        return mapWorkOrderBoolean;
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @description  Method takes in input a list of Service Appointment and adds an error if the Serial Number
     *              field on the Work Order is blank, trying to close the Service Appointment. It will work only for Work Orders
     *              with Work Type: Installation and Delivery.
     * @param listNew - List<ServiceAppointment>
     */
    public static void checkWOSerialNumber(List<ServiceAppointment> listNew){
        List<WorkOrder> listOfWorkOrder = new List<WorkOrder>();
        if(!listNew.isEmpty()){
            for(ServiceAppointment sa : listNew){
                if(sa.Status == Label.XC_CL_ServiceAppointment_Completed) {
                    listOfWorkOrder.add(new WorkOrder(Id=sa.ParentRecordId));
                }
            }   
        }
        if(!listOfWorkOrder.isEmpty()){
            Map<Id, String> mapWoError = XC_UTIL_WorkOrder.getMapWorkOrderErrorSerialNumber(listOfWorkOrder);
            Set<Id> listWoIdError = mapWoError.keySet();
            for(ServiceAppointment sa : listNew) {
                if(listWoIdError.contains(sa.ParentRecordId)) {
                    sa.addError(mapWoError.get(sa.ParentRecordId));
                }
            }
            /*Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>
                ([SELECT Id, Asset.SerialNumber, XC_WorkTypeCategory__c, AssetId,
                    (SELECT Id, Asset.SerialNumber, XC_WorkTypeCategory__c, WorkOrderNumber
                    FROM ChildWorkOrders)
                FROM WorkOrder
                WHERE Id IN: listOfWorkOrderId]);
            addErrorOnWrongSA(listNew, workOrderMap);*/
        }
    }

    /**
     * @author Roberta Cossiga rcossiga@deloitte.it
     * @param listNew - List<ServiceAppointment>
     * @param mapOld - Map<Id,ServiceAppointment>
     * @param mapNew - Map<Id,ServiceAppointment>
     * @description Method check if the SA can be modified by a Partner Admin
     */
    public static void checkToBeDigitalized(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew){
        List<String> fieldList = new List<String>{'ActualStartTime', 'ActualEndTime'};
        List<ServiceAppointment> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            List<Id> parentWoIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'ParentRecordId');
            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>([
                SELECT Id, XC_ToBeManuallyDigitalized__c, XC_Digitized__c, XC_Segment__c, XC_UpdatedByApp__c
                FROM WorkOrder
                WHERE Id IN: parentWoIds
            ]);
            List<User> listcurrentUser = [SELECT Id,XC_AccountId__c FROM User WHERE Id =: UserInfo.getUserId()];
            List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
            Boolean isUserPartner = !listcurrentUser.isEmpty() && String.isNotBlank(listcurrentUser[0].XC_AccountId__c);
            for(ServiceAppointment sa : listNew){
                WorkOrder wo = workOrderMap.get(sa.ParentRecordId);
                if(isUserPartner && !wo.XC_ToBeManuallyDigitalized__c && sa.Status != Label.XC_CL_ServiceAppointment_Scheduled && (sa.XC_LegalEntity__c == Label.XC_CL_EndesaX || sa.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) && wo.XC_Segment__c == 'B2C'
                   && sa.Status != Label.XC_CL_ServiceAppointment_None){
                       if(wo.XC_UpdatedByApp__c == false) {
                            sa.addError(Label.XC_CL_CannotModifySA);
                       }
                       else {
                            listWoToUpdate.add(new WorkOrder(Id = wo.Id, XC_UpdatedByApp__c = false));
                       }
                }else if(isUserPartner && wo.XC_ToBeManuallyDigitalized__c && !wo.XC_Digitized__c && (sa.XC_LegalEntity__c == Label.XC_CL_EndesaX || sa.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) && wo.XC_Segment__c == 'B2C'
                   && sa.Status == Label.XC_CL_ServiceAppointment_Completed && wo.XC_UpdatedByApp__c == false/*currentUser.get(UserInfo.getUserId()).Profile.Name == 'XC_ESP_PartnerAdmin'*/){
                    sa.addError(Label.XC_CL_ServiceAppDigitized);  
                }
            }
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(listWoToUpdate);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
        }
    }

    /**
    * @description method to check and update WOLI status when Malfunctioning Service Appointment status is changed to Completed
    * @author francisca.arnaudfarinha@nttdata.com 
    * @param mapOld 
    * @param mapNew 
    **/
    
    public static void checkMalfunctioningSACompletion (Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew) {
        List<String> fieldList = new List<String>{'Status'};
        List<ServiceAppointment> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if (listChanged.isEmpty()) return;
        List<ServiceAppointment> listChangedToCompleted = new List<ServiceAppointment>();
        for (ServiceAppointment sa : listChanged){
            if(sa.Status == Label.XC_CL_ServiceAppointment_Completed){
                listChangedToCompleted.add(sa);
            }
        }
        if (listChangedToCompleted.isEmpty()) return;
        List<Id> workOrderIdList = XC_UTIL_Sobject.getListFieldValues(listChangedToCompleted, 'ParentRecordId');
        Map<Id,WorkOrder> woliMap = new Map<Id, WorkOrder>([SELECT Id, XC_LegalEntity__c, XC_WorkTypeCategory__c, XC_Segment__c, Status, StatusCategory,Case.XC_BusinessLine__c, (SELECT Id, Status, StatusCategory, LineItemNumber FROM WorkOrderLineItems), (SELECT Id, Status, StatusCategory FROM ChildWorkOrders) FROM WorkOrder WHERE Id IN :workOrderIdList AND XC_LegalEntity__c = 'EnelSole' AND Case.XC_BusinessLine__c = 'eCity' AND (XC_Segment__c = 'B2B' OR XC_Segment__c = 'B2G') AND XC_WorkTypeCategory__c = 'Malfunctioning']);
        List<WorkOrderLineItem> woliToUpdate = new List<WorkOrderLineItem>();
        List<WorkOrder> woToUpdate = new List<WorkOrder>();       
        for(ServiceAppointment sa : listChangedToCompleted){
            if(sa.Status == Label.XC_CL_ServiceAppointment_Completed && woliMap.get(sa.ParentRecordId) != null){
                System.debug('***** checkMalfunctioningSA');
                WorkOrder parentWo = woliMap.get(sa.ParentRecordId);
                List<WorkOrderLineItem> woliToUpdateSA = new List<WorkOrderLineItem>();
                List<String> woliNewStatus = new List<String>();
                for(WorkOrderLineItem woli : woliMap.get(sa.ParentRecordId).WorkOrderLineItems){
                    if(woli.Status == 'New'){                           
                        woliNewStatus.add(woli.LineItemNumber);                          
                    } else if (woli.StatusCategory == 'InProgress'){
                        woli.Status = Label.XC_CL_WorkOrder_Completed;
                        woliToUpdateSA.add(woli);
                    }                                                                   
                }
                if(woliNewStatus.isEmpty()){
                    woliToUpdate.addAll(woliToUpdateSA);
                    for(WorkOrder childWo : woliMap.get(sa.ParentRecordId).ChildWorkOrders){
                        if(childWo.StatusCategory == 'InProgress'){
                            childWo.Status = Label.XC_CL_WorkOrder_Completed;
                            woToUpdate.add(childWo);
                        }
                    }                    
                    if(parentWo.StatusCategory == 'InProgress'){
                        parentWo.Status = Label.XC_CL_WorkOrder_Completed;
                        woToUpdate.add(parentWo);
                    }
                } else {
                    sa.addError('Please check that all related activities are in completed status.');
                }
            }
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(woliToUpdate);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
        XC_UTIL_Sobject.updateListRecords(woToUpdate);
        
    }

    /**
    * @description method to update contract field XC_LastSupplyDeclared__c when a service appointment status changes to completed
    * @author pedro.danielalmeida@nttdata.com | 28-04-2022 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void checkServiceAppointmentWhenCompleted(Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<ServiceAppointment> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        if (listChanged.isEmpty()) return;
        
        Set<Id> setWorkOrders = new Set<Id>();
        Map<Id, DateTime> mapWoEndDates = new Map<Id, DateTime>();
        for (ServiceAppointment sa : mapNew.values()) {
            if (sa.Status != 'Completed') continue;
            setWorkOrders.add(sa.ParentRecordId);
            mapWoEndDates.put(sa.ParentRecordId, sa.ActualEndTime != null ? sa.ActualEndTime : sa.XC_ActualEndDateTimestamp__c);
        }

        Set<Id> setContractServicesFromProjectPhase = new Set<Id>();
        Map<Id, DateTime> mapContractServicesEndDates = new Map<Id, DateTime>();
        for (WorkOrder wo : [SELECT Id,XC_ProjectPhase__c,XC_ProjectPhase__r.XC_ContractService__c
                             FROM WorkOrder 
                             WHERE Id IN :setWorkOrders]) {
            if (String.isBlank(wo.XC_ProjectPhase__c)) continue;
            setContractServicesFromProjectPhase.add(wo.XC_ProjectPhase__r.XC_ContractService__c);
            mapContractServicesEndDates.put(wo.XC_ProjectPhase__r.XC_ContractService__c, mapWoEndDates.get(wo.Id));
        }

        List<XC_ContractItem__c> lstContractServicesToUpdate = new List<XC_ContractItem__c>();
        for (XC_ContractItem__c cont : [SELECT Id, XC_LastSupplyDeclared__c,XC_Contract__r.XC_LegalEntity__c,XC_Contract__r.XC_Segment__c 
                                        FROM XC_ContractItem__c 
                                        WHERE Id IN :setContractServicesFromProjectPhase]) {
            
            if (cont.XC_Contract__r.XC_LegalEntity__c != 'EnelSole' || cont.XC_Contract__r.XC_Segment__c == 'B2C' || String.isBlank(cont.XC_Contract__r.XC_Segment__c)) continue;
            cont.XC_LastSupplyDeclared__c = mapContractServicesEndDates.get(cont.Id);
            lstContractServicesToUpdate.add(cont);
        }

        XC_UTIL_Sobject.updateListRecords(lstContractServicesToUpdate);
    }

    public static void codeCoverage() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Code Coverage');
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param listNew - List<ServiceAppointment>
     * @param workOrderMap - Map<Id, WorkOrder>
     * @description  Add an error on Service Appointment if you are trying to complete it withour
                     the Serial Number on the WorkOrder
     */
     /*private static void addErrorOnWrongSA(List<ServiceAppointment> listNew, Map<Id, WorkOrder> workOrderMap){
        for(ServiceAppointment sa : listNew){
            if(!workOrderMap.containsKey(sa.ParentRecordId)){
                continue;
            }
            WorkOrder wo = workOrderMap.get(sa.ParentRecordId);
            String workTypeName = wo.XC_WorkTypeCategory__c;
            if(String.isNotBlank(wo.AssetId) && (workTypeName == Label.XC_CL_WorkType_Installation|| workTypeName == Label.XC_CL_WorkType_DeliveryInstallation)  
                && String.isBlank(wo.Asset.SerialNumber) && sa.Status == Label.XC_CL_Completed){
                sa.addError(Label.XC_CL_ServiceAppointment_SerialNumberBlank);
            }  
            for(WorkOrder woChild : wo.ChildWorkOrders) {
                workTypeName = woChild.XC_WorkTypeCategory__c;
                if((workTypeName == Label.XC_CL_WorkType_Installation|| workTypeName == Label.XC_CL_WorkType_DeliveryInstallation)  
                    && String.isBlank(woChild.Asset.SerialNumber) && sa.Status == Label.XC_CL_Completed){
                    sa.addError(Label.XC_CL_ErrorSubstitution_SerialNum + ' ' + woChild.WorkOrderNumber);
                }  
            }
        }
     }*/

    /**
     * @description On before update SA
     * @param listNew the list new
     */
    /*public static void onBeforeUpdateSA(List<ServiceAppointment> listNew){
        List<ServiceAppointment> toUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa : listNew){
            if(sa.Status == Label.XC_CL_WorkOrderLineItem_InProgressStatus){
                sa.ActualStartTime = Datetime.now();
            }
            if(sa.Status == Label.XC_CL_ServiceAppointment_CannotComplete || sa.Status == Label.XC_CL_ServiceAppointment_Completed){ 
                sa.ActualEndTime = Datetime.now(); 
                if(sa.ActualStartTime != null){
                    Decimal millisecondsBetween = sa.ActualEndTime.getTime() - sa.ActualStartTime.getTime();
                    XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG,'-- sa.ActualEndTime.getTime() --'+sa.ActualEndTime.getTime());
                    XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.DEBUG,'-- sa.ActualStartTime.getTime()--'+sa.ActualStartTime.getTime());
                    Decimal timeBetween = (millisecondsBetween / 60000);
                    Integer timeBetweenY = Integer.valueOf(timeBetween);
                    sa.ActualDuration = timeBetweenY;
                }
            }
        }
    }*/

}
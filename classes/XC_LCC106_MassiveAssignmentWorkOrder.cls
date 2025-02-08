/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 23/11/2020
* @description XC_LCC106_MassiveAssignmentWorkOrder – Apex Controller for XC_LCP106_MassiveAssignmentWorkOrder
*/

public without sharing class XC_LCC106_MassiveAssignmentWorkOrder {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC106_MassiveAssignmentWorkOrder');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 23/11/2020
    * @description InitialInfoWrapper - Wrapper for Init method of component
    */ 
    public class InitialInfoWrapper {
        @AuraEnabled
        public String dueDateCM = '';
        @AuraEnabled
        public Boolean isNotCaringAgent = true;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/04/2019
    * @description ResultByPartnerWrapper - Wrapper for choosed operation
    */ 
    public class ResultByPartnerWrapper {
        @AuraEnabled
        public List<OptionCheckboxWrapper> listWorkType = new List<OptionCheckboxWrapper>();
        @AuraEnabled
        public List<OptionCheckboxWrapper> listZipCode = new List<OptionCheckboxWrapper>();
        @AuraEnabled
        public List<OptionCheckboxWrapper> listStatus = new List<OptionCheckboxWrapper>();
        @AuraEnabled
        public List<OptionCheckboxWrapper> listStatusReason = new List<OptionCheckboxWrapper>();
        @AuraEnabled
        public List<OptionCheckboxWrapper> listProvinces = new List<OptionCheckboxWrapper>();
        @AuraEnabled
        public Map<String, List<OptionCheckboxWrapper>> mapProvinceListZipcode = new Map<String, List<OptionCheckboxWrapper>>();
        @AuraEnabled
        public List<WorkOrder> listWorkOrder = new List<WorkOrder>();   
        @AuraEnabled
        public String resultMessage {get; set;} 
        @AuraEnabled
        public Boolean check {get; set;}    
        @AuraEnabled
        public Boolean initialFilterRequired = false; 
        @AuraEnabled
        public Integer countWorkOrder = 0; 
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/04/2019
    * @description ResultWrapper 
    */ 
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;     
        @AuraEnabled
        public List<ListView> listViews = new List<ListView>(); 
        @AuraEnabled
        public String resultMessage {get; set;}      
        @AuraEnabled
        public Boolean dirtyData = false;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/04/2019
    * @description OptionCheckboxWrapper - Wrapper to populate table of component
    */ 
    public class OptionCheckboxWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        public OptionCheckboxWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 23/11/2020
    * @description UploadWrapper - Wrapper to import Excel
    */ 
    public class UploadWrapper {
        @AuraEnabled
        public String WorkOrderNumber = '';
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/04/2019
    * @description SplitWorkOrderWrapper - Wrapper to split Work Order for Partner/Tech
    */ 
    public class SplitWorkOrderWrapper {
        public List<String> listIdWorkOrderWithAssignPartner = new List<String>();
        public List<String> listIdWorkOrderWithouthAssignPartner = new List<String>();       
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 24/09/2020
     * @description Method to get initial information
     * @return InitialInfoWrapper
    */
    @AuraEnabled 
    public static InitialInfoWrapper getInitialInformation() {
        InitialInfoWrapper wr = new InitialInfoWrapper();
        List<XC_CM_ServiceAppointment_Default_Value__mdt> listCMDueDate = new List<XC_CM_ServiceAppointment_Default_Value__mdt>([
            SELECT XC_DaysForUpdateDueDate__c 
            FROM XC_CM_ServiceAppointment_Default_Value__mdt 
            LIMIT 1
        ]);
        wr.dueDateCM = listCMDueDate.isEmpty() ? '?' : String.valueOf(Integer.valueOf(listCMDueDate[0].XC_DaysForUpdateDueDate__c));
        List<User> listUser = new List<User>([
            SELECT Id, Profile.Name
            FROM User
            WHERE Id = :Userinfo.getUserId()
        ]);
        if(listUser[0].Profile.Name.contains('CaringAgent')) {
            wr.isNotCaringAgent = false;
        }
        return wr;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 10/04/2019
     * @description Method to get information about selected Origin Partner
     * @param idAssignedPartner - Id Assigned Resource
     * @param isOutOfDateFilter - Boolean
     * @param cutoff - Integer
     * @param initialFilter - Boolean
     * @param listZipCodeSelected - String
     * @param listWorkTypeSelected - String
     * @param initialLimitedFilter - Boolean
     * @return resultWrapper - ResultByPartnerWrapper
    */
    @AuraEnabled
    public static ResultByPartnerWrapper getResultWrapperByPartner(String idAssignedPartner, Boolean isOutOfDateFilter, Integer cutoff, Boolean initialFilter, String listZipCodeSelectedString, String listWorkTypeSelectedString, Boolean initialLimitedFilter) {
        ResultByPartnerWrapper resultWrapper = new ResultByPartnerWrapper();  
        List<WorkOrder> listWorkOrder = new List<WorkOrder>();     
        if(initialFilter) {
            List<String> listZipCodeSelected = (List<String>) JSON.deserialize(listZipCodeSelectedString, Type.forName('List<String>'));
            List<String> listWorkTypeSelected = (List<String>) JSON.deserialize(listWorkTypeSelectedString, Type.forName('List<String>'));
            String labelAssigned = Label.XC_CL_WorkOrder_Assigned;
            String labelOnHold = Label.XC_CL_OnHold;
            if(listZipCodeSelected.isEmpty() && listWorkTypeSelected.isEmpty() && !initialLimitedFilter) {
                resultWrapper.initialFilterRequired = true;
                resultWrapper.check = false;
            } else {
                String query =  'SELECT Id, DurationInMinutes, XC_Segment__c, XC_LegalEntity__c, XC_StatusReasonFormula__c, PostalCode, XC_WorkTypeLabel__c, State, WorkOrderNumber, Status, createdDate, XC_AssignedPartner__c, XC_Conga_AssetProductName__c, XC_WorkTypeCategory__c, ' + 
                                '(SELECT Id, Status, XC_Check_Final_Status__c, DueDate FROM ServiceAppointments)' +
                                'FROM WorkOrder ' +
                                'WHERE XC_AssignedPartner__c = :idAssignedPartner AND ParentWorkOrderId = null AND (Status = :labelAssigned OR Status = :labelOnHold) ';
                if(isOutOfDateFilter) {
                    query += ' AND XC_OutOfDate__c = true';
                } else {
                    query += ' AND XC_OutOfDate__c = false';
                }
                if(!listZipCodeSelected.isEmpty()) {
                    query += ' AND PostalCode IN :listZipCodeSelected';
                }
                if(!listWorkTypeSelected.isEmpty()) {
                    query += ' AND XC_WorkTypeLabel__c IN :listWorkTypeSelected';
                }
                query += ' ORDER BY PostalCode, XC_WorkTypeLabel__c ';
                if(initialLimitedFilter) {
                    query += ' LIMIT ' + cutoff;
                }
                listWorkOrder = Database.query(query);
            }            
        } else {
            listWorkOrder = new List<WorkOrder>([
                SELECT Id, DurationInMinutes, XC_Segment__c, XC_LegalEntity__c, XC_StatusReasonFormula__c, PostalCode, XC_WorkTypeLabel__c, State, WorkOrderNumber, Status, createdDate, XC_AssignedPartner__c, XC_Conga_AssetProductName__c, XC_WorkTypeCategory__c, 
                    (SELECT Id, Status, XC_Check_Final_Status__c, DueDate FROM ServiceAppointments)
                FROM WorkOrder 
                WHERE XC_AssignedPartner__c = :idAssignedPartner AND ParentWorkOrderId = null AND (Status = :Label.XC_CL_WorkOrder_Assigned OR Status = :Label.XC_CL_OnHold) AND XC_OutOfDate__c =:isOutOfDateFilter
            ]);
        }
        Set<String> setWorkType = new Set<String>();
        Set<String> setZipCode = new Set<String>();
        Set<String> setStatus = new Set<String>();
        Set<String> setProvinces = new Set<String>();
        Set<String> setStatusReason = new Set<String>();
        resultWrapper.listWorkOrder = listWorkOrder; 
        for(WorkOrder workOrder : resultWrapper.listWorkOrder) {
            if(workOrder.PostalCode != null) {
                setZipCode.add(workOrder.PostalCode);
            } 
            if(workOrder.XC_WorkTypeLabel__c != null) { 
                setWorkType.add(workOrder.XC_WorkTypeLabel__c);
            }
            if(workOrder.Status != null) {
                setStatus.add(workOrder.Status);
            }
            if(workOrder.XC_StatusReasonFormula__c != null) {
                setStatusReason.add(workOrder.XC_StatusReasonFormula__c);
            }
            if(workOrder.State != null) {
                setProvinces.add(workOrder.State.toLowerCase().capitalize());
            }
            if(!resultWrapper.mapProvinceListZipcode.containsKey(workOrder.State)) {
                resultWrapper.mapProvinceListZipcode.put(workOrder.State, new List<OptionCheckboxWrapper>());
            }
            resultWrapper.mapProvinceListZipcode.get(workOrder.State).add(new OptionCheckboxWrapper(workOrder.PostalCode, workOrder.PostalCode));
        }

        for(String workTypeName : setWorkType) {
            resultWrapper.listWorkType.add(new OptionCheckboxWrapper(workTypeName,workTypeName));
        }
        for(String zipCode : setZipCode) {
            resultWrapper.listZipCode.add(new OptionCheckboxWrapper(zipCode,zipCode));
        }
        for(String status : setStatus) {
            resultWrapper.listStatus.add(new OptionCheckboxWrapper(status,status));
        }
        for(String statusReason : setStatusReason) {
            resultWrapper.listStatusReason.add(new OptionCheckboxWrapper(statusReason,statusReason));
        }
        for(String status : setProvinces) {
            resultWrapper.listProvinces.add(new OptionCheckboxWrapper(status,status));
        }

        if(resultWrapper.listWorkOrder.size() > cutoff) {
            resultWrapper.initialFilterRequired = true;
            resultWrapper.countWorkOrder = resultWrapper.listWorkOrder.size();
            resultWrapper.check = true;
        }

        return resultWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/04/2019
     * @description Method for populating ResultWrapper (to view Logs)
     * @param dirtyData - Boolean
     * @return wrapper - ResultWrapper
    */
    @AuraEnabled
    public static ResultWrapper populateWrapperResult(Boolean dirtyData) {
        ResultWrapper wrapper = new ResultWrapper();
        if(!Schema.sObjectType.ListView.isAccessible()){
            wrapper.resultMessage = Label.XC_CL_InsufficientPrivileges;
            wrapper.success = false;
            return wrapper;
        }
        wrapper.success = true;
        wrapper.listViews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'XC_MassiveAssignmentWorkOrderLog__c' and Name='All'];
        wrapper.dirtyData = dirtyData;
        return wrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 10/04/2019
     * @description Method to check and assign Work Order to destination Partner
     * @param mapAssignString - String
     * @param listWorkOrder - List<WorkOrder>
     * @return wrapper - ResultWrapper
    */
    @AuraEnabled
    public static ResultWrapper assignPartnerToWorkOrder(String mapAssignString, List<WorkOrder> listWorkOrder) {
        ResultWrapper wrapper = new ResultWrapper();
        if(String.isBlank(mapAssignString)) {
            wrapper.success = false;
            wrapper.resultMessage = 'Impossible to read input';
            return wrapper; 
        }

        Savepoint savePoint = Database.setSavepoint();
        try {
            Map<String,Object> mapAssign = (Map<String, Object>) JSON.deserializeUntyped(mapAssignString); 
            String originPartner = (String) mapAssign.get('originPartner');
            String destinationPartner = (String) mapAssign.get('destinationPartner');
            Boolean updateDueDate = (Boolean) mapAssign.get('updateDueDate');
            Boolean outOfDate = (Boolean) mapAssign.get('outOfDate');
            String comments = (String) mapAssign.get('comments');
            Boolean skipCheckCoverage = (Boolean) mapAssign.get('checkCoverage');
            Boolean massiveMood = (Boolean) mapAssign.get('moodAllWo');
            Boolean assignToPartner = (Boolean) mapAssign.get('assignToPartner');

            Boolean dirtyData = false;
            if(!massiveMood) {
                // For selective option:
                List<WorkOrder> listIds = listWorkOrder;
                listWorkOrder = new List<WorkOrder>([
                    SELECT Id, DurationInMinutes, ServiceTerritoryId, XC_EarliestStartPermitted__c, XC_Segment__c, XC_LegalEntity__c, XC_StatusReasonFormula__c, PostalCode, XC_WorkTypeLabel__c, State, WorkOrderNumber, Status, createdDate, XC_AssignedPartner__c, XC_Conga_AssetProductName__c, XC_WorkTypeCategory__c, Country, City, Street, Latitude, Longitude,
                        (SELECT Id, Status, XC_Check_Final_Status__c 
                        FROM ServiceAppointments)
                    FROM WorkOrder
                    WHERE Id IN :listIds
                ]);

                // To create SA for new WO
                List<WorkOrder> listNewWo = new List<WorkOrder>();  // List for Work Order with Status=New
                for(WorkOrder wo : listWorkOrder) {
                    if(wo.Status == Label.XC_CL_WorkOrder_New || wo.Status == Label.XC_CL_ServiceAppointment_OnHold || wo.Status == Label.XC_CL_WorkOrder_Assigned) 
					{
                        if(wo.ServiceAppointments.isEmpty()) {
                            listNewWo.add(wo);
                        }
                        else {
                            Boolean createSa = true;
                            for(ServiceAppointment sa : wo.ServiceAppointments) {
                                if(!sa.XC_Check_Final_Status__c) {
                                    createSa = false;
                                    break;
                                }
                            }
                            if(createSa) {
                                listNewWo.add(wo);
                            }
                        }
                    } 
                }
                if(!listNewWo.isEmpty()) {
                    // Create new Service Appointment
                    List<ServiceAppointment> listSaToInsert = new List<ServiceAppointment>();
                    for(WorkOrder wo : listNewWo) {
                        ServiceAppointment sa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);
                        DateTime startTime = String.isNotBlank(String.valueOf(wo.XC_EarliestStartPermitted__c)) ? wo.XC_EarliestStartPermitted__c : Datetime.now();
                        sa.EarliestStartTime = startTime;
                        sa.DueDate = XC_UTIL_Schedule_D.getDueDate(sa.EarliestStartTime, null);
                        sa.SchedStartTime = startTime;
                        sa.SchedEndTime = startTime.addMinutes(Integer.valueOf(wo.DurationInMinutes));
                        listSaToInsert.add(sa);
                    }
                    List<XC_UTIL_Sobject.WrapperResult> listWrSa = XC_UTIL_Sobject.insertListRecords(listSaToInsert);
                    if(!XC_UTIL_Sobject.checkDMLResults(listWrSa)) {
                        wrapper.success = false;
                        wrapper.resultMessage = listWrSa[0].errorMessage;
                        Database.rollback(savePoint);
                        return wrapper;
                    }
                }

                // Run batch;
                if(assignToPartner) {
                    // For Selective Option and Assign To Partner:
                    XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper();
                    autoscheduleWrapper.listIdWorkOrderAssignToPartner = XC_UTIL_Sobject.getIds(listWorkOrder);
                    autoscheduleWrapper.destinationPartner = destinationPartner;
                    autoscheduleWrapper.originPartner = originPartner;
                    autoscheduleWrapper.updateDueDate = updateDueDate;
                    autoscheduleWrapper.outOfDate = outOfDate;
                    autoscheduleWrapper.skipCheckCoverage = skipCheckCoverage;
                    if(String.isNotBlank(comments)) {
                        autoscheduleWrapper.comments = comments;
                    }
                    Database.executeBatch(new XC_SC012_MassiveWoPartner(autoscheduleWrapper), 100);
                }
                else {
                    // For Selective Option and Assign To Tech:
                    XC_SC012_MassiveWoTech.AutoScheduleTechWrapper autoScheduleTechWrapper = new XC_SC012_MassiveWoTech.AutoScheduleTechWrapper();
                    autoScheduleTechWrapper.originPartner = originPartner;
                    autoScheduleTechWrapper.destinationPartner = destinationPartner;
                    autoScheduleTechWrapper.updateDueDate = updateDueDate;
                    autoScheduleTechWrapper.outOfDate = outOfDate;
                    autoScheduleTechWrapper.listIdWorkOrderAssignToTechnician = XC_UTIL_Sobject.getIds(listWorkOrder);
                    autoScheduleTechWrapper.comments = comments;
                    autoScheduleTechWrapper.skipCheckCoverage = skipCheckCoverage;
                    Database.executeBatch(new XC_SC012_MassiveWoTech(autoScheduleTechWrapper), 1);
                }
            } else {
                // For Massive Option:
                // For selective option:
                List<WorkOrder> listWoQueried = new List<WorkOrder>([
                    SELECT Id, DurationInMinutes, ServiceTerritoryId, XC_EarliestStartPermitted__c, XC_Segment__c, XC_LegalEntity__c, XC_StatusReasonFormula__c, PostalCode, XC_WorkTypeLabel__c, State, WorkOrderNumber, Status, createdDate, XC_AssignedPartner__c, XC_Conga_AssetProductName__c, XC_WorkTypeCategory__c, Country, City, Street, Latitude, Longitude,
                        (SELECT Id, Status, XC_Check_Final_Status__c, DueDate 
                        FROM ServiceAppointments)
                    FROM WorkOrder
                    WHERE Id IN :listWorkOrder
                ]);
                List<WorkOrder> listWorkOrderWithAllData = new List<WorkOrder>();

                List<WorkOrder> listNewWo = new List<WorkOrder>(); 
                List<String> listSaIdCreated = new List<String>();
                for(WorkOrder wo : listWoQueried) {
                    if(wo.Status == Label.XC_CL_WorkOrder_New || wo.Status == Label.XC_CL_ServiceAppointment_OnHold) {
                        if(wo.ServiceAppointments.isEmpty()) {
                            listNewWo.add(wo);
                        }
                        else {
                            Boolean createSa = true;
                            for(ServiceAppointment sa : wo.ServiceAppointments) {
                                if(!sa.XC_Check_Final_Status__c) {
                                    createSa = false;
                                    break;
                                }
                            }
                            if(createSa) {
                                listNewWo.add(wo);
                            }
                        }
                    } 
                }
                if(!listNewWo.isEmpty()) {
                    // Create new Service Appointment
                    List<ServiceAppointment> listSaToInsert = new List<ServiceAppointment>();
                    for(WorkOrder wo : listNewWo) {
                        ServiceAppointment sa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(wo);
                        DateTime startTime = String.isNotBlank(String.valueOf(wo.XC_EarliestStartPermitted__c)) ? wo.XC_EarliestStartPermitted__c : Datetime.now();
                        sa.EarliestStartTime = startTime;
                        sa.DueDate = XC_UTIL_Schedule_D.getDueDate(sa.EarliestStartTime, null);
                        sa.SchedStartTime = startTime;
                        sa.SchedEndTime = startTime.addMinutes(Integer.valueOf(wo.DurationInMinutes));
                        listSaToInsert.add(sa);
                    }
                    List<XC_UTIL_Sobject.WrapperResult> listWrSa = XC_UTIL_Sobject.insertListRecords(listSaToInsert);
                    if(!XC_UTIL_Sobject.checkDMLResults(listWrSa)) {
                        wrapper.success = false;
                        wrapper.resultMessage = listWrSa[0].errorMessage;
                        Database.rollback(savePoint);
                        return wrapper;
                    } else {
                        for(XC_UTIL_Sobject.WrapperResult wrsa : listWrSa) {
                            if(String.isNotBlank(wrsa.recordId)) {
                                listSaIdCreated.add(wrsa.recordId);
                            }
                        }
                    }
                }

                for(WorkOrder wo : listWorkOrder) {
                    if(String.isNotBlank(wo.XC_WorkTypeLabel__c) && String.isNotBlank(wo.XC_Segment__c) && String.isNotBlank(wo.XC_LegalEntity__c)) {
                        listWorkOrderWithAllData.add(wo);
                    } else {
                        dirtyData = true;
                    }
                }

                SplitWorkOrderWrapper splitWorkOrdersWrapper = splitWorkOrders(listWorkOrderWithAllData);
                XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper autoscheduleWrapper = new XC_SC012_MassiveWoPartner.AutoSchedulePartnerWrapper();
                List<String> allWorkOrderId = new List<String>(); // List used to store all workorders [DDP 13-07-2021]
                allWorkOrderId.addAll(splitWorkOrdersWrapper.listIdWorkOrderWithouthAssignPartner);
                allWorkOrderId.addAll(splitWorkOrdersWrapper.listIdWorkOrderWithAssignPartner);
                autoscheduleWrapper.listIdWorkOrderAssignToTechnician = new List<String>();//splitWorkOrdersWrapper.listIdWorkOrderWithouthAssignPartner;
                autoscheduleWrapper.listIdWorkOrderAssignToPartner = allWorkOrderId;//splitWorkOrdersWrapper.listIdWorkOrderWithAssignPartner;
                autoscheduleWrapper.destinationPartner = destinationPartner;
                autoscheduleWrapper.originPartner = originPartner;
                autoscheduleWrapper.updateDueDate = updateDueDate;
                autoscheduleWrapper.outOfDate = outOfDate;
                autoscheduleWrapper.listSaCreated = listSaIdCreated;
                autoscheduleWrapper.skipCheckCoverage = false;
                if(String.isNotBlank(comments)) {
                    autoscheduleWrapper.comments = comments;
                }
                Database.executeBatch(new XC_SC012_MassiveWoPartner(autoscheduleWrapper), 100);
            }
            wrapper = populateWrapperResult(dirtyData);
        } catch(Exception e) {
            wrapper.success = false;
            wrapper.resultMessage = e.getMessage();
            Database.rollback(savePoint);
        }
        return wrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 10/04/2019
     * @description Method to check and assign Work Order to destination Partner
     * @param strfromlex - String
     * @return List<WorkOrder>
    */
    @AuraEnabled
    public static List<WorkOrder> uploadFileCsv(String strfromlex) {
        List<UploadWrapper> dataList = (List<UploadWrapper>) JSON.deserialize(strfromlex, List<UploadWrapper>.class);
        List<String> listWorkOrderNumbers = new List<String>();
        for(UploadWrapper uw : dataList) {
            listWorkOrderNumbers.add(uw.WorkOrderNumber);
        }
        return new List<WorkOrder>([
            SELECT Id, DurationInMinutes, XC_Segment__c, XC_LegalEntity__c, XC_StatusReasonFormula__c, PostalCode, XC_WorkTypeLabel__c, State, WorkOrderNumber, Status, createdDate, XC_AssignedPartner__c, XC_Conga_AssetProductName__c, XC_WorkTypeCategory__c,
                (SELECT Id, Status, XC_Check_Final_Status__c, DueDate FROM ServiceAppointments) 
            FROM WorkOrder 
            WHERE WorkOrderNumber IN :listWorkOrderNumbers
        ]);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 11/04/2019
     * @description Method to split work order for Partner/Tech
     * @param listWorkOrder - List Work Order
     * @return SplitWorkOrderWrapper
    */
    public static SplitWorkOrderWrapper splitWorkOrders(List<WorkOrder> listWorkOrder) {
        XC_LCC106_MassiveAssignmentWorkOrder.SplitWorkOrderWrapper wr = new XC_LCC106_MassiveAssignmentWorkOrder.SplitWorkOrderWrapper();
        List<String> listNameWorkType = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_WorkTypeLabel__c');
        List<String> listSegment = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_Segment__c');
        List<String> listLegalEntity = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_LegalEntity__c');
        List<WorkType> listWorkType = new List<WorkType>([
            SELECT Name, XC_Segment__c, XC_LegalEntity__c, XC_AssignToPartner__c 
            FROM WorkType 
            WHERE Name IN :listNameWorkType AND XC_Segment__c IN :listSegment AND XC_LegalEntity__c IN :listLegalEntity
        ]);
        Map<String,Boolean> mapNameIsAssignPartnerWorkType = new Map<String,Boolean>();
        for(WorkType wt: listWorkType) {
            mapNameIsAssignPartnerWorkType.put(wt.Name.toUpperCase()+wt.XC_Segment__c.toUpperCase()+wt.XC_LegalEntity__c.toUpperCase(), wt.XC_AssignToPartner__c);
        }
        for(WorkOrder workOrder : listWorkOrder) {
            Boolean checkValue = mapNameIsAssignPartnerWorkType.containsKey(workOrder.XC_WorkTypeLabel__c.toUpperCase()+workOrder.XC_Segment__c.toUpperCase()+workOrder.XC_LegalEntity__c.toUpperCase());
            if(checkValue && !mapNameIsAssignPartnerWorkType.get(workOrder.XC_WorkTypeLabel__c.toUpperCase()+workOrder.XC_Segment__c.toUpperCase()+workOrder.XC_LegalEntity__c.toUpperCase())) {
                wr.listIdWorkOrderWithouthAssignPartner.add(workOrder.Id);
            } else {
                wr.listIdWorkOrderWithAssignPartner.add(workOrder.Id);
            }
        }
        return wr;
    }

}
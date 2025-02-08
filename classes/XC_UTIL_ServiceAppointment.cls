/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 02/10/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ServiceAppointment – Util class for Service Appointment methods
*/ 

public without sharing class XC_UTIL_ServiceAppointment { 
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ServiceAppointment');
    /**
    *@description
    */
    public class ServiceAppointmentDefaultValues{
        public Map<String, Integer> mapCountryDaysAfterDeliveryDate;
        public Map<String, Integer> mapCountryDaysForRepairDueDate;
        public Map<String, Integer> mapCountryMonthOrDayForSecondMaintenance;
        public Map<String, String> mapCountryMonthOrDay;
    } 
    
    /**
    * @author Roberta Cossiga rcossiga@deloitte.it & Roberta Porrega roberta.porrega@nttdata.com & Chiara Turco cturco@deloitte.it
    * @description 
    **/
    
    public class WrapperMaintenanceDates {
        public Integer NumberDaysDueDateMaintenance = 45;
        public Integer NumberDaysEarliestMaintenance = -45;
        public Integer NumberMonthDueDateSecondPlannedMaintenance = 0;
        public String DaysOrMonthForDueDate = Label.XC_CL_Days;
    }
    
    /**
    * @author Simone Trenta - strenta@deloitte.it
    * @description wrapper class for ServiceAppointment
    **/
    public class ServiceAppointmentWrapper{
         
        public String AppointmentNumber; //AppointmentNumber
        public String Status; //Status 
        public String Subject; //Subject
        public String Description; //Description
        public DateTime EarliestStartPermitted; //EarliestStartTime
        public DateTime DueDate; //DueDate
        public DateTime ArrivalWindowStart; //ArrivalWindowStartTime
        public DateTime ArrivalWindowEnd; //ArrivalWindowEndTime
        public DateTime ScheduledStart; //SchedStartTime
        public DateTime ScheduledEnd; //SchedEndTime
        public Decimal Duration; //Duration
        public String DurationType; //DurationType
        public DateTime ActualStart; //ActualStartTime
        public DateTime ActualEnd; //ActualEndTime
        public Decimal ActualDurationMinutes; //ActualDuration 
        public String GanttLabel; //FSL__GanttLabel__c
        public Boolean InJeopardy; //FSL__InJeopardy__c
        public Boolean Emergency; //FSL__Emergency__c
        public Boolean Pinned; //FSL__Pinned__c
        public String InJeopardyReason; //FSL__InJeopardyReason__c
        public String GanttColor; //FSL__GanttColor__c
        public Boolean IsMultiDay; //FSL__IsMultiDay__c
        public String Street; 
        public String PostalCode; 
        public String City; 
        public String State;  
        public string Country;
        public String WorkOrderID;
        public String ServiceAppointmentID;
        public DateTime TimeSlotBegin;
        public DateTime StartDate;
        public DateTime TimeSlotFinish;
        public String AccountID;
        public String UniqueID;
        public String WorkType;
        public String OpportunityID;
        public String LeadID;
        public String InternalSLRGeolocation;
        
        public String CheckLocationStart;
        public String CheckLocationEnd;
        public String LongitudeStart;
        public String LongitudeEnd;
        public String LatitudeStart;
        public String LatitudeEnd;

        public String StatusReason;
        
        public Boolean AssignToMe;
        public Boolean BookNow;

        public String CreatedDate;
    }

/** 
* @author 
* @date
* @description 
* @param listWorkOrder
*/  
    public static void createServiceAppointmentsFromWorkOrders(List<WorkOrder> listWorkOrder){
        List<ServiceAppointment> listServiceAppointmentToInsert = new List<ServiceAppointment>();
        for(WorkOrder wo : listWorkOrder){
            ServiceAppointment sa = populateServiceAppointmentFromWorkOrder(wo);
            sa.FSL__Auto_Schedule__c = true; 
            listServiceAppointmentToInsert.add(sa);
        }
        XC_UTIL_Sobject.insertListRecords(listServiceAppointmentToInsert);//fix pmd SS 16/04/19 from -> insert listServiceAppointmentToInsert;
    }
    
    /** 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @description Method to return a Service Appointment record with data incoming from a Work Order.
    **/
        
        /*public static ServiceAppointment populateServiceAppointmentFromWorkOrder(WorkOrder wo){ 
    ServiceAppointment servApp = new ServiceAppointment();
    servApp.ParentRecordId = wo.Id;
    populateAddressFieldsFromWorkOrder(servApp,wo);
    return servApp;
    }*/
        
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @description Method to populate a Service Appointment record with data incoming from a Work Order.
    * @param sa
    * @param wo
    */
    public static void populateAddressFieldsFromWorkOrder(ServiceAppointment sa, WorkOrder wo){ 
        sa.Country = wo.Country;
        sa.State = wo.State;
        sa.City = wo.City;
        sa.PostalCode = wo.PostalCode;
        sa.Street = wo.Street;
        sa.Latitude = wo.Latitude;
        sa.Longitude = wo.Longitude;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date 10/03/2020
    * @description Method to populate Address Field for a Service Appointment from a Work Order
    * @param sa - ServiceAppointment
    * @param wo - WorkOrder
    */
    public static void populateAddressFields(ServiceAppointment sa, WorkOrder wo){ 
        sa.Country = wo.Country;
        sa.State = wo.State;
        sa.City = wo.City;
        sa.PostalCode = wo.PostalCode;
        //sa.Street = (String.isNotBlank(wo.XC_Address__r.XC_StreetTypeText__c) && String.isNotBlank(wo.XC_Address__r.XC_StreetNumber__c)) ? wo.XC_Address__r.XC_StreetTypeText__c + ' ' + wo.Street.toLowerCase().capitalize() + ' ' + wo.XC_Address__r.XC_StreetNumber__c : '';
        sa.Street = wo.Street;
        sa.Latitude = wo.Latitude;
        sa.Longitude = wo.Longitude;
    }
    
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @description Method to populate a Service Appointment record with data incoming from a Work Order.
    * @param wo
    * @return ServiceAppointment
    **/
    public static ServiceAppointment populateServiceAppointmentFromWorkOrder(WorkOrder wo){  
        ServiceAppointment servapp = new ServiceAppointment();
        servApp.ParentRecordId = wo.Id; 
        servapp.ServiceTerritoryId = wo.ServiceTerritoryId; 
        XC_UTIL_ServiceAppointment.populateAddressFieldsFromWorkOrder(servapp, wo); 
        return servapp;
    }   
    
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
    * @description Method to check the validity of Range Tume on the service appointment for closing the related work order line item
    * @param saList
    * @return boolean
    **/
    public static Boolean checkRangeTimeOnServiceAppointment(List<ServiceAppointment> saList){ 
        Boolean success = false;
        for (ServiceAppointment sa : saList) {
            if(sa.SchedStartTime!= null){
                
                Decimal millisecondsBetweenStart = sa.SchedStartTime.getTime() - DateTime.now().getTime();
                //Convert differnce between DateTime from ms in hours
                Decimal timeBetweenStart = millisecondsBetweenStart / 3600000;
                //Absoulte value;
                Decimal absTimeBetweenStart = math.abs(timeBetweenStart);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@DIFFERE ' + absTimeBetweenStart);
                if(absTimeBetweenStart > 2) {
                    
                    success = false;
                } else {   
                    success = true;
                } 
            }
            else {
                success = false;
            }
        }
        return success;   
    }
    
    
    /**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date 12/02/2019
* @description From a Map of ServiceAppointment, it retrives a Map with associations  between ServiceAppointment ID and WorkOrder, evalueted on AccountId and ContactId fields.
* @return Map<Id,WorkOrder>
* @param serviceAppointments
*/
    public static Map<Id,WorkOrder> retriveWOAccountContactInfo(List<ServiceAppointment> serviceAppointments){
        Map<Id,WorkOrder> result = new Map<Id,WorkOrder>();
        
        //Search of associated WO Id
        List<Id> woIdList = new List<Id>();
        for(ServiceAppointment sa : serviceAppointments){
            if(sa.ParentRecordId != null && XC_UTIL_Sobject.getObjectType(sa.ParentRecordId).equals('WorkOrder')){
                woIdList.add(sa.ParentRecordId);
            }
        }
        if(woIdList.isEmpty()){
            return result;
        }
        
        //Retrive data of associated WO
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([ SELECT Id, AccountId, ContactId FROM WorkOrder WHERE Id IN: woIdList]);
        
        for(ServiceAppointment sa : serviceAppointments){
            if(sa.ParentRecordId != null && XC_UTIL_Sobject.getObjectType(sa.ParentRecordId).equals('WorkOrder')){
                result.put(sa.Id, woMap.get(sa.ParentRecordId));
            }
        }
        
        return result;
    }
    
/**
* @author
* @date
* @date 
* @description  
* @param listCountries
* @return ServiceAppointmentDefaultValues
*/ 
    public static ServiceAppointmentDefaultValues getDefaultValues(List<String> listCountries){
        ServiceAppointmentDefaultValues wrapper = new ServiceAppointmentDefaultValues();
        List<XC_CM_ServiceAppointment_Default_Value__mdt> serviceAppDefValuesList = new List<XC_CM_ServiceAppointment_Default_Value__mdt>();
        Map<String, Integer> mapCountryDaysAfterDeliveryDate = new Map<String, Integer>();
        Map<String, Integer> mapCountryDaysForRepairDueDate = new Map<String, Integer>();

        mapCountryDaysAfterDeliveryDate.put(null, 2); 
        mapCountryDaysForRepairDueDate.put(null, 30);
        
        if(!listCountries.isEmpty() && Schema.sObjectType.XC_CM_ServiceAppointment_Default_Value__mdt.fields.Id.isAccessible() && Schema.sObjectType.XC_CM_ServiceAppointment_Default_Value__mdt.fields.XC_Country__c.isAccessible() && Schema.sObjectType.XC_CM_ServiceAppointment_Default_Value__mdt.fields.XC_Number_of_Days_for_Delivery_Date__c.isAccessible() && Schema.sObjectType.XC_CM_ServiceAppointment_Default_Value__mdt.fields.XC_Days_For_Repair_Due_Date__c.isAccessible() && Schema.SObjectType.XC_CM_ServiceAppointment_Default_Value__mdt.isAccessible()){
            serviceAppDefValuesList = [SELECT Id,XC_Country__c, XC_Number_of_Days_for_Delivery_Date__c, XC_Days_For_Repair_Due_Date__c
                                       FROM XC_CM_ServiceAppointment_Default_Value__mdt
                                       WHERE XC_Country__c IN: listCountries]; 
        }
        for(XC_CM_ServiceAppointment_Default_Value__mdt serviceAppDefValue : serviceAppDefValuesList){
            mapCountryDaysAfterDeliveryDate.put(serviceAppDefValue.XC_Country__c, (Integer) serviceAppDefValue.XC_Number_of_Days_for_Delivery_Date__c);
            mapCountryDaysForRepairDueDate.put(serviceAppDefValue.XC_Country__c, (Integer) serviceAppDefValue.XC_Days_For_Repair_Due_Date__c);
           
        }
        wrapper.mapCountryDaysAfterDeliveryDate = mapCountryDaysAfterDeliveryDate;
        wrapper.mapCountryDaysForRepairDueDate = mapCountryDaysForRepairDueDate;
        return wrapper;
    }
    

    
    /**
    * @description Method to get dates for Maintenance
    * @param listWorkOrder - List<WorkOrder>
    * @return Map<Id, WrapperMaintenanceDates>
    */  
    public static Map<Id, WrapperMaintenanceDates> getManteinanceDatesForProduct(List<WorkOrder> listWorkOrder){ 
        Map<Id, WrapperMaintenanceDates>  mapManteinanceDatesForProduct = new Map<Id,WrapperMaintenanceDates>();
        Map<String, Integer> mapCountryMonthOrDayForSecondMaintenance = new Map<String, Integer>();
        Map<String, String> mapCountryMonthOrDay = new Map<String, String>();
        List<String> listWoCatalogCat = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_CatalogCategory_Name__c');
        List<String> listWoProductName = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_Product_Name__c');
        listWoCatalogCat.add('DEFAULT');
        listWoProductName.add('DEFAULT');
        Map<Id, XC_CM_PlannedMaintenance_ProductDates__mdt> plannedMaintenanceProductDatesMap = new Map<Id, XC_CM_PlannedMaintenance_ProductDates__mdt>([
            SELECT Id, XC_CatalogCategory_Name__c, XC_ProductName__c, XC_NumberDaysDueDateMaintenance__c, XC_NumberDaysEarliestMaintenance__c, XC_Country__c, XC_MonthOrDayDueDateSecondMainten__c, XC_DaysOrMonth__c
            FROM XC_CM_PlannedMaintenance_ProductDates__mdt
            WHERE (XC_ProductName__c IN :listWoProductName OR XC_ProductName__c = '' OR XC_ProductName__c = 'DEFAULT') AND (XC_CatalogCategory_Name__c IN :listWoProductName OR XC_CatalogCategory_Name__c = 'DEFAULT')
        ]);

        List<WorkOrder> listWorkOrderForDefaultValue = new List<WorkOrder>();
        List<XC_CM_PlannedMaintenance_ProductDates__mdt> plannedMaintenanceProductDates = plannedMaintenanceProductDatesMap.values();
        for(WorkOrder wo : listWorkOrder){
            String prodName = wo.XC_Product_Name__c;
            String catalagCatName = wo.XC_CatalogCategory_Name__c;
            String workOrderCountry = wo.XC_Country__c;
            WrapperMaintenanceDates wr = new WrapperMaintenanceDates();
            Boolean found = false;
            for(XC_CM_PlannedMaintenance_ProductDates__mdt plannedMaintenanceProductDate : plannedMaintenanceProductDates){
                if(plannedMaintenanceProductDate.XC_ProductName__c == prodName && plannedMaintenanceProductDate.XC_Country__c == workOrderCountry){
                    wr.NumberDaysDueDateMaintenance = Integer.valueof(plannedMaintenanceProductDate.XC_NumberDaysDueDateMaintenance__c);
                    wr.NumberDaysEarliestMaintenance = Integer.valueof(plannedMaintenanceProductDate.XC_NumberDaysEarliestMaintenance__c);
                    wr.NumberMonthDueDateSecondPlannedMaintenance = Integer.valueOf(plannedMaintenanceProductDate.XC_MonthOrDayDueDateSecondMainten__c);
                    wr.DaysOrMonthForDueDate = plannedMaintenanceProductDate.XC_DaysOrMonth__c;
                    found = true;
                    break;
                }else if (String.isBlank(plannedMaintenanceProductDate.XC_ProductName__c) && (plannedMaintenanceProductDate.XC_CatalogCategory_Name__c == catalagCatName) && plannedMaintenanceProductDate.XC_Country__c == workOrderCountry){
                    wr.NumberDaysDueDateMaintenance = Integer.valueof(plannedMaintenanceProductDate.XC_NumberDaysDueDateMaintenance__c);
                    wr.NumberDaysEarliestMaintenance = Integer.valueof(plannedMaintenanceProductDate.XC_NumberDaysEarliestMaintenance__c);
                    wr.NumberMonthDueDateSecondPlannedMaintenance = Integer.valueOf(plannedMaintenanceProductDate.XC_MonthOrDayDueDateSecondMainten__c);
                    wr.DaysOrMonthForDueDate = plannedMaintenanceProductDate.XC_DaysOrMonth__c;
                    found = true;
                    break;
                }
            }
            if(!found) {
                listWorkOrderForDefaultValue.add(wo);
            }
            mapManteinanceDatesForProduct.put(wo.Id, wr);
        }
        // To set default values:
        if(!listWorkOrderForDefaultValue.isEmpty()) {
            for(WorkOrder wo : listWorkOrderForDefaultValue) {
                WrapperMaintenanceDates wr = new WrapperMaintenanceDates();
                for(XC_CM_PlannedMaintenance_ProductDates__mdt plannedMaintenanceProductDate : plannedMaintenanceProductDates) {
                    if(plannedMaintenanceProductDate.XC_ProductName__c == 'DEFAULT' && plannedMaintenanceProductDate.XC_Country__c == wo.XC_Country__c){
                        wr.NumberDaysDueDateMaintenance = Integer.valueof(plannedMaintenanceProductDate.XC_NumberDaysDueDateMaintenance__c);
                        wr.NumberDaysEarliestMaintenance = Integer.valueof(plannedMaintenanceProductDate.XC_NumberDaysEarliestMaintenance__c);
                        wr.NumberMonthDueDateSecondPlannedMaintenance = Integer.valueOf(plannedMaintenanceProductDate.XC_MonthOrDayDueDateSecondMainten__c);
                        wr.DaysOrMonthForDueDate = plannedMaintenanceProductDate.XC_DaysOrMonth__c;
                        break;
                    }
                }
                mapManteinanceDatesForProduct.put(wo.Id, wr);
            }
        }
        return mapManteinanceDatesForProduct;
    }
    
    
    /**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date 12/02/2019
* @description return the current active SA for the WO in input.
* @return ServiceAppointment
* @param workOrderId
*/
    public static ServiceAppointment getActiveSAFromWo(String workOrderId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In getActiveSAFromWo con WO: '+workOrderId);
        ServiceAppointment s = new ServiceAppointment();
        WorkOrder wo = [SELECT Id, (SELECT Id,Status FROM ServiceAppointments) 
                        FROM WorkOrder WHERE id=: workOrderId LIMIT 1];
        List<ServiceAppointment> sAppointmentList = wo.ServiceAppointments;
        if(!sAppointmentList.isEmpty()){
            for(ServiceAppointment sa : sAppointmentList){
                if(sa.Status=='In Progress' || sa.Status=='Scheduled'|| sa.Status=='On Hold' || sa.Status=='None' || sa.Status=='Dispatched'){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Found Active SA: '+sa);
                    return sa;
                }
            }
        }
        return s;
        
    }
    
    
    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @date 05/09/2019
     * @description return the mapping of WO input Id and the current active SA.
     * @param workOrderIds
     * @return Map<Id,ServiceAppointment>
     */
    public static Map<Id,ServiceAppointment> getDataActiveSAFromWo(Set<Id> workOrderIds){
        Map<Id,ServiceAppointment> result = new Map<Id,ServiceAppointment>();
        if(workOrderIds==null || workOrderIds.isEmpty()){
            return result;
        }
        Map<Id,WorkOrder> woData = new Map<Id,WorkOrder>(
            [ SELECT Id, 
                     (SELECT Id,Status, XC_SubStatus__c, XC_StatusReason__c FROM ServiceAppointments) 
                FROM WorkOrder 
                WHERE Id IN: workOrderIds ]);
        
        for(WorkOrder wo : woData.values()){
            for(ServiceAppointment sa : wo.ServiceAppointments){
                if(sa.Status=='In Progress' || sa.Status=='Scheduled'|| sa.Status=='On Hold' || sa.Status=='None' || sa.Status=='Dispatched'){
                    result.put(wo.Id,sa); 
                    break;
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@getDataActiveSAFromWo result=' + result);
        return result;
    }
}
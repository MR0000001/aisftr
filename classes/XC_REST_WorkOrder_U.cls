/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 28/12/2018 
* @description REST Utility Class for WorkOrder Interface 
*/   
public without sharing class XC_REST_WorkOrder_U {      
    
    /**
     * @description Sets the fields of a workorder by a wrapper
     *
     * @param param the wrapper 
     * @param wout the work order to set
     * @return the work order
     */
    public static workOrder createWorkOrder(XC_UTIL_WorkOrder.WorkOrderWrapper param, WorkOrder wout){ 

        Map<String, Object> mapField = new Map<String, Object>{ 
            'WorkTypeId' => param.WorkType, 
            'Priority' => param.Priority, 
            'OwnerId' => param.Owner,
            'ParentWorkOrderId' => (string.isBlank(param.ParentWorkOrderNumber)) ? null : XC_REST_WorkOrder_U_D.getWorkOrderByNumber(param.ParentWorkOrderNumber)[0].id, 
            'ContactId' => param.ContactID, 
            'AccountId' => param.AccountID,
            'XC_Opportunity__c' => param.OpportunityID, 
            'CaseId' => param.CaseID, 
            'XC_Configuration__c' => param.OrderID,
            'XC_Configuration_Item__c' => param.OrderItemID,
            'XC_Refusing_Reason__c' => param.RefusingReason,
            'XC_MissingQuoteReason__c' => param.MissingQuoteReason,
            'XC_Reason_Cannot_Complete__c' => param.CannotCompleteReason,
            'Subject' => param.WorkOrderSubject, 
            'Description' => param.WorkOrderDescription,
            'XC_InstallationDate__c' => param.InstallationDate,
            'XC_DeliveryId__c' => param.DeliveryID,
            'XC_DeliveryDate__c' => param.DeliveryDate,
            'XC_DeliveryType__c' => param.DeliveryType,
            'XC_EffectiveDeliveryDate__c' => param.EffectiveDeliveryDate,
            'XC_SerialNumber__c' => param.DeliverySerialNumber,
            'XC_EffectiveProductAvailabilityDate__c' => param.EffectiveProductAvailabilityDate,
            'XC_ProductReservationResult__c' => param.ProductReservationResult,
            'XC_Delivery_Tracking_URL__c' => param.DeliveryTracking,
            'XC_Courier_Partner__c' => param.CourierPartner,
            'XC_TypeOfSite__c' => param.SiteInspectionType,
            'Status' => param.Status,
            'XC_SiteOK__c' => param.SiteOk,
            'XC_GasAnalyzer__c' => param.SiteGasAnalyzer,
            'XC_ElectricityMeasurement__c' => param.SiteElectricityMeasurement, 
            'PostalCode' => param.PostalCode, 
            'City' => param.City, 
            'Country' => param.Country, 
            'State' => param.State, 
            'Street' => param.Street,
            'AssetId' => param.AssetID,
            'XC_StatusReason__c' => param.StatusReason,
            'XC_Comments__c' => param.Comments,
            'XC_LegalEntity__c' => param.LegalEntity,
            'XC_ReturnComments__c' => param.ReturnComments,
            'XC_AwareOfBenefits__c' => param.AwareOfBenefits,
            'XC_WelcomePackReceived__c' => param.WelcomePackReceived,
            'XC_ExternalPartner__c' => param.ExternalPartner,
            'XC_PartnerSparePartsCost__c' => param.PartnerSparePartsCost,
            'XC_PartnerWorkCost__c' => param.PartnerWorkCost,
            'XC_ActualEndDate__c' => param.ActualEndDate,
            'XC_ExtraCost__c' => param.PartnerExtraCostInvoice,
            'XC_Result__c' => param.Result,
            'XC_MaxWallboxPower__c' => param.MaxWallboxPower
        };
        
        for (String field : mapField.keySet()) {
            if ( mapField.get(field)!=null && mapField.get(field)+'' != '') {
                wout.put(field, mapField.get(field));
            }    
        }

        return wout;
    } 
    
    /**
     * @description Update or create a list of work order line items
     *
     * @param itemsWrapper a list of work order line item wrapper 
     * @param woid the parent work order id 
     * @param items a list of work order line item  
     * @return a list of work order line item 
     */ 
    public static list<workOrderLineItem> updateOrCreateWorkOrderLine(list<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> itemsWrapper, id woid, List<WorkOrderLineItem> items){
        list<workOrderLineItem> res = new list<workOrderLineItem>();
        if(itemsWrapper==null){
            return res;
        }
        Map<String, WorkOrderLineItem> numberWli = new Map<String, WorkOrderLineItem>();
        for (WorkOrderLineItem wi : items) {
            numberWli.put(wi.LineItemNumber, wi);
        }
        for(XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wliWrapper : itemsWrapper) {
            WorkOrderLineItem wlout;
            if(String.isBlank(wliWrapper.WorkOrderLineItemNumber)) {    
                wlout = XC_UTIL_WorkOrderLineItem.createWorkOrderLineItemByWrapper(wliWrapper, woid, new WorkOrderLineItem()); 

            } else {
                wlout = XC_UTIL_WorkOrderLineItem.createWorkOrderLineItemByWrapper(wliWrapper, null, numberWli.get(wliWrapper.WorkOrderLineItemNumber));

            }

            res.add(wlout);
        }
        
        return res; 
    }

    /**
     * @description Create a list of work order line items
     *
     * @param items a list of work order line item wrapper 
     * @param woid the parent work order id 
     * @return a list of work order line item 
     */ 
    public static list<workOrderLineItem> createWorkOrderLine(list<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> items, id woid){
        list<workOrderLineItem> res = new list<workOrderLineItem>();
        
        if (items != null) {
            for(XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wliWrapper : items) {
            
                WorkOrderLineItem wlout = XC_UTIL_WorkOrderLineItem.createWorkOrderLineItemByWrapper(wliWrapper, woid, new WorkOrderLineItem()); 

                res.add(wlout);
            }
        }
         
        return res; 
    }

    /**
     * @description Update or create a list of service appointments
     * @param saListWrapper 
     * @param woId
     * @param saList   
     * @return List<ServiceAppointment>
     */ 
    public static List<ServiceAppointment> updateOrCreateServiceAppointment(List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper> saListWrapper, id woId,  List<ServiceAppointment> saList){
        List<serviceAppointment> res = new List<serviceappointment>();
        if(saListWrapper==null){
            return res; 
        }
        Map<String, ServiceAppointment> idServApp = new Map<String, ServiceAppointment>();
        Map<String, ServiceAppointment> numberServApp = new Map<String, ServiceAppointment>();
        for (ServiceAppointment sa : saList) {
            numberServApp.put(sa.AppointmentNumber, sa);
            idServApp.put(sa.id, sa); 
        }
         
        for(XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa : saListWrapper) {
            ServiceAppointment saout = new ServiceAppointment();  

            if(String.isBlank(sa.AppointmentNumber) && String.isBlank(sa.ServiceAppointmentID)) {   
                saout.parentRecordId = woId;  
                saout = setServiceAppointmentFields(saout, sa); 

            } else if(String.isNotBlank(sa.AppointmentNumber)) {
                saout = setServiceAppointmentFields(numberServApp.get(sa.AppointmentNumber), sa);

            } else {
                saout = setServiceAppointmentFields(idServApp.get(sa.ServiceAppointmentID), sa);

            }
            
            res.add(saout);
        }
        return res;
    } 
    
    /**
    * @description Create a list of service appointments
    *
    * @param saList a list of service appointment wrapper 
    * @param id the parent work order id 
    * @return a list of service appointment
    */ 
    public static list<ServiceAppointment> createServiceAppointment(List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper> saList, id id){
        list<serviceAppointment> res = new list<serviceappointment>();

        if (saList != null) {
            for(XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa : saList) {
                ServiceAppointment saout = new ServiceAppointment();   
                saout.parentRecordId = id;
                
                saout = setServiceAppointmentFields(saout, sa);
                
                res.add(saout);
            }
        }

        return res;
    } 

    private static ServiceAppointment setServiceAppointmentFields(ServiceAppointment sa, XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper param){
        
        Map<String, Object> mapField = new Map<String, Object>{ 
                    //'AppointmentNumber' => param.AppointmentNumber, 
                    'Status' => param.Status, 
                    'Subject' => param.Subject, 
                    'Description' => param.Description,
                    'EarliestStartTime' => param.EarliestStartPermitted, 
                    'DueDate' => param.DueDate, 
                    'ArrivalWindowStartTime' => param.ArrivalWindowStart,
                    'ArrivalWindowEndTime' => param.ArrivalWindowEnd, 
                    'Duration' => param.Duration, 
                    'DurationType' => param.DurationType,
                    'ActualStartTime' => param.ActualStart,
                    'ActualEndTime' => param.ActualEnd,
                    'ActualDuration' => param.ActualDurationMinutes,
                    'FSL__GanttLabel__c' => param.GanttLabel,
                    'FSL__InJeopardy__c' => param.InJeopardy,
                    'FSL__Emergency__c' => param.Emergency,
                    'FSL__Pinned__c' => param.Pinned,
                    'XC_Reason_Cannot_Complete__c' => param.InJeopardyReason,
                    'FSL__GanttColor__c' => param.GanttColor,
                    'FSL__IsMultiDay__c' => param.IsMultiDay, 
                    'PostalCode' => param.PostalCode, 
                    'City' => param.City, 
                    'Country' => param.Country, 
                    'State' => param.State, 
                    'Street' => param.Street,
                    //GDB 07/01/2020
                    'XC_CheckLocationStart__c' => param.CheckLocationStart,
                    'XC_CheckLocationEnd__c' => param.CheckLocationEnd,
                    'XC_LatitudeStart__c' => param.LatitudeStart,
                    'XC_LatitudeEnd__c' => param.LatitudeEnd,
                    'XC_LongitudeStart__c' => param.LongitudeStart,
                    'XC_LongitudeEnd__c' => param.LongitudeEnd,
                    'XC_StatusReason__c' => param.StatusReason
                    };

        for (String field : mapField.keySet()) {
            if ( mapField.get(field)!=null && mapField.get(field)+'' != '') {
                sa.put(field, mapField.get(field));
            }    
        }

        return sa;
    }  

    /**
    * @description Create a list of work order line item wrapper
    *
    * @param woliList a list of work order line item
    * @return a list of work order line item wrapper
    */ 
    public static List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> getWoliWrapperList(List<WorkOrderLineItem> woliList){
        List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> res = new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();

        if(woliList==null || woliList.isEmpty()) {
            return new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        }

        list<Id> woliIdList = new list<Id>();
        for (workOrderLineItem a : woliList) { 
            woliIdList.add(a.Id);
        }

        Map<Id, WorkOrderLineItem> wliWithNumb = new Map<Id, WorkOrderLineItem>([SELECT LineItemNumber FROM WorkOrderLineItem WHERE Id in: woliIdList]);
        for(workorderlineitem wli : woliList) {
            if(wliWithNumb.containsKey(wli.id)) {
                XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper newWl = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
                
                newWl.WorkOrderLineItemNumber = wliWithNumb.get(wli.id).LineItemNumber;
                newWl.ActivityName = wli.XC_ActivityName__c;
                newWl.Status = wli.status;

                newWl.ActionDescription = wli.XC_ActionDescription__c;
                newWl.MacroBlocNumber = (Integer)wli.XC_MacroBlocNumber__c; 
                newWl.MacroBlocName = wli.XC_MacroBlocName__c;
                newWl.ActivityNumber = (Integer)wli.XC_ActivityNumber__c;
                newWl.Description = wli.Description;
                newWl.CompletionMode = wli.XC_CompletionMode__c;
                newWl.ObservationsOne = wli.XC_ObservationsOne__c;
                newWl.ObservationsTWO = wli.XC_ObservationsTWO__c;
                newWl.TechnicianResponse = wli.XC_TechnicianResponseForConfiguration__c;
                newWl.DefectRefer = wli.XC_DefectRefer__c;
                newWl.DefectType = wli.XC_DefectType__c;
                newWl.MeasurementValueOne = wli.XC_MeasurementValueOne__c;
                newWl.MeasurementUnitOne = wli.XC_MeasurementUnitOne__c;
                newWl.MeasurementValueTwo = wli.XC_MeasurementValueTwo__c;
                newWl.MeasurementUnitTwo = wli.XC_MeasurementUnitTwo__c;
                newWl.RecordTypeID = wli.RecordTypeId;
                newWl.AssetID = wli.AssetId;

                res.add(newWl);
            }
        }


        return res;
    }

    /**
    * @description Create a list of service appointment wrapper
    *
    * @param servAppList a list of service appointment
    * @return a list of service appointment wrapper
    */ 
    public static List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper> getServAppWrapperList(List<ServiceAppointment> servAppList){
        List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper> res = new List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();

        if(servAppList==null || servAppList.isEmpty()) { 
            return new List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
        } 

        list<Id> saIdList = new list<Id>();
        for (ServiceAppointment s : servAppList){
            saIdList.add(s.Id);
        }
        
        Map <id, ServiceAppointment> saWithNumb = new Map<id, ServiceAppointment>([SELECT AppointmentNumber FROM ServiceAppointment WHERE Id in: saIdList]);
        for(serviceAppointment sa : servAppList) {
            if(saWithNumb.containsKey(sa.id)) {
                XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper newSa = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();

                newSa.AppointmentNumber = saWithNumb.get(sa.id).AppointmentNumber;
                newSa.Description = sa.description;
                newSa.EarliestStartPermitted = sa.EarliestStartTime;
                newSa.DueDate = sa.DueDate;
                newSa.status = sa.status;
                newSa.ServiceAppointmentID = sa.id;

                res.add(newSa); 
            }
        } 
 
        return res;
    }

}
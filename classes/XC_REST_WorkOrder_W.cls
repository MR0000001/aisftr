/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 23/04/2019 
* @description REST Utility Class for WorkOrder Interface - contain all the wrapper classes
*/   

public with sharing class XC_REST_WorkOrder_W {

    /**
     * @description wrapper class for Post and Put   
     */
    public class Wrapper {
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result;
        
        /** The Work order. */ 
        public XC_UTIL_WorkOrder.WorkOrderWrapper WorkOrder; 
        
        /** The Appointment slots. */
        public List<WrapperSlot> AppointmentSlots;
        
        /** The Book appointment. */
        public XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper BookAppointment;
        
        /**
         * @description instantiate the wrapper
         */ 
        public Wrapper(){ 
            Result = new XC_UTIL_Integration.Result();  
        }
    }

    /**
     * @description wrapper class for Get request and response
     */
    public class GetResultWrapper {  
        
        /** The Result. */
        public XC_UTIL_Integration.Result Result;
        
        /** The Work order. */
        public List<XC_UTIL_WorkOrder.WorkOrderWrapper> WorkOrder; 
        
        /** The Appointment slots. */ 
        public List<WrapperSlot> AppointmentSlots;
        
        /** The Read appointment slots. */
        public GetAppointmentWrapper ReadAppointmentSlots; 
        
        /**
         * @description instantiate the wrapper
         */
        public GetResultWrapper(){   
            Result = new XC_UTIL_Integration.Result();
        }
    }

    /**
     * @description wrapper class for GetAppointment request 
     */
    public class GetAppointmentWrapper { 
        
        /** The Work order number. */
        public string WorkOrderNumber;

        /** The Work order number. */
        public string WorkOrderID;
        
        /** The Service appointment ID. */ 
        public string ServiceAppointmentID;
        
        /** The Lead ID. */
        public string LeadID;
        
        /** The Opportunity ID. */
        public string OpportunityID;
        
        /** The Account ID. */
        public string AccountID; //deleted
    }
    
    /**
     * @description wrapper class for slot
     */
    public class WrapperSlot {
        
        /** The Start time. */
        public datetime StartTime;
        
        /** The Time slot start. */
        public datetime TimeSlotStart;
        
        /** The Time slot end. */
        public datetime TimeSlotEnd;
        
    }

    /** 
     * @description Creates the wrapper slot.
     * @param slots the slot
     * @param sTime the start time
     * @return  List<XC_REST_WorkOrder_W.WrapperSlot>
     */
    public static List<XC_REST_WorkOrder_W.WrapperSlot> createWrapperSlot(List<XC_UTIL_Schedule.Slot> slots, DateTime sTime, DateTime dueDate){ 
        List<XC_REST_WorkOrder_W.WrapperSlot> res = new List<XC_REST_WorkOrder_W.WrapperSlot>();

        for(XC_UTIL_Schedule.Slot s : slots){
            XC_REST_WorkOrder_W.WrapperSlot ws = new XC_REST_WorkOrder_W.WrapperSlot();
            ws.StartTime = sTime;  
            ws.TimeSlotStart=s.Interval.start;
            ws.TimeSlotEnd=s.Interval.finish; 
            if(ws.TimeSlotStart>Datetime.now() && ws.TimeSlotStart<dueDate){ 
                res.add(ws); 
            }
        }

        return res; 
    }

    /**
     * @description Creates the work order wrapper. 
     *
     * @param wo the wo
     * @param items the items
     * @param servApps the serv apps
     * @return the x C UTI L work order. work order wrapper
     */
    public static XC_UTIL_WorkOrder.WorkOrderWrapper createWorkOrderWrapper(WorkOrder wo, List<workOrderLineItem> items, List<ServiceAppointment> servApps, Map<Id,Map<String,Integer>> documentMap, String clientSystem){
        XC_UTIL_WorkOrder.WorkOrderWrapper res = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        
        res.WorkOrderID = wo.id;
        res.WorkOrderNumber = wo.WorkOrderNumber;
        res.WorkType = wo.XC_WorkTypeCategory__c!=null ? wo.XC_WorkTypeCategory__c.replace('&','and') : null;
        res.ServiceType = wo.XC_WorkTypeLabel__c; 
        res.Status = wo.Status;
        res.Priority = wo.Priority ;
        res.Owner = wo.OwnerId ;
        res.ParentWorkOrderNumber = wo.ParentWorkOrder.WorkOrderNumber ;
        res.ContactID = wo.ContactId ;
        res.AccountID = wo.AccountId ;
        res.OpportunityID = wo.XC_Opportunity__c ;
        res.CaseID = wo.CaseId ;
        res.RefusingReason = wo.XC_Refusing_Reason__c ;
        res.MissingQuoteReason = wo.XC_MissingQuoteReason__c ;
        res.CannotCompleteReason = wo.XC_Reason_Cannot_Complete__c ;
        res.WorkOrderSubject = wo.Subject ;
        res.WorkOrderDescription = wo.Description ;
        res.InstallationDate = wo.XC_InstallationDate__c ;
        res.DeliveryID = wo.XC_DeliveryId__c ;
        res.DeliveryDate = wo.XC_DeliveryDate__c ;
        res.DeliveryType = wo.XC_DeliveryType__c ;
        res.EffectiveDeliveryDate = wo.XC_EffectiveDeliveryDate__c ;
        res.EffectiveProductAvailabilityDate = wo.XC_EffectiveProductAvailabilityDate__c ;
        res.ProductReservationResult = wo.XC_ProductReservationResult__c ;
        res.DeliveryTracking = wo.XC_Delivery_Tracking_URL__c ;
        res.CourierPartner = wo.XC_Courier_Partner__c ;
        res.SiteInspectionType = wo.XC_TypeOfSite__c ; 
        res.SiteOk = wo.XC_SiteOK__c ;
        res.SiteGasAnalyzer = wo.XC_GasAnalyzer__c ;
        res.SiteElectricityMeasurement = wo.XC_ElectricityMeasurement__c ;
        res.Street = wo.street;
        res.PostalCode = wo.postalcode;
        res.City = wo.city;
        res.State = wo.state;
        res.country = wo.country;
        res.DeliverySerialNumber = wo.XC_SerialNumber__c; 
        res.OrderID = wo.XC_Configuration__c; 
        res.OrderItemID = wo.XC_Configuration_Item__c;
        res.AccountMainPhonePrefix = wo.Account.XC_MainPhonePrefix__c;
        res.AccountMainPhone = wo.Account.XC_AccountMainPhone__c; 
        res.AccountPhonePrefix = wo.Account.XC_AccountPhonePrefix__c;
        res.AccountPhone = wo.Account.XC_AccountPhone__c;
        res.AccountLastName = wo.Account.XC_LastName__c;
        res.AccountFirstName = wo.Account.XC_FirstName__c;
        res.AccountEmail = wo.Account.PrimaryEmail__c;
        res.AssetID = wo.AssetId; 
        res.LeadId = wo.XC_Lead__r.id;
        res.LeadName = wo.XC_Lead__r.Name;
        res.LeadCondominiumName = wo.XC_Lead__r.XC_CondominiumName__c;
        res.LeadEmail = wo.XC_Lead__r.XC_EmailCustom__c;
        res.LeadMainPhonePrefix = wo.XC_Lead__r.XC_PhonePrefix__c;
        res.LeadMainPhone = wo.XC_Lead__r.XC_LeadPhone__c;
        res.LeadPhonePrefix = wo.XC_Lead__r.XC_MobilePrefix__c;
        res.LeadPhone = wo.XC_Lead__r.XC_LeadMobile__c;
        res.AssetName = wo.Asset.Name;
        res.AssetBrand = wo.Asset.XC_Configuration_Item__r.NE__CatalogItem__r.XC_Brand__c;
        res.AssetModel = wo.Asset.XC_Model__c;
        res.AssetCatalogCategory = wo.Asset.XC_CatalogCategory__c;
        res.StatusReason = wo.XC_StatusReason__c;
        res.Comments = wo.XC_Comments__c;
        res.AffectedEquipment = wo.XC_AffectedEquipment__c;
        res.AffectedInstallation = wo.XC_AffectedInstallation__c;
        res.ReturnComments = wo.XC_ReturnComments__c;
        res.UrgentRepair = wo.XC_Urgent_Repair__c != null ? String.valueOf(wo.XC_Urgent_Repair__c) : null;
        res.AwareOfBenefits = wo.XC_AwareOfBenefits__c;
        res.WelcomePackReceived  = wo.XC_WelcomePackReceived__c;
        res.ExternalPartner = wo.XC_ExternalPartner__c;
        res.Result = wo.XC_Result__c;
        res.MaxWallboxPower = wo.XC_MaxWallboxPower__c;
        if(clientSystem != null && clientSystem.equals('XInstaller')){
            res.LegalEntity = String.isNotBlank(wo.XC_LegalEntity__c) ? wo.XC_LegalEntity__c : '';
        }
        
        if(items!=null) {
            res.WorkOrderLineItem = new list<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
            for (WorkOrderLineItem i : items) {
                res.WorkOrderLineItem.add(createItemWrapper(i)); 
            }
        }

        if(servApps!=null) {
            res.ServiceAppointment = new list<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
            for (ServiceAppointment s : servApps) {
                res.ServiceAppointment.add(createServAppWrapper(s));
            }
        }

        if(!wo.ChildWorkOrders.isEmpty()){
            res.WorkOrderChild = new List<XC_UTIL_WorkOrder.WorkOrderChildWrapper>();
            for (WorkOrder w : wo.ChildWorkOrders) {
                XC_UTIL_WorkOrder.WorkOrderChildWrapper ch = new XC_UTIL_WorkOrder.WorkOrderChildWrapper();
                ch.WorkOrderChildID = w.id;
                res.WorkOrderChild.add(ch);
            }
        }

        if(!documentMap.isEmpty()){
            res.Document = new List<XC_UTIL_WorkOrder.Document>();
            for(String docType : documentMap.get(wo.id).keySet()){
                XC_UTIL_WorkOrder.Document doc = new XC_UTIL_WorkOrder.Document();
                doc.DocumentType = docType;
                doc.Quantity = documentMap.get(wo.id).get(docType);
                res.Document.add(doc);
            }
        }

        
        return res;  
    }

    private static XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper createItemWrapper(WorkOrderLineItem i){
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper res = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        
        res.WorkOrderLineItemNumber = i.LineItemNumber ;
        res.Status = i.Status ;
        res.ActionStart = i.XC_Action_Start__c ;
        res.ActionEnd = i.XC_Action_End__c ;
        res.ActivityName = i.XC_ActivityName__c ;
        res.Required = i.XC_Required__c ;
        res.Operation = i.XC_Operation__c;
        res.Description = i.Description;
        res.CompletionMode = i.XC_CompletionMode__c;
        res.TechnicianResponse = i.XC_TechnicianResponseForConfiguration__c;
        res.DefectType = i.XC_DefectType__c;
        res.DefectRefer = i.XC_DefectRefer__c;

        res.ActionDescription = i.XC_ActionDescription__c;
        res.MacroBlocNumber = (integer)i.XC_MacroBlocNumber__c;
        res.MacroBlocName = i.XC_MacroBlocName__c;
        res.ActivityNumber = (integer)i.XC_ActivityNumber__c;
        res.ObservationsOne = i.XC_ObservationsOne__c;
        res.ObservationsTWO = i.XC_ObservationsTWO__c;
        res.MeasurementValueOne = i.XC_MeasurementValueOne__c;
        res.MeasurementUnitOne = i.XC_MeasurementUnitOne__c;
        res.MeasurementValueTwo = i.XC_MeasurementValueTwo__c;
        res.MeasurementUnitTwo = i.XC_MeasurementUnitTwo__c;
        res.RecordTypeID = i.RecordTypeId; 
        res.AssetID = i.AssetId;

        res.AssetName = i.Asset.Name;
        res.AssetBrand = i.Asset.XC_Configuration_Item__r.NE__CatalogItem__r.XC_Brand__c;
        res.AssetModel = i.Asset.XC_Model__c;
        res.AssetCatalogCategory = i.Asset.XC_CatalogCategory__c;

        res.Range = i.XC_Range__c;
        
        res.WorkOrderLineItemId = i.Id;
        
        return res;
    }

    private static XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper createServAppWrapper(ServiceAppointment s){
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper res = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        
        //res.AccountID=s.AccountID;  
        //res.OpportunityID=s.Opportunity__c;
        //res.WorkOrderID=s.ParentRecordID; 
        res.ServiceAppointmentID=s.id;
        //res.WorkType=s.WorkTypeId;  
        res.ScheduledStart = s.SchedStartTime ;
        res.ScheduledEnd = s.SchedEndTime ;

        res.AppointmentNumber = s.AppointmentNumber;
        res.Status = s.Status ;
        res.Subject = s.Subject ;
        res.Description = s.Description ;
        res.EarliestStartPermitted = s.EarliestStartTime ;
        res.DueDate = s.DueDate ;
        res.ArrivalWindowStart = s.ArrivalWindowStartTime ;
        res.ArrivalWindowEnd = s.ArrivalWindowEndTime ;
        res.Duration = s.Duration ;
        res.DurationType = s.DurationType ; 
        res.ActualStart = s.ActualStartTime ;
        res.ActualEnd = s.ActualEndTime ;
        res.ActualDurationMinutes = s.ActualDuration ;
        res.GanttLabel = s.FSL__GanttLabel__c ;
        res.InJeopardy = s.FSL__InJeopardy__c ;
        res.Emergency = s.FSL__Emergency__c ;
        res.Pinned = s.FSL__Pinned__c ; 
        res.InJeopardyReason = s.XC_Reason_Cannot_Complete__c ;
        res.GanttColor = s.FSL__GanttColor__c ;
        res.IsMultiDay = s.FSL__IsMultiDay__c ; 

        if(s.FSL__InternalSLRGeolocation__c!=null){
            res.InternalSLRGeolocation = s.FSL__InternalSLRGeolocation__c.getLatitude()+'; '+s.FSL__InternalSLRGeolocation__c.getLongitude();
        }
        
        res.street = s.street;
        res.city = s.city;
        res.state = s.state;
        res.country = s.country;
        res.postalcode = s.postalcode;

        //GDB 07/01/2020
        res.CheckLocationStart = s.XC_CheckLocationStart__c;
        res.CheckLocationEnd = s.XC_CheckLocationEnd__c;
        res.LatitudeStart = s.XC_LatitudeStart__c;
        res.LatitudeEnd = s.XC_LatitudeEnd__c;
        res.LongitudeStart = s.XC_LongitudeStart__c;
        res.LongitudeEnd = s.XC_LongitudeEnd__c;

        res.StatusReason = s.XC_StatusReason__c;
        
        res.CreatedDate = s.CreatedDate+'';

        return res;
    }
    
    /**
     * @description Gets the book app wrapper.
     *
     * @param wrReq the request
     * @param bookingResult the booking result
     * @return the book app wrapper
     */
    public static XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper getBookAppWrapper(XC_REST_WorkOrder_W.Wrapper wrReq, XC_UTIL_Schedule.BookingResult bookingResult){

        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper bookAppointment = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();

        bookAppointment.UniqueID = wrReq.bookAppointment.UniqueID;
        bookAppointment.LeadID = wrReq.BookAppointment.LeadID;
        bookAppointment.AccountID = wrReq.bookAppointment.AccountID;
        bookAppointment.OpportunityID = wrReq.bookAppointment.OpportunityID;
        bookAppointment.WorkOrderID = wrReq.bookAppointment.WorkOrderID;
        bookAppointment.WorkType = wrReq.bookAppointment.WorkType;
        bookAppointment.ServiceAppointmentID = bookingResult.scheduledAppointmentId;
        bookAppointment.StartDate = wrReq.bookAppointment.StartDate;
        bookAppointment.TimeSlotBegin = wrReq.bookAppointment.TimeSlotBegin; 
        bookAppointment.TimeSlotFinish = wrReq.bookAppointment.TimeSlotFinish;

        bookAppointment.WorkOrderID = bookingResult.workOrderId;
        bookAppointment.WorkType = bookingResult.workTypeName;
        bookAppointment.AccountID = bookingResult.accountId;

        if (bookingResult.Address != null) {
            bookAppointment.Street = bookingResult.Address.Street;
            bookAppointment.PostalCode = bookingResult.Address.PostalCode;
            bookAppointment.City = bookingResult.Address.City;
            bookAppointment.State = bookingResult.Address.State;
            bookAppointment.Country = bookingResult.Address.Country;   
        }

        return bookAppointment;
    } 

}
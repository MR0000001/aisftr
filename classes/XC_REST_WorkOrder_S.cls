/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 23/04/2019 
* @description REST Utility Class for WorkOrder Interface - contain all the methods to call util schedule 
*/    
public with sharing class XC_REST_WorkOrder_S { 
 
    private static XC_UTIL_Schedule.BookingResult callScheduleByServApp(String appId, XC_UTIL_Schedule_W.ScheduleRequestWrapper wrapperReq){
        XC_UTIL_Schedule_W.AddressWrapper addr = new XC_UTIL_Schedule_W.AddressWrapper();
        XC_UTIL_Schedule.BookingResult res = new XC_UTIL_Schedule.BookingResult();  //test test
            
        Map<id, ServiceAppointment> saMap = new Map<id, ServiceAppointment>([ select id, city, street, country, state, postalcode, XC_Country__c                
                                                from ServiceAppointment 
                                                where id =: appId]);
            
        if (saMap.values().size()==0){
            res.IntegrationError = 'ERROR. ServiceAppointment not found';
            res.success = false;
            return res;  
        }  
                        
        ServiceAppointment sa = saMap.values()[0];

        addr.city = sa.city;
        addr.country = sa.country;
        addr.postalCode = sa.postalcode;
        addr.street = sa.street;
        addr.state = sa.state;

        wrapperReq.addressWr = addr;

        wrapperReq.country = sa.XC_Country__c ;
        wrapperReq.workType = 'Commercial Visit';
        wrapperReq.existingServiceAppointmentId = appId;   
            
        system.debug('@@ input wrapper for schedule appointment: '+ json.serialize(wrapperReq, true));

        if (wrapperReq.operation == XC_UTIL_Schedule.GETSLOTS){ 
            res = XC_UTIL_Schedule.getSlots(wrapperReq);

        } else {
            res = XC_UTIL_Schedule.scheduleAppointment(wrapperReq);
        }

        res.Address = addr;

        return res;
    }

    private static XC_UTIL_Schedule.BookingResult callScheduleByLead(String leadId, XC_UTIL_Schedule_W.ScheduleRequestWrapper wrapperReq){
        XC_UTIL_Schedule_W.AddressWrapper addr = new XC_UTIL_Schedule_W.AddressWrapper();
        XC_UTIL_Schedule.BookingResult res = new XC_UTIL_Schedule.BookingResult(); 

        Map<id, Lead> lMap = new Map<id, Lead>([ 
            SELECT id, XC_City__c, XC_Address__c, XC_Country__c, XC_Province__c, XC_ZipCode__c, Country__c, XC_LeadAddress__c, XC_StreetType__c, XC_StreetNumber__c,             
            XC_LeadAddress__r.XC_StreetNumber__c, XC_LeadAddress__r.XC_StreetTypeText__c, XC_LeadAddress__r.XC_Address__c
            FROM Lead 
            WHERE id =: leadId]);
            
        if (lMap.values().size()==0){
            res.IntegrationError = 'ERROR. Lead not found';
            res.success = false;
            return res;
        }
            
        Lead l = lMap.values()[0];
            
        addr.city = l.XC_City__c;
        addr.country = l.XC_Country__c;
        addr.postalCode = l.XC_ZipCode__c;
        addr.street = l.XC_LeadAddress__r.XC_Address__c;
        addr.state = l.XC_Province__c;
        addr.addressId = l.XC_LeadAddress__c;

        wrapperReq.addressWr = addr;
        wrapperReq.country = l.Country__c;
        wrapperReq.workType = 'Commercial Visit';
        wrapperReq.LeadID = leadId; 

        system.debug('@@ input wrapper for schedule appointment: '+ json.serialize(wrapperReq, true));

        if (wrapperReq.operation == XC_UTIL_Schedule.GETSLOTS){ 
            res = XC_UTIL_Schedule.getSlots(wrapperReq);

        } else {
            res = XC_UTIL_Schedule.scheduleAppointment(wrapperReq);
        }

        res.Address = addr;

        return res;
    }

    private static XC_UTIL_Schedule.BookingResult callScheduleByWorkOrder(string woId, string woNumb, XC_UTIL_Schedule_W.ScheduleRequestWrapper wrapperReq){
        XC_UTIL_Schedule_W.AddressWrapper addr = new XC_UTIL_Schedule_W.AddressWrapper();
        XC_UTIL_Schedule.BookingResult res = new XC_UTIL_Schedule.BookingResult(); 

        Map<id, WorkOrder> woMap;

        if (String.isNotBlank(woId)) {
            woMap = new Map<id, WorkOrder>([    select id, WorkOrderNumber, city, street, country, state, postalcode, XC_Country__c, XC_WorkTypeCategory__c , XC_Address__c                     
                        from WorkOrder 
                        where id =: woId]);

        } else {
            woMap = new Map<id, WorkOrder>([    select id, WorkOrderNumber, city, street, country, state, postalcode, XC_Country__c, XC_WorkTypeCategory__c , XC_Address__c                     
                        from WorkOrder 
                        where WorkOrderNumber =: woNumb]);
        }
            
        if (woMap.values().size()==0){
            res.IntegrationError = 'ERROR. WorkOrder not found'; 
            res.success = false;
            return res;
        }
        
        WorkOrder w = woMap.values()[0];
            
        addr.city = w.city;
        addr.country = w.country;
        addr.postalCode = w.postalcode; 
        addr.street = w.street;
        addr.state = w.state;
        addr.addressId = w.XC_Address__c;

        wrapperReq.addressWr = addr;
        wrapperReq.country = w.XC_Country__c;
        wrapperReq.workType = w.XC_WorkTypeCategory__c;
        wrapperReq.existingWorkOrderId = w.id; 

        system.debug('@@ input wrapper for schedule appointment: '+ json.serialize(wrapperReq, true));

        if (wrapperReq.operation == XC_UTIL_Schedule.GETSLOTS){ 
            res = XC_UTIL_Schedule.getSlots(wrapperReq);
            res.workOrderNumber = w.WorkOrderNumber;

        } else {
            res = XC_UTIL_Schedule.scheduleAppointment(wrapperReq);
        }

        res.Address = addr;

        return res;
    }

    private static XC_UTIL_Schedule.BookingResult callScheduleByOpportunity(string oppId, XC_UTIL_Schedule_W.ScheduleRequestWrapper wrapperReq){
        XC_UTIL_Schedule_W.AddressWrapper addr = new XC_UTIL_Schedule_W.AddressWrapper();
        XC_UTIL_Schedule.BookingResult res = new XC_UTIL_Schedule.BookingResult(); 
           
        Map<id,Opportunity> oppList = new Map<id,Opportunity>([     select id, XC_Address__c, XC_Address__r.XC_PostalCode__c, XC_Address__r.XC_City__c, XC_Address__r.Name, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_AddressCountry__c, XC_Country__c
                                            from Opportunity 
                                            where id =: oppId]);
            
        if (oppList.values().size()==0){
            res.IntegrationError = 'ERROR. Opportunity not found';
            res.success = false;
            return res;
        }
            
        Opportunity o = oppList.values()[0];
            
        addr.city = o.XC_Address__r.XC_City__c;
        addr.country = o.XC_Address__r.XC_AddressCountry__c;
        addr.postalCode = o.XC_Address__r.XC_PostalCode__c;
        addr.street = o.XC_Address__r.Name; 
        addr.state = o.XC_Address__r.XC_AddressProvince__c;
        addr.addressId = o.XC_Address__c;

        wrapperReq.addressWr = addr;
        wrapperReq.country = o.XC_Country__c;
        wrapperReq.workType = 'Commercial Visit';
        wrapperReq.opportunityId = oppID;

        system.debug('@@ input wrapper for schedule appointment: '+ json.serialize(wrapperReq, true));
        if (wrapperReq.operation == XC_UTIL_Schedule.GETSLOTS){ 
            res = XC_UTIL_Schedule.getSlots(wrapperReq);

        } else {
            res = XC_UTIL_Schedule.scheduleAppointment(wrapperReq);
        }

        res.Address = addr;

        return res;
    }
    
    /**
     * @description handle the read slots request
     *
     * @param params the params
     * @return the wrapper response
     */
    public static XC_UTIL_Schedule.BookingResult readSlots(Map<string, string> params){
        XC_UTIL_Schedule_W.ScheduleRequestWrapper wrapperReq = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        XC_UTIL_Schedule.BookingResult res = new XC_UTIL_Schedule.BookingResult(); 

        wrapperReq.operation = XC_UTIL_Schedule.GETSLOTS;
        wrapperReq.action = XC_UTIL_Schedule.NEWAPPOINTMENT;
        wrapperReq.startDate = DateTime.valueOf(params.get('AppointmentSlotDate')+' 00:00:00');  
        
        wrapperReq.assignToMe = (params.get('AssignToMe')=='true');
       
        /* Ricerca per ServiceAppointment */ 
        if (String.isNotBlank(params.get('ServiceAppointmentID'))) {
            wrapperReq.action = XC_UTIL_Schedule.EDITAPPOINTMENT;
            res = callScheduleByServApp(params.get('ServiceAppointmentID'), wrapperReq);
        
        /* Ricerca per Lead */
        } else if (String.isNotBlank(params.get('LeadID'))) {
            res = callScheduleByLead(params.get('LeadID'), wrapperReq);

        /* Ricerca per WorkOrderNumber */
        } else if (String.isNotBlank(params.get('WorkOrderNumber')) || String.isNotBlank(params.get('WorkOrderID'))) {
            res = callScheduleByWorkOrder(params.get('WorkOrderID'), params.get('WorkOrderNumber'), wrapperReq);
            
        /* Ricerca per OpportunityID */
        } else if (String.isNotBlank(params.get('OpportunityID'))) {
            res = callScheduleByOpportunity(params.get('OpportunityID'), wrapperReq);
        }   

        return res; 
    }
    
    /**
     * @description handle the schedule appointment request
     *
     * @param params the params
     * @return the wrapper response
     */
    public static XC_UTIL_Schedule.BookingResult scheduleAppointment(XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper params){
        XC_UTIL_Schedule_W.ScheduleRequestWrapper wrapperReq = new XC_UTIL_Schedule_W.ScheduleRequestWrapper();
        XC_UTIL_Schedule_W.AddressWrapper addr = new XC_UTIL_Schedule_W.AddressWrapper();
        XC_UTIL_Schedule.BookingResult res = new XC_UTIL_Schedule.BookingResult();
        
        wrapperReq.operation = XC_UTIL_Schedule.SCHEDULEAPPOINTMENT; 
        wrapperReq.action = XC_UTIL_Schedule.NEWAPPOINTMENT;
        wrapperReq.startDate = params.StartDate;
        //wrapperReq.startDate = DateTime.newInstance(Integer.valueOf(params.StartDate.year()), Integer.valueOf(params.StartDate.month()), Integer.valueOf(params.StartDate.day()), 0, 0, 0);
        
        /*
        String beg = String.valueOf(params.TimeSlotBegin);
        beg = beg.replace('T', ' ');
        DateTime dt = DateTime.valueofGMT( beg );
        
        wrapperReq.timeslotBegin = dt;
        wrapperReq.timeslotFinish = DateTime.valueof( String.valueOf(params.TimeSlotFinish).replace('T', ' ') );
        
        system.debug('@@@ startdate: '+ wrapperReq.timeslotBegin);
        */

        wrapperReq.timeslotBegin = params.TimeSlotBegin; 
        wrapperReq.timeslotFinish = params.TimeSlotFinish; 
        wrapperReq.bookNow = params.BookNow;
        wrapperReq.assignToMe = params.AssignToMe;
                
        /* Schedulazione per ServiceAppointment */
        if (!String.isBlank(params.ServiceAppointmentID)) {
            wrapperReq.action = XC_UTIL_Schedule.EDITAPPOINTMENT;
            res = callScheduleByServApp(params.ServiceAppointmentID, wrapperReq);
        
        /* Schedulazione per Lead */
        } else if (!String.isBlank(params.LeadID)) {     
            res = callScheduleByLead(params.LeadID, wrapperReq);
        
        /* Schedulazione per WorkOrderNumber */
        } else if (!String.isBlank(params.WorkOrderID)) {   
            res = callScheduleByWorkOrder(params.WorkOrderID, '', wrapperReq);
            
        /* Schedulazione per OpportunityID */
        } else if (!String.isBlank(params.OpportunityID)) {    
            res = callScheduleByOpportunity(params.OpportunityID, wrapperReq);    
        } 
        
        return res;
    } 

}
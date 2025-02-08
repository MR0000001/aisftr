public without sharing class TA_LCC252_AppointmentToBeConfirmed {

    /*public class ServiceAppointmentWrapper {
        @AuraEnabled
        public Id      Id                   {get; set;}
        @AuraEnabled
        public String  formatDueDate        {get; set;}
        @AuraEnabled
        public String  dueTime              {get; set;}
        @AuraEnabled
        public Date    dueDate              {get; set;}
        @AuraEnabled
        public String  formatSchedStartDate {get; set;}
        @AuraEnabled
        public String  formatSchedEndDate   {get; set;}
        @AuraEnabled
        public Date    schedStartDate       {get; set;}
        @AuraEnabled
        public Date    schedEndDate         {get; set;}
        @AuraEnabled
        public String  schedStartTime       {get; set;}
        @AuraEnabled
        public String  schedEndTime         {get; set;}
        @AuraEnabled
        public String  street               {get; set;}
        @AuraEnabled
        public String  city                 {get; set;}
        @AuraEnabled
        public String  address              {get; set;}
        @AuraEnabled
        public String  description          {get; set;}
        @AuraEnabled
        public String  status               {get; set;}
        @AuraEnabled
        public String  duration             {get; set;}
        @AuraEnabled
        public String  durationType         {get; set;}
        @AuraEnabled
        public String  appNumber            {get; set;}
        @AuraEnabled
        public String  type                 {get; set;}
        @AuraEnabled
        public Id      workOrderId          {get; set;}
        @AuraEnabled
        public String  workOrderName        {get; set;}
        @AuraEnabled
        public String  workTypeCategory     {get; set;}
        @AuraEnabled
        public String  workTypeLabel        {get; set;}
        @AuraEnabled
        public Id      customerId           {get; set;}
        @AuraEnabled
        public String  customerName         {get; set;}
        @AuraEnabled
        public String  createdDate          {get; set;}
        @AuraEnabled
        public String  productName          {get; set;}

        public ServiceAppointmentWrapper() {}
    }*/

    @AuraEnabled
    public static String initialize() {
        return TA_UTIL_Appointment.getInfoBag(null, true); 
    }

    /*@AuraEnabled
    public static List<ServiceAppointmentWrapper> initialize() {
        List<ServiceAppointmentWrapper> servAppointmentWrapperList = new List<ServiceAppointmentWrapper>();
        List<ServiceAppointment> servAppointmentList = new List<ServiceAppointment>();

        try {
            List<ServiceResource> serviceResList = [SELECT Id
                                                    FROM ServiceResource
                                                    WHERE RelatedRecordId =: UserInfo.getUserId()];

            if(!serviceResList.isEmpty()) {
                List<AssignedResource> assignedResList = [SELECT Id, ServiceAppointmentId
                                                            FROM AssignedResource
                                                            WHERE ServiceResourceId = :serviceResList[0].Id];

                List<Id> servAppointmentIdList = new List<Id>();
                for(AssignedResource assignedRes : assignedResList) {
                    servAppointmentIdList.add(assignedRes.ServiceAppointmentId);
                }

                servAppointmentList = [SELECT Id,
                                            DueDate,
                                            SchedStartTime,
                                            XC_StatusReason__c,
                                            SchedEndTime,
                                            Street,
                                            Status,
                                            City,
                                            Description,
                                            AccountId,
                                            CreatedDate,
                                            Account.Name,
                                            ParentRecordId,
                                            ParentRecord.Name,
                                            Duration,
                                            XC_WorkTypeCategory__c,
                                            XC_WorkTypeLabel__c,
                                            AppointmentNumber,
                                            DurationType,
                                            XC_NE_ProdName__c //ENXCRM-88
                                        FROM ServiceAppointment
                                        WHERE Id IN :servAppointmentIdList
                                        AND XC_StatusReason__c = 'To be scheduled'
                                        AND Status != 'Completed'
                                        ORDER BY CreatedDate ASC];
            }

            for(ServiceAppointment servApp : servAppointmentList) {
                ServiceAppointmentWrapper servAppWrp = new ServiceAppointmentWrapper();

                if(servApp.DueDate != null) {
                    servAppWrp.formatDueDate = Date.newInstance(servApp.DueDate.year(), servApp.DueDate.month(), servApp.DueDate.day()).format();
                    servAppWrp.dueDate = Date.newInstance(servApp.DueDate.year(), servApp.DueDate.month(), servApp.DueDate.day());
                    servAppWrp.dueTime = String.valueOf(Time.newInstance(servApp.DueDate.hour(), servApp.DueDate.minute(), 0, 0)).substring(0,5);
                }
                
                servAppWrp.formatSchedStartDate = Date.newInstance(servApp.CreatedDate.year(), servApp.CreatedDate.month(), servApp.CreatedDate.day()).format();
                servAppWrp.schedStartDate = Date.newInstance(servApp.CreatedDate.year(), servApp.CreatedDate.month(), servApp.CreatedDate.day());
                servAppWrp.schedStartTime = String.valueOf(Time.newInstance(servApp.CreatedDate.hour(), servApp.CreatedDate.minute(), 0, 0)).substring(0,5);

                if(servApp.SchedEndTime != null) {
                    servAppWrp.formatSchedEndDate = Date.newInstance(servApp.SchedEndTime.year(), servApp.SchedEndTime.month(), servApp.SchedEndTime.day()).format();
                    servAppWrp.schedEndDate = Date.newInstance(servApp.SchedEndTime.year(), servApp.SchedEndTime.month(), servApp.SchedEndTime.day());
                    servAppWrp.schedEndTime = String.valueOf(Time.newInstance(servApp.SchedEndTime.hour(), servApp.SchedEndTime.minute(), 0, 0)).substring(0,5);
                }

                servAppWrp.Id               = servApp.Id;
                servAppWrp.street           = servApp.Street;
                servAppWrp.city             = servApp.City;
                servAppWrp.address          = servApp.Street + ', ' + servApp.City;
                servAppWrp.workOrderId      = servApp.ParentRecordId;
                servAppWrp.workOrderName    = servApp.ParentRecord.Name;
                servAppWrp.customerId       = servApp.AccountId;
                servAppWrp.customerName     = servApp.Account.Name;
                servAppWrp.description      = servApp.Description;
                servAppWrp.status           = servApp.Status;
                servAppWrp.duration         = String.valueOf(servApp.Duration);        
                servAppWrp.appNumber        = servApp.AppointmentNumber;
                servAppWrp.workTypeCategory = servApp.XC_WorkTypeCategory__c;        
                servAppWrp.workTypeLabel    = servApp.XC_WorkTypeLabel__c;
                servAppWrp.durationType     = servApp.DurationType;
                servAppWrp.createdDate      = String.valueOf(Date.newInstance(servApp.CreatedDate.year(), servApp.CreatedDate.month(), servApp.CreatedDate.day())); //ENXCRM-89
                servAppWrp.productName      = servApp.XC_NE_ProdName__c; //ENXCRM-88

                servAppointmentWrapperList.add(servAppWrp);
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC252_AppointmentToBeConfirmed] initialize - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC252_AppointmentToBeConfirmed', 'initialize', errorMessage, 0, errorMessage, null);
        }

        return servAppointmentWrapperList;
    }*/
}
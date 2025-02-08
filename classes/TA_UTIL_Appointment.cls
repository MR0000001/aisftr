public without sharing class TA_UTIL_Appointment {
    public TA_UTIL_Appointment() {}

    public class InfoBag {
        public Id                               contactId           {get;set;}
        public List<ServiceAppointmentWrapper>  serviceAppointment  {get;set;}
        public String                           errorMsg            {get;set;}
        public String                           communityBaseURL    {get;set;}
        public Date                             sysDate             {get;set;}

        public InfoBag() {}
    }

    public class ServiceAppointmentWrapper {
        public Id      Id                       {get; set;}
        public String  formatDueDate            {get; set;}
        public String  dueTime                  {get; set;}
        public Date    dueDate                  {get; set;}
        public String  formatSchedStartDate     {get; set;}
        public String  formatSchedEndDate       {get; set;}
        public Date    schedStartDate           {get; set;}
        public Date    schedEndDate             {get; set;}
        public String  schedStartTime           {get; set;}
        public String  schedEndTime             {get; set;}
        public String  street                   {get; set;}
        public String  city                     {get; set;}
        public String  address                  {get; set;}
        public String  description              {get; set;}
        public String  status                   {get; set;}
        public String  duration                 {get; set;}
        public String  durationType             {get; set;}
        public String  appNumber                {get; set;}
        public String  type                     {get; set;}
        public Id      workOrderId              {get; set;}
        public String  workOrderStatus          {get; set;}
        public String  workOrderName            {get; set;}
        public String  workTypeCategory         {get; set;}
        public String  toLabelWorkTypeCategory  {get; set;}
        public String  workTypeLabel            {get; set;}
        public String  toLabelWorkTypeLabel     {get; set;}
        public Id      customerId               {get; set;}
        public String  customerName             {get; set;}
        public Boolean isToBeScheduled          {get; set;}
        public String  createdDate              {get; set;}
        public String  productName              {get; set;}
        public Boolean woHasChild               {get; set;}
        public List<WorkOrderWrapper> woChilds  {get; set;}
        public String faultType {get; set; } //FIX [20220527AL] - NR2331
        public ServiceAppointmentWrapper() {}
    }

    public class WorkOrderWrapper {
        public Id      workOrderId      {get; set;}
        public String  woNumber         {get; set;}
        public String  woAddress        {get; set;}
        public String  woStatus         {get; set;}
        public String  woProductName    {get; set;}
        public Boolean isMain           {get; set;}
        public List<WorkOrderWrapper> wocSecondary  {get; set;}

        public WorkOrderWrapper() {}

        public WorkOrderWrapper(Id workOrderId, String woNumber, String woAddress, String woStatus, String woProductName, Boolean isMain) {
            this.workOrderId = workOrderId;
            this.woNumber = woNumber;
            this.woAddress = woAddress;
            this.woStatus = woStatus;
            this.woProductName = woProductName;
            this.isMain = isMain;
            this.wocSecondary = new List<WorkOrderWrapper>();
        }
    }

    public static String getInfoBag(Integer rowLimit) {
        return TA_UTIL_Appointment.getInfoBag(rowLimit, false);
    }

    public static String getInfoBag(Integer rowLimit, Boolean toBeScheduled) {
        System.debug('>_> Inside : TA_UTIL_Appointment.getInfoBag');
        System.debug('>_> TA_UTIL_Appointment.getInfoBag param rowLimit : ' + rowLimit);

        InfoBag infoBag = new InfoBag();

        try {
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            infoBag.contactId = currentUser.ContactId;

            List<ServiceResource> serviceResList = [   SELECT Id
                                                            FROM ServiceResource
                                                            WHERE RelatedRecordId =:UserInfo.getUserId()];
        
            if(!serviceResList.isEmpty()) {
                List<AssignedResource> assignedResList = [  SELECT Id, ServiceAppointmentId
                                                            FROM AssignedResource
                                                            WHERE ServiceResourceId = :serviceResList[0].Id];
                if(!assignedResList.isEmpty()) {

                    Set<String> servAppIds = new Set<String>();

                    for(AssignedResource ar : assignedResList) {
                        servAppIds.add(ar.ServiceAppointmentId);
                    }

                    if(!servAppIds.isEmpty()) {
                        List<ServiceAppointment> servAppList = getServiceAppointment(rowLimit, servAppIds, toBeScheduled);
                        Set<String> workOrderIds = new Set<String>();
                        Map<String, WorkOrder> woIdToWorkOrderMap = new Map<String, WorkOrder>();
                        Map<String, List<WorkOrder>> woChildsMap = new Map<String, List<WorkOrder>>();
                        
                        if(!servAppList.isEmpty()) {
                            for(ServiceAppointment servApp : servAppList) {
                                workOrderIds.add(servApp.ParentRecordId);
                            }
                            if(!workOrderIds.isEmpty()) {
                                List<WorkOrder> workOrders = [SELECT Id, Status, XC_Segment__c, WorkOrderNumber, XC_ProductSubType__c, 
                                                                    AccountId, Account.Name, XC_Lead__r.Name, XC_Product_Name__c, Case.XC_FaultType__c,
                                                                    Case.XC_Address__r.Name, AssetId, Asset.Name, ParentWorkOrderId, toLabel(XC_WorkTypeLabel__c) toLabel_XC_WorkTypeLabel__c,
                                                                    (SELECT Id, WorkOrderNumber, Asset.NE__Bundle_element__c, Asset.NE__Bundle_element__r.Name, Asset.NE__Bundle_element__r.XC_MacroCategory__c, XC_Address__r.Name, toLabel(Status), Asset.Name, XC_ProductSubType__c, XC_Conga_AssetProductName__c, Asset.NE__ProdId__r.NE__Part__c	
                                                                    FROM ChildWorkOrders)
                                                                FROM WorkOrder 
                                                                WHERE Id IN :workOrderIds]; //ENXCRM-141 - BGO - 04062021
                                if(!workOrders.isEmpty()) {
                                    for(WorkOrder wo : workOrders) {
                                        woIdToWorkOrderMap.put(wo.Id, wo);

                                        if(String.isBlank(wo.ParentWorkOrderId)) {
                                            if(wo.ChildWorkOrders.size() > 0) {
                                                woChildsMap.put(wo.Id, wo.ChildWorkOrders);
                                            }
                                        }
                                    }  
                                }
                            }
                            System.debug('>_> woIdToWorkOrderMap: ' + woIdToWorkOrderMap);
                            System.debug('>_> woChildsMap: ' + woChildsMap);
                        }

                        infoBag.serviceAppointment = new List<ServiceAppointmentWrapper>();
                        System.debug('servAppList: ' + servAppList);

                        for(ServiceAppointment servApp : servAppList) {

                            ServiceAppointmentWrapper servAppWrp = new ServiceAppointmentWrapper();

                            if(servApp.DueDate != null){
                                servAppWrp.formatDueDate = Date.newInstance(servApp.DueDate.year(), servApp.DueDate.month(), servApp.DueDate.day()).format();
                                servAppWrp.dueDate = Date.newInstance(servApp.DueDate.year(), servApp.DueDate.month(), servApp.DueDate.day());
                                servAppWrp.dueTime = String.valueOf(Time.newInstance(servApp.DueDate.hour(), servApp.DueDate.minute(), 0, 0)).substring(0,5);
                            }

                            if(servApp.SchedStartTime != null && servApp.XC_StatusReason__c != 'To be scheduled'){
                                servAppWrp.formatSchedStartDate = Date.newInstance(servApp.SchedStartTime.year(), servApp.SchedStartTime.month(), servApp.SchedStartTime.day()).format();
                                servAppWrp.schedStartDate = Date.newInstance(servApp.SchedStartTime.year(), servApp.SchedStartTime.month(), servApp.SchedStartTime.day());
                                servAppWrp.schedStartTime = String.valueOf(Time.newInstance(servApp.SchedStartTime.hour(), servApp.SchedStartTime.minute(), 0, 0)).substring(0,5);

                            } else if(servApp.XC_StatusReason__c == 'To be scheduled') {
                                servAppWrp.formatSchedStartDate = servApp.CreatedDate != null ? Date.newInstance(servApp.CreatedDate.year(), servApp.CreatedDate.month(), servApp.CreatedDate.day()).format() : String.valueOf(servApp.ActualEndTime);
                                servAppWrp.schedStartDate = servApp.CreatedDate != null ? Date.newInstance(servApp.CreatedDate.year(), servApp.CreatedDate.month(), servApp.CreatedDate.day()) : Date.newInstance(servApp.ActualEndTime.year(), servApp.ActualEndTime.month(), servApp.ActualEndTime.day());
                                servAppWrp.schedStartTime = servApp.CreatedDate != null ? String.valueOf(Time.newInstance(servApp.CreatedDate.hour(), servApp.CreatedDate.minute(), 0, 0)).substring(0,5) : String.valueOf(servApp.ActualEndTime);
                            }

                            if(servApp.SchedEndTime != null){
                                servAppWrp.formatSchedEndDate = Date.newInstance(servApp.SchedEndTime.year(), servApp.SchedEndTime.month(), servApp.SchedEndTime.day()).format();
                                servAppWrp.schedEndDate = Date.newInstance(servApp.SchedEndTime.year(), servApp.SchedEndTime.month(), servApp.SchedEndTime.day());
                                servAppWrp.schedEndTime = String.valueOf(Time.newInstance(servApp.SchedEndTime.hour(), servApp.SchedEndTime.minute(), 0, 0)).substring(0,5);
                            }

                            servAppWrp.Id                       = servApp.Id;
                            servAppWrp.street                   = servApp.Street;
                            servAppWrp.city                     = servApp.City;
                            servAppWrp.address                  = String.isBlank(woIdToWorkOrderMap.get(servApp.ParentRecordId).Case.XC_Address__r.Name) ? servApp.Street + ', ' + servApp.City : woIdToWorkOrderMap.get(servApp.ParentRecordId).Case.XC_Address__r.Name; //ENXCRM-141 - BGO - 04062021
                            servAppWrp.workOrderId              = servApp.ParentRecordId;
                            servAppWrp.workOrderStatus          = woIdToWorkOrderMap.get(servApp.ParentRecordId).Status;
                            servAppWrp.workOrderName            = woIdToWorkOrderMap.get(servApp.ParentRecordId).WorkOrderNumber;
                            servAppWrp.customerId               = String.isNotBlank(servApp.AccountId) ? servApp.AccountId : woIdToWorkOrderMap.get(servApp.ParentRecordId).AccountId;
                            servAppWrp.customerName             = String.isNotBlank(servApp.Account.Name) ? servApp.Account.Name : String.isNotBlank(woIdToWorkOrderMap.get(servApp.ParentRecordId).Account.Name) ? woIdToWorkOrderMap.get(servApp.ParentRecordId).Account.Name : woIdToWorkOrderMap.get(servApp.ParentRecordId).XC_Lead__r.Name;
                            servAppWrp.description              = servApp.Description;
                            servAppWrp.status                   = servApp.Status;
                            servAppWrp.duration                 = String.valueOf(servApp.Duration);
                            servAppWrp.appNumber                = servApp.AppointmentNumber;
                            servAppWrp.workTypeCategory         = servApp.XC_WorkTypeCategory__c;
                            servAppWrp.toLabelWorkTypeCategory  = String.valueOf(servApp.get('toLabel_XC_WorkTypeCategory__c'));
                            servAppWrp.workTypeLabel            = servApp.XC_WorkTypeLabel__c;
                            servAppWrp.toLabelWorkTypeLabel     = String.valueOf(woIdToWorkOrderMap.get(servApp.ParentRecordId).get('toLabel_XC_WorkTypeLabel__c'));
                            servAppWrp.type                     = woIdToWorkOrderMap.get(servApp.ParentRecordId).XC_ProductSubType__c;
                            servAppWrp.durationType             = servApp.DurationType;
                            servAppWrp.isToBeScheduled          = servApp.XC_StatusReason__c == 'To be scheduled' ? true : false;
                            servAppWrp.createdDate              = servApp.CreatedDate != null ? String.valueOf(Date.newInstance(servApp.CreatedDate.year(), servApp.CreatedDate.month(), servApp.CreatedDate.day())) : String.valueOf(Date.newInstance(servApp.ActualEndTime.year(), servApp.ActualEndTime.month(), servApp.ActualEndTime.day())); //ENXCRM-89
                            servAppWrp.productName              = String.isNotBlank(woIdToWorkOrderMap.get(servApp.ParentRecordId).XC_Product_Name__c) ? woIdToWorkOrderMap.get(servApp.ParentRecordId).XC_Product_Name__c : String.isNotBlank(woIdToWorkOrderMap.get(servApp.ParentRecordId).AssetId) ? woIdToWorkOrderMap.get(servApp.ParentRecordId).Asset.Name : null;
                            servAppWrp.faultType                = String.isNotBlank(woIdToWorkOrderMap.get(servApp.ParentRecordId).Case.XC_FaultType__c) ? woIdToWorkOrderMap.get(servApp.ParentRecordId).Case.XC_FaultType__c : null; //FIX - [20220527AL] - NR2331

                            servAppWrp.woChilds = new List<WorkOrderWrapper>();
                            servAppWrp.woHasChild = false;
                            if(woChildsMap.get(servApp.ParentRecordId) != null){
                                servAppWrp.woHasChild = true;
                                servAppWrp.woChilds = processWorkOrderChilds(woChildsMap.get(servApp.ParentRecordId));
                            }

                            infoBag.serviceAppointment.add(servAppWrp);
                        }
                    }
                }
            }

            infoBag.communityBaseUrl    = Site.getBaseUrl();
            infoBag.sysDate             = Date.Today();
            
            System.debug('[TA_UTIL_Appointment] infoBag: ' + infoBag);
            return JSON.serialize(infoBag);
               
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            
            infoBag.errorMsg = errorMessage;
            System.debug('[TA_UTIL_Appointment] EXCEPTION HANDLER: ' + infoBag.errorMsg);
            TA_UTIL_LogManagement.createLog('TA_UTIL_Appointment', 'initialize', errorMessage, 0, errorMessage, null);
            return JSON.serialize(infoBag);
        }
    }

    public static List<WorkOrderWrapper> processWorkOrderChilds(List<WorkOrder> woChildList){
        List<WorkOrderWrapper> woChildToReturn = new List<WorkOrderWrapper>();
        List<WorkOrder> wocMain = new List<WorkOrder>();
        List<WorkOrder> wocSecondary = new List<WorkOrder>();

        for (WorkOrder woc : woChildList) {
            if('Main'.equals(woc.Asset.NE__Bundle_element__r.XC_MacroCategory__c)){
                wocMain.add(woc);
            } else {
                wocSecondary.add(woc);
            }   
        }

        for(WorkOrder wom : wocMain){

            WorkOrderWrapper wow = new WorkOrderWrapper(wom.Id, wom.WorkOrderNumber, wom.XC_Address__r.Name, wom.Status, wom.Asset.Name, true);
    
            for(WorkOrder wos : wocSecondary){
                if( (wos.Asset.NE__Bundle_element__c != null && wom.XC_Conga_AssetProductName__c == wos.XC_Conga_AssetProductName__c) 
                    || (wos.Asset.NE__Bundle_element__c == null && wom.Asset.NE__Bundle_element__r.Name	 == wos.Asset.NE__ProdId__r.NE__Part__c) ){
                    wow.wocSecondary.add(new WorkOrderWrapper(wos.Id, wos.WorkOrderNumber, wos.XC_Address__r.Name, wos.Status, wos.Asset.Name, false));
                }
            }

            woChildToReturn.add(wow);

        }

        system.debug('>_> woChildToReturn : ' + woChildToReturn );
        return woChildToReturn;
    } 

    public static List<ServiceAppointment> getServiceAppointment(Integer rowLimit, Set<String> servAppIds, Boolean toBeScheduled){
        String querySelect = 'SELECT Id,DueDate,SchedStartTime,XC_StatusReason__c,SchedEndTime,Street,Status,City,Description,AccountId,Account.Name,ParentRecordId,ParentRecord.Name,Duration,XC_WorkTypeCategory__c,XC_WorkTypeLabel__c,AppointmentNumber,DurationType,CreatedDate,toLabel(XC_WorkTypeCategory__c) toLabel_XC_WorkTypeCategory__c FROM ServiceAppointment ';
        String whereCondition = '';
        String query = '';
        String statusCompleted = 'Completed';
        String statusReasonTBS = 'To be scheduled'; //ENXCRM-54 - benjamin.geronimo - 27042021
        
        //START | ENXCRM-54 - benjamin.geronimo - added processType - 27042021
        String userPermissionSetName = TA_LCC209_BaseWizardCnt.getUserPermissionSetName();
        Boolean isB2C = userPermissionSetName != null && userPermissionSetName.contains('B2C') ? true : false;
        
        if (rowLimit != null){
            if (isB2C) {
                whereCondition = 'WHERE Id IN :servAppIds AND Status != :statusCompleted AND XC_StatusReason__c = :statusReasonTBS ORDER BY CreatedDate ASC LIMIT :rowLimit'; //ENXCRM-79
            } else {
                whereCondition = 'WHERE Id IN :servAppIds AND Status != :statusCompleted AND SchedStartTime >= TODAY ORDER BY SchedStartTime ASC LIMIT :rowLimit';
            }

        }
        else {
            if (isB2C) {
                if(toBeScheduled) {
                    whereCondition = 'WHERE Id IN :servAppIds AND Status != :statusCompleted AND XC_StatusReason__c = :statusReasonTBS ORDER BY CreatedDate ASC'; //ENXCRM-54 - benjamin.geronimo - 27042021
                } else {
                    //START FIX [20210204AL] - Filter sched start time appointments
                    //whereCondition = 'WHERE Id IN :servAppIds AND XC_StatusReason__c != :statusReasonTBS AND XC_Reason_Cannot_Complete__c = null ORDER BY CreatedDate ASC'; //ENXCRM-54 - benjamin.geronimo - 27042021
                    whereCondition = 'WHERE Id IN :servAppIds AND XC_StatusReason__c != :statusReasonTBS AND XC_Reason_Cannot_Complete__c = null AND SchedStartTime >= LAST_MONTH ORDER BY CreatedDate ASC';
                    //END FIX [20210204AL] - Filter sched start time appointments
                }
                
            } else {
                //START FIX [20210204AL] - Filter sched start time appointments
                //whereCondition = 'WHERE Id IN :servAppIds ORDER BY SchedStartTime ASC';
                whereCondition = 'WHERE Id IN :servAppIds AND SchedStartTime >= LAST_MONTH ORDER BY SchedStartTime ASC';
                //END FIX [20210204AL] - Filter sched start time appointments
            }
        }
        //END | ENXCRM-54 - benjamin.geronimo - added processType - 27042021
        
        query = querySelect + whereCondition;
        List<ServiceAppointment> servAppList = Database.query(query);
        List<String> woIdsToBeCanceled = new List<String>();
        Map<String, ServiceAppointment> woIdToSaMaps = new Map<String, ServiceAppointment>();

        // if(!servAppList.isEmpty()) {
        //     List<String> workOrderIds = new List<String>();
        //     for(ServiceAppointment servApp : servAppList) {
        //         workOrderIds.add(servApp.ParentRecordId);
        //         woIdToSaMaps.put(servApp.ParentRecordId, servApp);
        //     }

        //     if(!workOrderIds.isEmpty()) {
        //         List<WorkOrder> workOrders = [SELECT Id, ParentWorkOrderId,
        //                                       (SELECT Id, XC_WorkTypeCategory__c, XC_WorkTypeLabel__c FROM ChildWorkOrders)  
        //                                       FROM WorkOrder
        //                                       WHERE Id IN :workOrderIds];
        //         if(!workOrders.isEmpty()) {

        //             for(WorkOrder wo : workOrders) {
        //                 if(String.isBlank(wo.ParentWorkOrderId)) {
        //                     if(wo.ChildWorkOrders.size() > 0) {
        //                         for(WorkOrder woChild : wo.ChildWorkOrders) {
        //                             ServiceAppointment servAppCloned = woIdToSaMaps.get(wo.Id).clone(false, true, false, false);
        //                             servAppCloned.ParentRecordId = woChild.Id;
        //                             servAppCloned.XC_WorkTypeCategory__c = woChild.XC_WorkTypeCategory__c;
        //                             servAppCloned.XC_WorkTypeLabel__c = woChild.XC_WorkTypeLabel__c;
        //                             servAppCloned.ActualEndTime = woIdToSaMaps.get(wo.Id).CreatedDate;
        //                             servAppList.add(servAppCloned);
        //                         }
        //                         woIdsToBeCanceled.add(wo.Id);
        //                     }
        //                 }
        //             }

        //             if(!woIdsToBeCanceled.isEmpty()) {
        //                 List<ServiceAppointment> servAppTmp = new List<ServiceAppointment>();
        //                 for(Integer i = 0; i < servAppList.size(); i ++) {
        //                     Boolean check = false; 
        //                     for(String woId : woIdsToBeCanceled) {
        //                         if(servAppList[i].ParentRecordId == woId) {
        //                             check = true;
        //                         }
        //                     }
        //                     if(!check) {
        //                         servAppTmp.add(servAppList[i]);
        //                     }
        //                 }
        //                 servAppList = new List<ServiceAppointment>();
        //                 servAppList.addAll(servAppTmp);
        //             }
        //         }
        //     }
        // }
        // start fix [ADC 26/04/2021]
        if (rowLimit != null && servAppList.size()>0){
            rowLimit = rowLimit > servAppList.size() ? servAppList.size() : rowLimit;
            List<ServiceAppointment> servAppListFiltered = new List<ServiceAppointment>();
            for(Integer i = 0; i < rowLimit; i ++) {
                servAppListFiltered.add(servAppList[i]);
            }
            return servAppListFiltered;
        } 
        // end fix [ADC 26/04/2021]
        return servAppList;                                        
    }
}
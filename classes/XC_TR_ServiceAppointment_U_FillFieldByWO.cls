/**
* @author fabrizio.antonioli@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 26/11/2018
* @date Modification 20/11/2019 - Salvatore Agrillo - salvatore.agrillo@libero.it
* @description XC_TR_ServiceAppointment_U_FillFieldByWO - Util class to populate several SA fields 
*                                                         according to the relative WO fields on before insert
*/

public without sharing class XC_TR_ServiceAppointment_U_FillFieldByWO {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceAppointment_U_FillFieldByWO');

    /** @description Wrapper for populateFields parameters */
    public class PopulateFieldsWrapper{
        public Map<String,Integer> mapCountryDaysAfterDeliveryDate = new Map<String,Integer>();
        public Map<String,Integer> mapCountryDaysForRepairDueDate = new Map<String,Integer>(); 
        public Datetime originalEarliestStartTime;
        public Datetime originalDueDate;
        public String workTypeName; 
        public Map<String, XC_CM_CaseUrgencyManagement__mdt> mapRepairDates;
    }    

    /**
     * @description Populate fields from work order
     * @param listNew - List<ServiceAppointment>
     */
    //JJP 01-12-2021 - Start
    public static void populateFieldsFromWorkOrderCH(List<ServiceAppointment> listNew){
        List<String> listOfWorkOrderId = XC_UTIL_SObject.getListFieldValues(listNew, 'ParentRecordId');
        if(!listOfWorkOrderId.isEmpty()){
            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(
                [SELECT Id, Case.CaseNumber
                 FROM WorkOrder
                 WHERE Id IN: listOfWorkOrderId]);
           
            for(ServiceAppointment sa : listNew){
                if(!workOrderMap.containsKey(sa.ParentRecordId)){
                    continue;
                }
                WorkOrder wo = workOrderMap.get(sa.ParentRecordId);
                sa.Related_Parent_Case__c = wo.Case.CaseNumber;
            }
        }     
    } 
    //JJP 01-12-2021 - End
    
    public static void populateFieldsFromWorkOrder(List<ServiceAppointment> listNew){
        List<String> listOfWorkOrderId = XC_UTIL_SObject.getListFieldValues(listNew, 'ParentRecordId');
        if(!listOfWorkOrderId.isEmpty()){
            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(
                [SELECT Id, WorkTypeId,XC_RequiredPartnerId__c, XC_DeliveryDate__c,XC_Configuration__c,XC_ProductCategoryOfInterest__c, XC_Configuration_Item__c, XC_Payment_Type__c, 
                        Longitude,Latitude,Street,PostalCode,City,State,Country,XC_Commitment__c,XC_MaintenanceYearFrequency__c, XC_FSLAssignmentKey__c,
                        XC_PositionInMaintenancePlan__c, XC_Configuration_Item__r.NE__ProdName__c, ParentWorkOrderId, XC_ReadyToBeBooked__c,
                        XC_Address__r.XC_StreetTypeText__c, XC_Address__r.XC_StreetNumber__c, XC_Urgent_Repair__c, XC_LegalEntity__c, 
                        XC_WorkTypeCategory__c, XC_WorkTypeLabel__c, XC_AvailabilityDate__c, DurationType, Duration, Asset.XC_ActivationDate__c, 
                        Asset.XC_Product_Type__c, Asset.InstallDate, XC_Provisioning_Step__c, XC_Segment__c,XC_Auto_Schedulable__c,
                        (SELECT Id, Status, XC_StatusReason__c   
                        FROM ServiceAppointments
                        WHERE Status =:Label.XC_CL_ServiceAppointment_CannotComplete AND XC_Reason_Cannot_Complete__c = 'Work to be completed with a second visit')
                FROM WorkOrder
                WHERE Id IN: listOfWorkOrderId]);
            checkIfWorkOrderIsBookable(workOrderMap, listNew);                          
            populateFields(workOrderMap, listNew);
        }       
    }  

    /**
     * @description Gets the max date time
     * @param date1 - DateTime
     * @param date2 - DateTime
     * @return DateTime
     */
    private static DateTime getMaxDateTime(DateTime date1, DateTime date2){
        if(date1 >= date2){
            return date1;
        } else {
            return date2;
        }
    } 

    /**
     * @description Gets the max date time
     * @param workTypeName - String
     * @param wo - WorkOrder
     * @param sa - ServiceAppointment
     */
    private static void setProductCategoryOnSA (String workTypeName, WorkOrder wo, ServiceAppointment sa){
        if(workTypeName == Label.XC_CL_CommercialVisit){
            sa.XC_ProductCategoryOfInterest__c = wo.XC_ProductCategoryOfInterest__c;
        }
    }

    /**
     * @description Gets the max date time
     * @param workOrderMap - Map<Id, WorkOrder>
     * @param listNew - List<ServiceAppointment>
     */
    private static void populateFields (Map<Id, WorkOrder> workOrderMap, List<ServiceAppointment> listNew){
        PopulateFieldsWrapper wrapperOfFields = new PopulateFieldsWrapper();
        List<String> listIdWorkType = XC_UTIL_Sobject.getListFieldValues(workOrderMap.values(),'WorkTypeId');
        Map<Id, WorkType> mapWorkType = new Map<Id, WorkType>([
            SELECT Id, XC_AssignToPartner__c
            FROM WorkType
            WHERE Id IN :listIdWorkType
        ]);
        //Map<String,Boolean> mapWorkTypeAssignToPartner = XC_UTIL_WorkType.getMapAssignToPartnerByWorkTypeName(listNameWorkType);
        List<String> listCountries = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Country__c'); 
        XC_UTIL_ServiceAppointment.ServiceAppointmentDefaultValues serviceAppointmentWrapper = XC_UTIL_ServiceAppointment.getDefaultValues(listCountries);
        wrapperOfFields.mapCountryDaysAfterDeliveryDate = serviceAppointmentWrapper.mapCountryDaysAfterDeliveryDate;
        wrapperOfFields.mapCountryDaysForRepairDueDate = serviceAppointmentWrapper.mapCountryDaysForRepairDueDate;
        wrapperOfFields.mapRepairDates = XC_TR_ServiceAppoint_U_FillFieldByWO_U.retrieveRepairDate(listCountries);
        for(ServiceAppointment sa : listNew){
            if(!workOrderMap.containsKey(sa.ParentRecordId)){
                continue;
            }
            WorkOrder wo = workOrderMap.get(sa.ParentRecordId);
            wrapperOfFields.workTypeName = wo.XC_WorkTypeLabel__c;
            sa.XC_WorkTypeLabel__c = wrapperOfFields.workTypeName;
            sa.FSL__GanttLabel__c = wrapperOfFields.workTypeName;  
            sa.XC_Order__c = wo.XC_Configuration__c;   
            sa.XC_LegalEntity__c = wo.XC_LegalEntity__c;
            sa.XC_FSLAssignmentKey__c = wo.XC_FSLAssignmentKey__c;
            sa.XC_WorkTypeCategory__c = wo.XC_WorkTypeCategory__c;
            sa.XC_Segment__c = wo.XC_Segment__c;
            sa.XC_Configuration_Item__c = wo.XC_Configuration_Item__c;
            sa.XC_NE_ProdName__c = wo.XC_Configuration_Item__r.NE__ProdName__c;
            sa.XC_Payment_Type__c = wo.XC_Payment_Type__c;
            setProductCategoryOnSA(wrapperOfFields.workTypeName,wo,sa); 
            sa.XC_RequiredPartnerId__c = wo.XC_RequiredPartnerId__c;

            if(!wo.XC_Auto_Schedulable__c){
            	sa.XC_AssignToPartner__c = (!mapWorkType.isEmpty() && mapWorkType.containsKey(wo.WorkTypeId)) ? mapWorkType.get(wo.WorkTypeId).XC_AssignToPartner__c : false;//mapWorkTypeAssignToPartner.get(wrapperOfFields.workTypeName); 
            }

            if(wo.DurationType == 'Hours' && wo.Duration > 6 && wo.XC_Segment__c == 'B2C'){
                sa.FSL__IsMultiDay__c = true;
            } 
            //XC_UTIL_ServiceAppointment.populateAddressFieldsFromWorkOrder(sa,wo);  // Salvatore Agrillo - 10/03/2020
            XC_UTIL_ServiceAppointment.populateAddressFields(sa, wo);
            wrapperOfFields.originalEarliestStartTime = sa.EarliestStartTime;
            wrapperOfFields.originalDueDate = sa.DueDate;  
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'originalEarliestStartTime->' + wrapperOfFields.originalEarliestStartTime);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'originalDueDate->' + wrapperOfFields.originalDueDate);    
            XC_TR_ServiceAppointment_FillFieldByWO_U.setDatesOnRepairWo(wrapperOfFields, wo, sa);
            manageDatesForInstallation(wrapperOfFields, wo, sa);
            /*if(sa.XC_LegalEntity__c == 'EnelXItalia' && sa.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
                setDatesForItalianMaintenance(sa, wo);
            }*/
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
     * @date 05/03/2020
     * @description Manage dates for Installation
     * @param wrapperOfFields - PopulateFieldsWrapper
     * @param wo - WorkOrder
     * @param sa - ServiceAppointment
     */
    private static void manageDatesForInstallation(PopulateFieldsWrapper wrapperOfFields, WorkOrder wo, ServiceAppointment sa) {
        if(wrapperOfFields.workTypeName == Label.XC_CL_WorkType_Delivery) { 
            if(wo.XC_DeliveryDate__c != null && wrapperOfFields.mapCountryDaysAfterDeliveryDate.get(sa.XC_Country__c) != null) {
                Integer days = wrapperOfFields.mapCountryDaysAfterDeliveryDate.get(sa.XC_Country__c); 
                Datetime newEarliestStartTime = wo.XC_DeliveryDate__c + days;
                newEarliestStartTime = getMaxDateTime(newEarliestStartTime, wrapperOfFields.originalEarliestStartTime);
                sa.EarliestStartTime = newEarliestStartTime;
                getNewDueDate(wrapperOfFields, newEarliestStartTime, sa);
            }  
        } 

        List<String> listWorkTypeToManage = new List<String>{Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_Installation, Label.XC_CL_WorkType_Substitution};
        if(String.isNotBlank(String.valueOf(wo.XC_AvailabilityDate__c)) && listWorkTypeToManage.contains(wo.XC_WorkTypeCategory__c)){ 
            DateTime originalEarliestStartTime = sa.EarliestStartTime;             
            if(wo.XC_AvailabilityDate__c == Date.today()){
                sa.EarliestStartTime = (originalEarliestStartTime < DateTime.now()) ? DateTime.now() : originalEarliestStartTime;                 
            } else{
                sa.EarliestStartTime = (originalEarliestStartTime < wo.XC_AvailabilityDate__c) ? wo.XC_AvailabilityDate__c : originalEarliestStartTime;
            } 
            DateTime originalDueDate= sa.DueDate;
            if(originalDueDate != null && originalEarliestStartTime != null){
                DateTime newDueDate = sa.EarliestStartTime.addDays(originalEarliestStartTime.date().daysBetween(originalDueDate.date()));
                newDueDate = newDueDate.addHours(12);
                sa.DueDate = newDueDate;                
            }
        } 

        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && sa.XC_Payment_Type__c == Label.XC_CL_Barcode) {
            if(sa.EarliestStartTime < Datetime.now().addDays(3)) {
                sa.EarliestStartTime = System.now().addDays(3);
                sa.DueDate = sa.EarliestStartTime.addDays(sa.EarliestStartTime.date().daysBetween(sa.DueDate.date()));
            }
        }
    }
    
    
     /**
     * @description Gets the new due date
     * @param wrapperOfFields - PopulateFieldsWrapper
     * @param newEarliestStartTime - DateTime
     * @param sa - ServiceAppointment
     */
    /*private static void setDatesForItalianMaintenance(ServiceAppointment sa, WorkOrder wo){
        if(wo.Asset.XC_ActivationDate__c != null && wo.Asset.XC_Product_Type__c != 'Equipment' && wo.XC_Provisioning_Step__c != null && wo.XC_PositionInMaintenancePlan__c != null 
           && wo.XC_PositionInMaintenancePlan__c == 1){
            sa.EarliestStartTime = wo.Asset.XC_ActivationDate__c.addDays(30);
            sa.DueDate =  wo.Asset.XC_ActivationDate__c.addDays(60);
        }
    }*/

    /**
     * @description Gets the new due date
     * @param wrapperOfFields - PopulateFieldsWrapper
     * @param newEarliestStartTime - DateTime
     * @param sa - ServiceAppointment
     */
    private static void getNewDueDate(PopulateFieldsWrapper wrapperOfFields, DateTime newEarliestStartTime, ServiceAppointment sa){
        if(wrapperOfFields.originalDueDate != null){
            DateTime originalEarliestStartTime = wrapperOfFields.originalEarliestStartTime;
            DateTime originalDueDate = wrapperOfFields.originalDueDate;
            if(originalEarliestStartTime == null){
                originalEarliestStartTime = newEarliestStartTime; 
            }
            DateTime newDueDate = newEarliestStartTime.addDays(originalEarliestStartTime.date().daysBetween(originalDueDate.date()));
            newDueDate = newDueDate.addHours(12);
            sa.DueDate = newDueDate;
        }    
    }

    /**
     * @author Porrega Roberta - roberta.porrega@nttdata.com, Cossiga Roberta - rcossiga@deloitte.it
     * @param listNew the service appointment 
     * @description  method to update the lead status of the service appointment
     */
    public static void changeLeadStatus(List<ServiceAppointment> listNew){ 
        List<String> listOfWorkOrderId = XC_TR_ServiceAppoint_U_FillFieldByWO_U.retrieveWorkOrderFromCanceledSA(listNew);
        List<Id> leadToUpdate = XC_TR_ServiceAppoint_U_FillFieldByWO_U.retrieveLeadToUpdate(listOfWorkOrderId);
        List<Lead> leadList = new List<Lead>();
        if(!leadToUpdate.isEmpty() && Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.Id.isAccessible() && Schema.sObjectType.Lead.fields.Status.isAccessible()){ 
            for(String ldIds : leadToUpdate) {
                Lead lead = new Lead(
                    Id = ldIds,
                    Status = Label.XC_CL_Lead_PendingScheduling 
                );
                leadList.add(lead);
            }
        }
        XC_UTIL_Sobject.updateListRecords(leadList); 
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @param workOrderMap - Map<Id, WorkOrder>
     * @param listNew - List<ServiceAppointment>
     * @description  method to identify Children WO
     */
    public static void checkIfWorkOrderIsBookable(Map<Id, WorkOrder> workOrderMap, List<ServiceAppointment> listNew){
        for(ServiceAppointment sa : listNew){
            if(!workOrderMap.containsKey(sa.ParentRecordId)){
                continue;
            }
            WorkOrder wo = workOrderMap.get(sa.ParentRecordId);

            if(wo.XC_Segment__c == 'B2B' || wo.XC_Segment__c == 'B2G'){
                continue;
            }

            if((wo.ParentWorkOrderId != null && !wo.XC_ReadyToBeBooked__c) || (wo.ParentWorkOrderId != null && (wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia))){
                sa.addError(Label.XC_CL_CannotBookOnChildWO);
            }
            else if(!wo.XC_ReadyToBeBooked__c && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){
                sa.addError(Label.XC_CL_CannotYetBookOnWO);
            }
        }   
    }

}
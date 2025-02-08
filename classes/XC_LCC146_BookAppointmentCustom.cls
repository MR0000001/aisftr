/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/09/2019
* @description XC_LCC146_BookAppointmentCustom – Apex Controller for Book Appointment Custom
*/

public without sharing class XC_LCC146_BookAppointmentCustom {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC146_BookAppointmentCustom');

    /** @description CheckAvailabilityWrapper */
    public class CheckAvailabilityWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String message = '';
        @AuraEnabled
        public Boolean isCommunity = false;
        @AuraEnabled
        public String segment = '';
        @AuraEnabled
        public boolean isProd;        
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 05/09/2019
    * @description Method to check resources
    * @param idWorkOrder - CheckAvailabilityWrapper
    * @return CheckAvailabilityWrapper
    */
    @AuraEnabled
    public static CheckAvailabilityWrapper checkAvailability(String idWorkOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check Availability for WO -> ' + idWorkOrder);
        CheckAvailabilityWrapper resultWrapper = new CheckAvailabilityWrapper();
        String currentUserPartnerId = '';      
        // Check for Community:
        //check if is in Prod or SandBox Envinronement NA 13012021
        Organization org=[select IsSandbox from Organization limit 1];
        resultWrapper.isProd=org.IsSandbox;
        List<User> user = new List<User>([SELECT AccountId, Account.isPartner FROM User WHERE Id = :UserInfo.getUserId()]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ userQuery -->' + user);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ currentUser -->' + UserInfo.getUserId());
        if(user[0].AccountId != null) {
            resultWrapper.isCommunity = user[0].Account.isPartner;
            currentUserPartnerId = user[0].AccountId;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isCommunity -> ' + resultWrapper.isCommunity);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ currentUserPartnerId -> ' + currentUserPartnerId); 
        // Check for WorkType:
        
        List<String> listWorkTypeFilteredB2C = new List<String>{
            Label.XC_CL_WorkType_DeliveryInstallation, 
            Label.XC_CL_WorkType_Substitution,
            Label.XC_CL_WorkType_PlannedMaintenance
        };
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, XC_ApplyCoverageFilterInBooking__c, PostalCode, XC_Segment__c, XC_RequiredPartnerId__c, WorkTypeId, ParentWorkOrderId, XC_WorkTypeCategory__c,XC_LegalEntity__c, XC_NumberWorkOrdersDI__c, XC_FSLAssignmentKey__c, XC_WorkTypeLabel__c,Country,
                (SELECT Id, XC_ApplyCoverageFilterInBooking__c, PostalCode, WorkTypeId, XC_WorkTypeCategory__c,XC_FSLAssignmentKey__c, XC_WorkTypeLabel__c FROM ChildWorkOrders)
            FROM WorkOrder
            WHERE Id = :idWorkOrder
            //((Id = :idWorkOrder AND XC_WorkTypeCategory__c IN :listWorkTypeFilteredB2C AND XC_Segment__c='B2C') OR 
            //        (Id = :idWorkOrder AND (XC_Segment__c='B2B' OR XC_Segment__c='B2G') ) ) 
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWorkOrder -> ' + listWorkOrder);
        WorkOrder currentWO = listWorkOrder[0];
        List<String> listLegalEntityToCheck = new List<String>{Label.XC_CL_EndesaX, Label.XC_CL_LegalEntity_EnelXMobilitySpain};
        List<String> listSegmentToCheck = new List<String>{'B2C'};
        if(String.isBlank(currentUserPartnerId) && listLegalEntityToCheck.contains(currentWO.XC_LegalEntity__c) && listSegmentToCheck.contains(currentWO.XC_Segment__c)) {
            currentUserPartnerId = listWorkOrder[0].XC_RequiredPartnerId__c;
        }
        resultWrapper.segment = currentWO.XC_Segment__c;

        Boolean conditionB2CToExit = currentWO.XC_Segment__c == 'B2C' && !listWorkTypeFilteredB2C.contains(currentWO.XC_WorkTypeCategory__c);
        Boolean conditionB2BToExit = (currentWO.XC_Segment__c =='B2B' || currentWO.XC_Segment__c =='B2G'); //&& currentWO.XC_Project_Task__c != null;
        Boolean conditionB2CMaintenance = currentWO.XC_Segment__c =='B2C' && currentWO.ParentWorkOrderId == null && currentWO.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance;
        Boolean conditionB2CPublicRecharge = currentWO.XC_Segment__c == 'B2C' && currentWO.XC_WorkTypeLabel__c == 'Delivery & Installation - Public recharge';
        
        if(conditionB2CToExit || conditionB2BToExit || conditionB2CMaintenance || conditionB2CPublicRecharge){
            resultWrapper.success = true;
            return resultWrapper;
        }
        
        if(currentWO.ParentWorkOrderId != null && currentWO.XC_Segment__c =='B2C'){
            resultWrapper.message = Label.XC_CL_CannotBookOnChildWO;
            return resultWrapper;
        } 
        WorkOrder woToSendToGlovia = new WorkOrder();
        Boolean isSubstitution = false;
        if(currentWO.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder D&I');
            if((currentWO.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || currentWO.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && (!currentWO.ChildWorkOrders.isEmpty() && currentWO.XC_NumberWorkOrdersDI__c != currentWO.ChildWorkOrders.size()) || (currentWO.ChildWorkOrders.isEmpty() && currentWO.XC_NumberWorkOrdersDI__c > 1)){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Number of D&I Child not right');
                resultWrapper.message = Label.XC_CL_CannotYetBookOnWO;
                return resultWrapper;
            }
            woToSendToGlovia = currentWO;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ woToSendToGlovia --->'+ woToSendToGlovia);
        } else if(currentWO.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder Substitution');
            isSubstitution = true;
            Boolean workOrderChildFound = false;
            for(WorkOrder woChild : currentWO.ChildWorkOrders) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Work Order Child -> ' + woChild.Id);
                if(woChild.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ D&I of Substitution found');
                    woToSendToGlovia = woChild;
                    workOrderChildFound = true;
                    break;
                }
            }
            if(!workOrderChildFound) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ No child found');
                resultWrapper.message = Label.XC_CL_BookApp_ErrorSubstitution;
                return resultWrapper;
            }
        }

        // Check for Eligible Resource:
        //check if country is enableb for Glovia Callout
        List<XC_CM_Scheduling_Default_Value__mdt> metadataList = XC_UTIL_Schedule_D.getMetadata(currentWO.Country);
        //if a country is not configured on XC_CM_Scheduling_Default_Value__mdt the default is TRUE. In this way
        //will be performed glovia call
        Boolean callGlovia = !metadataList.isEmpty() &&  currentWO.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation ? metadataList[0].XC_Use_Glovia__c : true;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ use glovia: -> ' + callGlovia);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ metadataList: -> ' + metadataList);

        if(callGlovia || Test.isRunningTest()) {
            String zipCodeToUse = (String.isBlank(woToSendToGlovia.XC_FSLAssignmentKey__c)) ? woToSendToGlovia.PostalCode : woToSendToGlovia.XC_FSLAssignmentKey__c;
            XC_UTIL_EligibleServiceResource.EligibleWrapper eWr = XC_UTIL_FSLLogistic.checkAvailability(woToSendToGlovia, zipCodeToUse, woToSendToGlovia.WorkTypeId, currentUserPartnerId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Glovia -> ' + eWr);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isSubstitution -> ' + isSubstitution);
            if (isSubstitution && eWr.success) {
                // If Substitution we have to update Availability Date of Parent
                currentWo.XC_AvailabilityDate__c = eWr.availabilityDate;
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                XC_UTIL_Sobject.WrapperResult resUpdate = XC_UTIL_Sobject.updateRecord(currentWo);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
                if (!resUpdate.success) {
                    resultWrapper.message = resUpdate.errorMessage;
                    return resultWrapper;
                }
            }
            resultWrapper.success = eWr.success;
            resultWrapper.message = eWr.errorMessage;
        }else{
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ glovia not used (Enable it on XC_CM_Scheduling_Default_Value__mdt -> XC_Use_Glovia__c )');
            resultWrapper.success = true;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ resultWrapper -> ' + resultWrapper);
        return resultWrapper;
    }
   
}
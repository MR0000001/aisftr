/**
* @author Roberta Cossiga - rcossiga@deloitte.it & Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/10/2019
* @description  – public class with invocable method. It is invoked by a Flow to check the Credit Card Pre Authorization
*/ 

public without sharing class XC_IN035_ReservationSpareParts {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN035_ReservationSpareParts');
    public static Boolean throwTest = false;

    /** @description InputWrapper */
    public class InputWrapper { 
        @Invocablevariable
        public String stepId; 

        /** @description Constructor */
        public InputWrapper() {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ > In IN035');
        }

        /**
        * @description Constructor with paramas
        * @param stepId - String
        */
        public InputWrapper(String stepId) {
            this.stepId = stepId;
        }     
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @date Creation 25/11/2019
     * @description Method to make reservation for a product
     * @param inputWrapperList - List<InputWrapper>
     */
    @InvocableMethod
    public static void makeReservation(List<InputWrapper> inputWrapperList) {
        if(!inputWrapperList.isEmpty()){      
            List<XC_Provisioning_Step__c> listMyStep = new List<XC_Provisioning_Step__c>([
                SELECT Id, XC_Status__c, XC_Configuration_Item__r.NE__OrderId__c, 
                        XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__r.XC_WorkTypeCategory__c, 
                        XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__r.XC_StatusReason__c, XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedResource__c
                FROM XC_Provisioning_Step__c 
                WHERE Id = :inputWrapperList[0].stepId
            ]); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stepId >' + inputWrapperList[0].stepId);
            
            XC_Provisioning_Step__c updateStep = new XC_Provisioning_Step__c(Id = listMyStep[0].Id);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Id WO Technical Quote >' + listMyStep[0].XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Id Order > ' + listMyStep[0].XC_Configuration_Item__r.NE__OrderId__c);
            if(String.isBlank(listMyStep[0].XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c)){
                updateStep.XC_Status__c = Label.XC_CL_Step_Skipped;
            } else {
                String orderId = listMyStep[0].XC_Configuration_Item__r.NE__OrderId__c; 
                if(!String.isBlank(orderId) ) {  
                    if(Limits.getDMLStatements()>0 ){ 
                        List<XC_Provisioning_Step__c> listSteps =  XC_UTIL_Sobject.selectAllFields(inputWrapperList[0].stepId); 
                        XC_UTIL_ProvisioningStep.insertEvent(listSteps) ; 
                        return ; 
                     } 
                    callGlovia(orderId, updateStep, listMyStep);
                } else {
                    updateStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    updateStep.XC_ErrorMessage__c = Label.XC_CL_ErrorConfiguration;
                }            
            }
                
            XC_UTIL_Sobject.WrapperResult resWrapper = XC_UTIL_Sobject.updateRecord(updateStep);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Update step Product Reservation -> ' + resWrapper);
        }                 
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @date Creation 25/11/2019
     * @description Method to call Glovia to manage the creation of Sales Order
     * @param orderId - orderId
     * @param updateStep - XC_Provisioning_Step__c
     * @param listMyStep - List<XC_Provisioning_Step__c>
     */
    private static void callGlovia(Id orderId, XC_Provisioning_Step__c updateStep, List<XC_Provisioning_Step__c> listMyStep) {
        giic_CommonWrapper.OrderResponse responseWrapper = new giic_CommonWrapper.OrderResponse();
        try{
            if(!throwTest) {
                responseWrapper = XC_UTIL_FSLLogistic.createSalesOrderFromConfig(orderId);
            }
            if(responseWrapper.errorMessages.isEmpty() || throwTest) {
                WorkOrder workOrder = new WorkOrder(
                    Id = listMyStep[0].XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__c, 
                    XC_WorkTypeCategory__c = listMyStep[0].XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__r.XC_WorkTypeCategory__c, 
                    XC_StatusReason__c = listMyStep[0].XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__r.XC_StatusReason__c,
                    XC_AssignedResource__c = listMyStep[0].XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_WorkOrder__r.XC_AssignedResource__c
                );
                String error = updateDateWorkOrder(workOrder, responseWrapper.lstProductAvailability);
                if(String.isBlank(error)) {
                    updateStep.XC_Status__c = Label.XC_CL_Completed_Ok;
                } else {
                    updateStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    updateStep.XC_ErrorMessage__c = error;
                }
            } else if(responseWrapper.errorMessages.contains(Label.XC_CL_Glovia_ReservationError)) {
                updateStep.XC_Status__c = Label.XC_CL_Step_Skipped;
            } else {
                updateStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                updateStep.XC_ErrorMessage__c = responseWrapper.errorMessages[0];
            } 
        } catch (Exception e) {
            if(updateStep.XC_ErrorMessage__c == Label.XC_CL_ReadTimeOut){
                updateStep.XC_Status__c = Label.XC_CL_Completed_Ok;
                updateStep.XC_ErrorMessage__c = '';
            }else {    
                updateStep.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                updateStep.XC_ErrorMessage__c = e.getMessage();
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @date Creation 25/11/2019
     * @description Method to update availability date on WorkOrder
     * @param workOrder - WorkOrder
     * @param lstProductAvailability - List<Giic_CommonWrapper.ProductAvailability>
     * @return String
     */
    private static String updateDateWorkOrder(WorkOrder workOrder, List<Giic_CommonWrapper.ProductAvailability> lstProductAvailability) {
        Date maxDate = Date.today();
        if(!throwTest) {
            List<Date> listAvailabilityDate = new List<Date>();
            for(Giic_CommonWrapper.ProductAvailability prod : lstProductAvailability) {
                listAvailabilityDate.add(prod.availabilityDate);
            }
            maxDate = XC_SC010_PopulateSkillsOnRes_U_Interval.calculateMaxOfDates(listAvailabilityDate);
        }

        if(workOrder.XC_StatusReason__c == Label.XC_CL_PendingParts) {
            // Set Availability Date:
            workOrder.XC_AvailabilityDate__c = maxDate;
            XC_UTIL_Sobject.WrapperResult updateWoWrapper = XC_UTIL_Sobject.updateRecord(workOrder);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Update Work Order -> ' + updateWoWrapper);
            if(!updateWoWrapper.success) {
                return updateWoWrapper.errorMessage;
            }

            // Set Resource Preference:
            return manageResourcePreference(workOrder);
        }        
        return '';
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @date Creation 25/11/2019
     * @description Method to manage Resource Preference of WorkOrder
     * @param workOrder - WorkOrder
     * @return String
     */
    private static String manageResourcePreference(WorkOrder workOrder) {
        List<ResourcePreference> listResourcePreference = new List<ResourcePreference>([
            SELECT Id 
            FROM ResourcePreference 
            WHERE RelatedRecordId = :workOrder.Id
        ]);
        if(!listResourcePreference.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> lisrResDeleteWrapper = XC_UTIL_Sobject.deleteListRecords(listResourcePreference);
            if(!XC_UTIL_Sobject.checkDMLResults(lisrResDeleteWrapper)) {
                return lisrResDeleteWrapper[0].errorMessage;
            }
            ResourcePreference newPreference = new ResourcePreference();
            newPreference.RelatedRecordId = workOrder.Id;
            newPreference.ServiceResourceId = workOrder.XC_AssignedResource__c;
            XC_UTIL_Sobject.WrapperResult insertRequiredWrapper = XC_UTIL_Sobject.insertRecord(newPreference);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Insert Resource Preference -> ' + insertRequiredWrapper);
            if(!insertRequiredWrapper.success) {
                return insertRequiredWrapper.errorMessage;
            }
        }
        return '';
    }

}
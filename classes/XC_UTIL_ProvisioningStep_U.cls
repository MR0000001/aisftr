/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 19/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ProvisioningStep_U – Method for XC_UTIL_ProvisioningStep
*/

public without sharing class XC_UTIL_ProvisioningStep_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ProvisioningStep_U');

    /** @description CheckStepWrapper */
    public class CheckStepWrapper {
        public Integer numberStep = 0;
        public Map<String, List<XC_Provisioning_Step__c>> mapStepsForCreateSubscription = new Map<String, List<XC_Provisioning_Step__c>>();
        public Map<Id, NE__OrderItem__c> mapOrderItemToUpdate = new Map<Id, NE__OrderItem__c>();
        public Map<String, List<XC_Provisioning_Step__c>> mapStepsForProductReservation = new Map<String, List<XC_Provisioning_Step__c>>();
        public Map<String, List<XC_Provisioning_Step__c>> mapStepsForManagePayment =  new Map<String, List<XC_Provisioning_Step__c>>();
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttadata.com
     * @description Method to populate ResultWrapper
     * @param results - ResultWrapper
     * @param mapConfItemTemplateName - Map<Id, String>
     * @param configurationItemList - List<NE__OrderItem__c>
    **/
    public static void populateResultWrapper(List<XC_UTIL_ProvisioningStep.ResultWrapper> results, Map<Id, String> mapConfItemTemplateName, List<NE__OrderItem__c> configurationItemList) {
        
        List<XC_Provisioning_Step__c> listStepToInsert = new List<XC_Provisioning_Step__c>(); 
        if(!mapConfItemTemplateName.isEmpty()) { 
            Map<Id, List<XC_CM_Provisioning_Template_Config__mdt>> mapConfItemListSteps = XC_UTIL_ProvisioningTemplateConfig.getTemplateSteps(mapConfItemTemplateName);
            for(NE__OrderItem__c confItem : configurationItemList){
                if(!mapConfItemListSteps.containsKey(confItem.Id)) {
                    results.add(new XC_UTIL_ProvisioningStep.ResultWrapper(false, Label.XC_CL_NoProvisioningSteps));
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@ss@ mapConfItemListSteps---> ' + mapConfItemListSteps);
            if(!mapConfItemListSteps.isEmpty()){ 
                for(Id confItemId : mapConfItemListSteps.keySet()){  
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@ss0606@ confItemId---> ' + confItemId);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@ss0606@ stepMD before---> ' + mapConfItemListSteps.get(confItemId));
                    for(XC_CM_Provisioning_Template_Config__mdt stepMD : mapConfItemListSteps.get(confItemId)){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ss0606@ stepMD---> ' + stepMD);
                        XC_Provisioning_Step__c newStep = createNewStep(stepMD);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@ss@ newStep---> ' + newStep);
                        newStep.XC_Configuration_Item__c = confItemId;
                        listStepToInsert.add(newStep);
                    }
                    results.add(new XC_UTIL_ProvisioningStep.ResultWrapper(true, ''));
                }
                List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_Sobject.insertListRecords(listStepToInsert);
                populateListResult(wrapperResultList, results);
            }
        } 
    }

    /**
     * @description Populate List ResultWrapper
     * @param wrapperResultList
     * @param results
    **/
    private static void populateListResult(List<XC_UTIL_Sobject.WrapperResult> wrapperResultList, List<XC_UTIL_ProvisioningStep.ResultWrapper> results) {
        for(XC_UTIL_Sobject.WrapperResult wr: wrapperResultList){
            if(!wr.success){
                results.add(new XC_UTIL_ProvisioningStep.ResultWrapper(false, wr.errorMessage));
            }
        }
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttadata.com
     * @description Given a Provisioning Template Config this method returns a Provisioning Step by mapping all fields
     * @param stepMD
     * @return newStep 
    **/
    public static XC_Provisioning_Step__c createNewStep(XC_CM_Provisioning_Template_Config__mdt stepMD){
        XC_Provisioning_Step__c newStep = new XC_Provisioning_Step__c();
        newStep.XC_Mandatory_Steps__c = stepMD.XC_CM_Mandatory_Steps__c;
        newStep.XC_Step_Code__c = stepMD.XC_CM_Step_Code__c;
        newStep.XC_Step_Order__c = stepMD.XC_CM_Step_Order__c;
        newStep.XC_Synchronous__c = stepMD.XC_CM_Synchronous__c;
        newStep.XC_OptionalForProvisioningCompletion__c=stepMD.XC_CM_OptionalForProvisioningCompletion__c;
        newStep.XC_Template_Name__c = stepMD.XC_CM_Template_Name__c;
        newStep.XC_StepLabel__c = stepMD.XC_CM_Step_Name__c;
        newStep.XC_PlatformEventName__c = stepMD.XC_CM_PlatformEventName__c;
        newStep.XC_Flow_API_Name__c = stepMD.XC_CM_Flow_to_execute__r.XC_CM_Flow_Developer_Name__c;
        return newStep;
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps this method group them by flowName
     * @param stepsToEnqueue
     * @return Map<String, List<XC_Provisioning_Step__c>>
    **/
    public static Map<String, List<XC_Provisioning_Step__c>> getMapStepsByName(List<XC_Provisioning_Step__c> stepsToEnqueue){
        Map<String, List<XC_Provisioning_Step__c>> mapStepsByName = new Map<String, List<XC_Provisioning_Step__c>>();
        for(XC_Provisioning_Step__c step : stepsToEnqueue){
            String flowName = step.XC_Flow_API_Name__c;
            if(!String.isBlank(flowName)){
                if(!mapStepsByName.containsKey(flowName)){
                    mapStepsByName.put(flowName, new List<XC_Provisioning_Step__c>());
                } 
                mapStepsByName.get(flowName).add(step); 
            } 
        }
        return mapStepsByName;
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param orderId the id of the order
     * @description method to retrieve the configuration items related to the configuration that changed their status to 'In Provisioning' and
     *              start the provisioing steps on these items
     */ 
    public static void startProvisioningStepsOnConfigurationItems(String orderId){

        Map<Id,XC_Provisioning_Step__c> stepMap = new Map<Id,XC_Provisioning_Step__c>([
            SELECT Id,XC_Step_Order__c,XC_Configuration_Item__c,XC_Status__c,
                        XC_Step_Code__c,
                        XC_Mandatory_Steps__c,
                        XC_Synchronous__c,
                        XC_Flow_API_Name__c,
                        XC_Country__c, 
                        XC_ConfigurationId__c,
                        XC_Segment__c,
                        XC_LegalEntity__c,
                        XC_PlatformEventName__c, XC_Template_Name__c 
            FROM XC_Provisioning_Step__c 
            WHERE XC_Configuration_Item__r.NE__OrderId__c =: orderId /*AND XC_Configuration_Item__r.XC_IsAProduct__c = true*/]);

        List<XC_Provisioning_Step__c> stepList = stepMap.values();
        System.debug('stepList->' + stepList);
        XC_UTIL_ProvisioningStep.startInitialSteps(stepList); 
    } 

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 30/07/2019
    * @description Method to check provisioning step
    * @param orderId - String
    * @return CheckStepWrapper
    */
    public static CheckStepWrapper checkProvisioningStep(String orderId) {
        CheckStepWrapper wrapper = new CheckStepWrapper();
        List<NE__OrderItem__c> listorderItems = new List<NE__OrderItem__c>([
            SELECT Id, NE__Bundle_Configuration__c, XC_Product_Type__c, NE__Root_Order_Item__c,NE__OrderId__c,
                (SELECT Id, XC_Flow_API_Name__c  FROM Provisioning_Steps__r) 
            FROM NE__OrderItem__c 
            WHERE NE__OrderId__c = :orderId
        ]);

        for(NE__OrderItem__c orderItem : listorderItems) {
            for(XC_Provisioning_Step__c step : orderItem.Provisioning_Steps__r) {
                // For Delivery Status:
                Boolean checkInstallation = orderItem.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && step.XC_Flow_API_Name__c == Label.XC_CL_Flow_OnlyInstallation;
                Boolean checkDelivery = orderItem.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && step.XC_Flow_API_Name__c == Label.XC_CL_Flow_OnlyDelivery;
                Boolean checkService = orderItem.XC_Product_Type__c == Label.XC_CL_ProductTypeService;
                Boolean checkServiceCoverage = orderItem.XC_Product_Type__c == Label.XC_CL_ProductTypeCoverage && String.isBlank(orderItem.NE__Root_Order_Item__c) && String.isBlank(orderItem.NE__Bundle_Configuration__c);
                Boolean checkTechnicalProduct = orderItem.XC_Product_Type__c == Label.XC_CL_Technical;
                if(checkInstallation || checkTechnicalProduct) {
                    // For Installation:
                    orderItem.XC_DeliveryStatusList__c = Label.XC_CL_ListDeliveryStatusInstallation;
                    orderItem.XC_DeliveryStatus__c = Label.XC_CL_Configuration_OrderInProgress;
                    wrapper.mapOrderItemToUpdate.put(orderItem.Id, orderItem);
                } else if(checkDelivery) {
                    // For Delivery:
                    orderItem.XC_DeliveryStatusList__c = Label.XC_CL_ListDeliveryStatusDelivery;
                    orderItem.XC_DeliveryStatus__c = Label.XC_CL_Configuration_OrderInProgress;
                    wrapper.mapOrderItemToUpdate.put(orderItem.Id, orderItem);
                } else if(checkService || checkServiceCoverage) {
                    // For Service:
                    orderItem.XC_DeliveryStatusList__c = Label.XC_CL_ListDeliveryStatusService;
                    orderItem.XC_DeliveryStatus__c = Label.XC_CL_Configuration_OrderInProgress;
                    wrapper.mapOrderItemToUpdate.put(orderItem.Id, orderItem);
                }

                // For Master of subscription:
                if(step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningCreateDeliveryInstallationWO_Flow) {
                    wrapper.numberStep++;
                }
                if(!String.isBlank(orderItem.NE__Bundle_Configuration__c) && checkFlowSubscription(step)) {
                    if(!wrapper.mapStepsForCreateSubscription.containsKey(orderItem.NE__Bundle_Configuration__c)) {
                        wrapper.mapStepsForCreateSubscription.put(orderItem.NE__Bundle_Configuration__c, new List<XC_Provisioning_Step__c>());
                    }
                    wrapper.mapStepsForCreateSubscription.get(orderItem.NE__Bundle_Configuration__c).add(step);
                }
                if(!String.isBlank(orderItem.NE__OrderId__c) && checkFlowProductReservation(step)){
                    if(!wrapper.mapStepsForProductReservation.containsKey(orderItem.NE__OrderId__c)) {
                        wrapper.mapStepsForProductReservation.put(orderItem.NE__OrderId__c, new List<XC_Provisioning_Step__c>());
                    }
                    wrapper.mapStepsForProductReservation.get(orderItem.NE__OrderId__c).add(step);
                }
                //  For Manage Payment: 
                if( !String.isBlank(orderItem.NE__OrderId__c) && checkFlowManagePayment(step)){
                    if( !wrapper.mapStepsForManagePayment.containsKey(orderItem.NE__OrderId__c)) {
                        wrapper.mapStepsForManagePayment.put(orderItem.NE__OrderId__c, new List<XC_Provisioning_Step__c>() );
                    }
                     wrapper.mapStepsForManagePayment.get(orderItem.NE__OrderId__c).add(step);
                 }
             } 
         }
        return wrapper;
    }

    /**
    * @description Method to check for Flow Subscription
    * @param step - XC_Provisioning_Step__c
    * @return Boolean
    */
    private static Boolean checkFlowSubscription(XC_Provisioning_Step__c step){
        return (step.XC_Flow_API_Name__c  == Label.XC_CL_ProvisioningCreateSubscription_Flow || step.XC_Flow_API_Name__c  == Label.XC_CL_ProvisioningTriggerInvoice_Flow || step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningChangeBilling_Flow || step.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningTriggerInvoiceBarcode_Flow);
    }

    /**
    * @description Method to check for Flow Subscription
    * @param step - XC_Provisioning_Step__c
    * @return Boolean
    */
    private static Boolean checkFlowProductReservation(XC_Provisioning_Step__c step){
        return (step.XC_Flow_API_Name__c  == Label.XC_CL_ProvisioningProductReservation_Flow);
    }

    /** 
    * @description Method to check for Flow Manage Payment.
    * @param step -  XC_Provisioning_Step__c
    * @return  Boolean
    */ 
    private static Boolean checkFlowManagePayment(XC_Provisioning_Step__c step ){
        return (step.XC_Flow_API_Name__c  == Label.XC_CL_ProvisioningManagePayment_Flow );
     }
}
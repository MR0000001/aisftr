/**
 * @author: Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 14/03/2019
 * @date Modification 31/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @description XC_LCC099_NextStepOrderToProvisioning – Controller of XC_LCP099_NextStepOrderToProvisioning (to manage Compliant Verification and Start Provisioning for an Order)
 */

public without sharing class XC_LCC099_NextStepOrderToProvisioning {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC099_NextStepOrderToProvisioning');
    public static Boolean forTestVar = False;

    /** @description CheckSiteInspectionWrapper */
    public class CheckSiteInspectionWrapper {
        Boolean success = false;
        String message = '';
    }

    /** @description CheckSiteInspectionWrapper */
    public class CheckExternalFinancialWrapper {
        Boolean success = false;
        String message = '';
    }

    /** @description CheckPaymentMethod Wrapper */
    private class CheckPaymentMethodWrapper {
        Boolean success = false;
        String message = '';
    }

    /**
     * @description Evaluate if Compliant Verification needed; execute relatives operations when it's needed, else check executeNextStep true, to evauate the second step.
     * @param configurationId - String
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper implementFirstNextStep(String configurationId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_LCC099_NextStepOrderToProvisioning - implementFirstNextStep');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Map<Id, NE__Order__c> mapConfiguration = getOrderFields(configurationId);
        //NA Adoption Chile and Colombia
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add(mapConfiguration.values()[0].XC_Segment__c);
        Set<string> setLegalEntity2=new Set<String>();
        setLegalEntity2.add(mapConfiguration.values()[0].XC_LegalEntity__c);
        //NA adoption for Chile and Colombia mapConfItem
      /*  for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r){
            if(mapConfiguration.values()[0].XC_LegalEntity__c!=){

            }
        }*/

        //Start EA Affiliati e Beneficiari CR NR1857 29/09/2021
        List<XC_Affiliate_Beneficiary__c> listAffBen =  getAffBenByIdConfiguration(configurationId);
        Map<String,Object> objectValidatedAffBen = checkErrorAffBenByList(listAffBen, configurationId);
        if(!(Boolean)objectValidatedAffBen.get('validate')){
            return populateWrapperFailedStopExecution(rw, (String)objectValidatedAffBen.get('errorMessage'));
        }
        //End EA Affiliati e Beneficiari CR NR1857 29/09/2021

        // method to check order and related objects permissions
        Map<String,Object> objectPermissionsRes = checkObjectPermissions(mapConfiguration);
        if(!(Boolean)objectPermissionsRes.get('hasPermissions')){
            return populateWrapperFailedStopExecution(rw, (String)objectPermissionsRes.get('errorMessage'));
        }

        // method to check order and related objects permissions
        Map<String,Object> needApprovalVat = doNeedVatApproval(mapConfiguration);
        if((Boolean)needApprovalVat.get('needApproval')){
            return populateWrapperFailedStopExecution(rw, (String)needApprovalVat.get('errorMessage'));
        }

        // Check User Code:
        Boolean checkCode = checkUserCode(mapConfiguration);
        if(!checkCode) {
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_UserCodeMandatory);
        }
		
		
        //20211111_DD_PROV_22 - start
        Boolean checkAssociateProvisioning = checkConfiguredProvisioningStepsMetadata(configurationId);
        if(!checkAssociateProvisioning || forTestVar){
            NE__Order__c orderUpdate = new NE__Order__c(
                Id = configurationId,
                XC_Error_Provisioning__c = Label.XC_CL_LCP099_ProvisioningTemplateMissing
            );
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateRecord(orderUpdate);
            if(!Test.isRunningTest())
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_LCP099_ProvisioningTemplateMissing);
        }
        //20211111_DD_PROV_22 - end
        
        //----------------------------------------------------------------------------------------------- Check Site Inspection:

        XC_LCC168_CreateWorkOrderFromOrder.OutputWrapper siteInspectionWrapper = XC_LCC168_CreateWorkOrderFromOrder.createWorkOrder(mapConfiguration.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Site Inspection Wrapper: ' + siteInspectionWrapper);
        if(!siteInspectionWrapper.success) {
            return populateWrapperFailedStopExecution(rw, siteInspectionWrapper.errorMessage);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Site Inspection Pass');
        if(siteInspectionWrapper.isCreated) {
            NE__Order__c orderUpdate = new NE__Order__c(
                Id = configurationId,
                XC_OrderConfirmation__c = Label.XC_CL_ConfirmedOrder
            );
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateRecord(orderUpdate);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
            rw.success = true;
            rw.resultMessage = Label.XC_CL_SiteInspectionCreated;
            rw.typeMessage = 'success';
            return rw;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Site Inspection already exists');
        // Check for existing Site Inspection:
        CheckSiteInspectionWrapper checkWoWrapper = checkSiteInspectionWo(mapConfiguration);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check existing Work Order Site Inspection: ' + checkWoWrapper);
        if(!checkWoWrapper.success) {
            return populateWrapperFailedStopExecution(rw, checkWoWrapper.message);
        }

        //-----------------------------------------------------------------------------------------------------------------------


        Map<String,XC_CM_LegalEntity_Configuration__mdt> mapLeConfigurationCM=XC_Util_LegalEntityOneOrg.getOrgConfigLegalEntities(setLegalEntity2,setSegmanet);
        // Check Order Status:
        if(!checkOrderStatus(mapConfiguration.values()[0])) {
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_Configuration_ErrorStatus);
        }
        // NR1455 - Return Rethinking - SS 03/02/2021
        if(isDisconnectionWithoutActivitiesOrder(mapConfiguration.values()[0])){
            List<NE__Order_Item_Attribute__c> orderItemAttributesList = getOrderItemAttributes(configurationId);
            if(checkManualLogisticActivities(orderItemAttributesList)){
                return populateWrapperFailedStopExecution(rw, Label.XC_CL_ErrorMessage_LogisticActivitiesRequired);
            }
        }
        // Check if Account has a document:
        if(!checkAccountDocument(mapConfiguration.values()[0])) {
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_Order_DocumentNeeded + ' ' + mapConfiguration.values()[0].NE__AccountId__r.Name);
            /*rw.success = false;
            rw.resultMessage = Label.XC_CL_Order_DocumentNeeded + ' ' + mapConfiguration.values()[0].NE__AccountId__r.Name;
            rw.typeMessage = 'error';
            rw.executeNextStep = false;
            return rw;*/
        }

        // Check for Payment method and Creation of External Financing Case
        CheckPaymentMethodWrapper checkMPWrapper = checkPaymentMethod(configurationId, mapConfiguration);
        if(!checkMPWrapper.success){
            return populateWrapperFailedStopExecution(rw, checkMPWrapper.message);
        }

        // Check for Billing Profile Line Item:
      	for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r){
            if(orderItem.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c !='OpenCharge B2B'){
                //20220126 HotTopic_PROV_41 - [DO] – start
        		if(!XC_UTIL_ConfigurationItem.checkBillingProfile(mapConfiguration.values()[0].NE__Order_Items__r, mapConfiguration.values()[0].XC_Subtype__c == 'Change of ownership' ? 'Change of ownership' : 'Provisioning')) {
                    //20220126 HotTopic_PROV_41 - [DO] – end
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_ErrorMissingBPLI);
        }
		    }
        }

        // Check the action of order items for change order
        if(!checkActionsForChangeOrder(mapConfiguration)) {
            if(mapConfiguration.values()[0].XC_Subtype__c == Label.XC_CL_ConfigurationSubtype_PromocodeApplication) {
                return populateWrapperFailedStopExecution(rw, Label.XC_CL_Configuration_NextStepError_AddCoupon);
            } else {
                return populateWrapperFailedStopExecution(rw, Label.XC_CL_Configuration_NextStepError_AddRemoveProducts);
            }
        }

        //check current billing profile line item on change order - change billing profile
        if(!checkCurrentAndPreviousBpli(mapConfiguration, 'Provisioning')) {
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_SameBpliOnChangeOrder);
        }

        // Check for Billing Profile Line Item Status:
        if(!checkStatusBillingProfileLineItem(mapConfiguration.values()[0].NE__Order_Items__r, mapConfiguration.values()[0].NE__Type__c)) {
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_ErrorStatusBillingProfile);
        }

            // Check for External financing:
            CheckExternalFinancialWrapper checkExtFinWrap = checkExternalFinancing(configurationId, mapConfiguration);
            if(!checkExtFinWrap.success){
                return populateWrapperFailedStopExecution(rw, checkExtFinWrap.message);
                /*rw.success=false;
                rw.resultMessage = checkExtFinWrap.message;
                rw.typeMessage = 'error';
                rw.executeNextStep = false;
                return rw;*/
            }



       //Check Online payment
        if(!checkOnlinePayment(configurationId, mapConfiguration)) {
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_Online_ErrorMessage);
        }


        //Check WBE/WBS
        System.debug('Check WBE' + checkWBE(mapConfiguration));
        if(checkWBE(mapConfiguration)) {
            return populateWrapperFailedStopExecution(rw, Label.XC_insertWBE);
            /*rw.success = false;
            rw.resultMessage = Label.XC_insertWBE;
            rw.typeMessage = 'error';
            rw.executeNextStep = false;
            return rw;*/
        }
        if(mapConfiguration.values()[0].XC_Segment__c != 'B2C' && XC_LCC250_CreditCheckVerify.checkInstallmentPlan(mapConfiguration.values()[0].NE__Order_Items__r)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_CreditCheckInstallmentPlan);
        }

        if(checkWBEApproved(mapConfiguration)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_CheckWBEApproved);
        }
        /*GS*/ if(checkPOD(mapConfiguration)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_CheckPOD);
        }

        /* Mod CV CR.NR2044
        *@ Add error to Chekc correct date
        Start --> */
        Map<String,Object> objectValidateAdjustment = checkReccurringAdjustDate(mapConfiguration);
        if(!(Boolean)objectValidateAdjustment.get('validate')){
            return populateWrapperFailedStopExecution(rw, (String)objectValidateAdjustment.get('errorMessage'));
        }
        //<-- End

        //Check credit assignment
        if(Boolean.valueOf(checkCreditAssignment(mapConfiguration).get('checkResult'))) {
            return populateWrapperFailedStopExecution(rw, String.valueOf(checkCreditAssignment(mapConfiguration).get('errorMsg')));
            /*rw.success = false;
            rw.resultMessage = Label.XC_CL_ConfItem_CreditAssignmentRequiredFields;
            rw.typeMessage = 'error';
            rw.executeNextStep = false;
            return rw;*/
        }

        //Check Zip Code BlackList
        // Map<String,Object> zipCodeBLCheck = checkBlackListOnOrderItems(mapConfiguration);
        // if(Boolean.valueOf(zipCodeBLCheck.get('checkResult'))){
        //     return populateWrapperFailedStopExecution(rw,String.valueOf(zipCodeBLCheck.get('errorMsg')));
        // }

        //Check OTP Signature presence for credit assignment flow
        Map<String,Object> otpSignatureCheck = checkOTPSignatureCreditAssignment(mapConfiguration);
        Map<String,Object> callRecCheck = checkCallRecordingIfOrderFromCTI(mapConfiguration);
        if(Boolean.valueOf(callRecCheck.get('checkResult'))){
            return populateWrapperFailedStopExecution(rw,String.valueOf(callRecCheck.get('errorMsg')));
        }

        if(Boolean.valueOf(otpSignatureCheck.get('checkResult'))) {
            //Check call recording presence in case order has been created from CTI channel
            if(!checkisFromCTI(mapConfiguration)) {
                return populateWrapperFailedStopExecution(rw,String.valueOf(otpSignatureCheck.get('errorMsg')));
            }
        }


        //NA modified for Chile and Colombia adoption
        if(checkDurationWhenBillingModelIsRecurring(mapConfiguration,mapLeConfigurationCM)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_DurationField_Is_Filled);

        }
         //NA modified for Chile and Colombia adoption
        if(checkCreditCheck(mapConfiguration,mapLeConfigurationCM)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_CreditCheckMessage);
        }
        //NA modified for Chile and Colombia Adoption
        if(checkContractIsSigned(mapConfiguration,mapLeConfigurationCM)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_VerifyContractIsSigned);
        }
        if(checkContractCigCugDetermina(mapConfiguration)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_Contract_Fill_CigCup);
        }

        if(checkExtensionField(mapConfiguration)){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_ContractEstension);
        }

        //NA modified for Chile and Colombia Adoption

        if(checkInstallmentPlan(mapConfiguration,mapLeConfigurationCM)){
            return populateWrapperFailedStopExecution(rw,Label.XC_CL_CheckInstallmentPlanIsApproved);
        }

        if(checkProvvissiongIsComplexCapex(mapConfiguration) ){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_CapexButNotPPM);
        }


        if(mapConfiguration.values()[0].xc_segment__c != 'B2C' && checkProvisioningType(mapConfiguration) ){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_NoAddTechnicalItem);
        }




        //NA0302
        //check for dane code confItem
        List<NE__OrderItem__c> configurationsItems= new List<NE__OrderItem__c>();
        if(Schema.SObjectType.NE__OrderItem__c.isAccessible()){
            configurationsItems=[select id,NE__OrderId__r.XC_LegalEntity__c, XC_Segment__c, NE__OrderId__c,XC_DaneCode__c
                                                from NE__OrderItem__c
                                                where NE__OrderId__r.XC_LegalEntity__c='Codensa' and

                                                XC_Segment__c !='B2C' and

                                                XC_DaneCode__c=null and
                                                NE__OrderId__c=: configurationId];
            system.debug('populate confogiurationItems List');
         }
         system.debug('size configurationsItems' +' '+configurationsItems.size());
         if(!configurationsItems.isEmpty()){
            return populateWrapperFailedStopExecution(rw, Label.XC_OperationNotAllowedWithouthDaneCode);
            /*rw.success = false;
            rw.resultMessage = Label.XC_OperationNotAllowedWithouthDaneCode;
            rw.typeMessage = 'error';
            rw.executeNextStep = false;
            return rw;*/
        }

        // Check for Compliance:
        //Boolean isComplianceNeeded = XC_LCC069_ComplianceVerification1.checkCompliance1Needed(configurationId);
        XC_UTIL_ResultWrapper checkRW = XC_LCC069_ComplianceVerification1.checkCompliance1NeededOrToSkeep(configurationId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isComplianceNeeded result = '+checkRW);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_LCC099_NextStepOrderToProvisioning');
        if(checkRW.success && checkRW.outcome){ //isComplianceNeeded
            XC_UTIL_ResultWrapper compliance1RW = XC_LCC069_ComplianceVerification1.checkDocumentsComplianceVerification1(configurationId);
            rw.success = compliance1RW.success;
            rw.resultMessage = compliance1RW.resultMessage;
            rw.typeMessage = compliance1RW.typeMessage;
            rw.executeNextStep = compliance1RW.executeNextStep;
            if(compliance1RW.executeNextStep && checkProvvissiongIsComplex(mapConfiguration)){
                return XC_LCC186_CreateProjectCheckProvIsOk.checkProvvisioning(configurationId);
            }
        }else if(checkRW.success){
            //evaluate next step
            rw.success=true;
            rw.executeNextStep = true;
            rw.resultMessage = checkRW.resultMessage;
            if(checkProvvissiongIsComplex(mapConfiguration)){
                return XC_LCC186_CreateProjectCheckProvIsOk.checkProvvisioning(configurationId);
            }
        }
        else {
            rw.success=false;
            rw.resultMessage = checkRW.resultMessage;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ NextStepOrderToProvisioning FirstNextStep result='+rw);
        return rw;
    }

    /**
     * @description Evaluate if Start Provisioning need and if true insert provisioning steps
     * @param configurationId - String
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper implementSecondNextStep(String configurationId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_LCC099_NextStepOrderToProvisioning - implementSecondNextStep');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        Boolean checkNeedWBE = XC_LCC_056_CalculateWBS_U.checkWBEForPenality(configurationId);
        if(checkNeedWBE){
            populateWrapperSuccess(rw, Label.XC_insertWBE, 'error');
            /*rw.success=true;
            rw.resultMessage = Label.XC_insertWBE;
            rw.typeMessage = 'error';*/
            return rw;
        }

        Boolean isToChangeInProvisioning = XC_LCC048_OrderInProvisioning.checkCompliance1Status(configurationId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isToChangeInProvisioning='+isToChangeInProvisioning);

        if(isToChangeInProvisioning) {
            manageChangeInProvisioning(configurationId, rw);
        }else{
            populateWrapperSuccess(rw, Label.XC_CL_CompleteComplianceVerification, 'error');
            /*rw.success=true;
            rw.resultMessage = Label.XC_CL_CompleteComplianceVerification;
            rw.typeMessage = 'error';*/
        }
        return rw;
    }

    /**
     * @description Execute the update of the order status and its provisioning steps
     * @param configurationId - String
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper implementThirdNextStep(String configurationId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_LCC099_NextStepOrderToProvisioning - implementThirdNextStep');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Boolean checkSimpleProvisioning = checkConfiguredProvisioningSteps(configurationId);
        if(!checkSimpleProvisioning){
            return populateWrapperFailedStopExecution(rw, Label.XC_CL_LCP099_ProvisioningTypeError);
        }
        NE__Order__c orderUpdate = new NE__Order__c(
            //20211111_DD_PROV_22 - start
            XC_Error_Provisioning__c = '',
            //20211111_DD_PROV_22 - end
            Id = configurationId,
            XC_OrderConfirmation__c = Label.XC_CL_ConfirmedOrder
            
        );
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateRecord(orderUpdate);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        return XC_LCC048_OrderInProvisioning.updateOrderStatus(configurationId);
    }

    /**
     * @description Method to populare Result Wrapper for Error
     * @param rw - XC_UTIL_ResultWrapper
     * @param resultMessage - String
     * @return XC_UTIL_ResultWrapper
     */
    private static XC_UTIL_ResultWrapper populateWrapperFailedStopExecution(XC_UTIL_ResultWrapper rw, String resultMessage){
        rw.success = false;
        rw.resultMessage = resultMessage;
        rw.typeMessage = 'error';
        rw.executeNextStep = false;
        return rw;
    }

    /**
     * @description Method to populare Result Wrapper for Success
     * @param rw - XC_UTIL_ResultWrapper
     * @param resultMessage - String
     * @param typeMessage - String
     * @return XC_UTIL_ResultWrapper
     */
    private static void populateWrapperSuccess(XC_UTIL_ResultWrapper rw, String resultMessage, String typeMessage){
        rw.success = true;
        rw.resultMessage = resultMessage;
        rw.typeMessage = typeMessage;
    }

    /**
     * @description method to insert provisioning steps
     * @param configurationId - String
     * @param rw - XC_UTIL_ResultWrapper
     */
    public static void manageChangeInProvisioning(String configurationId, XC_UTIL_ResultWrapper rw){
        WorkOrder wo = new WorkOrder();
        XC_UTIL_ProvisioningStep.ResultWrapper stepRw = XC_LCC048_OrderInProvisioning.insertProvisioningSteps(configurationId, 'XC_LCC099_NextStepOrderToProvisioning');
        XC_UTIL_ProvisioningStep_U.CheckStepWrapper checkStepdWrapper = XC_UTIL_ProvisioningStep_U.checkProvisioningStep(configurationId);
        if(checkStepdWrapper.numberStep > 1 && stepRw.order.Work_Orders__r.isEmpty()) {
            wo = createWorkOrder(stepRw.order, checkStepdWrapper.numberStep);
            XC_UTIL_Sobject.insertRecord(wo);
        }

        Map<String, Map<String, List<XC_Provisioning_Step__c>>> mapStepToUpdate = new Map<String, Map<String, List<XC_Provisioning_Step__c>>>();
        for(String bundleId : checkStepdWrapper.mapStepsForCreateSubscription.keySet()) {
            Map<String, List<XC_Provisioning_Step__c>> mapStep = new Map<String, List<XC_Provisioning_Step__c>>();
            mapStepToUpdate.put(bundleId, new Map<String, List<XC_Provisioning_Step__c>>());
            for(Integer i=0; i<checkStepdWrapper.mapStepsForCreateSubscription.get(bundleId).size(); i++) {
                if(!mapStep.containsKey(checkStepdWrapper.mapStepsForCreateSubscription.get(bundleId)[i].XC_Flow_API_Name__c)) {
                    mapStep.put(checkStepdWrapper.mapStepsForCreateSubscription.get(bundleId)[i].XC_Flow_API_Name__c, new List<XC_Provisioning_Step__c>());
                } else {
                    mapStep.get(checkStepdWrapper.mapStepsForCreateSubscription.get(bundleId)[i].XC_Flow_API_Name__c).add(checkStepdWrapper.mapStepsForCreateSubscription.get(bundleId)[i]);
                }
            }
            if(!mapStep.keySet().isEmpty()) {
                for(String keyMapStep : mapStep.keySet()) {
                    mapStepToUpdate.get(bundleId).put(keyMapStep, mapStep.get(keyMapStep));
                }
            }
        }
        List<XC_Provisioning_Step__c> listStepToUpdate = new List<XC_Provisioning_Step__c>();
        for(String keyMapStepToUpdate : mapStepToUpdate.keySet()) {
            Map<String, List<XC_Provisioning_Step__c>> mapStepForOrderItem = mapStepToUpdate.get(keyMapStepToUpdate);
            for(String key : mapStepForOrderItem.keySet()) {
                for(XC_Provisioning_Step__c step : mapStepForOrderItem.get(key)) {
                    step.XC_MasterOfSubscription__c = false;
                    listStepToUpdate.add(step);
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(listStepToUpdate);
        // Logic for unique product reservation step SS 06/07/2020
        Map<String, List<XC_Provisioning_Step__c>> orderIdProvisioningMap = checkStepdWrapper.mapStepsForProductReservation;
        List<XC_Provisioning_Step__c> productReservationStepList = new List<XC_Provisioning_Step__c> ();
        if(!orderIdProvisioningMap.isEmpty() && !String.isEmpty(wo.Id)){
            if(orderIdProvisioningMap.containsKey(configurationId)){
                productReservationStepList = orderIdProvisioningMap.get(configurationId);
                Integer stepNumber = productReservationStepList.size();
                for(Integer i = 1; i < stepNumber; i++){
                    productReservationStepList[i].XC_MasterofProductReservation__c = false;
                }
            }
        }
        // Logic for unique manage payment step SS 12/11/2020
        Map<String, List<XC_Provisioning_Step__c>> orderIdManagePaymentStepMap = checkStepdWrapper.mapStepsForManagePayment;
        List<XC_Provisioning_Step__c> managePaymentStepList = new List<XC_Provisioning_Step__c> ();
        if(!orderIdManagePaymentStepMap.isEmpty()){
            if(orderIdManagePaymentStepMap.containsKey(configurationId)){
                managePaymentStepList = orderIdManagePaymentStepMap.get(configurationId);
                Integer stepNumber = managePaymentStepList.size();
                for(Integer i = 1; i < stepNumber; i++){
                    managePaymentStepList[i].XC_MasterOfManagePayment__c = false;
                }
            }
        }
        List<XC_Provisioning_Step__c> listProvisioningStepToUpdate = new List<XC_Provisioning_Step__c>();
        if(!productReservationStepList.isEmpty()){
            listProvisioningStepToUpdate.addAll(productReservationStepList);
        }
        if(!managePaymentStepList.isEmpty()){
            listProvisioningStepToUpdate.addAll(managePaymentStepList);
        }
        // Update Order Items:
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(checkStepdWrapper.mapOrderItemToUpdate.values());
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        XC_UTIL_Sobject.updateListRecords(listProvisioningStepToUpdate);
        rw.success = true;
        rw.executeNextStep = true;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Create Work Order root with Configuration Id
     * @param order - NE__Order__c
     * @param numberStepsDeliveryInstallation - Integer
     * @return WorkOrder
     */
    @TestVisible
    private static WorkOrder createWorkOrder(NE__Order__c order, Integer numberStepsDeliveryInstallation) {
        WorkOrder wo = new WorkOrder(
                XC_Configuration__c = order.Id,
                XC_ReadyToBeBooked__c = false,
                XC_WorkTypeLabel__c = Label.XC_CL_WorkType_DeliveryInstallation,
                XC_HierarchyLevel__c = 0,
                XC_isTree__c = true,
                Street = order.XC_InstallationAddress__r.XC_Address__c,
                PostalCode = order.XC_InstallationAddress__r.XC_PostalCode__c,
                City = order.XC_InstallationAddress__r.XC_City__c,
                Country = order.XC_InstallationAddress__r.XC_AddressCountry__c,
                XC_Address__c = order.XC_InstallationAddress__c,
                XC_NumberWorkOrdersDI__c = numberStepsDeliveryInstallation,
                AccountId = order.NE__OptyId__r.AccountId,
                ContactId = order.NE__OptyId__r.XC_Contact__c,
                XC_Segment__c = order.XC_Segment__c,
                XC_CreatedAutomaticallyBySystem__c = true
        );
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Work Order created with LCC099: ' + wo);
        return wo;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/10/2019
     * @description Method to check if a Site Inspection Work Order exists (with final status)
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return CheckSiteInspectionWrapper
     */
    private static CheckSiteInspectionWrapper checkSiteInspectionWo(Map<Id, NE__Order__c> mapConfiguration) {
        CheckSiteInspectionWrapper outputWrapper = new CheckSiteInspectionWrapper();
        if(mapConfiguration.values()[0].XC_Segment__c == 'B2B' || mapConfiguration.values()[0].XC_Segment__c =='B2G'){
            outputWrapper.success = true;
            return outputWrapper;
        }
        if(mapConfiguration.values()[0].NE__Type__c != Label.XC_CL_Configuration_TypeInOrder) {
            outputWrapper.success = true;
            return outputWrapper;
        }
        Boolean photovolaticFound = false;
        String allChannelForSkipSiteInspection = '';
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.NE__CatalogItem__r.XC_Site_Inspection_Required__c) {
                photovolaticFound = true;
                allChannelForSkipSiteInspection = orderItem.NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c;
                break;
            }
        }
        List<NE__Order__c> listOfQuote = new List<NE__Order__c>();
        if (photovolaticFound){
            listOfQuote = [SELECT Id, XC_ReceivingChannelFormula__c FROM NE__Order__c WHERE RecordType.DeveloperName =: Label.XC_CL_Configuration_RtQuote AND NE__OptyId__c =: mapConfiguration.values()[0].NE__OptyId__c AND XC_Status__c =: Label.XC_CL_Configuration_QuoteAccepted];
        }
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BlockNotRequiredSiteInspection__c
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_Stream__c = :mapConfiguration.values()[0].XC_Segment__c AND XC_LegalEntity__c = :mapConfiguration.values()[0].XC_LegalEntity__c
        ]);
        String receivingChannel = listOfQuote.isEmpty() ? mapConfiguration.values()[0].XC_ReceivingChannelFormula__c : listOfQuote[0].XC_ReceivingChannelFormula__c;
        Boolean skipSiteInspectionFromReceivingChannel = allChannelForSkipSiteInspection != null && receivingChannel != null && allChannelForSkipSiteInspection.contains(receivingChannel);
        if(!photovolaticFound ||(skipSiteInspectionFromReceivingChannel && photovolaticFound)) {
            outputWrapper.success = true;
            return outputWrapper;
        }
        else {
            List<WorkOrder> listWo = new List<WorkOrder>([
                    SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c, Status
                    FROM WorkOrder
                    WHERE XC_Configuration__c = :mapConfiguration.values()[0].Id
            ]);

            Boolean checkWoSuccess = false;
            for(WorkOrder wo : listWo) {
                if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection && wo.Status == Label.XC_CL_Completed) {
                    checkWoSuccess = true;
                    // outputWrapper.success = true;
                    // return outputWrapper;
                }
            }

            // Check on technical products
            List<XC_CM_LegalEntity_Configuration__mdt> listLEconf = new List<XC_CM_LegalEntity_Configuration__mdt>([
                SELECT Id, XC_BlockNotRequiredSiteInspection__c,XC_SiteInspReqTechProdSubType__c ,XC_SkipTechProdbyCatInterest__c
                FROM XC_CM_LegalEntity_Configuration__mdt
                WHERE XC_LegalEntity__c = :mapConfiguration.values()[0].XC_LegalEntity__c AND XC_Stream__c = :mapConfiguration.values()[0].XC_Segment__c
            ]);
            if(checkWoSuccess){
                Map<String,Object> techProductResult = checkTechProductMandatoriety(mapConfiguration,listLEconf);
                outputWrapper.success = Boolean.valueOf(techProductResult.get('checkResult'));
                outputWrapper.message = String.valueOf(techProductResult.get('errorMsg'));
                return outputWrapper;
            }

            outputWrapper.message = Label.XC_CL_SiteInspectionErrorProvisioning;
            return outputWrapper;
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/10/2019
     * @description Method to check external financing
     * @param orderId - String
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return CheckSiteInspectionWrapper
     */
    private static CheckExternalFinancialWrapper checkExternalFinancing(String orderId, Map<Id, NE__Order__c> mapConfiguration) {
        CheckExternalFinancialWrapper outputWrapper = new CheckExternalFinancialWrapper();
        Boolean externalFinancingFound = false;
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.XC_PaymentMethod__c == 'External Financing') {
                externalFinancingFound = true;
                break;
            }
        }
        if(externalFinancingFound && mapConfiguration.values()[0].NE__Type__c == Label.XC_CL_Configuration_TypeInOrder && !checkFieldsForExternalFinancing(orderId, mapConfiguration)){
            outputWrapper.message = Label.XC_CL_ExternalFinancingNotApproved;
        }else{
            outputWrapper.success = true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check external financing: ' + outputWrapper);
        return outputWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/10/2019
     * @description Method to check fields for external financing
     * @param orderId - String
     * @param mapConfiguration
     * @return CheckSiteInspectionWrapper
     */
    public static Boolean checkFieldsForExternalFinancing(String orderId, Map<Id, NE__Order__c> mapConfiguration) {
        NE__Order__c order = mapConfiguration.get(orderId);
        if(String.isEmpty(order.XC_FinancialPracticeStatus__c) || String.isEmpty(order.XC_FinancialPracticeNumber__c) || String.isEmpty(order.XC_FinancialInstitution__c) || order.XC_FinancialPracticeStatus__c != 'OK'){
            return false;
        }
        return true;
    }

    /**
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @date 03/08/2021
     * @description Method to check the items action for change order
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return Boolean
     */
    public static Boolean checkActionsForChangeOrder(Map<Id, NE__Order__c> mapConfiguration) {

        NE__Order__c configurationOrder = mapConfiguration.values()[0];

        if(configurationOrder.XC_Segment__c == 'B2C' && configurationOrder.NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder &&
            (configurationOrder.XC_Subtype__c == Label.XC_CL_ConfigurationSubtype_PromocodeApplication || configurationOrder.XC_Subtype__c == Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade)) {

            Boolean change = false;
            Boolean add = false;
            Boolean remove = false;
            for(NE__OrderItem__c oi : configurationOrder.NE__Order_Items__r){
                change = (oi.NE__Action__c == 'Change' && oi.NE__Root_Order_Item__c == null && oi.XC_Product_Type__c != 'Billing') ? true : change;
                add = (oi.NE__Action__c == 'Add') ? true : add;
                remove = (oi.NE__Action__c == 'Remove') ? true : remove;
            }

            if((configurationOrder.XC_Subtype__c == Label.XC_CL_ConfigurationSubtype_PromocodeApplication && change) ||
                (configurationOrder.XC_Subtype__c == Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade && add && remove)){
                    return true;
            }

            return false;

        } else {
            return true;
        }
    }

    /**
     * @author Luisana Rocco - lrocco@deloitte.it
     * @date 18/01/2021
     * @description Method to check current and previous bpli
     * @param operation - String
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return  Boolean
     */
    public static Boolean checkCurrentAndPreviousBpli(Map<Id, NE__Order__c> mapConfiguration, String operation) {

        if(mapConfiguration.values()[0].XC_Segment__c == 'B2C' && mapConfiguration.values()[0].NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder && mapConfiguration.values()[0].XC_Subtype__c == 'Change Billing Profile'){

            XC_UTIL_ConfigurationItem.CheckBillingProfileWrapper bpWrapper = XC_UTIL_ConfigurationItem.getCorrectBillingProfile(mapConfiguration.values()[0].NE__Order_Items__r, operation);
            for(NE__OrderItem__c oiToCheck : bpWrapper.listOrderItem){
                if(!String.isblank(oiToCheck.XC_BillingProfileLineItem__c) && oiToCheck.XC_PreviousBillingProfileLineItem__c == oiToCheck.XC_BillingProfileLineItem__c){
                    return false;
                }
            }
            return true;

        }else{
            return true;
        }
    }

    /**
     * @author Luisana Rocco - lrocco@deloitte.it
     * @date 19/01/2021
     * @description Method to check objectPermission
     * @return  Boolean
     */
    private static Map<String,Object> checkObjectPermissions(Map<Id, NE__Order__c> mapConfiguration) {

        Map<String,Object> checkResult = new Map<String,Object>();
        checkResult.put('hasPermissions', true);
        checkResult.put('errorMessage', ' ');

        if(mapConfiguration.values()[0].XC_Segment__c == 'B2C'){
            UserRecordAccess userSharingRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: mapConfiguration.values()[0].ID];
            if(userSharingRecordAccess.HasEditAccess && Schema.SObjectType.NE__Order__c.isUpdateable()){ // check sharing and object CRUD permissions
                if(
                        !Schema.SObjectType.NE__OrderItem__c.isUpdateable() || !Schema.SObjectType.NE__Order_Item_Attribute__c.isUpdateable() ||
                                !Schema.SObjectType.B2WExtCat__Work_Order__c.isUpdateable() ||  !Schema.SObjectType.B2WExtCat__Work_Order__c.isCreateable() ||
                                !Schema.SObjectType.B2WExtCat__Work_Order_Item__c.isUpdateable() ||  !Schema.SObjectType.B2WExtCat__Work_Order_Item__c.isCreateable() ||
                                !Schema.SObjectType.B2WExtCat__External_Catalog_Association__c.isAccessible() || !Schema.SObjectType.B2WExtCat__External_Catalog_Item__c.isAccessible()
                        ){ // check object CRUD permissions
                    checkResult.put('hasPermissions', false);
                    checkResult.put('errorMessage', Label.XC_CL_ObjectPermissionsError);
                    return checkResult;
                }
            }else{
                checkResult.put('hasPermissions', false);
                checkResult.put('errorMessage', Label.XC_CL_OrderPermissionError);
                return checkResult;
            }
        }
        return checkResult;
    }

    /**
     * @author Federico Angelini - fangelini@deloitte.it
     * @date 24/06/2021
     * @description check if configuration items XC_Need_approval_VAT_exempt__c is true
     * @return  Map<String,Object>
     */
    private static Map<String,Object> doNeedVatApproval(Map<Id, NE__Order__c> mapConfiguration) {

        Map<String,Object> checkResult = new Map<String,Object>();
        checkResult.put('needApproval', false);
        checkResult.put('errorMessage', '');
        NE__Order__c configurationOrder = mapConfiguration.values()[0];

        if(configurationOrder.XC_LegalEntity__c == 'Codensa' && (configurationOrder.XC_Segment__c == 'B2G' || configurationOrder.XC_Segment__c == 'B2B')){
            for (NE__OrderItem__c configItem :configurationOrder.NE__Order_Items__r){
                if (configItem.XC_Need_approval_VAT_exempt__c){
                    checkResult.put('needApproval', true);
                    checkResult.put('errorMessage', (String) 'A configuration item needs approval');
                    return checkResult;
                }
            }
        }
        return checkResult;
    }


/**
     * @author Luisana Rocco - lrocco@deloitte.it
     * @date 16/11/2020
     * @description Method to check Online payment
     * @param orderId - String
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return  Boolean
     */
    public static Boolean checkOnlinePayment(String orderId, Map<Id, NE__Order__c> mapConfiguration) {

        Boolean onlineFound = false;
        String rtOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
      
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.XC_PaymentMethod__c == Label.XC_CL_Online) {
                onlineFound = true;
                break;
            }
        }

        if(onlineFound && mapConfiguration.values()[0].NE__Type__c == Label.XC_CL_Configuration_TypeInOrder && mapConfiguration.get(orderId).RecordTypeId == rtOrder && String.isEmpty(mapConfiguration.get(orderId).XC_PaymentTransactionID__c)){
            return false;
        }

        return true;
    }


    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/11/2019
     * @description Method to check if Account has a document
     * @param order - NE__Order__c
     * @return Boolean
     */
    private static Boolean checkAccountDocument(NE__Order__c order) {
        if((order.NE__Type__c != Label.XC_CL_Configuration_TypeInOrder) || (String.isNotBlank(order.NE__AccountId__r.IdentityType__c) && String.isNotBlank(order.NE__AccountId__r.IdentityNumber__c) && String.isNotBlank(order.NE__AccountId__r.XC_DocumentCountry__c))) {
            return true;
        }
        return false;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 05/11/2019
     * @description Method to get field from Order
     * @param orderId - String
     * @return Map<Id, NE__Order__c>
     *  Mod CV CR.NR2044 08/10/2021
     *  Description:
       Add two field to query XC_Billing_Period_Recurring__c , XC_Effective_Start_Date_Recurring__c,NE__ProdName__c on NE__Order_Items__r to check date
     */
    private static Map<Id, NE__Order__c> getOrderFields(String orderId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Get fields for order ' + orderId);
        return new Map<Id, NE__Order__c>([
                SELECT Id, XC_FinancialPracticeStatus__c, XC_SignedByExternal__c, XC_InstallationAddress__c, XC_BillingModel__c, XC_Status__c, NE__Type__c, NE__AccountId__c,NE__OptyId__r.XC_Contact__c, XC_ReceivingChannelFormula__c, XC_ManualLogisticActivities__c,
                XC_FinancialPracticeNumber__c, XC_FinancialInstitution__c, NE__AccountId__r.IdentityType__c, NE__Configuration_Type__c, XC_Country__c,
                NE__AccountId__r.IdentityNumber__c, NE__AccountId__r.XC_DocumentCountry__c, NE__AccountId__r.Name, NE__OptyId__r.AccountId, NE__OptyId__r.XC_ContractType__c, NE__OptyId__r.XC_ModeOfEngagement__c, NE__OptyId__r.XC_BusinessModel__c,
                NE__OptyId__r.XC_ProductCategoryOfInterest__c, NE__OptyId__r.XC_Address__r.XC_PostalCode__c,NE__OptyId__c, XC_EmobilityWebAppType__c,
                XC_LegalEntity__c, XC_Segment__c, NE__OptyId__r.XC_CTI_Interaction__c,XC_CTICallRecording__c, NE__OptyId__r.XC_ReceivingChannel__c, NE__OptyId__r.XC_CreditCheck_GB__c, XC_ProvisioningType__c,
                XC_Subtype__c, XC_Substatus__c, XC_ExtensionMonths__c, XC_PaymentTransactionID__c, RecordTypeId, XC_UserNumber__c,XC_InstallationAddress__r.XC_ElectricCUPS__c,XC_POD__c,
                (SELECT Id, InstallmentDivisionTax__c, XC_InstallmentFrequency__c, XC_InstallmentPlanType__c, XC_InstallmentRate__c, XC_InstallmentsNumber__c, XC_IsAProduct__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_ProvisioningSpareParts__c, XC_BillingProfileLineItem__r.XC_Status__c, Name, XC_PaymentMethodNeeded__c, XC_BillingProfileLineItem__c, XC_LegalEntityFormula__c, XC_PaymentMethod__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c,NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c ,XC_Wbe__c, XC_CreditAssignmentAvailable__c,
                        XC_CityCode__c, XC_UrbanSection__c, RecordType.DeveloperName, XC_Sheet__c, XC_Particle__c, XC_Subordinate__c, XC_HouseType__c,NE__ProdId__c, XC_Complex_Product__c, XC_RecurringDuration__c, XC_BillingModel__c, XC_LegalEntity__c, XC_Segment__c, XC_WBE_Status__c, XC_PreviousBillingProfileLineItem__c, XC_Need_approval_VAT_exempt__c, NE__Action__c, NE__Root_Order_Item__c,XC_Billing_Period_Recurring__c,XC_Effective_Start_Date_Recurring__c,NE__ProdName__c,XC_RecurringPeriodType__c,NE__CatalogItem__c, NE__CatalogItem__r.NE__ProductId__c, NE__CatalogItem__r.NE__ProductId__r.XC_LIC_Product_Name__c,NE__OrderId__r.XC_POD__c,NE__OrderId__c,NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c, NE__OrderId__r.XC_EmobilityWebAppType__c, NE__EndDate__c
                FROM NE__Order_Items__r where RecordType.DeveloperName != 'Technical_Item'),
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c, Status FROM Work_Orders__r)
                // @ Mod CV CR.NR1652 @date 29/10/2021 add XC_Zone__c to quey
                ,(SELECT Id, StartDate FROM Contract__r)
                FROM NE__Order__c
                WHERE Id =: orderId]);
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @date 05/11/2019
     * @description Method to check payment method
     * @param orderId - String
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return CheckPaymentMethodWrapper
     */
    private static CheckPaymentMethodWrapper checkPaymentMethod(String orderId, Map<Id, NE__Order__c> mapConfiguration) {
        CheckPaymentMethodWrapper outputWrapper = new CheckPaymentMethodWrapper();
        Boolean externalFinancingFound = false;
        if(!XC_UTIL_Configuration.areOrderItemsPaymentMethodsOk(orderId)){
            outputWrapper.message =Label.XC_CL_PaymentMethodsRequiredMess;
        }else{
            outputWrapper.success = true;
        }
        return outputWrapper;
    }

    /**
     * @author Donato lombardi - dolombardi@deloitte.it
     * @date 10/12/2019
     * @description Method to check WBE field
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return Boolean
     */
    private static Boolean checkWBE(Map<Id, NE__Order__c> mapConfiguration){
        Boolean wbeCheck = false;
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.RecordType.DeveloperName != 'Technical_Item'){
                if(orderItem.XC_Wbe__c == null && orderItem.XC_Segment__c != 'B2C') {
                    wbeCheck = true;
                    break;
                }
            }
        }
        return wbeCheck;
    }

    /**
     * @author Luisana Rocco - lrocco@deloitte.it
     * @date 02/03/2020
     * @description Method to check if all fields for credit assignment are filled
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return Boolean
     */
    private static Map<String,Object> checkCreditAssignment(Map<Id, NE__Order__c> mapConfiguration){
        Map<String,Object> result = new Map<String,Object>();
        Boolean fieldsCheck = false;
        String errorItems = '';
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeIncentive && orderItem.XC_CreditAssignmentAvailable__c && (String.isBlank(orderItem.XC_CityCode__c)
                || String.isBlank(orderItem.XC_Sheet__c) || String.isBlank(orderItem.XC_Particle__c)  || String.isBlank(orderItem.XC_Subordinate__c) ||
                String.isBlank(orderItem.XC_HouseType__c))) {
                fieldsCheck = true;
                errorItems += orderItem.Name + ' ';
            }
        }
        result.put('checkResult',fieldsCheck);
        result.put('errorMsg',Label.XC_CL_ConfItem_CreditAssignmentRequiredFields + ' ' + errorItems);
        return result;
    }

    /**
     * @author Francesco Imperioli - fimperioli@deloitte.it
     * @createdate 19-03-2020
     * @description: check orderItems blacklist
     */

    // private static Map<String,Object> checkBlackListOnOrderItems(Map<Id, NE__Order__c> mapConfiguration){
    //     String orderLE = mapConfiguration.values()[0].XC_LegalEntity__c;
    //     String orderStream = mapConfiguration.values()[0].XC_Segment__c;
    //     String optyPostalCode = mapConfiguration.values()[0].NE__OptyId__r.XC_Address__r.XC_PostalCode__c;
    //     String blackListMPR = XC_UTIL_ZipCodeBlacklist.getMPRName(orderLE, orderStream);
    //     List<NE__OrderItem__c> oItems = mapConfiguration.values()[0].NE__Order_Items__r;
    //     Map<String,Object> result = new Map<String,Object>();
    //     result.put('checkResult',false);

    //     if(String.isNotBlank(optyPostalCode) && String.isNotBlank(blackListMPR)){
    //         List<XC_UTIL_ZipCodeBlacklist.InputWrapper> inputs = new List<XC_UTIL_ZipCodeBlacklist.InputWrapper>();
    //         Map<String,List<NE__OrderItem__c>> subtypeOisMap = new Map<String,List<NE__OrderItem__c>>();


    //         //check on coverage
    //         Map<String,String> docCharCoverageMap = new Map<String,String>();
    //         Set<String> productIds = new Set<String>();

    //         for(NE__OrderItem__c oi : oItems){
    //             productIds.add(oi.NE__ProdId__c);
    //         }

    //         List<NE__DocumentationCharacterist__c > docChars = [SELECT ID,Name,NE__Value__c,NE__Product__c
    //         FROM NE__DocumentationCharacterist__c
    //         WHERE NE__Product__c IN :productIds AND Name = 'Coverage Type'];

    //         for(NE__DocumentationCharacterist__c  docChar : docChars){
    //             docCharCoverageMap.put(docChar.NE__Product__c,docChar.NE__Value__c);
    //         }


    //         //create inputwrappers and populate map
    //         for(NE__OrderItem__c oi : oItems){

    //             XC_UTIL_ZipCodeBlacklist.InputWrapper iw = new XC_UTIL_ZipCodeBlacklist.InputWrapper();
    //             iw.productCategoryOfInterest = oi.XC_Product_Subtype__c;
    //             iw.zipCode=optyPostalCode;

    //             //add subcategory for coverages
    //             if(docCharCoverageMap.containsKey(oi.NE__ProdId__c)){
    //                 iw.subCategory = docCharCoverageMap.get(oi.NE__ProdId__c);
    //             }

    //             inputs.add(iw);

    //             if(subtypeOisMap.containsKey(oi.XC_Product_Subtype__c)){
    //                 subtypeOisMap.get(oi.XC_Product_Subtype__c).add(oi);
    //             }else{
    //                 subtypeOisMap.put(oi.XC_Product_Subtype__c,new List<NE__OrderItem__c>{oi});
    //             }


    //         }
    //         Map<XC_UTIL_ZipCodeBlacklist.InputWrapper,Boolean> checkResults = XC_UTIL_ZipCodeBlacklist.checkZipBlacklistByProductSubtype(inputs, orderLE, orderStream);
    //         List<NE__OrderItem__c> blackListedOis = new List<NE__OrderItem__c>();
    //         for(XC_UTIL_ZipCodeBlacklist.InputWrapper iw : checkResults.keySet()){
    //             if(checkResults.get(iw)){
    //                 blackListedOis.addAll(subtypeOisMap.get(iw.productCategoryOfInterest));
    //             }
    //         }
    //         if(!blackListedOis.isEmpty()){
    //             result.put('checkResult',true);
    //             result.put('errorRecords',blackListedOis);
    //             String errorMessageStart = Label.XC_CL_BlackListOitems_1 + ' ';
    //             String errorMessageOi = '';
    //             //build error message
    //             for(NE__OrderItem__c oi : blackListedOis){
    //                 errorMessageOi += oi.Name+' ';
    //             }
    //             result.put('errorMsg',errorMessageStart+errorMessageOi);
    //         }
    //     }
    //     return result;
    // }


    /**
    * @description check if we have an OTP signature for credit assignment
    * @author Francesco Imperioli - fimperioli@deloitte.it | 31/3/2020
    * @param mapConfiguration
    * @return Map<String, Object>
    **/
    private static Map<String,Object> checkOTPSignatureCreditAssignment(Map<Id, NE__Order__c> mapConfiguration){
        Boolean hasCreditAssignment = false;
        Integer numberOfCA = 0;
        String creditAssignmentOiNames = '';
        Map<String,Object> result = new Map<String,Object>();
        result.put('checkResult',false);
        for(NE__OrderItem__c oi : mapConfiguration.values()[0].NE__Order_Items__r){
            if(oi.XC_CreditAssignmentAvailable__c){
                hasCreditAssignment = true;
                numberOfCA++;
                creditAssignmentOiNames += oi.Name + ' ';
            }
        }
        if(hasCreditAssignment && numberOfCA>0){

            List<XC_DocumentSignature__c> otpSignatures = [SELECT Id FROM XC_DocumentSignature__c WHERE XC_Order__c = :mapConfiguration.values()[0].Id AND XC_Step__c = '3'];
            if(otpSignatures.isEmpty()){
                result.put('checkResult',true);
                result.put('errorMsg',Label.XC_CL_LockOTPCreditAssignmentError + ' ' + creditAssignmentOiNames);
            }
        }
        return result;
    }


     /**
    * @description check if we have an OTP signature for credit assignment
    * @author Marco Ottaviano - mottaviano@deloitte.it | 30/06/2020
    * @param mapConfiguration
    * @return Map<String, Object>
    **/
    private static Boolean checkisFromCTI(Map<Id, NE__Order__c> mapConfiguration){
       Boolean result = false;

        NE__Order__c mainConf = mapConfiguration.values()[0];
        String legalEntity = mainConf.XC_LegalEntity__c;

        //getting actual configuration
        List<XC_CM_CallRecordingConfiguration__mdt> callRecConfs = [SELECT
        XC_CheckOnDisconnect__c,XC_CheckOnProvisioning__c,XC_Enabled__c,XC_LegalEntity__c
        FROM XC_CM_CallRecordingConfiguration__mdt
        WHERE XC_LegalEntity__c = :legalEntity LIMIT 1];

        if(!callRecConfs.isEmpty()
            && callRecConfs[0].XC_CheckOnProvisioning__c
            && String.isNotBlank(mainConf.NE__OptyId__r.XC_CTI_Interaction__c)) {
                result = true;
            }



        return result;
    }


    /**
    * @description check if call recording is needed to start provisioning based on LE
    * @author Francesco Imperioli - fimperioli@deloitte.it | 20/5/2020
    * @param mapConfiguration
    * @return Map<String, Object>
    **/
    private static Map<String,Object> checkCallRecordingIfOrderFromCTI(Map<Id,NE__Order__c> mapConfiguration){
        Map<String,Object> result = new Map<String,Object>();
        result.put('checkResult',false);

        NE__Order__c mainConf = mapConfiguration.values()[0];
        String legalEntity = mainConf.XC_LegalEntity__c;

        //getting actual configuration
        List<XC_CM_CallRecordingConfiguration__mdt> callRecConfs = [SELECT
        XC_CheckOnDisconnect__c,XC_CheckOnProvisioning__c,XC_Enabled__c,XC_LegalEntity__c
        FROM XC_CM_CallRecordingConfiguration__mdt
        WHERE XC_LegalEntity__c = :legalEntity LIMIT 1];

        List<User> runningUser = [SELECT id, XC_ExternalCallCenterUser__c
        FROM User
        WHERE id = : UserInfo.getUserId() LIMIT 1];

        if(!callRecConfs.isEmpty()
            && callRecConfs[0].XC_CheckOnProvisioning__c
            && (String.isNotBlank(mainConf.NE__OptyId__r.XC_CTI_Interaction__c) || runningUser[0].XC_ExternalCallCenterUser__c)
            && String.isBlank(mainConf.XC_CTICallRecording__c)
            && mainConf.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder
            ){
            result.put('checkResult',true);
            result.put('errorMsg',Label.XC_CL_CTIRecordingMandatoryProv);
        }

        return result;

    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 23/04/2020
     * @description Method to check Order Status to start Provisioning
     * @param order - NE__Order__c
     * @return Boolean
     */
    private static Boolean checkOrderStatus(NE__Order__c order) {
        List<String> listStatusForError = new List<String>{
            Label.XC_CL_Configuration_OrderInProvisioning,
            Label.XC_CL_Configuration_Closed,
            Label.XC_CL_Configuration_OrderCancelled
        };
        if(listStatusForError.contains(order.XC_Status__c)) {
            return false;
        }
        return true;
    }

    /**
  * @description Check Is Provvisong Is Complex for PPM or Simple
  * @author Donato Lombardi
  * @param mapConfiguration
  * @return Map<String, Object>
  **/
    private static Boolean checkProvvissiongIsComplex(Map<Id, NE__Order__c> mapConfiguration){
        return mapConfiguration.values().get(0).XC_ProvisioningType__c == 'Project';
    }

    /**
  * @description Check Is Provvisong Is Complex for PPM or Simple
  * @author Donato Lombardi
  * @param mapConfiguration
  * @return Map<String, Object>
  **/
    private static Boolean checkProvvissiongIsComplexCapex(Map<Id, NE__Order__c> mapConfiguration){
        Boolean complex = false;
        Boolean isCapex = false;
        if(mapConfiguration.values().get(0).XC_ProvisioningType__c == 'Project'){
            complex = true;
        }
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.XC_BillingModel__c == 'Capex'){
                isCapex = true;
            }

        }
        return !complex && isCapex;
    }

    /**
    * @description NR0488 - Check if during the site inspection a technical product has to be added for particual product subtypes
    * @author Francesco Imperioli - fimperioli@deloitte.it | 5/6/2020
    * @param mapConfiguration
    * @return Map<String, Object>
    **/
    private static Map<String,Object> checkTechProductMandatoriety(Map<Id,NE__Order__c> mapConfiguration,List<XC_CM_LegalEntity_Configuration__mdt> leConf){
        Map<String,Object> result = new Map<String,Object>();
        result.put('checkResult',true);

        //getting LE configuration
        NE__Order__c ord = mapConfiguration.values()[0];

        // List<XC_CM_LegalEntity_Configuration__mdt> leConf = [SELECT Id,XC_LegalEntity__c,XC_Stream__c,XC_SiteInspReqTechProdSubType__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c = :ord.XC_LegalEntity__c AND XC_Stream__c = :ord.XC_Segment__c AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];
        if(!leConf.isEmpty() && String.isNotBlank(leConf[0].XC_SiteInspReqTechProdSubType__c)){
            //NR0807 -- Skip the Technical Product Check by  XC_ProductCategoryOfInterest__c
            if(String.isNotBlank(leConf[0].XC_SkipTechProdbyCatInterest__c)) {
                String[] categoryInterestList = leConf[0].XC_SkipTechProdbyCatInterest__c.split(';');
                Set<String> categoryInterestSet = new Set<String>();
                categoryInterestSet.addAll(categoryInterestList);
                if(categoryInterestSet.contains(ord.NE__OptyId__r.XC_ProductCategoryOfInterest__c)) {
                    return result;
                }
            }
            //check the product subtypes for which the technical products are required
            String [] techProductSubtypes = leConf[0].XC_SiteInspReqTechProdSubType__c.split(';');
            Set<String> subTypesSet = new Set<String>();
            subTypesSet.addAll(techProductSubtypes);

            //check if in the orderitems there's an orderitem that needs to be checked
            Boolean checkNeeded = false;
            List<NE__OrderItem__c> ois = ord.NE__Order_Items__r;
            for(NE__OrderItem__c oi : ois){
                if(subTypesSet.contains(oi.XC_Product_Subtype__c)){
                    checkNeeded = true;
                    break;
                }
            }

            if(checkNeeded){
                Boolean finalResult = false;
                for(NE__OrderItem__c oi : ois){
                    if(oi.XC_Product_Type__c == Label.XC_CL_Technical && oi.XC_Product_Subtype__c == 'Product'){
                        finalResult = true;
                    }
                }
                result.put('checkResult',finalResult);
                result.put('errorMsg',Label.XC_CL_LCC099_CheckTechProductSIError);
            }

        }
        return result;
    }

    /**
* @description If billing model is recurring the duration field must be filled
* @author Donato Lombardi
* @param mapConfiguration
* @return Map<String, Object>
**/

    private static Boolean checkDurationWhenBillingModelIsRecurring(Map<Id, NE__Order__c> mapConfiguration,Map<String,XC_CM_LegalEntity_Configuration__mdt> mapLeConfigurationCM){
        Boolean check = false;
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2B');
        setSegmanet.add('B2G');
      /*  for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.XC_LegalEntity__c== 'EnelXItalia' && setSegmanet.contains(orderItem.XC_Segment__c)) {
                if(orderItem.XC_BillingModel__c=='Recurring' && orderItem.XC_RecurringDuration__c == Null) {
                    check = True;
                    break;
                }
            }*/
            for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
                if(((orderItem.XC_LegalEntity__c!='Codensa' && orderItem.XC_LegalEntity__c!='EnelX' && orderItem.XC_LegalEntity__c!='EnelXMobilityChile' && orderItem.XC_LegalEntity__c!='EnelDistribucion') ||
                   mapLeConfigurationCM.values()[0].XC_ComplexProductActive__c==true) &&
                   setSegmanet.contains(orderItem.XC_Segment__c)){
                    if(orderItem.XC_BillingModel__c=='Recurring' && orderItem.XC_RecurringDuration__c == Null) {
                        check = True;
                        break;
                    }
                   }

            }
            return check;
        }



    /**
* @description If billing model is recurring the duration field must be filled
* @author Donato Lombardi
* @param mapConfiguration
* @return Map<String, Object>
**/


    public static Boolean checkCreditCheck(Map<Id, NE__Order__c> mapConfiguration, Map<String,XC_CM_LegalEntity_Configuration__mdt> mapLeConfigurationCM){
         Boolean check = false;
        XC_UTIL_Debug.debug(false, '@@@ XC_LCC099_NextStepOrderToProvisioning - implementFirstNextStep');
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2B');
        setSegmanet.add('B2G');
        Set<String> setLegalEntity = new Set<String>{'EnelXItalia','EnelXMobilityItalia'};
         /*   if(setLegalEntity.contains(mapConfiguration.values()[0].XC_LegalEntity__c) && setSegmanet.contains(mapConfiguration.values()[0].XC_Segment__c)) {
                if(mapConfiguration.values()[0].NE__OptyId__r.XC_CreditCheck_GB__c !='OK') {
                    check = True;
                }
            }*/
          if(setSegmanet.contains(mapConfiguration.values()[0].XC_Segment__c) &&
              ((mapConfiguration.values()[0].XC_LegalEntity__c!='Codensa' && mapConfiguration.values()[0].XC_LegalEntity__c!='EnelX' && mapConfiguration.values()[0].XC_LegalEntity__c!='EnelXMobilityChile' && mapConfiguration.values()[0].XC_LegalEntity__c!='EnelDistribucion') ||
                mapLeConfigurationCM.values()[0].XC_ComplexProductActive__c==true)){
                 if(mapConfiguration.values()[0].NE__OptyId__r.XC_CreditCheck_GB__c !='OK' && mapConfiguration.values()[0].NE__OptyId__r.XC_CreditCheck_GB__c != 'OK_prepayment' ) {
                    check = True;
                     if(check){
                         String businessModel = mapConfiguration.values()[0].NE__OptyId__r.XC_BusinessModel__c;
                         String modeOfEngagement = mapConfiguration.values()[0].NE__OptyId__r.XC_ModeOfEngagement__c;
                         String contractType = mapConfiguration.values()[0].NE__OptyId__r.XC_ContractType__c;
                         List<XC_CM_Skip_Credit_Check__mdt> listCMSkipCreditCheck = new List<XC_CM_Skip_Credit_Check__mdt>();
                         listCMSkipCreditCheck = [select Id, DeveloperName, XC_Contract_Type__c, XC_BusinessModel__c, XC_ModeOfEngagement__c  from XC_CM_Skip_Credit_Check__mdt
                         where XC_Contract_Type__c IN (:contractType,'*') AND XC_BusinessModel__c IN (:businessModel,'*') AND XC_ModeOfEngagement__c IN (:modeOfEngagement,'*')];
                         if(!listCMSkipCreditCheck.isEmpty()){
                             check = false;
                         }
                     }
                 }
               }
        return check;

    }

    @TestVisible
    private static Boolean checkContractIsSigned(Map<Id, NE__Order__c> mapConfiguration,Map<String,XC_CM_LegalEntity_Configuration__mdt> mapLeConfigurationCM){
        Boolean check = false;
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2B');
        setSegmanet.add('B2G');
        Set<String> setLegalEntity = new Set<String>{'EnelXItalia','EnelXMobilityItalia'};

       /* if(setLegalEntity.contains(mapConfiguration.values()[0].XC_LegalEntity__c) && setSegmanet.contains(mapConfiguration.values()[0].XC_Segment__c)) {
            Map<Id,Contract> mapIdContractRelatedToOpportunity = new Map<Id,Contract>([select id, RecordType.DeveloperName, XC_Signed__c from Contract where Opportunity__c = :mapConfiguration.values()[0].NE__OptyId__c]);
            if(mapIdContractRelatedToOpportunity.isEmpty()){
                return false;
            }
            for(Contract c : mapIdContractRelatedToOpportunity.values()){
                if(c.RecordType.DeveloperName == 'XC_B2B_EnelXItalia_Contract' && !c.XC_Signed__c){
                    check = True;
                    break;
                }
            }
        }*/
        if(setSegmanet.contains(mapConfiguration.values()[0].XC_Segment__c) &&
                ((mapConfiguration.values()[0].XC_LegalEntity__c!='Codensa' && mapConfiguration.values()[0].XC_LegalEntity__c!='EnelX' && mapConfiguration.values()[0].XC_LegalEntity__c!='EnelXMobilityChile' && mapConfiguration.values()[0].XC_LegalEntity__c!='EnelDistribucion')||
                 mapLeConfigurationCM.values()[0].XC_ComplexProductActive__c==true)){
                    Map<Id,Contract> mapIdContractRelatedToOpportunity = new Map<Id,Contract>([select id, RecordType.DeveloperName, XC_Signed__c from Contract where Opportunity__c = :mapConfiguration.values()[0].NE__OptyId__c]);
                    for(Contract c:mapIdContractRelatedToOpportunity.values()){
                        if(!c.XC_Signed__c){
                            check = True;
                            break;
                        }
                    }
                }


        return check;

    }
    @TestVisible
    private static Boolean checkContractCigCugDetermina(Map<Id, NE__Order__c> mapConfiguration){
        Boolean check = false;
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2G');
        Set<String> setLegalEntity = new Set<String>{'EnelXItalia','EnelXMobilityItalia','EnelSole','Cogenio'};

         if(setLegalEntity.contains(mapConfiguration.values()[0].XC_LegalEntity__c) && setSegmanet.contains(mapConfiguration.values()[0].XC_Segment__c) /* && mapLeConfigurationCM.values()[0].XC_ComplexProductActive__c*/) {
             Map<Id,Contract> mapIdContractRelatedToOpportunity = new Map<Id,Contract>([select id, RecordType.DeveloperName, XC_Signed__c, XC_CIG__c, XC_CUP__c, XC_Determina__c from Contract where Opportunity__c = :mapConfiguration.values()[0].NE__OptyId__c]);
             if(mapIdContractRelatedToOpportunity.isEmpty()){
                 return false;
             }
             for(Contract c : mapIdContractRelatedToOpportunity.values()){
                 if(String.isEmpty(c.XC_CIG__c)|| String.isEmpty(c.XC_CUP__c) || String.isEmpty(c.XC_Determina__c)){
                     check = True;
                     break;
                 }
             }
         }
        return check;

    }

    private static Boolean checkConfiguredProvisioningSteps(String configurationId){
        Map<Id, NE__OrderItem__c> mapOrderItems = new  Map<Id, NE__OrderItem__c>([Select id, XC_Segment__c, NE__OrderId__r.XC_ProvisioningType__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_eMobTransactionId__c from NE__OrderItem__c /*where RecordType.DeveloperName  like 'StanStandarddard' */where RecordType.DeveloperName  != 'Technical_Item' and NE__Parent_Order_Item__c = null and NE__OrderId__c = : configurationId]);
        Map<Id, String> mapOrderItemVSTemplates = new Map<Id, String>();

        if(mapOrderItems == null || mapOrderItems.isEmpty() || mapOrderItems.values().get(0).XC_Segment__c == 'B2C' || mapOrderItems.values().get(0).NE__OrderId__r.XC_ProvisioningType__c != 'Predefined' || String.IsNotBlank(mapOrderItems.values().get(0).NE__OrderId__r.XC_eMobTransactionId__c)){
            return true;
        }

        mapOrderItemVSTemplates = XC_UTIL_ProvisioningTemplateAssociation.getTemplate(mapOrderItems.values());
        for(Id confId : mapOrderItemVSTemplates.keySet()){
            if(mapOrderItemVSTemplates.get(confId)== null || mapOrderItemVSTemplates.get(confId) == ''){
                mapOrderItemVSTemplates.remove(confId);
            }
        }
        return mapOrderItems.size()  == mapOrderItemVSTemplates.size();
    }
    
    private static Boolean checkConfiguredProvisioningStepsMetadata(String configurationId){
        Map<Id, NE__OrderItem__c> mapOrderItems = new  Map<Id, NE__OrderItem__c>([SELECT id, XC_Segment__c, NE__OrderId__r.XC_ProvisioningType__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_eMobTransactionId__c 
                                                                                  FROM NE__OrderItem__c /*where RecordType.DeveloperName  like 'StanStandarddard' */
                                                                                  WHERE RecordType.DeveloperName  != 'Technical_Item' AND NE__Parent_Order_Item__c = null AND NE__OrderId__c = : configurationId]);
        Map<Id, String> mapOrderItemVSTemplates = new Map<Id, String>();

        if(mapOrderItems == null || mapOrderItems.isEmpty() || mapOrderItems.values().get(0).NE__OrderId__r.XC_ProvisioningType__c != 'Predefined'){
            return true;
        }

        mapOrderItemVSTemplates = XC_UTIL_ProvisioningTemplateAssociation.getTemplate(mapOrderItems.values());
        for(Id confId : mapOrderItemVSTemplates.keySet()){
            if(mapOrderItemVSTemplates.get(confId)== null || mapOrderItemVSTemplates.get(confId) == ''){
                mapOrderItemVSTemplates.remove(confId);
            }
        }
        return mapOrderItemVSTemplates.size()>0;
    }

    private static Boolean checkInstallmentPlan(Map<Id, NE__Order__c> mapConfiguration,Map<String,XC_CM_LegalEntity_Configuration__mdt> mapLeConfigurationCM) {
        Boolean check = false;
        Set<String> setSegmanet = new Set<String>();
        setSegmanet.add('B2B');
        setSegmanet.add('B2G');
       Set<String> setLegalEntity = new Set<String>{
                'EnelXItalia', 'Cogenio', 'EnelSole','EnelXMobilityItalia'
        };
        Set<String>setInstallment = new Set<String>{'Installment Plan Update',' Installment Plan Drop','Contract Extension','Change Billing Profile','Service Upgrade/Downgrade','Change Billing Profile','Change of ownership'};
        /* if(setInstallment.contains(mapConfiguration.values()[0].XC_Subtype__c) && mapConfiguration.values()[0].XC_Substatus__c !='Approved'&& setLegalEntity.contains(mapConfiguration.values()[0].XC_LegalEntity__c) && setSegmanet.contains(mapConfiguration.values()[0].XC_Segment__c)){
            check = true;
        }*/
        if (mapConfiguration.values()[0].NE__Configuration_Type__c != 'Disconnect'){
            if (setInstallment.contains(mapConfiguration.values()[0].XC_Subtype__c) &&
                    mapConfiguration.values()[0].XC_Substatus__c != 'Approved' &&
                    ((mapConfiguration.values()[0].XC_LegalEntity__c != 'Codensa' && 
					mapConfiguration.values()[0].XC_LegalEntity__c != 'EnelX' && 		        
					mapConfiguration.values()[0].XC_LegalEntity__c != 'EnelDistribucion' &&
					mapConfiguration.values()[0].XC_LegalEntity__c != 'EnelSole' &&
                    mapConfiguration.values()[0].XC_LegalEntity__c != 'EnelXItalia' &&
                    mapConfiguration.values()[0].XC_LegalEntity__c != 'Cogenio' &&
                    mapConfiguration.values()[0].XC_LegalEntity__c != 'EnelXMobility') ||
                            mapLeConfigurationCM.values()[0].XC_ComplexProductActive__c == true) &&
                    setSegmanet.contains(mapConfiguration.values()[0].XC_Segment__c)
                    ) {
                check = true;
            }
    }
        return check;
    }

    private static Boolean checkExtensionField(Map<Id, NE__Order__c> mapConfiguration){
        if(mapConfiguration.values()[0].XC_Subtype__c != 'Contract Extension'){
            return false;
        }else{
            if(mapConfiguration.values()[0].XC_ExtensionMonths__c == null || mapConfiguration.values()[0].XC_ExtensionMonths__c == 0){
                return true;
            }else{
                return false;
            }
        }

    }

    @TestVisible
    private static Boolean checkProvisioningType(Map<Id, NE__Order__c> mapConfiguration){
        Boolean check = false;
        Map<Id,NE__OrderItem__c> techItems = new Map<Id,NE__OrderItem__c>([select id from NE__OrderItem__c where RecordType.developerName = 'Technical_Item' and NE__OrderId__r.XC_ProvisioningType__c != 'Project' and NE__OrderId__c = :mapConfiguration.keySet()]);
        return !techItems.isEmpty();

    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 09/12/2020
     * @description Method to check Status of Billing Profile Line Item
     * @param listOrderItem - List<NE__OrderItem__c>
     * @param typeOrder - String
     * @return Boolean
     */
    private static Boolean checkStatusBillingProfileLineItem(List<NE__OrderItem__c> listOrderItem, String typeOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 checkStatusBillingProfileLineItem');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 checkStatusBillingProfileLineItem - typeOrder -->' + typeOrder);
        if(typeOrder == Label.XC_CL_Configuration_TypeDisconnection) {
            return true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 checkStatusBillingProfileLineItem - listOrderItem -->' + listOrderItem);
        List<String> listStatusErrorB2C =  new List<String>{Label.XC_CL_BillingProfileStatus_Draft, Label.XC_CL_BillingProfileStatus_Refused};
        List<String> listStatusErrorB2BG =  new List<String>{Label.XC_CL_BillingProfileStatus_Draft, Label.XC_CL_BillingProfileStatus_Refused,Label.XC_CL_BillingProfileWaiting,'Sent To Zuora'};
        for(NE__OrderItem__c oi : listOrderItem) {
            if((oi.XC_Segment__c =='B2C' && listStatusErrorB2C.contains(oi.XC_BillingProfileLineItem__r.XC_Status__c)) || (oi.XC_Segment__c!='B2C' && listStatusErrorB2BG.contains(oi.XC_BillingProfileLineItem__r.XC_Status__c))) {
                return false;
            }
        }
        return true;
    }
    /**
    * @author Donato lombardi - dolombardi@deloitte.it
    * @date 10/12/2019
    * @description Method to check WBE field
    * @param mapConfiguration - Map<Id, NE__Order__c>
    * @return Boolean
    */
    private static Boolean checkWBEApproved(Map<Id, NE__Order__c> mapConfiguration){
        Boolean wbeCheck = false;
        List<XC_CM_LegalEntity_Configuration__mdt> listCMCompanyCode = [SELECT ID, XC_LegalEntity__c,XC_Stream__c, XC_CompanyCode__c,XC_digFree__c, XC_digitFree2__c, XC_Type_of_WBE__c, XC_WBEDigit18__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c =: mapConfiguration.values()[0].XC_LegalEntity__c AND XC_Stream__c =: mapConfiguration.values()[0].XC_Segment__c AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];
        if(listCMCompanyCode[0].XC_Type_of_WBE__c == 'Simple'){
            return false;
        }
        if(mapConfiguration.values()[0].NE__Type__c != Label.XC_CL_Configuration_TypeInOrder){
            return false;
        }
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.RecordType.DeveloperName != 'Technical_Item'){
                if(orderItem.XC_WBE_Status__c != 'Approved' && orderItem.XC_Segment__c != 'B2C') {
                    wbeCheck = true;
                    break;
                }
            }
        }
        return wbeCheck;
    }



    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @date 03/02/2021
     * @description Method to check if the order is related to the Disonnection-B2C process (NR1455)
     * @param order NE__Order__c
     * @return Boolean
     */
    private static Boolean isDisconnectionWithoutActivitiesOrder(NE__Order__c order) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 isDisconnectionWithoutActivitiesOrder');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 isDisconnectionWithoutActivitiesOrder - order ->'+ order);
        Boolean isDisconnectionWithoutActivities = false;
        if(order.XC_Segment__c == 'B2C'
            && order.NE__Type__c == Label.XC_CL_Configuration_TypeDisconnection
            && !order.XC_ManualLogisticActivities__c){
            isDisconnectionWithoutActivities = true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 isDisconnectionWithoutActivitiesOrder - order ->'+ isDisconnectionWithoutActivities);
        return isDisconnectionWithoutActivities;
    }

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @date 03/02/2021
     * @description Method to check if manual logistic activities are needed (NR1455)
     * @param listOrderItemAttributes - List<NE__Order_Item_Attribute__c>
     * @return Boolean
     */
    public static Boolean checkManualLogisticActivities(List<NE__Order_Item_Attribute__c> listOrderItemAttributes){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 checkManualLogisticActivities');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 checkManualLogisticActivities - listOrderItemAttributes ->'+ listOrderItemAttributes);
        Boolean manualActivitiesToDo = false;
        for(NE__Order_Item_Attribute__c oia : listOrderItemAttributes){
            if(oia.XC_DeveloperName__c == Label.XC_CL_DeliveryMethod && oia.NE__Value__c == Label.XC_CL_DeliveryMethod_Shipping){
                manualActivitiesToDo = true;
                break;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 checkManualLogisticActivities - manualActivitiesToDo ->'+ manualActivitiesToDo);
        return manualActivitiesToDo;
    }

     /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @date 03/02/2021
     * @description Method to retrieve all order item attribute on an order (NR1455)
     * @param configurationId - String
     * @return List<NE__Order_Item_Attribute__c>
     */
    private static List<NE__Order_Item_Attribute__c> getOrderItemAttributes(String configurationId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 getOrderItemAttributes');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 getOrderItemAttributes - configurationId ->'+ configurationId);
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__Order_Item_Attribute__c');
        query += ' FROM NE__Order_Item_Attribute__c ';
        query += ' WHERE NE__Order_Item__r.NE__OrderId__c = :configurationId';
        List<NE__Order_Item_Attribute__c> listOrderItemAttributes = Database.query(String.escapeSingleQuotes(query));
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ IN LCC099 getOrderItemAttributes - listOrderItemAttributes ->'+ listOrderItemAttributes);
        return listOrderItemAttributes;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 04/05/2021
     * @description Method to check User Code
     * @param mapConfiguration - Map<Id, NE__Order__c>
     * @return Boolean
     */
    private static Boolean checkUserCode(Map<Id, NE__Order__c> mapConfiguration) {
        List<User> listUser = new List<User>([
            SELECT Id, XC_AMP_UserCode__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ]);
        if(String.isBlank(mapConfiguration.values()[0].XC_UserNumber__c) && String.isNotBlank(listUser[0].XC_AMP_UserCode__c)) {
            if(Test.isRunningTest()) return true;
            else return false;
        }
        return true;
    }
    /**
     * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
     * @date 30/09/2021
     * @description Promocode Application Warning - Check if NE__Type__c = 'ChangeOrder' and XC_Subtype__c = 'Promocode application', then show the warning modal.
     * @param configurationId - String
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkPromocodeApplication(String configurationId) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        NE__Order__c ord = [SELECT Id, NE__Type__c, XC_Subtype__c, XC_In_Provisioning__c, XC_Status__c FROM NE__Order__c WHERE Id =:configurationId];
        if ( (ord.XC_Status__c == 'In Progress' || ord.XC_Status__c == 'To be validated') && ord.NE__Type__c == 'ChangeOrder' && ord.XC_Subtype__c == 'Promocode application' && ord.XC_In_Provisioning__c == false) {
            rw.success = true;
        } else {
            rw.success = false;
        }
        return rw;
    }

    /**
     * @author Elio Adami - elio.adami@accenture.com
     * @date 29/09/2021
     * @description Method to retrive affiliate and beneficiary related to configurationId
     * @param configurationId - String
     * @return  List<XC_Affiliate_Beneficiary__c>
     */
    private static List<XC_Affiliate_Beneficiary__c> getAffBenByIdConfiguration(String configurationId) {
        List<XC_Affiliate_Beneficiary__c> listAffBen = [SELECT id, XC_Status__c, XC_OrderItem__r.NE__OrderId__r.NE__Type__c, XC_OrderItem__r.NE__OrderId__r.XC_CaseId__r.XC_Subtype__c //[DeAv 14/12/2021 added field]
                                                        FROM XC_Affiliate_Beneficiary__c
                                                        WHERE XC_OrderItem__r.NE__OrderId__c =: configurationId];
        return listAffBen;
    }

    /**
     * @author Elio Adami - elio.adami@accenture.com
     * @date 29/09/2021
     * @description Method to retrive check validate of affiliate and beneficiary's list
     * @param affBenList Affiliate and Beneficiary's List related to configurationId in context
     * @param configurationId - String
     * @return  Map<String,Object>
     * @modified on 12/10/2021 by Denise Avolio - denise.avolio@accenture.com
     */
    private static Map<String,Object> checkErrorAffBenByList(List<XC_Affiliate_Beneficiary__c> affBenList, String configurationId) {
        Map<String,Object> checkList = new Map<String,Object>();
        checkList.put('validate', true);
        checkList.put('errorMessage', ' ');

        if(!affBenList.isEmpty()){
            for(XC_Affiliate_Beneficiary__c aff : affBenList){
                if(('Not Validated'.equalsIgnoreCase(aff.XC_Status__c) && 'InOrder'.equalsIgnoreCase(aff.XC_OrderItem__r.NE__OrderId__r.NE__Type__c)) || 
                   ('Not Validated'.equalsIgnoreCase(aff.XC_Status__c) && 'ChangeOrder'.equalsIgnoreCase(aff.XC_OrderItem__r.NE__OrderId__r.NE__Type__c) && 'XC108'.equalsIgnoreCase(aff.XC_OrderItem__r.NE__OrderId__r.XC_CaseId__r.XC_Subtype__c))){ //[DeAv 14/12/2021 added conditions]
                    checkList.put('validate', false);
                    checkList.put('errorMessage', Label.XC_CL_AffBen_ErrorValidate);
                    return checkList;
                }
            }
        }else{
            List<NE__Order_Item_Attribute__c> orderItemAttributeList = new List<NE__Order_Item_Attribute__c>([SELECT id, Name, NE__Value__c
                                                                                                              FROM NE__Order_Item_Attribute__c
                                                                                                              WHERE Name IN :XC_AffiliateBeneficiary_U.ATTRIB_NAME_LIST AND
                                                                                                                    NE__Order_Item__r.NE__OrderId__c =: configurationId]);
            if(!orderItemAttributeList.isEmpty()){
                String valueCode;
                String valuePlan;
                for(NE__Order_Item_Attribute__c oia: orderItemAttributeList){
                    if(XC_AffiliateBeneficiary_U.AFFBENCODE.equalsIgnoreCase(oia.Name)){
                        valueCode = oia.NE__Value__c;
                    }else{
                        valuePlan = oia.NE__Value__c;
                    }
                }
                List<XC_AffiliateBeneficiaryConfiguration__c> affBenConfList = new List<XC_AffiliateBeneficiaryConfiguration__c>([SELECT id
                                                                                                                                  FROM XC_AffiliateBeneficiaryConfiguration__c
                                                                                                                                  WHERE XC_ConfigurationCode__c =: valueCode AND
                                                                                                                                        XC_ProductPlan__c =: valuePlan]);
                if(!affBenConfList.isEmpty()){
                    checkList.put('validate', false);
                    checkList.put('errorMessage', Label.XC_CL_AffBen_ErrorValidate);
                    return checkList;
                }
            }
        }
        return checkList;

    }

    /*  Mod CV CR.NR2044
    * @date 07/10/2021
    * @Description;
        Check to ensure the correctness of data:
        the end date of recurring duration period related to Adjustment’
        must be less than the end date of recurring duration period related to the root product.
    * @param mapConfiguration - Map<Id, NE__Order__c>
    * @return Boolean
    Start -->
    */
    @TestVisible
    private static Map<String,Object> checkReccurringAdjustDate(Map<Id, NE__Order__c> mapConfiguration) {
        Map<String,Object> checkList = new Map<String,Object>();
        checkList.put('validate', true);
        checkList.put('errorMessage', ' ');

        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
             if(orderItem.NE__ProdName__c == Label.XC_CL_AdjustmentProdName){
                if(orderItem.XC_Effective_Start_Date_Recurring__c == null || orderItem.XC_Billing_Period_Recurring__c == null || orderItem.XC_Billing_Period_Recurring__c == 0){
                    checkList.put('validate', false);
                    checkList.put('errorMessage',Label.XC_CL_CheckAdjustmentValidation);
                    return checkList;
                } else {
                NE__OrderItem__c orderItemRoot = getfRootProd(mapConfiguration, orderItem.NE__Parent_Order_Item__c);
                Datetime estEndDateAdj = orderItem.NE__EndDate__c; //orderItem.XC_Effective_Start_Date_Recurring__c.addMonths(Integer.valueOf(orderItem.XC_Billing_Period_Recurring__c));
                Datetime estEndDateRoot;
                if(orderItemRoot.NE__EndDate__c != null){
                     estEndDateRoot = orderItemRoot.NE__EndDate__c;//.XC_Effective_Start_Date_Recurring__c.addMonths(Integer.valueOf(orderItemRoot.XC_Billing_Period_Recurring__c));
                }else{
                    checkList.put('validate', false);
                    checkList.put('errorMessage',Label.XC_CL_CheckAdjustmentRecurringDuration);
                }
                 if( estEndDateAdj > estEndDateRoot){
                    checkList.put('validate', false);
                    checkList.put('errorMessage',Label.XC_CL_CheckAdjustmentRecurringDuration);
                 }
                }
             }
        }
      return checkList;
    }

    /* @date 07/10/2021
    * @Description;
       return a  Root Product
    * @param mapConfiguration - Map<Id, NE__Order__c>,idSon  NE__Parent_Order_Item__c
    * @return NE__OrderItem__c
    */
    @TestVisible
    private static NE__OrderItem__c getfRootProd(Map<Id, NE__Order__c> mapConfiguration,Id idSon) {
        NE__OrderItem__c rootProd = new NE__OrderItem__c();
        for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.Id == idSon){
                rootProd = orderItem;
                break;
            }

        }
        return rootProd;
    }
    //<-- End
	@TestVisible
  	private static boolean checkPOD(Map<Id, NE__Order__c> mapConfiguration) {

		Boolean isUpdatable = false;

		for(NE__OrderItem__c orderItem : mapConfiguration.values()[0].NE__Order_Items__r) {
            if(orderItem.NE__Parent_Order_Item__c == null && orderItem.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c == 'OpenCharge B2B') {
            	if(String.isNotBlank(orderItem.NE__OrderId__r.XC_POD__c) && String.isNotBlank(orderItem.NE__OrderId__r.XC_EmobilityWebAppType__c)) {
					return false;
				}

				if(String.isNotBlank(mapConfiguration.values()[0].XC_InstallationAddress__r.XC_ElectricCUPS__c)) {
					mapConfiguration.values()[0].XC_POD__c = mapConfiguration.values()[0].XC_InstallationAddress__r.XC_ElectricCUPS__c;
                    mapConfiguration.values()[0].XC_EmobilityWebAppType__c = Label.XC_CL_EmobilityWebAppType_Recharge;
                	isUpdatable = true;
            	} else {
                 	return true;
				}
    		}
        }

      	if(isUpdatable) {
      		XC_UTIL_Sobject.updateListRecords(mapConfiguration.values());
      	}
        
      	return false;
	}

}
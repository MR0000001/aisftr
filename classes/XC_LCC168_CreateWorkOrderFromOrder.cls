/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 30/10/2019
* @description XC_LCC168_CreateWorkOrderFromOrder – Apex Controller to create Work Order from Order
*/

public without sharing class XC_LCC168_CreateWorkOrderFromOrder {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC168_CreateWorkOrderFromOrder');

    /** @description OutputWrapper */
    public class OutputWrapper {
        @AuraEnabled public Boolean success = true;
        @AuraEnabled public Boolean isCreated = false;
        @AuraEnabled public String errorMessage = '';
        @AuraEnabled public WorkOrder workOrderInserted = new WorkOrder();
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 03/03/2021
    * @description Method to create WO from Order
    * @param listOrder - List<NE__Order__c> 
    * @return OutputWrapper
    */
    public static OutputWrapper createWorkOrder(List<NE__Order__c> listOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Create Work Order Site Inspection from Order');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Order: ' + listOrder[0].Id);
        OutputWrapper wrapper = new OutputWrapper();
        if(listOrder[0].NE__Type__c != Label.XC_CL_Configuration_TypeInOrder) {
            wrapper.success = true;
            wrapper.isCreated = false;
            return wrapper;
        }
        // Check for Block Not Required Site Inspection
        Boolean siteInspectionRequired = false;
        String allChannelForSkipSiteInspection = '';
        for(NE__OrderItem__c oi : listOrder[0].NE__Order_Items__r) {
            if(oi.NE__CatalogItem__r.XC_Site_Inspection_Required__c) {
                siteInspectionRequired = true;
                allChannelForSkipSiteInspection = oi.NE__CatalogItem__r.XC_SkipSiteInspectionChannel__c;
                break;
            }
        }
        List<NE__Order__c> listOfQuote = new List<NE__Order__c>();
        if (siteInspectionRequired){
            listOfQuote = [SELECT Id, XC_ReceivingChannelFormula__c FROM NE__Order__c WHERE RecordType.DeveloperName =: 'Quote' AND NE__OptyId__c =: listOrder[0].NE__OptyId__c AND XC_Status__c =: Label.XC_CL_Configuration_QuoteAccepted];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Site Inspection required: ' + siteInspectionRequired);
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BlockNotRequiredSiteInspection__c
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_Stream__c = :listOrder[0].XC_Segment__c AND XC_LegalEntity__c = :listOrder[0].XC_LegalEntity__c
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listCM' + listCM);
        String receivingChannel = listOfQuote.isEmpty() ? listOrder[0].XC_ReceivingChannelFormula__c : listOfQuote[0].XC_ReceivingChannelFormula__c;
        Boolean createSiteInspectionByCM = !listCM.isEmpty() && listCM[0].XC_BlockNotRequiredSiteInspection__c;
        Boolean skipSiteInspectionFromReceivingChannel = allChannelForSkipSiteInspection != null && receivingChannel != null && allChannelForSkipSiteInspection.contains(receivingChannel);
        if(!siteInspectionRequired || (skipSiteInspectionFromReceivingChannel || (siteInspectionRequired && !createSiteInspectionByCM))) {
            wrapper.success = true;
            wrapper.isCreated = false;
            wrapper.errorMessage = Label.XC_CL_SiteInspection_NotRequired;
            return wrapper;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Site Inspection required');
        NE__Order__c myOrder = listOrder[0];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Order: ' + myOrder);
        String workTypeCategory = Label.XC_CL_WorkType_SiteInspection;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ workTypeCategory ' + workTypeCategory); 
        for(WorkOrder myWo : myOrder.Work_Orders__r) {
            if(myWo.XC_WorkTypeCategory__c == workTypeCategory) {
                if(!myWo.XC_Check_Final_Status__c) {
                    wrapper.success = true;
                    wrapper.isCreated = false;
                    wrapper.errorMessage = Label.XC_CL_WoSiteInspectionExists;
                    return wrapper;
                } else if(myWo.Status == Label.XC_CL_WorkOrder_Completed) {
                    wrapper.success = true;
                    wrapper.isCreated = false;
                    return wrapper;
                }
            }  
        }

        // Check for Billing Profile Line Item:
        if(!XC_UTIL_ConfigurationItem.checkBillingProfile(listOrder[0].NE__Order_Items__r, 'Site Inspection')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error for missing Billing Profile');
            wrapper.success = false;
            wrapper.errorMessage = Label.XC_CL_ErrorMissingBPLI;
            return wrapper;
        }

        Map<Id, List<String>> mapOrderitemDocument = new Map<Id, List<String>>();
        List<Id> confItemIdList = new List<Id>();
        for(NE__OrderItem__c item : listOrder[0].NE__Order_Items__r){
            confItemIdList.add(item.id);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ confItemIdList -> ' + confItemIdList);
        mapOrderitemDocument = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster('C0', confItemIdList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOrderitemDocument: ' + mapOrderitemDocument);
        Boolean hasWebSignature = String.isNotBlank(listOrder[0].XC_SignedByExternal__c) && listOrder[0].XC_SignedByExternal__c.equalsIgnoreCase('Web');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ hasWebSignature: ' + hasWebSignature);
        if(!hasWebSignature && !XC_LCC069_ComplianceVerification1.checkDoxeeDocumentations(listOrder[0].Id, mapOrderitemDocument)){
            wrapper.success = false;
            wrapper.errorMessage = Label.XC_CL_SiteInspectionCompliance0Error + XC_LCC069_ComplianceVerification1_U.retrieveMissingDocumentAsString(mapOrderitemDocument, listOrder[0].Id);
            return wrapper;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ No error for missing document');

        // Check for EnelXItalia:
        if(listOrder[0].XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || listOrder[0].XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For LE EnelXItalia');
            Boolean hasCreditAssignment = false;
            for(NE__OrderItem__c item : listOrder[0].NE__Order_Items__r){
                if((item.NE__Parent_Order_Item__c == null && item.NE__Bundle_Configuration__c == null && item.XC_PaymentMethod__c== null && item.XC_Product_Type__c != 'Billing' && item.XC_Product_Type__c != 'Technical') || (item.XC_ProvisioningSpareParts__c && item.XC_PaymentMethod__c== null)) {
                    wrapper.success = false;
                    wrapper.errorMessage = Label.XC_CL_SiteInspection_ErrorPayMethod;
                    return wrapper;
                }else if(item.XC_CreditAssignmentAvailable__c){
                    hasCreditAssignment = true;
                    break;
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ hasCreditAssignment: ' + hasCreditAssignment);
            //check otp signature in case the order has te credit assignment
            if(hasCreditAssignment){
                NE__Order__c currentOrd = listOrder[0];
                List<XC_DocumentSignature__c> otpSignatures = [SELECT Id FROM XC_DocumentSignature__c WHERE XC_Order__c = : currentOrd.Id AND XC_Step__c = '3'];
                if(otpSignatures.isEmpty()){
                    //check call recording on order
                    //getting actual configuration
                    List<XC_CM_CallRecordingConfiguration__mdt> callRecConfs = [SELECT 
                    XC_CheckOnDisconnect__c,XC_CheckOnProvisioning__c,XC_Enabled__c,XC_LegalEntity__c 
                    FROM XC_CM_CallRecordingConfiguration__mdt 
                    WHERE XC_LegalEntity__c = :listOrder[0].XC_LegalEntity__c LIMIT 1];
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ callRecConfs: ' + callRecConfs);
                    Boolean checkCTI = !callRecConfs.isEmpty() && callRecConfs[0].XC_CheckOnProvisioning__c && String.isNotBlank(listOrder[0].NE__OptyId__r.XC_CTI_Interaction__c) && String.isBlank(listOrder[0].XC_CTICallRecording__c) && listOrder[0].NE__Type__c == Label.XC_CL_Configuration_TypeInOrder;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkCTI -> ' + checkCTI);
                    if(checkCTI) {
                        wrapper.success = false;
                        wrapper.errorMessage = Label.XC_CL_CTIRecordingMandatoryProv;
                        return wrapper;
                    } else if(!callRecConfs.isEmpty() && callRecConfs[0].XC_CheckOnProvisioning__c && String.isBlank(listOrder[0].NE__OptyId__r.XC_CTI_Interaction__c)) {
                        wrapper.success = false;
                        wrapper.errorMessage = Label.XC_CL_SiteInspectionOTP;
                        return wrapper;
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check credit assignment passed'); 
            }       
        }

        if(myOrder.XC_LegalEntity__c == 'Codensa'|| myOrder.XC_LegalEntity__c == 'EnelX' || myOrder.XC_LegalEntity__c == 'EnelXMobilityChile' || ((myOrder.XC_LegalEntity__c == 'EnelXitalia' || myOrder.XC_LegalEntity__c == 'EnelXMobilityItalia') && (myOrder.XC_Segment__c == 'B2B' || myOrder.XC_Segment__c == 'B2G'))){
            workTypeCategory = Label.XC_CL_WorkType_SalesSiteInspection;
        }
        WorkOrder wo = XC_UTIL_WorkOrder.createWorkOrder(workTypeCategory, listOrder[0].XC_Country__c, listOrder[0].NE__OptyId__r.AccountId);
        if(!String.isBlank(listOrder[0].XC_InstallationAddress__c)) {
            List<XC_Address__c> listAddress = XC_UTIL_Sobject.selectAllFields(listOrder[0].XC_InstallationAddress__c);
            wo.XC_Address__c = listAddress[0].Id;
            XC_UTIL_Address.populateAddressFieldsFromAddress(wo, listAddress[0]); 
        }
        wo.ContactId = listOrder[0].NE__OptyId__r.XC_Contact__c ;
        wo.XC_LegalEntity__c = listOrder[0].XC_LegalEntity__c;
        wo.XC_Opportunity__c = listOrder[0].NE__OptyId__c;
        wo.XC_Configuration__c = listOrder[0].Id;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PendingContact;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder to create: ' + wo);
        XC_UTIL_Sobject.WrapperResult wrInsertWo = XC_UTIL_Sobject.insertRecord(wo);
        if(!wrInsertWo.success) {
            wrapper.success = wrInsertWo.success;
            wrapper.errorMessage = wrInsertWo.errorMessage;
            return wrapper;
        }
    
        
        wo.XC_CreatedAutomaticallyBySystem__c = true; //FSL NEW 1

        wrapper.isCreated = true;
        wrapper.workOrderInserted = wo;
        return wrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 30/10/2019
    * @description Method to create WO from Order
    * @param orderId - String
    * @return OutputWrapper
    */
    @AuraEnabled
    public static OutputWrapper createWorkOrder(String orderId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Create Site Inspection Work Order');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For order ' + orderId); 
        OutputWrapper wrapper = new OutputWrapper();
        List<NE__Order__c> listOrder = new List<NE__Order__c>([
            SELECT Id, XC_BillingModel__c, XC_Segment__c, XC_SignedByExternal__c,XC_InstallationAddress__c, XC_Country__c,XC_CTICallRecording__c,NE__OptyId__r.XC_CTI_Interaction__c,NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, NE__OptyId__c,NE__Type__c,
                (SELECT Id, XC_WorkTypeCategory__c, XC_Check_Final_Status__c, Status 
                FROM Work_Orders__r),
                (SELECT Id, XC_BillingModel__c, XC_Segment__c,  XC_CreditAssignmentAvailable__c, XC_IsAProduct__c, XC_PaymentMethodNeeded__c, NE__CatalogItem__r.XC_Site_Inspection_Required__c, XC_Product_Type__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_LegalEntityFormula__c, XC_BillingProfileLineItem__c 
                FROM NE__Order_Items__r)/*,
                (SELECT Id 
                FROM Document_Types__r 
                WHERE Category__c = 'SF_CONTRACT_SIGNED')*/
            FROM Ne__Order__c
            WHERE Id = :orderId
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listOrder -> ' + listOrder);

        // Check for Block Not Required Site Inspection
        Boolean siteInspectionRequired = false;
        for(NE__OrderItem__c oi : listOrder[0].NE__Order_Items__r) {
            if(oi.NE__CatalogItem__r.XC_Site_Inspection_Required__c) {
                siteInspectionRequired = true;
                break;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Site Inspection required: ' + siteInspectionRequired);
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BlockNotRequiredSiteInspection__c
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_Stream__c = :listOrder[0].XC_Segment__c AND XC_LegalEntity__c = :listOrder[0].XC_LegalEntity__c
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Legal Entity Configuration -> ' + listCM);
        if(!siteInspectionRequired && !listCM.isEmpty() && listCM[0].XC_BlockNotRequiredSiteInspection__c) {
            wrapper.success = false;
            wrapper.errorMessage = Label.XC_CL_SiteInspection_NotRequired;
            return wrapper;
        }

        // Check for Billing Profile Line Item:
        if(!XC_UTIL_ConfigurationItem.checkBillingProfile(listOrder[0].NE__Order_Items__r, 'Site Inspection')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error for missing billing profile'); 
            wrapper.success = false;
            wrapper.errorMessage = Label.XC_CL_ErrorMissingBPLI;
            return wrapper;
        }

        Map<Id, List<String>> mapOrderitemDocument = new Map<Id, List<String>>();
        List<Id> confItemIdList = new List<Id>();
        for(NE__OrderItem__c item : listOrder[0].NE__Order_Items__r){
            confItemIdList.add(item.id);
        }
        mapOrderitemDocument = XC_UTIL_DocumentComplianceMaster.getDocumentComplianceMaster('C0', confItemIdList);
        Boolean hasWebSignature = String.isNotBlank(listOrder[0].XC_SignedByExternal__c) && listOrder[0].XC_SignedByExternal__c.equalsIgnoreCase('Web');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ hasWebSignature -> ' + hasWebSignature);
        if(!hasWebSignature && !XC_LCC069_ComplianceVerification1.checkDoxeeDocumentations(listOrder[0].Id, mapOrderitemDocument)){
            wrapper.success = false;
            wrapper.errorMessage = Label.XC_CL_SiteInspectionCompliance0Error + XC_LCC069_ComplianceVerification1_U.retrieveMissingDocumentAsString(mapOrderitemDocument, listOrder[0].Id);
            return wrapper;
        }

        // Check for EnelXItalia:
        if(listOrder[0].XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || listOrder[0].XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For LE EnelXItalia');
            Boolean hasCreditAssignment = false;
            for(NE__OrderItem__c item : listOrder[0].NE__Order_Items__r){
                if((item.NE__Parent_Order_Item__c == null && item.NE__Bundle_Configuration__c == null && item.XC_PaymentMethod__c== null && item.XC_Product_Type__c != 'Billing' && item.XC_Product_Type__c != 'Technical') || (item.XC_ProvisioningSpareParts__c && item.XC_PaymentMethod__c== null)) {
                    wrapper.success = false;
                    wrapper.errorMessage = Label.XC_CL_SiteInspection_ErrorPayMethod;
                    return wrapper;
                }else if(item.XC_CreditAssignmentAvailable__c){
                    hasCreditAssignment = true;
                    break;
                }
            }
            //check otp signature in case the order has te credit assignment
            if(hasCreditAssignment){
                NE__Order__c currentOrd = listOrder[0];
                List<XC_DocumentSignature__c> otpSignatures = [SELECT Id FROM XC_DocumentSignature__c WHERE XC_Order__c = : currentOrd.Id AND XC_Step__c = '3'];
                if(otpSignatures.isEmpty()){
                    //check call recording on order
                    //getting actual configuration
                    List<XC_CM_CallRecordingConfiguration__mdt> callRecConfs = [SELECT 
                    XC_CheckOnDisconnect__c,XC_CheckOnProvisioning__c,XC_Enabled__c,XC_LegalEntity__c 
                    FROM XC_CM_CallRecordingConfiguration__mdt 
                    WHERE XC_LegalEntity__c = :listOrder[0].XC_LegalEntity__c LIMIT 1];
                    Boolean checkCTI = !callRecConfs.isEmpty() && callRecConfs[0].XC_CheckOnProvisioning__c && String.isNotBlank(listOrder[0].NE__OptyId__r.XC_CTI_Interaction__c) && String.isBlank(listOrder[0].XC_CTICallRecording__c) && listOrder[0].NE__Type__c == Label.XC_CL_Configuration_TypeInOrder;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ checkCTI -> ' + checkCTI);
                    if(checkCTI) {
                        wrapper.success = false;
                        wrapper.errorMessage = Label.XC_CL_CTIRecordingMandatoryProv;
                        return wrapper;
                    } else if(!callRecConfs.isEmpty() && callRecConfs[0].XC_CheckOnProvisioning__c && String.isBlank(listOrder[0].NE__OptyId__r.XC_CTI_Interaction__c)) {
                        wrapper.success = false;
                        wrapper.errorMessage = Label.XC_CL_SiteInspectionOTP;
                        return wrapper;
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check credit assignment passed'); 
            }        
        }
        NE__Order__c myOrder = listOrder[0];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For order ' + myOrder); 
        for(WorkOrder myWo : myOrder.Work_Orders__r) {
            if(myWo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection && !myWo.XC_Check_Final_Status__c) {
                wrapper.success = false;
                wrapper.errorMessage = Label.XC_CL_WoSiteInspectionExists;
                return wrapper;
            }
        }
        String workTypeCategory = Label.XC_CL_WorkType_SiteInspection;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ workTypeCategory ' + workTypeCategory); 
        if(myOrder.XC_LegalEntity__c == 'Codensa'){
            workTypeCategory = Label.XC_CL_WorkType_SalesSiteInspection;
        }
        WorkOrder wo = XC_UTIL_WorkOrder.createWorkOrder(workTypeCategory, listOrder[0].XC_Country__c, listOrder[0].NE__OptyId__r.AccountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder created: ' + wo); 
        if(!String.isBlank(listOrder[0].XC_InstallationAddress__c)) {
            List<XC_Address__c> listAddress = XC_UTIL_Sobject.selectAllFields(listOrder[0].XC_InstallationAddress__c);
            wo.XC_Address__c = listAddress[0].Id;
            XC_UTIL_Address.populateAddressFieldsFromAddress(wo, listAddress[0]); 
        }
        wo.ContactId = listOrder[0].NE__OptyId__r.XC_Contact__c ;
        wo.XC_LegalEntity__c = listOrder[0].XC_LegalEntity__c;
        wo.XC_Opportunity__c = listOrder[0].NE__OptyId__c;
        wo.XC_Configuration__c = listOrder[0].Id;
        wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PendingContact;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WorkOrder created: ' + wo);
        XC_UTIL_Sobject.WrapperResult wrInsertWo = XC_UTIL_Sobject.insertRecord(wo);
        if(!wrInsertWo.success) {
            wrapper.success = wrInsertWo.success;
            wrapper.errorMessage = wrInsertWo.errorMessage;
            return wrapper;
        }
        wrapper.workOrderInserted = wo;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Returned wrapper: ' + wrapper);
        return wrapper;
    }

}
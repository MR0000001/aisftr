/**
*@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
*@date Creation 30/01/2019
*@date Modification dd/mm/yyyy
*@description controller for custom lightning component for disconnect  asset 
*/
public without sharing class XC_LCC073_DisconnectAsset {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC073_DisconnectAsset');
    
    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Class to return check result ok Asset related to the Case
     */ 
    private Class CheckOnAssetResult {
        Boolean checkResultKO = false;
        String resultMessage = '';
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description Check penality before disconnect.
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */
    /*@AuraEnabled
    public static XC_UTIL_ResultWrapper checkPenalityBeforeDisconnect(String recordId){
    //XC_CM_DisconnectBillingMethod__mdt penaltyBillMethod) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in checkPenalityBeforeDisconnect');
        XC_UTIL_ResultWrapper wr;     
        Asset a = XC_LCC073_DisconnectAsset_D.getAsset(recordId);
        if(a == null){
            wr = new XC_UTIL_ResultWrapper();
            wr.success = false;
            wr.objectInfo = '0';
            wr.resultMessage = Label.XC_CL_NoAccessObjOrField;
            return wr;
        }

        if(a.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_Configuration_SubtypeOutOfBusiness ||
           a.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_Configuration_SubtypeEndOfSupply ||
           a.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_Configuration_SubtypeBusinessDecision ||
           a.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_Configuration_SubtypeEarlyRenewal ||
           a.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_Configuration_SubtypeClaimServiceUsed        
        ) {
              System.debug('@@@JUMP@@@');
              wr = new XC_UTIL_ResultWrapper();
              wr.success = true;
              wr.objectInfo = '0';
              wr.resultMessage = Label.XC_CL_NoPenality;
              return wr;
        }
        
        return XC_LCC095_ShowPenalty.showPenalty(recordId);    
    }*/
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - monica.cutillo@nttdata.com
    * @description Check penality before disconnect case.
    * @param recordId the record id
    * @param calculationWr the CalculationInputWrapper, can be null
    * @return the x C UTI L result wrapper
    */
    //@AuraEnabled
    public static XC_UTIL_ResultWrapper checkPenalityBeforeDisconnectCase(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calculationWr){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in checkPenalityBeforeDisconnectCase');
        String standardAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        Map<String,String> objInfoData = new Map<String,String>();

        List<Case> cases = XC_LCC073_DisconnectAsset_D.getCases(calculationWr.caso.Id);
        
        if(cases.isEmpty() || cases[0].AssetId == null || cases[0].Asset.RecordTypeId!=standardAssetId || 
            cases[0].Asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == 'Out of business' || 
            cases[0].Asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == 'End of supply' || 
            cases[0].Asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == 'Business decision' || 
            cases[0].Asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == 'Early renewal' || 
            cases[0].Asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Subtype__c == 'Claim applicable (service used)'
            ) {
            wr.success = true;
            wr.resultMessage = Label.XC_CL_CaseChangeOrderError;
            wr.objectInfo = '0';
            return wr; 
        } else{
            //return XC_LCC095_ShowPenalty.showPenalty(cases[0].AssetId, cases[0].XC_Communication_Date__c);
            return XC_LCC095_ShowPenalty.showPenalty(calculationWr);
        }
    }
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Disconnect asset.
    *@param recordId the asset id
    *@param subtype the subtype
    *@param caso the Case
    *@return the x C UTI L result wrapper
    */
    //@AuraEnabled
    //public static XC_UTIL_ResultWrapper disconnectAsset(String recordId, String subtype, String caseId){
    public static XC_UTIL_ResultWrapper disconnectAsset(String recordId, String subtype, Case caso){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in disconnectAsset');
        //return XC_LCC073_U_DisconnectAsset.disconnectAsset(recordId, subtype, caseId);
        return XC_LCC073_U_DisconnectAsset.disconnectAsset(recordId, subtype, caso);
    }
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Disconnect asset from case.
    *@param recordId the record id
    *@param subtype the subtype
    * @param skipOrderCreation 
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper disconnectAssetFromCase(String recordId,String subtype, Boolean skipOrderCreation){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in disconnectAssetFromCase');
        String standardAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_CaseChangeOrderError;
        List<Case> cases = XC_LCC073_DisconnectAsset_D.getCases(recordId);
        
        if(cases.isEmpty() || cases[0].AssetId == null || cases[0].Asset.RecordTypeId!=standardAssetId ) { 
            return wr; 
        } else if(skipOrderCreation){
            return skipOrderCreationAndClosure(recordId);
        } else{
            return disconnectAsset(cases[0].AssetId, subtype, cases[0]); //recordId
        }
    }
    
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Change order asset.
    *@param recordId the record id
    *@param subtype the subtype
    *@param caseId the caseId
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper changeOrderAsset(String recordId, String subtype, String caseId){
        return XC_LCC073_U_DisconnectAsset.changeOrderAsset(recordId, subtype, caseId);
    }
     
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Change order asset from case.
    *@param recordId the record id
    *@param subtype the subtype
    * @param skipOrderCreation 
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper changeOrderAssetFromCase(String recordId,String subtype, Boolean skipOrderCreation){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in changeOrderAssetFromCase');
        String standardAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_CaseChangeOrderError;
        List<Case> cases = XC_LCC073_DisconnectAsset_D.getCases(recordId);
        
        if(cases.isEmpty() 
           || cases[0].AssetId == null || cases[0].Asset.RecordTypeId!=standardAssetId ) {
            return wr; 
        } else if(skipOrderCreation){
            return skipOrderCreationAndClosure(recordId);
        } else{
            return changeOrderAsset(cases[0].AssetId,subtype, recordId);
        }
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com , Monica Cutillo - mcutillo@deloitte.it
     * @description Populate subtype.
     * @param recordId the record id
     * @param operationType operationType {'Disconnect','Change Order'} 
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper populateSubtype(String recordId, String operationType){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> in populateSubtype');
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        Map<Id,Case> cases = new Map<Id,Case>(
            [SELECT Id, Reason, AssetId,XC_Communication_Date__c,XC_Channel_Attribute__c, Origin,
                    Asset.XC_ActivationDate__c, XC_Subtype__c, SubCause__c, Status, XC_LegalEntity__c,
                    Asset.NE__Order_Config__c, Asset.NE__Order_Config__r.NE__Type__c, Asset.NE__Order_Config__r.XC_Status__c,
                    Asset.NE__Order_Config__r.Name, Asset.XC_LegalEntity__c, Asset.XC_Segment__c, Description, Asset.XC_LastInvoiceDate__c,
                    Asset.XC_BillingModel__c
               FROM Case 
              WHERE Id =: recordId]);

        if(cases.isEmpty()){
            wr.resultMessage = Label.XC_CL_Reason_Subcause;
            return wr;
        }

        Case caso = cases.values()[0];
        Boolean isToManageCO = checkIsToManageChangeOwner(caso);
        //Check Order 'Disconnect' OR 'ChangeOrder' already opened
        if(caso.Asset.NE__Order_Config__c != null && 
          (caso.Asset.NE__Order_Config__r.NE__Type__c == 'Disconnection' || caso.Asset.NE__Order_Config__r.NE__Type__c == 'ChangeOrder') &&
           caso.Asset.NE__Order_Config__r.XC_Status__c != 'Closed' && caso.Asset.NE__Order_Config__r.XC_Status__c != 'Cancelled'){
            wr.resultMessage = String.format(Label.XC_CL_OrderAlreadyInProgress, new List<String>{caso.Asset.NE__Order_Config__r.Name});
            updateChangeOwnershipCase(caso, wr, isToManageCO);
            return wr;
        }
        //Check Order 'InOrder' already opened for ChangeOrder
        if(caso.Asset.NE__Order_Config__c != null && 
          (caso.Asset.NE__Order_Config__r.NE__Type__c == 'InOrder' && operationType == 'ChangeOrder') &&
           caso.Asset.NE__Order_Config__r.XC_Status__c != 'Closed' && caso.Asset.NE__Order_Config__r.XC_Status__c != 'Cancelled'){
            wr.resultMessage = String.format(Label.XC_CL_OrderAlreadyInProgress, new List<String>{caso.Asset.NE__Order_Config__r.Name});
            updateChangeOwnershipCase(caso, wr, isToManageCO);
            return wr;
        }
          //20211201_DD_ERR_03 - start
        //Check Order 'InOrder' cancelled for ChangeOrder
        if(caso.Asset.NE__Order_Config__c != null && 
          (caso.Asset.NE__Order_Config__r.NE__Type__c == 'InOrder' && operationType == 'ChangeOrder') &&
           caso.Asset.NE__Order_Config__r.XC_Status__c == 'Cancelled'){
            wr.resultMessage = String.format(Label.XC_CL_LCC073_OrderCancelled, new List<String>{caso.Asset.NE__Order_Config__r.Name});
            return wr;
        }
        //20211201_DD_ERR_03 - end
        if(caso.Status == Label.XC_CL_Case_Status007 || caso.Status == Label.XC_CL_Case_Status008){
            wr.resultMessage = Label.XC_CL_OperationNotAllowedOnCaseClosedCancelled;
            return wr;
        }
        if(caso.AssetId == null){
            wr.resultMessage = Label.XC_CL_NoAssetForCase;
            return wr;
        }
        /*if(caso.XC_Channel_Attribute__c=='CA003' && caso.XC_Communication_Date__c==null){
             wr.resultMessage = Label.XC_CL_CommunicationDateNotFilled;
             return wr;
        }/ *else if(caso.XC_Channel_Attribute__c!='CA003'){
            caso.XC_Communication_Date__c = Date.today();
            XC_UTIL_Sobject.updateRecord(caso);
        }*/
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> pre-popolo la pick SubStatus');
        if(operationType=='Disconnect'){
            return XC_UTIL_DisconnectAssetManager.manageInitDisconnection(caso);
        }else if(operationType=='ChangeOrder'){
            return XC_UTIL_ChangeOrder.manageChangeOrder(caso);
        }

        wr.resultMessage = Label.XC_CL_OperationNotAllowed;
        return wr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description checkOrderSubtypeBeaforeChangeOrder
     * @param caso the Case from starts the ChangeOrder
     * @param orderSubtype orderSubtype from metadata
     * @param operationType (Disconnect or Change Order)
     * @return the cheks result wrapper
     */
    public static XC_UTIL_ResultWrapper checkOrderSubtypeBeaforeChangeOrder(Case caso, String orderSubtype, String operationType){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        if(caso.AssetId == null){
            wr.success = false;
            wr.resultMessage = Label.XC_CL_NoAssetForCase;
            return wr;
        }
        CheckOnAssetResult ceckAssRes = checkAssetStatus(caso);
        if(ceckAssRes.checkResultKO){
            wr.success = false;
            wr.resultMessage = ceckAssRes.resultMessage;
            return wr;
        }
        return checkOrderSubtypeBeaforeOperation(caso,orderSubtype,operationType);
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com , Monica Cutillo - mcutillo@deloitte.it
     * @description checkOrderSubtypeBeaforeOperation
     * @param caso the Case from starts the operation
     * @param orderSubtype orderSubtype from metadata
     * @param operationType (Disconnect or Change Order)
     * @return the cheks result wrapper
     */
    public static XC_UTIL_ResultWrapper checkOrderSubtypeBeaforeOperation(Case caso, String orderSubtype, String operationType){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        if(caso.AssetId == null){
            wr.success = false;
            wr.resultMessage = Label.XC_CL_NoAssetForCase;
            return wr;
        }
        wr.success = true;
        if(operationType == 'ChangeOrder'){
            wr.resultMessage = orderSubtype;
        }
        if((caso.XC_LegalEntity__c == 'EndesaX' || caso.XC_LegalEntity__c == 'EnelXMobilitySpain') && (orderSubtype == Label.XC_CL_OrdersubTypeValue_RequestedByTheClient || orderSubtype == Label.XC_CL_OrdersubTypeValue_ScheduleDeactivation)){
            //wr.resultMessage = XC_UTIL_DisconnectAsset.manageRequestByClient(caso.AssetId);
            String reqByClientType = XC_UTIL_DisconnectAsset.manageRequestByClient(caso.AssetId);
            if(Label.XC_CL_OrdersubTypeValue_ScheduleDeactivation == reqByClientType && operationType != 'ChangeOrder'){
                wr.success = false;
                wr.resultMessage = Label.XC_CL_ScheduledDeactivationMessage;
                return wr;
            }
            if(Label.XC_CL_OrdersubTypeValue_ScheduleDeactivation != reqByClientType && operationType == 'ChangeOrder'){
                wr.success = false;
                wr.resultMessage = Label.XC_CL_ScheduledDeactivationNotMessage;
                return wr;
            }
            if(String.isNotBlank(reqByClientType)){
                wr.objectInfo = reqByClientType;
            }
        }else if(caso.XC_LegalEntity__c == 'EndesaX' && caso.Origin != 'CAN003' &&
                 (orderSubtype == Label.XC_CL_OrdersubTypeValue_Complaint || orderSubtype == Label.XC_CL_Configuration_SubtypeClaimNotApplicable)){
            String complType = XC_UTIL_DisconnectAsset.manageComplaint(caso.AssetId);
            if(Label.XC_CL_Configuration_SubtypeClaimNotApplicable == complType && operationType != 'ChangeOrder'){
                wr.success = false;
                wr.resultMessage = Label.XC_CL_ClaimNotApplicableMessage;
                return wr;
            }
            if(Label.XC_CL_Configuration_SubtypeClaimNotApplicable != complType && operationType == 'ChangeOrder'){
                wr.success = false;
                wr.resultMessage = Label.XC_CL_ClaimNotApplicableNotMessage;
                return wr;
            }
            wr.objectInfo = Label.XC_CL_OrdersubTypeValue_Complaint;
            wr.resultMessage = complType;
        } // [Begin - NR1640 Fix - 20220503 - LR]
        // XC_LastInvoiceDate__c is populated in the cancel an old subscription step and used to start a new subscription
        // The creation of the change order is blocked if there is a subscription that starts in the future.
        else if(caso.Asset.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelSole && operationType == 'ChangeOrder' && 
                caso.Asset.XC_BillingModel__c == Label.XC_CL_BillingModel_Recurring && (caso.Asset.XC_Segment__c =='B2B' ||caso.Asset.XC_Segment__c =='B2G')
                && orderSubtype == Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade){  
                    if(caso.Asset.XC_LastInvoiceDate__c != null && DateTime.Now().dateGMT() < caso.Asset.XC_LastInvoiceDate__c){
                        wr.success = false;
                        wr.resultMessage = Label.XC_CL_ServiceUpDownNotAllowed + ' ' + caso.Asset.XC_LastInvoiceDate__c;
                        return wr;
                    }
        } // [End - NR1640 Fix - 20220503 - LR]
        else{   
            wr.resultMessage = orderSubtype;
            //Boolean check15 = checkDaysBetween(caso.Asset.XC_ActivationDate__c, caso.XC_Communication_Date__c, 15);
            /*if(orderSubtype == 'Rethinking'){
                if(caso.XC_Channel_Attribute__c=='CA003' && caso.XC_Communication_Date__c==null){
                    wr.resultMessage = Label.XC_CL_CommunicationDateNotFilled;
                    return wr;
                }
                else{
                    Boolean check15 = checkDaysBetween(caso.Asset.XC_ActivationDate__c, caso.XC_Communication_Date__c, 15);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '-> check15 = '+check15);
                    if(check15){
                        wr.resultMessage = Label.XC_CL_RethinkingNotPossible;
                        wr.success = false;
                        return wr;
                    }
                }
            }
            else*/ 
            if(orderSubtype == Label.XC_CL_ChangeOfOwnership){
                CheckOnAssetResult ceckAssRes = checkActiveAssetSon(caso);
                if(ceckAssRes.checkResultKO){
                    wr.success = false;
                    wr.resultMessage = ceckAssRes.resultMessage;
                }
            }
        }
        return wr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description skipOrderCreationAndClosure
     * @param caseId the Case id
     * @return the XC_UTIL_ResultWrapper result
     */
    private static XC_UTIL_ResultWrapper skipOrderCreationAndClosure(String caseId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        rw.resultMessage = Label.XC_CL_OperationPerformed;

        Map<Id,Case> caseData = XC_UTIL_Case_D.retrieveCaseTypeData(new List<String>{caseId});
        Map<Id, XC_CM_Case_Type_Setting__mdt> mtData = XC_UTIL_Case_D.retriveCaseTypeSettingMtdFromCases(caseData.values());

        XC_CM_Case_Type_Setting__mdt mtd = mtData.get(caseId);
        if(mtd == null){
            rw.resultMessage = '';
            return rw;
        }
        //else Case closure
        Case caso = caseData.values()[0];
        caso.XC_Resolution__c = mtd.XC_Resolution__c;
        caso.XC_Result__c = mtd.XC_Result__c;
        //caso.CaseRemarks__c = mtd.XC_CaseRemarks__c;
        caso.CaseRemarks__c = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(mtd, caso.XC_LegalEntity__c); // MC 03/05/2020
        List<XC_UTIL_Sobject.WrapperResult> caseUpdRes = XC_UTIL_DML.updateRecords(new List<Case>{caso});
        return rw;
    }
    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Check Asset status is Active
     * @param caso the Case
     * @return the CheckOnAssetResult wr
     */
    private static CheckOnAssetResult checkAssetStatus(Case caso) {
        System.debug('In checkAssetStatus con '+caso.AssetId);
        CheckOnAssetResult result = new CheckOnAssetResult();
        Map<Id,Asset> assetData = new Map<Id,Asset>(
        [ SELECT id, Status
            FROM Asset 
           WHERE id=: caso.AssetId]);

        Asset a = assetData.values()[0];
        System.debug('Asset Status='+a.Status);
        if(a.Status != Label.XC_CL_Asset_StatusActive){
            result.checkResultKO = true;
            result.resultMessage = Label.XC_CL_NoChangeOrdOnProvisioningProduct;
        }
        return result;
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description Check state obj children.
     * @param caso the Case
     * @return the CheckOnAssetResult wr
     */
    private static CheckOnAssetResult checkActiveAssetSon(Case caso) {
        System.debug('In checkActiveAssetSon con '+caso.AssetId);
        CheckOnAssetResult result = new CheckOnAssetResult();
        Map<Id,Asset> assetData = new Map<Id,Asset>(
        [ SELECT id, XC_LegalEntity__c, XC_Segment__c,
                (SELECT id, Status, XC_WorkTypeCategory__c
                   FROM WorkOrders 
                  WHERE Status='New' OR Status = 'Assigned' OR Status = 'On Hold' OR Status='In Progress'),
                (SELECT id, Status, RecordType.DeveloperName, Description, AssetId, CaseNumber
                   FROM Cases 
                  //WHERE (Status='New' OR Status = 'On Hold' OR Status='In Progress') AND Id <>: Caso.Id) 
                  WHERE (Status='ESTA001' OR Status = 'ESTA004' OR Status='ESTA003') AND Id <>: Caso.Id) 
           FROM Asset 
          WHERE id=: caso.AssetId]);

        Asset a = assetData.values()[0];
        Map<String,Object> utilMap = new Map<String,Object>{'mapAsset' => assetData};
        if(!a.WorkOrders.isEmpty() || !a.Cases.isEmpty()){
            //return true;
            /*result.checkResultKO = true;
            result.resultMessage = Label.XC_CL_ActionNotAllowed;*/
            result = manageChangeOwnershipBlock(utilMap, caso);
        }
        return result;
    }

    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkCallRecordingNeeded(String caseId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        Case currentCase = [SELECT Id,XC_CTI_Interaction__c,XC_CTICallRecording__c,XC_LegalEntity__c FROM Case WHERE Id= : caseId];

        if(String.isBlank(currentCase.XC_CTI_Interaction__c)){
            rw.success = true;
            return rw;
        }

        //check if LE control on disconnect is enabled
        List<XC_CM_CallRecordingConfiguration__mdt> callRecConfs = [SELECT XC_LegalEntity__c,XC_CheckOnDisconnect__c FROM XC_CM_CallRecordingConfiguration__mdt WHERE XC_LegalEntity__c = :currentCase.XC_LegalEntity__c LIMIT 1];

        if(String.isBlank(currentCase.XC_CTICallRecording__c) && !callRecConfs.isEmpty()){
            if(callRecConfs[0].XC_CheckOnDisconnect__c){
                rw.success = false;
                rw.resultMessage = Label.XC_CL_LCP075_CaseDisconnectCallRec;
                return rw;
            }
        }
        rw.success = true;
        return rw;

    }


    /**
    * @description method to manage the change of ownership block. 
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    * @param Case caso
    * @return CheckOnAssetResult
    **/
    private static CheckOnAssetResult manageChangeOwnershipBlock(Map<String,Object> utilMap, Case caso){

        CheckOnAssetResult result = new CheckOnAssetResult();

        if(XC_UTIL_ChangeOrder.checkIsToBlock(utilMap)){
            result.checkResultKO = true;
            result.resultMessage = Label.XC_CL_ActionNotAllowed;
            if(((Map<String,String>)utilMap.get('complaintCase'))!= null && !((Map<String,String>)utilMap.get('complaintCase')).isEmpty()){
                if(!XC_UTIL_ChangeOrder.manageChangeOwnershipCase(utilMap, caso)){
                    result.checkResultKO = true;
                    result.resultMessage = (String)utilMap.get('ErrorMessage');
                }
            }
            return result;
        } else if(((Map<Id, Case>)utilMap.get('caseToUpdate'))!= null && !((Map<Id, Case>)utilMap.get('caseToUpdate')).isEmpty()){//Check if it is necessary to update Information and Management Case 
            if(!XC_UTIL_ChangeOrder.updateCase(utilMap)){
                result.checkResultKO = true;
                result.resultMessage = (String)utilMap.get('ErrorMessage');
            }
        }

        return result; 
    }

    /**
    * @description method that updates the case of change of ownership
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param XC_UTIL_ResultWrapper wr
    * @param Case caso
    * @param Boolean isToManageCO
    **/
    private static void updateChangeOwnershipCase(Case caso, XC_UTIL_ResultWrapper wr, Boolean isToManageCO){
       
        Map<String,Object> utilMap = new Map<String,Object>();
        if(isToManageCO){
            if(!XC_UTIL_ChangeOrder.manageChangeOwnershipCase(utilMap, caso)){
                wr.resultMessage = (String)utilMap.get('ErrorMessage');
            }  
        }   
    }

    
    /**
    * @description method that checks if it is a change of ownership and if it is necessary to update the case
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Case caso
    * @return boolean
    **/
    private static boolean checkIsToManageChangeOwner(Case caso){

        XC_UTIL_DisconnectAsset.CaseSearchFilter caseFilter = new XC_UTIL_DisconnectAsset.CaseSearchFilter(caso.Reason, caso.SubCause__c, caso.XC_Subtype__c);
        XC_OrderSubtypeByCase__mdt mdt = XC_UTIL_DisconnectAsset.getAssetSubtypeByCaseReasonAndSubtype(caseFilter,'ChangeOrder');
        if(mdt != null && mdt.OrderSubtype__c == Label.XC_CL_ChangeOfOwnership){
            return XC_UTIL_ChangeOrder.getIsToSkipCOBlock(caso.Asset.XC_LegalEntity__c, caso.Asset.XC_Segment__c);
        }
        return false;
    }


}
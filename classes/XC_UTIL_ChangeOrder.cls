/**
*@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
*@date Creation 12/09/2019
*@date Modification 27/01/2020 - Monica Cutillo - mcutillo@deloitte.it
*@description controller manage ChangeOrder
*/
public without sharing class XC_UTIL_ChangeOrder {  
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC073_DisconnectAsset');

    /**
     * @description manageChangeOrder
     * @param c the case
     * @return result wrapper
     */
    public static XC_UTIL_ResultWrapper manageChangeOrder(Case c){ 
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        XC_UTIL_DisconnectAsset.CaseSearchFilter caseFilter = new XC_UTIL_DisconnectAsset.CaseSearchFilter(c.Reason, c.SubCause__c,c.XC_Subtype__c);
        XC_OrderSubtypeByCase__mdt mtd = XC_UTIL_DisconnectAsset.getAssetSubtypeByCaseReasonAndSubtype(caseFilter,'ChangeOrder');
        String fromMetadato;
        Boolean skipOrderCreation = false;
        if(mtd != null) {
            fromMetadato = mtd.OrderSubtype__c;
            skipOrderCreation = mtd.XC_SkipOrderCreation__c;
        }
        Boolean ckeckError = ckeckError(fromMetadato,c);
        if(ckeckError){
              wr.success = false;
              wr.resultMessage = Label.XC_CL_SohoNotValid;
              return wr;
        }
        wr = XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeChangeOrder(c, fromMetadato,'ChangeOrder');
        if(wr.success){
            String orderSubtype = wr.resultMessage;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Change Order > orderSubtype='+orderSubtype);

            Map<String,Object> objInfoData = new Map<String,Object>();
            objInfoData.put('orderSubtype', orderSubtype);
            objInfoData.put('skipOrderCreation', skipOrderCreation);

            /* LEGAL TEXT CONFIG */
            if(c.XC_LegalEntity__c == 'EndesaX' || c.XC_LegalEntity__c == 'EnelXMobilitySpain'){
                objInfoData.put('showLegalText', true);
                objInfoData.put('legalText', Label.XC_CL_BaseLegalText);
            }else{
                objInfoData.put('showLegalText', false);
            }
            
            XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(c.assetId, orderSubtype, c.XC_Communication_Date__c);
            calcWr.caso = c;
            XC_UTIL_ResultWrapper optionRW = XC_LCC073_DisconnectAsset.checkPenalityBeforeDisconnectCase(calcWr);
            objInfoData.put('purchOptionValue', optionRW.objectInfo);
            objInfoData.put('isOptionvalid', optionRW.isValid);
            if(calcWr.asset != null){
                objInfoData.put('assetId', calcWr.asset.Id);
                objInfoData.put('contractNumber', calcWr.asset.XC_Contract__r.ContractNumber);
                if(calcWr.asset.XC_Contract__r.StartDate != null){
                    objInfoData.put('contrStartD', calcWr.asset.XC_Contract__r.StartDate.format());
                }
                if(calcWr.asset.XC_Contract__r.EndDate != null){
                    objInfoData.put('contrEndD', calcWr.asset.XC_Contract__r.EndDate.format());
                }
            }
        
            wr.objectInfo = JSON.serialize(objInfoData);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '-> manageChangeOrder RW='+wr);

            //save data on Case for Conga Legal text - MC 24/04/2020
            List<XC_UTIL_Sobject.WrapperResult> caseUpdRes = XC_UTIL_PenaltyRefundCalculation.saveCalculatedDataOnCase(calcWr, objInfoData);
        }
        return wr;
    }

    /**
     * @description ckeckError
     * @param fromMetadato value
     * @param c the case
     * @return check result
     */
    public static Boolean ckeckError(String fromMetadato, Case c){
        Boolean errorFound = false;
        if(fromMetadato=='Substitution (Malfunction)' && c.AssetId!=null){
            Asset a = [SELECT id, AccountId, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                      XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Account__c,XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Account__r.XC_RecordTypeDeveloperName__c,
                      XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Account__r.XC_SohoType__c
                      FROM Asset WHERE id =: c.AssetId limit 1];
            if(a.AccountId!= a.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Account__c && !ckeckIfValidSoho(a.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Account__r.XC_RecordTypeDeveloperName__c, a.XC_BillingProfileLineItem__r.XC_BillingProfile__r.NE__Account__r.XC_SohoType__c)){
                errorFound = true;
            }
		}
        return errorFound;

    }
    
    /**
     * @description ckeckIfValidSoho
     * @param recordTypeName
     * @param sohoType
     * @return check result
     */
    public static Boolean ckeckIfValidSoho(String recordTypeName, String sohoType){
        Boolean valid = true;
        if(recordTypeName=='XC_GLO_Account_Soho' && (sohoType!='Soho' || sohoType!=null )) {
            valid = false;
        }
        return valid;
    }


    /**
    * @description method to check if it is possible to skip the block due to pending activities linked to asset
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    * @return Boolean
    **/
    public static boolean checkIsToBlock(Map<String,Object> utilMap){

        //Remove block filter for change of ownership 
        Set<String> workOrderToExclude = new Set<String>{Label.XC_CL_WorkType_Repair, Label.XC_CL_WorkType_PlannedMaintenance,
                                                        'Diagnostic', Label.XC_CL_WorkType_QualityCheckInspection};
        
        Asset a = ((Map<Id,Asset>)utilMap.get('mapAsset')).values()[0];
        Map<String,String> compliantCaseMap = new Map<String,String>();
        
        if(getIsToSkipCOBlock(a.XC_LegalEntity__c, a.XC_Segment__c)){
            Map<Id, Case> caseToUpdate = new Map<Id, Case>();
            Boolean isToBlock = false;
            for(WorkOrder wo: a.WorkOrders){ //check if there are work orders blocking change ownership
                if(!workOrderToExclude.contains(wo.XC_WorkTypeCategory__c)){
                    isToBlock =  true;
                }
            }

            for(Case c: a.Cases){ //check if there are cases blocking change ownership

                if(c.RecordType.DeveloperName.containsIgnorecase('Management_Case') || c.RecordType.DeveloperName.containsIgnorecase('Information_Case') || c.RecordType.DeveloperName =='XC_ESP_Case'){
                        caseToUpdate.put(c.Id, c);
                }else{
                    isToBlock = true;
                    if(c.RecordType.DeveloperName.containsIgnorecase('Complaint_Case')){
                        compliantCaseMap.put(c.Id, c.CaseNumber + '(' + c.Id + ')' );
                    }
                }
            }

            utilMap.put('complaintCase', compliantCaseMap);
            utilMap.put('caseToUpdate', caseToUpdate);
            return isToBlock;
        }


        return true; // for B2B or legal entity different from endesaX
    }


    /**
    * @description method to update case with record type Information and Management. 
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    * @return Boolean
    **/
    public static boolean updateCase(Map<String,Object> utilMap){

        Map<Id, Case> caseToUpdateMap = (Map<Id, Case>)utilMap.get('caseToUpdate');
        List<Case> casetoUpdateList = new List<Case>();

        for(Case c : caseToUpdateMap.values()){ // empty the asset lookup and save it in the description field
            if(!String.isBlank(c.AssetId)){
                c.Description =  (!String.isBlank(c.Description)) ? c.Description + '\n' + Label.XC_CL_EmptyAssetId + ':' + c.AssetId : Label.XC_CL_EmptyAssetId + ':' + c.AssetId;
                c.AssetId = null; 
                casetoUpdateList.add(c);
            }
        }


        if(!casetoUpdateList.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> updateCaseResult = XC_UTIL_Sobject.updateListRecords(casetoUpdateList);
            for(XC_UTIL_Sobject.WrapperResult updateRes: updateCaseResult){
                if(!updateRes.success){
                    utilMap.put('ErrorMessage', updateRes.ErrorMessage);
                    return false;
                }
            }
        }
        return true;
    }


    /**
    * @description method to manage change of ownership case. The field description will contain all compliant cases blocking the processing of the change of ownership
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    **/
    public static Boolean manageChangeOwnershipCase(Map<String,Object> utilMap, Case changeOwnershipCase){

        Map<String,String> compliantCaseMap = (Map<String,String>)utilMap.get('complaintCase');

        Set<Case> caseToUpdate = new Set<Case>();

        // assignment rules
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

        if(compliantCaseMap != null && !compliantCaseMap.isEmpty()){// sets in the description field of the change of ownership case the information of the compliant case that blocks the change of ownership  

            String complaintCaseInfo= !String.isBlank(changeOwnershipCase.description) ? changeOwnershipCase.description.subStringBetween(':[', '].') : null;
            List<String> compliantCaseList = !String.isBlank(complaintCaseInfo) ? complaintCaseInfo.split(';') : null;
            String concatenateValue = String.join(compliantCaseMap.values(), ';');
            if(compliantCaseList != null){
                Boolean updateStatus=False;
                if(changeOwnershipCase.Status!=Label.XC_CL_Case_Open){
                    changeOwnershipCase.setOptions(dmlOpts);
                    changeOwnershipCase.Status = Label.XC_CL_Case_Open;
                    updateStatus=True;
                }            
                Boolean checkUpdate=False;
                for(String str:compliantCaseList){
                    if(!compliantCaseMap.values().contains(str)){
                        checkUpdate=True;
                    }
                }
                if (compliantCaseMap.size() != compliantCaseList.size()||checkUpdate==True){
                    changeOwnershipCase.Description = changeOwnershipCase.description.replace(complaintCaseInfo, concatenateValue);
                    caseToUpdate.add(changeOwnershipCase);
                } else if(updateStatus){
                    caseToUpdate.add(changeOwnershipCase);
                }
            }else{
                if(!String.isBlank(changeOwnershipCase.Description)){
                    changeOwnershipCase.Description = changeOwnershipCase.description +  '\n' + Label.XC_CL_ComplaintCaseErrorMessage + ':[' + concatenateValue + '].';
                }else{
                    changeOwnershipCase.Description = Label.XC_CL_ComplaintCaseErrorMessage + ':[' + concatenateValue + '].';
                }
                changeOwnershipCase.setOptions(dmlOpts);
                changeOwnershipCase.Status = Label.XC_CL_Case_Open;
                caseToUpdate.add(changeOwnershipCase);
            }

        }else if(changeOwnershipCase.Status!=Label.XC_CL_Case_Open){
            changeOwnershipCase.setOptions(dmlOpts);
            changeOwnershipCase.Status = Label.XC_CL_Case_Open;
            caseToUpdate.add(changeOwnershipCase);
        }
        
        if(!caseToUpdate.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> updateCaseResult = XC_UTIL_Sobject.updateListRecords(new List<Case>(caseToUpdate));
            for(XC_UTIL_Sobject.WrapperResult updateRes: updateCaseResult){
                if(!updateRes.success){
                    utilMap.put('ErrorMessage', updateRes.ErrorMessage);
                    return false;
                }
            }
        }
    
        return true;
    }


    /**
    * @description method that checks if it is possible to bypass the blocks for change of ownership 
    * @param woToMigrate - LSet<Id>
    * @return Map<Id,WorkOrder>
    */
    public static boolean getIsToSkipCOBlock(String legalEntity, String  stream){

        if(String.isBlank(legalEntity) || String.isBlank(stream)) {
            return false;
        }

        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnMap = new Map<Id,XC_CM_LegalEntity_Configuration__mdt> ([SELECT XC_SkipChangeOwnershipBlock__c
                                                                                                                      FROM XC_CM_LegalEntity_Configuration__mdt  
                                                                                                                      WHERE XC_LegalEntity__c =: legalEntity AND XC_OrgId__c =: orgId and XC_Stream__c =: stream]);
        
        if(!(legalEnMap.values()).isEmpty()){
            System.debug(LoggingLevel.FINEST, '[XC_UTIL_ChangeOrder.getIsToSkipCOBlock] LegalEntity: ' + legalEntity + '- Stream: ' + stream);                                                                                                             
            return legalEnMap.values()[0].XC_SkipChangeOwnershipBlock__c;
        }
        
        return false;
    }


}
/**
*@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
*@date Creation 30/01/2019
*@date Modification dd/mm/yyyy
*@description util for  XC_LCC073_DisconnectAsset
*/
public without sharing class XC_LCC073_U_DisconnectAsset {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC073_DisconnectAsset');
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Disconnect asset.
    *@param recordId the Asset Id
    *@param subtype the subtype
    *@param caseId the disconnection Case
    *@return the x C UTI L result wrapper
    */
    //public static XC_UTIL_ResultWrapper disconnectAsset(String recordId, String subtype, String caseId){
    public static XC_UTIL_ResultWrapper disconnectAsset(String recordId, String subtype, Case caso){
        System.debug('entrato in disconnectAsset con id = '+recordId+'e subtype ='+subtype);
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_AssetOperationNotAllowed;        
        if(!Schema.sObjectType.Asset.isAccessible()){
            return wr;  
        }

        List<Asset> a = [
            SELECT Id, NE__Status__c, NE__Order_Config__c, NE__Bundle_Configuration__c,NE__Root_Order_Item__c, NE__Order_Config__r.Name, XC_Product_Type__c, XC_LegalEntity__c
            FROM Asset 
            WHERE id =:recordId limit 1];


        if(!a.isEmpty()){
            if(a[0].NE__Status__c=='Inactive'){
                  wr.resultMessage = Label.XC_CL_ErrorInactiveAsset;
                  return wr;
            }
            if(a[0].XC_Product_Type__c=='Coverage' && (a[0].NE__Bundle_Configuration__c != null || a[0].NE__Root_Order_Item__c != null)){
                  wr.resultMessage = Label.XC_CL_ErrorCoverages;
                  return wr;
            }
            if(a[0].NE__Status__c== Label.XC_CL_Asset_InProgress || a[0].NE__Order_Config__c==null || a[0].NE__Status__c==Label.XC_CL_Asset_Disconnected  ||  a[0].NE__Root_Order_Item__c!=null) {  //a[0].NE__Bundle_Configuration__c!=null
               wr = XC_UTIL_DisconnectAsset.populateError(a[0]);
            }else if(a[0].NE__Bundle_Configuration__c!=null){
                //faccio tutto sul padre
                return disconnectAsset(a[0].NE__Bundle_Configuration__c, subtype, caso);
            }else{
                /** CHECK PREVISTI SOLO PER LE EndesaX - MC 2020/04/24 **/
                if((a[0].XC_LegalEntity__c == 'EndesaX' || a[0].XC_LegalEntity__c == 'EnelXMobilitySpain') && caso.Origin != 'CAN003'){
                    XC_UTIL_ResultWrapper depRW = checkDisconnectDependencies(recordId, subtype, caso.Id);
                    if(!depRW.success){
                        return depRW;
                    }
                }
                /** FINE CHECK **/
                
                Date d = date.today();
                String sMessage = NE.JS_RemoteMethods.verifyAssetPenalties(recordId, d); 
                if(sMessage != ''){ 
                    wr.resultMessage  = sMessage; 
                }
                
                String idorder = NE.JS_RemoteMethods.stdasset2order(recordId , 'Disconnect'); 
                System.debug('order trovato = ' +idorder);  
                wr = XC_UTIL_DisconnectAsset.evaluateIdOrder(idorder,subtype,caso.Id);
            }                    
        }		
        return wr;        
    }
    
    /**
     * @author Monica Cutillo - mcutillo@deoloitte.it
     * @description check abot Disconnect dependencies > NB: Checks only for EndesaX
     * @param assetId the asset id
     * @param subtype the order subtype
     * @param caseId the case Id
     * @return result wrapper
     */
    private static XC_UTIL_ResultWrapper checkDisconnectDependencies(String assetId, String orderSubtype, String caseId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_ComplaintBadSale_CaseSettings});
        if(caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings)==null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on Case_Type_Setting__mdt for '+Label.XC_CL_ComplaintBadSale_CaseSettings);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ checkDisconnectDependencies NOT processed!');
            return wr;
        }

        //Check Complaint Disconnections
        if(orderSubtype == 'Claim not applicable' || orderSubtype == 'Claim applicable (service not used)' || orderSubtype == 'Claim applicable (service used)'){
            //I search the Complaint NOT Bad Sale Case, closed Procedente
            XC_CM_Case_Type_Setting__mdt complaintCaseSett = caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings);
            List<Case> complCaseData = getCaseComplaintNotBadSaleColsedProcedente(assetId, complaintCaseSett);

            if( (orderSubtype == 'Claim applicable (service not used)' || orderSubtype == 'Claim applicable (service used)') && 
                (complCaseData).isEmpty() ){
                wr.resultMessage = Label.XC_CL_DiscMess_ComplaintCaseWithoutNotBadSaleCase;
                return wr;
            }
            if(orderSubtype == 'Claim not applicable' && !(complCaseData).isEmpty()){
                wr.resultMessage = Label.XC_CL_DiscMess_ComplaintCaseWithNotBadSaleCase;
                return wr;
            }
        }else if(orderSubtype == 'Bad referral'){
            //I search the Complaint Bad Sale Case, closed Procedente
            XC_CM_Case_Type_Setting__mdt complaintCaseSett = caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings);
            List<Case> complCaseData = getCaseComplaintBadSaleColsedProcedente(assetId, complaintCaseSett);
            
            if((complCaseData).isEmpty()){
                wr.resultMessage = Label.XC_CL_DiscMess_ComplaintCaseWithoutBadSaleCase;
                return wr;
            }
        }else if(orderSubtype == 'Claim'){
            //I search the Complaint NOT Bad Sale Case, closed Procedente
            XC_CM_Case_Type_Setting__mdt complaintCaseSett = caseSettingsMap.get(Label.XC_CL_ComplaintBadSale_CaseSettings);
            List<Case> complCaseData = getCaseComplaintNotBadSaleColsedProcedente(assetId, complaintCaseSett);

            if((complCaseData).isEmpty()){
                wr.resultMessage = Label.XC_CL_DiscMess_ComplaintCaseWithoutNotBadSaleCase;
                return wr;
            }
        }

        wr.success = true;
        return wr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deoloitte.it
     * @description getCaseComplaintBadSaleColsedProcedente
     * @param assetId the asset id
     * @param complaintCaseSett case setting metadata for Complaint Bad Sale Case
     * @return List<Case> that match
     */
    private static List<Case> getCaseComplaintBadSaleColsedProcedente(Id assetId, XC_CM_Case_Type_Setting__mdt complaintCaseSett){
        Map<Id,Case> complCaseData = new Map<Id,Case>(
            [SELECT Id, AssetId
                FROM Case 
                WHERE AssetId =: assetId
                AND Status =: Label.XC_CL_Case_Status007 
                AND Reason =: complaintCaseSett.XC_Case_Reason__c
                AND SubCause__c =: complaintCaseSett.XC_Sub_Cause__c
                //AND XC_Subtype__c =: complaintCaseSett.XC_Sub_Type__c
                AND XC_Result__c =: Label.XC_CL_Case_Result001 ]);

        if(complaintCaseSett.XC_Sub_Type__c == null){
            return complCaseData.values();
        }

        List<Case> result = new List<Case>();
        for(Case caso : complCaseData.values()){
            if(complaintCaseSett.XC_Sub_Type__c.equals(caso.XC_Subtype__c)){
                result.add(caso);
            }
        }
        return result;
        //return complCaseData.values();
    }

    /**
     * @author Monica Cutillo - mcutillo@deoloitte.it
     * @description getCaseComplaint NOT BadSaleColsedProcedente
     * @param assetId the asset id
     * @param complaintCaseSett case setting metadata for Complaint Bad Sale Case
     * @return List<Case> that match
     */
    private static List<Case> getCaseComplaintNotBadSaleColsedProcedente(Id assetId, XC_CM_Case_Type_Setting__mdt complaintCaseSett){
        Map<Id,Case> complCaseData = new Map<Id,Case>(
            [SELECT Id, AssetId
                FROM Case 
                WHERE AssetId =: assetId
                AND Status =: Label.XC_CL_Case_Status007 
                AND Reason =: complaintCaseSett.XC_Case_Reason__c
                AND SubCause__c !=: complaintCaseSett.XC_Sub_Cause__c
                //AND XC_Subtype__c =: complaintCaseSett.XC_Sub_Type__c
                AND XC_Result__c =: Label.XC_CL_Case_Result001 ]);

        if(complaintCaseSett.XC_Sub_Type__c == null){
            return complCaseData.values();
        }

        List<Case> result = new List<Case>();
        for(Case caso : complCaseData.values()){
            if(complaintCaseSett.XC_Sub_Type__c.equals(caso.XC_Subtype__c)){
                result.add(caso);
            }
        }
        return result;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Change order asset.
    *@param recordId the record id
    *@param subtype the subtype
    *@param caseId the case Id
    *@return the x C UTI L result wrapper
    */
    public static XC_UTIL_ResultWrapper changeOrderAsset(String recordId, String subtype, String caseId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        Map<id,Asset> mapAsset = new Map<id,Asset>([SELECT Id, NE__Status__c, NE__Root_Order_Item__c,NE__Bundle_Configuration__c,NE__Order_Config__c, NE__Order_Config__r.Name FROM Asset where id =:recordId limit 1]);
        List<Asset> a = mapAsset.values();
        if(!a.isEmpty()){
            if( a[0].NE__Status__c==Label.XC_CL_Asset_InProgress || a[0].NE__Order_Config__c==null || 
                a[0].NE__Root_Order_Item__c!=null || a[0].NE__Status__c==Label.XC_CL_Asset_Disconnected) {
                wr = manageError(a[0]);
            }else if(a[0].NE__Bundle_Configuration__c!=null){
                //faccio tutto sul padre
                return changeOrderAsset(a[0].NE__Bundle_Configuration__c, subtype, caseId);
            }else{ 
                String idOrder = NE.JS_RemoteMethods.stdasset2order(recordId , 'Change'); 
                System.debug('Idorder RITORNATO ='+Idorder);
                wr = manageIdOrder(idOrder,subtype,caseId);
            }
            
        }
        return wr;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description Change order asset from case.
    *@param idOrder the record id
    *@param subtype the subtype
    *@return the result wrapper
    */
    public static XC_UTIL_ResultWrapper manageIdOrder(String idOrder,String subtype,String caseId){
                XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper(); 
                
                if(XC_UTIL_DisconnectAsset.isAnOrder(Idorder)){

                    //TODO: add check on order-items
                    /*Map<id,NE__Order__c> mapIdOrder = new Map<id,NE__Order__c>([SELECT id, 
                    XC_Subtype__c FROM NE__Order__c where Id =: Idorder limit 1]);
                    List<NE__Order__c> conf = mapIdOrder.values();*/
                    wr.success = true;
                    wr.recordId = Idorder;
                    NE__Order__c conf = new NE__Order__c(Id = idOrder, NE__Type__c = 'ChangeOrder', XC_Subtype__c = subtype, XC_CaseId__c = caseId);
                    /*if(caseId!=null && caseId!=''){ 
                    conf[0].XC_CaseId__c = caseId;
                    }
                    conf[0].NE__Type__c = 'ChangeOrder';
                    conf[0].XC_Subtype__c = subtype;*/
                    XC_UTIL_Sobject.updateRecord(conf);
                } else {//if (Idorder.contains(Label.XC_CL_AssetErrorAttempt) ){
                    wr.resultMessage = (Idorder!=null && Idorder!='') ? (Label.XC_CL_Order_not_created +': '+Idorder) : (Label.XC_CL_Order_not_created);
                }
                return wr;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description manageError.
    *@param a is an Asset 
    *@return the result wrapper
    */
    private static XC_UTIL_ResultWrapper manageError(Asset a){
    System.debug('ChangeOrder >> Lo stato dell asset e sbagliato');
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        /*if(a.NE__Bundle_Configuration__c!=null ){ 
            return changeOrderAsset(a.NE__Bundle_Configuration__c, subtype,''); 
        }*/
        if(a.NE__Root_Order_Item__c!=null){ 
            wr.resultMessage = Label.XC_CL_NoOnAssetChild;
        } else if(a.NE__Status__c== Label.XC_CL_Asset_Disconnected ){
            wr.resultMessage = Label.XC_CL_NoOnDisconnectedAsset; 
        } else if(a.NE__Status__c== Label.XC_CL_Asset_InProgress){
            wr.resultMessage = Label.XC_CL_AssetAlreadyInProgress+' '+a.NE__Order_Config__r.Name;
        } else if(a.NE__Order_Config__c==null){
            wr.resultMessage = Label.XC_CL_Source_Configuration;
        }
        return wr;
    }

}
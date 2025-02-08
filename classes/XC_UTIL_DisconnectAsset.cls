/**
*@author Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com 
*@date Creation 30/04/2019
*@date Modification dd/mm/yyyy
*@description UTIL for disconnect asset 
*/
public without sharing class XC_UTIL_DisconnectAsset {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC073_DisconnectAsset');
 
    /**
     * @description Wrapper to contain Case input filters
     */
    public class CaseSearchFilter{
        public String reason;
        public String subCause;
        public String subType;
        
        public CaseSearchFilter(String reason, String subCause){
            this.reason = reason;
            this.subCause = subCause;
        }
        
        public CaseSearchFilter(String reason, String subCause, String subType){
            this.reason = reason;
            this.subCause = subCause;
            this.subType = subType;
        }
    }
    
    /**
     * @description Checks if is an order
     * @param a the Asset
     * @return an XC_UTIL_ResultWrapper
     */
    public static XC_UTIL_ResultWrapper populateError(Asset a){
    XC_UTIL_Debug.debug(DEBUGACTIVE, 'DisconnectAsset >> Lo stato dell asset e sbagliato');
    XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
    if(a.NE__Root_Order_Item__c!=null){ //|| a.NE__Bundle_Configuration__c!=null 
        wr.resultMessage = Label.XC_CL_NoOnAssetChild;
    }   else if(a.NE__Status__c== Label.XC_CL_Asset_Disconnected  ){
        wr.resultMessage = Label.XC_CL_NoOnDisconnectedAsset;
    }else if(a.NE__Status__c== Label.XC_CL_Asset_InProgress){
        wr.resultMessage = Label.XC_CL_AssetAlreadyInProgress+' '+a.NE__Order_Config__r.Name;
    }else if(a.NE__Order_Config__c==null){
        wr.resultMessage = Label.XC_CL_Source_Configuration;
    } 
    return wr;
}


 /**
*@description Checks if is an order
*@param idorder 
*@param subtype 
*@return an XC_UTIL_ResultWrapper
*/
public static XC_UTIL_ResultWrapper evaluateIdOrder(String idorder,String subtype,  String caseId){

     XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
     if(isAnOrder(idorder) && Schema.SObjectType.NE__Order__c.isAccessible() && Schema.sObjectType.NE__Order__c.fields.Id.isAccessible() && Schema.sObjectType.NE__Order__c.fields.XC_Subtype__c.isAccessible()){
                    
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_SUBTYPE_RECEIVED::: ' + subtype + ' CASEID: ' + caseId); 
                    
                    List<NE__Order__c> conf = [SELECT id, XC_Subtype__c FROM NE__Order__c WHERE Id =: idorder limit 1];
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Idorder ='+idorder);
                    wr.success = true;
                    wr.recordId = idorder;
                    conf[0].XC_Subtype__c = subtype;
                    if(caseId!=null && caseId!=''){
                        Case currentCase = [SELECT Id,XC_CTICallRecording__c FROM Case WHERE Id = :caseId LIMIT 1];
                        if(String.isNotBlank(currentCase.XC_CTICallRecording__c)){
                            conf[0].XC_CTICallRecording__c = currentCase.XC_CTICallRecording__c;
                        }
                        conf[0].XC_CaseId__c = caseId;
                    }


                    XC_UTIL_Sobject.updateRecord(conf[0]);
                } else { 
                    //if (idorder.contains(Label.XC_CL_AssetErrorAttempt) ){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'non e arrivato nessun orderId da stdasset2order');
                    wr.resultMessage = (idorder!=null && idorder!='') ? (Label.XC_CL_Order_not_created +': '+idorder) : (Label.XC_CL_Order_not_created);
                }
                return wr;
}

 /**
*@description Checks if is an order
*@param recordId the record id
*@return the boolean
*/
    
    public static Boolean isAnOrder(String recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'isAnOrder - recordId '+recordId);
        if(recordId == null || recordId ==''){ return false;}
        try{
            Id id = recordId;
            String sobjectType = id.getSObjectType().getDescribe().getName();
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'isAnOrder sobjectType '+sobjectType);
            return (sobjectType == 'NE__Order__c');
        }
        catch (Exception e){
            return false;
        }
    }

     
    /**
    *@description Gets the asset subtype by case reason.
    *@param caseFilter
    *@param operationType
    *@return the XC_OrderSubtypeByCase__mdt row or null if there isn't match with Case in input 
    */
    public static XC_OrderSubtypeByCase__mdt getAssetSubtypeByCaseReason(CaseSearchFilter caseFilter, String operationType){
        /* CR - End of Renting Flow */
        Set<String> subTypeFilter = new Set<String>{caseFilter.subType};
        subTypeFilter.add(null);
        
        Map<Id,XC_OrderSubtypeByCase__mdt> data = new Map<Id,XC_OrderSubtypeByCase__mdt>([
            SELECT OrderSubtype__c, XC_SkipOrderCreation__c, XC_Subtype__c
            FROM XC_OrderSubtypeByCase__mdt 
            WHERE Reason__c =: caseFilter.reason
            AND SubCause__c =: caseFilter.subCause 
            AND XC_Type__c	=:operationType 
            AND XC_Subtype__c IN: subTypeFilter 
        ]); //limit 1
        if(!data.values().isEmpty()){
            //searching of right row
            Id mtdWithEmptySubtypeId;
            Id mtdWithSameSubtypeId;
            for(XC_OrderSubtypeByCase__mdt mtd : data.values()){
                if(String.isBlank(mtd.XC_Subtype__c)){
                    mtdWithEmptySubtypeId = mtd.Id;
                }else if(mtd.XC_Subtype__c == caseFilter.subType){
                    mtdWithSameSubtypeId = mtd.Id;
                }
            }
            if(mtdWithSameSubtypeId != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Preso dal metadato '+data.get(mtdWithSameSubtypeId).OrderSubtype__c);
                return data.get(mtdWithSameSubtypeId);
            }
            if(mtdWithEmptySubtypeId != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Preso dal metadato '+data.get(mtdWithEmptySubtypeId).OrderSubtype__c);
                return data.get(mtdWithEmptySubtypeId);
            }
            /*XC_UTIL_Debug.debug(DEBUGACTIVE, 'Preso dal metadato '+data.values()[0].OrderSubtype__c);
            return data.values()[0];*/
        }
        return null;
    }

     /**
    *@description Gets the asset subtype by case reason and subtype.
    *@param caseFilter
    *@param operationType
    *@return the XC_OrderSubtypeByCase__mdt row or null if there isn't match with Case in input 
    */
    //public static XC_OrderSubtypeByCase__mdt getAssetSubtypeByCaseReasonAndSubtype(String reason, String subCause,String subType, String operationType){
    public static XC_OrderSubtypeByCase__mdt getAssetSubtypeByCaseReasonAndSubtype(CaseSearchFilter caseFilter, String operationType){
        //String result;
        /*List<XC_OrderSubtypeByCase__mdt> orderSubtypeList = new List<XC_OrderSubtypeByCase__mdt>();
        if(Schema.sObjectType.XC_OrderSubtypeByCase__mdt.fields.OrderSubtype__c.isAccessible() && Schema.SObjectType.XC_OrderSubtypeByCase__mdt.isAccessible()){
            orderSubtypeList = [SELECT OrderSubtype__c FROM XC_OrderSubtypeByCase__mdt WHERE Reason__c =: reason
                                                             AND SubCause__c =: subCause AND XC_Subtype__c=: subType AND
                                                             XC_Type__c	=:operationType limit 1];
        }*/

        /* MC 2019/10/22: In generale sul metadata, data una coppia <Reason,SubCause> 
           avrò una sola riga con Subtype vuoto oppure n con n valori di subtype differenti */
        List<String> subTypeFilter = new List<String>{caseFilter.subType};
        subTypeFilter.add(null);
        Map<Id,XC_OrderSubtypeByCase__mdt> data = new Map<Id,XC_OrderSubtypeByCase__mdt>([
            SELECT OrderSubtype__c, XC_SkipOrderCreation__c
            FROM XC_OrderSubtypeByCase__mdt 
            WHERE Reason__c =: caseFilter.reason
            AND SubCause__c =: caseFilter.subCause 
            AND XC_Subtype__c IN: subTypeFilter 
            AND XC_Type__c	=: operationType limit 1
        ]);
        if(!data.values().isEmpty()){
            system.debug('Preso dal metadato '+data.values()[0].OrderSubtype__c);
            return data.values()[0];
        }
        return null;
    }
    
    /**
     * @description Manage request by client.
     * @param assetId the asset id
     * @return the string
     */
    public static String manageRequestByClient(String assetId){
        //String ret;
        Integer countRepair = 0 ;
        Integer countManteinence = 0;
        /*Map<Id,Asset> assetMap = new Map<Id,Asset>([
            SELECT Id, XC_ContractStartDate__c, XC_Service_Last_Renewal_Date__c, (SELECT id, WorkTypeId, XC_WorkTypeLabel__c FROM WorkOrders) 
            FROM Asset 
            WHERE id =: assetId
        ]);*/
        Map<Id,WorkOrder> assWOData = new Map<Id,WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c, XC_Coverage__r.XC_Product_Name_LIC__c, XC_Coverage__r.NE__Root_Order_Item__c, Status,
                   XC_Coverage__r.XC_ContractStartDate__c, XC_Coverage__r.XC_Service_Last_Renewal_Date__c, Asset.XC_ContractStartDate__c, Asset.XC_Service_Last_Renewal_Date__c
              FROM WorkOrder 
             WHERE Status NOT IN ('Assigned','New')
             AND ( (XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_Repair and XC_Coverage__r.NE__Root_Order_Item__c =: assetId) 
                OR (XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_PlannedMaintenance and AssetId =: assetId) )
        ]);
        //List<Asset> assetList = assetMap.values();
        //if(!assetList.isEmpty() && !(assetList[0].WorkOrders).isEmpty() ){
        List<WorkOrder> woList = assWOData.values();
        if(woList.isEmpty()){
            return Label.XC_CL_Configuration_SubtypeBusinessDecision;   //Label.XC_CL_BusinessDecision
        }
            //Integer timeSinceLastRenew = timeSinceLastRenewalDate(assetList[0]);
            //XC_UTIL_Debug.debug(DEBUGACTIVE, 'manageRequestByClient: timeSinceLastRenew='+timeSinceLastRenew);
            //List<WorkOrder> woList = assetList[0].WorkOrders;
        Integer timeSinceLastRenewalDateForRep;
        Integer timeSinceLastRenewalDateForMant;
        for(WorkOrder wo : woList){
            //if((wo.XC_WorkTypeLabel__c).contains(Label.XC_CL_Repair)){
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){
                timeSinceLastRenewalDateForRep = timeSinceLastRenewalDate(wo.XC_Coverage__r.XC_Service_Last_Renewal_Date__c, wo.XC_Coverage__r.XC_ContractStartDate__c);
                countRepair++;
            //}else if((wo.XC_WorkTypeLabel__c).contains(Label.XC_CL_Maintenance)){
            }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
                timeSinceLastRenewalDateForMant = timeSinceLastRenewalDate(wo.Asset.XC_Service_Last_Renewal_Date__c, wo.Asset.XC_ContractStartDate__c);
                countManteinence++;
            }
        }
        if( ((countRepair>0 || countManteinence>0 ) && (timeSinceLastRenewalDateForRep > 60 || timeSinceLastRenewalDateForMant > 60)) ||
            (countRepair>0 && timeSinceLastRenewalDateForRep <= 60) ){
            return Label.XC_CL_OrdersubTypeValue_ScheduleDeactivation;
        }
        if(countRepair==0 && countManteinence>0 && timeSinceLastRenewalDateForMant <= 60){
            return Label.XC_CL_Configuration_SubtypeEarlyRenewal;   //Label.XC_CL_EarlyRenewal
        }

            /*if(countRepair>0 || (countRepair==0 && timeSinceLastRenew > 60)){
                ret = Label.XC_CL_Schedule_deactivation;
            }else if(countManteinence>0 && countRepair==0 && timeSinceLastRenew <= 60 ){
                ret = Label.XC_CL_Configuration_SubtypeEarlyRenewal; //Label.XC_CL_EarlyRenewal; [MC-20191126]
            }*/
        //}
        return Label.XC_CL_Configuration_SubtypeBusinessDecision;   //Label.XC_CL_BusinessDecision
    }

    /**
     * @description Calculation of time passed since last renewal date
     * @param serviceLastRenewalDate field XC_Service_Last_Renewal_Date__c of the Asset
     * @param contractStartDate field XC_ContractStartDate__c of the Asset
     * @return number of days passed
     */
    //private static Integer timeSinceLastRenewalDate(Asset asset){
    private static Integer timeSinceLastRenewalDate(Date serviceLastRenewalDate, Date contractStartDate){
        if(contractStartDate == null && serviceLastRenewalDate == null){
            return 0;
        }
        Date dateToCheck = contractStartDate;
        if(serviceLastRenewalDate != null){
            dateToCheck = serviceLastRenewalDate;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'timeSinceLastRenewalDate: dateToCheck='+dateToCheck);
        return dateToCheck.daysBetween(Date.today());
    }
    
    /**
     * @description Manage complaint.
     * @param assetId the asset id
     * @return the string
     */
    public static String manageComplaint(String assetId){
        //String ret = Label.XC_CL_ClaimNotApplicable;
        //Integer countRepair = 0 ;
        //Integer countManteinence = 0;
        /*if(!Schema.SObjectType.Asset.isAccessible()) {
            return 'NO ACCESS';
        }*/
        
        List<String> woStatusFilter = new List<String>{Label.XC_CL_WorkOrder_New, Label.XC_CL_WorkOrder_Assigned};
        String caseReasonFilter = Label.XC_CL_CaseReason_ComplaintValue;
        String caseStatusFilter = Label.XC_CL_Case_Status007;
        /*Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT Id, (SELECT id FROM WorkOrders), (SELECT id FROM Cases ) FROM Asset where id =: assetId]);*/
        Map<Id,Asset> assetMap = new Map<Id,Asset>([
            SELECT Id, 
                (SELECT id, Status, Reason, SubCause__c, XC_Result__c, XC_CompliantApplicable__c 
                    FROM Cases 
                WHERE Reason =: caseReasonFilter AND Status =: caseStatusFilter ), 
                (SELECT id, Status FROM WorkOrders WHERE Status NOT IN: woStatusFilter)
            FROM Asset 
            WHERE id =: assetId]);
        
        List<Asset> assetList = assetMap.values();
        List<WorkOrder> woList = assetList[0].WorkOrders;
        List<Case> caseList = assetList[0].Cases;

        if(caseList.isEmpty()) {
            return Label.XC_CL_Configuration_SubtypeClaimNotApplicable; // Label.XC_CL_ClaimNotApplicable;
        }
        Map<String,Boolean> claimApplicableRes = checkClaimApplicable(caseList, woList);
        if(claimApplicableRes.get('claimApplicable')){
            if(claimApplicableRes.get('withReimbursement')){
                return Label.XC_CL_Configuration_SubtypeClaimServiceNotUsed; // Label.XC_CL_ClaimApplicable;
            }else{
                return Label.XC_CL_Configuration_SubtypeClaimServiceUsed; // Label.XC_CL_ClaimApplicable2;
            }
        }
        /*
        if(caseList.isEmpty()) {
            return Label.XC_CL_ClaimNotApplicable;
        } else if(woList.isEmpty()) {
            ret = Label.XC_CL_ClaimApplicable;
        } else if(!woList.isEmpty() && !caseList.isEmpty()){
            ret = Label.XC_CL_ClaimApplicable2;
        }
        */
        return Label.XC_CL_Configuration_SubtypeClaimNotApplicable; // Label.XC_CL_ClaimNotApplicable; // ret;
    }

    /**
     * @description check ClaimApplicable with or without reimbursement,
     * on Manage complaint.
     * @param caseList
     * @param woList
     * @return the map results
     */
    private static Map<String,Boolean> checkClaimApplicable(List<Case> caseList, List<WorkOrder> woList){
        Map<String,Boolean> result = new Map<String,Boolean>();
        Boolean claimApplicable = false;
        for(Case caso :caseList){
            if(caso.XC_Result__c == Label.XC_CL_Case_Result001 && caso.SubCause__c != Label.XC_CL_Case_SubCase_Bad_Sale){ // MC Defect 1705 [20202124]
                //Label.XC_CL_SubCause_BadSaleValue [MC20191216]
                claimApplicable = true;
                break;
            }
        }
        result.put('claimApplicable', claimApplicable);
        result.put('withReimbursement', woList.isEmpty());
        return result;
    }

}
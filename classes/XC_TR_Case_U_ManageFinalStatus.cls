/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 05/11/2019
* @description XC_TR_Case_U_ManageFinalStatus - Class used to manage scenarios in which the case go in a final status:
                                                1) close properly site inspection service appointment
*/ 
public with sharing class XC_TR_Case_U_ManageFinalStatus {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_ManageFinalStatus');
    /**
    * @param listNew the list new
    * @param  the mapmapOld old
    * @param mapNew the map new
    * @description the trigger start when the case go in a final status
    */
    public static void closeServiceAppointment(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTER In XC_TR_Case_U_ManageFinalStatus');
        List<String> fieldList = new List<String>{'Status'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#list of case Changed -> ' + listChanged);
        Map<String, Boolean> woIdMap = new Map<String, Boolean>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- list case status changed ---> ' + listChanged);
        for(Case cs: listChanged){
            if(cs.Status == Label.XC_CL_Case_Status007 && checkCase(cs)){
                woIdMap.put(cs.XC_WorkOrder__c, true);
            } else if(cs.Status == Label.XC_CL_Case_Status008 && checkCase(cs)){
                woIdMap.put(cs.XC_WorkOrder__c, false);
            }
        }
        if(!woIdMap.isEmpty()){
            closeSA(woIdMap);
        }
    }

    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param listNew the list new
     * @param  the mapmapOld old
     * @param mapNew the map new
     * @description extraValidationPhotovoltaicClosure
     */
    public static void photovoltaicRefundClosure(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {
        List<String> fieldList = new List<String>{'Status'};
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsData = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_PhotovoltaicRefund});
        if(caseSettingsData.isEmpty()){
            return;
        }
        List<Case> caseForWOupdate = new List<Case>();
        for(Case caso: listChanged){
            if(caso.Status == Label.XC_CL_Case_Status007 && checkPhotovoltaicCase(caso, caseSettingsData.get(Label.XC_CL_PhotovoltaicRefund))){
                caseForWOupdate.add(caso);
            }
        }
        if(!caseForWOupdate.isEmpty()){
            validateOkIstallationWOs(caseForWOupdate);
        }
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param caso Case to check
     * @param mtd
     * @return check result
     * @description validateOkIstallationWOs
     */
    private static void validateOkIstallationWOs(List<Case> photovoltaicCases){
        Set<Id> assetIds = XC_UTIL_Sobject.getSetIdsOnField(photovoltaicCases, 'AssetId');
        if(assetIds.isEmpty()){
            return;
        }
        
        Map<Id,WorkOrder> istallWO = new Map<Id,WorkOrder> ([
            SELECT Id, ParentWorkOrderId FROM WorkOrder WHERE AssetId IN: assetIds AND XC_WorkTypeCategory__c = 'Delivery & Installation'
        ]);
        if(istallWO.isEmpty()){
            return;
        }

        List<WorkOrder> woToValidate = new List<WorkOrder>();
        WorkOrder validatedWO;
        for(WorkOrder wo : istallWO.values()){
            validatedWO = new WorkOrder();
            validatedWO.Id = (wo.ParentWorkOrderId != null) ? wo.ParentWorkOrderId : wo.Id;
            validatedWO.XC_ValidationStatus__c = 'OK';
            woToValidate.add(validatedWO);
        }
        List<XC_UTIL_Sobject.WrapperResult> woUpdResult = XC_UTIL_DML.updateRecords(woToValidate);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @param caso Case to check
     * @param mtd
     * @return check result
     * @description checkPhotovoltaicCase
     */
    private static Boolean checkPhotovoltaicCase(Case caso, XC_CM_Case_Type_Setting__mdt mtd){
        return (XC_UTIL_Case.matchSettings(caso, mtd) && caso.AssetId != null && caso.XC_Result__c == 'RS015');  // 'RS015' -> Validation OK
    }

   /**
     * @param cs Case to check
     * @return check result
     * @description checkCase
     */
    private static Boolean checkCase(Case cs){
        return cs.XC_WorkOrder__c  != null && cs.Reason == Label.XC_CL_CaseReason_XCMOT007 && cs.SubCause__c == Label.XC_CL_SubCause_ATCL024;
    } 
    
    private static void closeSA(Map<String, Boolean> woIdMap){
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>([SELECT Id, Status, ParentRecordId
                                                                            FROM ServiceAppointment 
                                                                            WHERE ParentRecordId =: woIdMap.keySet()
                                                                            AND Status =: Label.XC_CL_ServiceAppointment_OnHold
                                                                            AND XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_SiteInspection]);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- list Service Appointment ---> ' + serviceAppointmentList);
        for(ServiceAppointment sa : serviceAppointmentList){
            if(woIdMap.containsKey(sa.ParentRecordId)){
                if(woIdMap.get(sa.ParentRecordId)){
                    sa.Status = Label.XC_CL_ServiceAppointment_Completed;
                } else {
                    sa.Status = Label.XC_CL_ServiceAppointment_Canceled;
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(serviceAppointmentList);
    }
}
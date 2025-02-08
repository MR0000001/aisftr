/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 01-02-2022
 * @last modified date  : 01-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Utility Class for XC_TR_WorkOrderLineItem_Handler to check if WOLI is editable
 * @test class          : XC_TR_WOLI_CheckEditableRecord_TEST
**/

public with sharing class XC_TR_WOLI_CheckEditableRecord {

    public final static String PE_TYPE = 'Partner Engagement';
    public final static String GI_TYPE = 'Good Issue';
    public final static String PP_TYPE = 'Partner Payment';
    public final static String MS_TYPE = 'Material Supply';

    public final static String COMPLETED_STATUS = 'Completed';
    public final static String CANCELED_STATUS  = 'Canceled';
    public final static String APPROVED_STATUS  = 'Approved';
    public final static String RELEASED_STATUS  = 'Released';
    public final static String SAC_STATUS       = 'Service Acquisition Created';
    public final static String SFR_STATUS       = 'Sent for release';

    public final static String ENELSOLE_PE_RT    = 'XC_B2G_EnelSole_PE_WOLI';
    public final static String ENELXITALIA_PE_RT = 'XC_B2G_EnelXItalia_PE_WOLI';
    public final static String ENELSOLE_GI_RT    = 'XC_B2G_EnelSole_Good_Issue';
    public final static String ENELXITALIA_GI_RT = 'XC_B2G_EnelXItalia_Good_Issue';
    public final static String ENELSOLE_PP_RT    = 'XC_B2GEnelSolePartnerPayment';
    public final static String ENELXITALIA_PP_RT = 'XC_B2GEnelXItaliaPartnerPayment';
    public final static String ENELSOLE_MS_RT    = 'XC_B2G_EnelSole_MR_WOLI';
    public final static String ENELXITALIA_MS_RT = 'XC_B2G_EnelXItalia_MR_WOLI';

    public final static List<String> PE_RT_LIST = new List<String>{
        ENELSOLE_PE_RT, ENELXITALIA_PE_RT
    };

    public final static List<String> GI_RT_LIST = new List<String>{
        ENELSOLE_GI_RT, ENELXITALIA_GI_RT
    };

    public final static List<String> PP_RT_LIST = new List<String>{
        ENELSOLE_PP_RT, ENELXITALIA_PP_RT
    };

    public final static List<String> MS_RT_LIST = new List<String>{
        ENELSOLE_MS_RT, ENELXITALIA_MS_RT
    };

    public final static List<String> PE_MS_STATUS_LIST = new List<String>{
        COMPLETED_STATUS, CANCELED_STATUS
    };

    public final static List<String> PP_STATUS_LIST = new List<String>{
        APPROVED_STATUS, RELEASED_STATUS, CANCELED_STATUS, SAC_STATUS, SFR_STATUS
    };

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method checks if the record can be updated.
     * @param mapNew The new map of WorkOrderLineItem
     * @param mapOld The old map of WorkOrderLineItem
    */
    public static void checkBeforeUpdateRecords(Map<Id, WorkOrderLineItem> mapNew, Map<Id, WorkOrderLineItem> mapOld){
        Set<Id> woliNotEditable = new Set<Id>();

        List<String> fieldList = new List<String>{'XC_OwnerWorkOrder__c'};
        List<WorkOrderLineItem> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        for(WorkOrderLineItem woli : mapOld.values()){            
            if(!listChanged.isEmpty()){
                for(WorkOrderLineItem woliEditable : listChanged){
                    if(woli.Id==woliEditable.Id){
                        break;
                    }
                }
                continue;
            }

            String rtWOLI = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosById().get(woli.RecordTypeId).getDeveloperName();
            
            if((PE_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && PE_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woli.Status)) ||
               (GI_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && GI_RT_LIST.contains(rtWOLI) && COMPLETED_STATUS.equalsIgnoreCase(woli.Status)) ||
               (PP_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && PP_RT_LIST.contains(rtWOLI) && PP_STATUS_LIST.contains(woli.Status)) ||
               (MS_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && MS_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woli.Status))){
                woliNotEditable.add(woli.Id);
                continue;
            }
        }

        if(!woliNotEditable.isEmpty()){
            for(WorkOrderLineItem woli : mapNew.values()){
                if(woliNotEditable.contains(woli.Id)){
                    woli.addError(Label.XC_CL_WOLI_ErrorUpdate);
                    continue;
                }
            }
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method checks if the record can be deleted.
     * @param mapOld The old map of WorkOrderLineItem
    */
    public static void checkBeforeDeleteRecords(Map<Id, WorkOrderLineItem> mapOld){

        for(WorkOrderLineItem woli : mapOld.values()){            
            
            String rtWOLI = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosById().get(woli.RecordTypeId).getDeveloperName();
            if((PE_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && PE_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woli.Status)) ||
               (GI_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && GI_RT_LIST.contains(rtWOLI) && COMPLETED_STATUS.equalsIgnoreCase(woli.Status)) ||
               (PP_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && PP_RT_LIST.contains(rtWOLI) && PP_STATUS_LIST.contains(woli.Status)) ||
               (MS_TYPE.equalsIgnoreCase(woli.XC_WOLIType__c) && MS_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woli.Status))){
                woli.addError(Label.XC_CL_WOLI_ErrorUpdate);
                continue;
            }
        }
    }
}
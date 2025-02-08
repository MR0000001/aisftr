/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 02-02-2022
 * @last modified date  : 02-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Utility Class for XC_TR_RequiredPosition_Handler to check if XC_RequiredPosition__c is editable
 * @test class          : XC_TR_ReqPos_CheckEditable_TEST
**/

public class XC_TR_RequiredPosition_CheckEditable {
    
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
     * @param mapNew The new map of XC_RequiredPosition__c
     * @param mapOld The old map of XC_RequiredPosition__c
    */
    public static void checkBeforeUpdateRecords(Map<Id, XC_RequiredPosition__c> mapNew, Map<Id, XC_RequiredPosition__c> mapOld){
        Set<Id> rpNotEditable = new Set<Id>();
        Set<Id> woliIds = new Set<Id>();

        for(XC_RequiredPosition__c rp : mapOld.values()){
            woliIds.add(rp.XC_WorkOrderLineItem__c);
        }

        Map<Id, WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem>([SELECT Id, RecordTypeId, XC_WOLIType__c, Status FROM WorkOrderLineItem WHERE Id IN : woliIds]);

        if(!woliMap.isEmpty()){
            for(XC_RequiredPosition__c rp : mapOld.values()){

                Id rtIdWOLI = woliMap.get(rp.XC_WorkOrderLineItem__c) != null ? woliMap.get(rp.XC_WorkOrderLineItem__c).RecordTypeId : null;
                String woliType = woliMap.get(rp.XC_WorkOrderLineItem__c) != null ? woliMap.get(rp.XC_WorkOrderLineItem__c).XC_WOLIType__c : null;
                String woliStatus = woliMap.get(rp.XC_WorkOrderLineItem__c) != null ? woliMap.get(rp.XC_WorkOrderLineItem__c).Status : null;
                String rtWOLI = String.isNotBlank(rtIdWOLI) ? Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosById().get(rtIdWOLI).getDeveloperName() : null;

                if((PE_TYPE.equalsIgnoreCase(woliType) && PE_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus)) ||
                   (GI_TYPE.equalsIgnoreCase(woliType) && GI_RT_LIST.contains(rtWOLI) && COMPLETED_STATUS.equalsIgnoreCase(woliStatus)) ||
                   (PP_TYPE.equalsIgnoreCase(woliType) && PP_RT_LIST.contains(rtWOLI) && PP_STATUS_LIST.contains(woliStatus)) ||
                   (MS_TYPE.equalsIgnoreCase(woliType) && MS_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus))){
                    rpNotEditable.add(rp.Id);
                    continue;
                }
            }

            if(!rpNotEditable.isEmpty()){
                for(XC_RequiredPosition__c rp : mapNew.values()){
                    if(rpNotEditable.contains(rp.Id)){
                        rp.addError(Label.XC_CL_RequiredPosition_ErrorUpdate);
                        continue;
                    }
                }
            }
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method checks if the record can be deleted.
     * @param mapOld The old map of XC_RequiredPosition__c
    */
    public static void checkBeforeDeleteRecords(Map<Id, XC_RequiredPosition__c> mapOld){
        Set<Id> woliIds = new Set<Id>();

        for(XC_RequiredPosition__c rp : mapOld.values()){
            woliIds.add(rp.XC_WorkOrderLineItem__c);
        }

        Map<Id, WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem>([SELECT Id, RecordTypeId, XC_WOLIType__c, Status FROM WorkOrderLineItem WHERE Id IN : woliIds]);

        if(!woliMap.isEmpty()){
            for(XC_RequiredPosition__c rp : mapOld.values()){            
                
                Id rtIdWOLI = woliMap.get(rp.XC_WorkOrderLineItem__c) != null ? woliMap.get(rp.XC_WorkOrderLineItem__c).RecordTypeId : null;
                String woliType = woliMap.get(rp.XC_WorkOrderLineItem__c) != null ? woliMap.get(rp.XC_WorkOrderLineItem__c).XC_WOLIType__c : null;
                String woliStatus = woliMap.get(rp.XC_WorkOrderLineItem__c) != null ? woliMap.get(rp.XC_WorkOrderLineItem__c).Status : null;
                String rtWOLI = String.isNotBlank(rtIdWOLI) ? Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosById().get(rtIdWOLI).getDeveloperName() : null;

                if((PE_TYPE.equalsIgnoreCase(woliType) && PE_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus)) ||
                    (GI_TYPE.equalsIgnoreCase(woliType) && GI_RT_LIST.contains(rtWOLI) && COMPLETED_STATUS.equalsIgnoreCase(woliStatus)) ||
                    (PP_TYPE.equalsIgnoreCase(woliType) && PP_RT_LIST.contains(rtWOLI) && PP_STATUS_LIST.contains(woliStatus)) ||
                    (MS_TYPE.equalsIgnoreCase(woliType) && MS_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus))){
                    rp.addError(Label.XC_CL_RequiredPosition_ErrorUpdate);
                    continue;
                }
            }
        }
    }
}
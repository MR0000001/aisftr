/**
 * @author              : Denise Avolio - denise.avolio@accenture.com
 * @group               : ACN Team
 * @created date        : 02-02-2022
 * @last modified date  : 02-02-2022
 * @last modified by    : Denise Avolio - denise.avolio@accenture.com
 * @description         : Utility Class for XC_TR_ProductRequired_Handler to check if ProductRequired is editable
 * @test class          : XC_TR_ProductRequired_CheckEditable_TEST
**/

public with sharing class XC_TR_ProductRequired_CheckEditable {

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
     * @param mapNew The new map of ProductRequired
     * @param mapOld The old map of ProductRequired
    */
    public static void checkBeforeUpdateRecords(Map<Id, ProductRequired> mapNew, Map<Id, ProductRequired> mapOld){
        Set<Id> prNotEditable = new Set<Id>();
        Set<Id> woliIds = new Set<Id>();

        for(ProductRequired pr : mapOld.values()){
            woliIds.add(pr.XC_WorkOrderLineItem__c);
        }

        Map<Id, WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem>([SELECT Id, RecordTypeId, XC_WOLIType__c, Status FROM WorkOrderLineItem WHERE Id IN : woliIds]);

        if(!woliMap.isEmpty()){
            for(ProductRequired pr : mapOld.values()){

                Id rtIdWOLI = woliMap.get(pr.XC_WorkOrderLineItem__c) != null ? woliMap.get(pr.XC_WorkOrderLineItem__c).RecordTypeId : null;
                String woliType = woliMap.get(pr.XC_WorkOrderLineItem__c) != null ? woliMap.get(pr.XC_WorkOrderLineItem__c).XC_WOLIType__c : null;
                String woliStatus = woliMap.get(pr.XC_WorkOrderLineItem__c) != null ? woliMap.get(pr.XC_WorkOrderLineItem__c).Status : null;
                String rtWOLI = String.isNotBlank(rtIdWOLI) ? Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosById().get(rtIdWOLI).getDeveloperName() : null;

                if((PE_TYPE.equalsIgnoreCase(woliType) && PE_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus)) ||
                   (GI_TYPE.equalsIgnoreCase(woliType) && GI_RT_LIST.contains(rtWOLI) && COMPLETED_STATUS.equalsIgnoreCase(woliStatus)) ||
                   (PP_TYPE.equalsIgnoreCase(woliType) && PP_RT_LIST.contains(rtWOLI) && PP_STATUS_LIST.contains(woliStatus)) ||
                   (MS_TYPE.equalsIgnoreCase(woliType) && MS_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus))){
                    prNotEditable.add(pr.Id);
                    continue;
                }
            }

            if(!prNotEditable.isEmpty()){
                for(ProductRequired pr : mapNew.values()){
                    if(prNotEditable.contains(pr.Id)){
                        pr.addError(Label.XC_CL_ProductRequired_ErrorUpdate);
                        continue;
                    }
                }
            }
        }
    }

    /**
     * @author Denise Avolio - denise.avolio@accenture.com
     * @description This method checks if the record can be deleted.
     * @param mapOld The old map of ProductRequired
    */
    public static void checkBeforeDeleteRecords(Map<Id, ProductRequired> mapOld){
        Set<Id> woliIds = new Set<Id>();

        for(ProductRequired pr : mapOld.values()){
            woliIds.add(pr.XC_WorkOrderLineItem__c);
        }

        Map<Id, WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem>([SELECT Id, RecordTypeId, XC_WOLIType__c, Status FROM WorkOrderLineItem WHERE Id IN : woliIds]);

        if(!woliMap.isEmpty()){
            for(ProductRequired pr : mapOld.values()){            
                
                Id rtIdWOLI = woliMap.get(pr.XC_WorkOrderLineItem__c) != null ? woliMap.get(pr.XC_WorkOrderLineItem__c).RecordTypeId : null;
                String woliType = woliMap.get(pr.XC_WorkOrderLineItem__c) != null ? woliMap.get(pr.XC_WorkOrderLineItem__c).XC_WOLIType__c : null;
                String woliStatus = woliMap.get(pr.XC_WorkOrderLineItem__c) != null ? woliMap.get(pr.XC_WorkOrderLineItem__c).Status : null;
                String rtWOLI = String.isNotBlank(rtIdWOLI) ? Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosById().get(rtIdWOLI).getDeveloperName() : null;

                if((PE_TYPE.equalsIgnoreCase(woliType) && PE_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus)) ||
                    (GI_TYPE.equalsIgnoreCase(woliType) && GI_RT_LIST.contains(rtWOLI) && COMPLETED_STATUS.equalsIgnoreCase(woliStatus)) ||
                    (PP_TYPE.equalsIgnoreCase(woliType) && PP_RT_LIST.contains(rtWOLI) && PP_STATUS_LIST.contains(woliStatus)) ||
                    (MS_TYPE.equalsIgnoreCase(woliType) && MS_RT_LIST.contains(rtWOLI) && PE_MS_STATUS_LIST.contains(woliStatus))){
                    pr.addError(Label.XC_CL_ProductRequired_ErrorUpdate);
                    continue;
                }
            }
        }
    }
}
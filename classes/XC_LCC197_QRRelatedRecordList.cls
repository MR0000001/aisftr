/**
 * @description       : controller for LCP197 to show related records of a queued request flow
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 07-09-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   07-09-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_LCC197_QRRelatedRecordList {

    public class RelatedRecordWrapper{
        @AuraEnabled
        public String recordId {get;set;}
        @AuraEnabled
        public String sObjectType {get;set;}
        @AuraEnabled
        public String sObjectLabel {get;set;}
        @AuraEnabled
        public String stepId {get;set;}
        @AuraEnabled
        public Boolean isCustom {get;set;}
    }

    public class RelatedRecordListWrapper{
        @AuraEnabled
        public List<RelatedRecordWrapper> records {get;set;}
        @AuraEnabled
        public Boolean showComponent = false;
    }

    
    /**
    * @description return a list of wrapper to show related records created by a queued request flow
    * @author Francesco Imperioli - fimperioli@deloitte.it | 07-09-2020 
    * @param recordId 
    * @return RelatedRecordListWrapper 
    **/
    @AuraEnabled
    public static RelatedRecordListWrapper getQRRelatedRecords(String recordId){
        RelatedRecordListWrapper rrlw = new RelatedRecordListWrapper();

        List<XC_QueuedRequest__c> currentQrWithSteps = [SELECT Id,XC_Status__c ,
        (SELECT Id,XC_Status__c,XC_RelatedRecordsIds__c FROM QueuedRequestSteps__r WHERE XC_RelatedRecordsIds__c!= NULL AND XC_Status__c = 'Completed OK')
        FROM XC_QueuedRequest__c WHERE Id = :recordId LIMIT 1];

        rrlw.showComponent = !currentQrWithSteps[0].QueuedRequestSteps__r.isEmpty();
        rrlw.records = new List<RelatedRecordWrapper>();
        if(rrlw.showComponent){
            for(XC_QueuedRequestStep__c step : currentQrWithSteps[0].QueuedRequestSteps__r){
                for(String recId : step.XC_RelatedRecordsIds__c.split(';')){

                    RelatedRecordWrapper rrw = new RelatedRecordWrapper();
                    rrw.recordId = recId;
                    rrw.sObjectType = XC_UTIL_Sobject.getObjectType(recId);
                    rrw.sObjectLabel = Schema.describeSObjects(new List<String>{rrw.sObjectType})[0].getLabel();
                    rrw.stepId = step.Id;
                    rrw.isCustom = Schema.describeSObjects(new List<String>{rrw.sObjectType})[0].isCustom();
                    rrlw.records.add(rrw);
                }
            }
        }
        return rrlw;
    }


}
/**
 * @description The Class XC_LCC063_RejectQuote.
 */
public without sharing class XC_LCC063_RejectQuote {
    
    /**
     * @description The Class PicklistValues.
     */
    public class PicklistValues{

        /** @description fieldLabel */
        @AuraEnabled
        public String fieldLabel {get; set;} 
        /** @description fieldValue */
        @AuraEnabled 
        public String fieldValue {get; set;} 
    }
  
    /**
     * @description Retrive category values.
     *
     * @return the list
     */
    @AuraEnabled
    public static List<PicklistValues> retriveCategoryValues() {
        List<PicklistValues> lstPickvals = new List<PicklistValues>();
        List<Schema.PicklistEntry> pickListValues = XC_UTIL_SObject.retrieveAllPicklistValues('NE__Order__c' ,  'XC_LossReason__c');
        for (Schema.PicklistEntry f : pickListValues) { 
            PicklistValues pv = new PicklistValues();
            pv.fieldLabel = f.getLabel();
            pv.fieldValue = f.getValue();
            lstPickvals.add(pv);    
        }
        return lstPickvals;
    }

    /**
     * @description Reject quote.
     *
     * @param recordId the record id
     * @param lossReason the loss reason
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper rejectQuote(String recordId, String lossReason){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_Quote_OperationNotAllowedWithThisStatus;  
        //Operation permitted only if previous status is Draft or notify to client
        //
        //
        Map<Id,NE__Order__c> configurationsMap =  new Map<Id,NE__Order__c>([SELECT Id, XC_Status__c, RecordTypeId FROM NE__Order__c WHERE id=: recordId]);
        List<NE__Order__c> configurations = configurationsMap.values();


        if(!configurations.isEmpty()){
            
            String recordTypeQuote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
            if(recordTypeQuote==configurations[0].RecordTypeId && (configurations[0].XC_Status__c == Label.XC_CL_Configuration_QuoteDraft || 
                                                                   configurations[0].XC_Status__c == Label.XC_CL_Configuratione_QuoteNotifiedToClient)){
            System.debug('Entrato in update Quote');
                                                                       
                                                              
            configurations[0].XC_Status__c = Label.XC_CL_Configuration_QuoteRejected;
            configurations[0].XC_LossReason__c = lossReason;                       
            XC_UTIL_Sobject.updateListRecords(configurations);
            wr.success = true; 
            wr.resultMessage =  Label.XC_CL_CPAB_Success;
                                                       
             }
        }
       
        
        return wr;
    }

}
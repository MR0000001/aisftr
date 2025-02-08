/**
 * The Class XC_LCC002_NewLead_W
 *
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 14/05/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC002_NewLead_W – Wrapper class of XC_LCC002_NewLead
 */
public without sharing class XC_LCC002_NewLead_W {
    
    /** @description RollBack Wrapper Class*/
    public class RollBackWrapper {
        public Boolean isRollBack = false;
        public InsertResultWrapper resultWrapper;
    }

    /** @description The Class InsertResultWrapper */
    public class InsertResultWrapper{ 
        /** @description The record id */
        @AuraEnabled
        public Id recordId {get; set;} 
        /** @description The success. */
        @AuraEnabled
        public Boolean success {get; set;} 
        /** @description The error message. */
        @AuraEnabled
        public String errorMessage {get; set;} 
        /** @description The field name. */
        @AuraEnabled
        public String fieldName {get; set;} 
        /** @description The converted account id. */
        @AuraEnabled
        public String convertedAccountId {get; set;} 
        @AuraEnabled
        public Lead leadToUpdate;
        @AuraEnabled
        public Boolean leadUpdated;
        @AuraEnabled
        public String key;        
        public XC_PersonalDocument__c peronalDocumentToInsert;
        public Lead leadToAddError;
        /**
         * @description InsertResultWrapper constructor for success
         * @param  recordId                 
         */
        public InsertResultWrapper(Id recordId){
            this.recordId = recordId;
            this.success = true;
            this.errorMessage = '';
            this.fieldName = '';
            this.convertedAccountId = null;
        }

        /**
         * @description InsertResultWrapper constructor for error
         * @param  errorMessage 
         * @param  fieldName                 
         */
        public InsertResultWrapper(String errorMessage, String fieldName){
            this.recordId = null;
            this.success = false;
            this.errorMessage = errorMessage;
            this.fieldName = fieldName;
            this.convertedAccountId = null;
        }
    }  
    
    /** @description Wrapper with all input for the Lead creation **/
    public class LeadInputDataWrapper{
        public String recordTypeId;
        public Boolean assignLead;
        public Boolean thirdPartiesCheck;
        public Boolean robinsonCustomer;
        public String thirdPartiesCheckNew;
        public String thirdPartiesVersion;
        public String consentsLE;
        public String consentsWrapper; //dpalamides
    }
}
/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 08/05/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC003_NewAccount_W – Class Wrapper of XC_LCC003_NewAccount
*/
 public class XC_LCC003_NewAccount_W {

    /** @description The Class InsertResultWrapper */
    public class InsertResultWrapper{
        /** @description The record id. */
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
        
        /** @description The existing acc id. */
        @AuraEnabled
        public String existingAccId {get; set;}

        /*public InsertResultWrapper(){
            XC_UTIL_Debug.debug(false, '');
        }*/
        
        /**
         * @description InsertResultWrapper constructor for success
         * @param  recordId                 
         */
        public InsertResultWrapper(Id recordId){
            this.recordId = recordId;
            this.success = true;
            this.errorMessage = '';
            this.fieldName = '';
            this.existingAccId = null;
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
            this.existingAccId = null;
        }
    } 
    
    /**
     * @description Wrapper with all input for the Account creation
     **/
    public class AccountInputDataWrapper{
        public String contactFields;
        public String addressFields;
        public Boolean addressNoValidate;
        public Boolean thirdPartiesCheck;
        public Boolean robinsonCustomer;
        public Boolean successConsent = true;
        public String thirdPartiesCheckNew;
        public String thirdPartiesVersion;
        public String consentsLE;
        public String consentsWrapper; //dpalamides

        public XC_TR_Account_U_CheckDuplicates.ResultWrapper accountCheckDuplicateRes;
    }
}
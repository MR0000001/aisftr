/**
 * @author Andrea Di Cicco
 * @description controller of the component of the 360 view
 * @date Creation 30/10/2019
 * @date Modification 13/02/2020 Monica Cutillo
 */
public without sharing  class XC_LCC005_360View {


        private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC005_360View');

    /** @description The Class ContinuationCommodityResult */
    public class ContinuationCommodityResult{

        /** @description success */
        @AuraEnabled
        public Boolean success {get; set;}

        /** @description message */
        @AuraEnabled
        public String message {get; set;}

        /** @description sobjectTypeName */
        @AuraEnabled
        public String sobjectTypeName {get; set;}

        /** @description sobjectId */
        @AuraEnabled
        public String sobjectId {get; set;}

        /** @description sobjectId */
        @AuraEnabled
        public String identityNumber {get; set;}
        
        /** @description commodityAccountResult */
        @AuraEnabled
        public Object commodityAccountResult {get; set;}

        /** @description commodityContractResult */
        @AuraEnabled
        public Object commodityContractResult {get; set;}

        /** @description commodityCaseResult */
        @AuraEnabled
        public Object commodityCaseResult {get; set;}

        /** @description commodityInvoiceResult */
        @AuraEnabled
        public Object commodityInvoiceResult {get; set;}

        /** @description serverSystem */
        @AuraEnabled
        public String serverSystem {get; set;}

    }

    /*  */
    private class ObjectInfo{
        public String recordType;
        public String documentNumber;
        public String documentType;
    }
    /**
     * @author Andrea Di Cicco
     * @description collect all the info from the commodity
     * @param recordId
     * @return the wrapper with all the info
     */
     @AuraEnabled
    public static String callToCommodity(String recordId){
        ContinuationCommodityResult res = new ContinuationCommodityResult();
        ObjectInfo objInfo = retrieveObjectInfo( recordId); 
        if(String.isBlank(objInfo.documentNumber)){
            return'{}';
        }
        if(objInfo.documentType == 'RUT'){
            objInfo.documentType = '1';
        }
        objInfo.documentNumber = XC_LCC005_AccountDataAccordion.adaptDocumentNumber(objInfo.documentType, objInfo.documentNumber);
        XC_REST_ReadAccont.WrapperResult callResult = XC_REST_ReadAccont.callToReadAccount(recordId, new Map<String, String> 
            { 'IdentityNumber' => objInfo.documentNumber,
              'IdentityType'   => objInfo.documentType }, true);
        System.debug(' objInfo.documentNumber ' + objInfo.documentNumber);
        List<XC_UTIL_Account.AccountIFWrapper> filteredAccountCommodity = new List<XC_UTIL_Account.AccountIFWrapper>();

        res.sobjectTypeName = ((Id)recordId).getSObjectType().getDescribe().getName();
        if(callResult!= null && callResult.readAccountResponse != null && callResult.readAccountResponse.Account != null){
            for(XC_UTIL_Account.AccountIFWrapper commodityAccount : callResult.readAccountResponse.Account ){
                if(XC_UTIL_CommodityAccountRelated.checkCommodityAccountRecordType(((Id)recordId).getSObjectType().getDescribe().getName(), objInfo.recordType, commodityAccount.AccountType) || commodityAccount.AccountType == null || commodityAccount.AccountType == ''){
                    filteredAccountCommodity.add(commodityAccount);
                }else if(XC_UTIL_CommodityAccountRelated.checkExcentionCommodityMapping(((Id)recordId).getSObjectType().getDescribe().getName(), objInfo.recordType, commodityAccount)){
                    filteredAccountCommodity.add(commodityAccount);
                }
            }
            
        }else{
            res.success = false;
            return JSON.serialize(res);
        }
        res.success = true;
        res.serverSystem = callResult.serverSystem;
        res.commodityAccountResult = filteredAccountCommodity;
        System.debug(res.commodityAccountResult);
        return JSON.serialize(res);
    }

    /**
     * @author Andrea Di Cicco
     * @description retrieveObjectInfo
     * @param recordId
     * @return the ObjectInfo wrapper
     */
    private static ObjectInfo retrieveObjectInfo(String recordId){
        ObjectInfo objInfo = new ObjectInfo();
        String sobjectType =  ((Id)recordId).getSObjectType().getDescribe().getName();
        if(sobjectType == 'Account' && Schema.sObjectType.Account.isAccessible()){
            Account account = [SELECT RecordType.DeveloperName, IdentityNumber__c, IdentityType__c 
                                FROM Account
                                WHERE Id = : recordId  LIMIT 1];
            objInfo.recordType= account.RecordType.DeveloperName;
            objInfo.documentNumber = account.IdentityNumber__c; 
            objInfo.documentType = account.IdentityType__c; 
        }else if(Schema.sObjectType.Lead.isAccessible()){
            Lead lead =  [SELECT RecordType.DeveloperName, XC_DocumentNumber__c, XC_DocumentType__c 
                                FROM Lead
                                WHERE Id = : recordId  LIMIT 1];
            objInfo.recordType= lead.RecordType.DeveloperName;
            objInfo.documentNumber = lead.XC_DocumentNumber__c;
            objInfo.documentType = lead.XC_DocumentType__c; 
        }
        return objInfo;
    }
      
    /**
     * @author Andrea Di Cicco
     * @description collect all the info from the commodity
     * @param recordId
     * @param selectedAccount
     * @return the wrapper with all the info
     */
     @AuraEnabled
      public static XC_LCC005_AccountDataAccordion.ContinuationCommodityResult callToCommoditySecondPart(String recordId, String selectedAccount){
          return XC_LCC005_AccountDataAccordion.callToCommodity( recordId, selectedAccount);
      } 


      /**
       * @author Andrea Di Cicco
       * @description this method is used to check if consent flag is true o false 
       * @param recordId
       * @return true if the consents flag is false
       */
       @AuraEnabled
       public static Boolean areConsentsGiven(String recordId){ 
           boolean flagConsents = false;
           if(Schema.sObjectType.Account.isAccessible()){
               Account accountInfo = [SELECT XC_ConfirmationByCustomer__c FROM  Account WHERE ID= : recordId LIMIT 1];
               flagConsents = !accountInfo.XC_ConfirmationByCustomer__c;
           }
           return flagConsents;
       }
}
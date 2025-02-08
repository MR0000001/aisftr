/**
 * @author Monica Cutillo - monicaa.cutillo@nttdata.com
 * @date Creation 16/01/2019
 * @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_LCC053_RedirectOpportunity – Controller for XC_LCP053_RedirectOpportunity
 */

public without sharing class XC_LCC053_RedirectOpportunity {

    /** @description RedirectWrapper */ 
    public class RedirectWrapper {
        @AuraEnabled
        public String channelUser = '';
        @AuraEnabled
        public Boolean canCreateOpp = false;
        @AuraEnabled
        public String contactId = '';
        @AuraEnabled
        public String accountId = '';
        @AuraEnabled
        public String workOrderId = '';
        @AuraEnabled
        public String stageName = '';
        @AuraEnabled
        public Date closeDate;
        @AuraEnabled
        public String addressId = '';
        @AuraEnabled
        public String productCategory = '';
        @AuraEnabled
        public String typeObject = '';
        @AuraEnabled
        public Boolean documentExists = true;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 25/10/2019
     * @description Method used to retrieve info for redirect
     * @param userId - String
     * @param idSobject - Id
     * @return RedirectWrapper
     */
    @AuraEnabled
    public static RedirectWrapper retrieveInfoForRedirect(String userId, Id idSobject) {
        RedirectWrapper wrapper = new RedirectWrapper();
        wrapper.channelUser = XC_UTIL_User.getChannelFromUser(userId);
        if(idSobject != null) {
            wrapper.typeObject = idSobject.getSObjectType().getDescribe().getName();
            wrapper.documentExists = checkDocumentOnAccount(idSobject, wrapper.typeObject);

            if(wrapper.typeObject != 'Contact' && !wrapper.documentExists){
                return wrapper;
            }
            if(wrapper.typeObject == 'WorkOrder') {
                wrapper.canCreateOpp = true;

                List<WorkOrder> listWo = new List<WorkOrder>([
                        SELECT Id, ContactId, AccountId, XC_Address__c, XC_ProductCategoryOfInterest__c, XC_Country__c
                        FROM WorkOrder
                        WHERE Id = :idSobject
                ]);
                wrapper.contactId = listWo[0].ContactId;
                wrapper.accountId = listWo[0].AccountId;
                wrapper.workOrderId = listWo[0].Id;
                wrapper.stageName = Label.XC_CL_Opportunity_Draft;
                wrapper.addressId = listWo[0].XC_Address__c;
                wrapper.productCategory = listWo[0].XC_ProductCategoryOfInterest__c;

                List<XC_CM_Opportunity_Default_Values__mdt> listCMcloseDate = new List<XC_CM_Opportunity_Default_Values__mdt>([
                        SELECT XC_Default_Days_For_Close_Date_On_Insert__c
                        FROM XC_CM_Opportunity_Default_Values__mdt
                        WHERE XC_Country__c = :listWo[0].XC_Country__c
                ]);

                wrapper.closeDate = !listCMcloseDate.isEmpty() ? Date.today().addDays(Integer.valueOf(listCMcloseDate[0].XC_Default_Days_For_Close_Date_On_Insert__c)) : wrapper.closeDate;
            }
        }
        return wrapper;
    }

    /**
    * @description check if document is populated on Account
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 4/11/2019
    * @param recordId id of record
    * @param sObjectName id of sObject
    * @return Boolean
    **/
    @AuraEnabled
    public static Boolean checkDocumentOnAccount(String recordId, String sObjectName) {
        String query = String.escapeSingleQuotes('SELECT ID FROM ACCOUNT WHERE XC_DocumentCountry__c != NULL AND IdentityType__c != NULL AND IdentityNumber__c != NULL AND ID IN (SELECT AccountId FROM  ' + sObjectName + ' WHERE ID = :recordId)');
        System.debug('Query: ' + query);
        List<Account> accList = Database.query(query);
        return !accList.isEmpty();
    }
}
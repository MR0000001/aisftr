/**
  @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  @date 26/03/2021
  @description XC_AMP_LCC020_SimplifiedSales - Apex Controller for component LCP247
*/

public without sharing class XC_AMP_LCC020_SimplifiedSales {

    /** @description Wrapper for cmp return */
    public class ResultWrapper {
        @AuraEnabled   
        public Boolean success = false;
        @AuraEnabled   
        public String message = '';
        @AuraEnabled   
        public String legalEntityUser = '';
        @AuraEnabled   
        public String segmentUser = '';
        @AuraEnabled   
        public Map<String, Object> mapViewDefinition = new Map<String, Object>();
        @AuraEnabled   
        public Map<String, Map<String, Object>> mapComponentDefinition = new Map<String, Map<String, Object>>();
        @AuraEnabled   
        public NE__Order__c order = new NE__Order__c();
        @AuraEnabled   
        public String checkPointStep = '';
        @AuraEnabled   
        public Map<String, Map<String, Object>> mapOtherInfoForComponentDefinition = new Map<String, Map<String, Object>>();
    }

    /**
        @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
        @date 26/03/2021
        @description Method to get template for new/edit mode
        @param oppId - String
        @return ResultWrapper
    */
    @AuraEnabled
    public static ResultWrapper getTemplate(String oppId) {
        ResultWrapper rw = new ResultWrapper();
        try {
            String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__Order__c') + ', NE__AccountId__r.XC_RecordTypeDeveloperName__c FROM NE__Order__c WHERE RecordType.Name	= \'Order\' AND NE__Type__c = \'InOrder\' AND XC_Status__c = \'In Progress\' AND NE__OptyId__c = \'' + oppId + '\'';
            List<NE__Order__c> listOrders = Database.query(query);
            if(listOrders.isEmpty()) {
                rw.success = false;
                rw.message = Label.XC_CL_NoOrderFound;
                return rw;
            }
            rw.order = listOrders[0];
            rw.checkPointStep = rw.order.XC_CheckpointSimplifiedSales__c;
            List<User> listUser = new List<User>([
                SELECT Id, XC_LegalEntity__c, Contact.XC_Segment__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ]);
            rw.legalEntityUser = listUser[0].XC_LegalEntity__c;
            rw.segmentUser = listUser[0].Contact.XC_Segment__c;
            List<XC_CM_OrderPortalSales_ViewDefinition__mdt> listViewDefinition = new List<XC_CM_OrderPortalSales_ViewDefinition__mdt>([
                SELECT Id, XC_NetworkName__c, XC_AvailableSections__c, XC_InsertDocument__c, XC_ClientType__c, XC_CategoriesMandatoryDocumentation__c, XC_ExtraSections__c, XC_CategoriesExtraSections__c, XC_EditableSectionsBeforeOrderCreation__c, XC_IsFullFlow__c, XC_DefaultCategoryOfInterest__c, XC_AvailableNextSteps__c 
                FROM XC_CM_OrderPortalSales_ViewDefinition__mdt
                WHERE XC_LegalEntity__c = :rw.legalEntityUser AND XC_Stream__c = 'B2C' AND XC_NetworkName__c = 'Enel x Partner Community' AND XC_ClientType__c = :Label.XC_CL_Account_ResindentialRt
            ]);
            rw.mapViewDefinition = listViewDefinition[0].getPopulatedFieldsAsMap();
            List<String> listComponentCmToQuery = XC_UTIL_Sobject.getListFieldValues(listViewDefinition, 'XC_AvailableNextSteps__c')[0].split(',');
            List<XC_CM_OrderPortalSales_ComponentDef__mdt> listCmpDefinition = new List<XC_CM_OrderPortalSales_ComponentDef__mdt>([SELECT Id, MasterLabel, XC_SectionName__c, XC_ComponentName__c, XC_FieldSetName__c, XC_ReferenceSObject__c, XC_FieldSetRequiredName__c, XC_RTDevName__c FROM XC_CM_OrderPortalSales_ComponentDef__mdt WHERE XC_LegalEntity__c = :rw.legalEntityUser AND XC_Stream__c = 'B2C' AND MasterLabel IN :listComponentCmToQuery]);
            for(XC_CM_OrderPortalSales_ComponentDef__mdt cmpDef : listCmpDefinition) {
                Map<String, Object> mapObject = cmpDef.getPopulatedFieldsAsMap();
                String referencedObject = mapObject.containsKey('XC_ReferenceSObject__c') ? (String)mapObject.get('XC_ReferenceSObject__c') : '';
                String fieldSetName = mapObject.containsKey('XC_FieldSetName__c') ? (String)mapObject.get('XC_FieldSetName__c') : '';
                String rtName = mapObject.containsKey('XC_RTDevName__c') ? (String)mapObject.get('XC_RTDevName__c') : '';
                String valueRecordTypeId = '';
                if(String.isNotBlank(referencedObject) && String.isNotBlank(rtName)) {valueRecordTypeId = Schema.getGlobalDescribe().get(referencedObject).getDescribe().getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId(); }
                List<XC_UTIL_FieldSet.FieldWrapper> valueFieldSet = new List<XC_UTIL_FieldSet.FieldWrapper>();
                if(String.isNotBlank(referencedObject) && String.isNotBlank(fieldSetName)) { valueFieldSet = XC_UTIL_FieldSet.getFieldSetFields(fieldSetName, referencedObject); }
                Map<String, Object> mapTemp = new Map<String, Object>();
                rw.mapComponentDefinition.put(cmpDef.MasterLabel, mapObject);
                mapTemp.put('RecordTypeId', valueRecordTypeId);
                mapTemp.put('FieldSet', valueFieldSet);
                rw.mapOtherInfoForComponentDefinition.put(cmpDef.Id, mapTemp);       
            }
            rw.success = true;
        } catch(Exception e) { rw.success = false; rw.message = e.getMessage(); }
        
        return rw;
    }

    /**
        @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
        @date 26/03/2021
        @description Method to update checkpoint
        @param orderId - String
        @param checkpoint - String
        @return ResultWrapper
    */
    @AuraEnabled
    public static ResultWrapper updateCheckPoint(String orderId, String checkpoint) {
        ResultWrapper rw = new ResultWrapper();
        try {
            NE__Order__c order = new NE__Order__c(
                Id = orderId,
                XC_CheckpointSimplifiedSales__c = checkpoint
            );
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(order);
            if(!wr.success) {
                rw.success = false;
                rw.message = wr.errorMessage;
                return rw;
            }
        } catch(Exception e) { rw.success = false; rw.message = e.getMessage(); return rw; }
        
        rw.success = true;
        return rw;
    }

    /**
        @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
        @date 07/04/2021
        @description Method to start provisioning
        @param orderId - String
        @param numberStep - Integer
        @return ResultWrapper
    */
    @AuraEnabled
    public static ResultWrapper startProvisioning(String orderId, Integer numberStep) {
        ResultWrapper rw = new ResultWrapper();
        try {
            XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
            rw.success = true;
            switch on numberStep {
                when 1 {
                    resWrapper = XC_LCC099_NextStepOrderToProvisioning.implementFirstNextStep(orderId);
                    if(!resWrapper.success) {
                        rw.success = false;
                        rw.message = resWrapper.resultMessage;
                    }
                }
                when 2 {
                    resWrapper = XC_LCC099_NextStepOrderToProvisioning.implementSecondNextStep(orderId);
                    if(!resWrapper.success) {
                        rw.success = false; rw.message = resWrapper.resultMessage;
                    }
                }
                when 3 {
                    resWrapper = XC_LCC099_NextStepOrderToProvisioning.implementThirdNextStep(orderId);
                    if(!resWrapper.success) {
                        rw.success = false; rw.message = resWrapper.resultMessage;
                    }
                }
                when else {
                    rw.success = false;
                    rw.message = 'Error number step provisioning';
                }
            }
        } catch(Exception e) {
            rw.success = false; rw.message = e.getMessage(); return rw;
        }
        return rw;
    }

    /**
        @author Eleni Tsiolaki
        @date 14/04/2021
        @description Method to create a new one, or to use the selected Billing Profile
        @param accountId - String
		@param mapValues - String
        @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createOrSelectBillingProfile(String accountId, String mapValues){
        return XC_AMP_UTIL_BillingProfileManagement.createOrSelectBillingProfile(accountId, mapValues);
    }

    /**
    * @author
    * @description Method to call Sia and manage Operation after call
    * @param contactId
    * @param lang
    * @param paymentMethod
    * @param billingProfileId
    *@return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper manageOperationBeforeCallSia(String contactId, String lang, String paymentMethod, String billingProfileId){
        return XC_AMP_UTIL_BillingProfileManagement.manageOperationBeforeCallSia(contactId, lang, paymentMethod, billingProfileId);
    }

    /**
     * @author
     * @description Method to prepare all the information needed and call the CreateUnlinkedZuoraAccount method
     * @param optionsMap - Map<String, Object>
     * @param account - Account
     * @param billTo - Contact
     * @param soldTo - Contact
     * @return String
     **/
    @AuraEnabled
    public static String prepareForCreateUnlinkedZuoraAccount(String optionsMap, String account, String billTo, String soldTo, String billingProfileLineItemId) {
        return XC_AMP_UTIL_BillingProfileManagement.prepareForCreateUnlinkedZuoraAccount(optionsMap, account, billTo, soldTo, billingProfileLineItemId);
    }

    /**
    * @description save integration logs from component
    * @author 
    * @param integrationLogList 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean saveIntegrationLog(String integrationLogList){ 
        return XC_AMP_UTIL_BillingProfileManagement.saveIntegrationLog(integrationLogList);
    }


    /**
     * @author
     * @description Method to link Payment Method to the Account 
     * @param zuoraAccountId - String
     * @param paymentMethodId - String
     * @param entityName - String
     * @return String
     **/
    @AuraEnabled
    public static String linkPaymentMethodToAccount(String zuoraAccountId, String paymentMethodId, String entityName){
        ZuoraWebservice zws = new ZuoraWebservice(entityName);
        ZuoraWebservice.LinkPaymentMethodToAccountResponse resp = zws.linkPaymentMethodToAccount(zuoraAccountId, paymentMethodId);
        return JSON.serialize(resp);
    }


    /**
     * @author
     * @description Method to link the Account to the External Payment Method
     * @param accountId - String
     * @param externalPaymentMethodType - String
     * @param entityName - String
     * @return Map<String,Object> 
     **/
    @AuraEnabled
    public static Map<String,Object> linkAccountToExternalPaymentMethod(String accountId, String externalPaymentMethodType, String entityName){
        return ZuoraWebservice.linkAccountToExternalPaymentMethod(accountId,externalPaymentMethodType,entityName);
    }

    /**
     * @author 
     * @date 
     * @description Method to rollback if Zuora fails for create payment method
     * @param paymentMethod - String
     * @param entityName - String
     * @param billingProfLineItemId - String
     * @return String
     **/
    @AuraEnabled
    public static String createPaymentMethod(String paymentMethod, String entityName, String billingProfLineItemId){
        return XC_AMP_UTIL_BillingProfileManagement.createPaymentMethod(paymentMethod, entityName, billingProfLineItemId);
    }

    /**
     * @author Eleni Tsiolaki
     * @description Method to associate the Billing Profile Line item to the Order
     *@param accountId - String
	 *@param mapValues - String
     *@return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper associateBillingProfile(String accountId, String billingProfileLineItemId, String opportunityId, String paymentMethod){
        return XC_AMP_UTIL_BillingProfileManagement.associateBillingProfile(accountId, billingProfileLineItemId, opportunityId, paymentMethod);
    }
}
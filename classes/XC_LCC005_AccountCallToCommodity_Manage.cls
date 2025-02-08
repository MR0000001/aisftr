/**
 * @author Monica Cutillo - monica.cutillo@nttdata.com (PMD > Salvatore Agrillo - salvatore.agrillo@nttdata.com)
 * @date Creation 06/05/2018
 * @description XC_LCC005_AccountCallToCommodity_Manage – Util class for XC_LCC005_AccountCallToCommodity
 */

public without sharing class XC_LCC005_AccountCallToCommodity_Manage {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC005_AccountCallToCommodity');

    /**
     * @description Manage response fake.
     * @param fakeResponse the fake response
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper manageResponseFake(String fakeResponse){
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        result.recordFields = new List<XC_LCC005_AccountCallToCommodity.FieldWrapper>();
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(fakeResponse); 
        for(String key : responseMap.keySet()){
            XC_LCC005_AccountCallToCommodity.FieldWrapper wr = new XC_LCC005_AccountCallToCommodity.FieldWrapper();
            wr.fieldLabel = key;
            wr.fieldValue = (String)responseMap.get(key);
            result.recordFields.add(wr);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'manageResponseFake RW='+wr);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'result.recordFields='+result.recordFields);
        result.success = true;

        return result;
    }

    /**
     * @description Manage response.
     * @param response the response
     * @return the result wrapper
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper manageResponse(HttpResponse response){
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        return result;
    }

    /**
     * @description retrieve Record Type Name from record id
     * @param recordId
     * @return record Type Name
     */
    private static String retrieveRecordTypeName(String recordId){
        String objType = XC_UTIL_Sobject.getObjectType(recordId);
        String recordTypeId = XC_UTIL_Sobject.getFieldValue(objType, 'RecordTypeId', recordId);
        return XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId);
    }
    
    /**
     * @description Manage Call Commodity Main
     * @param callResult
     * @param recordId
     * @param sobjectType
     * @return the result wrapper list
     */
    public static List<XC_LCC005_AccountCallToCommodity.ResultWrapper> manageCallCommodityMain(XC_REST_ReadAccont.WrapperResult callResult, String recordId, String sobjectType){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '########## CALL manageCallCommodityMain');
        XC_LCC005_AccountCallToCommodity.ResultWrapper rw;
        List<XC_LCC005_AccountCallToCommodity.ResultWrapper> result = new List<XC_LCC005_AccountCallToCommodity.ResultWrapper>();
        
        String rtAccountName = retrieveRecordTypeName(recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ Salesforce Account RT = '+rtAccountName);
        
        XC_REST_Account_W.WrapperResponseGET commodityResult = callResult.readAccountResponse;
        for(XC_UTIL_Account.AccountIFWrapper accountComm : commodityResult.Account){
            if(XC_UTIL_CommodityAccountRelated.checkCommodityAccountRecordType(sobjectType, rtAccountName, accountComm.AccountType)){
                rw = manageAccountCommodity(accountComm, callResult.viewDefinitions);
                result.add(rw);
            }
        }
        
        return result;
    }

    /**
     * @description Manage Call Commodity
     * @param accountWrapper
     * @param viewDefinitions
     * @return the result wrapper 
     */
    public static XC_LCC005_AccountCallToCommodity.ResultWrapper manageAccountCommodity(XC_UTIL_Account.AccountIFWrapper accountWrapper, Map<String,XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition> viewDefinitions){ 
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '########## CALL manageAccountCommodity');
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = new XC_LCC005_AccountCallToCommodity.ResultWrapper();
        result.success = true;
        //sezione Account
        //XC_REST_Account_W.WrapperResponseGET commodityResult = callResult.readAccountResponse;
        //XC_UTIL_Account.AccountIFWrapper accountWrapper = commodityResult.Account[0]; 
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'AccountIFWrapper='+accountWrapper);
        XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition accViewDef = viewDefinitions.get('Account');
        result.recordFields = XC_LCC005_AccountCallToCommodity.buildFieldsWrapper(accountWrapper, accViewDef);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'result.recordFields='+result.recordFields);
        if(accountWrapper.contact!= null){
            for(XC_UTIL_Account.ContactIFWrapper contact : accountWrapper.contact){
                if(contact.IdentityNumber == accountWrapper.IdentityNumber){
                    List<List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>>> subsectionObjects = new List<List<List<XC_LCC005_AccountCallToCommodity.FieldWrapper>>>();
                    XC_LCC005_AccountCallToCommodity.SectionFieldWrapper subsectionWrapper = XC_LCC005_AccountCallToCommodity.buildSectionFieldWrapper('LegalEntity', contact.GDPR.LegalEntity, viewDefinitions.get('LegalEntity'));//sectionCreation
                   subsectionObjects.add(subsectionWrapper.objectsRecordFields);
                }
            }
        }
       //sectionWrapper.subsectionObjects = subsectionObjects;
        //sezione Contacts  
        if(accountWrapper.Contact != null && !(accountWrapper.Contact.isEmpty())){
            //XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition contViewDef = viewDefinitions.get('Contact');
            //XC_LCC005_AccountCallToCommodity.SectionFieldWrapper contactSection = XC_LCC005_AccountCallToCommodity.sectionCreation('Contact', accountWrapper.Contact, contViewDef);
            XC_LCC005_AccountCallToCommodity.SectionFieldWrapper contactSection = XC_LCC005_AccountCallToCommodity.sectionContactCreation(accountWrapper.Contact, viewDefinitions);
            result.sections.put('Contact', contactSection);
        }
        //sezione Billing Profile
        Boolean isBillingProfileNotEmpty = accountWrapper.BillingProfile != null && !(accountWrapper.BillingProfile.isEmpty());
        if(isBillingProfileNotEmpty){
            XC_UTIL_ViewDefinitionsReadAccount.ReadAccountViewDefinition billPViewDef = viewDefinitions.get('BillingProfile');
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '########## accountWrapper.BillingProfile = '+accountWrapper.BillingProfile);
            XC_LCC005_AccountCallToCommodity.SectionFieldWrapper billingProfSection = XC_LCC005_AccountCallToCommodity.sectionCreation('BillingProfile', accountWrapper.BillingProfile, billPViewDef);
            result.sections.put('BillingProfile', billingProfSection);
        }
        Boolean isAddresWrapperNotEmpty = accountWrapper.Address != null && !(accountWrapper.Address.isEmpty());
        if(isAddresWrapperNotEmpty){
            XC_LCC005_AccountCallToCommodity.SectionFieldWrapper addressSection = XC_LCC005_AccountCallToCommodity.sectionAddressCreation(accountWrapper.Address, viewDefinitions);
            result.sections.put('Address', addressSection);
        }
        Boolean isContactWrapperNotEmpty = accountWrapper.Contact != null && !(accountWrapper.Contact.isEmpty());
        if(isContactWrapperNotEmpty){
            XC_LCC005_AccountCallToCommodity.SectionFieldWrapper legalEntitySection = XC_LCC005_AccountCallToCommodity.sectionLegalEntityCreation(accountWrapper.Contact, viewDefinitions, accountWrapper.IdentityNumber);
            result.sections.put('LegalEntity', legalEntitySection);
        }
        
        return result;
    }
}
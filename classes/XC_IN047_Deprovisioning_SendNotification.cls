/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 12/03/2020
* @date Modification dd/mm/yyyy 
* @description  - 
*/
public without sharing class XC_IN047_Deprovisioning_SendNotification {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN047_Deprovisioning_SendNotification');
    /** 
    * @description InputWrapper the input wrapper. TEST
    */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }

    /** 
    * @description UtilWrapper util wrapper for the class.
    */
    private class UtilWrapper{
        String customerType;
        String accountId;
        String contactId;
        String contactName;
        String orderId;
        String preferredlanguage;
        String email;
        String legalEntity;
        String invoice;
        String subscription;
    }
    /** 
    * @description Invocable method to launch the creation of a customer interaction
    * @param inputWrapperList
    */
    @InvocableMethod 
    public static void emailForDisconnect(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN047_Deprovisioning_SendNotification');
        createCustomerInteraction(getParentsInfo(inputWrapperList));
    }


    /**
    * @description Method to create a Customer Interaction record.
    * @param wrapper
    **/
    private static void createCustomerInteraction(UtilWrapper wrapper) {
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        String communicationType = Label.XC_CL_CustomerInteraction_Confirm_Cancellation;
        String accountId = wrapper.accountId;
        String contactId = wrapper.contactId;
        String contactName = wrapper.contactName;
        String orderId = wrapper.orderId;
        String preferredlanguage = wrapper.preferredlanguage;
        String email = wrapper.email;
        String legalEntity = wrapper.legalEntity;
        String invoice = wrapper.invoice;
        String subscription = wrapper.subscription;
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', communicationType);
        data.put('skipComunication', false);
        data.put('preferredlanguage', preferredlanguage);
        data.put('accountId', accountId);
        data.put('contactId', contactId);
        data.put('fullName', contactName);
        data.put('orderId',orderId);
        data.put('email',email);
        data.put('sent', false);
        data.put('legalEntity', legalEntity); 
		data.put('invoice', invoice);         
        data.put('subscription', subscription); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    }

    /**
    * @description Gets the info from step.
    * @param inputWrapperList the input wrapper list
    * @return 
    **/
    public static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList){    
        UtilWrapper wrapper = new UtilWrapper(); 
        NE__OrderItem__c orderItemFather = new NE__OrderItem__c();
        List<String> configurationItemIds = new List<String>(); 
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>();
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c> ([
            SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
            FROM XC_Provisioning_Step__c 
            WHERE Id IN: listStepIds
        ]);        
        List< XC_Provisioning_Step__c> listSteps =  mapSteps.values();
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        }
        
        configurationItemMap = new Map<Id, NE__OrderItem__c>([
            SELECT id, NE__OrderId__r.XC_CaseId__r.XC_Invoice__r.Zuora__External_Id__c , XC_CountryFormula__c, NE__OrderId__c, NE__OrderId__r.XC_LegalEntity__c, NE__ProdId__c, NE__ProdName__c, NE__Qty__c, NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c,NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c,NE__CatalogItem__c,NE__CatalogItem__r.NE__Catalog_Category_Name__c,NE__Catalog__c, 
            (SELECT id, AccountId, ContactId, XC_Subscription__r.Name, XC_Subscription__c, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c from Assets__r) 
            FROM NE__OrderItem__c 
            WHERE Id IN: configurationItemIds
        ]);              
        

        if(!configurationItemMap.isEmpty()){
            wrapper.orderId = configurationItemMap.values()[0].NE__OrderId__c;
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.XC_LegalEntity__c;
            wrapper.invoice =  configurationItemMap.values()[0].NE__OrderId__r.XC_CaseId__r.XC_Invoice__r.Zuora__External_Id__c;
            if(!configurationItemMap.values()[0].Assets__r.isEmpty()){
                wrapper.accountId = configurationItemMap.values()[0].Assets__r[0].AccountId;
                wrapper.contactId = configurationItemMap.values()[0].Assets__r[0].ContactId;
                wrapper.contactName = configurationItemMap.values()[0].Assets__r[0].Contact.Name;
                wrapper.email = configurationItemMap.values()[0].Assets__r[0].Contact.Email;
                wrapper.preferredlanguage = getPreferredLanguage(configurationItemMap.values()[0].Assets__r[0].Contact.XC_Preferredlanguageofcontact__c);
                wrapper.subscription = configurationItemMap.values()[0].Assets__r[0].XC_Subscription__r.Name;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.accountId -->' + wrapper.accountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.preferredlanguage -->' + wrapper.preferredlanguage);
        return wrapper; 
    }


    private static String getPreferredLanguage(String preferedLanguageOnContact){
        Schema.DescribeFieldResult fieldResult = XC_Customer_Interaction__c.XC_Preferredlanguageofcontact__c.getDescribe();
        List<String> acceptedLanguages= new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            acceptedLanguages.add(pickListVal.getLabel());
        }  
        String preferredlanguage = '';
        if(acceptedLanguages.contains(preferedLanguageOnContact)){
            preferredlanguage = preferedLanguageOnContact; 
        } else {
            preferredlanguage = Label.XC_CL_EnglishPrefLanguage;
        }
        return preferredlanguage;
    }  
}
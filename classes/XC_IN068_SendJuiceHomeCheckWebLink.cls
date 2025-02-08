/*
 * @author Dario Tramontin dtramonitn@deloitte.it
 * @date Creation 13/01/2021
 * @date Modification 
 * @description  – public class with invocable method. It is invoked by a Flow to generate the activation code and to create a XC_CustomerInteraction record
 */

public without sharing class XC_IN068_SendJuiceHomeCheckWebLink {

     public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN068_SendJuiceHomeCheckWebLink');


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
    public class UtilWrapper{
        public String stepId;
        public String accountId;
        public String contactId;
        public String contactName;
        public String opportunityId;
        public String eMail;
        public String preferredlanguage;
        public String catalog;
        public String channel;
        public String legalEntity;
        public String stream;
        public String source;
    }
    
    /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void emailForUserCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN068_SendJuiceHomeCheckWebLink');
        UtilWrapper utilWr = getParentsInfo(inputWrapperList);
        createCustomerInteraction(utilWr);
    }

    
    /**
     * @description Gets the info from step.
     * @param inputWrapperList the input wrapper list
     * @return 
     **/
    
    public static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList) {

        UtilWrapper wrapper = new UtilWrapper();
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
            wrapper.stepId = inputWr.stepId;
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: listStepIds]);
        List< XC_Provisioning_Step__c> listSteps =  mapSteps.values();

        List<String> configurationItemIds = new List<String>(); 
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        }
        
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([
            SELECT Id, NE__OrderId__r.NE__OptyId__r.XC_Contact__c,NE__OrderId__r.NE__OptyId__r.AccountId,  
            NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Email, NE__OrderId__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
            NE__OrderId__r.XC_LegalEntity__c,NE__OrderId__r.XC_Segment__c

                                                                                        FROM NE__OrderItem__c 
                                                                                        WHERE Id IN: configurationItemIds]);
        List<NE__OrderItem__c> listOrderItem = configurationItemMap.values();

        if(!configurationItemMap.isEmpty()) {
            wrapper.accountId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.AccountId;
            wrapper.contactId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
            wrapper.opportunityId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
            wrapper.eMail = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Email;
            wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c);
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.XC_LegalEntity__c;
            wrapper.stream = configurationItemMap.values()[0].NE__OrderId__r.XC_Segment__c;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.accountId -->' + wrapper.accountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.eMail -->' + wrapper.eMail);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.preferredlanguage -->' + wrapper.preferredlanguage);
        return wrapper; 
    }
    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    
    private static void createCustomerInteraction(UtilWrapper wrapper) {
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();

        String communicationType = 'Homecheck_Web_Purchase';
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', communicationType);
        data.put('email', wrapper.eMail);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('opportunityId', wrapper.opportunityId);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('segment', wrapper.stream);
        data.put('skipComunication', false);
        data.put('sent', false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOpportunity(interactions);
    }
}
/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 17/06/2019 
* @date Modification dd/mm/yyyy
* @description – public class with invocable method. It is invoked by the flow XC_FL_eMobility_B2B2CWelcomeEmail
*/
public without sharing class XC_IN026_EMobility_B2B2CWelcomeEmail {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN026_EMobility_B2B2CWelcomeEmail');

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
        String accountId;
        String contactId;
        String contactName;
        String orderId;
        String optyId;
        String preferredlanguage; /*ESCEP-1826 MCutillo 10/05/2019*/
        String productId;
        String legalEntity;
        String email;
        String stream;
    }


    /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void emailForUserCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN026_EMobility_B2B2CWelcomeEmail');
        createCustomerInteraction(getParentsInfo(inputWrapperList));
    }

    
    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    private static void createCustomerInteraction(UtilWrapper wrapper) {
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        String communicationType = Label.XC_CL_CustomerInteraction_B2B2CPurchaseEmail;

        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', communicationType);
        data.put('preferredlanguage', wrapper.preferredlanguage); /*ESCEP-1826 MCutillo 10/05/2019*/
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('fullName', wrapper.contactName);
        data.put('email', wrapper.email);
        data.put('orderId', wrapper.orderId);
        data.put('opportunityId', wrapper.optyId);
        data.put('productId', wrapper.productId);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('segment', wrapper.stream);
        data.put('skipComunication', false);
        data.put('sent', false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM data Map -->' + data);
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

        List<String> configurationItemIds = new List<String>(); 
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>();
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: listStepIds
                                                                                        ]);
        List< XC_Provisioning_Step__c> listSteps =  mapSteps.values();
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        }
        
        configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_CountryFormula__c, NE__OrderId__c, NE__ProdId__c, NE__ProdName__c, NE__Qty__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c,
                                                                NE__CatalogItem__c,NE__CatalogItem__r.NE__Catalog_Category_Name__c,NE__Catalog__c,NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c,
                                                                (SELECT Id, AccountId, ContactId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c from Assets__r) 
                                                            FROM NE__OrderItem__c 
                                                            WHERE Id IN: configurationItemIds
                                                            ]);
        
        if(!configurationItemMap.isEmpty()){
            wrapper.orderId = configurationItemMap.values()[0].NE__OrderId__c;
            wrapper.optyId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
            wrapper.productId = configurationItemMap.values()[0].NE__ProdId__c;
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.XC_LegalEntity__c;
            wrapper.stream = configurationItemMap.values()[0].NE__OrderId__r.XC_Segment__c;
            if(!configurationItemMap.values()[0].Assets__r.isEmpty()){
                wrapper.accountId = configurationItemMap.values()[0].Assets__r[0].AccountId;
                wrapper.contactId = configurationItemMap.values()[0].Assets__r[0].ContactId;
                wrapper.email = configurationItemMap.values()[0].Assets__r[0].Contact.Email;
                wrapper.contactName = configurationItemMap.values()[0].Assets__r[0].Contact.Name;
                wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(configurationItemMap.values()[0].Assets__r[0].Contact.XC_Preferredlanguageofcontact__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM wrapper.contactId -->' + wrapper.contactId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM wrapper.accountId -->' + wrapper.accountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM wrapper.preferredlanguage -->' + wrapper.preferredlanguage);
        return wrapper; 
    }
    
}
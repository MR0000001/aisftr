/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 26/04/2019
* @date Modification 25/05/2020
* @description  – public class with invocable method. It is invoked by a Flow to create a XC_CustomerInteraction record
*/ 


public without sharing class XC_IN021_EMobility_EmailForUserCreation {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN021_EMobility_EmailForUserCreation');


    /** 
     * @description InputWrapper the input wrapper.
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }


    /** 
     * @description UtilWrapper util wrapper for the class.
     */
    public class UtilWrapper {
        //public Map<String, Ne__Order__c> prodNameConfMap = new Map<String, Ne__Order__c>();
        public String accountId;
        public String contactId;
        public String configurationId;
        public String optyId;
        public String accountName;
        public String contactName;
        public String email;
        public String legalEntity;
        public String stream;
        public String preferredlanguage;
        public String productId;
        public String portalName;
        public String activationCountry;
        public Boolean setEmobWebAppTypeOnCI = false;
    }


    /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void emailForUserCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN021_EMobility_EmailForUserCreation');
        UtilWrapper utilWrap = getParentsInfo(inputWrapperList);
        populateFieldsOnOrder(utilWrap);
        createCustomerInteraction(utilWrap);
    }


    /**
     * @description populate Fields On Order
     * @param wrapper wrapper
     **/
    public static void populateFieldsOnOrder(UtilWrapper wrapper) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM wrapper.configurationId: ' + wrapper.configurationId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM wrapper.portalName: ' + wrapper.portalName);

        NE__Order__c orderToUpdate = new NE__Order__c(Id = wrapper.configurationId);
        orderToUpdate.XC_EmobilityWebAppType__c = wrapper.portalName;
        XC_UTIL_Sobject.updateRecord(orderToUpdate);
    }


    /**
     * @description Gets the info from step.
     * @param inputWrapperList the input wrapper list
     * @return 
     **/
    public static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList){
        UtilWrapper wrapper = new UtilWrapper();

        Set<String> configurationItemIds = new Set<String>(); 
        Map<String, String> confItemIdConfIdMap = new Map<String, String>();
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>();
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        }

        if(Schema.sObjectType.XC_Provisioning_Step__c.isAccessible() && Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            
            List<XC_Provisioning_Step__c> listSteps = [SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
                                                        FROM XC_Provisioning_Step__c 
                                                        WHERE Id IN: listStepIds
                                                        ];
            for(XC_Provisioning_Step__c step : listSteps){
                if(!String.isBlank(step.XC_Configuration_Item__c)){
                    configurationItemIds.add(step.XC_Configuration_Item__c);
                }
            }

            XC_UTIL_Debug.debug(DEBUGACTIVE, 'listStepIds -->' + listStepIds);
        
            configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_CountryFormula__c, NE__OrderId__c, NE__ProdId__c, NE__ProdId__r.XC_LIC_Product_Name__c, NE__OrderId__r.NE__OptyId__c,
                                                                        NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c,
                                                                        (SELECT id, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c from Assets__r) 
                                                                    FROM NE__OrderItem__c 
                                                                    WHERE Id IN: configurationItemIds
                                                                ]);
        }

        if(!configurationItemMap.isEmpty()){
            confItemIdConfIdMap.put(configurationItemMap.values()[0].Id, configurationItemMap.values()[0].NE__OrderId__c);
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            wrapper.stream = configurationItemMap.values()[0].NE__OrderId__r.XC_Segment__c;
            wrapper.configurationId = configurationItemMap.values()[0].NE__OrderId__c;
            wrapper.optyId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
            wrapper.activationCountry = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_ActivationCountry__c;
            wrapper.productId = configurationItemMap.values()[0].NE__ProdId__c;
            if(!configurationItemMap.values()[0].Assets__r.isEmpty()){
                wrapper.accountId = configurationItemMap.values()[0].Assets__r[0].AccountId;
                wrapper.accountName = configurationItemMap.values()[0].Assets__r[0].Account.Name;
                wrapper.contactId = configurationItemMap.values()[0].Assets__r[0].ContactId;
                wrapper.email = configurationItemMap.values()[0].Assets__r[0].Contact.Email;
                wrapper.contactName = configurationItemMap.values()[0].Assets__r[0].Contact.Name;
                wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(configurationItemMap.values()[0].Assets__r[0].Contact.XC_Preferredlanguageofcontact__c);
            }
        }

        for(String configurationItemId : confItemIdConfIdMap.keySet()){
            checkProduct(configurationItemMap.get(configurationItemId).NE__ProdId__r.XC_LIC_Product_Name__c, wrapper);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM wrapper: ' + wrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM wrapper.accountId: ' + wrapper.accountId);

        return wrapper; 
    }


    /**
     * @description Create the Customer Interaction.
     * @param wrapper the UtilWrapper
     **/
    private static void checkProduct(String prodName, UtilWrapper wrapper) {

        if(prodName.contains('SABA') || prodName.contains('BAMSA')){
            wrapper.portalName = Label.XC_CL_EmobilityWebAppType_SABA;
            wrapper.setEmobWebAppTypeOnCI = true;
        } else if(prodName.contains('Rent')){
            wrapper.portalName = Label.XC_CL_EmobilityWebAppType_RentACar;
            wrapper.setEmobWebAppTypeOnCI = true;
        } else if(prodName.contains('Merlin')){
            wrapper.portalName = Label.XC_CL_EmobilityWebAppType_Recharge;
            wrapper.setEmobWebAppTypeOnCI = true;
        } else {
            wrapper.portalName = Label.XC_CL_EmobilityWebAppType_Recharge;
            wrapper.setEmobWebAppTypeOnCI = false;
        }
    } 


    /**
     * @description Create the Customer Interaction.
     * @param wrapper the UtilWrapper
     **/
    private static void createCustomerInteraction(UtilWrapper wrapper) {
        
        String legalEntity = wrapper.legalEntity;
        String stream = wrapper.stream;
        String activationCountry = String.isNotBlank(wrapper.activationCountry) ? wrapper.activationCountry : '';
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', Label.XC_CL_CustomerInteraction_SuperUserCreation);
        data.put('legalEntity', legalEntity);

        // Map<String, XC_CM_CustomerInteractionConfiguration__mdt> customerInteractionInfo = XC_UTIL_CustomerInteractionGeneration.getCustomerInteractionInfo(Label.XC_CL_CustomerInteraction_SuperUserCreation, legalEntity, stream);
        Map<String, XC_CM_CustomerInteractionConfiguration__mdt> customerInteractionInfo = getCustomerInteractionInfo(Label.XC_CL_CustomerInteraction_SuperUserCreation, legalEntity, stream);
        if(String.isNotBlank(activationCountry) && customerInteractionInfo.containsKey(legalEntity + activationCountry)){
            data.put('email', customerInteractionInfo.get(legalEntity + activationCountry).XC_Email__c);
        } else if(customerInteractionInfo.containsKey(legalEntity)) {
            data.put('email', customerInteractionInfo.get(legalEntity).XC_Email__c);
        }

        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId); 
        data.put('fullName', wrapper.accountName);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('orderId', wrapper.configurationId);
        data.put('opportunityId', wrapper.optyId);
        data.put('productId', wrapper.productId);
        data.put('skipComunication', false);
        data.put('sent', false);
        data.put('setEmobWebAppTypeOnCI', wrapper.setEmobWebAppTypeOnCI);
        data.put('segment', stream);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@NM data Map -->' + data);
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    }


    /** 
     * @description method to return the custom metadata CustomerInteractionConfiguration
     * @param communicationType
     * @param legalEntity
     * @return customerInteractionMap
     **/
    public static Map<String,XC_CM_CustomerInteractionConfiguration__mdt> getCustomerInteractionInfo(String communicationType, String legalEntity, String stream){
        System.debug('enter in getCustomerInteractionInfo con '+communicationType+ ' and legalEntity = '+legalEntity);

        Map<String, XC_CM_CustomerInteractionConfiguration__mdt> customerInteractionMap = new Map<String,XC_CM_CustomerInteractionConfiguration__mdt>();

        Map<Id,XC_CM_CustomerInteractionConfiguration__mdt> customerInteractionQueryMap = new Map<Id,XC_CM_CustomerInteractionConfiguration__mdt> (
                                                    [SELECT Id, XC_CommunicationType__c, XC_Email__c, XC_LegalEntity__c, XC_Country__c 
                                                    FROM XC_CM_CustomerInteractionConfiguration__mdt  
                                                    WHERE XC_CommunicationType__c =: communicationType AND XC_LegalEntity__c =: legalEntity AND XC_Stream__c =: stream]);

        System.debug('@2006 customerInteractionMap->'+ JSON.serialize(customerInteractionQueryMap) );
        if(!customerInteractionQueryMap.isEmpty()){ 
            for(XC_CM_CustomerInteractionConfiguration__mdt customerInteraction : customerInteractionQueryMap.values()) {
                customerInteraction.XC_Country__c = (String.isNotBlank(customerInteraction.XC_Country__c)) ? customerInteraction.XC_Country__c : '';
                customerInteractionMap.put(legalEntity + customerInteraction.XC_Country__c, customerInteraction);
            }
        }
         
        return customerInteractionMap;                            
    }
    
}
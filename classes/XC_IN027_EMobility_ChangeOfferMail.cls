/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 17/06/2019 
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by the flow XC_FL_eMobility_ChangeOfferMail
*/


public without sharing class XC_IN027_EMobility_ChangeOfferMail {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN027_EMobility_ChangeOfferMail');


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
        String orderId;
        String optyId;
        String preferredlanguage; /*ESCEP-1826 MCutillo 10/05/2019*/
        String productId;
        String legalEntity;
        String email;
        String contactName;
        String eMobTransactionId;
        String subType;
    }


    /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void emailForUserCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN027_EMobility_ChangeOfferMail');
        createCustomerInteraction(getParentsInfo(inputWrapperList));
    }

    
    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    private static void createCustomerInteraction(UtilWrapper wrapper) {
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', Label.XC_CL_CustomerInteraction_ChangeFeeEmail);   // For standard eMobility Change Offer
        data.put('skipComunication', false);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('orderId', wrapper.orderId);
        data.put('opportunityId', wrapper.optyId);
        data.put('fullName', wrapper.contactName);
        data.put('email', wrapper.email);
        data.put('productId', wrapper.productId);
        data.put('sent', false);
        data.put('legalEntity', wrapper.legalEntity);
       
        if(String.isNotBlank(wrapper.eMobTransactionId) && wrapper.eMobTransactionId.deleteWhitespace() == Label.XC_CL_OpenCharge.deleteWhitespace()) {     // For change offer from OpenCharge to PPU
            data.put('customerType', Label.XC_CL_CustomerInteraction_CommodityKOChangeFeeEmail);
            data.put('subject', Label.XC_CL_OpenCharge.deleteWhitespace());

            NE__Order__c order = new NE__Order__c();
            order.Id = wrapper.orderId;
            order.XC_eMobTransactionId__c = null;
            XC_UTIL_SObject.updateRecord(order);

        } else if(wrapper.subType == Label.XC_CL_ConfigurationSubtype_ServiceUpgradeDowngrade) {    // For disconnection of OpenCharge to PPU
            data.put('customerType', Label.XC_CL_CustomerInteraction_OpenChargeReactivationEmail);
        }

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

        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c> ([SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: listStepIds
                                                                                            ]);
        List<XC_Provisioning_Step__c> listSteps =  mapSteps.values();

        Set<Id> configurationItemIds = new Set<Id>(); 
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        } 
        
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT id, XC_CountryFormula__c, NE__OrderId__c ,NE__ProdId__c, NE__ProdName__c, NE__Qty__c, NE__OrderId__r.NE__OptyId__c,
                                                                                            NE__OrderId__r.NE__OptyId__r.XC_CompanyCode__c, NE__OrderId__r.NE__OptyId__r.XC_CostCenter__c, NE__CatalogItem__c,
                                                                                            NE__CatalogItem__r.NE__Catalog_Category_Name__c,NE__Catalog__c, NE__OrderId__r.XC_LegalEntity__c, 
                                                                                            NE__OrderId__r.XC_eMobTransactionId__c, NE__OrderId__r.XC_Subtype__c,
                                                                                            (SELECT id, AccountId, ContactId, Contact.Email, Contact.Name, Contact.XC_Preferredlanguageofcontact__c from Assets__r) 
                                                                                        FROM NE__OrderItem__c 
                                                                                        WHERE Id IN: configurationItemIds
                                                                                        ]);
        
        if(!configurationItemMap.isEmpty()) {
            wrapper.orderId = configurationItemMap.values()[0].NE__OrderId__c;
            wrapper.optyId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
            wrapper.productId = configurationItemMap.values()[0].NE__ProdId__c;
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.XC_LegalEntity__c;
            wrapper.eMobTransactionId = configurationItemMap.values()[0].NE__OrderId__r.XC_eMobTransactionId__c;
            wrapper.subType = configurationItemMap.values()[0].NE__OrderId__r.XC_Subtype__c;
            if(!configurationItemMap.values()[0].Assets__r.isEmpty()){
                wrapper.accountId = configurationItemMap.values()[0].Assets__r[0].AccountId;
                wrapper.contactId = configurationItemMap.values()[0].Assets__r[0].ContactId;
                wrapper.contactName = configurationItemMap.values()[0].Assets__r[0].Contact.Name;
                wrapper.email = configurationItemMap.values()[0].Assets__r[0].Contact.Email;
                wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(configurationItemMap.values()[0].Assets__r[0].Contact.XC_Preferredlanguageofcontact__c);
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.accountId -->' + wrapper.accountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.preferredlanguage -->' + wrapper.preferredlanguage);

        return wrapper; 
    }

}
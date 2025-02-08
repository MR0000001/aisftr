/*
 * @author Dario Tramontin dtramonitn@deloitte.it
 * @date Creation 08/01/2021
 * @date Modification 
 * @description  – public class with invocable method. It is invoked by a Flow to generate the activation code and to create a XC_CustomerInteraction record
 */

public without sharing class XC_IN066_OrderConfirmationDealerNotif {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN066_OrderConfirmationDealerNotif');


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
        public String orderId;
        public String orderItemID;
        public String opportunityId;
        public String eMail;
        public String preferredlanguage;
        public String catalog;
        public String channel;
        public String legalEntity;
        public String stream;
        public String source;
        public String additionalInfo1;
        public String additionalInfo2;
    }
    
    /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void emailForUserCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN066_OrderConfirmationDealerNotif');
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
        
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__OrderId__r.CreatedBy.ContactId, NE__OrderId__r.CreatedBy.Contact.Name, NE__OrderId__r.CreatedBy.AccountId, NE__OrderId__c, NE__OrderId__r.XC_Segment__c,
                                                                                        NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.CreatedBy.Contact.Email, XC_Product_Subtype__c,NE__ProdId__c,NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.CreatedBy.Contact.XC_Preferredlanguageofcontact__c
                                                                                        FROM NE__OrderItem__c 
                                                                                        WHERE Id IN: configurationItemIds]);
        List<NE__OrderItem__c> listOrderItem = configurationItemMap.values();

        List<String> listProduct = new List<String>(); 
        for( NE__OrderItem__c order : listOrderItem){
            listProduct.add(order.NE__ProdId__c);
        }
        Map<Id, NE__DocumentationCharacterist__c> mapDocChar = new Map<Id, NE__DocumentationCharacterist__c>([SELECT Id, Name, NE__Product__c, NE__Value__c 
                                                                                        FROM NE__DocumentationCharacterist__c  
                                                                                        WHERE NE__Product__c IN: listProduct and LicName__c='Included kWH']);
        //List< NE__DocumentationCharacterist__c> listDocChar =  mapDocChar.values();
        if(!configurationItemMap.isEmpty()) {
            wrapper.accountId = configurationItemMap.values()[0].NE__OrderId__r.CreatedBy.AccountId;
            wrapper.contactId = configurationItemMap.values()[0].NE__OrderId__r.CreatedBy.ContactId;
            //wrapper.contactName = configurationItemMap.values()[0].NE__OrderId__r.CreatedBy.Contact.Name;
            wrapper.orderId = configurationItemMap.values()[0].NE__OrderId__c;
            wrapper.orderItemID = configurationItemMap.values()[0].Id;
            wrapper.opportunityId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
            wrapper.eMail = configurationItemMap.values()[0].NE__OrderId__r.CreatedBy.Contact.Email;
            wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(configurationItemMap.values()[0].NE__OrderId__r.CreatedBy.Contact.XC_Preferredlanguageofcontact__c);
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.XC_LegalEntity__c;
            wrapper.stream = configurationItemMap.values()[0].NE__OrderId__r.XC_Segment__c;
            wrapper.additionalInfo1 = configurationItemMap.values()[0].XC_Product_Subtype__c;
            if(mapDocChar != null && !mapDocChar.isEmpty() ){
                wrapper.additionalInfo2 = mapDocChar.values()[0].NE__Value__c;
            }
        }


        System.debug(' wrapper.accountId -->' + wrapper.accountId);
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

        String communicationType = 'Orders_Closed_Dealer';
        
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', communicationType);
        data.put('email', wrapper.eMail);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('opportunityId', wrapper.opportunityId);
        data.put('orderId', wrapper.orderId);
        data.put('orderItemID', wrapper.orderItemID);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('segment', wrapper.stream);
        data.put('additionalInfo1',wrapper.additionalInfo1);
        data.put('additionalInfo2', wrapper.additionalInfo2);
        data.put('skipComunication', false);
        data.put('sent', false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
    }
    

    /**
     * @description Get Sales Channel.
     * @param companyCode the company Code
     * @param costCenter the cost Center
     * @param childProdId the child Prod Id
     * @return the SalesChannel
     **/
    /*
    private static String getSalesChannel(String companyCode, String costCenter, String childProdId) {

        String salesChannel = '';
        Asset a;

        List<NE__Product__c> prodList = new List<NE__Product__c>([SELECT Id, (SELECT Id, NE__ProdId__c FROM NE__Asset_Prod__r WHERE XC_CompanyCode__c =: companyCode AND XC_CostCenter__c =: costCenter AND XC_ZQuoteId__c != '' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != ''),
                                                                    (SELECT ID, NE__FamilyId__r.XC_LIC_Family_Name__c FROM NE__ProductFamily__r WHERE NE__FamilyId__r.XC_LIC_Family_Name__c = :Label.XC_CL_Family_JNManager)
                                                                FROM NE__Product__c
                                                                WHERE Id IN (SELECT NE__ProdId__c FROM Asset WHERE XC_CompanyCode__c =: companyCode AND XC_CostCenter__c =: costCenter AND XC_ZQuoteId__c != '' AND NE__Order_Config__r.XC_EmobilityWebAppType__c != '')]);
        for(NE__Product__c pr : prodList) {
            if(pr.NE__ProductFamily__r.isEmpty()) {
                a = pr.NE__Asset_Prod__r[0];
            }
        }

        if(a == null){
            System.debug('@@@ Asset Father not found');
            return salesChannel;
        }

        List<NE__DocumentationCharacterist__c> docCharList = new List<NE__DocumentationCharacterist__c>([SELECT NE__Product__c, NE__Value__c FROM NE__DocumentationCharacterist__c
                                                                                                            WHERE LicName__c =: Label.XC_CL_SellingChannel AND (NE__Product__c =: a.NE__ProdId__c OR NE__Product__c =: childProdId)]);
        String salesChannelFather = '';
        String salesChannelChild = '';
        for(NE__DocumentationCharacterist__c dc : docCharList) {
            if(dc.NE__Product__c == a.NE__ProdId__c) {
                salesChannelFather = dc.NE__Value__c;
            } else if (dc.NE__Product__c == childProdId) {
                salesChannelChild = dc.NE__Value__c;
            }
        }
        salesChannel = salesChannelFather + '-' + salesChannelChild;
        
        return salesChannel;
    }*/
}
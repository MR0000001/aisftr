/**
 * @author Dario Tramontin dtramonitn@deloitte.it
 * @date Creation 08/01/2021
 * @date Modification 
 * @description  – public class with invocable method. It is invoked by a Flow to generate the activation code and to create a XC_CustomerInteraction record
 */


public without sharing class XC_IN067_SiteInspectionResultDealerNotif {



    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN067_SiteInspectionResultDealerNotif');


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
        public String dealerAccountId;
        public String dealerContactId;
        public String dealerEmail;
        public String dealerPreferredlanguage;
        public String customerAccountId;
        public String customerContactId;
        public String customerEmail;
        public String customerPreferredlanguage;
        public String orderId;
        public String orderItemID;
        public String opportunityId;
        public String catalog;
        public String channel;
        public String legalEntity;
        public String stream;
        public String source;
        public String additionalInfo1;
        public String additionalInfo2;
        public String serviceAppointmentId;
        public String workorderId;
        public String productName;
    }


    /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void emailForUserCreation(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN067_SiteInspectionResultDealerNotif');
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
        
        /*Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__OrderId__r.CreatedBy.ContactId, NE__OrderId__r.CreatedBy.Contact.Name, NE__OrderId__r.CreatedBy.AccountId, NE__OrderId__c, 
                                                                                        NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.CreatedBy.Contact.Email, XC_Product_Subtype__c, NE__ProdId__r.XC_LIC_Product_Name__c
                                                                                        FROM NE__OrderItem__c 
                                                                                        WHERE Id IN: configurationItemIds]);*/
        
        Map<Id,WorkOrder> woMap = new Map<Id,WorkOrder>([SELECT Id, XC_Configuration__c, XC_Configuration_Item__c, XC_Opportunity__c,  XC_Configuration__r.CreatedBy.ContactId, XC_Configuration_Item__r.NE__ProdId__r.XC_LIC_Product_Name__c,
                                                            XC_Result__c, XC_MaxWallboxPower__c, XC_Configuration__r.CreatedBy.Contact.XC_Preferredlanguageofcontact__c, XC_Configuration__r.CreatedBy.AccountId, XC_Configuration__r.CreatedBy.Email,
                                                            XC_Configuration__r.XC_LegalEntity__c, XC_Configuration__r.CreatedBy.Contact.Email, XC_Configuration__r.XC_Segment__c, XC_Configuration__r.NE__OptyId__r.AccountId,
                                                            XC_Configuration__r.NE__OptyId__r.XC_Contact__c, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                                            (SELECT Id, XC_Result__c, XC_MaxWallboxPower__c FROM ServiceAppointments)  
                                                        FROM WorkOrder
                                                        WHERE XC_Configuration_Item__c =: configurationItemIds]);

        if(!woMap.isEmpty()) {
            wrapper.dealerAccountId = woMap.values()[0].XC_Configuration__r.CreatedBy.AccountId;
            wrapper.dealerContactId = woMap.values()[0].XC_Configuration__r.CreatedBy.ContactId;
            wrapper.dealerEmail = woMap.values()[0].XC_Configuration__r.CreatedBy.Contact.Email;
            wrapper.dealerPreferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(woMap.values()[0].XC_Configuration__r.CreatedBy.Contact.XC_Preferredlanguageofcontact__c);
            wrapper.customerAccountId = woMap.values()[0].XC_Configuration__r.NE__OptyId__r.AccountId;
            wrapper.customerContactId = woMap.values()[0].XC_Configuration__r.NE__OptyId__r.XC_Contact__c;
            wrapper.customerEmail = woMap.values()[0].XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email;
            wrapper.customerPreferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(woMap.values()[0].XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c);
            wrapper.orderId = woMap.values()[0].XC_Configuration__c;
            wrapper.orderItemID = woMap.values()[0].XC_Configuration_Item__c;
            wrapper.opportunityId = woMap.values()[0].XC_Opportunity__c;
            wrapper.serviceAppointmentId = woMap.values()[0].ServiceAppointments[0].Id;
            wrapper.workorderId = woMap.values()[0].Id;
            wrapper.legalEntity = woMap.values()[0].XC_Configuration__r.XC_LegalEntity__c;
            wrapper.stream = woMap.values()[0].XC_Configuration__r.XC_Segment__c;
            wrapper.productName = woMap.values()[0].XC_Configuration_Item__r.NE__ProdId__r.XC_LIC_Product_Name__c;
            wrapper.additionalInfo1 = woMap.values()[0].XC_Result__c;
            wrapper.additionalInfo2 = woMap.values()[0].XC_MaxWallboxPower__c;            
        }

        System.debug('@SS@ wrapper.dealerAccountId -->' + wrapper.dealerAccountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.dealerContactId -->' + wrapper.dealerContactId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.dealerEmail -->' + wrapper.dealerEmail);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.dealerPreferredlanguage -->' + wrapper.dealerPreferredlanguage);
        System.debug('@SS@ wrapper.customerAccountId -->' + wrapper.customerAccountId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.customerContactId -->' + wrapper.customerContactId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.customerEmail -->' + wrapper.customerEmail);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ wrapper.customerPreferredlanguage -->' + wrapper.customerPreferredlanguage);
        return wrapper; 
    }


    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    private static void createCustomerInteraction(UtilWrapper wrapper) {

        String accountId = '';
        String contactId = '';
        String email = '';
        String preferredlanguage = '';
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        String communicationType = '';
        if(wrapper.productName == Label.XC_CL_ProductLicName_HomeCheckOpenCharge){
            communicationType = 'SiteInspection_Customer';
            accountId = wrapper.customerAccountId;
            contactId = wrapper.customerContactId;
            email = wrapper.customerEmail;
            preferredlanguage = wrapper.customerPreferredlanguage;
        } else {
		    communicationType = 'SiteInspection_Dealer';
            accountId = wrapper.dealerAccountId;
            contactId = wrapper.dealerContactId;
            email = wrapper.dealerEmail;
            preferredlanguage = wrapper.dealerPreferredlanguage;
        }

        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', communicationType);
        data.put('email', email);
        data.put('preferredlanguage', preferredlanguage);
        data.put('accountId', accountId);
        data.put('contactId', contactId);
        data.put('opportunityId', wrapper.opportunityId);
        data.put('orderId', wrapper.orderId);
        data.put('orderItemID', wrapper.orderItemID);
        data.put('serviceAppointmentId', wrapper.serviceAppointmentId);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('segment', wrapper.stream);
        data.put('additionalInfo1',wrapper.additionalInfo1);
        data.put('additionalInfo2', wrapper.additionalInfo2);
        data.put('skipComunication', false);
        data.put('workorderId', wrapper.workorderId);
        data.put('sent', false);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
    }

}
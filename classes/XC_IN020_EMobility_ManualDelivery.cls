/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 23/04/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by a Flow to create a specific case connected with the step "Manual Delivery" in the eMobility templates
*/ 


public without sharing class XC_IN020_EMobility_ManualDelivery {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN020_EMobility_ManualDelivery');
    

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
    public class UtilWrapper{
        public String country;
        public String accountId;
        public String contactId;
        public String assetId;
        public String orderId;
        public String opportunityId;
        public String accountName;
        public String accountPhone;
        public String legalEntity;
        public String stream;
        public String preferredlanguage;
        public String productId;
        public Decimal quantity;
    }


    /** 
     * @description create a Manual Delivery Case.
     * @param inputWrapperList from the flow
     */
    @InvocableMethod
    public static void createManualDeliveryCase(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN020_EMobility_ManualDelivery');

        List<String> caseSettingNames = new List<String>{Label.XC_CL_ManualDeliveryCase};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_ManualDeliveryCase);

        UtilWrapper utilWr = getParentsInfo(inputWrapperList);
        
        createCase(caseSettings, utilWr);
        createCustomerInteraction(utilWr);
    } 


    /**
     * @description Gets the info from step.
     * @param inputWrapperList the input wrapper list
     * @return 
     **/
    private static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList){
        UtilWrapper wrapper = new UtilWrapper();

        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        }
        
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id,XC_Provisioning_Step__c> ([SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: listStepIds
                                                                                        ]);
        List<XC_Provisioning_Step__c> listSteps =  mapSteps.values();
        
        Set<String> configurationItemIds = new Set<String>(); 
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__c)){
                configurationItemIds.add(step.XC_Configuration_Item__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listStepIds -->' + listStepIds);
    

        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>([SELECT id, XC_CountryFormula__c, NE__OrderId__c, NE__ProdId__c, NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__Qty__c, NE__OrderId__r.XC_Segment__c,
                                                                                            (SELECT id, AccountId, Account.Name, Account.MainPhone__c, ContactId, Contact.Email, Contact.XC_Preferredlanguageofcontact__c from Assets__r) 
                                                                                        FROM NE__OrderItem__c 
                                                                                        WHERE Id IN: configurationItemIds
                                                                                        ]);
        
        if(!configurationItemMap.isEmpty()){
            wrapper.quantity = configurationItemMap.values()[0].NE__Qty__c;
            wrapper.country = configurationItemMap.values()[0].XC_CountryFormula__c;
            wrapper.orderId = configurationItemMap.values()[0].NE__OrderId__c;
            wrapper.opportunityId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__c;
            wrapper.contactId = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
            wrapper.legalEntity = configurationItemMap.values()[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            wrapper.stream = configurationItemMap.values()[0].NE__OrderId__r.XC_Segment__c;
            wrapper.productId = configurationItemMap.values()[0].NE__ProdId__c;
            if(!configurationItemMap.values()[0].Assets__r.isEmpty()){
                wrapper.accountId = configurationItemMap.values()[0].Assets__r[0].AccountId;
                wrapper.assetId = configurationItemMap.values()[0].Assets__r[0].Id;
                wrapper.accountName = configurationItemMap.values()[0].Assets__r[0].Account.Name;
                wrapper.accountPhone = configurationItemMap.values()[0].Assets__r[0].Account.MainPhone__c;
                wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(configurationItemMap.values()[0].Assets__r[0].Contact.XC_Preferredlanguageofcontact__c);
            }
        }

        return wrapper; 
    }
    

    /**
     * @description Method that create the case
     * @param caseSettings info about case
     * @param utilWr info on configuration item and asset
     **/
    private static void createCase(XC_CM_Case_Type_Setting__mdt caseSettings, UtilWrapper utilWr){  
        List<Case> caseToInsertList = new List<Case>();

        Case cs = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        cs.AccountId = utilWr.accountId;
        cs.ContactId = utilWr.contactId;
        cs.AssetId = utilWr.assetId;
        cs.XC_Order__c = utilWr.orderId;
        cs.XC_OriginChannel__c = Label.XC_EMobility;
        cs.XC_LegalEntity__c = utilWr.legalentity;
        cs.XC_Resolution__c = caseSettings.XC_Resolution__c;
        cs.XC_Result__c = caseSettings.XC_Result__c;
        cs.CaseRemarks__c = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(caseSettings, utilWr.legalentity);
        caseToInsertList.add(cs);

        XC_UTIL_Sobject.insertListRecords(caseToInsertList);
    }


    /**
     * @description Method that create the CI
     * @param wrapper the wrapper
     **/
    public static void createCustomerInteraction(UtilWrapper wrapper) { 

        Map<String,Object> data = new Map<String,Object>();
        
        Map<String, XC_CM_CustomerInteractionConfiguration__mdt> customerInteractionInfo = XC_UTIL_CustomerInteractionGeneration.getCustomerInteractionInfo(Label.XC_CL_CustomerInteraction_DeliveryEngagementEmail, wrapper.legalEntity, wrapper.stream);
        if(!customerInteractionInfo.isEmpty() && customerInteractionInfo.containsKey(Label.XC_CL_CustomerInteraction_DeliveryEngagementEmail)){
            data.put('email', customerInteractionInfo.get(Label.XC_CL_CustomerInteraction_DeliveryEngagementEmail).XC_Email__c);
            data.put('legalEntity', customerInteractionInfo.get(Label.XC_CL_CustomerInteraction_DeliveryEngagementEmail).XC_LegalEntity__c);            
        }
        
        data.put('customerType', Label.XC_CL_CustomerInteraction_DeliveryEngagementEmail);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('orderId', wrapper.orderId);
        data.put('opportunityId', wrapper.opportunityId);
        data.put('quantity', wrapper.quantity);
        data.put('productId', wrapper.productId);
        data.put('fullName', wrapper.accountName);
        data.put('phone', wrapper.accountPhone);
        data.put('skipComunication', false);
        data.put('sent', false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        interactions.add(data);
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    }
    
}
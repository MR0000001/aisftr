/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 25/08/2021 
* @date Modification dd/mm/yyyy
* @description – public class with invocable method. It is invoked by the flow XC_FL_Provisioning_SendBookingNotification
*/
public without sharing class XC_IN080_SendBookingNotification {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN080_SendBookingNotification');

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
        public String stepId;
        public String accountId;
        public String contactId;
        public String email;
        public String preferredlanguage;
        public String orderId;
        public String opportunityId;
        public String catalog;
        public String channel;
        public String legalEntity;
        public String stream;
        public String source;
        public String serviceAppointmentId;
        public String workorderId;
    }
        /** 
     * @description Invocable method to launch the creation of a customer interaction
     * @param inputWrapperList
     */
    @InvocableMethod 
    public static void sendNotification(List<InputWrapper> inputWrapperList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN080_SendBookingNotification');
        createCustomerInteraction(getParentsInfo(inputWrapperList), inputWrapperList[0].stepId);
    }

    /**
     * @description Method to create a Customer Interaction record.
     * @param wrapper
     **/
    private static void createCustomerInteraction(UtilWrapper wrapper, String stepId) {
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c();
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        String communicationType = Label.XC_CL_CustomerInter_ComType_SAToBeBooked; 

        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', communicationType);
        data.put('email', wrapper.email);
        data.put('preferredlanguage', wrapper.preferredlanguage);
        data.put('accountId', wrapper.accountId);
        data.put('contactId', wrapper.contactId);
        data.put('opportunityId', wrapper.opportunityId);
        data.put('orderId', wrapper.orderId);
        data.put('serviceAppointmentId', wrapper.serviceAppointmentId);
        data.put('legalEntity', wrapper.legalEntity);
        data.put('segment', wrapper.stream);
        data.put('skipComunication', false);
        data.put('workorderId', wrapper.workorderId);
        data.put('sent', false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ data Map -->' + data);
        interactions.add(data);

        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
        if(wrapperResultList.isEmpty()){
            step = setStepStatus(false, stepId, 'The CI was not created');
        }
        if(wrapperResultList[0].success = true){
            step = setStepStatus(true, stepId, '');
        }  else {
            step = setStepStatus(false, stepId, wrapperResultList[0].errorMessage);
        }
        XC_UTIL_Sobject.updateRecord(step);
    }

    /**
     * @description Gets the info from step.
     * @param inputWrapperList the input wrapper list
     * @return 
     **/
    public static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList){
        UtilWrapper wrapper = new UtilWrapper();

        List<String> configurationIds = new List<String>(); 
        Map<Id, NE__OrderItem__c> configurationItemMap = new Map<Id, NE__OrderItem__c>();
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        } 
   
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>([SELECT XC_Configuration_Item__c, XC_ConfigurationId__c, XC_Configuration_Item__r.NE__OrderId__c
                                                                                            FROM XC_Provisioning_Step__c 
                                                                                            WHERE Id IN: listStepIds
                                                                                        ]);
        List< XC_Provisioning_Step__c> listSteps =  mapSteps.values();
        for(XC_Provisioning_Step__c step : listSteps){
            if(!String.isBlank(step.XC_Configuration_Item__r.NE__OrderId__c)){
                configurationIds.add(step.XC_Configuration_Item__r.NE__OrderId__c);
            }
        }
        
        Map<Id,WorkOrder> woMap = new Map<Id,WorkOrder>([SELECT Id, XC_Configuration__c, XC_Configuration_Item__c, XC_Opportunity__c,  XC_Configuration__r.CreatedBy.ContactId, XC_Configuration_Item__r.NE__ProdId__r.XC_LIC_Product_Name__c,
                                                            XC_Result__c, XC_MaxWallboxPower__c, XC_Configuration__r.CreatedBy.Contact.XC_Preferredlanguageofcontact__c, XC_Configuration__r.CreatedBy.AccountId, XC_Configuration__r.CreatedBy.Email,
                                                            XC_Configuration__r.XC_LegalEntity__c, XC_Configuration__r.CreatedBy.Contact.Email, XC_Configuration__r.XC_Segment__c, XC_Configuration__r.NE__OptyId__r.AccountId,
                                                            XC_Configuration__r.NE__OptyId__r.XC_Contact__c, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                                            (SELECT Id, XC_Result__c, XC_MaxWallboxPower__c FROM ServiceAppointments)  
                                                        FROM WorkOrder
                                                        WHERE XC_Configuration__c =: configurationIds 
                                                        AND (XC_WorkTypeCategory__c =:Label.XC_CL_WorkType_Diagnostic OR XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_DeliveryInstallation)]);

        if(!woMap.isEmpty()) {
            wrapper.accountId = woMap.values()[0].XC_Configuration__r.NE__OptyId__r.AccountId;
            wrapper.contactId = woMap.values()[0].XC_Configuration__r.NE__OptyId__r.XC_Contact__c;
            wrapper.email = woMap.values()[0].XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email;
            wrapper.preferredlanguage = XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage(woMap.values()[0].XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c);
            wrapper.orderId = woMap.values()[0].XC_Configuration__c;
            wrapper.opportunityId = woMap.values()[0].XC_Opportunity__c;
            if(!woMap.values()[0].ServiceAppointments.isEmpty()){
                wrapper.serviceAppointmentId = woMap.values()[0].ServiceAppointments[0].Id;
            }
            wrapper.workorderId = woMap.values()[0].Id;
            wrapper.legalEntity = woMap.values()[0].XC_Configuration__r.XC_LegalEntity__c;
            wrapper.stream = woMap.values()[0].XC_Configuration__r.XC_Segment__c;          
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapper.contactId -->' + wrapper.contactId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapper.accountId -->' + wrapper.accountId);
        return wrapper; 
    }

    /**
    * @description Method to set step status
    * @param success - Boolean
    * @param stepId - String
    * @param errorMessage - String
    * @return step
    **/
    private static XC_Provisioning_Step__c setStepStatus(Boolean success, String stepId, String errorMessage){
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id = stepId);
        if(!success){
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = errorMessage;
        }else {
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
        }
        return step;
    }
}
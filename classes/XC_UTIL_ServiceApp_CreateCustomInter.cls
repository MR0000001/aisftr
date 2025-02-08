/**
* @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation 23/11/2018
* @date Modification 09/01/2019
* @date Modification 06/05/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_UTIL_ServiceApp_CreateCustomInter – Util to create Customer Interaction records
*/

public without sharing class XC_UTIL_ServiceApp_CreateCustomInter {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ServiceApp_CreateCustomInter');

    /** @description CheckNotifyWrapper */
    public class CheckNotifyWrapper {
        public ServiceAppointment serApp;
        public List<XC_Customer_Interaction__c> customInterConsumerList = new List<XC_Customer_Interaction__c>();
        public List<XC_Customer_Interaction__c> customInterTechnicianList = new List<XC_Customer_Interaction__c>();
        public Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        public Map<Id, List<AssignedResource>> mapAssRes = new Map<Id, List<AssignedResource>>(); 
        public List<String> orderIdList = new List<String>();
    }

    /** @description PopulateCustomInterConsumerWrapper */
    @TestVisible private class PopulateCustomInterConsumerWrapper { 
        ServiceAppointment serApp;
        WorkOrder wo;
        String communicationType = '';
        List<XC_Customer_Interaction__c> customInterConsumerList = new List<XC_Customer_Interaction__c>();
        List<String> orderIdList = new List<String>();
    }

    /** @description PopulateCustomInterTechWrapper */
    /*private class PopulateCustomInterTechWrapper {
        ServiceAppointment serApp;
        WorkOrder wo;
        List<AssignedResource> arList = new List<AssignedResource>();
        String communicationType = '';
        List<XC_Customer_Interaction__c> customInterTechnicianList = new List<XC_Customer_Interaction__c>();
    }*/
    
    /**
     * @param checkNotifyWrapper - CheckNotifyWrapper
     * @description Method to populate the Customer Interaction List for Consumers
     */
    public static void checkNotify(CheckNotifyWrapper checkNotifyWrapper) {
        WorkOrder wo = checkNotifyWrapper.mapWorkOrder.get(checkNotifyWrapper.serApp.ParentRecordId);
        List<AssignedResource> ar;

        PopulateCustomInterConsumerWrapper populateWrapper = new PopulateCustomInterConsumerWrapper();
        populateWrapper.wo = wo;
        populateWrapper.customInterConsumerList = checkNotifyWrapper.customInterConsumerList;
       
        populateWrapper.serApp = checkNotifyWrapper.serApp;
        if (checkNotifyWrapper.serApp != NULL &&  populateServiceAppointment(populateWrapper, populateWrapper.serApp.XC_WorkTypeCategory__c)){
            checkNotifyWrapper.customInterConsumerList = populateWrapper.customInterConsumerList;
            return;
        }
        
        /* else if(XC_UTIL_ServiceApp_CustomInterCondition.checkInitial(checkNotifyWrapper.serApp)) { 
            if(XC_UTIL_ServiceApp_CustomInterCondition.checkCond1(wo)){
                populateWrapper.serApp = checkNotifyWrapper.serApp;
                populateWrapper.communicationType = 'ServiceAppointment_Scheduleded';
                populateCustomInterConsumerList(populateWrapper);   // Notification 4
                checkNotifyWrapper.customInterConsumerList = populateWrapper.customInterConsumerList;
            }  
        } else if (XC_UTIL_ServiceApp_CustomInterCondition.checkCond2(checkNotifyWrapper.serApp)) {
            populateWrapper.serApp = null;
            populateWrapper.communicationType = Label.XC_CL_CustomerInter_ComType_WO24BeforeInstallation;
            populateWrapper.orderIdList = checkNotifyWrapper.orderIdList;
            populateCustomInterConsumerListPlus(populateWrapper);  // NM LR - 05/12/2018 - ESCEP-101   Notification 17  
            checkNotifyWrapper.customInterConsumerList = populateWrapper.customInterConsumerList;
            checkNotifyWrapper.orderIdList = populateWrapper.orderIdList;
        } else if (checkNotifyWrapper.serApp.Status == Label.XC_CL_ServiceAppointment_Canceled) {
            populateWrapper.serApp = checkNotifyWrapper.serApp;
            populateWrapper.communicationType = 'ServiceAppointment_Cancelled';
            populateCustomInterConsumerList(populateWrapper);   // Notification 26
            checkNotifyWrapper.customInterConsumerList = populateWrapper.customInterConsumerList;
        } else if (XC_UTIL_ServiceApp_CustomInterCondition.checkCond3(checkNotifyWrapper.serApp)) {
            populateWrapper.communicationType = 'ServiceAppointment_Cancelled';
            populateWrapper.serApp = checkNotifyWrapper.serApp;
            populateCustomInterConsumerList(populateWrapper);   // Notification 26
            checkNotifyWrapper.customInterConsumerList = populateWrapper.customInterConsumerList;
            if(checkNotifyWrapper.mapAssRes.containsKey(checkNotifyWrapper.serApp.Id)) {
                ar = checkNotifyWrapper.mapAssRes.get(checkNotifyWrapper.serApp.Id);
                PopulateCustomInterTechWrapper populateWrapperTech = new PopulateCustomInterTechWrapper();
                populateWrapperTech.serApp = checkNotifyWrapper.serApp;
                populateWrapperTech.wo = wo;
                populateWrapperTech.arList = ar;
                populateWrapperTech.communicationType = Label.XC_CL_CustomerInter_ComType_SACancelledT;
                populateWrapperTech.customInterTechnicianList = checkNotifyWrapper.customInterTechnicianList;
                populateCustomInterTechnicianList(populateWrapperTech);   // Notification 26.1
                checkNotifyWrapper.customInterTechnicianList = populateWrapperTech.customInterTechnicianList;
            }
        } else if (XC_UTIL_ServiceApp_CustomInterCondition.checkCond4(checkNotifyWrapper.serApp)) {
            populateWrapper.communicationType = 'ServiceAppointment_Cancelled';
            populateWrapper.serApp = checkNotifyWrapper.serApp;
            populateCustomInterConsumerList(populateWrapper);   // Notification 26
            checkNotifyWrapper.customInterConsumerList = populateWrapper.customInterConsumerList;
            if(checkNotifyWrapper.mapAssRes.containsKey(checkNotifyWrapper.serApp.Id)) {
                ar = checkNotifyWrapper.mapAssRes.get(checkNotifyWrapper.serApp.Id);
                PopulateCustomInterTechWrapper populateWrapperTech = new PopulateCustomInterTechWrapper();
                populateWrapperTech.serApp = checkNotifyWrapper.serApp;
                populateWrapperTech.wo = wo;
                populateWrapperTech.arList = ar;
                populateWrapperTech.communicationType = Label.XC_CL_CustomerInter_ComType_SACancelledT;
                populateWrapperTech.customInterTechnicianList = checkNotifyWrapper.customInterTechnicianList;
                populateCustomInterTechnicianList(populateWrapperTech);   // Notification 26.1
                checkNotifyWrapper.customInterTechnicianList = populateWrapperTech.customInterTechnicianList;
            }
        }*/
    }

    /**
     * @param populateWrapper - PopulateCustomInterConsumerWrapper
     * @description Method to populate the Customer Interaction List for Consumers
     */
    /*private static void populateCustomInterConsumerList(PopulateCustomInterConsumerWrapper populateWrapper) {
        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
        cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
        cInteraction.XC_Channel__c = Label.XC_CL_CustomerInter_ChannelEmail;
        cInteraction.XC_SkipCommunication__c = false;
        cInteraction.XC_Communication_Type__c = populateWrapper.communicationType;
        

        if(populateWrapper.serApp != null) {
            cInteraction.XC_ServiceAppointmentId__c = populateWrapper.serApp.Id;    // not required for Notification 17
        }
        if(populateWrapper.communicationType != 'ServiceAppointment_Scheduleded') {
            cInteraction.XC_WorkOrderId__c = populateWrapper.wo.Id;     // not required for Notification 4
        } else {
            cInteraction.XC_LegalEntity__c = populateWrapper.wo.XC_LegalEntity__c;
            System.debug('**Tryn to set cInteraction.XC_LegalEntity__c = populateWrapper.wo.XC_LegalEntity__c');
        }
        if(!String.isBlank(populateWrapper.wo.XC_Opportunity__c)){
            cInteraction.XC_OpportunityId__c = populateWrapper.wo.XC_Opportunity__c;
        }
        if(!String.isBlank(populateWrapper.wo.Contact.Email)) {

            cInteraction.XC_ContactId__c = populateWrapper.wo.ContactId;
            cInteraction.XC_Recipient__c = populateWrapper.wo.Contact.Name;
            cInteraction.XC_Email__c = populateWrapper.wo.Contact.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = populateWrapper.wo.Contact.XC_Preferredlanguageofcontact__c; //ESCEP-1828 MCutillo 11/05/2019
            populateWrapper.customInterConsumerList.add(cInteraction);

        }else if(!String.isBlank(populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Email)) {

            cInteraction.XC_ContactId__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__c;
            cInteraction.XC_Recipient__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Name;
            cInteraction.XC_Email__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c; //ESCEP-1828 MCutillo 11/05/2019
            populateWrapper.customInterConsumerList.add(cInteraction);
        }

    }*/
    
    /**
     * @param populateWrapper - PopulateCustomInterConsumerWrapper
     * @description Method to populate the Customer Interaction List for Consumers
     */

    /*private static void populateCustomInterConsumerListPlus(PopulateCustomInterConsumerWrapper populateWrapper) {
        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
        cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
        cInteraction.XC_Channel__c = Label.XC_CL_CustomerInter_ChannelEmail;
        cInteraction.XC_SkipCommunication__c = false;
        cInteraction.XC_Communication_Type__c = populateWrapper.communicationType;
        
        if(populateWrapper.serApp != null) {
            cInteraction.XC_ServiceAppointmentId__c = populateWrapper.serApp.Id;    // not required for Notification 17
        }
        if(populateWrapper.communicationType != 'ServiceAppointment_Scheduleded') {
            cInteraction.XC_WorkOrderId__c = populateWrapper.wo.Id;     // not required for Notification 4
        } else {
            cInteraction.XC_LegalEntity__c = populateWrapper.wo.XC_LegalEntity__c;
            System.debug('**Tryn to set cInteraction.XC_LegalEntity__c = populateWrapper.wo.XC_LegalEntity__c');
        }
        if(!String.isBlank(populateWrapper.wo.XC_Opportunity__c)){
            cInteraction.XC_OpportunityId__c = populateWrapper.wo.XC_Opportunity__c;
        }
        if(!String.isBlank(populateWrapper.wo.Contact.Email)) {

            cInteraction.XC_ContactId__c = populateWrapper.wo.ContactId;
            cInteraction.XC_Recipient__c = populateWrapper.wo.Contact.Name;
            cInteraction.XC_Email__c = populateWrapper.wo.Contact.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = populateWrapper.wo.Contact.XC_Preferredlanguageofcontact__c; //ESCEP-1828 MCutillo 11/05/2019
            populateWrapper.customInterConsumerList.add(cInteraction);

        }else if(!String.isBlank(populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Email)) {

            cInteraction.XC_ContactId__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__c;
            cInteraction.XC_Recipient__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Name;
            cInteraction.XC_Email__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c; //ESCEP-1828 MCutillo 11/05/2019
            populateWrapper.customInterConsumerList.add(cInteraction);
        }
        XC_TR_ServiceApp_U_CreateCustomInter.checkServiceAppointmentChildrenOfWorkorder(populateWrapper.serApp, populateWrapper.wo, populateWrapper.customInterConsumerList);    // NM LR - 08/01/2019 - ESCEP-1044
                        
        // SS GS - 08/01/2019 - ESCEP-1041   Notification 11
        if(populateWrapper.wo.XC_Configuration__r.RecordType.DeveloperName == Label.XC_CL_Configuration_Order && populateWrapper.wo.XC_Configuration__r.XC_Status__c == Label.XC_CL_Configuration_OrderInProvisioning){
            if(populateWrapper.wo.XC_Provisioning_Step__r.XC_Flow_API_Name__c == Label.XC_CL_Provisioning_DeliveryInstallation){
                populateWrapper.orderIdList.add(populateWrapper.wo.XC_Configuration__c);
            }
        } 

    }*/
    
    /**
     * @param populateWrapper - PopulateCustomInterTechWrapper
     * @description Method to populate the Customer Interaction List for Technicians
     */
    /*@TestVisible
    private static void populateCustomInterTechnicianList(PopulateCustomInterTechWrapper populateWrapper) {
        XC_Customer_Interaction__c customInterTechnician;
        for(AssignedResource ar : populateWrapper.arList) {
            if(ar.ServiceResource.RelatedRecord.Email != null) {
                customInterTechnician = new XC_Customer_Interaction__c();
                customInterTechnician.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
                customInterTechnician.XC_Channel__c = Label.XC_CL_CustomerInter_ChannelEmail;
                customInterTechnician.XC_ServiceAppointmentId__c = populateWrapper.serApp.Id;
                customInterTechnician.XC_WorkOrderId__c = populateWrapper.wo.Id;
                customInterTechnician.XC_OpportunityId__c = populateWrapper.wo.XC_Opportunity__c;
                customInterTechnician.XC_SkipCommunication__c = false;
                customInterTechnician.XC_Communication_Type__c = populateWrapper.communicationType;
                customInterTechnician.XC_ContactId__c = ar.ServiceResource.RelatedRecord.ContactId;
                customInterTechnician.XC_Recipient__c = ar.ServiceResource.RelatedRecord.Contact.Name;
                customInterTechnician.XC_Email__c = ar.ServiceResource.RelatedRecord.Email;
                customInterTechnician.XC_Preferredlanguageofcontact__c = ar.ServiceResource.RelatedRecord.Contact.XC_Preferredlanguageofcontact__c;
                populateWrapper.customInterTechnicianList.add(customInterTechnician);
            }
        }
    }*/

    /**
    * @description method with new logic
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 15/10/2019 
    * @param populateWrapper 
    * @param workTypeName 
    * @return Boolean 
    **/
    private static Boolean populateServiceAppointment(PopulateCustomInterConsumerWrapper populateWrapper, String workTypeName) {
        
        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
        //populateRecipientAndName(populateWrapper, cInteraction);

        if(workTypeName == Label.XC_CL_WorkType_CommercialVisit){ 
            // opportuntity e lead non saranno mai popolati contemporaneamente
            cInteraction.XC_ContactId__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__c;
            cInteraction.XC_AccountId__c = populateWrapper.wo.XC_Opportunity__r.AccountId;

            cInteraction.XC_LeadId__c = populateWrapper.wo.XC_Lead__c;
        }

        if(!String.isBlank(cInteraction.XC_ContactId__c)){
            populateRecipientAndName(populateWrapper, cInteraction);
        }else if(!String.isBlank(cInteraction.XC_LeadId__c)){
            populateCustomerInterFromLead(populateWrapper, cInteraction);
        }else{
            cInteraction.XC_ContactId__c = populateWrapper.wo.ContactId;
            cInteraction.XC_AccountId__c = populateWrapper.wo.AccountId;
            populateRecipientAndName(populateWrapper, cInteraction);
        }
        
        //cInteraction.XC_ServiceAppIdEncrypt__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(populateWrapper.serApp.Id);
        cInteraction.XC_Communication_Type__c = populateWrapper.communicationType;
        
        Boolean flag = populateCommunicationType(populateWrapper, cInteraction);
        cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
        cInteraction.XC_SkipCommunication__c = false;
        
        if(populateWrapper.serApp != null) {
            cInteraction.XC_ServiceAppointmentId__c = populateWrapper.serApp.Id;
            cInteraction.XC_PhotoURL__c = populateWrapper.serApp.XC_AssignedResource__r.FSL__Picture_Link__c;
        }
        
        if(populateWrapper.wo != null){
            cInteraction.XC_WorkOrderId__c = populateWrapper.wo.Id;
            cInteraction.XC_LegalEntity__c = populateWrapper.wo.XC_LegalEntity__c; 
        }
        
        cInteraction.XC_Channel__c = !String.isBlank(cInteraction.XC_Email__c) ? Label.XC_CL_CustomerInter_ChannelEmail : Label.XC_CL_CustomerInter_ChannelSms;
        
        if (flag){
            populateWrapper.customInterConsumerList.add(cInteraction);
        }
        return flag;
    }

    private static Boolean populateCommunicationType(PopulateCustomInterConsumerWrapper populateWrapper, XC_Customer_Interaction__c cInteraction){
        if(XC_UTIL_ServiceApp_CustomInterCondition.checkSaScheduled(populateWrapper.wo, populateWrapper.serApp) && populateWrapper.serApp.XC_AssignedResource__c!=null) {
            cInteraction.XC_OpportunityId__c = populateWrapper.wo.XC_Opportunity__c;
            cInteraction.XC_Communication_Type__c = Label.XC_CL_CommType_ServiceAppointment_Scheduleded;
            return true;
        }else if (XC_UTIL_ServiceApp_CustomInterCondition.checkSaNotCompleted(populateWrapper.wo, populateWrapper.serApp)){
            cInteraction.XC_Communication_Type__c = Label.XC_CL_CommType_ServiceAppointment_NotCompleted;
            return true;
        }else if(XC_UTIL_ServiceApp_CustomInterCondition.checkSaCanceled(populateWrapper.wo, populateWrapper.serApp)){
            cInteraction.XC_Communication_Type__c = Label.XC_CL_CommType_ServiceAppointment_Canceled;
            return true;
        }
        return false;
    }

    private static void populateRecipientAndName(PopulateCustomInterConsumerWrapper populateWrapper, XC_Customer_Interaction__c cInteraction){
        if(!String.isBlank(populateWrapper.wo.Contact.Email)) {
            cInteraction.XC_Recipient__c = populateWrapper.wo.Contact.Name;
            cInteraction.XC_Email__c = populateWrapper.wo.Contact.Email;
        }else if(!String.isBlank(populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Email)) {
            cInteraction.XC_Recipient__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Name;
            cInteraction.XC_Email__c = populateWrapper.wo.XC_Opportunity__r.XC_Contact__r.Email;
        }
    }

    /**
    * @description method to populate customer interaction with lead information
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @param populateWrapper
    * @param cInteraction 
    **/
    public static void populateCustomerInterFromLead(PopulateCustomInterConsumerWrapper populateWrapper, XC_Customer_Interaction__c cInteraction){
        cInteraction.XC_Recipient__c =  populateWrapper.wo.XC_Lead__r.Name;
        cInteraction.XC_Email__c = populateWrapper.wo.XC_Lead__r.Email; 
        cInteraction.XC_Preferredlanguageofcontact__c  = populateWrapper.wo.XC_Lead__r.XC_Preference_Language__c;
        cInteraction.XC_LegalEntity__c = populateWrapper.wo.XC_Lead__r.XC_MainLegalEntity__c;
        //cInteraction.XC_LeadIdEncrypt__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(populateWrapper.wo.XC_Lead__c);
    }
}
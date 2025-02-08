/**
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 23/11/2018
 * @date Modification 09/01/2019
 * @description XC_TR_ServiceApp_U_CreateCustomInter – Util to create Customer Interaction records
 */

public without sharing class XC_TR_ServiceApp_U_CreateCustomInter {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceApp_U_CreateCustomInter');

    /** @description UtilWrapper */
    private class UtilWrapper {
        ServiceAppointment serAppNew;
        WorkOrder wo;
        List<XC_Customer_Interaction__c> customInterConsumerList = new List<XC_Customer_Interaction__c>();
        XC_Customer_Interaction__c cInteraction;
        Boolean check;
    }

    /**
    * @description After service appointment update.
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void afterServiceAppointmentUpdate(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew'+listNew);
        List<ServiceAppointment> listChanged = new List<ServiceAppointment>();
        for(ServiceAppointment sa : listNew) {
            if( mapOld.get(sa.Id).Status != mapNew.get(sa.Id).Status ||
                mapOld.get(sa.Id).SchedStartTime != mapNew.get(sa.Id).SchedStartTime ||
                mapOld.get(sa.Id).XC_StatusReason__c != mapNew.get(sa.Id).XC_StatusReason__c ||
                (String.isBlank(mapOld.get(sa.Id).XC_AssignedResource__c) && String.isNotBlank(mapNew.get(sa.Id).XC_AssignedResource__c))) {
                    listChanged.add(sa);
            }
        }
        if(!listChanged.isEmpty()) {
            createCIforStatusChange(listChanged);
        }
    }

    /**
    * @description Customer Interaction creation on after insert
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 23/9/2019
    * @param listNew the list new
    **/
    public static void afterInsertCICreation(List<ServiceAppointment> listNew){
        createCIforStatusChange(listNew);
    }

    /**
    * @param listNew the list new
    * @description : Method to create Customer Interaction when the Service Appointment Status changes
    */
    public static void createCIforStatusChange(List<ServiceAppointment> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew'+listNew);
        List<ServiceAppointment> serAppList = new List<ServiceAppointment>();

        Map<id,ServiceAppointment> mapSA = new Map<id,ServiceAppointment>([SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c
                                                                        FROM ServiceAppointment
                                                                        WHERE Id IN: listNew AND (Status=: Label.XC_CL_ServiceAppointment_Scheduled OR Status=: Label.XC_CL_ServiceAppointment_Canceled OR Status=: Label.XC_CL_ServiceAppointment_CannotComplete) ]);

        serAppList = mapSA.values();
        if(serAppList.isEmpty()) {
            return;
        }
        List<String> orderIdList = new List<String>();
        Map<Id, WorkOrder> mapWorkOrder = workOrderFromServiceAppointment(serAppList);

        Map<Id, List<AssignedResource> > mapAssRes = assignedResourceFromServiceAppointment(serAppList);

        List<XC_Customer_Interaction__c> customInterConsumerList = new List<XC_Customer_Interaction__c>();
        List<XC_Customer_Interaction__c> customInterTechnicianList = new List<XC_Customer_Interaction__c>();

        for(ServiceAppointment serApp : serAppList) {
            // if(XC_UTIL_ServiceApp_CustomInterCondition.checkParent(serApp)) {
            XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkNotifyWrapper = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
            checkNotifyWrapper.serApp = serApp;
            checkNotifyWrapper.customInterConsumerList = customInterConsumerList;
            checkNotifyWrapper.customInterTechnicianList = customInterTechnicianList;
            checkNotifyWrapper.mapWorkOrder = mapWorkOrder;
            checkNotifyWrapper.mapAssRes = mapAssRes;
            checkNotifyWrapper.orderIdList = orderIdList;
            XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkNotifyWrapper);
            orderIdList = checkNotifyWrapper.orderIdList;
            customInterTechnicianList = checkNotifyWrapper.customInterTechnicianList;
            customInterConsumerList = checkNotifyWrapper.customInterConsumerList;
            //}
        }

        customInterConsumerList.addAll(notificationForInstallation(orderIdList));
        customInterConsumerList.addAll(customIntertechnicianList);
        checkAndInsert(customInterConsumerList);
    }

    /**
    * @param customInterConsumerList the XC_Customer_Interaction__c list
    * @description : Method to check and insert
    */
    private static void checkAndInsert(List<XC_Customer_Interaction__c> customInterConsumerList){
        if(!customInterConsumerList.isEmpty()) {
            //XC_UTIL_CustomerInteractionGeneration.checkOpportunityIdNotBlank(customInterConsumerList); /*ESCEP-1839 MCutillo 10/05/2019*/
            XC_UTIL_Sobject.insertListRecords(customInterConsumerList);
        }
    }

    /**
    * @param serAppList the ser app list
    * @return the map
    * @description : Method to create a Map with WorkOrder Id as key and WorkOrder as value
    */
    private static Map<Id, WorkOrder> workOrderFromServiceAppointment(List<ServiceAppointment> serAppList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#serAppList'+serAppList);
        List<Id> idList = XC_UTIL_ServiceApp_CustomInterCondition.getWorkOrderIds(serAppList);
        Map<Id, WorkOrder> mapIdToWorkOrder = new Map<Id, WorkOrder>([
                                            SELECT Id, XC_StatusReason__c, Status, XC_Lead__c, ContactId, Contact.Name, Contact.Email, Contact.XC_Preferredlanguageofcontact__c, XC_Opportunity__c, XC_Opportunity__r.XC_Contact__c, XC_Opportunity__r.AccountId, XC_Opportunity__r.XC_Contact__r.Name, XC_Opportunity__r.XC_Contact__r.Email, XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, /*ESCEP-1828 MCutillo 11/05/2019*/
                                            XC_Provisioning_Step__r.XC_Flow_API_Name__c, XC_Configuration__c, XC_Configuration__r.RecordType.DeveloperName, XC_Configuration__r.XC_Status__c,// SS GS - 08/01/2019 - ESCEP-1041   Notification 11
                                            XC_Configuration__r.NE__OptyId__r.XC_Contact__c, XC_LegalEntity__c, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c, (SELECT Id, Status FROM ServiceAppointments), // NM LR - 08/01/2019 - ESCEP-1044
                                            AccountId, Account.XC_RecordTypeDeveloperName__c, Account.XC_LeadId__c, Account.XC_LeadId__r.Name, Account.XC_LeadId__r.Email, // NM LR - 10/01/2019 - Notification 4.1
                                            XC_Lead__r.Name, XC_Lead__r.Email, XC_Lead__r.XC_Preference_Language__c, XC_Lead__r.XC_MainLegalEntity__c
                                            FROM WorkOrder
                                            WHERE Id IN: idList]);

        return mapIdToWorkOrder;
    }

    /**
    * @param serAppList the ser app list
    * @return the map
    * @description : Method to create a Map with Service Appointment Id as key and its related Assigned Resource List as value
    */
    private static Map<Id, List<AssignedResource> > assignedResourceFromServiceAppointment(List<ServiceAppointment> serAppList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#serAppList'+serAppList);
        List<Id> idList = XC_UTIL_Sobject.getIds(serAppList);
        List<AssignedResource> listResource = new List<AssignedResource>();
        if(Schema.sObjectType.AssignedResource.isAccessible() && Schema.sObjectType.AssignedResource.fields.Id.isAccessible() && Schema.sObjectType.AssignedResource.fields.ServiceAppointmentId.isAccessible() && Schema.sObjectType.AssignedResource.fields.ServiceResourceId.isAccessible()) {
            listResource = [SELECT Id, ServiceAppointment.Id, ServiceResource.ResourceType, ServiceResource.RelatedRecord.Name, ServiceResource.RelatedRecord.Email, ServiceResource.RelatedRecord.ContactId, ServiceResource.RelatedRecord.Contact.Name, ServiceResource.RelatedRecord.Contact.XC_Preferredlanguageofcontact__c
                            FROM AssignedResource
                            WHERE ServiceAppointment.Id IN :idList];
        }
        Map<Id, List<AssignedResource> > mapIdToAssignedResources = new Map<Id, List<AssignedResource> >();
        List<AssignedResource> assResources;
        for(ServiceAppointment serApp : serAppList) {
            assResources = new List<AssignedResource>();
            for(AssignedResource assRes : listResource) {
                if(assRes.ServiceAppointment.Id == serApp.Id) {
                    assResources.add(assRes);
                }
            }
            mapIdToAssignedResources.put(serApp.Id, assResources);
        }

        return mapIdToAssignedResources;
    }

    /**
    * @description : Method to avoid the nested if-else statement
    * @param wrapper
    */
    /*private static void cycleOnServiceAppointments(UtilWrapper wrapper){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#wrapper'+wrapper);
        ServiceAppointment serAppNew = wrapper.serAppNew;
        WorkOrder wo = wrapper.wo;
        List<XC_Customer_Interaction__c> customInterConsumerList = wrapper.customInterConsumerList;
        XC_Customer_Interaction__c cInteraction = wrapper.cInteraction;
        Boolean check = wrapper.check;

        for(ServiceAppointment serApp : wo.ServiceAppointments) {
            if(!check && !String.isBlank(wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email) && (serApp.Status == Label.XC_CL_ServiceAppointment_Canceled || serApp.Status == Label.XC_CL_ServiceAppointment_CannotComplete)) {
                check = true;

                cInteraction = new XC_Customer_Interaction__c(); //  Notification 16
                cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
                cInteraction.XC_Channel__c = Label.XC_CL_CustomerInter_ChannelEmail;
                cInteraction.XC_SkipCommunication__c = false;
                cInteraction.XC_Communication_Type__c = Label.XC_CL_CustomerInter_ComType_SARescheduled;
                cInteraction.XC_OrderId__c = wo.XC_Configuration__c;
                cInteraction.XC_ContactId__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__c;
                cInteraction.XC_Recipient__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name;
                cInteraction.XC_Email__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email;
                cInteraction.XC_Preferredlanguageofcontact__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c; /*ESCEP-1828 MCutillo 11/05/2019
                cInteraction.XC_ServiceAppointmentId__c = serAppNew.Id;

                if(!String.isBlank(wo.XC_Configuration__r.NE__OptyId__c)) { // Marketing Cloud opportunityID required issue
                    cInteraction.XC_OpportunityId__c = wo.XC_Configuration__r.NE__OptyId__c;
                }else if(!String.isBlank(wo.XC_Opportunity__c)) {
                    cInteraction.XC_OpportunityId__c = wo.XC_Opportunity__c;
                }
                customInterConsumerList.add(cInteraction);
            }
        }
    }*/

    /**
    * @param serAppNew the ser app new
    * @param wo the wo
    * @param customInterConsumerList the custom inter consumer list
    * @description : Method to check if the WorkOrder has at least a Service appointment with Canceled or Cannot Complete Status.
    *                In this case, it creates a Customer Interaction in according to Notification 16
    */

    /*public static void checkServiceAppointmentChildrenOfWorkorder(ServiceAppointment serAppNew, WorkOrder wo, List<XC_Customer_Interaction__c> customInterConsumerList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#serAppNew'+serAppNew);
        Boolean check = false;
        XC_Customer_Interaction__c cInteraction;
        if(wo.ServiceAppointments.size() > 1) {
            UtilWrapper wrapper = new UtilWrapper();
            wrapper.serAppNew = serAppNew;
            wrapper.wo = wo;
            wrapper.customInterConsumerList = customInterConsumerList;
            wrapper.cInteraction = cInteraction;
            wrapper.check = check;
            cycleOnServiceAppointments(wrapper);
        }
    }*/

    /**
    * Notification for installation.
    *
    * @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param orderIdList the order id list
    * @return the list
    * @description Method to create Notification 11 if all installation service appointment of an order are scheduled
    */
    public static List<XC_Customer_Interaction__c> notificationForInstallation(List<String> orderIdList){     //  Notification 11 /*ESCEP-1828 MCutillo 11/05/2019*/
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#orderIdList'+orderIdList);
        List<XC_Customer_Interaction__c> customInterList = new List<XC_Customer_Interaction__c>();
        Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>([
                                    SELECT Id, XC_Configuration__c, XC_Configuration__r.NE__OptyId__r.XC_Contact__c,
                                    XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                    XC_Configuration__r.NE__OptyId__c,AccountId,
                                    (SELECT Id,Status FROM ServiceAppointments)
                                    FROM WorkOrder
                                    WHERE XC_Configuration__c IN: orderIdList
                                    AND XC_Provisioning_Step__r.XC_Flow_API_Name__c =: Label.XC_CL_Provisioning_DeliveryInstallation
                                                        ]);
        List<WorkOrder> listWO = mapWO.values();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listWO'+listWO);
        Map<Id, List<ServiceAppointment> > mapOrderIdListServiceAppointment = new Map<Id, List<ServiceAppointment> >();
        Map<Id, WorkOrder> mapOrderIdWorkOrder = new Map<Id, WorkOrder>();
        for(WorkOrder wo : listWO) {
            if(!mapOrderIdListServiceAppointment.containsKey(wo.XC_Configuration__c)) {
                mapOrderIdListServiceAppointment.put(wo.XC_Configuration__c, new List<ServiceAppointment>());
            }
            if(!mapOrderIdWorkOrder.containsKey(wo.XC_Configuration__c)) {
                mapOrderIdWorkOrder.put(wo.XC_Configuration__c, wo);
            }
            List<ServiceAppointment> listSA = wo.ServiceAppointments;
            mapOrderIdListServiceAppointment.get(wo.XC_Configuration__c).addAll(listSA);
        }

        for(Id orderId : mapOrderIdListServiceAppointment.keySet()) {
            customInterList = createCustomInterList(orderId,mapOrderIdListServiceAppointment,mapOrderIdWorkOrder);
        }
        return customInterList;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param orderId the order id list
    * @param mapOrderIdListServiceAppointment the map
    * @param mapOrderIdWorkOrder the map
    * @return the list
    * @description Method to create Notification 11 if all installation service appointment of an order are scheduled
    */
    public static List<XC_Customer_Interaction__c> createCustomInterList(Id orderId,Map<Id, List<ServiceAppointment> > mapOrderIdListServiceAppointment, Map<Id, WorkOrder> mapOrderIdWorkOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#orderId'+orderId);
        List<XC_Customer_Interaction__c> customInterList = new List<XC_Customer_Interaction__c>();
        List<ServiceAppointment> listSa = mapOrderIdListServiceAppointment.get(orderId);
        Boolean toSendCustomerInt = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#toSendCustomerInt'+toSendCustomerInt);
        if(listSa.isEmpty()) {
            toSendCustomerInt = false;
        }
        for(ServiceAppointment sa : listSa) {
            if(sa.Status == Label.XC_CL_ServiceAppointment_None || sa.Status == Label.XC_CL_ServiceAppointment_Canceled) {
                toSendCustomerInt = false;
                break;
            }
        }
        if(toSendCustomerInt) {
            WorkOrder wo = mapOrderIdWorkOrder.get(orderId);
            XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();   //  Notification 11
            cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
            cInteraction.XC_Channel__c = Label.XC_CL_CustomerInter_ChannelEmail;
            cInteraction.XC_SkipCommunication__c = false;
            cInteraction.XC_Communication_Type__c = Label.XC_CL_CustomerInter_ComType_OrderAllInstallationSACreatedEmail;
            cInteraction.XC_OrderId__c = orderId;
            cInteraction.XC_AccountId__c = wo.AccountId;
            cInteraction.XC_ContactId__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__c;
            cInteraction.XC_Recipient__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name;
            cInteraction.XC_Email__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = wo.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c; /*ESCEP-1828 MCutillo 11/05/2019*/
            cInteraction.XC_OpportunityId__c = wo.XC_Configuration__r.NE__OptyId__c;
            customInterList.add(cInteraction);
        }
        return customInterList;
    }

}
/**
 * The Class XC_TR_WorkOrder_U_CreateCustomInter.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 05/12/2018
 * @date Modification : 09/01/2019
 * @description       : XC_TR_WorkOrder_U_CreateCustomInter – Util to create Customer Interaction records
 **/

public without sharing class XC_TR_WorkOrder_U_CreateCustomInter {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CreateCustomInter'); 

    /**
     * @description After work order update.
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void afterWorkOrderUpdate(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {
        List<String> fieldListStatusAndReason = new List<String>{'Status', 'XC_StatusReason__c', 'XC_MissingQuoteReason__c'};
        List<WorkOrder> listChangedStatusAndReasonAll = XC_UTIL_Sobject.getListChanged(fieldListStatusAndReason, mapOld, mapNew);
        if(!listChangedStatusAndReasonAll.isEmpty()){
            if(System.isBatch()) {
                createCustomerInteractions(listNew, mapOld, mapNew);
            } else {
                System.enqueueJob(new CreateCustomerInteractionQueueableWo (listNew, mapOld, mapNew));
            }
        }
        
    }

    private static List<WorkOrder> getlistChangedStatus(List<WorkOrder> listChanged){
        List<WorkOrder> woList = new List<WorkOrder>();
        for (WorkOrder wo : listChanged) {
            if(wo.Status == Label.XC_CL_WorkOrder_Completed && 
                (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation)){
                    woList.add(wo);
            }
        }
        return woList;
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 20/11/2019 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    **/
    private static void createCustomerInteractions(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew){
        List<String> fieldListStatusAndReason = new List<String>{'Status', 'XC_StatusReason__c'};
        List<WorkOrder> listChangedStatusAndReasonAll = XC_UTIL_Sobject.getListChanged(fieldListStatusAndReason, mapOld, mapNew);

        List<String> fieldListStatus = new List<String>{'Status'};
        List<WorkOrder> listChangedStatusAll = XC_UTIL_Sobject.getListChanged(fieldListStatus, mapOld, mapNew);
        List<WorkOrder> listChangedStatusCompleteCV = getListChangedStatusCompl(listChangedStatusAll);

        List<WorkOrder> listChangedStatusComplete = getlistChangedStatus(listChangedStatusAll);

        List<WorkOrder> listChangedStatus = getListChangedStatusAndReason(listChangedStatusAndReasonAll);

        List<String> fieldListMissingQuoteReason = new List<String>{'XC_MissingQuoteReason__c'};
        List<WorkOrder> listChangedMissingQuoteReason = XC_UTIL_Sobject.getListChanged(fieldListMissingQuoteReason, mapOld, mapNew);

        Map<Id, WorkOrder> allChangedWoMap;
        List<XC_Customer_Interaction__c> ciToInsert = new List<XC_Customer_Interaction__c>();
        if(!listChangedStatus.isEmpty() || !listChangedStatusCompleteCV.isEmpty() || !listChangedStatusComplete.isEmpty() || !listChangedMissingQuoteReason.isEmpty()){
            List<WorkOrder> allChangedWo = new List<WorkOrder>();
            allChangedWo.addAll(listChangedStatus);
            allChangedWo.addAll(listChangedStatusCompleteCV);
            allChangedWo.addAll(listChangedStatusComplete);
            allChangedWo.addAll(listChangedMissingQuoteReason);
            allChangedWoMap = getWoMap(allChangedWo);
        }

        List<WorkOrder> listOfAllWo = new List<WorkOrder>();
        listOfAllWo.addAll(listChangedStatusCompleteCV);
        Map<Id, List<NE__Order__c>> quotesMap = getQuotesMap(listOfAllWo, allChangedWoMap);
        if(!listChangedStatus.isEmpty()) {
            ciToInsert.addAll(createCutomerInteractionCustomerUnreachable(listChangedStatus, allChangedWoMap));
        }
        if(!listChangedStatusCompleteCV.isEmpty()){
            ciToInsert.addAll(createCutomerInteractionCommercialVisit(listChangedStatusCompleteCV, allChangedWoMap, quotesMap));
        }

        if(!listChangedStatusComplete.isEmpty()){
            ciToInsert.addAll(createCIforStatusChange(listChangedStatusComplete, allChangedWoMap));
        }
        
        if(!listChangedMissingQuoteReason.isEmpty()){
            createCIforMissingQuoteReasonFilled(listChangedMissingQuoteReason, mapOld, allChangedWoMap);
        }

        XC_UTIL_Sobject.insertListRecords(ciToInsert);
    }

    private static List<WorkOrder> getListChangedStatusAndReason(List<WorkOrder> listChangedStatusAll){
        List<WorkOrder> listChangedStatus = new List<WorkOrder>();
        List<String> wtAccepted = new List<String>{Label.XC_CL_WorkType_Diagnostic, Label.XC_CL_WorkType_SiteInspection, Label.XC_CL_WorkType_QualityCheckInspection, Label.XC_CL_WorkType_Return, Label.XC_CL_WorkType_CommercialVisit};
        for (WorkOrder wo : listChangedStatusAll) {
            if(wo.XC_StatusReason__c == Label.XC_CL_StatusReason_Customernotlocated){
                if((wtAccepted.contains(wo.XC_WorkTypeCategory__c) && wo.Status == Label.XC_CL_Cancelled) ||
                    (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.Status == Label.XC_CL_New) ||
                    (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance && wo.Status == Label.XC_CL_CustomerInteraction_Assigned) ){
                        listChangedStatus.add(wo);
                    }
            }
        }
        return listChangedStatus;
    }

    private static List<WorkOrder> getListChangedStatusCompl(List<WorkOrder> listChangedStatus){
        List<WorkOrder> listChangedStatusCompl = new List<WorkOrder>();
        for (WorkOrder wo : listChangedStatus) {
            if(wo.Status == Label.XC_CL_WorkOrder_Completed && wo.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit){               
                listChangedStatusCompl.add(wo);
            }
        }
        return listChangedStatusCompl;
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 3/12/2019 
    * @param allChangedWo 
    * @return Map<Id, WorkOrder> 
    **/
    public static Map<Id, WorkOrder> getWoMap(List<WorkOrder> allChangedWo){
        return new Map<Id, WorkOrder>([SELECT Id, XC_CongaDynamicAPI__c, XC_Check_Final_Status__c, XC_StatusReason__c, ContactId, Contact.Name, AccountId, XC_WorkTypeCategory__c, Contact.Email, XC_LegalEntity__c, XC_Opportunity__r.XC_Contact__c, XC_Opportunity__r.AccountId,
                                                            XC_Lead__c, XC_Opportunity__c, XC_Opportunity__r.XC_Contact__r.Name, XC_Opportunity__r.XC_Contact__r.Email, 
                                                            XC_Lead__r.XC_MainLegalEntity__c, XC_Lead__r.Email, XC_Lead__r.Name, WorkType.Name, Contact.XC_Preferredlanguageofcontact__c, XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                                            XC_Configuration__c, XC_Configuration__r.NE__OptyId__c,
                                                            XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email, XC_Configuration__r.NE__OptyId__r.XC_Contact__c,
                                                            XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name, XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                                            Contact.Phone, Contact.XC_PhonePrefix__c, Contact.XC_ContactPhone__c,       
                                                            Contact.MobilePhone, Contact.XC_MobilePrefix__c, Contact.XC_ContactMobile__c, XC_Opportunity__r.XC_LegalEntity__c,
                                                                (SELECT ID, XC_StatusReason__c, Status, XC_AssignedResource__r.FSL__Picture_Link__c FROM ServiceAppointments order by CreatedDate desc)
                                                            FROM WorkOrder                                                                                                                                  
                                                            WHERE Id IN: allChangedWo]);
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 3/12/2019 
    * @param woList 
    * @param allChangedWoMap 
    * @param quotesMap 
    * @return List<XC_Customer_Interaction__c> 
    **/
    public static List<XC_Customer_Interaction__c> createCutomerInteractionCustomerActivityReport(List<WorkOrder> woList, Map<Id, WorkOrder> allChangedWoMap,  Map<Id, List<NE__Order__c>> quotesMap){
        List<XC_Customer_Interaction__c> ciToInsert = new List<XC_Customer_Interaction__c>();
        if(!woList.isEmpty()){
            for (WorkOrder woFromList : woList) {
                WorkOrder wo = allChangedWoMap.get(woFromList.Id);
                if(!String.isBlank(wo.XC_CongaDynamicAPI__c)){
                    ServiceAppointment serApp = wo.ServiceAppointments.isEmpty() ? NULL : wo.ServiceAppointments[0];
                    XC_Customer_Interaction__c ci = XC_UTIL_CustomerInteractionGeneration_U.getWorkOrderActivityReportCI(wo, serApp, quotesMap);
                    ciToInsert.add(ci);
                }
            }
        }
        
        return ciToInsert;
    }

    private static List<XC_Customer_Interaction__c> createCutomerInteractionCustomerUnreachable(List<WorkOrder> woList, Map<Id, WorkOrder> allChangedWoMap){
        List<XC_Customer_Interaction__c> ciToInsert = new List<XC_Customer_Interaction__c>();
        for (WorkOrder woFromList : woList) {
            WorkOrder wo = allChangedWoMap.get(woFromList.Id);
            if(!wo.ServiceAppointments.isEmpty()){
                ServiceAppointment serApp;
                if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){
                    serApp = getSerApp(wo.ServiceAppointments, 'None');
                    ciToInsert.add(XC_UTIL_CustomerInteractionGeneration_U.getCustomerUnreachableCI(wo, serApp));
                }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
                    serApp = getSerApp(wo.ServiceAppointments, 'Scheduled');
                    ciToInsert.add(XC_UTIL_CustomerInteractionGeneration_U.getCustomerUnreachableCI(wo, serApp));
                }
            }else {
                List<String> wtAccepted = new List<String>{Label.XC_CL_WorkType_Diagnostic, Label.XC_CL_WorkType_SiteInspection, Label.XC_CL_WorkType_QualityCheckInspection, Label.XC_CL_WorkType_Return, Label.XC_CL_WorkType_CommercialVisit};
                if(wtAccepted.contains(wo.XC_WorkTypeCategory__c)){
                    ciToInsert.add(XC_UTIL_CustomerInteractionGeneration_U.getCustomerUnreachableCI(wo, NULL));
                }
            }            
        }

        return ciToInsert;
    }

    private static ServiceAppointment getSerApp(List<ServiceAppointment> serAppList, String status){
        for (ServiceAppointment serApp : serAppList) {
            if(serApp.Status == status){
                return serApp;
            }
        }
        return NULL;
    }

    /**
     * CreateCIforStatusChange.
     *
     * @param listNew the list new
     * @description Method to create Customer Interactions when the Status of Repair, Installation or Delivery&Installation WorkOrders changes in Completed
     */
    @TestVisible
    private static List<XC_Customer_Interaction__c> createCIforStatusChange(List<WorkOrder> listNew, Map<Id, WorkOrder> allChangedWoMap) {

        System.debug('@@@In create Customer Interaction for Workorder Status Change');
        List<XC_Customer_Interaction__c> customInterList = new List<XC_Customer_Interaction__c>();

        //for (WorkOrder wo : mapWorkOrder.values()) {
        for (WorkOrder woFromList : listNew) {
            WorkOrder wo = allChangedWoMap.get(woFromList.Id);
            populateCustomInterList(wo, Label.XC_CL_CustomerInter_ComType_WOInstallationCompleted, customInterList);    // Notification 20
        }

        return customInterList;
    }


    /**
     * PopulateCustomInterList:
     *
     * @param workOr the work or
     * @param communicationType the communication type
     * @param customInterList the custom inter list
     * @description : Method to populate the Customer Interaction List
     */
    @TestVisible
    private static void populateCustomInterList(WorkOrder workOr, String communicationType, List<XC_Customer_Interaction__c> customInterList) {

        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();

        cInteraction.XC_WorkOrderId__c = workOr.Id;
        cInteraction.XC_SkipCommunication__c = false;
        cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
        cInteraction.XC_Channel__c = Label.XC_CL_CustomerInter_ChannelEmail;
        cInteraction.XC_Communication_Type__c = communicationType;
        
        if(communicationType == Label.XC_CL_CustomerInter_ComType_InstallationNeeded) {  // Notification 15
            cInteraction.XC_OrderId__c = workOr.XC_Configuration__c;
        }

        if(!String.isBlank(workOr.XC_Opportunity__c)) {         // Marketing Cloud opportunityID required issue
            cInteraction.XC_OpportunityId__c = workOr.XC_Opportunity__c;   
        } else if(!String.isBlank(workOr.XC_Configuration__r.NE__OptyId__c)) {
            cInteraction.XC_OpportunityId__c = workOr.XC_Configuration__r.NE__OptyId__c;
        }

        if(!String.isBlank(workOr.Contact.Email)) {
            cInteraction.XC_ContactId__c = workOr.ContactId;
            cInteraction.XC_Recipient__c = workOr.Contact.Name;
            cInteraction.XC_Email__c = workOr.Contact.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = workOr.Contact.XC_Preferredlanguageofcontact__c;
            customInterList.add(cInteraction);
        } else if (!String.isBlank(workOr.XC_Opportunity__r.XC_Contact__r.Email)) {
            cInteraction.XC_ContactId__c = workOr.XC_Opportunity__r.XC_Contact__c;
            cInteraction.XC_Recipient__c = workOr.XC_Opportunity__r.XC_Contact__r.Name;
            cInteraction.XC_Email__c = workOr.XC_Opportunity__r.XC_Contact__r.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = workOr.XC_Opportunity__r.XC_Contact__r.XC_Preferredlanguageofcontact__c;
            customInterList.add(cInteraction);
        } else if (!String.isBlank(workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email)) {
            cInteraction.XC_ContactId__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__c;
            cInteraction.XC_Recipient__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Name;
            cInteraction.XC_Email__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.Email;
            cInteraction.XC_Preferredlanguageofcontact__c = workOr.XC_Configuration__r.NE__OptyId__r.XC_Contact__r.XC_Preferredlanguageofcontact__c;
            customInterList.add(cInteraction);
        }
    }

    private static void createCIforMissingQuoteReasonFilled(List<WorkOrder> listChanged, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> woMap){
        Set<Id> woid = XC_UTIL_Sobject.getSetIds(listChanged);
        Map<Id,ServiceAppointment> saMap = XC_UTIL_ServiceAppointment.getDataActiveSAFromWo(woid);
        
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        for(WorkOrder wo : listChanged) {
            if(String.isBlank(mapOld.get(wo.Id).XC_MissingQuoteReason__c)) {
                System.debug('****if isblank'); 
                Map<String,Object> woInfo = new Map<String,Object>();
                woInfo.put('customerType', 'WorkOrder_QuoteNotCreated');
                woInfo.put('workorderId', wo.Id);
                woInfo.put('opportunityId', wo.XC_Opportunity__c);
                woInfo.put('contactId', wo.ContactId);
                woInfo.put('fullName', woMap.get(wo.Id).Contact.Name);
                woInfo.put('preferredlanguage', woMap.get(wo.Id).Contact.XC_Preferredlanguageofcontact__c);
                woInfo.put('skipComunication', false);
                woInfo.put('sent', false);
                woInfo.put('legalEntity', woMap.get(wo.Id).XC_Opportunity__r.XC_LegalEntity__c);
                woInfo.put('SurveyId', 'S11.3');
                if(saMap.get(wo.id) != null){
                	woInfo.put('serviceAppointmentId', saMap.get(wo.id).id);
                }

                if(String.isNotBlank(woMap.get(wo.Id).Contact.Email)) {
                    woInfo.put('email', woMap.get(wo.Id).Contact.Email);
                } else if(checkPrimaryPhone(woMap.get(wo.Id))) {
                    woInfo.put('phone', woMap.get(wo.Id).Contact.Phone);
                } else if(checkSecondaryPhone(woMap.get(wo.Id))) {
                    woInfo.put('phone', woMap.get(wo.Id).Contact.MobilePhone);
                } else {
                    System.debug('IN createCIforMissingQuoteReasonFilled the contact with ID ' + woMap.get(wo.Id).ContactId + ' has not an email ad a valid phone');
                    return;
                }

                interactions.add(woInfo);
            }
        }

        if(!interactions.isEmpty()){
			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromLead(interactions);
			XC_UTIL_Sobject.WrapperResult globalDMLResult = XC_UTIL_Sobject.getGlobalDMLResults(results);
			XC_UTIL_Debug.debug(true, 'globalDMLResult = ' + globalDMLResult);
		}
    }


    /**
	 * CheckPrimaryPhone.
	 *
	 * @author Nicola Mariniello - nmariniello@deloitte.it
	 * @date Creation 18/07/2019
	 * @param wo the workorder
	 * @return the result oh check
	 * @description check the format of Primary Phone of Contact
	 */
    @TestVisible
    private static Boolean checkPrimaryPhone(WorkOrder wo) {
		if(String.isNotBlank(wo.Contact.Phone) && (wo.Contact.XC_PhonePrefix__c != '+34' || (wo.Contact.XC_PhonePrefix__c == '+34' && (String.valueOf(wo.Contact.XC_ContactPhone__c).substring(0,1) == '6' || String.valueOf(wo.Contact.XC_ContactPhone__c).substring(0,1) == '7')))) {
			return true;
		} else {
			return false;
		}
	}


	/**
	 * CheckSecondaryPhone.
	 *
	 * @author Nicola Mariniello - nmariniello@deloitte.it
	 * @date Creation 18/07/2019
	 * @param wo the workorder
	 * @return the result of check
	 * @description check the format of Secondary Phone of Contact
	 */
    @TestVisible
    private static Boolean checkSecondaryPhone(WorkOrder wo) {
		if(String.isNotBlank(wo.Contact.MobilePhone) && (wo.Contact.XC_MobilePrefix__c != '+34' || (wo.Contact.XC_MobilePrefix__c == '+34' && (String.valueOf(wo.Contact.XC_ContactMobile__c).substring(0,1) == '6' || String.valueOf(wo.Contact.XC_ContactMobile__c).substring(0,1) == '7')))) {
			return true;
		} else {
			return false;
		}
	}


    /**
    * @description 
    **/
    public class CreateCustomerInteractionQueueableWo implements Queueable{
        List<WorkOrder> listNew;
        Map<Id, WorkOrder> mapOld;
        Map<Id, WorkOrder> mapNew;

        public CreateCustomerInteractionQueueableWo(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew){
            this.listNew = listNew;
            this.mapOld = mapOld;
            this.mapNew = mapNew;
        }
        
        public void execute(QueueableContext context) {
            createCustomerInteractions(listNew, mapOld, mapNew);
        }
    }

    /**
    * @description 
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 3/12/2019 
    * @param woList 
    * @param allChangedWoMap 
    * @return Map<Id, List<NE__Order__c>> 
    **/
    public static Map<Id, List<NE__Order__c>> getQuotesMap (List<WorkOrder> woList, Map<Id, WorkOrder> allChangedWoMap){
         Map<Id, List<NE__Order__c>> quotesMap = new Map<Id, List<NE__Order__c>>();
        if(woList.isEmpty()){
            return quotesMap;
        }
        List<String> opportunityIds = XC_UTIL_Sobject.getListFieldValues(woList, 'XC_Opportunity__c');
        Id orderRTId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        List<NE__Order__c> quotesList = new List<NE__Order__c>([SELECT ID, XC_Status__c, NE__OptyId__c 
                                                                FROM NE__Order__c 
                                                                WHERE NE__OptyId__c IN :opportunityIds AND RecordTypeId = :orderRTId]);
        Map<Id, List<NE__Order__c>> oppIdquotesMap = new Map<Id, List<NE__Order__c>>();
        for (NE__Order__c q : quotesList) {
            if(!oppIdquotesMap.containsKey(q.NE__OptyId__c)){
                oppIdquotesMap.put(q.NE__OptyId__c, new List<NE__Order__c>{q});
            }else {
                oppIdquotesMap.get(q.NE__OptyId__c).add(q);
            }
        }

        for (WorkOrder woFromList : woList) {
            WorkOrder wo = allChangedWoMap.get(woFromList.Id);
            quotesMap.put(wo.Id, oppIdquotesMap.get(wo.XC_Opportunity__c));
        }
        return quotesMap;
    }

    private static List<XC_Customer_Interaction__c> createCutomerInteractionCommercialVisit(List<WorkOrder> woList, Map<Id, WorkOrder> allChangedWoMap,  Map<Id, List<NE__Order__c>> quotesMap){
        List<XC_Customer_Interaction__c> ciToInsert = new List<XC_Customer_Interaction__c>();
        for (WorkOrder woFromList : woList) {
            WorkOrder wo = allChangedWoMap.get(woFromList.Id);
            ServiceAppointment serApp = wo.ServiceAppointments.isEmpty() ? NULL : wo.ServiceAppointments[0];
            XC_Customer_Interaction__c ci = XC_UTIL_CustomerInteractionGeneration_U.populateCICommercialVisit(wo, serApp, quotesMap);
            ciToInsert.add(ci);
        }        
        return ciToInsert;
    } 

}
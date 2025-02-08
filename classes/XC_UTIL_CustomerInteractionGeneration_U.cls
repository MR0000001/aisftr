/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Monica Cutillo - monica.cutillo@nttdata.com
*         Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 19/04/2019
* @date Modification 26/06/2019 by Nicola Mariniello nmariniello@deloitte.it
* @description XC_UTIL_CustomerInteractionGeneration_U – Class for XC_UTIL_CustomerInteractionGeneration
*/

public without sharing class XC_UTIL_CustomerInteractionGeneration_U { 

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_CustomerInteractionGeneration_U');

    /** 
    * @description Populate CCI
    * @author MCutillo - LOrlanducci
    * @date 30/11/2018 - ESCEP-154, ESCEP-528
    * @param emailMap
    * @return XC_Customer_Interaction__c
    **/
    public static XC_Customer_Interaction__c populateCoreCustomerInteration(Map<String,Object> emailMap){
        XC_UTIL_Debug.debug(true, 'enter in XC_UTIL_CustomerInteractionGeneration.populateCoreCustomerInteration');  
        XC_Customer_Interaction__c cInteraction = populateCoreCustomerInterationIDs(emailMap);
        cInteraction.XC_Sent__c = (emailMap.get('sent')!=null) ? (Boolean)emailMap.get('sent') : false;   
        cInteraction.XC_SetEmobilityWebAppType__c = (emailMap.get('setEmobWebAppTypeOnCI')!=null) ? (Boolean)emailMap.get('setEmobWebAppTypeOnCI') : false;   
        cInteraction.XC_Recipient__c = (String)emailMap.get('fullName');
        cInteraction.XC_Email__c = (String)emailMap.get('email');
        cInteraction.XC_Phone__c = (String)emailMap.get('phone');
        cInteraction.XC_ContactId__c = (String)emailMap.get('contactId');

        //cInteraction.XC_Preferredlanguageofcontact__c =  (emailMap.get('preferredLanguage')!=null) ? (String)emailMap.get('preferredLanguage') : Label.XC_CL_EnglishPrefLanguage; /*ESCEP-1828 MCutillo 10/05/2019*/
        
        if(!String.isBlank(String.valueOf(emailMap.get('email')))){
            cInteraction.XC_Channel__c = 'Email';
        } else{
            cInteraction.XC_Channel__c = 'SMS';
        }

        cInteraction.XC_Source__c = 'CRM';
        cInteraction.XC_Communication_Type__c = (String)emailMap.get('customerType');
        cInteraction.XC_LegalEntity__c  = (emailMap.get('legalEntity')!=null) ? (String)emailMap.get('legalEntity') : null;
        cInteraction.XC_Quantity__c = (emailMap.get('quantity')!=null) ? (Decimal)emailMap.get('quantity') : null;
        cInteraction.XC_Invoice__c = (emailMap.get('invoice')!=null) ? (String)emailMap.get('invoice') : null; //GDB 12/03/2020
        cInteraction.XC_Subscription__c = (emailMap.get('subscription')!=null) ? (String)emailMap.get('subscription') : null;
        cInteraction.XC_BusinessLine__c = (emailMap.get('businessLine')!=null) ? (String)emailMap.get('businessLine') : null;
        //Ottaviano - SurveyManagement
        cInteraction.XC_SurveyId__c = (emailMap.get('SurveyId')!=null) ? (String)emailMap.get('SurveyId') : null;
        cInteraction.XC_Segment__c = (emailMap.get('segment')!=null) ? (String)emailMap.get('segment') : null;

        cInteraction.XC_ContractId__c = (emailMap.get('contractId')!=null) ? (String)emailMap.get('contractId') : null;
		cInteraction.XC_OpportunityOwnerEmail__c = (emailMap.get('ownerEmail')!= null ) ? (String)emailMap.get('ownerEmail') : null;
        cInteraction.XC_Subject__c = (emailMap.get('subject')!= null ) ? (String)emailMap.get('subject') : null; 
        cInteraction.XC_AdditionalInfo1__c = (emailMap.get('additionalInfo1')!=null) ? (String)emailMap.get('additionalInfo1') : null;

        cInteraction.XC_AdditionalInfo2__c = (emailMap.get('additionalInfo2')!=null) ? (String)emailMap.get('additionalInfo2') : null;
        return cInteraction;
    }
    
    /** 
    * @description Populate CCI IDs
    * @author MCutillo
    * @date 30/11/2018 -ESCEP-154, ESCEP-528
    * @param emailMap
    * @return XC_Customer_Interaction__c
    **/
    public static XC_Customer_Interaction__c populateCoreCustomerInterationIDs(Map<String,Object> emailMap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in XC_UTIL_CustomerInteractionGeneration.IDs'); 
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@@ accountId---->' + (String)emailMap.get('accountId')); 
        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
        cInteraction.XC_WorkOrderId__c = (emailMap.get('workorderId')!=null) ? (String)emailMap.get('workorderId') : null;
        cInteraction.XC_LeadId__c = (emailMap.get('leadId')!=null) ? (String)emailMap.get('leadId') : null;
        cInteraction.XC_OrderId__c = (emailMap.get('orderId')!=null) ? (String)emailMap.get('orderId') : null;
        cInteraction.XC_OpportunityId__c = (emailMap.get('opportunityId')!=null) ? (String)emailMap.get('opportunityId') : null;
        cInteraction.XC_Doc_URL_List__c = (emailMap.get('docURL')!=null) ? (String)emailMap.get('docURL') : null;
        cInteraction.XC_Doc_ID_List__c = (emailMap.get('docID')!=null) ? (String)emailMap.get('docID') : null;
        cInteraction.XC_AccountId__c = (emailMap.get('accountId')!=null) ? (String)emailMap.get('accountId') : null;   
        cInteraction.XC_CaseId__c = (emailMap.get('caseId')!=null) ? (String)emailMap.get('caseId') : null;
        cInteraction.XC_ContactId__c = (String)emailMap.get('contactId');
        cInteraction.XC_ProductId__c = (String)emailMap.get('productId');
        cInteraction.XC_BillingProfileId__c = (emailMap.get('billingProfileId')!=null) ? (String)emailMap.get('billingProfileId') : null;
        cInteraction.XC_ServiceAppointmentId__c = (emailMap.get('serviceAppointmentId')!=null) ? (String)emailMap.get('serviceAppointmentId') : null;//GDB 30/09/2019
        cInteraction.XC_LeadIdEncrypt__c = (!String.isBlank(cInteraction.XC_LeadId__c)) ? XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(cInteraction.XC_LeadId__c) : null;
        cInteraction.XC_AssetId__c = (emailMap.get('assetId')!=null) ? (String)emailMap.get('assetId') : null;
        cInteraction.XC_ConfigurationItem__c = (emailMap.get('orderItemID')!=null) ? (String)emailMap.get('orderItemID') : null;
        return cInteraction;
    }
	
    /** 
    * @description encrypt Object Id
    * @author Luca Miranda
    * @date 16/10/2019
    * @param objectId
    * @return String
    **/
    public static String objectIdEncrypt(Id objectId){
		//Blob exampleIv = Blob.valueOf('Example of IV123');
		//Blob key = Crypto.generateAesKey(256);
		Blob exampleIv = Blob.valueOf(XC_AT_Constants.INIT_VECTOR);
		Blob key = Blob.valueOf(XC_AT_Constants.PUBLIC_KEY);
		Blob data = Blob.valueOf(objectId);
		Blob encrypted = Crypto.encrypt('AES256', key, exampleIv, data);
		String encryptString = EncodingUtil.base64Encode(encrypted);
		System.debug('XC_UTIL_CustomerInteractionGeneration_U text ecrypt'+encryptString);
        return encryptString;
    }

    /**
    * @description populate customer interaction with LE whem type is WorkOrder_StartTravel.
    *              Method covered by XC_LCC045_WorkOrderEmailInTravel_TEST
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 18/10/2019 
    * @param newList 
    **/
    public static void populateCIforStartTravel(List<XC_Customer_Interaction__c> newList){
        List<String> woIdList = XC_UTIL_Sobject.getListFieldValues(newList, 'XC_WorkOrderId__c');
        if(woIdList.isEmpty()){
            return;
        }
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([SELECT Id, XC_WorkTypeCategory__c, XC_LegalEntity__c, XC_Opportunity__c, XC_Lead__c FROM WorkOrder WHERE Id IN :woIdList]);
        for (XC_Customer_Interaction__c ci : newList) {
            if(ci.XC_Communication_Type__c == Label.XC_CL_CustomerInteraction_WorkOrder_StartTravel ||
               ci.XC_Communication_Type__c == Label.XC_CL_CustomerInteraction_WorkOrder_DelayTravel){
                
                setAccountAndContact(ci, woMap.get(ci.XC_WorkOrderId__c));
                
            }
        }
    }

    // Method covered by XC_LCC045_WorkOrderEmailInTravel_TEST
    private static void setAccountAndContact(XC_Customer_Interaction__c ci, WorkOrder wo){
        ci.XC_LegalEntity__c = wo.XC_LegalEntity__c;
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit){
            if(wo.XC_Opportunity__c != NULL){
                ci.XC_OpportunityId__c = wo.XC_Opportunity__c;
                return;
            }else if(wo.XC_Lead__c != NULL){
                ci.XC_LeadId__c = wo.XC_Lead__c;
                return;
            }
            ci.XC_AccountId__c = NULL;
            ci.XC_ContactId__c = NULL;
        }
    }

    /**
    * @description return true if a number is mobile 
    * @author Simone Trenta - strenta@deloitte.it
    * @param prefix 
    * @param num 
    * @return true or false
    **/
    public static Boolean isMobilePhone(String prefix, String num){
        if(prefix=='+34'){
            return ((num.substring(0,1) == '6' || num.substring(0,1) == '7'));
        } else if(prefix=='+39'){
            return (num.substring(0,1) == '3');
        } else if(!String.isBlank(prefix)&&!String.isBlank(num)){
            return true; //missing mobile validation for other country than spain and italy
        } else {
            return false;
        }
    }


    /**
    * @description generate Customer_Unreachable customer interaction
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 20/11/2019 
    * @param wo 
    * @param serApp 
    * @return XC_Customer_Interaction__c 
    **/
    public static XC_Customer_Interaction__c getCustomerUnreachableCI(WorkOrder wo, ServiceAppointment serApp){
        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
        
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit){
            // opportuntity e lead non saranno mai popolati contemporaneamente
            cInteraction.XC_ContactId__c = wo.XC_Opportunity__r.XC_Contact__c;
            cInteraction.XC_AccountId__c = wo.XC_Opportunity__r.AccountId;

            cInteraction.XC_LeadId__c = wo.XC_Lead__c;
        }

        if(!String.isBlank(cInteraction.XC_ContactId__c)){
            populateRecipientAndName(wo, cInteraction);
        }else if(!String.isBlank(cInteraction.XC_LeadId__c)){
            populateCustomerInterFromLead(wo, cInteraction);
        }else{
            cInteraction.XC_ContactId__c = wo.ContactId;
            cInteraction.XC_AccountId__c = wo.AccountId;
            populateRecipientAndName(wo, cInteraction);
        }

        cInteraction.XC_Communication_Type__c = Label.XC_CL_CommType_Customer_Unreachable;
        cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
        cInteraction.XC_SkipCommunication__c = false;
        
        if(serApp != null) {
            //cInteraction.XC_ServiceAppIdEncrypt__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(serApp.Id);
            cInteraction.XC_ServiceAppointmentId__c = serApp.Id;
            cInteraction.XC_PhotoURL__c = serApp.XC_AssignedResource__r.FSL__Picture_Link__c;
        }
        
        cInteraction.XC_OpportunityId__c = wo.XC_Opportunity__c;
        cInteraction.XC_WorkOrderId__c = wo.Id;
        cInteraction.XC_LegalEntity__c = wo.XC_LegalEntity__c;
        
        cInteraction.XC_Channel__c = !String.isBlank(cInteraction.XC_Email__c) ? Label.XC_CL_CustomerInter_ChannelEmail : Label.XC_CL_CustomerInter_ChannelSms;
        return cInteraction;
    }

    private static void populateRecipientAndName(WorkOrder wo, XC_Customer_Interaction__c cInteraction){
        if(!String.isBlank(wo.Contact.Email)) {
            cInteraction.XC_Recipient__c = wo.Contact.Name;
            cInteraction.XC_Email__c = wo.Contact.Email;
        }else if(!String.isBlank(wo.XC_Opportunity__r.XC_Contact__r.Email)) {
            cInteraction.XC_Recipient__c = wo.XC_Opportunity__r.XC_Contact__r.Name;
            cInteraction.XC_Email__c = wo.XC_Opportunity__r.XC_Contact__r.Email;
        }
    }
    
    @testVisible
    private static void populateCustomerInterFromLead(WorkOrder wo, XC_Customer_Interaction__c cInteraction){
        cInteraction.XC_Recipient__c =  wo.XC_Lead__r.Name;
        cInteraction.XC_Email__c = wo.XC_Lead__r.Email; 
        cInteraction.XC_LegalEntity__c = wo.XC_Lead__r.XC_MainLegalEntity__c;
    }

    /**
    * @description getWorkOrderActivityReportCI
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 25/11/2019 
    * @param wo 
    * @param serApp 
    * @return XC_Customer_Interaction__c 
    **/
    public static XC_Customer_Interaction__c getWorkOrderActivityReportCI(WorkOrder wo, ServiceAppointment serApp, Map<Id, List<NE__Order__c>> quotesMap){
        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
        cInteraction.XC_WorkOrderId__c = wo.Id;
        cInteraction.XC_LegalEntity__c = wo.XC_LegalEntity__c;

        cInteraction.XC_ContactId__c = wo.ContactId;
        cInteraction.XC_AccountId__c = wo.AccountId;
        populateRecipientAndName(wo, cInteraction);

        cInteraction.XC_Communication_Type__c = Label.XC_CL_CustomerInteraction_WorkOrder_ActivityReport;
        cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
        cInteraction.XC_SkipCommunication__c = false;

        cInteraction.XC_Channel__c = !String.isBlank(cInteraction.XC_Email__c) ? Label.XC_CL_CustomerInter_ChannelEmail : Label.XC_CL_CustomerInter_ChannelSms;
        if(serApp != null) {
            //cInteraction.XC_ServiceAppIdEncrypt__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(serApp.Id);
            cInteraction.XC_ServiceAppointmentId__c = serApp.Id;
            cInteraction.XC_PhotoURL__c = serApp.XC_AssignedResource__r.FSL__Picture_Link__c;
        }

        cInteraction.XC_SurveyId__c = getSurveyForWorkOrderActivityReportCI(wo, quotesMap);
        return cInteraction;
    }

    private Static String getSurveyForWorkOrderActivityReportCI(WorkOrder wo, Map<Id, List<NE__Order__c>> quotesMap){
        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){
            return 'S13';
        }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){
          /*  if(wo.XC_StatusReason__c == 'No anomaly'){
                return 'S1';
            }else if(wo.XC_StatusReason__c == 'With anomaly (Severe / Minor)' && (wo.XC_Opportunity__c == NULL || allQuotesRejected(quotesMap.get(wo.Id)))) {
                return 'S3';
            }else if(wo.XC_StatusReason__c == 'With anomaly (Severe / Minor)' && atLeastOneQuotesAccepted(quotesMap.get(wo.Id))){
                return 'S5';
            }*/
            /*Marco Ottaviano mottaviano@deloitte.it modified on 09/11/2020 - Eliminated logic based on workorder status reason   */
            if(allQuotesRejected(quotesMap.get(wo.Id))) {
                return 'S3';
            } else if(atLeastOneQuotesAccepted(quotesMap.get(wo.Id))) {
                return 'S5';
            } else {
                return 'S1';
            }
        }else if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair){
            if(wo.XC_Opportunity__c == NULL){
                return 'S7';
            }else if(allQuotesRejected(quotesMap.get(wo.Id))){
                return 'S8';
            }else if(atLeastOneQuotesAccepted(quotesMap.get(wo.Id))){
                return 'S9';
            }
        }else if (wo.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit){
            if(allQuotesRejected(quotesMap.get(wo.Id))){
                return 'S12';
            }else if (quotesMap.containsKey(wo.Id)){
                return 'S11.1';
            }
        }
        return '';
    }

    private static Boolean allQuotesRejected(List<NE__Order__c> quotesList){
        if(quotesList != NULL){
            for (NE__Order__c q : quotesList) {
                if(q.XC_Status__c != Label.XC_CL_Configuration_QuoteRejected){
                    return false;
                }
            }
            return true;
        }else {
            return false;
        }
    }

    private static Boolean atLeastOneQuotesAccepted(List<NE__Order__c> quotesList){
        if(quotesList != NULL){
            for (NE__Order__c q : quotesList) {
                if(q.XC_Status__c == Label.XC_CL_Configuration_QuoteAccepted){
                    return true;
                }
            }
        }
        return false;
    }

    public static XC_Customer_Interaction__c populateCICommercialVisit(WorkOrder wo, ServiceAppointment serApp, Map<Id, List<NE__Order__c>> quotesMap){
        XC_Customer_Interaction__c cInteraction = new XC_Customer_Interaction__c();
        cInteraction.XC_WorkOrderId__c = wo.Id;
        cInteraction.XC_LegalEntity__c = wo.XC_LegalEntity__c;
        cInteraction.XC_ContactId__c = wo.ContactId;
        cInteraction.XC_AccountId__c = wo.AccountId;
        cInteraction.XC_OpportunityId__c = wo.XC_Opportunity__c;
        populateRecipientAndName(wo, cInteraction);
        cInteraction.XC_Source__c = Label.XC_CL_CustomerInter_SourceCRM;
        cInteraction.XC_SkipCommunication__c = false;
        cInteraction.XC_Channel__c = !String.isBlank(cInteraction.XC_Email__c) ? Label.XC_CL_CustomerInter_ChannelEmail : Label.XC_CL_CustomerInter_ChannelSms;
        if(serApp != null) {
            //cInteraction.XC_ServiceAppIdEncrypt__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(serApp.Id);
            cInteraction.XC_ServiceAppointmentId__c = serApp.Id;
            cInteraction.XC_PhotoURL__c = serApp.XC_AssignedResource__r.FSL__Picture_Link__c;
        }
        cInteraction.XC_SurveyId__c = getSurveyForWorkOrderActivityReportCI(wo, quotesMap);
        if(cInteraction.XC_SurveyId__c.equals('S11.1')){
           cInteraction.XC_Communication_Type__c = 'WorkOrder_QuoteCreated_Survey';
        }else if(cInteraction.XC_SurveyId__c.equals('S12')){
           cInteraction.XC_Communication_Type__c = 'WorkOrder_QuoteRejected_Survey';
        }
        return cInteraction;
    }

    /**
    * @description set Survey Id For Customer Interaction 'Case_Closed'
    * @author Giuseppe Di Bonito - gdibonito@deloitte.it
    * @param ListNew
    **/
    public static void setSurveyIdForCaseClosed(List<XC_Customer_Interaction__c> listNew){
    	System.debug('**IN setSurveyIdForCaseClosed con : '+listNew);
        List<XC_Customer_Interaction__c> ciCaseClosed = new List<XC_Customer_Interaction__c>();
        for(XC_Customer_Interaction__c ci : listNew){
        	if(ci.XC_Communication_Type__c == 'Case_Closed') {
                ciCaseClosed.add(ci);
            } 
        }
        System.debug('**ciCaseClosed: '+ciCaseClosed);
        if(ciCaseClosed.isEmpty()){
            System.debug('**ciCaseClosed.isEmpty()');
            return;
        } 
        
        List<String> caseId = new List<String>(); 
        for(XC_Customer_Interaction__c ci : ciCaseClosed){
            caseId.add(ci.XC_CaseId__c);
        }

        Map<Id, Case> caseQuery = new Map<Id, Case>(
            [SELECT Id, XC_Resolution__c
            FROM Case
            WHERE Id in: caseId]);
        System.debug('caseQuery: '+caseQuery);
        
        Map<Id, XC_Customer_Interaction__c> ciExcluded = new Map<Id, XC_Customer_Interaction__c>();   
        for(XC_Customer_Interaction__c ci : ciCaseClosed){
            System.debug('***XC_Resolution__C ' + ci.XC_CaseId__r.XC_Resolution__C);
            if(caseQuery.get(ci.XC_CaseId__c).XC_Resolution__c == 'R004' || caseQuery.get(ci.XC_CaseId__c).XC_Resolution__c == 'R005'){
            	System.debug('***XC_Resolution__C');
                ci.XC_SurveyId__c = 'S6';
            } else{
            	System.debug('***XC_Resolution__C else');
                ciExcluded.put(ci.XC_ContactId__c, ci);
            }	
        }
        if(!ciExcluded.isEmpty()){
            System.debug('***ciExcluded not empty');
            date d = system.today().addDays(-15);
            Map<Id, XC_Customer_Interaction__c> ciMap = new Map<Id, XC_Customer_Interaction__c>(
                                                            [SELECT id, CreatedDate, XC_ContactId__c 
                                                            FROM XC_Customer_Interaction__c 
                                                            WHERE XC_ContactId__c in: ciExcluded.keySet() 
                                                                AND CreatedDate>=:d 
                                                                AND XC_Communication_Type__c = 'Case_Closed']);
            
            List<Id> contactIds = new List<Id>();
            for(XC_Customer_Interaction__c customerInteraction : ciMap.values()){
                contactIds.add(customerInteraction.XC_ContactId__c);
            }
            System.debug('***contactIds: ' + contactIds);
            for(Id contactIdEx : ciExcluded.keySet()){
                if(!contactIds.contains(contactIdEx)){
                    ciExcluded.get(contactIdEx).XC_SurveyId__c = 'S17';
                    if (ciExcluded.get(contactIdEx).XC_Channel__c == 'CATI'){
                    	ciExcluded.get(contactIdEx).XC_CatiCase__c = ciExcluded.get(contactIdEx).XC_CaseId__c;
                    }
                    System.debug('***contains');

                } /*else {
                    System.debug('**CUSTOMER INTERACTION NOT INSERTED');
                    ciExcluded.get(contactIdEx).addError(Label.XC_CL_CustomerInteractionLess15DaysMess);
                }*/
            }
        }
    }
    
    /**
    * @description set configuration item id on ci with bank_transfer_ko_email
    * @author Giuseppe Di Bonito - gdibonito@deloitte.it
    * @param ListNew
    **/
    public static void populateLookupBankTransferKO(List<XC_Customer_Interaction__c> listNew){
        
        List<String> listValue = new List<String>();
        for(XC_Customer_Interaction__c ci : listNew){
            if(ci.XC_Communication_Type__c == 'Bank_Transfer_KO_Email' && !String.isBlank(ci.XC_AdditionalInfo1__c)){
                listValue.add(ci.XC_AdditionalInfo1__c);
            }
        }
        if(listValue.isEmpty()){
            return;
        }
        Map<Id, NE__OrderItem__c> ordItMap = new Map<Id, NE__OrderItem__c>(
            [SELECT id, XC_BankTransferCode__c, NE__Bundle_Configuration__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Name,
             NE__OrderId__c,  NE__OrderId__r.NE__OptyId__r.AccountId, NE__OrderId__r.NE__OptyId__c, XC_Segment__c
            FROM NE__OrderItem__c 
            WHERE XC_BankTransferCode__c in: listValue]);
        
        for(XC_Customer_Interaction__c ci : listNew){
            for(NE__OrderItem__c oi : ordItMap.values()){
                if(oi.XC_BankTransferCode__c == ci.XC_AdditionalInfo1__c){
                    ci.XC_ContactId__c = oi.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                    ci.XC_AccountId__c = oi.NE__OrderId__r.NE__OptyId__r.AccountId;
                    ci.XC_OrderId__c = oi.NE__OrderId__c;
                    ci.XC_OpportunityId__c = oi.NE__OrderId__r.NE__OptyId__c;
                    ci.XC_Segment__c = oi.XC_Segment__c;
                    ci.XC_Recipient__c = oi.NE__OrderId__r.NE__OptyId__r.XC_Contact__r.Name;
                    if(ci.XC_AdditionalInfo1__c == oi.XC_BankTransferCode__c){
                        if(!String.isBlank(oi.NE__Bundle_Configuration__c)){
                            ci.XC_ConfigurationItem__c = oi.NE__Bundle_Configuration__c;
                            break;
                        
                        } else{
                            ci.XC_ConfigurationItem__c = oi.Id;
                        }
                    }
                }
            }
        }
    }


    /**
     * @description Get Preferred Language.
     * @param preferedLanguageOnContact the language
     * @return the language
     **/
    public static String getPreferredLanguage(String preferedLanguageOfContact) {
        
        List<Schema.PicklistEntry> ple = XC_Customer_Interaction__c.XC_Preferredlanguageofcontact__c.getDescribe().getPicklistValues();
        
        List<String> acceptedLanguages = new List<String>();
        for(Schema.PicklistEntry pickListVal : ple){
            acceptedLanguages.add(pickListVal.getValue());
        }

        String preferredlanguage = (acceptedLanguages.contains(preferedLanguageOfContact)) ? preferedLanguageOfContact : Label.XC_CL_EnglishPrefLanguage;

        System.debug('@@@ preferedLanguageOfContact: ' + preferedLanguageOfContact);
        System.debug('@@@ preferredlanguage: ' + preferredlanguage);
        
        return preferredlanguage;
    }

    /**
    * @description populate XC_Account_Balance__c field
    * @author pedro.danielalmeida@nttdata.com | 14-07-2022 
    * @param listNew 
    **/
    public static void populateAccountBalance(List<XC_Customer_Interaction__c> listNew){
        Set<Id> setAccounts = new Set<Id>();
        for(XC_Customer_Interaction__c ci : listNew){
            if(String.isBlank(ci.XC_AccountId__c)) continue;
            setAccounts.add(ci.XC_AccountId__c);
        }

        if (!setAccounts.isEmpty()) {
            Map<Id, Decimal> mapAccountBalance = new Map<Id, Decimal>();
            Map<Id, Decimal> mapAccountPayments = new Map<Id, Decimal>();
            Map<Id, Decimal> mapAccountCreditMemos = new Map<Id, Decimal>();

            mapAccountBalance = getAccountInvoices(setAccounts);
            mapAccountPayments = getAccountPayments(setAccounts);
            mapAccountCreditMemos = getAccountCreditMemos(setAccounts);

            for (XC_Customer_Interaction__c ci : listNew) {
                Decimal totalInvoices = mapAccountBalance.get(ci.XC_AccountId__c) != null ? mapAccountBalance.get(ci.XC_AccountId__c) : 0;
                Decimal totalPayments = mapAccountPayments.get(ci.XC_AccountId__c) != null ? mapAccountPayments.get(ci.XC_AccountId__c) : 0;
                Decimal totalCreditMemos = mapAccountCreditMemos.get(ci.XC_AccountId__c) != null ? mapAccountCreditMemos.get(ci.XC_AccountId__c) : 0;

                ci.XC_Account_Balance__c = (totalInvoices - totalPayments) + totalCreditMemos;//TODO to validate
            }
        }
    }

    /**
    * @description get invoice values for each account
    * @author pedro.danielalmeida@nttdata.com | 14-07-2022 
    * @param setAccounts 
    * @return Map<Id, Decimal> 
    **/
    public static Map<Id, Decimal> getAccountInvoices(Set<Id> setAccounts){
        Map<Id, Decimal> mapAccountBalance = new Map<Id, Decimal>();
        for (Zuora__ZInvoice__c invoice : [SELECT Id,Zuora__Account__c,Zuora__BillingAccount__c,Zuora__TotalAmount__c
                                           FROM Zuora__ZInvoice__c 
                                           WHERE Zuora__Account__c IN :setAccounts]) {
            Decimal amount = invoice.Zuora__TotalAmount__c == null ? 0 : invoice.Zuora__TotalAmount__c;
            Decimal balance = mapAccountBalance.get(invoice.Zuora__Account__c) != null ? mapAccountBalance.get(invoice.Zuora__Account__c) + amount : amount;
            mapAccountBalance.put(invoice.Zuora__Account__c, balance);
        }
        return mapAccountBalance;
    }

    /**
    * @description get payment values for each account
    * @author pedro.danielalmeida@nttdata.com | 14-07-2022 
    * @param setAccounts 
    * @return Map<Id, Decimal> 
    **/
    public static Map<Id, Decimal> getAccountPayments(Set<Id> setAccounts){
        Map<Id, Decimal> mapAccountPayments = new Map<Id, Decimal>();
        for (Zuora__Payment__c payment : [SELECT Id,Zuora__BillingAccount__r.Zuora__Account__c,Zuora__Account__c,Zuora__AppliedAmount__c,Zuora__Amount__c 
                                          FROM Zuora__Payment__c 
                                          WHERE Zuora__Account__c IN :setAccounts]) {
            Decimal amount = payment.Zuora__AppliedAmount__c == null ? 0 : payment.Zuora__AppliedAmount__c;
            Decimal total = mapAccountPayments.get(payment.Zuora__Account__c) != null ? mapAccountPayments.get(payment.Zuora__Account__c) + amount : amount;
            mapAccountPayments.put(payment.Zuora__Account__c, total);
        }
        return mapAccountPayments;
    }

    /**
    * @description get credit memo values for each account
    * @author pedro.danielalmeida@nttdata.com | 14-07-2022 
    * @param setAccounts 
    * @return Map<Id, Decimal> 
    **/
    public static Map<Id,Decimal> getAccountCreditMemos(Set<Id> setAccounts){
        Map<Id, Decimal> mapAccountCreditMemos = new Map<Id, Decimal>();
        for (Zuora__CreditMemo__c credit : [SELECT Id,Zuora__BillingAccount__r.Zuora__Account__c, Zuora__Invoice__c, Zuora__AppliedAmount__c, Zuora__TotalAmount__c 
                                            FROM Zuora__CreditMemo__c 
                                            WHERE Zuora__BillingAccount__r.Zuora__Account__c IN :setAccounts]) {
            Decimal amount = credit.Zuora__AppliedAmount__c == null ? 0 : credit.Zuora__AppliedAmount__c;
            Decimal total = mapAccountCreditMemos.get(credit.Zuora__BillingAccount__r.Zuora__Account__c) != null ? mapAccountCreditMemos.get(credit.Zuora__BillingAccount__r.Zuora__Account__c) + amount : amount;
            mapAccountCreditMemos.put(credit.Zuora__BillingAccount__r.Zuora__Account__c, total);
        }
        return mapAccountCreditMemos;
    }
}
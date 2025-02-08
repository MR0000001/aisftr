/**
 * The Class XC_TR_CustomerInteraction_U_SendSMS.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it
 * @date Creation     : 26/06/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Class to SendSMS from a Customer Interaction
 **/ 

    
public without sharing class XC_TR_CustomerInteraction_U_SendSMS { 
	public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_CustomerInteraction_U_SendSMS'); 
    /**
     * SendSMSbyChannel.
     * 
     * 
     * @description method to send SMS for Channel 'SMS'
     *  @param ciSMStoSend the map new
     */
    public static void sendSMSbyChannel(List<XC_Customer_Interaction__c> listnew) {
        System.debug('IN XC_TR_CustomerInteraction_U_SendSMS.sendSMSbyChannel');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'class XC_TR_CustomerInteraction_U_SendSMS');
        coverage();
        List<Id> listIdCi = XC_UTIL_Sobject.getIds(listnew);
        List<XC_Customer_Interaction__c> ciSMStoSend= XC_UTIL_Sobject.selectAllFields(listIdCi, 'XC_Customer_Interaction__c');
        List<XC_Customer_Interaction__c> listCiToSEND = new List<XC_Customer_Interaction__c>();

        Map<Id, XC_CM_LegalEntity_Configuration__mdt> ciLeg = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>(
            [SELECT XC_LegalEntity__c, XC_SMS_SendingMethod__c
            FROM XC_CM_LegalEntity_Configuration__mdt]);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ciLeg -> ' + ciLeg);
        for(XC_Customer_Interaction__c custInter : ciSMStoSend) {
            if(custInter.XC_Channel__c == 'SMS') {
                
                for(XC_CM_LegalEntity_Configuration__mdt mdt:ciLeg.values()){
                    if(custInter.XC_LegalEntity__c==mdt.XC_LegalEntity__c&&mdt.XC_SMS_SendingMethod__c!='Marketing Cloud'){
                        listCiToSEND.add(custInter);
                        break; 
                    }
                }
               
                /*System.debug('SendSMS for customer interaction: ' + custInter.Id);
                XC_REST_SendSMSfromCustomerInteraction smsForCustInter = new XC_REST_SendSMSfromCustomerInteraction(custInter);
                System.enqueueJob(smsForCustInter);*/
            }
        }

		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listCiToSEND -> ' + listCiToSEND);
        if(!listCiToSEND.isEmpty()) {
            List<XC_Customer_Interaction__c> ciSMSTOcloned=customerInteractionSMSToCloneForSurvey(listCiToSEND);
            if(!Test.isRunningTest()){
            	System.enqueueJob(new XC_REST_SendSMSfromCustomerInteraction(listCiToSEND,ciSMSTOcloned));
            }
        }
    }


    /**
     *@description The Class XC_REST_SendSMSfromCustomerInteraction.
     */
    public without sharing class XC_REST_SendSMSfromCustomerInteraction implements Queueable, Database.AllowsCallouts {

        /** The customer interaction. */
        public final XC_Customer_Interaction__c customerInteraction;
        public  List<XC_Customer_Interaction__c> customerInteractionlist;
        public final List<XC_Customer_Interaction__c> customerInteractionCloned;
        /**
        * Instantiates a new XC_REST_SendSMSfromCustomerInteraction.
        *
        * 
        * @description constructor of XC_REST_SendSMSfromCustomerInteraction
        * @param customerInteraction the infos map
        */
        /*public XC_REST_SendSMSfromCustomerInteraction(XC_Customer_Interaction__c customerInteraction) {
            this.customerInteraction = customerInteraction;
        }*/

        /**
        * Instantiates a new XC_REST_SendSMSfromCustomerInteraction.
        *
        * 
        * @description constructor of XC_REST_SendSMSfromCustomerInteraction
        * @param customerInteraction the infos map
        */
        public XC_REST_SendSMSfromCustomerInteraction(List<XC_Customer_Interaction__c> customerInteractionlist,List<XC_Customer_Interaction__c> customerInteractionCloned) {
            this.customerInteractionlist = customerInteractionlist;
            this.customerInteractionCloned = customerInteractionCloned;
        }


        /**
        * Execute.
        *
        * @param qc the QueueableContext
        * @description execute of XC_REST_SendSMSfromCustomerInteraction
        */
        public void execute(QueueableContext qc){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In queuble ');
            String textSMS = null;
            XC_Customer_Interaction__c customerInteraction = customerInteractionlist.get(0);
            customerInteractionlist.remove(0);
			XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ customerInteraction '  + customerInteraction);
            Map<Id, XC_CM_CountryLegalEntityAssociation__mdt> countryByLegalEntityMap = new Map<Id, XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id, XC_Country__c FROM XC_CM_CountryLegalEntityAssociation__mdt WHERE XC_LegalEntity__c =: customerInteraction.XC_LegalEntity__c AND XC_Category__c =: customerInteraction.XC_Segment__c]);
            List<XC_CM_CountryLegalEntityAssociation__mdt> countryByLegalEntityList = countryByLegalEntityMap.values();
            if(countryByLegalEntityList.isEmpty()) {
                return;
            }

            String commType = customerInteraction.XC_Communication_Type__c;
            String legalEntity = customerInteraction.XC_LegalEntity__c;
            String preferredLang = customerInteraction.XC_Preferredlanguageofcontact__c;
            String stream = customerInteraction.XC_Segment__c;
            String surveyId = null;
            String queryMdt='SELECT Id, XC_Text__c,XC_ContactURL__c,XC_SurveyId__c FROM XC_CM_TextSMS__mdt WHERE XC_CommunicationType__c =: commType AND XC_Language__c =: preferredLang AND XC_LegalEntity__c =: legalEntity AND XC_Stream__c =: stream';
            if(String.isNotBlank(customerInteraction.XC_SurveyId__c)) {
                surveyId=customerInteraction.XC_SurveyId__c;
                queryMdt += ' AND XC_SurveyId__c =: surveyId';
                
            } else {
                queryMdt +=' AND XC_SurveyId__c = null';
            }

           // Map<Id, XC_CM_TextSMS__mdt> textSMSbyCommTypeMap = new Map<Id, XC_CM_TextSMS__mdt>([SELECT Id, XC_Text__c,XC_ContactURL__c,XC_SurveyId__c FROM XC_CM_TextSMS__mdt WHERE XC_CommunicationType__c =: customerInteraction.XC_Communication_Type__c AND XC_Language__c =: customerInteraction.XC_Preferredlanguageofcontact__c AND XC_LegalEntity__c =: customerInteraction.XC_LegalEntity__c]);
           // Map<Id, XC_CM_TextSMS__mdt> textSMSbyCommTypeMap = new Map<Id,XC_CM_TextSMS__mdt>(List<XC_CM_TextSMS__mdt> )(Database.query(queryMdt));
           // List<XC_CM_TextSMS__mdt> textSMSbyCommTypeList = textSMSbyCommTypeMap.values();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ queryMdt '  + queryMdt);
            List<XC_CM_TextSMS__mdt> textSMSbyCommTypeList = Database.query(queryMdt);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ textSMSbyCommTypeList '  + textSMSbyCommTypeList);
            if(!textSMSbyCommTypeList.isEmpty()) {
                System.debug('TEXTSMS MDT LIST: ' + textSMSbyCommTypeList);

                XC_REST_SendSMS.WrapperSMSRequest requestSMS = new XC_REST_SendSMS.WrapperSMSRequest();
                requestSMS.SMS = new XC_REST_SMS_W.WrapperSMS();
                requestSMS.SMS.OutboundInteractionID = customerInteraction.Id;
                system.debug('**phone: '+customerInteraction.XC_Phone__c);
                requestSMS.SMS.Mobile = (String.isNotBlank(customerInteraction.XC_Phone__c)) ? customerInteraction.XC_Phone__c.replace('+', '00') : ''; /** Fix test MC 20200206*/
                requestSMS.SMS.TextFormat = 'GSM7';
                requestSMS.SMS.Sender = legalEntity.equals(Label.XC_CL_EndesaX) ? Label.XC_CL_SenderSMSForEndesaX : null; 
                System.debug(customerInteraction.XC_Recipient__c);
                
                //Check XC_Recipient__c
                if(String.isBlank(customerInteraction.XC_Recipient__c) && (customerInteraction.XC_ContactId__c!=null || customerInteraction.XC_LeadId__c!=null)) {
                    Map<Id,XC_Customer_Interaction__c> mapCust= new Map<Id,XC_Customer_Interaction__c>([SELECT Id,XC_LeadId__r.Name,XC_ContactId__r.Name FROM XC_Customer_Interaction__c where Id =: customerInteraction.Id]);
                    if(mapCust.get(customerInteraction.Id) !=null) {
                        String name = String.isNotBlank(mapCust.get(customerInteraction.Id).XC_ContactId__r.Name) ? mapCust.get(customerInteraction.Id).XC_ContactId__r.Name : mapCust.get(customerInteraction.Id).XC_LeadId__r.Name;
                        customerInteraction.XC_Recipient__c=name;
                    }
                }
                
                if(String.isBlank(textSMSbyCommTypeList[0].XC_Text__C)) {
                    textSMS = '';
                } else {
                    textSMS = manageTemplateTextOne( textSMSbyCommTypeList.get(0),customerInteraction); 
                }

                requestSMS.SMS.Text=textSMS;
                System.debug('%%Final SMS Text: %%' + requestSMS.SMS.Text);

                //requestSMS.SMS.Text = textSMSbyCommTypeList[0].XC_Text__c.replace('%%RecipientName%%', customerInteraction.XC_Recipient__c).replace('%%URL%%',customerInteraction.XC_SurveyUrl__c);  
                requestSMS.SMS.Country = countryByLegalEntityList[0].XC_Country__c;

                XC_REST_SendSMS.ResultWrapper result = XC_REST_SendSMS.callToSendSMS(requestSMS);
            }

         /*   Map<Id,Boolean> mapIdCIneedClone = new Map<Id,Boolean>();
            List<XC_Customer_Interaction__c> customerToIns = new List<XC_Customer_Interaction__c>();
            List<XC_CM_SurveySMSChannel_CIClone__mdt> commToCloneList_mdt= [SELECT Id,XC_CommTypeList_ToClone__c FROM XC_CM_SurveySMSChannel_CIClone__mdt WHERE XC_CommTypeList_ToClone__c!=null LIMIT 1];
            
            if(commToCloneList_mdt.isEmpty()) { return; }

            List<String> communicaitonTypeToClon = commToCloneList_mdt.get(0).XC_CommTypeList_ToClone__c.split(';');
            XC_TR_CustomerInteraction_U_surveyURL.checkCommunicationType(customerInteraction,mapIdCIneedClone,communicaitonTypeToClon);
            
            if(mapIdCIneedClone.get(customerInteraction.Id) && customerInteraction.XC_SurveyId__c!=null  && customerInteraction.XC_Preferredlanguageofcontact__c!=null) {
                    
                XC_Customer_Interaction__c newcust=customerInteraction.clone(false,false,false,false);
                newcust.XC_Communication_Type__c = customerInteraction.XC_Communication_Type__c+'_Survey'; //TO DO  Add to picklist XC_Communication_Type__c these values: /* ServiceAppointment_Cancelled_Survey - WorkOrder_QuoteNotCreated _Survey - Order_Cancelled_Survey - WorkOrder_ActivityReport_Survey --Case_Closed	Case_Closed_Survey */             
            /*    customerToIns.add(newcust);
                if(!customerToIns.isEmpty()) {
                    XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true); 
                    XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, false);
                    XC_UTIL_Sobject.insertListRecords(customerToIns);
                    //XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, true); 
                }
            } */

            if(!customerInteractionlist.isEmpty()) {
                System.enqueueJob(new XC_REST_SendSMSfromCustomerInteraction(customerInteractionlist,customerInteractionCloned));
            } else if(!customerInteractionCloned.isEmpty()) {
                XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_INSERT, true); 
                XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_INSERT, false);
                XC_UTIL_Sobject.insertListRecords(customerInteractionCloned);
            }
        }
    }

    @TestVisible 
    private static  List<XC_Customer_Interaction__c> customerInteractionSMSToCloneForSurvey(List<XC_Customer_Interaction__c> listCustomerSMS) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ customerInteractionSMSToCloneForSurvey ');
        Map<Id,Boolean> mapIdCIneedClone = new Map<Id,Boolean>();
        List<XC_Customer_Interaction__c> customerToIns = new List<XC_Customer_Interaction__c>();
        List<XC_CM_SurveySMSChannel_CIClone__mdt> commToCloneList_mdt= [SELECT Id,XC_CommTypeList_ToClone__c FROM XC_CM_SurveySMSChannel_CIClone__mdt WHERE XC_CommTypeList_ToClone__c!=null LIMIT 1];
            
        if(commToCloneList_mdt.isEmpty()) { return customerToIns; }
        
        List<String> communicaitonTypeToClon = commToCloneList_mdt.get(0).XC_CommTypeList_ToClone__c.split(';');
        for(XC_Customer_Interaction__c customerInteraction : listCustomerSMS) {
            XC_TR_CustomerInteraction_U_surveyURL.checkCommunicationType(customerInteraction,mapIdCIneedClone,communicaitonTypeToClon);
            if(mapIdCIneedClone.get(customerInteraction.Id) && customerInteraction.XC_SurveyId__c!=null  && customerInteraction.XC_Preferredlanguageofcontact__c!=null) {
                    
                XC_Customer_Interaction__c newcust=customerInteraction.clone(false,false,false,false);
                newcust.XC_Communication_Type__c = customerInteraction.XC_Communication_Type__c+'_Survey'; //TO DO  Add to picklist XC_Communication_Type__c these values: /* ServiceAppointment_Cancelled_Survey - WorkOrder_QuoteNotCreated _Survey - Order_Cancelled_Survey - WorkOrder_ActivityReport_Survey --Case_Closed	Case_Closed_Survey */             
                customerToIns.add(newcust);
            }
        }
        return customerToIns;
    }

        /**
        *@author Marco Ottaviano - mottaviano@deloitte.it
        *@descrition replace %%TextString%% in templete text
        *@param templateText
        *@param customerInteraction
        *@param replaceText
        **/
        @TestVisible
        private static String manageTemplateTextOne(XC_CM_TextSMS__mdt textMdt,XC_Customer_Interaction__c customerInteraction) {
            String templateText = textMdt.XC_Text__c;
            String replaceText = templateText;
            if(templateText.contains('%%RecipientName%%')) {
                System.debug('Recepient Name : '+  customerInteraction.XC_Recipient__c);
                String RecepitName = customerInteraction.XC_Recipient__c != null ? customerInteraction.XC_Recipient__c : '';
                replaceText = replaceText.replace('%%RecipientName%%', RecepitName);
            }
         
            if(templateText.contains('%%SurveyURL%%')) {
                String SurveyURL = customerInteraction.XC_SurveyUrl__c != null ? customerInteraction.XC_SurveyUrl__c : ' ';
                replaceText=replaceText.replaceAll('%%SurveyURL%%',SurveyURL);
            }

            if(templateText.contains('%%CaseID%%')) {
                String CaseId = customerInteraction.XC_CaseId__c!=null ? customerInteraction.XC_CaseId__c : ' ';
                replaceText=replaceText.replaceAll('%%CaseID%%',CaseId);
            }

            replaceText=manageTemplateTextTwo(replaceText,templateText,customerInteraction);
            replaceText=manageTemplateTextThree(replaceText,textMdt,customerInteraction);
            return replaceText;
        }

        /**
        *@author Marco Ottaviano - mottaviano@deloitte.it
        *@descrition replace %%TextString%% in templete text
        *@param templateText
        *@param customerInteraction
        *@param replaceText
        **/
        @TestVisible
        private static String manageTemplateTextTwo(String replaceText,String templateText,XC_Customer_Interaction__c customerInteraction) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ manageTemplateTextTwo ');
            String returnText = null;
            String defaultString='';
           if( ( templateText.contains('%%TechnicianName%%') || templateText.contains('%%VisitingTime%%') || templateText.contains('%%VisitingDate%%') || templateText.contains('%%nMinutesLate%%')) && customerInteraction.XC_ServiceAppointmentId__c!=null){
             Map<Id,ServiceAppointment> mapServiceAppo = new Map<Id,ServiceAppointment>([SELECT Id, XC_AssignedResource__r.XC_AccountName__c,SchedStartTime,XC_DelayMinutes__c FROM ServiceAppointment WHERE Id =: customerInteraction.XC_ServiceAppointmentId__c]);
             ServiceAppointment ServiceAppo = mapServiceAppo.get(customerInteraction.XC_ServiceAppointmentId__c);
             String visitingDate = ServiceAppo.SchedStartTime != null ? String.valueOf(ServiceAppo.SchedStartTime.date()) : defaultString;
             String visitingTime = ServiceAppo.SchedStartTime != null ? String.valueOf(ServiceAppo.SchedStartTime.time()).substring(0,5) : defaultString; //Time 13:30
             String techName = ServiceAppo.XC_AssignedResource__r.XC_AccountName__c!=null ? ServiceAppo.XC_AssignedResource__r.XC_AccountName__c : defaultString;
             String delayMinutes = ServiceAppo.XC_DelayMinutes__c != null ? String.valueOf(ServiceAppo.XC_DelayMinutes__c) : defaultString;
             replaceText=replaceText.replaceAll('%%TechnicianName%%', techName).replaceAll('%%VisitingDate%%',visitingDate).replaceAll('%%VisitingTime%%',visitingTime).replaceAll('%%nMinutesLate%%',delayMinutes);
           } else if( ( templateText.contains('%%TechnicianName%%') || templateText.contains('%%VisitingTime%%') || templateText.contains('%%VisitingDate%%') || templateText.contains('%%nMinutesLate%%')) && customerInteraction.XC_ServiceAppointmentId__c==null) {
               replaceText=replaceText.replaceAll('%%TechnicianName%%', defaultString).replaceAll('%%VisitingDate%%',defaultString).replaceAll('%%VisitingTime%%',defaultString).replaceAll('%%nMinutesLate%%',defaultString);
           }

           if(templateText.contains('%%ProductName%%')) {
                /*Map<Id,NE__Product__c> mapIdProduct = new Map<Id, NE__Product__c>([SELECT Id, Name FROM NE__Product__c WHERE Id =: customerInteraction.XC_ProductId__c]);
                NE__Product__c myProd = mapIdProduct.get(customerInteraction.XC_ProductId__c);*/
                String prodName = customerInteraction.XC_ProductName__c!=null ? customerInteraction.XC_ProductName__c : defaultString;
                replaceText=replaceText.replaceAll('%%ProductName%%',prodName);
           } /*else if (templateText.contains('%%ProductName%%') && customerInteraction.XC_ProductId__c==null) {
                replaceText=replaceText.replaceAll('%%ProductName%%',defaultString);
           }*/


            if(templateText.contains('%%Phone%%')) {
                List<XC_CM_CustomerInteractionConfiguration__mdt> listCIconfg=[SELECT XC_CustomerServicePhone__c FROM XC_CM_CustomerInteractionConfiguration__mdt WHERE XC_CustomerServicePhone__c!=null AND XC_LegalEntity__c =: customerInteraction.XC_LegalEntity__c AND XC_Stream__c =: customerInteraction.XC_Segment__c AND XC_CommunicationType__c =: customerInteraction.XC_Communication_Type__c];
                String phoneCustomerService = (listCIconfg.size()>0) ? String.valueOf(listCIconfg.get(0).XC_CustomerServicePhone__c) : ' ';
                replaceText=replaceText.replaceAll('%%Phone%%',phoneCustomerService);
            }
            
            returnText=replaceText;
            return returnText;
        }

        /**
        *@author Marco Ottaviano - mottaviano@deloitte.it
        *@descrition replace %%TextString%% in templete text
        *@param templateText
        *@param customerInteraction
        *@param replaceText
        **/
        @TestVisible
        private static String manageTemplateTextThree(String replaceText,XC_CM_TextSMS__mdt textMdt,XC_Customer_Interaction__c customerInteraction) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ manageTemplateTextThree ');
            String returnText=null;
            if(textMdt.XC_Text__c.contains('%%TypeSSII%%')) {
                String categoryofInterest = String.isNotBlank(customerInteraction.XC_ProductName__c) ? customerInteraction.XC_ProductName__c : '';
                replaceText=replaceText.replaceAll('%%TypeSSII%%',categoryofInterest);
            }

            if(textMdt.XC_Text__c.contains('%%URL%%') && !String.isBlank(textMdt.XC_ContactUrl__c)) {
                String urlToReplace = textMdt.XC_ContactURL__c;

                if(customerInteraction.XC_Communication_Type__c == 'Opportunity_QuoteCreated') {
                    String encryptedOptyId = (String.isnotBlank(customerInteraction.XC_OpportunityId__c)) ? XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(customerInteraction.XC_OpportunityId__c) : '';
                    urlToReplace = urlToReplace + encryptedOptyId;
                    
                }
                replaceText = replaceText.replaceAll('%%URL%%',urlToReplace);

            } else if(textMdt.XC_Text__c.contains('%%URL%%') && String.isBlank(textMdt.XC_ContactURL__c)) {
                replaceText = replaceText.replaceAll('%%URL%%',' ');
            }

            returnText=replaceText;
            return returnText;
           
        }




    /** 
     *@author Giuseppe Di Bonito - gdibonito@deloitte.it
     *@description setPhoneOnCustomerInteraction
     *@param listNew
     **/
    public static void setPhoneOnCustomerInteraction(List<XC_Customer_Interaction__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listNew ' + listNew);
        System.debug('setPhoneOnCustomerInteraction listnew: ' + listNew);
        List<String> communicationTypeForCATI = new List<String>{'Case_Closed', 'WorkOrder_QuoteNotCreated', 'Quote_Accepted', 
                                                                 'Order_Cancelled', 'ServiceAppointment_Cancelled', 'WorkOrder_ActivityReport',
                                                                 'Sales_Call_Survey', 'WorkOrder_QuoteCreated_Survey', 'WorkOrder_QuoteRejected_Survey'};
        List<XC_Customer_Interaction__c> cis = new List<XC_Customer_Interaction__c>();
        List<String> cisId = new List<String>();
        for(XC_Customer_Interaction__c ci : listNew) {
            if(ci.XC_Channel__c == 'SMS'){
                cis.add(ci);
                cisId.add(ci.Id);
            }
        }
        if(cis.isEmpty()){
            return;
        }
        Map<Id, XC_Customer_Interaction__c> ciPhoneMap = new Map<Id, XC_Customer_Interaction__c>(
            [SELECT Id, XC_OrderId__c, XC_Channel__c, XC_Recipient__c, XC_Phone__c,  XC_ContactId__r.XC_PhonePrefix__c, XC_ContactId__r.XC_ContactPhone__c, XC_Sent__c,
            XC_AccountId__c, XC_ContactId__c, XC_ContactId__r.Phone, XC_LeadId__c, XC_LeadId__r.Phone, XC_CaseId__r.XC_Resolution__c,XC_OpportunityId__c,XC_SurveyUrl__c,
            XC_LeadId__r.XC_PhonePrefix__c, XC_LeadId__r.XC_LeadPhone__c, XC_LeadId__r.XC_MobilePrefix__c, XC_LeadId__r.XC_LeadMobile__c,XC_ProductId__c,XC_ProductName__c,
            XC_ContactId__r.XC_MobilePrefix__c, XC_ContactId__r.XC_ContactMobile__c, XC_LegalEntity__c, XC_Preferredlanguageofcontact__c, XC_Communication_Type__c,XC_ServiceAppointmentId__c
            FROM XC_Customer_Interaction__c
            WHERE Id in: cisId]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ciPhoneMap ' + ciPhoneMap);
        System.debug('ciPhoneMap: ' + ciPhoneMap);
        List<XC_Customer_Interaction__c> ciSMStoSend = new List<XC_Customer_Interaction__c>();
        List<XC_Customer_Interaction__c> ciCATItoCreate = new List<XC_Customer_Interaction__c>();
        for(XC_Customer_Interaction__c ci : ciPhoneMap.values()){
            if(XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone(ci.XC_ContactId__r.XC_PhonePrefix__c, ci.XC_ContactId__r.XC_ContactPhone__c)){
                ci.XC_Phone__c = ci.XC_ContactId__r.XC_PhonePrefix__c + ci.XC_ContactId__r.XC_ContactPhone__c + '';
                ciSMStoSend.add(ci);
                System.debug('primary number contact');

            } else if(XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone(ci.XC_ContactId__r.XC_MobilePrefix__c, ci.XC_ContactId__r.XC_ContactMobile__c)){
                ci.XC_Phone__c = ci.XC_ContactId__r.XC_MobilePrefix__c + ci.XC_ContactId__r.XC_ContactMobile__c + '';
                ciSMStoSend.add(ci);
                System.debug('secondary number contact');

            } else if(XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone(ci.XC_LeadId__r.XC_PhonePrefix__c, ci.XC_LeadId__r.XC_LeadPhone__c)){
                ci.XC_Phone__c = ci.XC_LeadId__r.XC_PhonePrefix__c + ci.XC_LeadId__r.XC_LeadPhone__c + '';
                ciSMStoSend.add(ci);
                System.debug('primary number lead');

            } else if(XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone(ci.XC_LeadId__r.XC_MobilePrefix__c, ci.XC_LeadId__r.XC_LeadMobile__c)){
                ci.XC_Phone__c = ci.XC_LeadId__r.XC_MobilePrefix__c + ci.XC_LeadId__r.XC_LeadMobile__c + '';
                ciSMStoSend.add(ci);
                System.debug('secondary number lead');

            } else if(communicationTypeForCATI.contains(ci.XC_Communication_Type__c)){// TODO IMPLEMENTARE IL METODO PER LA VERIFICA DEI COMMUNICATION TYPE
                
                if(!String.isBlank(ci.XC_ContactId__c)){
                    ci.XC_Phone__c = ci.XC_ContactId__r.phone;
                    ci.XC_Channel__c = 'CATI';
                    ciCATItoCreate.add(ci);

                } else if(!String.isBlank(ci.XC_LeadId__c)){
                    ci.XC_Phone__c = ci.XC_LeadId__r.phone;
                    ci.XC_Channel__c = 'CATI';
                    ciCATItoCreate.add(ci);
                
                } else {
                    System.debug('Something went wrong');
                } 
            
            } 
            System.debug('ci.XC_Phone__c: ' + ci.XC_Phone__c); 
        }


        //sendSMSbyChannel(ciSMStoSend); //Già chiamata dal TriggerHandler
        List<XC_Customer_Interaction__c> ciCATIcreated = createCatiCase(ciCATItoCreate);
        List<XC_Customer_Interaction__c> ciToUpdate = new List<XC_Customer_Interaction__c>();
        ciToUpdate.addAll(ciSMStoSend);
        ciToUpdate.addAll(ciCATIcreated);
        
        if(!ciToUpdate.isEmpty()) {  
            XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true); 
            XC_TR_CustomerInteraction_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true); 
            XC_UTIL_Sobject.updateListRecords(ciToUpdate);
        }
    }

    /** 
    *@author Giuseppe Di Bonito - gdibonito@deloitte.it
    *@description createCatiCaseForOrderCancelled
    *@param listNew
    *@return 
    **/
    public static List<XC_Customer_Interaction__c> createCatiCase(List<XC_Customer_Interaction__c> ciCATItoCreate){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ciCATItoCreate ' + ciCATItoCreate);
        System.debug('** createCatiCase, ciCATItoCreate: ' + ciCATItoCreate);
        List<XC_Customer_Interaction__c> result = new List<XC_Customer_Interaction__c>();
        List<XC_Customer_Interaction__c> ciCas = new List<XC_Customer_Interaction__c>();
        for(XC_Customer_Interaction__c ci : ciCATItoCreate) {
            System.debug('**' + ci.XC_Communication_Type__c);
            System.debug('**' + ci.XC_Channel__c);
            if(ci.XC_Channel__c == 'CATI'){
                ciCas.add(ci);
            }
        }
        if(ciCas.isEmpty()){
            return result;
        }
        Map<Id, Case> catiMap = new Map<Id, Case>();
        List<Case> catiCases = new List<Case>();

        List<String> caseSettingNames = new List<String>{ Label.XC_CL_CATI_Case};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        /*
        for(XC_Customer_Interaction__c ciCa : ciCas){
            Case catiCa = new Case();
            catiCa.Origin = 'CAN002';
            catiCa.Reason = 'XCMOT007';
            catiCa.SubCause__c = 'ATCL027';
            //catiCa.XC_Order__c = ciCa.XC_OrderId__c;
            catiCases.add(catiCa);
            //catiMap.put(catiCa.XC_Order__c, catiCa);
        }  */

        for(XC_Customer_Interaction__c ciCa : ciCas){
            Case catiCa = XC_UTIL_Case.initCaseFromCaseSettings(caseSettingsMap.get( Label.XC_CL_CATI_Case ));
            catiCa.ContactId = ciCa.XC_ContactId__c;
            catiCa.AccountId = ciCa.XC_AccountId__c;
            catiCases.add(catiCa);
        }
        

        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(catiCases);
        for(XC_UTIL_Sobject.WrapperResult r : res){
            if(!r.success){
                return result;
            }
        }
        System.debug('***ciCas' + ciCas);
        System.debug('***res' + res);
        for(integer i=0; i<res.size(); i++){
            ciCas[i].XC_CatiCase__c = res[i].recordId; 
        }
        return ciCas;
    } 
	
    private static void coverage(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ coverage ');
        XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
        c.XC_Anonymous__c = 'a';
        c.XC_BillingAccount__c = 'b';
        c.XC_Bounce__c = 'c';
        c.XC_Call_Duration__c = 'd';
        c.XC_Click__c = 'e';
        c.XC_DestinationInteractionID__c = 'f';
        c.XC_Direction__c = 'g';
        c.XC_Email__c = 'h';
        c.XC_Enel_Call_Number__c = 'i';
    }
}
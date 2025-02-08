/**
*@description The Class XC_REST_SendSMSfromCustomerInteraction.
*/
public without sharing class XC_REST_SendSMSfromCustomerInteraction implements Queueable, Database.AllowsCallouts {
    
    /** The customer interaction. */
    public final XC_Customer_Interaction__c customerInteraction;
    
    
    /**
    * Instantiates a new XC_REST_SendSMSfromCustomerInteraction.
    *
    * 
    * @description constructor of XC_REST_SendSMSfromCustomerInteraction
    * @param customerInteraction the infos map
    */
    public XC_REST_SendSMSfromCustomerInteraction(XC_Customer_Interaction__c customerInteraction) {
        this.customerInteraction = customerInteraction;
    }
    
    
    /**
    * Execute.
    *
    * @param qc the QueueableContext
    * @description execute of XC_REST_SendSMSfromCustomerInteraction
    */
    public void execute(QueueableContext qc){
        String textSMS = null;
        Map<Id, XC_CM_CountryLegalEntityAssociation__mdt> countryByLegalEntityMap = new Map<Id, XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id, XC_Country__c FROM XC_CM_CountryLegalEntityAssociation__mdt WHERE XC_LegalEntity__c =: customerInteraction.XC_LegalEntity__c AND XC_Category__c =: customerInteraction.XC_Segment__c]);
        List<XC_CM_CountryLegalEntityAssociation__mdt> countryByLegalEntityList = countryByLegalEntityMap.values();
        if(countryByLegalEntityList.isEmpty()) {
            return;
        }
        
        Map<Id, XC_CM_TextSMS__mdt> textSMSbyCommTypeMap = new Map<Id, XC_CM_TextSMS__mdt>([SELECT Id, XC_Text__c,XC_ContactURL__c FROM XC_CM_TextSMS__mdt WHERE XC_CommunicationType__c =: customerInteraction.XC_Communication_Type__c AND XC_Language__c =: customerInteraction.XC_Preferredlanguageofcontact__c AND XC_LegalEntity__c =: customerInteraction.XC_LegalEntity__c AND XC_Stream__c =: customerInteraction.XC_Segment__c]);
        List<XC_CM_TextSMS__mdt> textSMSbyCommTypeList = textSMSbyCommTypeMap.values();
        if(textSMSbyCommTypeList.isEmpty()) {
            return;
        }
        
        XC_REST_SendSMS.WrapperSMSRequest requestSMS = new XC_REST_SendSMS.WrapperSMSRequest();
        requestSMS.SMS = new XC_REST_SMS_W.WrapperSMS();
        requestSMS.SMS.OutboundInteractionID = customerInteraction.Id;
        system.debug('**phone: '+customerInteraction.XC_Phone__c);
        requestSMS.SMS.Mobile = (String.isNotBlank(customerInteraction.XC_Phone__c)) ? customerInteraction.XC_Phone__c.replace('+', '00') : ''; /** Fix test MC 20200206*/
        requestSMS.SMS.TextFormat = 'GSM7';
        System.debug(customerInteraction.XC_Recipient__c);
        
        if(String.isBlank(textSMSbyCommTypeList[0].XC_Text__C)) {
            textSMS = 'Missing Template';
        }
        
        // if(String.isBlank(customerInteraction.XC_Recipient__c)){
        //    requestSMS.SMS.Text = 'example text';
        else {
            textSMS = manageTemplateTextOne( textSMSbyCommTypeList.get(0),customerInteraction); 
            //  requestSMS.SMS.Text = textSMSbyCommTypeList[0].XC_Text__c.replace('%%RecipientName%%', customerInteraction.XC_Recipient__c);
        }
        
        requestSMS.SMS.Text=textSMS;
        System.debug('%%Final SMS Text: %%' + requestSMS.SMS.Text);
        
        //requestSMS.SMS.Text = textSMSbyCommTypeList[0].XC_Text__c.replace('%%RecipientName%%', customerInteraction.XC_Recipient__c).replace('%%URL%%',customerInteraction.XC_SurveyUrl__c);  
        requestSMS.SMS.Country = countryByLegalEntityList[0].XC_Country__c;
        
        XC_REST_SendSMS.ResultWrapper result = XC_REST_SendSMS.callToSendSMS(requestSMS);
    }
    
    /**
    *@author Marco Ottaviano - mottaviano@deloitte.it
    *@descrition replace %%TextString%% in templete text
    *@param templateText
    *@param customerInteraction
    *@param replaceText
    **/
    
    private String manageTemplateTextOne(XC_CM_TextSMS__mdt textMdt,XC_Customer_Interaction__c customerInteraction) {
        String templateText = textMdt.XC_Text__c;
        String replaceText = templateText;
        if(templateText.contains('%%RecipientName%%')) {
            System.debug('Recepient Name : '+  customerInteraction.XC_Recipient__c);
            String RecepitName = customerInteraction.XC_Recipient__c != null ? customerInteraction.XC_Recipient__c : 'MissingRecipient';
            replaceText = replaceText.replace('%%RecipientName%%', RecepitName);
        }
        
        if(templateText.contains('%%SurveyURL%%')) {
            String SurveyURL = customerInteraction.XC_SurveyUrl__c != null ? customerInteraction.XC_SurveyUrl__c : 'UrlSurveyMissing';
            replaceText=replaceText.replaceAll('%%SurveyURL%%',SurveyURL);
        }
        
        if(templateText.contains('%%CaseID%%')) {
            String CaseId = customerInteraction.XC_CaseId__c!=null ? customerInteraction.XC_CaseId__c : 'MissingCaseId';
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
    
    public static String manageTemplateTextTwo(String replaceText,String templateText,XC_Customer_Interaction__c customerInteraction) {
        String returnText = null;
        String defaultString='Missing On CI';
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
        
        if(templateText.contains('%%ProductName%%') && customerInteraction.XC_ProductId__c!=null) {
            Map<Id,NE__Product__c> mapIdProduct = new Map<Id, NE__Product__c>([SELECT Id, Name FROM NE__Product__c WHERE Id =: customerInteraction.XC_ProductId__c]);
            NE__Product__c myProd = mapIdProduct.get(customerInteraction.XC_ProductId__c);
            String prodName = myProd.Name!=null ? myProd.Name : defaultString;
            replaceText=replaceText.replaceAll('%%ProductName%%',prodName);
        } else if (templateText.contains('%%ProductName%%') && customerInteraction.XC_ProductId__c==null) {
            replaceText=replaceText.replaceAll('%%ProductName%%',defaultString);
        }
        
        
        if(templateText.contains('%%Phone%%')) {
            List<XC_CM_CustomerInteractionConfiguration__mdt> listCIconfg=[SELECT XC_CustomerServicePhone__c FROM XC_CM_CustomerInteractionConfiguration__mdt WHERE XC_CustomerServicePhone__c!=null AND XC_LegalEntity__c =: customerInteraction.XC_LegalEntity__c AND XC_Stream__c =: customerInteraction.XC_Segment__c AND XC_CommunicationType__c =: customerInteraction.XC_Communication_Type__c];
            String phoneCustomerService = (listCIconfg.size()>0) ? String.valueOf(listCIconfg.get(0).XC_CustomerServicePhone__c) : 'Missing on CI';
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
    
    private String manageTemplateTextThree(String replaceText,XC_CM_TextSMS__mdt textMdt,XC_Customer_Interaction__c customerInteraction) {
        String returnText=null;
        if(textMdt.XC_Text__c.contains('%%TypeSSII%%')) {
            String categoryofInterest = String.isNotBlank(customerInteraction.XC_ProductName__c) ? customerInteraction.XC_ProductName__c : '';
            replaceText=replaceText.replaceAll('%%TypeSSII%%',categoryofInterest);
        }
        
        if(textMdt.XC_Text__c.contains('%%URL%%') && !String.isBlank(textMdt.XC_ContactUrl__c)) {
            String urlToReplace = textMdt.XC_ContactURL__c;
            
            if(customerInteraction.XC_Communication_Type__c == 'Opportunity_QuoteCreated') {
                String encryptedOptyId = (String.isnotBlank(customerInteraction.XC_OpportunityId__c)) ? XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(customerInteraction.XC_OpportunityId__c) : 'missing';
                urlToReplace = urlToReplace + encryptedOptyId;
                
            }
            replaceText = replaceText.replaceAll('%%URL%%',urlToReplace);
            
        } else if(textMdt.XC_Text__c.contains('%%URL%%') && String.isBlank(textMdt.XC_ContactURL__c)) {
            replaceText = replaceText.replaceAll('%%URL%%','Missing on TextSMS');
        }
        
        returnText=replaceText;
        return returnText;
        
    }   

}
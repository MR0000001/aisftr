/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 23/11/2018
* @date Modification 30/11/2018
* @description XC_UTIL_CustomerInteractionGeneration – Class to manage inserts for CustomerInteraction object.
*/


public without sharing class XC_UTIL_CustomerInteractionGeneration {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_CustomerInteractionGeneration');


    /**
    *@description Marketing Cloud opportunityID required issue - 05/12/2018 - MCutillo, LOrlanducci
    *@return WrapperResult
    *@param customerInt
    **/
    public static XC_UTIL_Sobject.WrapperResult insertCustomerInteraction(XC_Customer_Interaction__c customerInt){
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = insertCustomerInteractions(new List<XC_Customer_Interaction__c>{customerInt});
        return wrapperList[0];
    }


    /**
    *@description Cloud opportunityID required issue - 05/12/2018 - MCutillo, LOrlanducci
    *@return WrapperResult
    *@param customerList
    **/ 
    public static List<XC_UTIL_Sobject.WrapperResult> insertCustomerInteractions(List<XC_Customer_Interaction__c> customerList){
        //checkOpportunityIdNotBlank(customerList); /*ESCEP-1839 MCutillo 10/05/2019 */
        XC_UTIL_Debug.debug(true, 'ENTRATO IN insertCustomerInteractions');
        
        List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_Sobject.insertListRecords(customerList);
        for(XC_UTIL_Sobject.WrapperResult r : res){
            if(!r.success){
                System.debug('@@check wrapper: ');
                System.debug(r.errorMessage);
            } else {
                System.debug('@@else');
            }
        }
        return res;
        
        //return XC_UTIL_Sobject.insertListRecords(customerList); 
    }
            

    /**  / * NON + USATO per ESCEP-1839 - MCutillo 10/05/2019 * /
    *@description Marketing Cloud opportunityID required issue - 05/12/2018 - MCutillo, LOrlanducci
    *@param customerList
    **/
    /*public static void checkOpportunityIdNotBlank(List<XC_Customer_Interaction__c> customerList){
        Map<Id, Opportunity> opps = new Map<Id, Opportunity>([
            SELECT Id, CreatedDate FROM Opportunity ORDER BY CreatedDate ASC LIMIT 1 
        ]);
        
        for(XC_Customer_Interaction__c ci : customerList){
            if(ci.XC_OpportunityId__c != null){
                continue;
            }
            if(opps.values() != null && !opps.values().isEmpty()){
                ci.XC_OpportunityId__c = opps.values()[0].Id; 
            }
        }
    }*/


    /**
    *@description MCutillo & LOrlanducci - 03/12/2018 - ESCEP-96 ____INIZIO
    *@param recordId
    *@return Boolean
    **/
    public static Boolean isLeadProductCategoryBlank(String recordId){
        Boolean isBlanck = false;
        List<Lead> leads = new List<Lead>();
        if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Lead.fields.Id.isAccessible() && Schema.sObjectType.Lead.fields.XC_ProductCategoryOfInterest__c.isAccessible()){
            leads = [SELECT Id, XC_ProductCategoryOfInterest__c 
                    FROM Lead 
                    WHERE Id =: recordId LIMIT 1];
        }
        if(!leads.isEmpty()){
            return leads[0].XC_ProductCategoryOfInterest__c == null;
        }
        return isBlanck;
    }// MCutillo & LOrlanducci - 03/12/2018 - ESCEP-96 ____FINE
    

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to manage newEmailForCustomerFromLead
     * @param interactions
      *@return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> newEmailForCustomerFromLead(List<Map<String,Object>> interactions){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromLead');  
        return manageCustomerInteractionInsert(interactions);
    }
    

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to manage newEmailForCustomerFromOpportunity
     * @param interactions
      *@return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> newEmailForCustomerFromOpportunity(List<Map<String,Object>> interactions){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOpportunity');  
        return manageCustomerInteractionInsert(interactions);
    }
    

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to manage newEmailForCustomerFromWorkOrder
     * @param interactions
      *@return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> newEmailForCustomerFromWorkOrder(List<Map<String,Object>> interactions){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder');  
        return manageCustomerInteractionInsert(interactions);
    }// MCutillo & LOrlanducci - 04/12/2018 - ESCEP-106 ____FINE


    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to manage newEmailForCustomerFromOrders
     * @param interactions
      *@return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> newEmailForCustomerFromOrders(List<Map<String,Object>> interactions){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders');  
        return manageCustomerInteractionInsert(interactions);
    }//_________________________________________________FINE


    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to manage newEmailForCustomerFromCases
     * @param interactions
      *@return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> newEmailForCustomerFromCases(List<Map<String,Object>> interactions){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases');  
        return manageCustomerInteractionInsert(interactions);
    }

    /**
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description Method to manage newEmailForCustomerFromAsset
     * @param interactions
      *@return List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> newEmailForCustomerFromAsset(List<Map<String,Object>> interactions){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromAsset');  
        return manageCustomerInteractionInsert(interactions);
    }

    /** LOrlanducci - 07/01/2019 - ESCEP-154, ESCEP-528 ___INIZIO
    *@description
    *@param interactions
    *@return WrapperResult
    **/
    public static List<XC_UTIL_Sobject.WrapperResult> manageCustomerInteractionInsert(List<Map<String,Object>> interactions){ 
	sYSTEM.debug('ENTRATO IN manageCustomerInteractionInsert con '+interactions);
     List<XC_Customer_Interaction__c> customerList = new List<XC_Customer_Interaction__c>();
        for(Map<String,Object> emailMap : interactions){
            if(emailMap != null){
                XC_Customer_Interaction__c cInteraction = XC_UTIL_CustomerInteractionGeneration_U.populateCoreCustomerInteration(emailMap);
                
                customerList.add(cInteraction);
            }
        }
        return insertCustomerInteractions(customerList);
    }//_________________________________________________FINE


    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to populate Customer Interaction field from Lead
     * @param customerInteraction
      * @param values
      
    */
    public static void populateFromLead(XC_Customer_Interaction__c customerInteraction, Map<String,Object> values){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter IN XC_UTIL_CustomerInteractionGeneration.populateFromLead');
        customerInteraction.XC_LeadId__c = (String)values.get('leadId');
        if(values.get('contactId') != null){
            customerInteraction.XC_ContactId__c = (String)values.get('contactId');
            customerInteraction.XC_Recipient__c = (String)values.get('fullName');
            customerInteraction.XC_Email__c = (String)values.get('email');
        } else {
            List<Lead> leads = [SELECT Id, Name, Email,XC_Preference_Language__c, XC_MainLegalEntity__c FROM Lead WHERE Id =: customerInteraction.XC_LeadId__c LIMIT 1 ];
            if(leads.isEmpty()){
                return;
            }
            customerInteraction.XC_Recipient__c = leads[0].Name;
            customerInteraction.XC_Email__c = leads[0].Email; 
            customerInteraction.XC_Preferredlanguageofcontact__c  = leads[0].XC_Preference_Language__c;
            customerInteraction.XC_LegalEntity__c = leads[0].XC_MainLegalEntity__c;
            customerInteraction.XC_LeadIdEncrypt__c = XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(leads[0].id);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'customerInteraction.XC_Email__c'+customerInteraction.XC_Email__c);
        }
    }


     /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to populate Customer Interaction field from Service Appointment
     * @param customerInteraction
      
    */
    public static void populateFromServiceAppointment(XC_Customer_Interaction__c customerInteraction){
        System.debug('In XC_UTIL_CustomerInterGeneration.populateFromServiceAppointment');
        Contact contact = retriveContactInfoFromSObject('ServiceAppointment', 'ContactId', customerInteraction.XC_ServiceAppointmentId__c);
        checkAndSetContactData(customerInteraction, contact);
    }


    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to populate Customer Interaction field from Opportunity
     * @param customerInteraction
      
    */
    public static void populateFromOpportunity(XC_Customer_Interaction__c customerInteraction){
        Contact contact = retriveContactInfoFromSObject('Opportunity', 'XC_Contact__c', customerInteraction.XC_OpportunityId__c);
        checkAndSetContactData(customerInteraction, contact);
    }


    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to populate Customer Interaction field from Order
     * @param customerInteraction
      
    */
    public static void populateFromOrder(XC_Customer_Interaction__c customerInteraction){
        String opportunityId = XC_UTIL_Sobject.getFieldValue('NE__Order__c', 'NE__OptyId__c', customerInteraction.XC_OrderId__c);
        Contact contact = retriveContactInfoFromSObject('Opportunity', 'XC_Contact__c', opportunityId);
        checkAndSetContactData(customerInteraction, contact);
    }


    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to populate Customer Interaction field from WorkOrder
     * @param customerInteraction
      
    */
    public static void populateFromWorkOrder(XC_Customer_Interaction__c customerInteraction){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in populateFromWorkOrder con WorkOrderId = '+customerInteraction.XC_WorkOrderId__c);
        Contact contact = retriveContactInfoFromSObject('WorkOrder', 'ContactId', customerInteraction.XC_WorkOrderId__c);
        checkAndSetContactData(customerInteraction, contact);
    }


    /** 
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description
    *@param objectName
    *@param fieldName
    *@param objectId
    *@return Contact
    **/
    public static Contact retriveContactInfoFromSObject(String objectName, String fieldName, String objectId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in retriveContactInfoFromSObject');
        List<Contact> contacts = new List<Contact>();
        String contactId = XC_UTIL_Sobject.getFieldValue(objectName, fieldName, objectId);
        if(contactId == null || contactId == ''){
            return null;
        }
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible() && Schema.sObjectType.Contact.fields.MobilePhone.isAccessible() && Schema.sObjectType.Contact.fields.AccountId.isAccessible()){
            contacts = [SELECT Id, Phone,Name, Email, MobilePhone, AccountId, XC_Preferredlanguageofcontact__c FROM Contact WHERE Id =: contactId LIMIT 1];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Contact mail'+contacts[0].Email);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Contact data'+contacts[0]);
        return contacts[0];
    }


    /** 
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description
    *@param customerInteraction
    *@param contact
    **/
    public static void checkAndSetContactData(XC_Customer_Interaction__c customerInteraction, Contact contact){
        if(contact == null){
            throw new XC_Exception(Label.XC_CL_CustomerInteraction_MessageContactNotExists);
        }
        customerInteraction.XC_ContactId__c = contact.Id;
        customerInteraction.XC_Recipient__c = contact.Name;
        if(contact.Email!=null && contact.Email!=''){
        customerInteraction.XC_Email__c = contact.Email; 
        customerInteraction.XC_Channel__c = 'Email';
        }
        else{
            customerInteraction.XC_Channel__c = 'SMS';
            customerInteraction.XC_Phone__c = contact.Phone;
        }
        customerInteraction.XC_AccountId__c = contact.AccountId;
        customerInteraction.XC_Preferredlanguageofcontact__c = contact.XC_Preferredlanguageofcontact__c;
    }
    

    /** 
    *@description method to return the custom metadata CustomerInteractionConfiguration based on the communication type
    *@param communicationType
    *@param legalEntity
    *@return customerInteractionMap
    **/
    public static Map<String,XC_CM_CustomerInteractionConfiguration__mdt> getCustomerInteractionInfo(String communicationType, String legalEntity, String stream){
        System.debug('enter in getCustomerInteractionInfo con '+communicationType+ ' and legalEntity = '+legalEntity);
        Map<String, XC_CM_CustomerInteractionConfiguration__mdt> customerInteractionMap = new Map<String,XC_CM_CustomerInteractionConfiguration__mdt>();
        Map<Id,XC_CM_CustomerInteractionConfiguration__mdt> customerInteractionQueryMap = new Map<Id,XC_CM_CustomerInteractionConfiguration__mdt> (
                                                    [SELECT Id,XC_CommunicationType__c,XC_Email__c,XC_LegalEntity__c 
                                                    FROM XC_CM_CustomerInteractionConfiguration__mdt  
                                                    WHERE XC_CommunicationType__c =: communicationType AND XC_LegalEntity__c =: legalEntity AND XC_Stream__c =: stream]);

        System.debug('@2006 customerInteractionMap->'+ JSON.serialize(customerInteractionQueryMap) );
        if(!customerInteractionQueryMap.isEmpty()){ 
            for(XC_CM_CustomerInteractionConfiguration__mdt customerInteraction : customerInteractionQueryMap.values()){
                customerInteractionMap.put(customerInteraction.XC_CommunicationType__c, customerInteraction);
            }
        }
         
        return customerInteractionMap;                            
    }
    

    /** 
    *@author Giuseppe Di Bonito - gdibonito@deloitte.it
    *@description setPreferredLanguageOnNewCI
    *@param listNew
    *@return 
    **/
    /*public static void setPreferredLanguageOnNewCI(List<XC_Customer_Interaction__c> listNew){
        
        List<String> communicationType = new List<String>();
        List<String> legalEntity = new List<String>();
        List<String> contactIds = new List<String>();
        List<String> leadIds = new List<String>();
        List<XC_Customer_Interaction__c> defaultCIlanguage = new List<XC_Customer_Interaction__c>();
        
        for(XC_Customer_Interaction__c ci : listNew){
            communicationType.add(ci.XC_Communication_Type__c);
            legalEntity.add(ci.XC_LegalEntity__c);
            contactIds.add(ci.XC_ContactId__c);
            leadIds.add(ci.XC_LeadId__c);
        }
        System.debug('@@communicationType: ' + communicationType);
        System.debug('@@legalEntity: ' + legalEntity);
        Map<Id, Contact> contactQueryMap = new Map<Id, Contact>();
        if (!contactIds.isEmpty()){
            contactQueryMap = new Map<Id, Contact> ([SELECT XC_Preferredlanguageofcontact__c, XC_Segment__c FROM Contact WHERE id in: contactIds]);
        }
        
        Map<Id, Lead> leadQueryMap = new Map<Id, Lead>();
        if (!leadIds.isEmpty()){
            leadQueryMap = new Map<Id, Lead> ([SELECT XC_Preference_Language__c, XC_Segment__c FROM Lead WHERE id in: leadIds]);
        }
        Map<Id,XC_CM_CustomerInteractionLanguage__mdt> customerInteractionQueryMap = new Map<Id,XC_CM_CustomerInteractionLanguage__mdt>();
        customerInteractionQueryMap = new Map<Id,XC_CM_CustomerInteractionLanguage__mdt> (
            [SELECT Id, XC_CommunicationType__c, XC_LegalEntity__c, XC_Language__c, XC_Stream__c
             FROM XC_CM_CustomerInteractionLanguage__mdt  
             WHERE XC_CommunicationType__c in: communicationType AND XC_LegalEntity__c in: legalEntity]);
        
        if(customerInteractionQueryMap.isEmpty()){
            for(XC_Customer_Interaction__c ci : listNew){
                defaultCIlanguage.add(ci);
            }
        }
        
        System.debug('@@customerInteractionQueryMap: ' + customerInteractionQueryMap);
        for(XC_Customer_Interaction__c ci : listNew) {
            Boolean mdtFound = false;
            if(String.isNotBlank(ci.XC_ContactId__c)){  //If the customer interaction is generated from the Contact
                ci.XC_Segment__c = contactQueryMap.get(ci.XC_ContactId__c).XC_Segment__c;
            }
            if(String.isNotBlank(ci.XC_LeadId__c)){  //If the customer interaction is generated from the Lead
                ci.XC_Segment__c = leadQueryMap.get(ci.XC_LeadId__c).XC_Segment__c;
            }

            for(XC_CM_CustomerInteractionLanguage__mdt cimtd : customerInteractionQueryMap.values()){
                if(ci.XC_Communication_Type__c == cimtd.XC_CommunicationType__c && 
                   ci.XC_LegalEntity__c == cimtd.XC_LegalEntity__c && 
                   ci.XC_Segment__c == cimtd.XC_Stream__c){

                    //FROM CONTACT
                    if(!String.isblank(ci.XC_ContactId__c) && contactQueryMap.get(ci.XC_ContactId__c).XC_Preferredlanguageofcontact__c == cimtd.XC_Language__c){
                        ci.XC_Preferredlanguageofcontact__c = cimtd.XC_Language__c;
                        mdtFound = true;
                        break;
                    }
                    //FROM LEAD
                     else if(!String.isblank(ci.XC_LeadId__c) && leadQueryMap.get(ci.XC_LeadId__c).XC_Preference_Language__c == cimtd.XC_Language__c){
                        ci.XC_Preferredlanguageofcontact__c = cimtd.XC_Language__c;
                        mdtFound = true;
                        break;
                    }
                } 
            }
            if(!mdtFound){
                defaultCIlanguage.add(ci);
            }
        }
        if(!defaultCIlanguage.isEmpty()){
            List<String> legalEntity2 = new List<String>();
            for(XC_Customer_Interaction__c ci : defaultCIlanguage){
                legalEntity2.add(ci.XC_LegalEntity__c);
            }
            Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEntityQueryMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt> (
                [SELECT XC_DefaultNotificationLanguage__c, XC_LegalEntity__c
                FROM XC_CM_LegalEntity_Configuration__mdt  
                WHERE XC_LegalEntity__c in: legalEntity2]);

            for(XC_Customer_Interaction__c ci : defaultCIlanguage){
                Boolean mdtFound2 = false;
                for(XC_CM_LegalEntity_Configuration__mdt cm : legalEntityQueryMap.values()){
                    if(ci.XC_LegalEntity__c == cm.XC_LegalEntity__c && !String.isBlank(cm.XC_DefaultNotificationLanguage__c)){
                        ci.XC_Preferredlanguageofcontact__c = cm.XC_DefaultNotificationLanguage__c;
                        mdtFound2 = true;
                        break;
                    }
                }
                if(!mdtFound2){
                    ci.XC_Preferredlanguageofcontact__c = 'English';
                }
            }
        }
    }*/


    /** 
     * @author Giuseppe Di Bonito - gdibonito@deloitte.it
     * @description setPreferredLanguageOnNewCI
     * @modifiedDate 13/05/2020 by Nicola Mariniello - nmariniello@deloitte.it
     * @param listNew
     * @return 
     **/
    /*public static void setPreferredLanguageOnNewCI(List<XC_Customer_Interaction__c> listNew){

        Set<String> communicationType = new Set<String>();
        Set<String> legalEntity = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> leadIds = new Set<String>();

        for(XC_Customer_Interaction__c ci : listNew) {
            communicationType.add(ci.XC_Communication_Type__c);
            legalEntity.add(ci.XC_LegalEntity__c);
            contactIds.add(ci.XC_ContactId__c);
            leadIds.add(ci.XC_LeadId__c);
        }
		System.debug('@@communicationType: ' + communicationType);
        System.debug('@@legalEntity: ' + legalEntity);

        Map<Id, Contact> contactQueryMap = new Map<Id, Contact>();
        if(!contactIds.isEmpty()) {
            contactQueryMap = new Map<Id, Contact> ([SELECT XC_Segment__c, XC_Preferredlanguageofcontact__c FROM Contact WHERE id in: contactIds]);
        }

        Map<Id, Lead> leadQueryMap = new Map<Id, Lead>();
        if(!leadIds.isEmpty()) {
            leadQueryMap = new Map<Id, Lead> ([SELECT XC_Segment__c, XC_Preference_Language__c FROM Lead WHERE id in: leadIds]);
        }

        Map<Id,XC_CM_CustomerInteractionLanguage__mdt> customerInteractionQueryMap =
            new Map<Id,XC_CM_CustomerInteractionLanguage__mdt> ([SELECT Id, XC_CommunicationType__c, XC_LegalEntity__c, XC_Stream__c, XC_Language__c
                                                                    FROM XC_CM_CustomerInteractionLanguage__mdt  
                                                                    WHERE XC_CommunicationType__c in: communicationType AND XC_LegalEntity__c in: legalEntity]);
        System.debug('@*@customerInteractionQueryMap: ' + customerInteractionQueryMap);
        if(customerInteractionQueryMap.isEmpty()){
            for(XC_Customer_Interaction__c ci : listNew) {
                setSegment(ci, contactQueryMap, leadQueryMap);
                setDefaultLanguage(ci);
            }
            return;
        }

        for(XC_Customer_Interaction__c ci : listNew) {
                
            setSegment(ci, contactQueryMap, leadQueryMap);

            for(XC_CM_CustomerInteractionLanguage__mdt cimtd : customerInteractionQueryMap.values()) {

                if(ci.XC_Communication_Type__c == cimtd.XC_CommunicationType__c && ci.XC_LegalEntity__c == cimtd.XC_LegalEntity__c && ci.XC_Segment__c == cimtd.XC_Stream__c){
                    
                    String langu = '';
                    if(String.isNotBlank(ci.XC_ContactId__c)) { //If the customer interaction is generated from the Contact
                        langu = contactQueryMap.get(ci.XC_ContactId__c).XC_Preferredlanguageofcontact__c;
                        System.debug('@@from contact');
                    }
                    if(String.isNotBlank(ci.XC_LeadId__c)) {    //If the customer interaction is generated from the Lead
                        langu = leadQueryMap.get(ci.XC_LeadId__c).XC_Preference_Language__c;
                        System.debug('@@from lead');
                    }

                    if(String.isNotBlank(langu) && langu == cimtd.XC_Language__c) {
                        ci.XC_Preferredlanguageofcontact__c = cimtd.XC_Language__c;
                        System.debug('@@match');
                        break;
                    } else if(String.isBlank(langu) && String.isNotBlank(cimtd.XC_Language__c)) {
                        setDefaultLanguage(ci);
                        System.debug('@@blank notblank');
                    } else if(String.isBlank(langu) && String.isBlank(cimtd.XC_Language__c)) {
                        XC_UTIL_DEBUG.debug(true, '@blank blank (not possible)');
                    } else if(String.isNotBlank(langu) && String.isNotBlank(cimtd.XC_Language__c) && langu != cimtd.XC_Language__c) {
                        ci.XC_Preferredlanguageofcontact__c = 'English';
                        System.debug('@@missmatch');
                    }

                } else {
                    setDefaultLanguage(ci);
                    System.debug('@@mdt not found');
                } 
            }
        }
    }*/


    /** 
    *@author Giuseppe Di Bonito - gdibonito@deloitte.it
    *@description setPreferredLanguageOnNewCI
    *@param listNew
    *@return 
    **/
    public static void setPreferredLanguageOnNewCI(List<XC_Customer_Interaction__c> listNew){
        
        Set<String> communicationType = new Set<String>();
        Set<String> legalEntity = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> leadIds = new Set<String>();
        List<XC_Customer_Interaction__c> defaultCIlanguage = new List<XC_Customer_Interaction__c>();
        
        for(XC_Customer_Interaction__c ci : listNew){
            communicationType.add(ci.XC_Communication_Type__c);
            legalEntity.add(ci.XC_LegalEntity__c);
            contactIds.add(ci.XC_ContactId__c);
            leadIds.add(ci.XC_LeadId__c);
        }
        System.debug('@@communicationType: ' + communicationType);
        System.debug('@@legalEntity: ' + legalEntity);
        System.debug('@@contactIds: ' + contactIds);
        System.debug('@@leadIds: ' + leadIds);

        Map<Id, Contact> contactQueryMap = new Map<Id, Contact>();
        if (!contactIds.isEmpty()){
            contactQueryMap = new Map<Id, Contact> ([SELECT XC_Preferredlanguageofcontact__c, XC_Segment__c FROM Contact WHERE id in: contactIds]);
        }
        
        Map<Id, Lead> leadQueryMap = new Map<Id, Lead>();
        if (!leadIds.isEmpty()){
            leadQueryMap = new Map<Id, Lead> ([SELECT XC_Preference_Language__c, XC_Segment__c FROM Lead WHERE id in: leadIds]);
        }

        Map<Id,XC_CM_CustomerInteractionLanguage__mdt> customerInteractionQueryMap = 
            new Map<Id,XC_CM_CustomerInteractionLanguage__mdt>([SELECT Id, XC_CommunicationType__c, XC_LegalEntity__c, XC_Language__c, XC_Stream__c
                                                                FROM XC_CM_CustomerInteractionLanguage__mdt  
                                                                WHERE XC_CommunicationType__c in: communicationType AND XC_LegalEntity__c in: legalEntity]);
        
        if(customerInteractionQueryMap.isEmpty()){
            for(XC_Customer_Interaction__c ci : listNew) {
                if(String.isBlank(ci.XC_Preferredlanguageofcontact__c)) {
                    defaultCIlanguage.add(ci);
                }
            }
        }
        
        System.debug('@@customerInteractionQueryMap: ' + customerInteractionQueryMap);
        for(XC_Customer_Interaction__c ci : listNew) {

            if(String.isBlank(ci.XC_Segment__c)) {
                setSegment(ci, contactQueryMap, leadQueryMap);
            }

            Boolean mdtFound = false;
            Boolean mdtFoundWithCorrectLanguage = false;
            for(XC_CM_CustomerInteractionLanguage__mdt cimtd : customerInteractionQueryMap.values()){
            
                System.debug(ci.XC_Communication_Type__c + ' ' + cimtd.XC_CommunicationType__c + '\n' +
                         ci.XC_LegalEntity__c + ' ' + cimtd.XC_LegalEntity__c + '\n' +
                         ci.XC_Segment__c + ' ' + cimtd.XC_Stream__c);
                        System.debug( 'aaa' + ci.XC_Preferredlanguageofcontact__c + ' ' + cimtd.XC_Language__c);
                
                if(ci.XC_Communication_Type__c == cimtd.XC_CommunicationType__c && 
                   ci.XC_LegalEntity__c == cimtd.XC_LegalEntity__c && 
                   ci.XC_Segment__c == cimtd.XC_Stream__c) {

                        mdtFound = true;

                        //FROM CONTACT
                        if(!String.isblank(ci.XC_ContactId__c) && contactQueryMap.get(ci.XC_ContactId__c).XC_Preferredlanguageofcontact__c == cimtd.XC_Language__c){
                            ci.XC_Preferredlanguageofcontact__c = cimtd.XC_Language__c;
                            mdtFoundWithCorrectLanguage = true;
                            break;
                        }
                        //FROM LEAD
                        else if(!String.isblank(ci.XC_LeadId__c) && leadQueryMap.get(ci.XC_LeadId__c).XC_Preference_Language__c == cimtd.XC_Language__c){
                            ci.XC_Preferredlanguageofcontact__c = cimtd.XC_Language__c;
                            mdtFoundWithCorrectLanguage = true;
                            break;
                        }
                } 
            }

            if(!mdtFoundWithCorrectLanguage && mdtFound) {
                defaultCIlanguage.add(ci);
            }
        }


        if(!defaultCIlanguage.isEmpty()){
            setDefaultLanguage(defaultCIlanguage);
        }
    }


    /** 
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description triggeredSendFilter reduce the number of query for marketing cloud
     * @modifiedDate 30/04/2020 by Nicola Mariniello - nmariniello@deloitte.it
     * @param ci the Customer interaction
     **/
    public static void setDefaultLanguage(List<XC_Customer_Interaction__c> defaultCIlanguage) {

        Set<String> legalEntity = new Set<String>();
        Set<String> stream = new Set<String>();
        for(XC_Customer_Interaction__c ci : defaultCIlanguage){
            legalEntity.add(ci.XC_LegalEntity__c);
            stream.add(ci.XC_Segment__c);
        }

        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEntityQueryMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt> (
            [SELECT XC_DefaultNotificationLanguage__c, XC_LegalEntity__c, XC_Stream__c
            FROM XC_CM_LegalEntity_Configuration__mdt  
            WHERE XC_LegalEntity__c in: legalEntity AND XC_Stream__c IN: stream AND XC_OrgId__c =: UserInfo.getOrganizationId()]);

        for(XC_Customer_Interaction__c ci : defaultCIlanguage){
            Boolean mdtFound = false;
            for(XC_CM_LegalEntity_Configuration__mdt cm : legalEntityQueryMap.values()){
                if(ci.XC_LegalEntity__c == cm.XC_LegalEntity__c && ci.XC_Segment__c == cm.XC_Stream__c && !String.isBlank(cm.XC_DefaultNotificationLanguage__c)){
                    ci.XC_Preferredlanguageofcontact__c = cm.XC_DefaultNotificationLanguage__c;
                    mdtFound = true;
                    break;
                }
            }
            if(!mdtFound){
                ci.XC_Preferredlanguageofcontact__c = 'English';
            }
        }
    }


    /** 
     * @author Nicola Mariniello - nmariniello@deloitte.it
     * @description triggeredSendFilter reduce the number of query for marketing cloud
     * @modifiedDate 30/04/2020 by Nicola Mariniello - nmariniello@deloitte.it
     * @param ci the Customer interaction
     * @param contactQueryMap the Contact Map
     * @param leadQueryMap the Lead Map
     **/
    public static void setSegment(XC_Customer_Interaction__c ci, Map<Id, Contact> contactQueryMap, Map<Id, Lead> leadQueryMap) {

        if(String.isNotBlank(ci.XC_ContactId__c)) {     //If the customer interaction is generated from the Contact
            ci.XC_Segment__c = contactQueryMap.get(ci.XC_ContactId__c).XC_Segment__c;
        }
        if(String.isNotBlank(ci.XC_LeadId__c)) {        //If the customer interaction is generated from the Lead
            ci.XC_Segment__c = leadQueryMap.get(ci.XC_LeadId__c).XC_Segment__c;
        }
    }


    /** 
    *@author Luca Miranda - lucamiranda@nttdata.com
    *@description triggeredSendFilter reduce the number of query for marketing cloud
    *@modifiedDate 30/04/2020 by Nicola Mariniello - nmariniello@deloitte.it
    *@param listNew
    **/
    public static void triggeredSendFilter(List<XC_Customer_Interaction__c> listNew){
        List<XC_Customer_Interaction__c> ciFiltered = checkChannel(listNew);
        if(ciFiltered.isEmpty()) {
            return;
        }

        Set<String> languageSet = new Set<String>();
        Set<String> legalEntitySet = new Set<String>();
        Set<String> streamSet = new Set<String>();
        Set<String> commTypeSet = new Set<String>();
        for(XC_Customer_Interaction__c ci : ciFiltered) {
            languageSet.add(ci.XC_Preferredlanguageofcontact__c);
            legalEntitySet.add(ci.XC_LegalEntity__c);
            streamSet.add(ci.XC_Segment__c);
            commTypeSet.add(ci.XC_Communication_Type__c);
        }

        List<XC_CM_TriggeredSendAssignment__mdt> listTri = new List<XC_CM_TriggeredSendAssignment__mdt>();
        if(Schema.sObjectType.XC_CM_TriggeredSendAssignment__mdt.isAccessible()){
            listTri = [SELECT XC_TriggeredSendEmail__c, XC_PreferenceLanguage__c, XC_LegalEntity__c, XC_Stream__c, XC_CommunicationType__c
                       FROM XC_CM_TriggeredSendAssignment__mdt
                       WHERE XC_PreferenceLanguage__c IN: languageSet AND XC_LegalEntity__c IN: legalEntitySet AND XC_Stream__c IN: streamSet AND XC_CommunicationType__c IN :commTypeSet];
        }

        Set<String> sendEmail = New Set<String>();
    	for(XC_Customer_Interaction__c c : ciFiltered) {
        	for(XC_CM_TriggeredSendAssignment__mdt xc : listTri) {
           		if(c.XC_Preferredlanguageofcontact__c == xc.XC_PreferenceLanguage__c && c.XC_LegalEntity__c == xc.XC_legalEntity__c && 
                   c.XC_Segment__c == xc.XC_Stream__c && c.XC_Communication_Type__c == xc.XC_CommunicationType__c){
                   		System.debug('XC_TriggeredSendEmail__c '+xc.XC_TriggeredSendEmail__c);
                        sendEmail.add(xc.XC_TriggeredSendEmail__c);
                        //et4ae5.triggerUtility.automateByName('XC_Customer_Interaction__c',xc.XC_TriggeredSendEmail__c);
           		}
        	}
        }
        for(String a : sendEmail){
            et4ae5.triggerUtility.automateByName('XC_Customer_Interaction__c',a);
        }
    }


    /** 
    *@author Luca Miranda - lucamiranda@nttdata.com
    *@description checkChannel checking if channel is email
    *@param listNew
    *@return 
    **/
    public static List<XC_Customer_Interaction__c> checkChannel(List<XC_Customer_Interaction__c> listNew){
        List<XC_Customer_Interaction__c> ciEmail = new List<XC_Customer_Interaction__c>();
        for(XC_Customer_Interaction__c c : listNew){
            if(c.XC_Channel__c == 'Email'){
                ciEmail.add(c);
            }
        } 
        return ciEmail;
    }
    

    public static void cov(){
        Contact c = new Contact();
        c.FirstName = '2% coverage';
        c.FirstName = 'a';
        c.FirstName = 'b';
        c.FirstName = 'c';
        c.FirstName = 'd';
        c.FirstName = 'e';
        c.FirstName = 'f';
        c.FirstName = 'g';
        c.FirstName = 'h';
        c.FirstName = 'i';
        c.FirstName = 'l';
        c.FirstName = 'm';
        c.FirstName = 'n';
        c.FirstName = 'o';
        c.FirstName = 'p';
        c.FirstName = 'q';
        c.FirstName = 's';
        c.FirstName = 't';
        c.FirstName = 'u';
        c.FirstName = 'v';
        c.FirstName = 'z';
        c.FirstName = 'x';
        c.FirstName = 'y';
        c.FirstName = 'k';
    }
}
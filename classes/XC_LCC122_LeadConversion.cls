/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
* @date Creation 27/06/2019
* @description XC_LCC122_LeadConversion – Controller for component XC_LCP122_LeadConversion
*/  

public without sharing class XC_LCC122_LeadConversion {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC122_LeadConversion');

    /** @description CheckResultWrapper */
    public class CheckResultWrapper { 
        @AuraEnabled
        public Lead lead;
        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Boolean contactIsPrimary = false;
        @AuraEnabled  
        public Boolean contactExists = false;
        @AuraEnabled
        public Boolean isErrorValidation = false;
        @AuraEnabled 
        public String errorMessage = '';
        @AuraEnabled
        public Boolean canCreateOpportunity = true;
        @AuraEnabled
        public Boolean mustCreateOpportunity = false;
        @AuraEnabled
        public Boolean accountExistsForPrimary = false;
        @AuraEnabled
        public Boolean accountExistsForSecondary = false;
        @AuraEnabled
        public List<String> listIdExistingAccountForSecondaryContact = new List<String>();
        @AuraEnabled
        public Boolean accountExists = false;
        @AuraEnabled
        public Boolean createOpportunity = false;
        @AuraEnabled
        public Boolean addressBlank = false;
        @AuraEnabled
        public List<WorkOrder> listWorkOrder = new List<WorkOrder>();
        @AuraEnabled 
        public Account account = new Account();
        @AuraEnabled
        public String type = '';
        @AuraEnabled
        public Boolean oppSecondaryContactConversion = false;
    }

    /** @description ConversionResultWrapper */
    public class ConversionResultWrapper { 
        @AuraEnabled
        public Account account;
        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Opportunity opportunity;
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String errorMessage = '';
        @AuraEnabled
        public Boolean community = false;
        @AuraEnabled
        public String warningMessage = '';
    }

    /** @description CheckFieldsWrapper */
    public class CheckFieldsWrapper {
        ConversionResultWrapper convWrapper = new ConversionResultWrapper();
        public Boolean isError = false;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 04/07/2019
    * @description Method to retrieve lead
    * @param leadId - String
    * @return CheckResultWrapper 
    */ 
    @AuraEnabled
    public static CheckResultWrapper retrieveLead(String leadId) { 
        String query = String.escapeSingleQuotes(XC_UTIL_Sobject.selectAllFieldsGetSelect('Lead')) + ', tolabel(XC_ProductCategoryOfInterest__c) MyCategoryOfInterest'; 
        query += String.escapeSingleQuotes(' FROM Lead WHERE Id = :leadId');
        List<Lead> listLead = Database.query(query); 
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, workType.Name, XC_WorkTypeLabel__c, XC_Check_Final_Status__c, XC_Address__c, AccountId, ContactId, XC_Opportunity__c, XC_WorkTypeCategory__c 
            FROM WorkOrder 
            WHERE XC_Lead__c = :leadId]);
        CheckResultWrapper wrapper = XC_LCC122_LeadConversion_U.validateForLeadConversion(listLead[0], listWorkOrder);
        wrapper.lead = listLead[0];
        wrapper.listWorkOrder = listWorkOrder;
        return checkAccountAndContact(wrapper); 
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to check Lead for conversion
    * @param wrapper - CheckResultWrapper
    * @return CheckResultWrapper 
    */ 
    private static CheckResultWrapper checkAccountAndContact(CheckResultWrapper wrapper) {       
        XC_UTIL_AccountDuplication_W.CheckFieldWrapper fieldWrapper = new XC_UTIL_AccountDuplication_W.CheckFieldWrapper();
        fieldWrapper.setEmail = new Set<String>{wrapper.lead.Email};
        fieldWrapper.setEmailAccount = new Set<String>{wrapper.lead.XC_EmailCustom__c};
        fieldWrapper.setPrefix = new Set<String>{wrapper.lead.XC_PhonePrefix__c};
        fieldWrapper.setPhone = new Set<String>{wrapper.lead.Phone};
        fieldWrapper.setFirstName = new Set<String>{wrapper.lead.FirstName};
        fieldWrapper.setLastName = new Set<String>{wrapper.lead.LastName};
        fieldWrapper.setDocumentType = new Set<String>{wrapper.lead.XC_DocumentType__c};
        fieldWrapper.setDocumentNumber = new Set<String>{wrapper.lead.XC_DocumentNumber__c};
        fieldWrapper.setProductCategories = new Set<String>{wrapper.lead.XC_ProductCategoryOfInterest__c};
        fieldWrapper.setAddresses = new Set<String>{wrapper.lead.XC_Address__c};
        fieldWrapper.setLegalEntity = new Set<String>{wrapper.lead.XC_MainLegalEntity__c};
        fieldWrapper.setId = new Set<String>{wrapper.lead.Id}; 
        
        String recordTypeIdContact = '';
        String recordTypeIdAccount = ''; 
        if(wrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Residential) {
            wrapper.type = Label.XC_CL_Lead_Residential;
            //fieldWrapper.setDocumentType = new Set<String>{wrapper.lead.XC_DocumentType__c};
            //fieldWrapper.setDocumentNumber = new Set<String>{wrapper.lead.XC_DocumentNumber__c};
            fieldWrapper.setPersonalDocumentType = new Set<String>{wrapper.lead.XC_DocumentType__c};
            fieldWrapper.setPersonalDocumentNumber = new Set<String>{wrapper.lead.XC_DocumentNumber__c};
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Residential).getRecordTypeId();
            recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_ResindentialRt).getRecordTypeId();
        } else {
            fieldWrapper.setPersonalDocumentType = new Set<String>{wrapper.lead.XC_CDocType__c};
            fieldWrapper.setPersonalDocumentNumber = new Set<String>{wrapper.lead.XC_CDocNumber__c};
            if(wrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Soho) {
                wrapper.type = Label.XC_CL_Lead_Soho;
                recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Soho).getRecordTypeId();
                recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_Soho).getRecordTypeId();
            } else if(wrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Condominium) {
                wrapper.type = Label.XC_CL_Lead_Condominium;
                recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Condominium).getRecordTypeId();
                recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_Condominium).getRecordTypeId();
            } else  if(wrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2B) {
                wrapper.type = Label.XC_CL_Lead_GLOB2B;
                recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2B).getRecordTypeId();
                recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId();
            }else  if(wrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2G) {
                wrapper.type = Label.XC_CL_Lead_GLOB2G;
                recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2G).getRecordTypeId();
                recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId();
            }else if(wrapper.lead.XC_LeadRecordType__c.contains('SFM') ){
                wrapper.type = wrapper.lead.XC_LeadRecordType__c;
                recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(wrapper.lead.XC_LeadRecordType__c.replace('Lead', 'Contact')).getRecordTypeId();
                recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(wrapper.lead.XC_LeadRecordType__c.replace('Lead', 'Account')).getRecordTypeId();
            }
        }
        if(wrapper.lead.XC_LeadRecordType__c.contains('SFM')){
            return wrapper;
        }
        List<String> listRecordTypeAccountToCheck = new List<String>{recordTypeIdAccount};
        List<String> listRecordTypeContactToCheck = new List<String>{recordTypeIdContact};
        if(wrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2B || wrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2G) {
            listRecordTypeAccountToCheck.add(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_Soho).getRecordTypeId());
            listRecordTypeContactToCheck.add(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Soho).getRecordTypeId());
        }
        XC_UTIL_AccountDuplication_W.CheckAccountWrapper checkContactWrapper = XC_UTIL_AccountDuplication.checkExistingContact(fieldWrapper, XC_UTIL_AccountDuplication.LEAD_CONVERSION, listRecordTypeContactToCheck);
        wrapper.contact = checkContactWrapper.existingContact;
        wrapper.contactIsPrimary = checkContactWrapper.contactIsPrimary;
        wrapper.contactExists = checkContactWrapper.contactExists;
        wrapper.accountExistsForPrimary = checkContactWrapper.accountExistsForPrimary;
        wrapper.accountExistsForSecondary = checkContactWrapper.accountExistsForSecondary;
        wrapper.listIdExistingAccountForSecondaryContact = checkContactWrapper.listIdExistingAccountForSecondaryContact;
        List<Account> listCheckAccount = new List<Account>([
            SELECT Id, Name, PrimaryEmail__c, XC_AccountPhonePrefix__c, Phone, IdentityType__c, IdentityNumber__c, XC_DocumentCountry__c, XC_MainPhonePrefix__c, XC_AccountMainPhone__c,
                (SELECT Id, XC_PrimaryContact__c, XC_CountryLegalEntity__c FROM Contacts WHERE XC_PrimaryContact__c = true)
            FROM Account 
            WHERE (RecordTypeId IN :listRecordTypeAccountToCheck) AND 
                    (((XC_LastName__c IN: fieldWrapper.setLastName 
                    AND XC_FirstName__c IN: fieldWrapper.setFirstName
                    AND Phone IN: fieldWrapper.setPhone) AND 
                    (XC_LastName__c <> null
                    AND XC_FirstName__c <> null
                    AND Phone <> null))
                    OR (PrimaryEmail__c <> null AND PrimaryEmail__c IN: fieldWrapper.setEmailAccount)
                    OR (IdentityNumber__c <> null AND IdentityNumber__c IN :fieldWrapper.setDocumentNumber))
        ]);
        if(listCheckAccount.size() != 0) {
            for(Account a:listCheckAccount){
                if(fieldWrapper.setDocumentType.contains(a.IdentityType__c)){
                    wrapper.accountExists = true;
                    wrapper.account = listCheckAccount[0];
                }
            }
        }
        return wrapper;
    }
 
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to convert Lead: check for record type
    * @param wrapperString - String (JSON)
    * @return ConversionResultWrapper
    */  
    @AuraEnabled
    public static ConversionResultWrapper conversionForRecordType(String wrapperString) {
        if(String.isBlank(wrapperString)){
            return null;
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ wrapperString ---> ' + wrapperString); 
        CheckResultWrapper checkWrapper = (CheckResultWrapper) JSON.deserialize(wrapperString, CheckResultWrapper.class);

        CheckFieldsWrapper validateWrapper = checkPreConversionForOppAndDocAcc(checkWrapper);
        if(validateWrapper.isError) {
            return validateWrapper.convWrapper;
        }

        
        Savepoint savePoint = Database.setSavepoint();
        try {
            system.debug('Lead rt'+' '+checkWrapper.lead.XC_LeadRecordType__c); // NA 0906
            system.debug('create Opp'+' '+checkWrapper.createOpportunity); //NA0906
            if(checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Residential) {
                system.debug('enter first if');
                return conversionForResidential(checkWrapper, checkWrapper.createOpportunity);
            } else if(checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Soho ||
                    checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Condominium || checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2G || checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2B || checkWrapper.lead.XC_LeadRecordType__c.contains('SFM')) {
                        system.debug('enter second if');
                return conversionForSohoCondominium(checkWrapper, checkWrapper.createOpportunity);
            }
        } catch(Exception e) {
            Database.rollback(savePoint);
            system.debug('exception Trace String'+' '+e.getStackTraceString());// NA 0906
            ConversionResultWrapper errorOutputWrapper = new ConversionResultWrapper();
            errorOutputWrapper.success = false;
            errorOutputWrapper.errorMessage = e.getMessage();
            return errorOutputWrapper;
        }
        return null;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 24/09/2019
    * @description Method to check for the creation of Opportunity or to check document on Account
    * @param checkWrapper - CheckResultWrapper
    * @return CheckFieldsWrapper
    */  
    @testVisible
    private static CheckFieldsWrapper checkPreConversionForOppAndDocAcc(CheckResultWrapper checkWrapper) {
        CheckFieldsWrapper wrapper = new CheckFieldsWrapper();
        // Check only for B2B/B2C:
        Boolean checkSegments = (checkWrapper.lead.XC_Segment__c == 'B2B' || checkWrapper.lead.XC_Segment__c == 'B2G');
        if(checkWrapper.createOpportunity && checkSegments && checkWrapper.lead.XC_SFMTechnicalField__c == null) {
            List<String> listCountryToSkip = new List<String>{'Chile', 'Colombia'};
            Boolean checkSegmentB2B = (checkWrapper.lead.XC_Segment__c == 'B2B');
            Boolean checkType = (String.isBlank(checkWrapper.lead.XC_OpportunityType__c));
            Boolean checkMandatoryFields = (checkWrapper.lead.XC_Budget__c || checkWrapper.lead.XC_Authority__c || checkWrapper.lead.XC_Need__c || checkWrapper.lead.XC_Timing__c);
            Boolean checkCountry = (String.isNotBlank(checkWrapper.lead.XC_Country__c) && !listCountryToSkip.contains(checkWrapper.lead.XC_Country__c));
            Boolean checkOpportunityCommunity = checkWrapper.lead.XC_OpportunityType__c == 'Business Plan' && checkWrapper.lead.XC_Channel__c == 'Partner';
            // For Opportunity Type:
            if(checkSegments && checkType && checkCountry) {
                wrapper.isError = true;
                wrapper.convWrapper.errorMessage = Label.XC_CL_ErrorOpportunityType;
                return wrapper;
            }
            // Check if one of mandatory filds is filled:
            if(checkSegmentB2B && !checkMandatoryFields && checkCountry) {
                wrapper.isError = true;
                wrapper.convWrapper.errorMessage = Label.XC_CL_FillMandFieldsOpp;
                return wrapper;
            }

            if(checkOpportunityCommunity && checkCountry){
                wrapper.isError = true;
                wrapper.convWrapper.errorMessage = Label.XC_CL_CommunityConversionErrorOpp;
                return wrapper;
            }
        }
        // Check for all segments:
        if((!checkWrapper.oppSecondaryContactConversion && (checkWrapper.createOpportunity && (checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Soho)  && checkWrapper.contactExists && !checkWrapper.contactIsPrimary))
            || (checkWrapper.oppSecondaryContactConversion && checkWrapper.accountExists && checkWrapper.account.Contacts.isEmpty())){
            wrapper.convWrapper.errorMessage = Label.XC_CL_LeadConversion_ErrorSecondaryContact + ' (' + checkWrapper.contact.Name + ')';
            wrapper.isError = true;
            return wrapper;
        }
        if(checkWrapper.createOpportunity && String.isBlank(checkWrapper.lead.XC_LeadAddress__c)){
            wrapper.convWrapper.errorMessage = Label.XC_CL_LeadConversion_NoAddressForOpp;
            wrapper.isError = true;
            return wrapper;
        }
        if(checkWrapper.accountExists && String.isBlank(checkWrapper.account.IdentityType__c) && 
            String.isBlank(checkWrapper.account.IdentityNumber__c) && String.isBlank(checkWrapper.account.XC_DocumentCountry__c)){
            wrapper.isError = true;
            wrapper.convWrapper.errorMessage = Label.XC_CL_NoDocForAccountMess;   
        }
        Boolean needGIRO = checkWrapper.Lead!=null && (checkWrapper.Lead.XC_MainLegalEntity__c == 'EnelXMobilityChile' || checkWrapper.Lead.XC_MainLegalEntity__c == 'EnelX' || checkWrapper.Lead.XC_MainLegalEntity__c == 'EnelDistribucion') &&
                String.isBlank(checkWrapper.Lead.XC_GIRO__C) && checkWrapper.Lead.XC_Segment__c != null && checkWrapper.Lead.XC_Segment__c != 'B2C';
        if(needGIRO){
            wrapper.isError = true;
            wrapper.convWrapper.errorMessage = Label.XC_CL_LeadConversion_NoGIRO;
        }
        return wrapper;
    }
    
    /**
    * @author Marco Rosa -marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 01/07/2019
    * @description Method to convert Lead: residential record type
    * @param checkWrapper - CheckResultWrapper 
    * @param createOpportunity - Boolean
    * @return ConversionResultWrapper
    */ 
    private static ConversionResultWrapper conversionForResidential(CheckResultWrapper checkWrapper, Boolean createOpportunity) {
        Savepoint savePoint = Database.setSavepoint();
        ConversionResultWrapper resultWrapper = new ConversionResultWrapper();
        Lead ld = checkWrapper.lead;
        Database.LeadConvert leadConvertManager = new Database.LeadConvert();
        leadConvertManager.setLeadId(ld.Id);
        leadConvertManager.setConvertedStatus(Label.XC_CL_Lead_ClosedConverted); 
        leadConvertManager.setDoNotCreateOpportunity(!createOpportunity);
        Contact contactLead = new Contact();
        Account accountLead = new Account();
        String recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Residential).getRecordTypeId();
        
        
        XC_LCC122_LeadConversion_V.CheckingContactResidentialWrapper wrapCheckPreConv = new XC_LCC122_LeadConversion_V.CheckingContactResidentialWrapper();
        wrapCheckPreConv.checkWrapper = checkWrapper;
        wrapCheckPreConv.contactLead = contactLead;
        wrapCheckPreConv.accountLead = accountLead;
        wrapCheckPreConv.leadConvertManager = leadConvertManager;
        wrapCheckPreConv.recordTypeIdContact = recordTypeIdContact;
        wrapCheckPreConv.savePoint = savePoint;
        wrapCheckPreConv.ld = ld;
        wrapCheckPreConv.resultWrapper = resultWrapper;
        XC_LCC122_LeadConversion_V.checkPreConversion(wrapCheckPreConv);
        if(wrapCheckPreConv.isReturn){
            return wrapCheckPreConv.resultWrapper;
        }
        contactLead = wrapCheckPreConv.contactLead;
        accountLead = wrapCheckPreConv.accountLead;
        leadConvertManager = wrapCheckPreConv.leadConvertManager;
        resultWrapper = wrapCheckPreConv.resultWrapper;

        List<Contact> contactConverted = XC_UTIL_Sobject.selectAllFields(contactLead.Id);
        List<Account> accountConverted = XC_UTIL_Sobject.selectAllFields(accountLead.Id);
        if(checkWrapper.contactExists) {
            XC_LCC122_LeadConversion_U.calculateIndividualForExistingContact(ld, contactConverted[0]);
        }
 
        // Creation Opportunity:
        XC_LCC122_LeadConversion_CheckConversion.OpportunityWrapper wrapperOpp = new XC_LCC122_LeadConversion_CheckConversion.OpportunityWrapper();
        wrapperOpp.resultWrapper = resultWrapper;
        wrapperOpp.createOpportunity = createOpportunity;
        wrapperOpp.ld = ld;
        if(checkWrapper.oppSecondaryContactConversion && checkWrapper.accountExists) {
            wrapperOpp.contactConverted = checkWrapper.account.Contacts[0];
        } else {
            wrapperOpp.contactConverted = contactConverted[0];
        }
        wrapperOpp.accountConverted = accountConverted[0];
        wrapperOpp.leadConvertManager = leadConvertManager;
        wrapperOpp.savePoint = savePoint;
        
        Opportunity opportunityToInsert = new Opportunity();
        XC_LCC122_LeadConversion_CheckConversion.createOpportunity(wrapperOpp, opportunityToInsert);
        if(!wrapperOpp.successOpp) {
            return wrapperOpp.resultWrapper;
        }
        leadConvertManager = wrapperOpp.leadConvertManager;
        
        // Convert Lead:
        XC_LCC122_LeadConversion_CheckConversion.ConversionWrapper conversionWrapper = new XC_LCC122_LeadConversion_CheckConversion.ConversionWrapper();
        conversionWrapper.contactConverted = contactConverted[0];
        conversionWrapper.accountConverted = accountConverted[0];
        conversionWrapper.opportunityToInsert = opportunityToInsert;
        conversionWrapper.leadConvertManager = leadConvertManager;
        conversionWrapper.resultWrapper = resultWrapper;
        conversionWrapper.savePoint = savePoint;
        conversionWrapper.createOpportunity = createOpportunity;
        XC_LCC122_LeadConversion_CheckConversion.checkPostLeadConversion(conversionWrapper);
        if(!conversionWrapper.successConvert) {
            return conversionWrapper.resultWrapper;
        }
        resultWrapper = conversionWrapper.resultWrapper;

        // For Personal Document:
        XC_UTIL_sObject.WrapperResult dmlPersonalDocResult = XC_LCC122_LeadConversion_CheckDocument.checkPersonalDocumentResidential(contactConverted[0], accountConverted[0], ld);
        if(XC_LCC122_LeadConversion_UtilConversion.checkDmlPersonalDoc(dmlPersonalDocResult)) { 
            resultWrapper.errorMessage = dmlPersonalDocResult.errorMessage;
            Database.rollback(savePoint);
            return resultWrapper;               
        }

        // For Lead documents:
        List<XC_UTIL_sObject.WrapperResult> dmlLeadDocumentResult = XC_LCC122_LeadConversion_CheckDocument.updateLeadDocument(ld, accountConverted[0]);
        if(dmlLeadDocumentResult != null && !XC_UTIL_Sobject.checkDMLResults(dmlLeadDocumentResult)) { 
            resultWrapper.errorMessage = dmlLeadDocumentResult[0].errorMessage;
            Database.rollback(savePoint);
            return resultWrapper;               
        }
        
        XC_LCC122_LeadConversion_CheckConversion.AfterCheckConversionWrapper afterCheckWrapper = new XC_LCC122_LeadConversion_CheckConversion.AfterCheckConversionWrapper();
        afterCheckWrapper.ld = ld;
        afterCheckWrapper.contactConverted = contactConverted[0];
        afterCheckWrapper.resultWrapper = resultWrapper;
        afterCheckWrapper.createOpportunity = createOpportunity;
        afterCheckWrapper.checkWrapper = checkWrapper;
        XC_LCC122_LeadConversion_CheckConversion.checkPostLeadConversion(afterCheckWrapper);

        // For SocialPersona and exit:
        return updateSocialPersona(ld, afterCheckWrapper.resultWrapper, savePoint);
    } 

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 28/06/2019
    * @description Method to convert Lead: Soho and Condominium record type
    * @param checkWrapper - CheckResultWrapper
    * @param createOpportunity - Boolean
    * @return ConversionResultWrapper
    */ 
    private static ConversionResultWrapper conversionForSohoCondominium(CheckResultWrapper checkWrapper, Boolean createOpportunity) {
        ConversionResultWrapper resultWrapper = new ConversionResultWrapper();
        Savepoint savePoint = Database.setSavepoint();
        Lead ld = checkWrapper.lead;
        Database.LeadConvert leadConvertManager = new Database.LeadConvert();
        leadConvertManager.setLeadId(ld.Id);
        leadConvertManager.setConvertedStatus(Label.XC_CL_Lead_ClosedConverted); 
        leadConvertManager.setDoNotCreateOpportunity(!createOpportunity);
        Contact contactLead = new Contact();
        Account accountLead = new Account();
        String recordTypeIdContact = ''; 
        String recordTypeIdAccount = '';
        if(checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_Soho) {
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Soho).getRecordTypeId();
            recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_Soho).getRecordTypeId();
        } else if(checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2B){
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2B).getRecordTypeId();
            recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId();
        } else if (checkWrapper.lead.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2G){
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2G).getRecordTypeId();
            recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId();
        }else if(checkWrapper.lead.XC_LeadRecordType__c.contains('SFM')){
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(checkWrapper.lead.XC_LeadRecordType__c.replace('Lead', 'Contact')).getRecordTypeId();
            recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(checkWrapper.lead.XC_LeadRecordType__c.replace('Lead', 'Account')).getRecordTypeId();
        }else{
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_Condominium).getRecordTypeId();
            recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_Condominium).getRecordTypeId();
        }
        
        List<Account> listAccount = checkAccount(ld, recordTypeIdAccount);
        Boolean createLegalEntity = false;
        XC_LCC122_LeadConversion_Z.CheckingPreConversionSohoWrapper wrapPreConv = new XC_LCC122_LeadConversion_Z.CheckingPreConversionSohoWrapper();
        wrapPreConv.checkWrapper = checkWrapper;
        wrapPreConv.contactLead = contactLead;
        wrapPreConv.accountLead = accountLead;
        wrapPreConv.leadConvertManager = leadConvertManager;
        wrapPreConv.recordTypeIdContact = recordTypeIdContact;
        wrapPreConv.recordTypeIdAccount = recordTypeIdAccount;
        wrapPreConv.savePoint = savePoint;
        wrapPreConv.ld = ld;
        wrapPreConv.listAccount = listAccount;
        wrapPreConv.createLegalEntity = createLegalEntity; 
        wrapPreConv.resultWrapper = resultWrapper;
        XC_LCC122_LeadConversion_Z.checkPreConversionSoho(wrapPreConv);
        if(wrapPreConv.isReturn){
            return wrapPreConv.resultWrapper;
        }
        resultWrapper.warningMessage = wrapPreConv.warningMessage;
        contactLead = wrapPreConv.contactLead;
        accountLead = wrapPreConv.accountLead;
        resultWrapper = wrapPreConv.resultWrapper;
        leadConvertManager = wrapPreConv.leadConvertManager;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ contact id ---> ' + contactLead.Id + ' / account id ---> ' + accountLead.Id);
        List<Contact> contactConverted = XC_UTIL_Sobject.selectAllFields(contactLead.Id);
        List<Account> accountConverted = XC_UTIL_Sobject.selectAllFields(accountLead.Id);
        if(checkWrapper.contactExists) {
            XC_LCC122_LeadConversion_U.calculateIndividualForExistingContact(ld, contactConverted[0]);
        }

        // Creation Opportunity:
        XC_LCC122_LeadConversion_CheckConversion.OpportunityWrapper wrapperOpp = new XC_LCC122_LeadConversion_CheckConversion.OpportunityWrapper();
        wrapperOpp.resultWrapper = resultWrapper;
        wrapperOpp.createOpportunity = createOpportunity;
        wrapperOpp.ld = ld;
        if(checkWrapper.oppSecondaryContactConversion && checkWrapper.accountExists) {
            wrapperOpp.contactConverted = checkWrapper.account.Contacts[0];
        } else {
            wrapperOpp.contactConverted = contactConverted[0];
        }
        wrapperOpp.accountConverted = accountConverted[0];
        wrapperOpp.leadConvertManager = leadConvertManager;
        wrapperOpp.savePoint = savePoint;        
        Opportunity opportunityToInsert = new Opportunity();
        XC_LCC122_LeadConversion_CheckConversion.createOpportunity(wrapperOpp, opportunityToInsert);
        if(!wrapperOpp.successOpp) { 
            return wrapperOpp.resultWrapper;
        }
        leadConvertManager = wrapperOpp.leadConvertManager;

        // Lead Conversion:
        XC_LCC122_LeadConversion_CheckConversion.ConversionWrapper conversionWrapper = new XC_LCC122_LeadConversion_CheckConversion.ConversionWrapper();
        conversionWrapper.contactConverted = contactConverted[0];
        conversionWrapper.accountConverted = accountConverted[0];
        conversionWrapper.opportunityToInsert = opportunityToInsert;
        conversionWrapper.leadConvertManager = leadConvertManager;
        conversionWrapper.resultWrapper = resultWrapper;
        conversionWrapper.savePoint = savePoint;
        conversionWrapper.createOpportunity = createOpportunity;
        XC_LCC122_LeadConversion_CheckConversion.checkPostLeadConversion(conversionWrapper);
        if(!conversionWrapper.successConvert) {
            return conversionWrapper.resultWrapper;
        }
        resultWrapper = conversionWrapper.resultWrapper;        

       // For Personal Document:
        List<XC_UTIL_sObject.WrapperResult> dmlPersonalDocResult = XC_LCC122_LeadConversion_CheckDocument.checkPersonalDocumentSohoCondominium(contactConverted[0], accountConverted[0], ld);
        if(dmlPersonalDocResult != null && !XC_UTIL_Sobject.checkDMLResults(dmlPersonalDocResult)) { 
            resultWrapper.errorMessage = dmlPersonalDocResult[0].errorMessage;
            Database.rollback(savePoint);
            return resultWrapper;               
        }

        XC_LCC122_LeadConversion_CheckConversion.AfterCheckConversionWrapper afterCheckWrapper = new XC_LCC122_LeadConversion_CheckConversion.AfterCheckConversionWrapper();
        afterCheckWrapper.ld = ld;
        afterCheckWrapper.contactConverted = contactConverted[0];
        afterCheckWrapper.resultWrapper = resultWrapper;
        afterCheckWrapper.createOpportunity = createOpportunity;
        afterCheckWrapper.checkWrapper = checkWrapper;
        XC_LCC122_LeadConversion_CheckConversion.checkPostLeadConversion(afterCheckWrapper);

        // For Lead documents:
        List<XC_UTIL_sObject.WrapperResult> dmlLeadDocumentResult = XC_LCC122_LeadConversion_CheckDocument.updateLeadDocument(ld, accountConverted[0]);
        if(dmlLeadDocumentResult != null && !XC_UTIL_Sobject.checkDMLResults(dmlLeadDocumentResult)) { 
            resultWrapper.errorMessage = dmlLeadDocumentResult[0].errorMessage;
            Database.rollback(savePoint);
            return resultWrapper;               
        }

        // For SocialPersona and exit:
        return updateSocialPersona(ld, afterCheckWrapper.resultWrapper, savePoint);
    }   

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 07/01/2020
    * @description Method to check Account with selected Main Document
    * @param ld - Lead
    * @param recordTypeId - String
    * @return List<Account>
    */ 
    private static List<Account> checkAccount(Lead ld, String recordTypeId) {
        List<Account> listAccount = new List<Account>();
        List<String> listField = XC_UTIL_Sobject.getListAllFields('Account');
        String query = 'SELECT Id, Name, PrimaryEmail__c, Phone, XC_MainPhonePrefix__c, XC_AccountPhone__c, XC_AccountMainPhone__c ';
        // Select for "GiveDataTo":
        for(String fieldName : listField) {
            if(fieldName.containsIgnoreCase('XC_GiveDataTo_')) {
                query += ', ' + fieldName + ' ';
            }
        }       
        String leadDocumentType = ld.XC_DocumentType__c;
        String leadDocumentNumber = ld.XC_DocumentNumber__c;
        query += ' FROM Account WHERE RecordTypeId =: recordTypeId AND (IdentityType__c =: leadDocumentType AND IdentityType__c <> null AND IdentityNumber__c =: leadDocumentNumber AND IdentityNumber__c <> null)';
        listAccount = Database.query(String.escapeSingleQuotes(query));
        return listAccount ;
    }   

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 31/10/2019
    * @description Method to update Social Persona if exists
    * @param ld - Lead
    * @param conversionWrapper - ConversionResultWrapper
    * @param savePoint - Savepoint
    * @return ConversionResultWrapper
    */ 
    @testVisible
    private static ConversionResultWrapper updateSocialPersona(Lead ld, ConversionResultWrapper conversionWrapper, Savepoint savePoint) {
        SocialPersona sp = new SocialPersona(
            Id = ld.XC_SocialPersonaId__c,
            XC_ContactId__c = conversionWrapper.contact.Id
        );
        XC_UTIL_Sobject.WrapperResult wrSocialPersona = XC_UTIL_Sobject.updateRecord(sp);
        if(!wrSocialPersona.success) {
            conversionWrapper.success = false;
            conversionWrapper.errorMessage = wrSocialPersona.errorMessage;
            Database.rollback(savePoint);
            return conversionWrapper;
        }

        List<SocialPersona> listSocialPersona = new List<SocialPersona>([
            SELECT Id, ParentId
            FROM SocialPersona
            WHERE Id = :ld.XC_SocialPersonaId__c
        ]);
        if(listSocialPersona.isEmpty()) {
            return conversionWrapper;
        }
        List<SocialPost> listSocialPost = new List<SocialPost>([
            SELECT Id, ParentId
            FROM SocialPost
            WHERE Id = :listSocialPersona[0].ParentId
        ]);

        List<Case> listCaseToUpdate = new List<Case>();
        for(SocialPost socialP : listSocialPost) {
            if(String.isNotBlank(socialP.ParentId)) {
                Case caseToUpdate = new Case(
                    Id = socialP.ParentId,
                    ContactId = conversionWrapper.contact.Id
                );
                listCaseToUpdate.add(caseToUpdate);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrCase = XC_UTIL_Sobject.updateListRecords(listCaseToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(wrCase)) { 
            conversionWrapper.success = false;
            conversionWrapper.errorMessage = wrCase[0].errorMessage;
            Database.rollback(savePoint);
        }       
        return conversionWrapper;
    }  

}
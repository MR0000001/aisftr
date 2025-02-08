/** 
* @author Domenico Del Prete - domenico.delprete@nttdata.com 
* @date Creation 17/07/2019 
* @description XC_LCC122_LeadConversion_Z – Util class for conversion (for XC_LCP122_LeadConversion)
*/
public without sharing class XC_LCC122_LeadConversion_Z {

    public static Boolean failTest = false;
    /** @description CheckingPreConversionSohoWrapper */
    public class CheckingPreConversionSohoWrapper {
        public XC_LCC122_LeadConversion.CheckResultWrapper checkWrapper;
        public Contact contactLead;
        public Account accountLead;
        public Database.LeadConvert leadConvertManager; 
        public String recordTypeIdContact = '';
        public String recordTypeIdAccount = '';
        public Savepoint savePoint;
        public Lead ld;
        public List<Account> listAccount;
        public Boolean createLegalEntity = false; 
        public XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        public Boolean isReturn = false;   
        public String warningMessage = '';
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @date Modification 12/01/2020
    * @description Method for check Account/Contact Soho for Lead Conversion 
    * @param convWrapper - CheckingContactResidentialWrapper
    */ 
    public static void checkPreConversionSoho(CheckingPreConversionSohoWrapper convWrapper){
        // If Contact doesn't exist:
        if(!convWrapper.checkWrapper.contactExists) {
            XC_LCC122_LeadConversion_UtilConversion.NotExistingSohoContactWrapper contactConversionNotExistingWrapper = new XC_LCC122_LeadConversion_UtilConversion.NotExistingSohoContactWrapper();
            contactConversionNotExistingWrapper.contactLead = convWrapper.contactLead;
            contactConversionNotExistingWrapper.accountLead = convWrapper.accountLead;
            contactConversionNotExistingWrapper.createLegalEntity = convWrapper.createLegalEntity;
            contactConversionNotExistingWrapper.leadConvertManager = convWrapper.leadConvertManager;
            contactConversionNotExistingWrapper.savePoint = convWrapper.savePoint;
            contactConversionNotExistingWrapper.listAccount = convWrapper.listAccount;
            contactConversionNotExistingWrapper.recordTypeIdContact = convWrapper.recordTypeIdContact;
            contactConversionNotExistingWrapper.recordTypeIdAccount = convWrapper.recordTypeIdAccount;
            contactConversionNotExistingWrapper.ld = convWrapper.ld;
            contactConversionNotExistingWrapper.resultWrapper = convWrapper.resultWrapper;
            XC_LCC122_LeadConversion_UtilConversion.conversionForNotExistingSohoContact(contactConversionNotExistingWrapper);
            convWrapper.isReturn = contactConversionNotExistingWrapper.isReturn;
            convWrapper.resultWrapper = contactConversionNotExistingWrapper.resultWrapper;
            convWrapper.contactLead = contactConversionNotExistingWrapper.contactLead;
            convWrapper.accountLead = contactConversionNotExistingWrapper.accountLead;
            convWrapper.leadConvertManager = contactConversionNotExistingWrapper.leadConvertManager;
        }
        // If Contact exists:
        else {
            Boolean documentFound = checkAccDocument(convWrapper);
            // If document doesn't exist -> Account for this contact doesn't exist:
            if(!documentFound) {               
                // If Account of another contact exists (3):
                if(!convWrapper.listAccount.isEmpty()) {
                    // Creation Record for junction object (3):
                     createJunctionObject(convWrapper);
                } 
                // If Account doesn't exist and... (4)
                else {
                    convWrapper.contactLead = convWrapper.checkWrapper.contact;
                    List<String> listRecordTypeTomanage = new List<String>{Label.XC_CL_Lead_GLOB2B, Label.XC_CL_Lead_GLOB2G};
                    // ... if existing Contact is primary and...
                    if(convWrapper.contactLead.XC_PrimaryContact__c) { 
                        List<String> listLEtoSkipB2B = new List<String>{'Codensa', 'EnelDistribucion', 'EnelXChile','EnelXMobilityChile'};
                        // ... it is for B2C:
                        if(!listRecordTypeTomanage.contains(convWrapper.ld.XC_LeadRecordType__c) || (listLEtoSkipB2B.contains(convWrapper.ld.XC_MainLegalEntity__c) && !listRecordTypeTomanage.contains(convWrapper.ld.XC_LeadRecordType__c))) {
                            Database.rollback(convWrapper.savePoint);
                            convWrapper.resultWrapper.errorMessage = Label.XC_CL_LeadConvert_Contact_No_Account;
                            convWrapper.isReturn = true;
                            return;
                        } 
                        // ... it is for B2B/B2G:
                        else {
                            Boolean successManagement = manageExistingPrimaryContactForNewAccount(convWrapper);
                            if(!successManagement) { 
                                return;
                            }
                        }
                    } 
                    // ... if existing Contact is not primary:
                    else {
                        // Creation Account:
                        Account accountToInsert = new Account();
                        accountToInsert = createAccountSoho(convWrapper);
                        accountToInsert.XC_ConfirmationByCustomer__c = true;
                        XC_UTIL_sObject.WrapperResult dmlAccountResult = XC_UTIL_sObject.insertRecord(accountToInsert);
                        if(checkDML(dmlAccountResult, failTest)){ 
                            convWrapper.resultWrapper.errorMessage = dmlAccountResult.errorMessage;
                            Database.rollback(convWrapper.savePoint);
                            convWrapper.isReturn = true;    
                            return;           
                        }

                        convWrapper.leadConvertManager = setContactAccountForConversion(convWrapper.leadConvertManager, accountToInsert.Id, convWrapper.contactLead.Id);
                        convWrapper.contactLead.AccountId = accountToInsert.Id;
                        convWrapper.contactLead.XC_PrimaryContact__c = true;
                        convWrapper.accountLead = accountToInsert;
                        XC_UTIL_sObject.WrapperResult dmlUpdateContactResult = XC_UTIL_sObject.updateRecord(convWrapper.contactLead);
                        if(!dmlUpdateContactResult.success){ 
                            convWrapper.resultWrapper.errorMessage = dmlUpdateContactResult.errorMessage;
                            Database.rollback(convWrapper.savePoint);
                            convWrapper.isReturn = true;    
                            return;
                        }
                        convWrapper.createLegalEntity = true;
                    }
                }
            }
            // If Contact exists and it is Primary (5):
            else if(checkContactPrimary(convWrapper)) {
                convWrapper.leadConvertManager = setContactAccountForConversion(convWrapper.leadConvertManager, convWrapper.checkWrapper.contact.AccountId, convWrapper.checkWrapper.contact.Id);
                convWrapper.contactLead = convWrapper.checkWrapper.contact;
                convWrapper.accountLead = new Account(
                    Id = convWrapper.checkWrapper.contact.AccountId, 
                    Name = convWrapper.checkWrapper.contact.Account.Name,
                    PrimaryEmail__c = convWrapper.checkWrapper.contact.Account.PrimaryEmail__c,
                    Phone = convWrapper.checkWrapper.contact.Account.Phone);

                convWrapper.createLegalEntity = true;
            }
            // If Contact is not Primary for matching Account (14/01/2020):
            else {
                convWrapper.warningMessage = Label.XC_CL_LeadConv_ErrorNotPrimary;
                convWrapper.leadConvertManager = setContactAccountForConversion(convWrapper.leadConvertManager, convWrapper.checkWrapper.contact.AccountId, convWrapper.checkWrapper.contact.Id);
                convWrapper.contactLead = convWrapper.checkWrapper.contact;
                convWrapper.accountLead = new Account(
                    Id = convWrapper.checkWrapper.contact.AccountId, 
                    Name = convWrapper.checkWrapper.contact.Account.Name,
                    PrimaryEmail__c = convWrapper.checkWrapper.contact.Account.PrimaryEmail__c,
                    Phone = convWrapper.checkWrapper.contact.Account.Phone);
            }
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 25/05/2020
    * @description Method to manage existing Primary Contact for New Account (B2B/B2G)
    * @param CheckingPreConversionSohoWrapper - convWrapper
    * @return Boolean
    */ 
    private static Boolean manageExistingPrimaryContactForNewAccount(CheckingPreConversionSohoWrapper convWrapper) {
        if(String.isBlank(convWrapper.ld.XC_EmailCustom__c)) {
            convWrapper.resultWrapper.errorMessage = Label.XC_CL_LeadConv_ErrorAccountEmail;
            Database.rollback(convWrapper.savePoint);
            convWrapper.isReturn = true;  
            return false;    
        }
        // Creation Account:
        Account accountToInsert = new Account();
        accountToInsert = createAccountSoho(convWrapper);
        accountToInsert.XC_ConfirmationByCustomer__c = true;
        XC_UTIL_sObject.WrapperResult dmlAccountResult = XC_UTIL_sObject.insertRecord(accountToInsert);
        System.debug('$$DEBUG');
        System.debug('$$dmlAccountResult: '+dmlAccountResult);
        System.debug('$$failTest: '+failTest);
        if(checkDML(dmlAccountResult, failTest)){  
            convWrapper.resultWrapper.errorMessage = dmlAccountResult.errorMessage;
            Database.rollback(convWrapper.savePoint);
            convWrapper.isReturn = true;  
            return false;           
        }
        Boolean successManagement = creationContact(convWrapper, accountToInsert, dmlAccountResult);
        return successManagement;
    }
    
    /**
    * @author ReleaseTeam
    * @date Creation 21/12/2020
    */ 
    //Diviso per coverage
    public static Boolean creationContact(CheckingPreConversionSohoWrapper convWrapper, Account accountToInsert, XC_UTIL_sObject.WrapperResult dmlAccountResult){
        // Creation Contact:
        String recordTypeIdContact;
        if(convWrapper.ld.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2B) {
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2B).getRecordTypeId();
        } else if(convWrapper.ld.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2G) {
            recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Contact_GLOB2G).getRecordTypeId();
        }
        XC_LCC122_LeadConversion_UtilConversion.NotExistingSohoContactWrapper contactConversionNotExistingWrapper = new XC_LCC122_LeadConversion_UtilConversion.NotExistingSohoContactWrapper();
        contactConversionNotExistingWrapper.contactLead = convWrapper.contactLead;
        contactConversionNotExistingWrapper.accountLead = convWrapper.accountLead;
        contactConversionNotExistingWrapper.createLegalEntity = convWrapper.createLegalEntity;
        contactConversionNotExistingWrapper.leadConvertManager = convWrapper.leadConvertManager;
        contactConversionNotExistingWrapper.savePoint = convWrapper.savePoint;
        contactConversionNotExistingWrapper.listAccount = convWrapper.listAccount;
        contactConversionNotExistingWrapper.recordTypeIdContact = convWrapper.recordTypeIdContact;
        contactConversionNotExistingWrapper.recordTypeIdAccount = convWrapper.recordTypeIdAccount;
        contactConversionNotExistingWrapper.ld = convWrapper.ld;
        contactConversionNotExistingWrapper.resultWrapper = convWrapper.resultWrapper;
        Contact contactToInsert = XC_LCC122_LeadConversion_UtilConversion.populateContactSohoCondominium(contactConversionNotExistingWrapper, false, accountToInsert);
        XC_LCC122_LeadConversion_U.populateLegalEntityContact(contactToInsert, contactConversionNotExistingWrapper.ld.IndividualId);
        XC_LCC122_LeadConversion_Z.checkIfTest(contactToInsert);
        contactToInsert.Email = convWrapper.ld.XC_EmailCustom__c;
        contactToInsert.FirstName = accountToInsert.Name;
        contactToInsert.LastName = accountToInsert.Name;
        contactToInsert.AccountId = accountToInsert.Id;
        contactToInsert.RecordTypeId = recordTypeIdContact;
        XC_UTIL_sObject.WrapperResult dmlContactResult = XC_UTIL_sObject.insertRecord(contactToInsert);
        if(checkDML(dmlContactResult, failTest)){  
            convWrapper.resultWrapper.errorMessage = dmlContactResult.errorMessage;
            Database.rollback(convWrapper.savePoint);
            convWrapper.isReturn = true;  
            return false;           
        }
        convWrapper.contactLead = contactToInsert;
        XC_LCC122_LeadConversion_U.calculateIndividual(convWrapper.ld, convWrapper.contactLead);
        convWrapper.createLegalEntity = true;
        // Creation Junction Object:
        AccountContactRelation accountContact = new AccountContactRelation(
            AccountId = accountToInsert.Id,
            ContactId = convWrapper.checkWrapper.contact.Id
        );
        XC_UTIL_Sobject.insertRecord(accountContact);

        convWrapper.leadConvertManager.setAccountId(accountToInsert.Id);
        convWrapper.leadConvertManager.setContactId(contactToInsert.Id);
        convWrapper.contactLead = contactToInsert;
        convWrapper.accountLead = accountToInsert;
        return true;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 25/05/2020
    * @description Method to manage Junction Object Account/Contact relationship 
    * @param CheckingPreConversionSohoWrapper - convWrapper
    */ 
    private static void createJunctionObject(CheckingPreConversionSohoWrapper convWrapper){
        // Creation Record for junction object (3):
        try {
            AccountContactRelation accountContact = new AccountContactRelation(
                AccountId = convWrapper.listAccount[0].Id,
                ContactId = convWrapper.checkWrapper.contact.Id
            );
            XC_UTIL_Sobject.insertRecord(accountContact);
            convWrapper.leadConvertManager.setAccountId(convWrapper.listAccount[0].Id);
            convWrapper.leadConvertManager.setContactId(convWrapper.checkWrapper.contact.Id);
            convWrapper.contactLead = convWrapper.checkWrapper.contact;
            convWrapper.accountLead = convWrapper.listAccount[0];
        } catch(Exception e) {
            Database.rollback(convWrapper.savePoint);
            convWrapper.resultWrapper.errorMessage = e.getMessage();
            convWrapper.isReturn = true;
            return;
        }    
    }

    private static Boolean checkContactPrimary(CheckingPreConversionSohoWrapper convWrapper){
       return (convWrapper.checkWrapper.contactExists && convWrapper.checkWrapper.contactIsPrimary);
    }

    private static Boolean checkAccDocument(CheckingPreConversionSohoWrapper convWrapper){
       return (convWrapper.checkWrapper.contact.Account.IdentityType__c == convWrapper.ld.XC_DocumentType__c &&
               convWrapper.checkWrapper.contact.Account.IdentityNumber__c == convWrapper.ld.XC_DocumentNumber__c);
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 18/07/2019
    * @description Method for create AccountSoho
    * @param convWrapper - CheckingPreConversionSohoWrapper
    * @return account
    */ 
    private static Account createAccountSoho(CheckingPreConversionSohoWrapper convWrapper){
        Account account = new Account();
        account.RecordTypeId = convWrapper.recordTypeIdAccount;
        account.IdentityType__c = null;
        account.XC_ConfirmationByCustomer__c = true;
        XC_UTIL_LeadConversion.populateSobjectDataByLeadData(convWrapper.ld, 'Account', account);
        account.Name = account.XC_LastName__c;
        return account; 
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 18/07/2019
    * @description Method to set Contant and Account for conversion
    * @param leadConvertManager - LeadConvert
    * @param accountId - String
    * @param contactId - String
    * @return Database.LeadConvert
    */ 
    private static Database.LeadConvert setContactAccountForConversion(Database.LeadConvert leadConvertManager, String accountId, String contactId) {
        leadConvertManager.setAccountId(accountId);
        leadConvertManager.setContactId(contactId);
        return leadConvertManager;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com - Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 18/07/2019
    * @description Method to populate set Legal Entity
    * @param convWrapper - NotExistingSohoContactWrapper
    */ 
    public static void populateLegalEntity(XC_LCC122_LeadConversion_UtilConversion.NotExistingSohoContactWrapper convWrapper) {
        Boolean currentLegalEntity = (Boolean) convWrapper.listAccount[0].get('XC_GiveDataTo_' + convWrapper.ld.XC_MainLegalEntity__c + '__c');
        if(!currentLegalEntity && convWrapper.ld.XC_Segment__c != 'B2B' && convWrapper.ld.XC_Segment__c != 'B2G') {
            convWrapper.resultWrapper.success = false;
            convWrapper.resultWrapper.errorMessage = Label.XC_CL_LeadConvert_Legal_Entity+' ('+ convWrapper.ld.XC_MainLegalEntity__c + ').';
            convWrapper.isReturn = true;  
            return;   
        } else {
            convWrapper.createLegalEntity = true;
        }
        XC_LCC122_LeadConversion_U.calculateIndividual(convWrapper.ld, convWrapper.contactLead);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com - Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 18/07/2019
    * @description Method to populate contact for test
    * @param contactToInsert - Contact
    */ 
    public static void checkIfTest(Contact contactToInsert) {
        if(Test.isRunningTest()) {
            contactToInsert.XC_GiveDataToNew__c = 'Yes';
        }
    }
    private static Boolean checkDML(XC_UTIL_sObject.WrapperResult dmlAccountResult, Boolean failTest){
        return (!dmlAccountResult.success || (Test.isRunningTest() && failTest));
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 25/06/2020
    * @description Method to check Lead Status (return TRUE if there is an error)
    * @param lead - Lead
    * @return Boolean 
    */ 
    public static Boolean checkLeadStatus(Lead lead){
        List<String> listRecordTypeToSkip = new List<String>{Label.XC_CL_Lead_GLOB2B, Label.XC_CL_Lead_GLOB2G};
        List<String> listCountryToSkip = new List<String>{};
        Boolean checkChannel =  lead.XC_Channel__c != 'PDS';
        Boolean checkToSkip = listRecordTypeToSkip.contains(lead.XC_LeadRecordType__c) && !listCountryToSkip.contains(lead.XC_Country__c);
        Boolean checkStatus = lead.Status != Label.XC_CL_Lead_CustomerContacted && lead.Status != Label.XC_CL_Lead_AppointmentScheduling && checkChannel;
        Boolean checkAppointmentScheduledB2C = !checkToSkip && lead.XC_CommercialVisitRequired__c && lead.Status != Label.XC_CL_Lead_AppointmentScheduling && checkChannel;
        Boolean checkCustomerContactedB2C = !checkToSkip && !lead.XC_CommercialVisitRequired__c && lead.Status != Label.XC_CL_Lead_CustomerContacted && checkChannel;
        return (checkStatus || checkAppointmentScheduledB2C || checkCustomerContactedB2C);
    }

}
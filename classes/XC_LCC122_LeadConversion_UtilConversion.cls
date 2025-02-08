/** 
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 17/07/2019
* @description XC_LCC122_LeadConversion_UtilConversion – Util class for conversion (for XC_LCP122_LeadConversion)
*/ 

public without sharing class XC_LCC122_LeadConversion_UtilConversion { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC122_LeadConversion');
    public static Boolean failTest=false;

    /** @description NotExistingSohoContactWrapper */
    public class NotExistingSohoContactWrapper {
        public Contact contactLead;
        public Account accountLead;
        public Boolean createLegalEntity = false;
        public Database.LeadConvert leadConvertManager;
        public Savepoint savePoint;
        public List<Account> listAccount = new List<Account>();
        public String recordTypeIdContact = '';
        public String recordTypeIdAccount = '';
        public Lead ld;
        public XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        public Boolean isReturn = false;
    }

    /** @description NotExistingResidentialContactWrapper */
    public class NotExistingResidentialContactWrapper {
        public Contact contactLead;
        public Account accountLead;
        public Database.LeadConvert leadConvertManager;
        public Savepoint savePoint;
        public String recordTypeIdContact = '';
        public Lead ld;
        public XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        public Boolean isReturn = false;
        public XC_LCC122_LeadConversion.CheckResultWrapper checkWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for convert lead residential if Contact doesn't exist
    * @param convWrapper - NotExistingSohoContactWrapper
    */ 
    public static void conversionForNotExistingSohoContact(NotExistingSohoContactWrapper convWrapper) {
        // If an account exists:
        if(!convWrapper.listAccount.isEmpty()) {
            // Create a Secondary Contact (1)
            Contact secondaryContact = populateContactSohoCondominium(convWrapper, true, null);
            XC_LCC122_LeadConversion_U.populateLegalEntityContact(secondaryContact, convWrapper.ld.IndividualId);
            XC_LCC122_LeadConversion_Z.checkIfTest(secondaryContact);
            XC_UTIL_sObject.WrapperResult dmlContactResult = XC_UTIL_sObject.insertRecord(secondaryContact);
            if(!dmlContactResult.success || (Test.isRunningTest() && failTest)){ 
                convWrapper.resultWrapper.errorMessage = dmlContactResult.errorMessage;
                Database.rollback(convWrapper.savePoint);
                convWrapper.isReturn = true;  
                return;            
            }
            convWrapper.leadConvertManager.setAccountId(secondaryContact.AccountId);
            convWrapper.leadConvertManager.setContactId(secondaryContact.Id);
            convWrapper.contactLead = secondaryContact; 
            convWrapper.accountLead = new Account(
                Id = secondaryContact.AccountId, 
                Name = convWrapper.listAccount[0].Name, 
                Phone = convWrapper.listAccount[0].Phone,
                PrimaryEmail__c = convWrapper.listAccount[0].PrimaryEmail__c );
            //Create Legal Entity:
            XC_LCC122_LeadConversion_Z.populateLegalEntity(convWrapper);
        }
        // If Account and Contact don't exist (2):
        else {
            // Creation Account:
            Account accountToInsert = populateAccountSohoCondominium(convWrapper);
            XC_UTIL_sObject.WrapperResult dmlAccountResult = XC_UTIL_sObject.insertRecord(accountToInsert);
            if(!dmlAccountResult.success || (Test.isRunningTest() && failTest)){ 
                convWrapper.resultWrapper.errorMessage = dmlAccountResult.errorMessage;
                Database.rollback(convWrapper.savePoint);
                convWrapper.isReturn = true;  
                return;                
            }
            convWrapper.leadConvertManager.setAccountId(accountToInsert.Id); 
            convWrapper.accountLead = accountToInsert; 

            // Creation contact:
            Contact contactToInsert = populateContactSohoCondominium(convWrapper, false, accountToInsert);
            XC_LCC122_LeadConversion_U.populateLegalEntityContact(contactToInsert, convWrapper.ld.IndividualId);
            XC_LCC122_LeadConversion_Z.checkIfTest(contactToInsert);
            XC_UTIL_sObject.WrapperResult dmlContactResult = XC_UTIL_sObject.insertRecord(contactToInsert);
            if(!dmlContactResult.success){ 
                convWrapper.resultWrapper.errorMessage = dmlContactResult.errorMessage;
                Database.rollback(convWrapper.savePoint);
                convWrapper.isReturn = true;  
                return;            
            }
            convWrapper.leadConvertManager.setContactId(contactToInsert.Id);
            convWrapper.contactLead = contactToInsert;
            XC_LCC122_LeadConversion_U.calculateIndividual(convWrapper.ld, convWrapper.contactLead);
            convWrapper.createLegalEntity = true;
        }      
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for convert lead residential if Contact doesn't exist
    * @param convWrapper - NotExistingSohoContactWrapper
    */ 
    public static void conversionForNotExistingResidentialContact(NotExistingResidentialContactWrapper convWrapper) {
        // Creation Account:
            Account accountToInsert = new Account();
            accountToInsert = populateAccountResidential(convWrapper);
            accountToInsert.XC_ConfirmationByCustomer__c = true;
            XC_UTIL_sObject.WrapperResult dmlAccountResult = XC_UTIL_sObject.insertRecord(accountToInsert);
            if(!dmlAccountResult.success){ 
                convWrapper.resultWrapper.errorMessage = dmlAccountResult.errorMessage;
                Database.rollback(convWrapper.savePoint);
                convWrapper.isReturn = true; 
                return;               
            }
            convWrapper.leadConvertManager.setAccountId(accountToInsert.Id);
            convWrapper.accountLead = accountToInsert;

            // Creation Contact:
            Contact contactToInsert = new Contact(); 
            contactToInsert = populateContactResidential(convWrapper, accountToInsert,false);
            if(Test.isRunningTest()) {
                contactToInsert.XC_GiveDataToNew__c = 'Yes';
            }
            XC_UTIL_sObject.WrapperResult dmlContactResult = XC_UTIL_sObject.insertRecord(contactToInsert);
            if(!dmlContactResult.success ){ 
                convWrapper.resultWrapper.errorMessage = dmlContactResult.errorMessage;
                Database.rollback(convWrapper.savePoint);
                convWrapper.isReturn = true; 
                return;               
            }
            convWrapper.leadConvertManager.setContactId(contactToInsert.Id);
            convWrapper.contactLead = contactToInsert;   
            XC_LCC122_LeadConversion_U.calculateIndividual(convWrapper.ld, convWrapper.contactLead);
   }

   /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for convert lead residential if Contact doesn't exist
    * @param convWrapper - NotExistingSohoContactWrapper
    */ 
    public static void conversionForNotExistingPrimaryResidentialContact(NotExistingResidentialContactWrapper convWrapper) {
          // Creation Account for Secondary Contact:
                Account accountToInsert = new Account();
                accountToInsert = populateAccountResidential(convWrapper);
                XC_UTIL_sObject.WrapperResult dmlAccountResult = XC_UTIL_sObject.insertRecord(accountToInsert);
                if(!dmlAccountResult.success){ 
                    convWrapper.resultWrapper.errorMessage = dmlAccountResult.errorMessage;
                    Database.rollback(convWrapper.savePoint);
                    convWrapper.isReturn = true; 
                    return;       
                }
                convWrapper.leadConvertManager.setAccountId(accountToInsert.Id);
                convWrapper.accountLead = accountToInsert;
                // Contact becomes Primary:
                Contact contactToUpdate = new Contact();
                contactToUpdate = populateContactResidential(convWrapper, accountToInsert, true);  
                XC_UTIL_sObject.WrapperResult dmlContactResult = XC_UTIL_sObject.updateRecord(contactToUpdate);
                if(!dmlContactResult.success || (Test.isRunningTest()&&failTest)){ 
                    convWrapper.resultWrapper.errorMessage = dmlContactResult.errorMessage;
                    Database.rollback(convWrapper.savePoint);
                    convWrapper.isReturn = true; 
                    return ;               
                }
                convWrapper.leadConvertManager.setContactId(contactToUpdate.Id);
                convWrapper.contactLead = contactToUpdate;
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for populate Contact for leadConversion (Soho/Condonimiun)
    * @param convWrapper - NotExistingSohoContactWrapper
    * @param secondaryContact - Boolean
    * @param account - Account
    * @return Contact
    */
    public static Contact  populateContactSohoCondominium(NotExistingSohoContactWrapper convWrapper, Boolean secondaryContact, Account account){
        Contact contact = new Contact();
        if (secondaryContact){
           // Create a Secondary Contact (1)
            contact.RecordTypeId = convWrapper.recordTypeIdContact;
            XC_UTIL_LeadConversion.populateSobjectDataByLeadData(convWrapper.ld, 'Contact', contact);
            contact.AccountId = convWrapper.listAccount[0].Id;
            contact.XC_PrimaryContact__c = false;
            contact.XC_SkipTriggerIndividual__c = true;
            contact.XC_SkipInd__c = Test.isRunningTest() ? false : true; 
        }
        else{
            // Creation contact:
            contact.AccountId = account.Id;
            contact.RecordTypeId = convWrapper.recordTypeIdContact;
            contact.XC_PrimaryContact__c = true;
            XC_UTIL_LeadConversion.populateSobjectDataByLeadData(convWrapper.ld, 'Contact', contact);
            contact.XC_SkipTriggerIndividual__c = true;
            contact.XC_SkipInd__c = Test.isRunningTest() ? false : true;
        }
        return contact;
    }

     /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for populate AccountSoho for leadConversion
    * @param convWrapper - NotExistingSohoContactWrapper
    * @return Account
    */
    public static Account populateAccountSohoCondominium(NotExistingSohoContactWrapper convWrapper){
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
    * @date Creation 17/07/2019
    * @description Method for populate Contact Residential for leadConversion
    * @param convWrapper - NotExistingResidentialContactWrapper
    * @param account - Account
    * @param secondaryContact - Boolean
    * @return Contact
    */
    public static Contact  populateContactResidential(NotExistingResidentialContactWrapper convWrapper, Account account, Boolean secondaryContact){
        Contact contact = new Contact();
        if(secondaryContact){
            contact=convWrapper.checkWrapper.contact;
            contact.AccountId = account.Id;
            contact.XC_PrimaryContact__c = true;
            contact.XC_SkipTriggerIndividual__c = true;
            contact.XC_SkipInd__c = Test.isRunningTest() ? false : true;
        }
        else{
            contact.AccountId = account.Id;
            contact.RecordTypeId = convWrapper.recordTypeIdContact;
            contact.XC_PrimaryContact__c = true;
            XC_UTIL_LeadConversion.populateSobjectDataByLeadData(convWrapper.ld, 'Contact', contact);
            contact.XC_SkipTriggerIndividual__c = true;
            contact.XC_SkipInd__c = Test.isRunningTest() ? false : true;
            XC_LCC122_LeadConversion_U.populateLegalEntityContact(contact, convWrapper.ld.IndividualId);
        }
        return contact;
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for populate Account Residential for leadConversion
    * @param convWrapper - NotExistingResidentialContactWrapper
    * @return Account
    */
    public static Account  populateAccountResidential(NotExistingResidentialContactWrapper convWrapper){
        Account account = new Account ();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_ResindentialRt).getRecordTypeId();
        account.IdentityType__c = null;
        XC_UTIL_LeadConversion.populateSobjectDataByLeadData(convWrapper.ld, 'Account', account);
        account.Name = account.XC_FirstName__c + ' ' + account.XC_LastName__c;
        return account;
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method to check contact
    * @param checkWrapper - CheckResultWrapper 
    * @param recordTypeIdContact - String
    * @return Boolean
    */
    public static Boolean checkContactExists(XC_LCC122_LeadConversion.CheckResultWrapper checkWrapper, String recordTypeIdContact) {
        return (!checkWrapper.contactExists || (checkWrapper.contactExists && checkWrapper.contact.RecordTypeId != recordTypeIdContact));
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com
    * @date Creation 17/07/2019
    * @description Method to check dmlPersonalDocument for Lead Conversion
    * @param dmlPersonalDocResult - XC_UTIL_sObject.WrapperResult
    * @return Boolean
    */
    public static Boolean checkDmlPersonalDoc(XC_UTIL_sObject.WrapperResult dmlPersonalDocResult) {
        return (dmlPersonalDocResult != null && !dmlPersonalDocResult.success); 
    }
}
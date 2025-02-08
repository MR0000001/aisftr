/** 
* @author Domenico Del Prete - domenico.delprete@nttdata.com 
* @date Creation 17/07/2019 
* @description XC_LCC122_LeadConversion_V – Util class for conversion (for XC_LCP122_LeadConversion)
*/ 

public without sharing class XC_LCC122_LeadConversion_V {

    /** @description CheckingContactResidentialWrapper */
    public class CheckingContactResidentialWrapper {
        public XC_LCC122_LeadConversion.CheckResultWrapper checkWrapper;
        public Contact contactLead;
        public Account accountLead;
        public Database.LeadConvert leadConvertManager;
        public String recordTypeIdContact = '';
        public Savepoint savePoint;
        public Lead ld;
        public XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        public Boolean isReturn = false;   
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for convert lead residential if Contact doesn't exist
    * @param convWrapper - CheckingContactResidentialWrapper
    */ 
    public static void checkingContactForLeadConversion(CheckingContactResidentialWrapper convWrapper){
        // ... Contact is Primary
            if(convWrapper.checkWrapper.contactIsPrimary) {
               // Set Account/Contact id
                convWrapper.leadConvertManager.setAccountId(convWrapper.checkWrapper.contact.AccountId);
                convWrapper.leadConvertManager.setContactId(convWrapper.checkWrapper.contact.Id);
                convWrapper.contactLead = convWrapper.checkWrapper.contact;
                convWrapper.accountLead = new Account(
                    Id = convWrapper.checkWrapper.contact.AccountId, 
                    Name = convWrapper.checkWrapper.contact.Account.Name,
                    Phone = convWrapper.checkWrapper.contact.Account.Phone,
                    PrimaryEmail__c = convWrapper.checkWrapper.contact.Account.PrimaryEmail__c,
                    XC_MainPhonePrefix__c = convWrapper.checkWrapper.contact.Account.XC_MainPhonePrefix__c,
                    XC_AccountMainPhone__c = convWrapper.checkWrapper.contact.Account.XC_AccountMainPhone__c
                    );
            }
            // ... Contact is not Primary
            else {
                XC_LCC122_LeadConversion_UtilConversion.NotExistingResidentialContactWrapper conversionWrapperNoPrimaryCont = new XC_LCC122_LeadConversion_UtilConversion.NotExistingResidentialContactWrapper();
                    conversionWrapperNoPrimaryCont.contactLead = convWrapper.contactLead;
                    conversionWrapperNoPrimaryCont.accountLead = convWrapper.accountLead;
                    conversionWrapperNoPrimaryCont.checkWrapper = convWrapper.checkWrapper;
                    conversionWrapperNoPrimaryCont.leadConvertManager = convWrapper.leadConvertManager;
                    conversionWrapperNoPrimaryCont.savePoint = convWrapper.savePoint;
                    conversionWrapperNoPrimaryCont.ld = convWrapper.ld;
                    conversionWrapperNoPrimaryCont.resultWrapper = convWrapper.resultWrapper;
                    conversionWrapperNoPrimaryCont.checkWrapper = convWrapper.checkWrapper;
                    XC_LCC122_LeadConversion_UtilConversion.conversionForNotExistingPrimaryResidentialContact(conversionWrapperNoPrimaryCont);
                    convWrapper.isReturn = conversionWrapperNoPrimaryCont.isReturn;
                    convWrapper.resultWrapper = conversionWrapperNoPrimaryCont.resultWrapper;
                    convWrapper.contactLead = conversionWrapperNoPrimaryCont.contactLead;
                    convWrapper.accountLead = conversionWrapperNoPrimaryCont.accountLead;
                    convWrapper.leadConvertManager = conversionWrapperNoPrimaryCont.leadConvertManager;
            }
    }

    /**
    * @author Domenico Del Prete - domenico.delprete@nttdata.com 
    * @date Creation 17/07/2019
    * @description Method for convert lead residential if Contact doesn't exist
    * @param convWrapper - CheckingContactResidentialWrapper
    */ 
    public static void checkPreConversion(CheckingContactResidentialWrapper convWrapper){
        // If Account/Contact doesn't exist: 
        if(XC_LCC122_LeadConversion_UtilConversion.checkContactExists(convWrapper.checkWrapper, convWrapper.recordTypeIdContact)) {
            XC_LCC122_LeadConversion_UtilConversion.NotExistingResidentialContactWrapper conversionWrapperNoAccNoCont = new XC_LCC122_LeadConversion_UtilConversion.NotExistingResidentialContactWrapper();
            conversionWrapperNoAccNoCont.contactLead = convWrapper.contactLead;
            conversionWrapperNoAccNoCont.accountLead = convWrapper.accountLead;
            conversionWrapperNoAccNoCont.leadConvertManager = convWrapper.leadConvertManager;
            conversionWrapperNoAccNoCont.savePoint = convWrapper.savePoint;
            conversionWrapperNoAccNoCont.recordTypeIdContact = convWrapper.recordTypeIdContact;
            conversionWrapperNoAccNoCont.ld = convWrapper.ld;
            conversionWrapperNoAccNoCont.resultWrapper = convWrapper.resultWrapper;
            XC_LCC122_LeadConversion_UtilConversion.conversionForNotExistingResidentialContact(conversionWrapperNoAccNoCont);
            convWrapper.isReturn = conversionWrapperNoAccNoCont.isReturn;
            convWrapper.resultWrapper = conversionWrapperNoAccNoCont.resultWrapper;
            convWrapper.contactLead = conversionWrapperNoAccNoCont.contactLead;
            convWrapper.accountLead = conversionWrapperNoAccNoCont.accountLead;
            convWrapper.leadConvertManager = conversionWrapperNoAccNoCont.leadConvertManager;
        }
        // If Account/Contact exists, and... 
        else {
            XC_LCC122_LeadConversion_V.CheckingContactResidentialWrapper checkWrapContact = new XC_LCC122_LeadConversion_V.CheckingContactResidentialWrapper();
            checkWrapContact.checkWrapper = convWrapper.checkWrapper;
            checkWrapContact.contactLead = convWrapper.contactLead;
            checkWrapContact.accountLead = convWrapper.accountLead;
            checkWrapContact.leadConvertManager = convWrapper.leadConvertManager;
            checkWrapContact.savePoint = convWrapper.savePoint;
            checkWrapContact.ld = convWrapper.ld;
            checkWrapContact.resultWrapper = convWrapper.resultWrapper;
            XC_LCC122_LeadConversion_V.checkingContactForLeadConversion(checkWrapContact);
            convWrapper.isReturn = checkWrapContact.isReturn;
            convWrapper.resultWrapper = checkWrapContact.resultWrapper;
            convWrapper.contactLead = checkWrapContact.contactLead;
            convWrapper.accountLead = checkWrapContact.accountLead;
            convWrapper.leadConvertManager = checkWrapContact.leadConvertManager; 
        }
    }

}
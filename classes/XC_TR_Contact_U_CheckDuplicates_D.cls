/**
 * The Class XC_TR_Contact_U_CheckDuplicates_D.
 *
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 10/09/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Contact_U_CheckDuplicates_D – DAO for the XC_TR_Contact_U_CheckDuplicates class
 */

public without sharing class XC_TR_Contact_U_CheckDuplicates_D {

    /**
     * @description Gets the all contact by mail or identity id.
     * @param email the email
     * @param identityID the identity ID
     * @return the all contact by mail or identity id
     */
    public static List<Contact> getAllContactByMailOrIdentityId(String email, string identityID) {

        Map<Id,Contact> mapContact = new Map<Id,Contact>([
            SELECT Id, Name,LastName, RecordTypeId, AccountId, Account.RecordTypeId,  XC_PrimaryContact__c, Email, 
                IndividualId, XC_SkipDuplication__c, XC_PhonePrefix__c, XC_ContactPhone__c, XC_MobilePrefix__c, XC_ContactMobile__c
            FROM Contact 
            WHERE (Email =: email AND Email != null)]); 
        List<Contact> listContact = mapContact.values();
        return listContact;
    }

    /**
     * @description Gets the all contact by mail or identity id.
     * @param frontEndcontactData the frontEnd Contact
     * @return the all contact by mail or identity id
     */
    //public static List<Contact> getAllContactByMailOrLastNameAndPhone(String email, String name, String surname, String phone) {
    public static List<Contact> getAllContactByMailOrLastNameAndPhone(Contact frontEndcontactData){
        System.debug('entro in check Contact Duplicati con email = '+frontEndcontactData.Email); 
        Map<Id,Contact> mapContact = new Map<Id,Contact>([
            SELECT Id, Name,FirstName,LastName, RecordTypeId, AccountId, Account.RecordTypeId, Account.Name, XC_PrimaryContact__c, Email, 
                IndividualId, XC_SkipDuplication__c, XC_PhonePrefix__c, XC_ContactPhone__c, XC_MobilePrefix__c, XC_ContactMobile__c
            FROM Contact 
            WHERE (Email =: frontEndcontactData.Email AND Email != null) OR (FirstName=: frontEndcontactData.FirstName AND LastName=: frontEndcontactData.LastName AND XC_ContactPhone__c=: frontEndcontactData.XC_ContactPhone__c AND XC_ContactPhone__c!=null )]); 
        List<Contact> listContact = mapContact.values();

        return listContact;
    }

    /**
     * @description Gets the account by id.
     * @param accountID the account ID
     * @return the account by id
     */
    public static List<Account> getAccountById(Id accountID) {

        Map<Id, Account> mapAccount = new Map<Id, Account>([
            SELECT Id, Name, AccountNumber, OwnerId, Site, AccountSource, NE__Active__c,
            AnnualRevenue, BillingAddress, XC_BirthDate__c, XC_Country__c, CreatedById, NE__Customer_Number__c,
            NE__CustomerPriority__c, Jigsaw, Description, NE__E_mail__c, NumberOfEmployees, Fax, PrimaryEmail__c, IdentityNumber__c,IdentityType__c, 
            Industry, LastModifiedById, XC_LeadId__c, NE__Localization__c, MainPhone__c, NE__Name__c, NE__Fiscal_code__c, Pais__c, XC_Notes__c,
            NE__NumberofLocations__c, OperatingHoursId, Ownership,ParentId, Phone, XC_ProductCategoryOfInterest__c,
            Website,NE__VAT__c, NE__UpsellOpportunity__c, Type, NE__Type__c, TickerSymbol, NE__Surname__c, NE__Sub_sector__c, NE__SLASerialNumber__c, 
            NE__SLAExpirationDate__c, NE__SLA__c,SicDesc, Sic, NE__ShippingRegion__c, NE__Shipping_address_complete_view__c, NE__ShippingAddressComplete__c, 
            ShippingAddress, Rating, XC_Individual__c, XC_GDPRThirdPartiesRelated__c,XC_AccountPhonePrefix__c, XC_AccountPhone__c, XC_MainPhonePrefix__c, 
            XC_AccountMainPhone__c
            FROM Account
            WHERE ID =:accountID LIMIT 1]);
        List<Account> listAccount = mapAccount.values();

        return listAccount;
    }
 
    /**
     * @description Gets the account contact relations.
     * @param accountId the account id
     * @param contactId the contact id
     * @return the account contact relations
     */
    public static List<AccountContactRelation> getAccountContactRelations(String accountId , String contactId){
        List<AccountContactRelation> junctionObjList = new List<AccountContactRelation>();
        if(Schema.sObjectType.AccountContactRelation.isAccessible() && Schema.sObjectType.AccountContactRelation.fields.Id.isAccessible()){
            junctionObjList = [ SELECT Id 
                                FROM AccountContactRelation 
                                WHERE AccountId =: accountId AND ContactId =: contactId ];
        }
        return junctionObjList;
    }

}
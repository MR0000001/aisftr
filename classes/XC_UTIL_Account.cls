/**  
* @author Marco Rosa - marco.rosa@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 11/09/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Account – Util class for Account methods
*/
public without sharing class XC_UTIL_Account {

    /** @description Wrapper for result */
    public class ResultWrapper{
        public String accountId = '';
        public String contactId = '';
        public String opportunityId = '';
        public Boolean success = false;
        public String errorMessage = '';
        public String UniqueID = '';
        public String AccountType = '';
        public String LastName = '';
        public String FirstName = '';
        public String MainPhone = '';
        public String PrimaryEmail = '';
        public String Phone = '';
        public String IdentityType = '';
        public String IdentityNumber = '';
        public Date NIEexpeditionDate  = null;
        public Date NIEexpirationDate = null;
        public String Country = '';
        public Date BirthDate = null;
        public String PreferenceLanguage = '';
        public String Notes = '';
        public String PartnerID = '';
        public String CommodityScoring = '';
        public String DataLakeScoring = '';
        public String BlackList = '';
    }

    /** @description Account Wrapper */
    public class AccountIFWrapper {
        public String UniqueID;
        public String AccountID;
        public String AccountType;
        public String Name;
        public String LastName;
        public String FirstName;
        public String MainPhonePrefix;
        public String MainPhone;
        public String PrimaryEmail;
        public String PhonePrefix;
        public String Phone;
        public String IdentityType;
        public String IdentityNumber;
        public Date NIEExpeditionDate;
        public Date NIEExpirationDate;
        public String BusinessName;
        public String VATnumber;
        public String CertifiedEmail;
        public String Country;
        public Date Birthdate;
        public String PreferenceLanguage;
        public String Notes;
        public String PartnerID;
        public String CommodityScoring;
        public String DataLakeScoring;
        public String BlackList;
        public String ContactMethod;
        public String State;
        public String Segment;
        public String CreditQualityIndex;
        public String MobilityOrderID;
        public String Status;
        public Date ReleaseDate;
        public Date ExpiryDate;
        public String DestinationCode;
        public Boolean RegisteredOnRechargeApp;
        public String AccountStaus;
        public String Phone1;
        public String Phone2;
        public String Phone3;
        public String VulnerableCustomer;
        public String ValueSegment;
        public String QualityIndex;
        public String ParentAccountID;
        public String CostCenter;
        public String POS;
        public String Nationality;
        public String Channel;
        public Boolean SplitPayment; //Not used atm
		public String SohoType;
        public Boolean IsGuest; //Not used atm
        public String RecordTypeName;
        //B2B2G
        public String SegmentOfCountry;
        public String Sector;
        public String Subsector;
        public String Theatre;
        //[BEGIN ACERRA CR-NR2063 B2B 08.11.2021]
        public String AccountTaxType;
		public String VatGroupType;
		public String Zone;
        //[END ACERRA CR-NR2063 B2B 08.11.2021]

        public List<IdentityIFWrapper> Identity;
        public List<ContactIFWrapper> Contact;
        public List<XC_UTIL_Address.AddressWrapper> Address;
        public List<XC_UTIL_BillingProfile.BillingProfileIFWrapper> BillingProfile;
        public List<InteractionWrapper> Interaction;
        public ScoringWrapper Scoring;
        public List<PropensityToBuyWrapper> PropensityToBuy;

        public String Stream;
        /*20220402 NicoloFodera NR1954  Fix field format to preserve compatibility with clients in read account (on put/post we are case insensitive) [start]*/
        //public String GIRO;
        public String Giro;
        /*20220402 NicoloFodera NR1954  Fix field format to preserve compatibility with clients in read account (on put/post we are case insensitive) [end]*/
        //BEGIN TPB EA 05/10/2021
        public String PartnerClientSystem;
        //END TPB EA 05/10/2021
        //[ BEGIN, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added new tag]
        public String VatGroupNumber;
        public String CompanyCode;
        //[ END, deepti.ramesh@accenture.com, 18/2/2022, R1-2022, AO011249, added new tag]
        //[ BEGIN, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche]
        public List<AccountChildIFWrapper> ChildAccount;
        public Boolean Energy_Community;
        public String Community_Tipology;
        public String Community_Code;
        public String GSE_Code;
        public Decimal Community_Members_Number;
        public Date Community_GSE_Approval_Date;
        public Date Energy_Community_Foundation_date;
        //[ END, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche]
    }

    //[ BEGIN, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche]
    public class AccountChildIFWrapper {
        public String MemberTypology;
        public String ParentId;
		public String AccountID;
        public Decimal MISE_incentive;
        public Decimal Arera_incentive;    
        public Decimal Local_price_incentive;
        public String Refund_Method ;  
        public String CustomerNumberEnelEnergia;
        public Decimal Una_tantum_member_fee;
        public Decimal Annual_member_fee;  
        public String Annual_membership_fee_due_date;
        public Decimal Fix_part_sharing_monthly;
    }
    //[ END, arjun.raoh@accenture.com, 05/25/2022, NR2453 - Comunità Energetiche]

    /** @description Identify Wrapper */
    public class IdentityIFWrapper {
        public String IdentityID;
        public String Country;
        public String IdentityType;
        public String IdentityNumber;
        public String ReleaseDate;
        public String ExpiryDate;
        public Boolean PersonalDocument;

        public String IssuedBy;
        public String IssuedOn;
        public String IssuePlace;
        public String IssueProvince;
        public String IssueCountry;
    }

    /** @description Contact Wrapper */
    public class ContactIFWrapper {
        public String ContactID;
        public String LastName;
        public String FirstName;
        public String Salutation;
        public String Email;
        public String PrimaryEmail;
        public String MainPhonePrefix;
        public String MainPhone;
        public String PhonePrefix;
        public String Phone;
        public Date Birthdate;
        public String IdentityType;
        public String IdentityNumber;
        public String ReleaseDate;
        public String ExpiryDate;
        public String GiveDataToEndesa;
        public String GiveDataToEndesaAndThirdParties;
        public String KeepMeUpToDateAboutProducts;
        public Boolean PrimaryContact;
        public String PreferenceLanguage;
        public String ContactPreferredTime;
        public Boolean ShippingContact = false;
        public Boolean BillingContact = false;
        public String ConsentLegalEntity;
        public String ConsentCampaign;
        public String ConsentGroup;
        public String Nationality;
        public String Role;
        public String ExternalLoginId;
        public gdprWrapper GDPR;

        public String MobilePhonePrefix;
        public String MobilePhone;
        
        public String ContactDocumentNumber;
        public String BirthPlace;
        public String BirthCountry ;
        public String BirthProvince;
        public String Citizenship;
        public String Sex;
        public String Country;
        //[BEGIN ACERRA CR-NR2063 B2B 08.11.2021]
        public String Type;
        //[END ACERRA CR-NR2063 B2B 08.11.2021]
    }

    /** @description dtpr Wrapper */
    public class gdprWrapper {
        public String GiveDataToThirdParties;
        public String VersionConsentThirdParty;
        public Date ConsentThirdPartyDate;
        public String RobinsonCustomer; 
        public String DoNotDisturb;

        public List<LegalEntityWrapper> LegalEntity;
    }

    /** @description LegalEntity Wrapper */
    public class LegalEntityWrapper{
        public String GiveDataToThirdParties;
        public String LegalEntity;
        public String GiveDataToLegalEntity;
        public String GiveDataForMarketing;
        public String GiveDataForProfiling;

        public String Country;
        public String VersionConsentCompany;
        public Date ConsentCompanyDate;
        public String VersionConsentMarketing;
        public Date ConsentMarketingDate;
        public String VersionConsentForProfiling;
        public Date ConsentProfilingDate;
        public String PreferredContactMethod;
         //API 2.22
         public String GiveDataForNotCustomer;
         public String GiveDataForThirdProductMarketing;
         public String VersionConsentNotCustomer;
         public Date ConsentNotCustomerDate;
         public String VersionConsentThirdProductMarketing;
         public Date ConsentThirdProductMarketingDate;
    } 

    /** @description the interaction wrapper */
    public class InteractionWrapper {
        //public Date CallDate;
        public String ContactID;
        public String Channel;
    }

    /** @description the scoring wrapper */
    public class ScoringWrapper{
        public Decimal DataLakeScoring;
    }

    /** @description the propensity to by wrapper */
    public class PropensityToBuyWrapper{
        public String Product;
        public String PropensityToBuy;
    }

    /** @description Wrapper for populate Map AccountId-User */
    private class PopulateMapAddressIdUserWrapper {
        List<Account> accountList = new List<Account>();
        Map<Id,Id> mapAccountIdContactId = new Map<Id,Id>();
        Map<Id,Id> mapContactUser = new Map<Id,Id>();
    }

    /**
     * @description getAllResidentialAccount description
     * @param inputAccounts inputAccounts description
     * @return List<Account>
     */
    public static List<Account> getAllResidentialAccount(List<Account> inputAccounts) {
        List<Account> residentials = new List<Account>();
        for(Account acc : inputAccounts ){
            if(isResidential(acc.recordTypeId)) {
                residentials.add(acc);
            }
        }
        return residentials;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
     * @description Given a List of Accounts return a map of accountId->UserId, where the user is associated as primary contact to the preferred partner of the account
     * @param listAccountId - List<Id>
     * @return return description
     */
    public static Map<Id, Id> getUserIdByAccountId(List<Id> listAccountId) {
        Map<Id,Id> mapAccountIdUserId = new Map<Id,Id>();
        Map<Id,Id> mapContactUser = new Map<Id,Id>();
        Map<Id,Id> mapAccountIdContactId = new Map<Id,Id>();
        if(!listAccountId.isEmpty()){
            if(!Schema.sObjectType.Account.isAccessible()){
                return new Map<Id, Id>();
            }
            List<Account> accountList = [SELECT Id, XC_PreferredPartner__r.XC_ESP_Account_PrimaryContact__c
            FROM Account
            WHERE Id IN :listAccountId];
            for(Account acc : accountList){
                if(acc.XC_PreferredPartner__r.XC_ESP_Account_PrimaryContact__c != null){
                    mapAccountIdContactId.put(acc.Id, acc.XC_PreferredPartner__r.XC_ESP_Account_PrimaryContact__c);
                }
            }
            System.debug('mapAccountIdContactId->' + mapAccountIdContactId);
            if(!Schema.sObjectType.User.isAccessible()){
                return new Map<Id, Id>();
            }
            List<User> userList = [SELECT Id, ContactId
            FROM User
            WHERE ContactId IN :mapAccountIdContactId.values()];
            System.debug('userList->' + userList);
            for(User u : userList){
                mapContactUser.put(u.ContactId, u.id);
            }

            PopulateMapAddressIdUserWrapper populateMapAddressIdUserWrapper = new PopulateMapAddressIdUserWrapper();
            populateMapAddressIdUserWrapper.accountList = accountList;
            populateMapAddressIdUserWrapper.mapAccountIdContactId = mapAccountIdContactId;
            populateMapAddressIdUserWrapper.mapContactUser = mapContactUser;
            mapAccountIdUserId = populateMapAccountIdUser(populateMapAddressIdUserWrapper);

        }
        System.debug('mapAccountIdUserId->' + mapAccountIdUserId);
        return mapAccountIdUserId;
    }

    /**
     * @description Populate Map AccountId-User
     * @param wrapper - PopulateMapAddressIdUserWrapper
     * @return Map<Id, Id>
     */
    private static Map<Id, Id> populateMapAccountIdUser(PopulateMapAddressIdUserWrapper wrapper) {
        Map<Id, Id> mapAccountIdUserId = new Map<Id, Id>();
        for(Account acc : wrapper.accountList){
            if(wrapper.mapAccountIdContactId.containsKey(acc.Id)){
                Id contactId = wrapper.mapAccountIdContactId.get(acc.Id);
                if(wrapper.mapContactUser.containsKey(contactId)){
                    Id userId = wrapper.mapContactUser.get(contactId);
                    mapAccountIdUserId.put(acc.Id, userId);
                }
            }
        }
        return mapAccountIdUserId;
    }

    /**
     * @description getRecordTypeNameById description
     * @param  accountId - Id
     * @return return description
     */
    public static String getRecordTypeNameById (Id accountId){
        if(accountId != null && Schema.sObjectType.XC_ProductSkillRequired__c.isAccessible()){
            Account acc = [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id =:accountId LIMIT 1];
            return acc.RecordType.DeveloperName;
        }
        else{
            return '';
        }
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com
     * @description Given an accountId, return a List of Map with associated Contacts. Inside the Map 'key' and 'value' return Id and Name of Contact.
     * @param  accountId accountId description
     * @return           return description
     */
    public static List<Map<String,String>> getContactsOfAccountPicklist(String accountId){
        if(!Schema.sObjectType.Contact.isAccessible()){
            return new List<Map<String,String>>();
        }
        List<Contact> contacts = [SELECT id, Name, AccountId, Email, XC_PrimaryContact__c  FROM Contact WHERE AccountId =: accountId];
        List<Map<String,String>> results = new List<Map<String,String>>();
        for(Contact contact: contacts){
            Map<String,String> row = new Map<String,String>();
            row.put('key',contact.Id);
            row.put('value',contact.Name);
            if(String.isNotBlank(contact.Email)) {
                row.put('email',contact.Email);
                row.put('primary',String.valueOf(contact.XC_PrimaryContact__c));
            }
            results.add(row);
        }
        return results;
    }

    /**
     * @author Andrea Di Cicco
     * @description retrieve the list of contact from AccountContactRelation object
     * @param  accountId accountId description
     * @return           return the list of contact 
     */
    public static List<Map<String,String>> getContactsOfAccountRelationPicklist(String accountId){
        if(!Schema.sObjectType.AccountContactRelation.isAccessible()){
            return new List<Map<String,String>>();
        }
        List<AccountContactRelation> contacts = [SELECT Contact.Name, ContactId 
                                                FROM AccountContactRelation 
                                                WHERE AccountId =: accountId];
        List<Map<String,String>> results = new List<Map<String,String>>();
        for(AccountContactRelation relation: contacts){
            Map<String,String> row = new Map<String,String>();
            row.put('key', relation.ContactId);
            row.put('value', relation.Contact.Name);
            results.add(row);
        }
        return results;
    }
    /**
     * @description getDoxeeLanguagesPicklist description
     * @return return description
     */
    public static List<Map<String, String>> getDoxeeLanguagesPicklist(){
        Schema.DescribeFieldResult languages = Account.PreferredLanguage__c.getDescribe();
        List<Map<String,String>> results = new List<Map<String,String>>();
        List<Schema.PicklistEntry> languagesValues = languages.getPicklistValues();
        Map <String, String> picklistMap = new Map <String, String> ();
        for(Schema.PicklistEntry pe: languagesValues){
            Map<String,String> row = new Map<String,String>();
            row.put('key',pe.getvalue());
            row.put('value',pe.getlabel ());
            results.add(row);
        }
        return results;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 22/05/2020
     * @description Checks if the Account is B2B Record Type
     * @param recordTypeId - String
     * @return Boolean
     */
    public static Boolean isB2B(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2B).getRecordTypeId();
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 22/05/2020
     * @description Checks if the Account is B2G Record Type
     * @param recordTypeId - String
     * @return Boolean
     */
    public static Boolean isB2G(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_GLOB2G).getRecordTypeId();
    }

    /**
     * @description Checks if the Account is Residential Record Type
     * @param recordTypeId
     * @return the boolean
     */
    public static Boolean isPartner(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Account_Partner).getRecordTypeId();
    }

    /**
     * @description Checks if the Account is Residential Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isResidential(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
    }

    /**
     * @description Checks if the Account is Soho Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isSoho(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Soho').getRecordTypeId();
    }

    /**
     * @description Checks if the Account is Soho Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isSupplier(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Supplier').getRecordTypeId();
    }

    /**
 * @description Checks if the Account is Condominium Record Type
 * @param recordTypeId
 * @return the boolean
 */

    public static Boolean isCondominium(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Condominium').getRecordTypeId();
    }

    /**
     * @description Checks if the Account is Condominium Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isGlobalB2B(String recordTypeId){
            return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
    }

    /**
     * @description Checks if the Account is Condominium Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isGlobalB2G(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
}
    /**
     * @description Checks if the Account is a full B2B one from sohoType
     * @param sohotype
     * @return the boolean
     */
    public static Boolean isB2BManaged(String sohoType){

        String UserLE = XC_UTIL_User.getLegalEntityFromUser();

        if(String.isBlank(UserLe)){
            return false;
        }

        //checking current user legalentity:
        List<XC_CM_CountryLegalEntityAssociation__mdt> leConfs = [
                SELECT XC_LegalEntity__c,XC_Category__c
                FROM XC_CM_CountryLegalEntityAssociation__mdt
                WHERE XC_LegalEntity__c = :UserLE LIMIT 1];

        if(leConfs.isEmpty()){
            return false;
        }
        return sohoType.equalsIgnoreCase('B2B') && leConfs[0].XC_Category__c == 'B2B';
    }

    /**
     * @description Checks if the Account is Condominium Record Type
     * @param recordTypeId
     * @return check if the record type is one of SFM Adoption
     */

    public static Boolean isSFMAccount(String recordTypeId){
        String recordTypeName = Schema.SObjectType.Account.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
        return recordTypeName.contains('SFM');
    }
}
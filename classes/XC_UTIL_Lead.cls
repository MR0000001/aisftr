/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 28/08/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Lead – Util class for lead methods
*/ 

public without sharing class XC_UTIL_Lead { 
        
/**
* @author
* @date
* @date 
* @description 
*/  
    public class gdprWrapper {
        public String GiveDataToThirdParties;
        public List<LegalEntityWrapper> LegalEntity;
        public String VersionConsentThirdParty; 
        public Date ConsentThirdPartyDate;
        public String RobinsonCustomer; 
    }
            
    /**
    * @author
    * @date
    * @date 
    * @description 
    */  
     public class LegalEntityWrapper{
        public String LegalEntityID;
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


    /** 
    *@description LeadRESTWrapper 
    */
    public class LeadRESTWrapper {
        public String LeadID;
        public String LeadType;
        public String LastName;
        public String FirstName;
        public String BusinessName;
        public String PhonePrefix;
        public String Phone;
        public String PrimaryEmail;  
        public String IdentityCountry;
        public String IdentityType;
        public String IdentityNumber;
        public String ReleaseDate;
        public String ExpiryDate;
        public String Nationality;
        public String Birthdate;
        public String ReceivingChannel;
        public String Source;
        public String PreferenceLanguage;
        public String ProductCategoryOfInterest;
        public String RequestType;
        public String CommercialVisitPreferredTime;
        public String Notes;
        public String Company;
        public String Country;
        public String OpportunityID;
        public Boolean CommercialVisit;
        public String AccountID;    // for Convert Lead
        public String AccountType;  // for Convert Lead
        public String ContactID;    // for Convert Lead
        public String Status;

        public String MobilePrefix;
        public String Mobile;

        public String ProductID;
        public String CampaignPlatform;
        public String CampaignProduct;
        public String CampaignCode;
        public String ConventionCode;

        public String ECID;
        public String ZipCode;
        public String Stream = 'B2C';
        public String LeadFormID;
        public String CompanySectorLev1;
        public String CompanySectorLev2;
        public String Salutation;

        public String ExternalID;
        public String PartnerEventCode;
        public Boolean PrivacyInfo;
        public Boolean Newsletter;
        public String Location;
        public String AvailableSurface;
        public String RoofType;
        public String AnnualBillingAmount;
        public String AnnualEnergyConsumption;
        public String Voltage;
        public String ContractedPower;
        public String WeeklyBehaviour;
        public String DailyBehaviour;
        public String NominalPower;
        public String AvgProducibility;
        public String CostSavings;
        public String PaybackPeriod;
        public String co2Avoidance;
        public String PlantCost;
        public String AutoconsumedEnergy;
        public String ExchangedEnergy;
        public String NumberOfVehicles;
        public String VehicleType;
        public String ChargePoint;
        public String RentingPeriod;
        public String VehicleMileage;
        public String Theatre;
        public String SalesChannel;
        public String SegmentOfCountry;

        public String UserChannelName;
        public String UserChannelCode;
        public String UserSubchannelCode;
        public String UserSubchannelName;
        public String UserNumber;
        public String RegistrationLink;

        //Lead Outbound
        public String OrderID;
        public String ContactRequestDate;
        public String ContactRequestTimeSlot;
        public String BillingExternalID;
        public Boolean SendToGenesys;
        public String ProductName;
        public String RequestDate;
        public Boolean CustomerBaseEE;
        public String OpportunityOwnerReceivingChannel;
        public String OpportunityOwnerName;
        public String OpportunityOwnerCompany;

        public List<XC_UTIL_Account.IdentityIFWrapper> Identity;
        public XC_UTIL_Address.AddressWrapper Address;
        public gdprWrapper GDPR;
    }


    /** 
     * @description Checks if the Lead is Residential Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isResidential(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
    }

    /** 
     * @description Checks if the Lead is Soho Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isSoho(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Soho').getRecordTypeId();
    }

    /** 
     * @description Checks if the Lead is Condominium Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isCondominium(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Condominium').getRecordTypeId();
    }

    /** 
     * @description Checks if the Lead is from Web
     * @param ld - the lead
     * @return the boolean
     */

    public static Boolean isSourceWeb(Lead ld){
        return ld.XC_Channel__c == Label.XC_CL_Web;
    }

    /** 
     * @description Checks if the Lead is massively uploaded
     * @param ld - the lead
     * @return the boolean
     */
 
    public static Boolean isSourceDataLoader(Lead ld){
        return ld.XC_MassivelyCreated__c;
    }   
    
    /** 
     * @description Checks if the Lead is Condominium Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isGlobalB2B(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
    }
    /** 
     * @description Checks if the Lead is Condominium Record Type
     * @param recordTypeId
     * @return the boolean
     */

    public static Boolean isGlobalB2G(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
    }
    
    public static Boolean isGlobalLead(String recordTypeId){
        return recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_Global').getRecordTypeId();
    }
}
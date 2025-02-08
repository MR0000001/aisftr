/**
*@author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
*@date Creation 28/09/2018
*@date Modification dd/mm/yyyy
*@description XC_UTIL_Opportunity – Util class for Opportunity methods
**/ 
public with sharing class XC_UTIL_Opportunity{
    /**
    *@description
    */
    public class OpportunityIFWrapper {
        public String OpportunityID;
        public String OpportunityName; 
        public String AccountID;
        public String ContactID;
        public String ProductCategoryOfInterest;
        public Date CloseDate;
        public String Status;
        public String LossReason;
        public String LossReasonDescription;
        public Integer Probability;
        public String PrincingRegion;
        public String ReceivingChannel;
        public String Sources;
        public String PrimaryCampaignSource;
        public String Scoring;
        public Boolean ExecuteAssignment = false;
        public String Description;
        public String LegalEntity;
        public String AddressID;   
        public String WorkOrderID; 
        
        public String UniqueID;
        public String ProductType;

        public String CampaignPlatform; 
        public String CampaignProduct;
        public String CampaignCode;
        public String ConventionCode; 
        public String ECID;

        //B2B2G
        public String LeadID;
        public String OpportunityType;
        public String LeadSourceCampaign;
        public String LeadChannelCategory;
        public String LeadChannel;
        public String SalesChannel;

    }

    /**
    *@param acc
    *@param ld
    *@return Opportunity
    *@description Method to createOpportunity
    */
    public static Opportunity createOpportunity(Account acc, Lead ld){
        Opportunity opp = new Opportunity();
        opp.Name = acc.Name;
        opp.AccountId = acc.Id;
        opp.StageName = Label.XC_CL_Opportunity_Draft;  
        opp.XC_ProductCategoryOfInterest__c = ld.XC_ProductCategoryOfInterest__c;
        return opp;
    }  

    /** 
    *@author Marco Rosa - marco.rosa@nttdata.com
    *@description Method to get Opportunity RecordTypeId By Country.
    *@param listCountries
    *@return map
    */
    public static Map<String, Id> getRecordTypeByCountry(List<String> listCountries){
        Map<String, String> mapCountryRecordTypeName = new Map<String, String>{ 
            'SPAIN' => 'XC_Opportunity_Spain' 
        };
        return XC_UTIL_SObject.getRecordTypeMapByCountry('Opportunity', listCountries, mapCountryRecordTypeName);
	}  
 
    /**
    *@author Marco Rosa - marco.rosa@nttdata.com
    *@description Method to get Opportunity Default Close Date By Country.
    *@param listCountries
    *@return mapCountryDefaultCloseDate
    **/
    public static Map<String, Date> getDefaultCloseDateByCountry(List<String> listCountries){
        Map<String, Date> mapCountryDefaultCloseDate = new Map<String, Date>();
		Set<String> setCountries = new Set<String>(listCountries);
        List<XC_CM_Opportunity_Default_Values__mdt> listMetadata = new List<XC_CM_Opportunity_Default_Values__mdt>();
        if(Schema.sObjectType.XC_CM_Opportunity_Default_Values__mdt.isAccessible() && Schema.sObjectType.XC_CM_Opportunity_Default_Values__mdt.fields.XC_Country__c.isAccessible() && Schema.sObjectType.XC_CM_Opportunity_Default_Values__mdt.fields.XC_Default_Days_For_Close_Date_On_Insert__c.isAccessible()){
            listMetadata = [SELECT XC_Country__c, XC_Default_Days_For_Close_Date_On_Insert__c 
                                                            FROM XC_CM_Opportunity_Default_Values__mdt
                                                             WHERE XC_Country__c IN:setCountries];
        }
        for(String countryName : setCountries){ 
            for(XC_CM_Opportunity_Default_Values__mdt md : listMetadata){
                if(md.XC_Country__c == countryName){
                    Integer n = Integer.valueOf(md.XC_Default_Days_For_Close_Date_On_Insert__c);
                    if(n != null){
                        mapCountryDefaultCloseDate.put(countryName, Date.today().addDays(n));
                    } else {
                        mapCountryDefaultCloseDate.put(countryName, Date.today().addDays(30));
                    }
                }
            } 
        } 
		return mapCountryDefaultCloseDate;
	}



}
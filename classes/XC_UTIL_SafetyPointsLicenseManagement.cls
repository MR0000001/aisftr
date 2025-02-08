/**
 * @description       : Util Class for Safety Points License Management
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 17-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_UTIL_SafetyPointsLicenseManagement {
    
    public class SafetyPointsLicense{
        String country{get;set;}
        String legalEntity{get;set;}
        Boolean kpiPerformanceEnabled{get;set;}
        Boolean safetyPointsLicenseEnabled {get;set;}
        Integer defaultInitPoints{get;set;}
        Integer defaultMinPoints{get;set;}
        Integer defaultMaxPoints{get;set;}
        Integer defaultWalletNumber{get;set;}
        Integer maxWallets{get;set;}

        public SafetyPointsLicense(String country, String legalEntity, Boolean kpiPerformanceEnabled, Boolean safetyPointsLicenseEnabled, Integer defaultInitPoints, Integer defaultMinPoints, Integer defaultMaxPoints, Integer defaultWalletNumber, Integer maxWallets){
            this.country = country;
            this.legalEntity = legalEntity;
            this.kpiPerformanceEnabled = kpiPerformanceEnabled;
            this.safetyPointsLicenseEnabled = safetyPointsLicenseEnabled;
            this.defaultInitPoints = defaultInitPoints;
            this.defaultMinPoints = defaultMinPoints;
            this.defaultMaxPoints = defaultMaxPoints;
            this.defaultWalletNumber = defaultWalletNumber;
            this.maxWallets = maxWallets;
        }
    }

    /**
    * @description get Safety Points License Information by country
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param country 
    * @param legalEntity 
    * @return XC_CS011_SafetyPointsLicenseSettings__c 
    **/
    public static XC_CS011_SafetyPointsLicenseSettings__c getSpecificSafetyPointsLicenseSettings(String country) {
        XC_CS011_SafetyPointsLicenseSettings__c countrySetting;
        List<XC_CS011_SafetyPointsLicenseSettings__c> safetyPointsLicenseSettings = XC_CS011_SafetyPointsLicenseSettings__c.getAll().values();
        for(XC_CS011_SafetyPointsLicenseSettings__c s : safetyPointsLicenseSettings) {
            if(String.isNotBlank(s.XC_Country__c) && s.XC_Country__c.equals(country)) {
                countrySetting = s;
            }
        }
        return countrySetting;
    }

    /**
    * @description get all Safety points licenses from countries passed by parameters
    * @author pedro.danielalmeida@nttdata.com | 10-05-2022 
    * @param countries 
    * @param legalEntities 
    * @return Map<String, XC_CS011_SafetyPointsLicenseSettings__c> 
    **/
    public static Map<String,XC_CS011_SafetyPointsLicenseSettings__c> getSafetyPointsLicenseSettings(Set<String> countries){
        Map<String,XC_CS011_SafetyPointsLicenseSettings__c> mapSafetyPointsLicenseSettings = new Map<String,XC_CS011_SafetyPointsLicenseSettings__c>();
        List<XC_CS011_SafetyPointsLicenseSettings__c> safetyPointsLicenseSettings = XC_CS011_SafetyPointsLicenseSettings__c.getAll().values();
        for(XC_CS011_SafetyPointsLicenseSettings__c s : safetyPointsLicenseSettings) {
            if(countries.contains(s.XC_Country__c)) {
                mapSafetyPointsLicenseSettings.put(s.XC_Country__c, s);
            }
        }
        return mapSafetyPointsLicenseSettings;
    }



    /**
    * @description check if Safety Points License is enabled for the country and legal entity
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param country 
    * @param legalEntity 
    * @return Boolean 
    **/
    public static Boolean safetyPointsLicenseIsEnabled(String country){
        XC_CS011_SafetyPointsLicenseSettings__c safetyPointsLicenseSettings = getSpecificSafetyPointsLicenseSettings(country/* ,legalEntity */); 

        if (safetyPointsLicenseSettings != null) {
            return safetyPointsLicenseSettings.XC_SafetyPointsLicenseEnabled__c;
        } else {
            return null;
        }
    }

    /**
    * @description check if KPI Planning Performance is enabled for country and legal entity
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param country 
    * @param legalEntity 
    * @return Boolean 
    **/
    public static Boolean kpiPlaningPerformanceIsEnabled(String country){
        XC_CS011_SafetyPointsLicenseSettings__c safetyPointsLicenseSettings = getSpecificSafetyPointsLicenseSettings(country/* ,legalEntity */); 

        if (safetyPointsLicenseSettings != null) {
            return safetyPointsLicenseSettings.XC_KPIPlanningPerformanceEnabled__c;
        } else {
            return null;
        }
    }

    /**
    * @description get the maximum number of wallets for country and legal entity
    * @author pedro.danielalmeida@nttdata.com | 09-05-2022 
    * @param country 
    * @param legalEntity 
    * @return Integer 
    **/
    public static Integer getSafetyPointsLicenseMaxWallet(String country){
        XC_CS011_SafetyPointsLicenseSettings__c safetyPointsLicenseSettings = getSpecificSafetyPointsLicenseSettings(country/* ,legalEntity */); 

        if (safetyPointsLicenseSettings != null) {
            return Integer.valueOf(safetyPointsLicenseSettings.XC_MaxWallets__c);
        } else {
            return null;
        }
    }

    /**
    * @description creates new XC_CS011_SafetyPointsLicenseSettings__c record
    * @author pedro.danielalmeida@nttdata.com | 12-05-2022 
    * @param spl 
    **/
    public static void createNewSafetyPointsLicenseSettings(SafetyPointsLicense spl){
        XC_CS011_SafetyPointsLicenseSettings__c settings = new XC_CS011_SafetyPointsLicenseSettings__c();
        settings.XC_Country__c = spl.country;
        settings.XC_DefaultInitialPoints__c = spl.defaultInitPoints;
        settings.XC_DefaultMaximumPoints__c = spl.defaultMaxPoints;
        settings.XC_DefaultMinimumPoints__c = spl.defaultMinPoints;
        settings.XC_DefaultWalletNumber__c = spl.defaultWalletNumber;
        settings.XC_KPIPlanningPerformanceEnabled__c = spl.kpiPerformanceEnabled;
        settings.XC_LegalEntity__c = spl.legalEntity;
        settings.XC_MaxWallets__c = spl.maxWallets;
        settings.XC_SafetyPointsLicenseEnabled__c = spl.safetyPointsLicenseEnabled;
        settings.Name = 'EnelXItalia_'+spl.country;
        insert settings;
    }
}
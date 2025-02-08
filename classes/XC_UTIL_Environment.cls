/**
* @author Monica Cutillo - mcutillo@deloitte.it
* @date Creation 06/09/2018
* @date Modification dd/mm/yyyy
* @description XC_LCC002_NewLead_D – DAO Class for XC_LCC002_NewLead
*/
public with sharing class XC_UTIL_Environment {

    /**
    *@description method to isMobileOrCommunityExperience
    *@return String
    **/
    @AuraEnabled
    public static String isMobileOrCommunityExperience(){
        String experience='isConsole';
        string info = UserInfo.getUiTheme();
        System.debug('UserInfoTheme'+info);
     	if(info=='Theme4t'){
         	experience='isMobile';
     	} 
        if(info=='Theme3'){
            experience='isCommunity';
        }
        
        return experience;
    }

    /**
    *@description method to isMobileExperience
    *@return boolean
    **/
    public static boolean isMobileExperience(){
        boolean isMobileExperience = false;
        string info = UserInfo.getUiTheme();
        System.debug('UserInfoTheme'+info);
     	if(info=='Theme4t'){
         	isMobileExperience=true;
     	} 
        
        return isMobileExperience;
    }

    /**
    *@description method to isSystemAdmin
    *@return boolean
    **/
    public static Boolean isSystemAdmin(){
        System.debug('entrato in isSystemAdmin');
        boolean isSystemAdmin = false;
        Id id1 = UserInfo.getProfileId();
        List<Profile> plist = new List<Profile>();
        if(Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible()){
            plist = [SELECT Name FROM Profile WHERE Id =: id1 limit 1];
        }
        if(plist[0].Name=='System Administrator'){
            isSystemAdmin = true;
        }
        System.debug('My type is System= '+isSystemAdmin);
        return isSystemAdmin;
    }

    /**
     * @description method to isCommunity
     * @return boolean
     **/
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }

}
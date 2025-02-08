/**
 * The Class XC_LCC091_U_NewZipCodeSkillTerritory.
  * @description  UTIL for NewZipCodeSkillTerritory component
 */
public without sharing class XC_LCC091_U_NewZipCodeSkillTerritory {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC091_NewZipCodeSkillTerritory');
     /**
     * Check root territory for profiles.
     * @description  method for checkRootTerritoryForProfiles
     * @param recordId the record id
     * @return the boolean
     */
   
    public static Boolean checkRootTerritoryForProfiles (Id recordId){
        Boolean cannotInsert = false;
       
        if(!Schema.sObjectType.ServiceTerritory.isAccessible() && !Schema.sObjectType.User.isAccessible()){
            cannotInsert = false; 
        }else{
            Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>([SELECT Id, XC_IsRoot__c
                                                                                         FROM ServiceTerritory 
                                                                                         WHERE Id =: recordId]);
        
            ServiceTerritory serviceTerritory = serviceTerritoryMap.values();

            Map<Id,User> currentUserMap = new Map<Id,User>([SELECT Id, Profile.Name, Profile.Id,Profile.UserLicense.Name  
                                                            FROM User  
                                                            WHERE Id =: UserInfo.getUserId()]);
            User currentUser = currentUserMap.values();
            if(serviceTerritory.XC_IsRoot__c == true && currentUser.Profile.UserLicense.Name == Label.XC_CL_PartnerCommunity){
            cannotInsert = true;
            }         
        }
        return cannotInsert;
    }
    
     /**
     * Check root territory for profiles.
     * @description  method for checkRootTerritoryForProfiles in Edit mode
     * @param recordId the record id
     * @return the boolean
     */
   
     public static Boolean checkRootTerritoryForProfilesInEdit(Id recordId){
        Boolean cannotInsert = false;
       
        if(!Schema.sObjectType.ServiceTerritory.isAccessible() && !Schema.sObjectType.User.isAccessible()){
            cannotInsert = false; 
        }else{
            XC_ZipCodeSkill_TerritoryAssociation__c zipCodeAssociation = setZipCodeValues(recordId);
            Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>( [SELECT Id, XC_IsRoot__c 
                                                                                          FROM ServiceTerritory 
                                                                                          WHERE Id =: zipCodeAssociation.XC_ServiceTerritoryId__c]);
            ServiceTerritory serviceTerritory = serviceTerritoryMap.values();
            Map<Id,User> currentUserMap = new Map<Id,User>([SELECT Id, Profile.Name, Profile.Id,Profile.UserLicense.Name  
                                                            FROM User  
                                                            WHERE Id =: UserInfo.getUserId()]);
            User currentUser = currentUserMap.values();
            if(serviceTerritory.XC_IsRoot__c == true && currentUser.Profile.UserLicense.Name == Label.XC_CL_PartnerCommunity){
            cannotInsert = true;
            }                   
        }
        return cannotInsert;
    }
    
    
     /**
     * @description method to set the zip code values.
     *
     * @param recordId the record id
     * @return the x C zip code skill territory association c
     */
    
    public static XC_ZipCodeSkill_TerritoryAssociation__c setZipCodeValues(String recordId){
         Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT id, XC_Province__c, XC_ZipCode__c,XC_ListOfSkillNames__c, XC_ListOfSkills__c, XC_ServiceTerritoryId__c FROM XC_ZipCodeSkill_TerritoryAssociation__c
                                                             WHERE id=: recordId]);
        List<XC_ZipCodeSkill_TerritoryAssociation__c> zcs =zipcodeterritoryMap.values();
        return zcs[0]; 
    }
    


    
     /**
     * @description method to get Country.
     *
     * @param recordId the record id
     * @return the x C zip code skill territory association c
     */
    public static String getCountry(String recordId){
       String country = '';
       if(XC_UTIL_Sobject.getObjectType(recordId) == 'ServiceTerritory'){
            if(!Schema.sObjectType.ServiceTerritory.isAccessible()){
                return country;
            } else{ 
                Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>( [SELECT Id, XC_Country__c FROM ServiceTerritory WHERE Id =: recordId]);
                ServiceTerritory serviceTerritory = serviceTerritoryMap.values();
                country = serviceTerritory.XC_Country__c;
            }
        }else if(XC_UTIL_Sobject.getObjectType(recordId) == 'XC_ZipCodeSkill_TerritoryAssociation__c') {
             if(!Schema.sObjectType.XC_ZipCodeSkill_TerritoryAssociation__c.isAccessible() ){
                  return country;
            } else{
                Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT Id, XC_ServiceTerritoryId__r.XC_Country__c  FROM XC_ZipCodeSkill_TerritoryAssociation__c WHERE Id =: recordId]);
                XC_ZipCodeSkill_TerritoryAssociation__c zipcodeterritory = zipcodeterritoryMap.values();
                country = zipcodeterritory.XC_ServiceTerritoryId__r.XC_Country__c;
            }
        }
      
        
        system.debug('recordId -->'+recordId);
        system.debug('country-->' + country);
        return country;              
    } 

    /**
     * @description Check for WrapperResult
     * @param listSobjectResult - List<XC_UTIL_Sobject.WrapperResult>
     * @param rw - XC_UTIL_ResultWrapper
     */
    public static void checkResultSuccess(List<XC_UTIL_Sobject.WrapperResult> listSobjectResult, XC_UTIL_ResultWrapper rw) {
        for(XC_UTIL_Sobject.WrapperResult sobjectResult : listSobjectResult){
            if(!sobjectResult.success){
                rw.resultMessage = sobjectResult.errorMessage;
                rw.success = false;
            }
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'risultato dell insert zc = '+rw); 
        }
    }




}
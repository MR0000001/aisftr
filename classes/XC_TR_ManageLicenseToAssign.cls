/** 
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 05/05/2020
* @date Modification dd/mm/yyyy
* @description XC_TR_ManageLicenseAssign – Utility for assign Platform license dinamically                            
*/  
public without sharing class XC_TR_ManageLicenseToAssign {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ManageLicenseToAssign');
    
    public class LicenseWrapper {
    	public String platformName;
  		public Boolean licenseNeeded = false;
        public PackageLicense correctLicense;
        public List<String> permissionSetNeeded;
    }
    
     /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @date 05/05/2020
     * @description Method to be executed on after insert
     * @param listNew - list<User> -> record To Check for any Platform
    */
    public static void checkPermissionNeeded(List<User> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkPermissionNeeded'); 
        List<User> fslUserToManage = new  List<User>();
        List<User> gloviaUserToManage = new  List<User>();
        List<User> CloudCoachUserToManage = new  List<User>();
        for(User u : listNew){
            if(u.isActive){
                if(u.XC_isGloviaUser__c){
                    gloviaUserToManage.add(u);
                }
                if(u.XC_IsCloudCoachUser__c){
                  CloudCoachUserToManage.add(u);
                }
                //...add logic for the other platform here
            }
        }
        if(!gloviaUserToManage.isEmpty()){
            setPermissionFor('Glovia',listNew);
        }
        if(!CloudCoachUserToManage.isEmpty()){
            setPermissionFor('CloudCoach',listNew);
        }
        
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @date 05/05/2020
     * @description Method to be executed on after update
     * @param listNew - list<User> -> record To Check for Glovia in Update
    */
    public static void checkIfAddOrRemoveGloviaLicense(List<User> listNew, map<Id,User> mapOld, map<Id,User> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkIfAddOrRemoveGloviaLicense'); 
        List<User> userToAddGloviaLicense = new List<User>();
        List<User> userToRemoveGloviaLicense = new List<User>();  
        for(User u : listNew){
            if(u.IsActive){
                if(mapNew.get(u.Id).XC_isGloviaUser__c && mapOld.get(u.Id).XC_isGloviaUser__c==false){
                    userToAddGloviaLicense.add(u);
                }
                if(mapNew.get(u.Id).XC_isGloviaUser__c==false && mapOld.get(u.Id).XC_isGloviaUser__c){
                    userToRemoveGloviaLicense.add(u);
                }
            }
        }
        
        if(!userToAddGloviaLicense.isEmpty()){
            setPermissionFor('Glovia', userToAddGloviaLicense);
        }
        if(!userToRemoveGloviaLicense.isEmpty()){
            removeGloviaLicense(userToRemoveGloviaLicense);
        }
        
    }
    
    /**
     * @author Ketan Raninga - ketan.raninga@vyomlabs.com
     * @date 14/02/2022
     * @description Method to be executed on after update
     * @param listNew - list<User> -> record To Check for  CloudCoach in Update
    */
    public static void checkIfAddOrRemoveCloudCoachLicense(List<User> listNew, map<Id,User> mapOld, map<Id,User> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkIfAddOrRemoveCloudCoachLicense'); 
        List<User> userToAddCloudCoachLicense = new List<User>();
        List<User> userToRemoveCloudCoachLicense = new List<User>();  
        for(User u : listNew){
            if(u.IsActive){
                if(mapNew.get(u.Id).XC_IsCloudCoachUser__c && mapOld.get(u.Id).XC_IsCloudCoachUser__c ==false){
                    userToAddCloudCoachLicense.add(u);
                }
                if(mapNew.get(u.Id).XC_IsCloudCoachUser__c==false && mapOld.get(u.Id).XC_IsCloudCoachUser__c ){
                    userToRemoveCloudCoachLicense.add(u);
                }
            }
        }
        
        if(!userToAddCloudCoachLicense.isEmpty()){
            setPermissionFor('CloudCoach', userToAddCloudCoachLicense);
        }
        if(!userToRemoveCloudCoachLicense.isEmpty()){
            removeCloudCoachLicense(userToRemoveCloudCoachLicense);
        }    
    }
    
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @date 05/05/2020
     * @description Method to be executed on after insert
     * @param listNew - list<User> -> record To Check
     * @param platformToCheck - String -> Name of the platform to retrieve information 
    */
     public static void setPermissionFor(String platformToCheck, List<User> userList ){
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'In setPermissionFor '+platformToCheck); 
         List<UserPackageLicense> newPackageLicenseToInsert = new List<UserPackageLicense>();
         List<PermissionSetAssignment> permissionSetToInsert = new List<PermissionSetAssignment>();
         LicenseWrapper lw  = retrieveAllPlatformPermission(platformToCheck); 
         Set<Id> permissionSetIds;
         if(lw.permissionSetNeeded != null && !lw.permissionSetNeeded.isEmpty()){
              permissionSetIds = retrievePermissionSetIdsByNames(lw.permissionSetNeeded);
         }
         for(User u : userList){
             if(lw.licenseNeeded){
                 if((lw.correctLicense).AllowedLicenses==-1 || (lw.correctLicense).AllowedLicenses>0 ){
                    UserPackageLicense upl = new UserPackageLicense(UserId = u.id, PackageLicenseId = (lw.correctLicense).id);
                    newPackageLicenseToInsert.add(upl);
                 }
             }
             if(lw.permissionSetNeeded != null && !lw.permissionSetNeeded.isEmpty()){
                 for(Id psId : permissionSetIds){
                 	PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psId, AssigneeId = u.Id);
                 	permissionSetToInsert.add(psa);
                  }
             }
         }
         
         XC_UTIL_Glovia.insertAndDontLogError(newPackageLicenseToInsert);
         XC_UTIL_Glovia.insertAndDontLogError(permissionSetToInsert);
     }
    
     /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @date 05/05/2020
     * @description Method to retrieve platform info
     * @param String - platformName -> retrieve permission needed by platform name
    */
    public static LicenseWrapper retrieveAllPlatformPermission(String platformName){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In retrieveAllPlatformPermission'); 
        LicenseWrapper lw = new LicenseWrapper();
        lw.platformName = platformName;
        XC_UserPermission__c cs = XC_UserPermission__c.getValues(platformName);
        if(!String.isBlank(cs.XC_PermissionSetToAdd__c)){
                    lw.permissionSetNeeded = (cs.XC_PermissionSetToAdd__c).split(';');            
        }
        if(cs.XC_LicenseRequired__c){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'required license');
                    lw.licenseNeeded = true;
                    lw.correctLicense = retrieveCorrectLicense(cs.XC_NamespacePrefix__c);
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'lw = '+lw);
        return lw;
        
    }
    
    
    
      /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @date 05/05/2020
     * @description Method to be executed on after insert
     * @param String - namespacePrefix -> retrieve the Correct License to add
    */
    public static PackageLicense retrieveCorrectLicense(String namespacePrefix){
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'In retrieveCorrectLicense');
         PackageLicense pl = [SELECT Id, AllowedLicenses FROM PackageLicense WHERE NamespacePrefix =: namespacePrefix LIMIT 1];
         return pl;
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @date 05/05/2020
     * @description Method to be executed on after insert
     * @param String - namespacePrefix -> retrieve the Correct Permission Set to add
    */
    public static Set<Id> retrievePermissionSetIdsByNames(List<String> permissionSetNames){
        map<Id,PermissionSet> permissionMap = new map<Id,PermissionSet>([SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionSetNames]);
        Set<Id> permissionSetIds = XC_UTIL_Sobject.getSetIds(permissionMap.values());
        return  permissionSetIds;
    }
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @date 05/05/2020
     * @description Method to be executed on after update
     * @param userList - list<User> -> remove license for user without isGloviaUser Flag
    */
    public static void removeGloviaLicense(List<User> userList){
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'In removeGloviaLicense');
         List<id> userIds = XC_UTIL_Sobject.getIds(userList);
         PackageLicense pl = retrieveCorrectLicense('gii');
         map<Id,UserPackageLicense> newPackageLicenseToRemove = new map<Id,UserPackageLicense>([SELECT Id FROM UserPackageLicense WHERE UserId IN: userIds AND PackageLicenseId=:pl.Id ]);
         delete newPackageLicenseToRemove.values();    
        
    }
    
    /**
     * @author Ketan Raninga - ketan.raninga@vyomlabs.com
     * @date 14/02/2022
     * @description Method to be executed on after update
     * @param userList - list<User> -> remove license for user without IsCloudCoachUser Flag
    */
    public static void removeCloudCoachLicense(List<User> userList){
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'In removeCloudCoachLicense');
         List<id> userIds = XC_UTIL_Sobject.getIds(userList);
         PackageLicense pl = retrieveCorrectLicense('project_cloud');
         map<Id,UserPackageLicense> newPackageLicenseToRemove = new map<Id,UserPackageLicense>([SELECT Id FROM UserPackageLicense WHERE UserId IN: userIds AND PackageLicenseId=:pl.Id ]);
         delete newPackageLicenseToRemove.values();         
    }
    
    

}
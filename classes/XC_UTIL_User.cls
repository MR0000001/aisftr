/**
* @author Giulio Serra giserra@deloitte.it
* @date Creation 22/10/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_User - contains utils to process users roles 
*/ 

public without sharing class XC_UTIL_User {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_User');

    /**
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @description get data from Portal UserId
    * @param userId - Id User
    * @return result data Map
    */
    public static Map<String,Object> getInfoFromPortalUser(String userId){
        Map<String,Object> userData = new Map<String,Object>();
        List<User> users = [SELECT id, Country__c, XC_LegalEntity__c, Account.XC_AMP_Partner__c FROM User WHERE Id =: userId];
        if(users.isEmpty()){
            return userData;
        }
        userData.put('Country__c',users[0].Country__c);
        userData.put('XC_LegalEntity__c',users[0].XC_LegalEntity__c);
        userData.put('XC_AMP_Partner__c',users[0].Account.XC_AMP_Partner__c);
        return userData; 
    }

    
    /**
    * @author Giulio Serra giserra@deloitte.it
    * @date Creation 22/10/2018
    * @date Modification dd/mm/yyyy
    * @description get Channel from User
    * @param userId - Id User
    * @return Receiving Channel User
    */
    public static String getChannelFromUser(String userId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in getChannelFromUser con userId= '+userId); 
        
        List<User> userList = [SELECT id, XC_Receiving_Channel__c FROM User WHERE Id=:userId];
        if(!userList.isEmpty() && userList[0].XC_Receiving_Channel__c!=null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_Receiving_Channel__c = '+userList[0].XC_Receiving_Channel__c);
            return userList[0].XC_Receiving_Channel__c;
        }else{
            return '';
        }
    }
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 22/07/2019
    * @date Modification dd/mm/yyyy
    * @description get Country from User
    * @param userId - Id User
    * @return User Country
    */
    public static String getCountryFromUser(String userId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in getCountryFromUser con userId= '+userId); 
        
        List<User> userList = [SELECT id, Country__c FROM User WHERE Id=:userId];
        if(!userList.isEmpty() && userList[0].Country__c!=null){
            return userList[0].Country__c;
        } else{ 
            return ''; 
        }
    }
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 22/07/2019
    * @date Modification dd/mm/yyyy
    * @description get Legal Entity from User
    * @param userId - Id User 
    * @return User Legal Entity
    */
    public static String getLegalEntityFromUser(){
        String userId = UserInfo.getUserId();
        System.debug('@@@Entrato in getLegalEntityFromUser con userId= '+userId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in getLegalEntityFromUser con userId= '+userId);
        if(!Schema.sObjectType.User.isAccessible()) { 
            return ''; 
        }
        
        List<User> userList = [SELECT id, XC_LegalEntity__c FROM User WHERE Id=:userId];
        if(!userList.isEmpty() && userList[0].XC_LegalEntity__c!=null){
            return userList[0].XC_LegalEntity__c;
        }else{ 
            return ''; 
        }
    }

     /**
    * @author dpalamides
    * @date Creation 22/07/2019
    * @date Modification dd/mm/yyyy
    * @description get CountryLE association by current user
    * @return XC_CM_CountryLegalEntityAssociation__mdt
    */
    public static XC_CM_CountryLegalEntityAssociation__mdt getLegalEntityMetadataFromUser(){
        String userId = UserInfo.getUserId();
        if(!Schema.sObjectType.User.isAccessible() || !Schema.sObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()) { 
            return null; 
        }

        List<User> userList = [SELECT id, XC_LegalEntity__c FROM User WHERE Id=:userId];
        if(!userList.isEmpty() && userList[0].XC_LegalEntity__c!=null){
            XC_CM_CountryLegalEntityAssociation__mdt le = [select id, XC_Category__c, XC_LegalEntity__c,XC_Country__c,XC_LegalEntityGroup__c,XC_PhonePrefix__c,XC_Nationality__c,XC_Preferredlanguageofcontact__c from XC_CM_CountryLegalEntityAssociation__mdt where XC_LegalEntity__c = :userList[0].XC_LegalEntity__c LIMIT 1];
            return le;
        }else{ 
            return null; 
        }
    }

    
    /**
     * @author dpalamides
     * @date Creation 09/12/2019
     * @date Modification dd/mm/yyyy
     * @description get Legal Entity multi-picklist from User
     * @return User Legal Entities
     */
    public static List<String> getLegalEntitiesFromUser(){
        String userId = UserInfo.getUserId();
        List<String> ret = new List<String>();
        if(!Schema.sObjectType.User.isAccessible()) { return new List<String>(); }
 
        List<User> userList = [SELECT id, XC_LegalEntity__c,XC_LegalEntities__c FROM User WHERE Id=:userId];
        if(!userList.isEmpty() && userList[0].XC_LegalEntities__c!=null){
            ret.addAll(userList[0].XC_LegalEntities__c.split(';'));
            ret.add(userList[0].XC_LegalEntity__c);
            return ret;
        }else if(!userList.isEmpty() && userList[0].XC_LegalEntity__c!=null){
            ret.add(userList[0].XC_LegalEntity__c);
            return ret;
        }
        else{ return new List<String>(); }
    }


    /**
    * @author Giulio Serra giserra@deloitte.it
    * @date Creation 22/10/2018
    * @date Modification dd/mm/yyyy
    * @description get Role Names from User
    * @param users - List User
    * @return roleNames
    */ 
    public static List<String> getRoleNamesFromUsers(List<User> users){

        List<String> roleNames = new List<String>();

        for(User us : users){
          
            us.XC_AccountId__c = us.AccountId; 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'E UTENTE PARTNER COMMUNITY');

            //populate the map with correspondig Partner Contact
            //userAndContact.put(us.Id, us.Contact);
            
            String accountName = us.Contact.Account.Name; 
            
            roleNames.add(accountName + ' ' + 'Partner User'); //TODO custom Label 
            roleNames.add(accountName + ' ' + 'Partner Executive'); //TODO custom Label 
            roleNames.add(accountName + ' ' + 'Partner Manager'); //TODO custom label
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ROLE NAME ' + roleNames);
            
        }

        return roleNames;
    }

    /**
    * @author Giulio Serra giserra@deloitte.it
    * @date Creation 22/10/2018
    * @date Modification dd/mm/yyyy
    * @description get Role Names from User
    * @param roleNames
    * @return roleNameIdMap - Map<String,Id>
    */ 
    public static Map<String,Id> getUserRoleNames(List<String> roleNames){
      XC_UTIL_Debug.debug(DEBUGACTIVE, 'getUserRoleNames ' + roleNames);
        Map<String,Id> roleNameIdMap = new Map<String,Id>();

        Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>(
            [SELECT Id,Name FROM UserRole WHERE Name IN: roleNames]
        );
       
        for(Id roleId : userRoleMap.keySet()){
            UserRole ur = userRoleMap.get(roleId);

            if(ur != null) {
                roleNameIdMap.put(ur.name, ur.Id);
            }
        }

        return roleNameIdMap;
    }

    /**
    * @author Giulio Serra giserra@deloitte.it
    * @date Creation 22/10/2018
    * @date Modification dd/mm/yyyy
    * @description get Role Names from User
    * @param users - List User
    * @param userRoles - Map<String,Id>
    */ 
  
    public static void setUsersRoles(List<User> users, Map<String,Id> userRoles) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in setUsersRoles');  }
      /*
        for(User u : users){
            u.XC_HasRoleBeenProcessed__c = true;
            String accountName = u.Contact.Account.Name;
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ACC NAME ' + accountName);
            if(u.Contact.XC_TypeOfContact__c == Label.XC_CL_Contact_PartnerAdministrator){
                u.UserRoleId =  userRoles.get(accountName + ' ' + 'Partner Executive');
            }else if(u.Contact.XC_TypeOfContact__c == Label.XC_CL_Contact_PartnerManager){
                u.UserRoleId =  userRoles.get(accountName + ' ' + 'Partner Manager');
            }else if(u.Contact.XC_TypeOfContact__c == Label.XC_CL_Contact_PartnerTechnician){
                u.UserRoleId =  userRoles.get(accountName + ' ' + 'Partner User');    
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'USER ROLE NUOVO ' + u.UserRoleId);
        } 
    }*/
    /**
    * @author dpalamides
    * @date Creation 22/07/2019
    * @date Modification dd/mm/yyyy
    * @description get CountryLE association by current user and the name of recordType for segmentation purpose
    * @return XC_CM_CountryLegalEntityAssociation__mdt
    */
    public static XC_CM_CountryLegalEntityAssociation__mdt getLegalEntityMetadataFromUserByRT(String recordType){
        String segment  = '';
        String userId = UserInfo.getUserId();
        if(!Schema.sObjectType.User.isAccessible() || !Schema.sObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()) { 
            return null; 
        }
        if(recordType.contains('B2B')){
            segment = 'B2B';
        }else if( recordType.contains('B2G') ){
            segment = 'B2G';
        }else{
            segment ='B2C';
        }
        List<User> userList = [SELECT id, XC_LegalEntity__c FROM User WHERE Id=:userId];
        if(!userList.isEmpty() && userList[0].XC_LegalEntity__c!=null){
            List<XC_CM_CountryLegalEntityAssociation__mdt> le = [select id, XC_Category__c, XC_LegalEntity__c,XC_Country__c,XC_LegalEntityGroup__c,XC_PhonePrefix__c,XC_Nationality__c,XC_Preferredlanguageofcontact__c from XC_CM_CountryLegalEntityAssociation__mdt where XC_LegalEntity__c = :userList[0].XC_LegalEntity__c AND XC_Stream__c = : segment ];
            if(!le.isEmpty()){
                return le[0];
            }else{
                return null;
            }
            
        }else{ 
            return null; 
        }
    }
}
/**
 * @description The Class XC_TR_Contact_FillChildrenInfo.
 */
public without sharing class XC_TR_Contact_FillChildrenInfo {

     /**
      * Update children info.
      * @author Giulio Serra giserra@deloitte.it
      * @param newContacts the new contacts
      * @param oldValues the old values
      * @param newValues the new values
      * @date Creation 23/10/2018
      * @description update the role of user children with the field from the fathers
      */ 
    public static void updateChildrenInfo(List<Contact> newContacts, Map<Id,Contact> oldValues, Map<Id,Contact> newValues){

        Set<Id> idFromContacts = new Set<Id>(XC_UTIL_Sobject.getIds(newContacts));

        List<User> toUpdate = new List<User>();
        List<String> fieldList = new List<String>{'XC_TypeOfContact__c'};
        List<Contact> changedContacts = XC_UTIL_SObject.getListChanged(fieldList, oldValues,newValues); // List of contacts where the fields of interest changed

        if(changedContacts.size() == 0){
            return;
        }

        Set<Id> contactIDs = new Set<Id>(XC_UTIL_Sobject.getIds(changedContacts));
        Set<Id> accountIDs = getAccountIdFromContacts(changedContacts);

        Map<Id, Contact> mapOfNewContacts = new Map<Id, Contact>();
        for(Contact cnt : changedContacts)
        {
          mapOfNewContacts.put(cnt.Id, cnt);
        }// map of new contacts 

        Map<ID,User> usersFromContacts = XC_TR_Contact_FillChildrenInfo_D.getUserFromContacts(contactIDs);

        Map<Id,UserRole> userIDs = userRoles(usersFromContacts.values());

        Map<String,Id> userRoleNames = mapOfRolesToId(userIDs);
        System.debug('userFromContacts' + usersFromContacts + 'Map of user Roles' + userIDs +  'Map of user Roles' + userRoleNames);

        Map<String, String> mapUserRoleId = new Map<String, String>();
    
        for(User currentUser : usersFromContacts.values()){

            System.debug('BEFORE' + ' ' + currentUser.Contact.XC_TypeOfContact__c);
            String accountName = currentUser.Contact.Account.Name;

            Contact newContact = mapOfNewContacts.get(currentUser.Contact.Id);

            if(newContact.XC_TypeOfContact__c == Label.XC_CL_Contact_PartnerAdministrator){
               currentUser.UserRoleId = userRoleNames.get(accountName + ' ' + 'Partner Executive');
               mapUserRoleId.put(currentUser.Id, userRoleNames.get(accountName + ' ' + 'Partner Executive'));
            }

            if(newContact.XC_TypeOfContact__c == Label.XC_CL_Contact_PartnerManager){
                currentUser.UserRoleId = userRoleNames.get(accountName + ' ' + 'Partner Manager');
               mapUserRoleId.put(currentUser.Id, userRoleNames.get(accountName + ' ' + 'Partner Manager'));
            }

            if(newContact.XC_TypeOfContact__c ==  Label.XC_CL_Contact_PartnerTechnician){
                currentUser.UserRoleId = userRoleNames.get(accountName + ' ' + 'Partner User');
               mapUserRoleId.put(currentUser.Id, userRoleNames.get(accountName + ' ' + 'Partner User'));
            }
            
            System.debug('AFTER' + ' ' + currentUser.UserRoleId+ ' ' + userIds.get(currentUser.UserRoleId));
            toUpdate.add(currentUser);
        }
        updateUsers(mapUserRoleId);
        System.debug('User to update' + toUpdate);
        //XC_UTIL_Sobject.updateListRecords(toUpdate);
    }


    /**
     * User roles.
     *
     * @author Giulio Serra giserra@deloitte.it
     * @param userToProcess the user to process
     * @return the map
     * @date Creation 23/10/2018
     * @description return a map of roles from the input list of users
     */ 
    private static Map<Id,UserRole> userRoles(List<User> userToProcess){

        List<String> roleNames = new List<String>();
        //For every iserted user
        for(User us : userToProcess){
            //verify if is a Partner User    

            System.debug('us role' + us.Profile.UserLicense.Name);

            if(us.Profile.UserLicense.Name == Label.XC_CL_PartnerCommunity){
                System.debug('E UTENTE PARTNER COMMUNITY');
                
                String accountName = us.Contact.Account.Name; 
                
                roleNames.add(accountName + ' ' + 'Partner User'); 
                roleNames.add(accountName + ' ' + 'Partner Executive'); 
                roleNames.add(accountName + ' ' + 'Partner Manager'); 

                System.debug('ROLE NAME ' + roleNames);
            }
        }

        Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>(
            [SELECT Id,Name FROM UserRole WHERE Name IN: roleNames]
        );

        return userRoleMap;
    }


      /**
       * Map of roles to id.
       *
       * @author Giulio Serra giserra@deloitte.it
       * @param idToRoles the id to roles
       * @return the map
       * @date Creation 23/10/2018
       * @description return a map of roles from the input list of users
       */ 
    private static Map<String,Id> mapOfRolesToId(Map<Id,UserRole> idToRoles){

        Map<String,Id> mapOfRoleId = new Map<String,Id>();

        for(Id roleId : idToRoles.keySet()){
            UserRole ur = idToRoles.get(roleId);
            mapOfRoleId.put(ur.name, ur.Id);
        }

        return mapOfRoleId;
    }

     /**
      * Gets the account id from contacts.
      *
      * @author Giulio Serra giserra@deloitte.it
      * @param contacts the contacts
      * @return the account id from contacts
      * @date Creation 23/10/2018
      * @description get the ID of the accounts from the input contacts
      */ 
    private static Set<Id> getAccountIdFromContacts(List<Contact> contacts){

        Set<Id> accountID = new Set<Id>();
        for(Contact current : contacts){
            accountID.add(current.AccountId);
        }

        return accountID;
    }

    /**
     * @description Update users.
     *
     * @param mapUserRoleId the map user role id
     */
    @future
    public static void updateUsers(Map<String, String> mapUserRoleId){
        System.debug('mapUserRoleId->' + mapUserRoleId); 
        List<User> userToUpdate = new List<User>();
        for(String userId : mapUserRoleId.keySet()){
            User u = new User();
            u.Id = userId;
            u.UserRoleId = mapUserRoleId.get(userId);
            userToUpdate.add(u);
        }
        XC_UTIL_Sobject.updateListRecords(userToUpdate);
    }
}
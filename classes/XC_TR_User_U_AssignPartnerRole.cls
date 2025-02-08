/**
* @author Federica Tavera federica.tavera@nttdata.com
* @date Creation 22/10/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_User_U_AssignPartnerRole - Assign the correct role to partner user based on the field 
* Type of Contact in the related partner contact
*/ 

public with sharing class XC_TR_User_U_AssignPartnerRole {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_User_U_AssignPartnerRole');
    
    /**
     * Assign role from contact type.
     * @description method to assignRoleFromContactType
     * @param userToInsert the user to insert
     */
    public static void assignRoleFromContactType(list<User> userToInsert){
        //List of user to Update
        //List<User> userToUpdate = new List<User>();
        
        //Map<Id,Contact> userAndContact = new Map<Id,Contact>(); 

        List<Id> userIds = XC_UTIL_Sobject.getIds(userToInsert);
        List<User> userToProcess = XC_TR_User_U_AssignPartnerRole_D.getUsers(userIds);
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'User to process: ' + userToProcess);
        List<String> roleNames = XC_UTIL_User.getRoleNamesFromUsers(userToProcess);
        Map<String,Id> roleNameIdMap = XC_UTIL_User.getUserRoleNames(roleNames);
        
        //For every inserted Partner user, verify the correspondeting Contact Type
        XC_UTIL_User.setUsersRoles(userToProcess, roleNameIdMap);
        
        //XC_UTIL_Sobject.updateListRecords(userToUpdate);
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'User to update: ' + userToProcess);
        XC_UTIL_Sobject.updateListRecords(userToProcess);    
    }
}
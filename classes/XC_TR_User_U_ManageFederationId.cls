/**
 * @author Luigi Porcelli - luporcelli@deloitte.it
 * @description classes.XC_TR_User_U_ManageFederationId 
 */

public without sharing class XC_TR_User_U_ManageFederationId {

    /**
     * @author Luigi Porcelli
     * @param listNew - List of the inserted new users
     * @description - This method works on the creation of a subset of users, setting the FederationId as the name and storing the name in User Owner field.
    */
    public static void manageFederationId(List<User> listNew){
        Set<String> updatableProfile = XC_CM_UserFederationId__mdt.getAll().keySet();
        Set<Id> newUsersProfileIds = new Set<Id>();
        Map<Id, String> profilesMap = new Map<Id, String>();

        for(User u : listNew){
            newUsersProfileIds.add(u.profileid);
        }
        for(Profile p : [SELECT ID, NAME FROM PROFILE WHERE ID IN :newUsersProfileIds]){
            profilesMap.put(p.id, p.name);
        }

        for(User u : listNew){
            if(!(u.FederationIdentifier == null || u.FederationIdentifier == '')){
                System.debug(u.FederationIdentifier);
                if(updatableProfile.contains(profilesMap.get(u.profileid))){
                    System.debug(u.name);
                    u.user_owner__c = u.FirstName + ' ' + u.LastName;
                    u.FirstName = '';
                    u.LastName = u.FederationIdentifier;
                }
            }
        }
    }
}
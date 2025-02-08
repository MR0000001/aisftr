/**
 * Created by LCONATO00 on 19/05/2020.
 */

public without sharing class UserSelector {
    public static User getUserbyId(String userId){
        User queriedUser = [SELECT Id, Profile.Name, SerialNumber__c, UserRole.Name FROM User WHERE Id =: userId];
        return queriedUser;
    }

    public static User getAdminUser(){
        User queriedUser = [SELECT Id, Email FROM User WHERE (Username LIKE '%admin%') AND (Username LIKE '%pwc%') LIMIT 1];
        return queriedUser;
    }

}
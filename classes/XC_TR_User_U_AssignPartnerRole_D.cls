/**
 * @description DAO Class for XC_TR_User_U_CopyChannelForPartner.
 */
public without sharing class XC_TR_User_U_AssignPartnerRole_D {
    /**
    * @description query on Users
    * @param userIds the id of users
    * @return users list of users    
    */
    public static List<User> getUsers(List<Id> userIds){
        List<User> userToProcess = new List<User>();
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.ProfileId.isAccessible() && Schema.sObjectType.User.fields.ContactId.isAccessible() && Schema.sObjectType.User.fields.UserRoleId.isAccessible() && Schema.sObjectType.User.fields.AccountId.isAccessible() && Schema.sObjectType.User.fields.XC_AccountId__c.isAccessible()){
            userToProcess = [SELECT Id, Profile.UserLicense.Name, Contact.Account.Name, Contact.XC_TypeOfContact__c,
                                        UserRole.Name, AccountId, XC_AccountId__c
                                        FROM User WHERE Id IN: userIds 
                                        AND Profile.UserLicense.Name =: Label.XC_CL_PartnerCommunity];
        }
        return userToProcess;
    }
}
/**
 * @description DAO Class for XC_TR_User_U_CopyChannelForPartner.
 */
public without sharing class XC_TR_User_U_CopyChannelForPartner_D {
    /**
    * @description query on Users
    * @param userIds the id of users
    * @return users list of users    
    */
    public static List<User> getUsers(List<Id> userIds){
        List<User> users = new List<User>();
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.XC_Receiving_Channel__c.isAccessible() && Schema.sObjectType.User.fields.AccountId.isAccessible()){
            users = [SELECT Id, XC_Receiving_Channel__c, AccountId FROM User WHERE Id IN :userIds AND AccountId != null ];
        }
        return users;
    }
    /**
    * @description query on Account
    * @param accIds the id of accounts
    * @return accs list of accounts
    */
    public static List<Account> getAccounts(Set<Id> accIds){
        List<Account> accs = new List<Account>();
        if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.XC_ReceivingChannel__c.isAccessible()){
            accs = [SELECT Id, XC_ReceivingChannel__c FROM Account WHERE id IN :accIds  AND XC_ReceivingChannel__c != null ];
        }
        return accs;
    }  
}
/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 24/01/2019
* @date Modification 
* @description XC_TR_Account_U_CopyChannelOnUsers - Class to update the channel on all users under a partner account 
*/
   public without sharing class XC_TR_Account_U_CopyChannelOnUsers {

    /**
     * @description The Class AccountMapsWrapper.
     */
    public class AccountMapsWrapper{
        public Map<Id, List<User>> mapAccountListUser;
        public Map<Id,Account> mapAccount;
    }

    /**
     * Populate channel on users.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @description Method to launch the final method from the trigger input
     */       
     public static void populateChannelOnUsers(List<Account> listNew, Map<Id,Account> mapOld, Map<Id,Account> mapNew){
        
        AccountMapsWrapper amw = getUsersOnAccountPartner(listNew,mapOld,mapNew);
        if(!amw.mapAccountListUser.isEmpty() && !amw.mapAccount.isEmpty()){ 
            populateChannelFields(amw); 
        }  
        
    } 
    
    /**
     * Gets the users on account partner.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @return the users on account partner
     * @description Method to return a Map<Account, List<User>> when the field XC_ReceivingChannel__c on the Account changed and
     *                     the record type of the Account is Partner.
     */  
     public static AccountMapsWrapper getUsersOnAccountPartner(List<Account> listNew, Map<Id,Account> mapOld, Map<Id,Account> mapNew){
        
        AccountMapsWrapper amw = new AccountMapsWrapper();
        Map<Id, List<User>> mapAccountIdUsers = new Map<Id, List<User>>();
        List<String> fieldList = new List<String>{'XC_ReceivingChannel__c'};
        List<Account> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        Map<Id, Account> accountMap = new Map<Id, Account> ();
        if(!listChanged.isEmpty() && Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.User.isAccessible()){
            List<Id> listAccountIds = XC_UTIL_Sobject.getIds(listChanged);
            accountMap  = new Map<Id, Account>([
                SELECT Id, recordtype.developername,XC_ReceivingChannel__c, 
                (SELECT Id, XC_Receiving_Channel__c FROM Users) 
                FROM Account 
                WHERE Id IN: listAccountIds AND Recordtype.Developername =: Label.XC_CL_Account_Partner
            ]);
        }
        if(!accountMap.isEmpty()){ 
            for(Id accId : accountMap.keyset()){
                mapAccountIdUsers.put(accId, accountMap.get(accId).Users);
            }
        }
        amw.mapAccountListUser = mapAccountIdUsers;
        amw.mapAccount = accountMap;

        return amw;
        
    } 
    
    /**
     * Populate channel fields.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param accountMapWrapper the account map wrapper
     * @description Method to populate the field XC_Receiving_Channel__c on the users based on the related account partner
     */  
     public static void populateChannelFields(AccountMapsWrapper accountMapWrapper){
        
        List<User> userListToUpdate = new List<User>();
        for(Id accountId : accountMapWrapper.mapAccountListUser.keyset()){
            for(User userToModify:accountMapWrapper.mapAccountListUser.get(accountId)){
                userToModify.XC_Receiving_Channel__c = accountMapWrapper.mapAccount.get(accountId).XC_ReceivingChannel__c;
                userListToUpdate.add(userToModify);
            }
        }
       XC_UTIL_Sobject.updateListRecords(userListToUpdate);     
    } 
}
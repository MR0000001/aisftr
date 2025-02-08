/**
 * @description The Class XC_TR_User_U_CopyChannelForPartner.
 */
public class XC_TR_User_U_CopyChannelForPartner {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_User_U_AssignPartnerRole');
    
    /** The run. */
    private static boolean run = true;
    
    /**
     * @description Run once.
     * @return true, if successful
     */
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        } else{
            return run;
        }
    }

    /**
     * @description Rebalt channel.
     * @param listNew the list new
     */
    public static void rebaltChannel(List<User> listNew) {

		if(runOnce()) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'userToUpdate'+ listNew);
            List<User> userToUpdate = new  List<User>();
            List<Id> userIds = XC_UTIL_Sobject.getIds(listNew);
            List<User> users = XC_TR_User_U_CopyChannelForPartner_D.getUsers(userIds);
            Map<Id,User> accountIdUser = new  Map<Id,User>();

            for(User u : users) {
                accountIdUser.put(u.AccountId, u );
            }	
            Set<Id> accIds = accountIdUser.keySet();
            List<Account> accs = XC_TR_User_U_CopyChannelForPartner_D.getAccounts(accIds);
            for(Account a : accs) {
                User us = accountIdUser.get(a.id);
                us.XC_Receiving_Channel__c = a.XC_ReceivingChannel__c;
                userToUpdate.add(us);
            } 
    
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'userToUpdate'+ userToUpdate);
            XC_UTIL_Sobject.updateListRecords(userToUpdate);
        }
    }
    
}
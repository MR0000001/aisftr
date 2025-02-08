/**
 * The Class XC_TR_User_U_CheckPartnerRole.
 * @author Giulio Serra giserra@deloitte.it
 * @date Creation 22/10/2018
 * @date Modification dd/mm/yyyy
 * @description check if the user partner role is changed
 */ 

public without sharing class XC_TR_User_U_CheckPartnerRole {

    /**
     * Check partner role changed.
     * @author Giulio Serra giserra@deloitte.it
     * @param userChanged the user changed
     * @param userOldValues the user old values
     * @param userNewValues the user new values
     * @date Creation 23/10/2018
     * @description check if the user partner role is changed
     */ 
    public static void checkPartnerRoleChanged(List<User> userChanged,Map<Id,User> userOldValues,Map<Id,User> userNewValues){

        List<String> fieldList = new List<String>{'UserRoleId'};
        List<User> changedUser = XC_UTIL_SObject.getListChanged(fieldList, userOldValues,userNewValues);     
        System.debug('changedUser-> ' + changedUser);

        List<ID> listIdChanged = XC_UTIL_SObject.getIds(changedUser);
        Map<Id,User> changed = new Map<Id,User>([SELECT Id,Profile.Name, Profile.Id,Profile.UserLicense.Name  
                                                FROM User 
                                                WHERE Id IN :listIdChanged]);


        if(changed.isEmpty()){
            return;
        }

        for(User currentUser : changedUser){ 
            User userFromQuery = changed.get(currentUser.Id); 
            if(userFromQuery != null){
                System.debug(userFromQuery.Profile);
                System.debug('current user status' + userFromQuery.Profile.UserLicense.Name);

                 if(userFromQuery.Profile.UserLicense.Name == Label.XC_CL_PartnerCommunity && !canUserChangeStatus(currentUser,userOldValues)){ 
                    currentUser.addError(Label.XC_CL_User_RoleChangeError);
                }
            }
        } 
    } 

      /**
       * Can user change status.
       * @author Giulio Serra giserra@deloitte.it
       * @param u the u
       * @param userOldVal the user old val
       * @return true, if successful
       * @date Creation 23/10/2018
       * @description check if the user's status change is from trigger
       */ 
    @TestVisible
    private static boolean canUserChangeStatus(User u,Map<Id,User> userOldVal){ 
        User oldValue = userOldVal.get(u.ID);
        return oldValue != null && u.XC_HasRoleBeenProcessed__c && oldValue.XC_HasRoleBeenProcessed__c == false; 
    }
}
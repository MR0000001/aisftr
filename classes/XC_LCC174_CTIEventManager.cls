/**
* @author Monica Cutillo - mcutillo@deloitte.it && Simone Trenta - strenta@deloitte.it
* @date Creation 02/12/2020
* @date Modification dd/mm/yyyy
* @description XC_AMP_UTIL_ViewConfiguration – Util class with method for view configuration
*/ 
public without sharing  class XC_LCC174_CTIEventManager {

    /**
    * @description checkCTIUserEnabled
    * @return true if the User is enabled, false otherwise
    **/
    @AuraEnabled
    public static Boolean checkCTIUserEnabled(){

        String currentUserId = UserInfo.getUserId();

        User currentUserInfo = [
            SELECT Id, CallCenterId
              FROM User 
             WHERE Id =: currentUserId];

        return String.isNotBlank(currentUserInfo.CallCenterId);
    }
}
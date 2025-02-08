/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 31/07/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_RFID_Card_U_PopulateField – Class to populate XC_RFID_Card__c
*/

public without sharing class XC_TR_RFID_Card_U_PopulateField {

    /**
    * @author Dario Tramontin - dtramontin@deloitte.it 
 	* @description Method to populate XC_RFID_Card__c
    * @param listNew - List<XC_RFID_Card__c>  
    */
    public static void manageInsertRFID(List<XC_RFID_Card__c> listNew ){
        Map<Id,User> mapUser = new Map<Id,User>([Select Id, XC_LegalEntity__c FROM User where id= :UserInfo.getUserId()]);
        User runningUser;
        Boolean userRetrieved = false;
        if(!mapUser.values().isEmpty() ){
            runningUser = mapUser.values()[0];
            userRetrieved = true;
        }

        for(XC_RFID_Card__c r : listNew ){
            if(String.isBlank(r.XC_LegalEntity__c) && userRetrieved) {
                r.XC_LegalEntity__c = runningUser.XC_LegalEntity__c;
            }
        }
    }

}
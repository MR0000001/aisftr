/**
* @author Simone Trenta - stenta@deloitte.it
* @date Creation 12/04/2019
* @date Modification 
* @description Class with methods to delete children of deleted accounts
*/

public without sharing class XC_TR_Account_U_DeleteChildren {

    /**
     * @author Simone Trenta - stenta@deloitte.it
     * @description Method to be executed on after delete, delete personal documents of deleted account
     * @param mapOld - map Id -> old value of record
    */
    public static void deletePersonalDocument(Map<id,Account> mapOld){
        if(Schema.sObjectType.XC_PersonalDocument__c.isAccessible()){
            List<XC_PersonalDocument__c> docs = [SELECT id from XC_PersonalDocument__c where XC_Account__c in: mapOld.keySet()];
            XC_UTIL_Sobject.deleteListRecords(docs);
        }  
    } 

}
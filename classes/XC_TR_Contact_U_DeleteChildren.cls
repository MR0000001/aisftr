/**
* @author Simone Trenta - stenta@deloitte.it
* @date Creation 12/04/2019
* @date Modification 
* @description Class with methods to delete children of deleted leads
*/

public with sharing class XC_TR_Contact_U_DeleteChildren {
	public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contact_U_DeleteChildren');
    /**
     * @author Simone Trenta - stenta@deloitte.it
     * @description Method to be executed on after delete, delete personal documents of deleted lead
     * @param mapOld - map Id -> old value of record
    */
    public static void deletePersonalDocument(Map<id,Contact> mapOld){

        if(!Schema.sObjectType.XC_PersonalDocument__c.isAccessible()){  return; }
		List<XC_PersonalDocument__c> docs = [SELECT id from XC_PersonalDocument__c where XC_Contact__c in: mapOld.keySet()];
        XC_UTIL_Sobject.deleteListRecords(docs);  
    } 


}
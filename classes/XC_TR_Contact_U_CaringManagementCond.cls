/**
 * The Class XC_TR_Contact_U_CaringManagementCond.
 *
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @date Creation 18/04/2019
 * @date Modification 23/04/2019  Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
 * @description XC_TR_Contact_U_CaringManagementCond – Class that manages case caring conditions
 */
public without sharing class XC_TR_Contact_U_CaringManagementCond {

    /**
     * @description Check this condition.
     * @param newCase a newCase
     * @param caseObj a caseObj
     * @param settingsWithAuth a settingsWithAuth
     * @return boolean
     */
     public static boolean checkCond1(Case newCase, Case caseObj, XC_CM_Case_Type_Setting__mdt settingsWithAuth){
        if(    newCase.RecordTypeId==caseObj.RecordTypeId && 
               newCase.Reason==caseObj.Reason &&
               newCase.Subcause__c==caseObj.Subcause__c &&
               newCase.ContactId==caseObj.ContactId &&
               (settingsWithAuth.XC_Sub_Type__c == null || newCase.XC_Subtype__c==caseObj.XC_Subtype__c ) ){
            return true;
        }
        return false;
    }


    /**
     * @description Check this condition.
     * @param newContact a newContact
     * @param oldContact a oldContact
     
     * @return boolean
     */
     public static boolean checkCond2(Contact newContact, Contact oldContact){
        Id recordTypeCustomer = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId();
        if(newContact.RecordTypeId != recordTypeCustomer && (newContact.LastName != oldContact.LastName
                                                                || newContact.FirstName != oldContact.FirstName
                                                                || newContact.Phone != oldContact.Phone
                                                                || newContact.XC_Preferredlanguageofcontact__c != oldContact.XC_Preferredlanguageofcontact__c
                                                                || newContact.XC_Nationality__c != oldContact.XC_Nationality__c
                                                                || newContact.MobilePhone != oldContact.MobilePhone
                                                                || newContact.XC_HourToBeRecontacted__c != oldContact.XC_HourToBeRecontacted__c 
                                                                || newContact.Email != oldContact.Email) ){
            return true;
        }
        return false;
    }


    /**
     * @description Check this condition.
     * @param newContact a newContact
     * @param oldContact a oldContact
     * @return boolean
     */
     public static boolean checkCond3(Contact newContact,Contact oldContact){
       
        if(newContact.Phone != oldContact.Phone
                       || newContact.MobilePhone != oldContact.MobilePhone
                       || newContact.XC_Nationality__c != oldContact.XC_Nationality__c
                       || newContact.XC_Preferredlanguageofcontact__c != oldContact.XC_Preferredlanguageofcontact__c ){
            return true;
        }
        return false;
    }


    /**
     * @description Check this condition.
     * @param contactId the Contact Id
     * @param caseObj a caseObj
     * @param settingsWithAuth a settingsWithAuth
     * @return boolean
     */
    public static boolean checkCond4(String contactId, Case caseObj, XC_CM_Case_Type_Setting__mdt settingsWithAuth){
        if( caseObj.Reason == settingsWithAuth.XC_Case_Reason__c &&
            caseObj.Subcause__c==settingsWithAuth.XC_Sub_cause__c &&
            caseObj.XC_Subtype__c == settingsWithAuth.XC_Sub_type__c &&
            caseObj.ContactId == contactId) {
                return true;
        }

        return false;
    }
    /**
     *  @author Nicola Arrigo - narrigo@deloitte.it
     * @description checkCond5.
     * @param newContact contact
     * @param oldContact contact
     * @return Map<string,boolean>
     */

    public static Map<string,boolean> checkCond5(contact newContact, contact oldContact){
       system.debug('enter in checkCond5 method');
        Map<string,boolean> newMap= new Map<string,boolean>();
        if(newContact.LastName != oldContact.LastName
           || newContact.FirstName != oldContact.FirstName
           || newContact.Email != oldContact.Email){
            newMap.put(newContact.id,true);  
           }else{
             newMap.put(newContact.id,false);
           }
           system.debug('map'+' '+newMap); 
           return newMap;
     }
  
 


    /**
     * @description Check this condition.
     * @param newContact a newContact
     * @param oldContact a oldContact
     * @return boolean
     */
    public static boolean checkCondZuora(Contact newContact, Contact oldContact) {
        Id recordTypeCustomer = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId();
        if(newContact.RecordTypeId != recordTypeCustomer && (newContact.LastName != oldContact.LastName
                                                                || newContact.FirstName != oldContact.FirstName
                                                                || newContact.Phone != oldContact.Phone
                                                                //|| newContact.XC_Preferredlanguageofcontact__c != oldContact.XC_Preferredlanguageofcontact__c
                                                                || newContact.MobilePhone != oldContact.MobilePhone
                                                                || newContact.Email != oldContact.Email) ){
            return true;
        }
        return false;
    }
}
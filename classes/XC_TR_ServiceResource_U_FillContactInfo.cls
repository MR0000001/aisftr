/**
* @author Federica Tavera - federica.tavera@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 05/03/2019
* @date Modification 03/09/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Copies the user information about contact and account in the ServiceResource 
*/

public without sharing class XC_TR_ServiceResource_U_FillContactInfo {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceResource_U_FillContactInfo');
    /**
     * @description Fill contact info method
     * @param resList - List<ServiceResource>
     */
    public static void fillContactInfoMethod(List<ServiceResource> resList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '*** ENTER IN XC_TR_ServiceResource_U_FillContactInfo ***');
        List<String> listUserId = XC_UTIL_SObject.getListFieldValues(resList, 'RelatedRecordId');      
        Map<Id, User> mapUser = new Map<Id, User>([ 
            SELECT Id, AccountId, ContactId, Contact.XC_ContactDocumentType__c, Contact.XC_ContactDocumentNumber__c, Account.XC_CommercialCode__c, Account.XC_InternalCommercialCode__c, XC_LegalEntity__c
            FROM User 
            WHERE Id IN: listUserId 
        ]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '*** mapUser-->' + mapUser);
        for(ServiceResource sr : resList){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '*** service resource-->' + sr);
            if(mapUser.containsKey(sr.RelatedRecordId)){
                User usr = mapUser.get(sr.RelatedRecordId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '*** user-->' + usr);
                sr.XC_RelatedUser__c = !String.isBlank(sr.XC_RelatedUser__c) ? sr.XC_RelatedUser__c : usr.Id;
                sr.XC_LegalEntity__c = !String.isBlank(sr.XC_LegalEntity__c) ? sr.XC_LegalEntity__c : usr.XC_LegalEntity__c;
                sr.XC_Account__c = !String.isBlank(sr.XC_Account__c) ? sr.XC_Account__c : usr.AccountId;
                sr.XC_Contact__c = !String.isBlank(sr.XC_Contact__c) ? sr.XC_Contact__c :  usr.ContactId;
                if(usr.AccountId != null && usr.ContactId != null){
                    sr.XC_PartnerCommercialCode__c = !String.isBlank(sr.XC_PartnerCommercialCode__c) ? sr.XC_PartnerCommercialCode__c : usr.Account.XC_CommercialCode__c;
                    sr.XC_InternalCommercialCode__c = !String.isBlank(sr.XC_InternalCommercialCode__c) ? sr.XC_InternalCommercialCode__c : usr.Account.XC_InternalCommercialCode__c;
                    sr.XC_DocumentId__c = !String.isBlank(sr.XC_DocumentId__c) ?  sr.XC_DocumentId__c : usr.Contact.XC_ContactDocumentNumber__c;
                    sr.XC_DocumentType__c = !String.isBlank(sr.XC_DocumentType__c) ? sr.XC_DocumentType__c : usr.Contact.XC_ContactDocumentType__c; 
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '*** END XC_TR_ServiceResource_U_FillContactInfo ***');
            }
            
        }
    }

    /**
     * @description Fill fields for Servise Resource
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 03/09/2019
     * @param listNew - List<ServiceResource>
     */
    /*public static void populateFields(List<ServiceResource> listNew) {
        List<User> listUser = new List<User>([
            SELECT Id, XC_LegalEntity__c 
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ]);
        for(ServiceResource sr : listNew) {
            sr.XC_LegalEntity__c = listUser[0].XC_LegalEntity__c;
        }
    }*/

}
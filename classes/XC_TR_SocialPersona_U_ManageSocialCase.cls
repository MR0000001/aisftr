/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/01/2020
* @description XC_TR_SocialPersona_U_ManageSocialCase – Util Class to manage Social Cases
*/

public without sharing class XC_TR_SocialPersona_U_ManageSocialCase {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_SocialPersona_U_ManageSocialCase');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 28/01/2020
    * @description Method to manage social cases on update
    * @param listNew - List<SocialPersona>
    * @param mapOld - Map<Id, SocialPersona> 
    * @param mapNew - Map<Id, SocialPersona> 
    */
    public static void manageSocialCaseOnUpdate(List<SocialPersona> listNew, Map<Id, SocialPersona> mapOld, Map<Id, SocialPersona> mapNew) {
        List<SocialPersona> listSpChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_ContactId__c'}, mapOld, mapNew);
        if(listSpChanged.isEmpty()) {
            return;
        }

        Map<String, String> mapIdsPersonaIdContactId = new Map<String, String>();
        List<SocialPersona> listSpChangedWithContact = new List<SocialPersona>();
        for(SocialPersona sp : listSpChanged) {
            if(String.isBlank(mapOld.get(sp.Id).XC_ContactId__c) && String.isNotBlank(mapNew.get(sp.Id).XC_ContactId__c)) {
                mapIdsPersonaIdContactId.put(sp.Id, sp.XC_ContactId__c);
                listSpChangedWithContact.add(sp);
            }
        }
        if(listSpChangedWithContact.isEmpty()) {
            return;
        }

        List<SocialPost> listFilteredSocialPost = filterSocialCases(listSpChangedWithContact);
        if(listFilteredSocialPost.isEmpty()) {
            return;
        }
        updateSocialCases(listFilteredSocialPost, listSpChangedWithContact, mapIdsPersonaIdContactId);
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 28/01/2020
    * @description Method to filter Social Cases
    * @param listSpChangedWithContact - List<SocialPost>
    * @return List<SocialPost>
    */
    private static List<SocialPost> filterSocialCases(List<SocialPersona> listSpChangedWithContact) {
        List<SocialPost> listFilteredSocialPost = new List<SocialPost>();
        List<SocialPost> listSocialPost = new List<SocialPost>([
            SELECT Id, ParentId, PersonaId, Persona.XC_ContactId__r.AccountId
            FROM SocialPost
            WHERE PersonaId = :listSpChangedWithContact AND Persona.XC_ContactId__c != null
        ]);
        if(listSocialPost.isEmpty()) {
            return listFilteredSocialPost;
        }
        List<String> listCaseIds = XC_UTIL_Sobject.getListFieldValues(listSocialPost, 'ParentId');
        List<String> listStatusClosedCase = new List<String>{Label.XC_CL_Case_Status007, Label.XC_CL_Case_Status007};
        List<Case> listCases = new List<Case>([
            SELECT Id, ContactId
            FROM Case
            WHERE Id IN :listCaseIds AND (ContactId = null OR ContactId = '') AND Status NOT IN :listStatusClosedCase
        ]);
        if(listCases.isEmpty()) {
            return listFilteredSocialPost;
        }
        List<Id> listCaseIdsOk = XC_UTIL_Sobject.getIds(listCases);
        for(SocialPersona sp : listSpChangedWithContact) {
            for(SocialPost sPost : listSocialPost) {
                if(listCaseIdsOk.contains(sPost.ParentId)) {
                    listFilteredSocialPost.add(sPost);
                    break;
                }
            }
        }    
        return listFilteredSocialPost;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 28/01/2020
    * @description Method to update Social Cases
    * @param listSocialPost - List<SocialPost>
    * @param listSpChanged - List<SocialPersona> 
    * @param mapIdsPersonaIdContactId - Map<String, String> 
    */
    private static void updateSocialCases(List<SocialPost> listSocialPost, List<SocialPersona> listSpChanged, Map<String, String> mapIdsPersonaIdContactId) {
        List<Case> listCaseToUpdate = new List<Case>();
        for(SocialPost socialP : listSocialPost) {
            if(String.isNotBlank(socialP.ParentId)) {
                Case caseToUpdate = new Case(
                    Id = socialP.ParentId,
                    ContactId = mapIdsPersonaIdContactId.get(socialP.PersonaId),
                    AccountId = socialP.Persona.XC_ContactId__r.AccountId
                );
                listCaseToUpdate.add(caseToUpdate);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> wrCase = XC_UTIL_Sobject.updateListRecords(listCaseToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(wrCase)) { 
            listSpChanged[0].addError(wrCase[0].errorMessage);
        }  
    }
	


}
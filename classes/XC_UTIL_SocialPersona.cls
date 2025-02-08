/**
*@author Federico Amici - federico.amici@nttdata.com 
*@date Creation 18/04/2019  
*@date Modification dd/mm/yyyy
*@description XC_UTIL_SocialPersona util for SocialPersona
*/
public with sharing class XC_UTIL_SocialPersona {
    
    /**
    *@author Federico Amici - federico.amici@nttdata.com 
    *@date Creation 18/04/2019   
    *@date Modification dd/mm/yyyy
    *@param persona param
    *@description createPersona util for SocialPersona
    */
    public static void createPersona(SocialPersona persona) {
        System.debug('@@inside create persona!!!: '+persona);
        SocialPost sp = new SocialPost();
        List<SocialPost> spList = new Map<Id, SocialPost>([SELECT ID FROM SocialPost Limit 1]).values();
        if(!spList.isEmpty()){
            sp = spList[0];
        }
        Boolean cond1 = (persona == null);
        Boolean cond2 = (String.isNotBlank(persona.Id));
        Boolean cond3 = isThereEnoughInformationToCreatePersona(persona);

        if (cond1 || cond2 || !cond3) {
             return; 
        }

        System.debug('@@passed the first IF: '+persona);
        //[IN] 07112018 START COMMENT
        //SObject parent = createPersonaParent(persona);
        persona.ParentId = sp.id;//[IN] 07112018 added socialPost id as parent
        System.debug('@@Persona after parentId: '+persona);
        //[IN] 07112018 END COMMENT
        XC_UTIL_SObject.insertRecord(persona);
        System.debug('@@Persona after insert: '+persona);
    }

    @TestVisible
    /**
    *@author Federico Amici - federico.amici@nttdata.com 
    *@date Creation 18/04/2019  
    *@date Modification dd/mm/yyyy
    *@param persona param
    *@description isThereEnoughInformationToCreatePersona 
    *@return boolean
    */
    private static boolean isThereEnoughInformationToCreatePersona(SocialPersona persona) {
        return String.isNotBlank(persona.Name) && 
            String.isNotBlank(persona.Provider) && 
            String.isNotBlank(persona.MediaProvider);
    }

    /**
     *@description 
     *@param persona
     *@return SocialPersona
     */
    public static SocialPersona buildPersona(SocialPersona persona) {
        System.debug('@@persona: '+persona);
        if (persona.Id == null){
            XC_UTIL_SocialPersona.createPersona(persona);
        } else {
            XC_UTIL_Sobject.updateRecord(persona);
        }
        
        return persona;
    }

        /**
     *@description 
     *@param persona
     */
    public static void matchPersona(SocialPersona persona) {
        
        if (persona == null) {
            return;
        }

        List<SocialPersona> personaList = new List<SocialPersona>();
        if (persona.Provider != 'Other') {
            personaList = retrieveSocialPersona(persona);
        }

        if(String.isNotBlank(persona.MediaProvider) && persona.Provider == 'Other') {
            if(String.isNotBlank(persona.ExternalId)) {
                personaList = new Map<Id, SocialPersona>([SELECT Id, ParentId, XC_ContactId__c FROM SocialPersona WHERE
                               MediaProvider = :persona.MediaProvider AND
                               ExternalId = :persona.ExternalId LIMIT 1]).values();
            } else if(String.isNotBlank(persona.Name)) {
                personaList = new Map<Id, SocialPersona>([SELECT Id, ParentId, XC_ContactId__c FROM SocialPersona WHERE
                               MediaProvider = :persona.MediaProvider AND
                               Name = :persona.Name LIMIT 1]).values();
            }
        } 
        
        if (!personaList.isEmpty()) {
            persona.Id = personaList[0].Id;
            persona.ParentId = personaList[0].ParentId;
            persona.XC_ContactId__c = personaList[0].XC_ContactId__c;
        }
    
    }

    private static List<SocialPersona> retrieveSocialPersona(SocialPersona persona) {

        List<SocialPersona> personaList;

        if (String.isNotBlank(persona.ExternalId)) {
            personaList = new Map<Id, SocialPersona>([SELECT Id, ParentId, XC_ContactId__c FROM SocialPersona WHERE
                               Provider = :persona.Provider AND
                               ExternalId = :persona.ExternalId LIMIT 1]).values();
        } else if (String.isNotBlank(persona.Name)) {
            //this is a best-effort attempt to match: persona.Name is not guaranteed to be unique for all networks
            personaList = new Map<Id, SocialPersona>([SELECT Id, ParentId, XC_ContactId__c FROM SocialPersona WHERE
                           Provider = :persona.Provider AND
                           Name = :persona.Name LIMIT 1]).values();
        }

        return personaList;
    }
    
}
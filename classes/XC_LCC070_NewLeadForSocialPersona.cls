/**
 * @description The Class XC_LCC070_NewLeadForSocialPersona.
 */
public without sharing class XC_LCC070_NewLeadForSocialPersona {
    /**
     * @description Check lead lookup.
     *
     * @param recordId the record id
     * @return the boolean
     */
    @AuraEnabled
    public static Boolean checkLeadLookup (String recordId){
        System.debug('entrato in checkLeadLookup con id= '+recordId);
        Boolean res = true;
        Map<Id,SocialPersona> socialsMap = new Map<Id,SocialPersona>([SELECT Id, XC_LeadId__c 
            FROM SocialPersona WHERE Id=:recordId]);
        List<SocialPersona> socials = socialsMap.values();


        if(socials[0].XC_LeadId__c != null){
            res=false;
        }
        System.debug('can create: '+res);
        return res;
    }
}
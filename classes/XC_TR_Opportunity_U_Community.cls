/**
 * @author Andrea Di Cicco
 * @date Creation 16/07/2020
 * @description class used to implement the community automation about opportunity
**/

public without sharing class XC_TR_Opportunity_U_Community {

    /**
     * @author Andrea Di Cicco
     * @date Creation 16/07/2020
     * @description when an opportunity is created, populate fields
     * @param listNew List<Opportunity>
    */
    public static void populatePartnerFields(List<Opportunity> listNew){
        String userId = UserInfo.getUserId();
        List<User> sessionUser = new List<User>();
        List<Opportunity> partnerOpportunity = new List<Opportunity>();

        for(Opportunity opp : listNew){
            if(opp.XC_Segment__c == 'B2B' || opp.XC_Segment__c == 'B2G'){
                partnerOpportunity.add(opp);
            }
        }

        if(partnerOpportunity.isEmpty()){
            return;
        }

        if(Schema.sObjectType.User.isAccessible()){
            sessionUser = [Select ContactId, Contact.AccountId, Contact.Account.XC_PartnerLevel__c from User where ContactId != null and Contact.AccountId != null and id =: userId ];
        }

        if(sessionUser == null || sessionUser.isEmpty()){
            return;
        }
        
        for(Opportunity opp : partnerOpportunity ){  
            opp.XC_PartnerLevel__c = sessionUser.get(0).Contact.Account.XC_PartnerLevel__c;
        }

    }


}
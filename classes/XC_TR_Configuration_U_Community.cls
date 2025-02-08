/**
 * @author Andrea Di Cicco
 * @date Creation 16/07/2020
 * @description class used to implement the community automation about configuration
**/
public without sharing class XC_TR_Configuration_U_Community {
        /**
     * @author Andrea Di Cicco
     * @date Creation 16/07/2020
     * @description when an opportunity is created, populate fields
     * @param listNew List<Opportunity>
    */
    public static void setPartnerAccount(List<NE__Order__c> listNew){
        String userId = UserInfo.getUserId();
        List<User> sessionUser = new List<User>();
        /*List<NE__Order__c> communityOrder = new List<NE__Order__c>();

        for(NE__Order__c ord : listNew){
            if(ord.XC_Segment__c == 'B2B' || ord.XC_Segment__c == 'B2G' ){
                communityOrder.add(ord);
            } 
        }

        if(communityOrder.isEmpty()){ 
            return;
        }*/

        if(Schema.sObjectType.User.isAccessible()){
            sessionUser = [Select ContactId, Contact.AccountId, Contact.Account.XC_Account__c, Contact.Account.XC_BillToPartner__c from User where ContactId != null and Contact.AccountId != null and id =: userId];
        }
 
        if(sessionUser == null || sessionUser.isEmpty()){
            return;
        }
        
        for(NE__Order__c ord : listNew ){  
            if(sessionUser.get(0).Contact.Account.XC_BillToPartner__c){
                ord.NE__BillAccId__c = sessionUser.get(0).Contact.Account.XC_Account__c;
            }
        }

    }
}
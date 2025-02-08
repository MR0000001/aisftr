public class XC_TR_Opportunity_DealRegistration {
 
    public static void insertDealStatus(List<Opportunity> opp){
        System.debug('@@@ GS ');
       // Set<Id> idOpp= new Set<Id>();

        Map<Id,Account> mapAcc = new Map<Id,Account> ([Select id,OwnerId from Account where Id IN:XC_UTIL_Sobject.getSetIdsOnField(opp, 'AccountId')]);
        Map<Id,User> user = new Map<Id,User>([Select id, Profile.Name from user where id IN:XC_UTIL_Sobject.getSetIdsOnField(opp, 'OwnerId') ]);
        for(Opportunity o: opp){
  
            if(user.get(o.OwnerId).Profile.Name =='XC_B2B_ITA_SalesPartnerManager'){
                System.debug('@@@ GS ' + o.Owner.Profile.Name);
                if(mapAcc.get(o.AccountId).OwnerId == o.OwnerId){
                   
                    o.XC_DealRegistrationStatus__c = 'Not Needed';
                }
                else{
                    o.XC_DealRegistrationStatus__c = 'Approval Needed';
                }
      //          idOpp.add(o.Id);
            }
        }
    }

  
}
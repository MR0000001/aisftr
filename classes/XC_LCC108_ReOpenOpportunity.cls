/**
* @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation  18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC108_ReOpenOpportunity – Controller for XC_LCP108_ReOpenOpportunity
*/


public without sharing class XC_LCC108_ReOpenOpportunity {
    /**
     * @description Method to Re-Open a closed Opportunity .
     *
     * @param recordId - The record Id of the Opportunity
     * @return the insert result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper reOpenOpportunity(String recordId){
        XC_UTIL_ResultWrapper wrW = new XC_UTIL_ResultWrapper ();
        
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id,StageName,XC_ClosureDateTime__c,XC_ClosingUser__r.AccountId, XC_LossReason__c,XC_ClosingUser__c,XC_LossReasonDescription__c
                                                                        FROM Opportunity
                                                                         WHERE Id =:recordId]);
        Opportunity opp = opportunityMap.values();
 
        Map<Id,User> currentUserMap = new Map<Id,User>( [SELECT Id, Profile.Name, Profile.Id,Profile.UserLicense.Name,AccountId  
                                                             FROM User  
                                                              WHERE Id =: UserInfo.getUserId()]);
        User currentUser = currentUserMap.values(); 
        Id rt1 = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Opty').getRecordTypeId();
        Id rt2 = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        String idValue1 = String.valueOf(rt1);
        String idValue2 = String.valueOf(rt2);

        Map<Id, NE__Order__c> configurationMap = new Map<Id, NE__Order__c>([SELECT Id,NE__OptyId__c,RecordTypeId
                                                                            FROM NE__Order__c
                                                                            WHERE (RecordTypeId =: idValue1 OR RecordTypeId =: idValue2)
                                                                                    AND NE__OptyId__c =: opp.Id
                                                                             ]);
        List<NE__Order__c> configurations = configurationMap.values();

         If(opp.StageName != Label.XC_CL_Opportunity_ClosedLost){
             wrW.success = false;
             wrW.resultMessage = Label.XC_CL_Opportunity_ErrorStageName;
             return wrW;
         }
         If (opp.XC_ClosingUser__r.AccountId == currentUser.AccountId){
             opp.StageName = Label.XC_CL_Opportunity_Draft;
             opp.XC_LossReasonDescription__c = '';
             opp.XC_ClosingUser__c = null;
             opp.XC_ClosureDateTime__c = null;
             opp.XC_LossReason__c = '';
         }else{
            wrW.success = false;
            wrW.resultMessage = Label.XC_CL_Opportunity_ErrorUser;
            return wrW;

         }
         If(!configurations.isEmpty()){
             wrW.success = false;
             wrW.resultMessage = Label.XC_CL_Opportunity_ErrorConfig;
             return wrW;

         }
         XC_UTIL_Sobject.WrapperResult wrp = XC_UTIL_Sobject.updateRecord(opp);
             wrW.success = wrp.success;
             wrW.resultMessage = wrp.errorMessage;
         return wrW;
         

    } 
                                            
        
    

}
/**
* @author Federico Melella - fmelella@deloitte.it & Luisana Rocco - lrocco@deloitte.it
* @date Creation 27/08/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_ManageScoring – Class to manage oppportunity scoring
*/ 
public without sharing class XC_TR_Opportunity_U_ManageScoring {
    /**
* @author Federico Melella - fmelella@deloitte.it
* @param oppList a list of opportunities
* @description set scoring on opportunity update to account and opportunity objects
*/
    // in attesa di specifiche
    public static void rebaltScoring(List<Opportunity> oppList){
        
        Map<Id,Map<String,String>> listOfDocuments = checkForDocuments(oppList);
        //List<Account> accListToUpdate = new List<Account>();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        
        for(Opportunity opp: oppList){
            if(!opp.XC_SkipRisk__c){
                if(!String.isBlank(listOfDocuments.get(opp.AccountId).get('IdentityNumber'))
                   || !String.isBlank(listOfDocuments.get(opp.AccountId).get('PrimaryEmail'))){ 
                                                        
                        Map<String,String>  clouderaMap = new Map<String,String>{'opportunity' => JSON.serialize(opp, true),
                                                                               'accountInfo' => JSON.serialize(listOfDocuments, true)
                                                                    };
                        callCloudera(clouderaMap);

                        /*XC_REST_ReadAccont.WrapperResult wrapper = XC_REST_ReadAccont.CallToReadAccountCloudera('Scoring',listOfDocuments.get(opp.AccountId));
                        if(wrapper.Success){
                                opp.XC_Score__c = String.valueOf(wrapper.ReadAccountResponse.Account[0].Scoring.DataLakeScoring);
                                oppListToUpdate.add(opp);
                                Account acc = new Account();
                                acc.XC_Score__c = String.valueOf(wrapper.ReadAccountResponse.Account[0].Scoring.DataLakeScoring);
                                acc.Id = opp.AccountId;
                                accListToUpdate.add(acc);
                            }
                            else{
                                opp.XC_ScoringErrorMessage__c = wrapper.Message;
                                oppListToUpdate.add(opp);
                            }*/
                }
                else {
                    opp.XC_ScoringErrorMessage__c = Label.XC_CL_ScoringErrorMessage_NotCallingCloudera;
                    oppListToUpdate.add(opp);
                }
            }
        }
        
        if(!oppListToUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(oppListToUpdate);
            //XC_UTIL_Sobject.updateListRecords(accListToUpdate);
        }
        
    }



     /**
    * @param clouderaMap - Map<String,String>
    * @description Method to call Cloudea
    */
    @future(callout=true)
    public static void callCloudera(Map<String,String> clouderaMap){
            
        String opportunityTodeserialize = clouderaMap.get('opportunity');
        String accountTodeserialize = clouderaMap.get('accountInfo');

        Opportunity opp = (Opportunity) JSON.deserialize(opportunityTodeserialize, Opportunity.class);
        Map<Id,Map<String,String>> listOfDocuments = (Map<Id,Map<String,String>>) JSON.deserialize(accountTodeserialize, Map<Id,Map<String,String>>.class);

        Account acc;
        Opportunity oppToUpdate = new Opportunity();

        XC_REST_ReadAccont.WrapperResult wrapper = XC_REST_ReadAccont.CallToReadAccountCloudera('Scoring',listOfDocuments.get(opp.AccountId));
        if(wrapper.Success){
            oppToUpdate.Id = opp.Id;
            oppToUpdate.XC_Score__c = String.valueOf(wrapper.ReadAccountResponse.Account[0].Scoring.DataLakeScoring);
            acc = new Account();
            acc.XC_Score__c = String.valueOf(wrapper.ReadAccountResponse.Account[0].Scoring.DataLakeScoring);
            acc.Id = opp.AccountId;
        }
        else{
            oppToUpdate.XC_ScoringErrorMessage__c = wrapper.Message;
        }

        XC_UTIL_Sobject.updateRecord(oppToUpdate);

        if(acc != null){
            XC_UTIL_Sobject.updateRecord(acc);
        }
        
    }
    
    
    /**
    * @param oppList - List<Opportunity>
    * @description Method to retrieve documents or primary email on a list of accounts associated to a list of optys
    */
    private static Map<Id,Map<String,String>> checkForDocuments (List<Opportunity> oppList){
        Map<Id,Map<String,String>> listOfDocuments = new Map<Id,Map<String,String>>();
        List<Id> accountIDs = new List<Id>();
        for(Opportunity o: oppList){
            accountIDs.add(o.AccountId);
        }
        Map<Id,Account> emailAndDocList = new Map<Id,Account>([SELECT RecordType.Name, PrimaryEmail__c, IdentityType__c, IdentityNumber__c, (SELECT XC_Account__c, XC_DocumentNumber__c FROM Personal_Documents__r) FROM Account WHERE Id IN :accountIDs]);
        for(Account a: emailAndDocList.values()){
            Map<String,String> documentToRetrieve = new Map<String,String>();
            if(a.RecordType.Name == 'Soho' && !String.isBlank(a.IdentityNumber__c)){
                documentToRetrieve.put('IdentityNumber', a.IdentityNumber__c);
            }
            else if(a.RecordType.Name == 'Residential' && !a.Personal_Documents__r.isEmpty()){
                documentToRetrieve.put('IdentityNumber', a.Personal_Documents__r[0].XC_DocumentNumber__c);
            }
            else if(!String.isBlank(a.PrimaryEmail__c)) {
                documentToRetrieve.put('PrimaryEmail', a.PrimaryEmail__c);
            }
            listOfDocuments.put(a.Id, documentToRetrieve);
        }
        return listOfDocuments;
    }
    
}
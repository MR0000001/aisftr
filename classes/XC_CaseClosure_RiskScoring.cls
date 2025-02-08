/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 22/06/2020
* @description XC_CaseClosure_RiskScoring 
*/
public with sharing class XC_CaseClosure_RiskScoring {
  /**
      * @author Nicola Arrigo
      * @@date Creation 2/06/2020
      * @description Method to check CreditCheck
      * @param mapNew - Map<Id,Case>
      * @param mapOld - Map<Id,Case>
     **/
     public static void caseClosureRiskScoring(Map<Id,Case> mapNew,Map<Id,Case> mapOld){
      system.debug('caseClosureScoring method'); 
       List<Id> accListIdOk=new List<id>();
       List<Id> accListIdKo=new List<id>(); 
       for(case c:mapNew.values()){
         if( c.Status!=mapOld.get(c.id).Status && 
             c.Status=='ESTA007' &&
             c.Reason=='XCMOT007' &&
             c.SubCause__c=='ATCL157' &&
             c.XC_Subtype__c=='XC191' 
           ){
             if(c.XC_Resolution__c=='R135' &&
                 c.XC_Result__c=='RS003'){
                     system.debug('first if cycle');
                     accListIdOk.add(c.AccountId);
             }else if(c.XC_Resolution__c=='R136' &&
                     c.XC_Result__c=='RS003'){
                     system.debug('second if cycle');  
                     system.debug('Account id'+' '+c.AccountId);   
                     accListIdKo.add(c.AccountId); 
              }       
         }
       }
       string blackList;
       List<Account> accList=new List<Account>();
       if(accListIdOk.size()>0){
         blackList='Customer not present in the blacklist';
        accList=retrieveAcc(accListIdOk);
        updateAcc(accList,blackList);
       }
       if(accListIdKo.size()>0){
         blackList='KO - Customer present in the blacklist';
        accList=retrieveAcc(accListIdko);
        updateAcc(accList,blackList);
       }
     }
 
     private static List<Account>  retrieveAcc(List<Id> accListId){
         List<Account> accList=[select Id, XC_CheckBlacklist__c  from Account
                                where Id IN:accListId];
            system.debug('List Account return'+' '+ accListId);                                                     
            return accList;
                                   
       } 
     
       private static void updateAcc (List<Account>  accList,string blackList){
         for(Account acc:accList){
           acc.XC_CheckBlacklist__c=blackList;
         }
          update accList;
       }
 }
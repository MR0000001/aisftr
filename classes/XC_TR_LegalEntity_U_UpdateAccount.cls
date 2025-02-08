/**
* The Class XC_TR_LegalEntity_U_UpdateAccount.
*
* @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 24/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_LegalEntity_U_UpdateAccount - Update the Account field XC_GiveDataTo from XC_LegalEntityConsents__c
*/
public without sharing class XC_TR_LegalEntity_U_UpdateAccount {
     
    /**
    * Creates the Legal Entity.
    *
    * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
    * @param legalEntityList
    * @date Creation 23/04/19
    * @description create the legal entities
    */   
    public static void updateLegalEntityAccount(List<XC_LegalEntityConsent__c> legalEntityList){ 
        Map<Id, XC_LegalEntityConsent__c> indLegalMap  = new Map<Id, XC_LegalEntityConsent__c> ();
        List<String> individualsId = XC_UTIL_Sobject.getListFieldValues( legalEntityList, 'XC_Individual__c');

        Map<Id, Contact> contacts = new Map<Id, Contact> ([SELECT ID, IndividualId, XC_MainLegalEntity__c, XC_GiveDataToNew__c ,XC_PrimaryContact__c, AccountId
                                                           FROM Contact 
                                                           WHERE IndividualId IN :individualsId AND XC_PrimaryContact__c = true]);
        List<Account> accList = new List<Account>();
        //BEGIN G.S. 10062022 - INC000088324936
        Map<Id,Account> accMap = new Map<Id,Account>();
        //END G.S. 10062022 - INC000088324936
        for(Contact con : contacts.values()){
                for(XC_LegalEntityConsent__c legalEnt : legalEntityList){
                    if(legalEnt.XC_Individual__c == con.IndividualId){
                        Account acc;
						//BEGIN G.S. 10062022 - INC000088324936
                        if(!accMap.containsKey(con.AccountId)){
						//END G.S. 10062022 - INC000088324936
                            acc = new Account(Id = con.AccountId);
						//BEGIN G.S. 10062022 - INC000088324936
                        } else {
                            acc = accMap.get(con.AccountId);
                        }
                        //END G.S. 10062022 - INC000088324936						
						
                        if(legalEnt.XC_GiveDataToNew__c == 'Yes') {
                            String field = 'XC_GiveDataTo_' + legalEnt.XC_LegalEntity__c + '__c';
                            acc.put(field.replaceAll( '\\s+', ''), true);
                        }
						//BEGIN G.S. 10062022 - INC000088324936
                        if(!accMap.containsKey(acc.id)){
                            accMap.put(acc.id,acc);
                        }						
                        //accList.add(acc);
						//END G.S. 10062022 - INC000088324936
                    }
                }
        }
		//BEGIN G.S. 10062022 - INC000088324936
        //XC_UTIL_Sobject.updateListRecords(accList); 		
        if(!accMap.isEmpty()) {
            XC_UTIL_Sobject.updateListRecords(accMap.values()); 
        }
		//END G.S. 10062022 - INC000088324936
        
    }
/**
    * Populate the Legal Entity Individual Id .
    *
    * @author Sara Miozza - sara.miozza@nttdata.com 
    * @param listNew a lis og Legal Entity
    * @date Creation 16/05/2019
    * @description populate the Legal Entity Individual Id
    */   
    public static void populateIndividualId(List<XC_LegalEntityConsent__c> listNew){
        for(XC_LegalEntityConsent__c legalEnt : listNew){
            if(!String.isBlank(legalEnt.XC_Individual__c)){
                legalEnt.XC_IndividualId__c = legalEnt.XC_Individual__c;
            }
        }
    }

    

    
    
}
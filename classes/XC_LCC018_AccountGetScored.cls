/**
 * @description The Class XC_LCC018_AccountGetScored.
 */
public without sharing class XC_LCC018_AccountGetScored {
    
    /**
     * @description Generate scored.
     * @param recordId the record id
     * @return true, if successful
     */
    @AuraEnabled
    public static boolean generateScored(String recordId) {
        List<Account> newAccount = XC_UTIL_Sobject.selectAllFields(recordId);
        String scored;
        String scoredName;
        Integer scoredNumber = 50;
        Double rnd =  Math.random()*10;
		Integer a = (Integer)rnd;
        switch on a {
            when 1,2 {
                scored = 'Pago único';
                scoredName = 'One shot';
            }
            when 3,4 {
                scored = 'Renting a 3 años (36 meses) - 50€';
                scoredName = '3 years renting';
            }
            when 5,6 {
                scored = 'Renting a 5 años (60 meses) - 50€';
                scoredName = '5 years renting';
            }
            when else {
                scored = 'Renting a 7 años (84 meses) - 50€';
                scoredName = '7 years renting';
            }
        }
        newAccount[0].XC_Score__c = scored;
        newAccount[0].XC_Score_Name__c = scoredName;
        newAccount[0].XC_Score_Number__c = scoredNumber;
        try{
            Database.update(newAccount[0]);                    
        } catch(Exception e){ 
           return false;
        } 
        return true;
    }

}
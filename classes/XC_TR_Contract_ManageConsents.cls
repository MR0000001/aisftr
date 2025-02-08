/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 14/04/2020
 * @description XC_TR_Contract_ManageConsents - Class to manage Legal Entity Consent after a contract inserted/updated
 */

public without sharing class XC_TR_Contract_ManageConsents {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contract_ManageConsents');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 14/04/2020
     * @description Method to update Legal Entity Consent
     * @param listNew - List<Contract>
     */
    public static void updateDatesLec(List<Contract> listNew) {
        // Data Preparation:
        List<String> listAccountIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'AccountId');
        List<String> listLegalEntity = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_LegalEntity__c');
        Map<Id, Account> mapAccount = new Map<Id, Account>([
            SELECT Id, 
                (SELECT Id, IndividualId FROM Contacts),
                (SELECT Id, EndDate, XC_LegalEntity__c FROM Contracts WHERE XC_LegalEntity__c IN :listLegalEntity)   
            FROM Account
            WHERE Id IN :listAccountIds
        ]);
        List<String> listIndividualIds = new List<String>();
        for(Account acc : mapAccount.values()) {
            for(Contact cnt : acc.Contacts) {
                listIndividualIds.add(cnt.IndividualId);
            }
        }
        List<Individual> listIndividual = new List<Individual>([
            SELECT Id, 
                (SELECT Id, XC_Individual__c, XC_LegalEntity__c, XC_ExpirationDateProfilingConsent__c, XC_ExpirationDateMarketingConsent__c 
                FROM Legal_Entity_Consents__r),
                (SELECT Id FROM Contacts)
            FROM Individual  
            WHERE Id IN :listIndividualIds
        ]);
        if(listIndividual.isEmpty()) {
            return;
        }
        Map<String, Individual> mapContactIdIndividual = new Map<String, Individual>();
        for(Individual ind : listIndividual) {
            for(Contact cnt : ind.Contacts) {
                mapContactIdIndividual.put(cnt.Id, ind);
            }
        }

        // Check max date for Profiling and Marketing Consents:
        List<XC_LegalEntityConsent__c> listLecToUpdate = new List<XC_LegalEntityConsent__c>();
        for(Contract cntr : listNew) {
            if(mapAccount.get(cntr.AccountId).Contacts.isEmpty() || mapAccount.get(cntr.AccountId).Contracts.isEmpty()) {
                break;
            }
            List<Contact> listContact = mapAccount.get(cntr.AccountId).Contacts;
            List<Contract> listContract = mapAccount.get(cntr.AccountId).Contracts;
            Map<String, Date> mapEndDateContracts = new Map<String, Date>(); 
            for(Contract cntrAcc : listContract) {
                if(mapEndDateContracts.containsKey(cntrAcc.XC_LegalEntity__c)) {
                    if(mapEndDateContracts.get(cntrAcc.XC_LegalEntity__c) < cntrAcc.EndDate) {
                        mapEndDateContracts.put(cntrAcc.XC_LegalEntity__c, cntrAcc.EndDate);
                    }
                } else {
                    mapEndDateContracts.put(cntrAcc.XC_LegalEntity__c, cntrAcc.EndDate);
                }
            }
            for(Contact cnt : listContact) {
                Individual ind = mapContactIdIndividual.get(cnt.Id);
                if(ind == null || ind.Legal_Entity_Consents__r == null){
                    continue;
                }
                for(XC_LegalEntityConsent__c lec : ind.Legal_Entity_Consents__r) {
                    if(!mapEndDateContracts.containsKey(lec.XC_LegalEntity__c)) {
                        break;
                    }
                    Boolean toUpdate = false;
                    XC_LegalEntityConsent__c lecToUpdate = new XC_LegalEntityConsent__c(Id = lec.Id);
                    // For Profiling:
                    toUpdate = checkMaxDate(lec, lecToUpdate, mapEndDateContracts.get(lec.XC_LegalEntity__c), 'XC_ExpirationDateProfilingConsent__c');
                    // For Marketing:
                    toUpdate = checkMaxDate(lec, lecToUpdate, mapEndDateContracts.get(lec.XC_LegalEntity__c), 'XC_ExpirationDateMarketingConsent__c');
                    
                    if(toUpdate) {
                        listLecToUpdate.add(lecToUpdate);
                    }
                }
            }
        }

        // DML Operation:
        List<XC_UTIL_Sobject.WrapperResult> listWrRes = XC_UTIL_Sobject.updateListRecords(listLecToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(listWrRes)) {
            listNew[0].addError(listWrRes[0].errorMessage);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 14/04/2020
     * @description Method to update Legal Entity Consent
     * @param lec - XC_LegalEntityConsent__c
     * @param lecToUpdate - XC_LegalEntityConsent__c
     * @param maxContractEndDate - Date
     * @param fieldToCheck - String
     * @return Boolean
     */
    private static Boolean checkMaxDate(XC_LegalEntityConsent__c lec, XC_LegalEntityConsent__c lecToUpdate, Date maxContractEndDate, String fieldToCheck) {
        Date currentLecDate = (Date) lec.get(fieldToCheck);
        if(currentLecDate < maxContractEndDate) {
            lecToUpdate.put(fieldToCheck, maxContractEndDate);
            return true;
        }
        return false;
    }

}
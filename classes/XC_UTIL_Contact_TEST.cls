/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date 24/05/2019
* @description Test Class for XC_UTIL_Contact
*/

@isTest
private class XC_UTIL_Contact_TEST {
    static testMethod void UtilContactTest(){
        Test.startTest();
        XC_UTIL_Contact.ResultWrapper rW = new XC_UTIL_Contact.ResultWrapper();
        List<Contact> c = XC_DF_Contact.createResidentialContacts(1);
        insert c;
        List<Account> a = XC_DF_Account.createResidentialAccounts(1);
        insert a;
        String accountId = a[0].Id;
        Set<Id> indS = new Set<Id>();
        indS.add(c[0].Id);
        
        List<Contact> getP = XC_UTIL_Contact.getPrimaryContacts(c);
        List<Contact> getPC = XC_UTIL_Contact.getContactsFromaAccountId(accountId,c);
        Map<Id,Contact> getCI = XC_UTIL_Contact.getContactsFromaIndividuals(indS);
        
        System.assert(getP.isEmpty());
        System.assert(getPC.isEmpty());
        System.assert(getCI != null);
        
        Test.stopTest();
    }
    
    static testmethod void getContactLegalEntities(){
        List<Contact> contList = XC_DF_Contact.createCondominiumContacts(1);
        insert contList;
        
        Test.startTest();
        XC_UTIL_Contact.getContactLegalEntities(contList[0].id);
        XC_UTIL_Contact.getLegalEntitiesLabels();
        Test.stopTest();
    } 
}
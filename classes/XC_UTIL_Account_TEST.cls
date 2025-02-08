/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 21/05/2019
* @description Test Class for XC_UTIL_Account
*/
@isTest
private class XC_UTIL_Account_TEST {
    static testMethod void accountTest(){
        Test.startTest();
        //Inner Classes
        XC_UTIL_Account.ResultWrapper rWr = new XC_UTIL_Account.ResultWrapper ();
        XC_UTIL_Account.AccountIFWrapper accIF = new  XC_UTIL_Account.AccountIFWrapper();
        XC_UTIL_Account.IdentityIFWrapper IFWr = new XC_UTIL_Account.IdentityIFWrapper();
        XC_UTIL_Account.ContactIFWrapper CWr = new XC_UTIL_Account.ContactIFWrapper();
        XC_UTIL_Account.gdprWrapper gdpRWr = new XC_UTIL_Account.gdprWrapper();
        XC_UTIL_Account.LegalEntityWrapper LWr = new XC_UTIL_Account.LegalEntityWrapper ();
        XC_UTIL_Account.InteractionWrapper Iwr = new XC_UTIL_Account.InteractionWrapper();
        
        List<Account> inputAccounts = XC_DF_Account.createResidentialAccounts(1);
        insert inputAccounts;
        
        String accountId = inputAccounts[0].Id;
        String RecordTypeIdAcc = inputAccounts[0].RecordTypeId;
		
		insert XC_DF_Opportunity.createOpportunity(1,true);  
        List<Opportunity> o = [SELECT ID,AccountId FROM OPPORTUNITY ];
        
        List<Account> getAll = XC_UTIL_Account.getAllResidentialAccount(inputAccounts);
        List<Map<String,String>> getContacts = XC_UTIL_Account.getContactsOfAccountPicklist(accountId);
        List<Map<String, String>> getDoxee = XC_UTIL_Account.getDoxeeLanguagesPicklist();
        String getRecordType = XC_UTIL_Account.getRecordTypeNameById(accountId);
        Boolean isP = XC_UTIL_Account.isPartner(accountId);
        Boolean isS = XC_UTIL_Account.isSoho(accountId);
        Boolean isC = XC_UTIL_Account.isCondominium(accountId);
        XC_UTIL_Account.isB2B(RecordTypeIdAcc);
        XC_UTIL_Account.isB2G(RecordTypeIdAcc);
        XC_UTIL_Account.isGlobalB2B(RecordTypeIdAcc);
        XC_UTIL_Account.isGlobalB2G(RecordTypeIdAcc);
        XC_UTIL_Account.isSFMAccount(RecordTypeIdAcc);
      
        List<Id> idList = new List<Id>();
        for(Account account: getAll){
            idList.add(account.Id);
        }

        XC_UTIL_Account.getUserIdByAccountId(idList);
        System.assert(!getAll.isEmpty());
        System.assert(getContacts.isEmpty());
        System.assert(!getDoxee.isEmpty());
        System.assertEquals(false,isP);
        System.assertEquals(false,isS);
        System.assertEquals(false,isC);
        System.assert(!String.isBlank(getRecordType));
      
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testTwo() {
        List<Account> inputAccounts = XC_DF_Account.createResidentialAccounts(1);
        insert inputAccounts;
        
        List<Contact> contList=XC_DF_Contact.createResidentialContacts(inputAccounts);
        insert contList;
        Test.startTest();
        	 List<Map<String,String>> getContacts = XC_UTIL_Account.getContactsOfAccountPicklist(inputAccounts[0].Id);
        	XC_UTIL_Account.getContactsOfAccountRelationPicklist(inputAccounts[0].Id);
        Test.stopTest();
    }
    
}
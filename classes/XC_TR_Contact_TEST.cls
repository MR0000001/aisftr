/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 24/06/2019
* @description XC_TR_Contact_TEST – Trigger on Contact
*/ 

@isTest
private class XC_TR_Contact_TEST {
    @isTest
    static void onInsertDeleteUpdateCase() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> listOfContact = XC_DF_Contact.createCondominiumContacts(1);
        insert listOfContact;
        System.assertNotEquals(listOfContact, null);
        listOfContact[0].FirstName='TEST';
        update listOfContact;
        List<Case>listOfCase=[SELECT Id
                                FROM Case
                                WHERE ContactId=:listOfContact[0].Id];
        delete listOfCase;
        delete listOfContact;
         XC_TR_Contact_Handler contactHandler =new XC_TR_Contact_Handler();
         contactHandler.onAfterUnDelete(null);
        Test.stopTest();
    }
    
     @isTest
    static void testCF() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contact> listOfContact = XC_DF_Contact.createCondominiumContacts(1);
        listOfContact[0].XC_ContactDocumentNumber__c = 'abc';
        listOfContact[0].XC_ContactDocumentType__c = 'CF';
        try{
            insert listOfContact;
        } catch(exception e){
            xc_util_debug.debug(true,e+'');
        }
        
        Test.stopTest();
    }

}
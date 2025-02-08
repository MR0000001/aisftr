/**
 * Created by FMARCHEGIA00 on 02/04/2021.
 */

@IsTest
private class TestFlowCitizenAssociationService {

    static testMethod void testBehavior() {

        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        List<Service_Request__c> serviceRequests = TestDataFactory.createServiceRequests(accounts, contacts);

        Case singleCase = new Case();
        singleCase.AccountId = accounts[0].Id;
        singleCase.ContactId = contacts[0].Id;
        singleCase.Anonymous_Contact__c = true;
        singleCase.Service_Request__c = serviceRequests[0].Id;
        singleCase.Origin = 'Email Rigetti 060606';
        insert singleCase;
        List<Case> casesList = new List<Case>();
        casesList.add(singleCase);
        test.startTest();
        FlowCitizenAssociationService.futureUpdateObjectCitizenAssociation(casesList);
        test.stopTest();
    }
}
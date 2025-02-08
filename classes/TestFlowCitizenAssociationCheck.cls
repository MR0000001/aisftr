/**
 * Created by FMARCHEGIA00 on 09/06/2021.
 */

@IsTest
private class TestFlowCitizenAssociationCheck {


    static testMethod void falseTest() {
        List<FlowCitizenAssociationCheck.FlowOutput> outputs = new List<FlowCitizenAssociationCheck.FlowOutput>();
        List<FlowCitizenAssociationCheck.FlowInput> fakeInputs = new List<FlowCitizenAssociationCheck.FlowInput>();
        FlowCitizenAssociationCheck.FlowInput fakeSingleInput = new FlowCitizenAssociationCheck.FlowInput();
        fakeSingleInput.caseId = '5001l0000072qeXXXX';
        fakeSingleInput.serviceRequestId = '5001l0000072qeXXXX';
        fakeInputs.add(fakeSingleInput);
        outputs = FlowCitizenAssociationCheck.checkCase(fakeInputs);
        system.assertEquals(outputs[0].associazione_error, false);

        fakeSingleInput.serviceRequestId = null;
        outputs = FlowCitizenAssociationCheck.checkCase(fakeInputs);
        system.assertEquals(outputs[0].associazione_error, false);
    }

    static testMethod void faseTest_3() {
        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);
        List<Service_Request__c> serviceRequests =  TestDataFactory.createServiceRequests(accounts, contacts);

        List<FlowCitizenAssociationCheck.FlowOutput> outputs = new List<FlowCitizenAssociationCheck.FlowOutput>();
        List<FlowCitizenAssociationCheck.FlowInput> inputs = new List<FlowCitizenAssociationCheck.FlowInput>();
        FlowCitizenAssociationCheck.FlowInput singleInput = new FlowCitizenAssociationCheck.FlowInput();
        TestDataFactory.createCasesWithoutCities();
        List<Case> allCases = [SELECT Id, ParentId, Service_Request__c FROM Case];
        system.debug(' allCases -> '+ allCases);

        allCases[0].AccountId = accounts[0].Id;
        allCases[0].Status = 'New';
        update allCases[0];

        Case tmpCase = [SELECT Id, AccountId, Status, Sub_Status__c, Type FROM Case WHERE Id=: allCases[0].Id];
        system.debug('tmpCase -> '+ tmpCase);

        Case caseOne = new Case();
        caseOne.Type = 'Sollecito';
        caseOne.Status = 'New';
        caseOne.Sub_Status__c  = 'Nuovo';
        caseOne.RecordTypeId = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Reminder' limit 1].Id;
        caseOne.Case_Theme_Area__c = 'sollecito';
        caseOne.Case_Specification__c = 'sollecito';
        caseOne.AccountId = accounts[0].Id;
        caseOne.ReminderCase__c = allCases[0].Id;
        caseOne.ParentId = allCases[0].Id;
        caseOne.Service_Request__c = serviceRequests[0].Id;
        system.debug('caseOne -> '+ caseOne);
        insert caseOne;

        singleInput.caseId = allCases[1].Id;
        singleInput.serviceRequestId = null;
        system.debug('singleInput.serviceRequestId -> '+ singleInput.serviceRequestId);
        inputs.add(singleInput);
        outputs = FlowCitizenAssociationCheck.checkCase(inputs);
        system.assertEquals(outputs[0].associazione_error, false);

        inputs[0].serviceRequestId = caseOne.Service_Request__c;
        outputs = FlowCitizenAssociationCheck.checkCase(inputs);
        system.assertEquals(outputs[0].associazione_error, true);
    }

    static testMethod void trueTest_2() {
        List<FlowCitizenAssociationCheck.FlowOutput> outputs = new List<FlowCitizenAssociationCheck.FlowOutput>();
        TestDataFactory.createCasesWithoutCities();
        List<Case> allCases = [SELECT Id, ParentId, Service_Request__c FROM Case];
        system.debug('allCases -> ' + allCases);
        List<FlowCitizenAssociationCheck.FlowInput> inputs = new List<FlowCitizenAssociationCheck.FlowInput>();
        for ( Case singleCase : allCases ) {
            FlowCitizenAssociationCheck.FlowInput singleInput = new FlowCitizenAssociationCheck.FlowInput();
            singleInput.caseId = singleCase.ParentId;
            singleInput.serviceRequestId = singleCase.ParentId;
            inputs.add(singleInput);
        }
        outputs = FlowCitizenAssociationCheck.checkCase(inputs);
        system.assertEquals(outputs[0].associazione_error, true);

    }

}
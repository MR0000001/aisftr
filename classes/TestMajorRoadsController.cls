/**
 * Created by FMARCHEGIA00 on 07/06/2021.
 */

@IsTest
private class TestMajorRoadsController {

    @isTest
    static void testBehavior() {
        Case newCase0 = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione_KO',
                Case_Theme_Area__c = 'TURISMO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = 'vai Santo Vario',
                Origin = 'CDC');
        insert newCase0;

        MajorRoads__c singleMajorRoads = new MajorRoads__c();
        MajorRoads__c singleMajorRoads2 = new MajorRoads__c();
        List<Id> fixedSearchResults = new List<Id>();
        singleMajorRoads = TestDataFactory.createSingleMajorRoads('via di prova', true);
        fixedSearchResults.add(singleMajorRoads.Id);
        Test.setFixedSearchResults(fixedSearchResults);

    }

    @isTest static void test2() {
        List<Case> cases = new List<Case>();

        Case newCase0 = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione_KO',
                Case_Theme_Area__c = 'TURISMO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = 'vai Santo Vario',
                Origin = 'CDC');
        cases.add(newCase0);

        newCase0 = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione',
                Case_Theme_Area__c = 'TURISMO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = 'via Santissimo SS. Santino',
                Origin = 'CDC');
        cases.add(newCase0);

        Case newCase = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione',
                Case_Theme_Area__c = 'TURISMO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = 'via di prova',
                Origin = 'CDC');
        cases.add(newCase);

        Case newCaseNoMajor = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione',
                Case_Theme_Area__c = 'TURISMO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE_nomajor',
                Street_Address__c = 'via di test',
                Origin = 'CDC');
        cases.add(newCaseNoMajor);

        Case newCaseError = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione_KO',
                Case_Theme_Area__c = 'TURISMO_KO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE_KO',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE_KO',
                Street_Address__c = 'via di prova ma sbagliata',
                Origin = 'CDC');
        cases.add(newCaseError);

        Case newCaseError2 = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione',
                Case_Theme_Area__c = 'TURISMO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = 'SSP13',
                Origin = 'CDC');
        cases.add(newCaseError2);

        Case newCaseError3 = new Case(Subject = 'testo qualsiasi',
                Description = 'testo qualsiasi',
                Status = 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority = 'Medium',
                Type = 'Segnalazione',
                Case_Theme_Area__c = 'TURISMO',
                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = null,
                Origin = 'CDC');
        cases.add(newCaseError3);

        insert cases;

        MajorRoads__c singleMajorRoads2 = TestDataFactory.createSingleMajorRoads('via di prova due', true);
        List<Id> fixedSearchResults = new List<Id>{(singleMajorRoads2.Id)};
        Test.setFixedSearchResults(fixedSearchResults);
    }

    @isTest static void test3() {
        Case newCase2 = new Case(Subject= 'testo qualsiasi',
                Description= 'testo qualsiasi',
                Status= 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority= 'Medium',
                Type= 'Segnalazione',
                Case_Theme_Area__c= 'TURISMO',
                Case_Topic_Service__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = 'via di prova due',
                Origin = 'CDC');
        insert newCase2;

        Case newCaseErrorTryCatch = new Case(Subject= 'testo qualsiasi',
                Description= 'testo qualsiasi',
                Status= 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority= 'Medium',
                Type= 'Segnalazione',
                Case_Theme_Area__c= 'TURISMO',
                Case_Topic_Service__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = '3',
                Origin = 'CDC');
        insert newCaseErrorTryCatch;
    }
}
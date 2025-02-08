/**
 * Created by FMARCHEGIA00 on 02/02/2021.
 */

@IsTest
private class CaseCDCManagerTest {

    @testSetup
    static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    static void testBehavior() {
        TestDataFactory.creteTaxonomyByValues('TURISMO', 'ANTIABUSIVISMO STRUTTURE RICETTIVE', 'ANTIABUSIVISMO STRUTTURE RICETTIVE', true, true, 'A1', true, '1', '14' );
        TestDataFactory.creteTaxonomyByValues('TURISMO', 'ANTIABUSIVISMO STRUTTURE RICETTIVE', 'ANTIABUSIVISMO STRUTTURE RICETTIVE_nomajor', true, true, 'A1', false, '1', '14' );

        Test.startTest();

        MajorRoads__c singleMajorRoads = new MajorRoads__c();
        List<Id> fixedSearchResults= new List<Id>();
        singleMajorRoads = TestDataFactory.createSingleMajorRoads('via di prova', true);
        fixedSearchResults.add(singleMajorRoads.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        List<Case> allCasesToManage = new List<Case>();

        Case newCase = new Case(Subject= 'testo qualsiasi',
                Description= 'testo qualsiasi',
                Status= 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority= 'Medium',
                Type= 'Segnalazione',
                Case_Theme_Area__c= 'TURISMO',
                Case_Topic_Service__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Street_Address__c = 'via di prova',
                Origin = 'CDC');
        insert newCase;
        allCasesToManage.add(newCase);

        Case newCaseNoMajor = new Case(Subject= 'testo qualsiasi',
                Description= 'testo qualsiasi',
                Status= 'In Creazione',
                Sub_Status__c = 'Nuovo',
                Priority= 'Medium',
                Type= 'Segnalazione',
                Case_Theme_Area__c= 'TURISMO',
                Case_Topic_Service__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE',
                Case_Specification__c= 'ANTIABUSIVISMO STRUTTURE RICETTIVE_nomajor',
                Street_Address__c = 'via di test',
                Municipality_Category__c = '1',
                Origin = 'CDC');
        insert newCaseNoMajor;
        allCasesToManage.add(newCaseNoMajor);

//        Case newCaseError = new Case(Subject = 'testo qualsiasi',
//                Description = 'testo qualsiasi',
//                Status = 'In Creazione',
//                Sub_Status__c = 'Nuovo',
//                Priority = 'Medium',
//                Type = 'Segnalazione_KO',
//                Case_Theme_Area__c = 'TURISMO_KO',
//                Case_Topic_Service__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE_KO',
//                Case_Specification__c = 'ANTIABUSIVISMO STRUTTURE RICETTIVE_KO',
//                Street_Address__c = 'via di prova ma sbagliata',
//                Origin = 'CDC');
//        insert newCaseError;
//        allCasesToManage.add(newCaseError);

        OrgManagement__c setting = new OrgManagement__c();
        setting.Default_Queue_Label__c = 'DIP_COMUNICAZIONE_RIASSEGNAZIONE';
        insert setting;
        system.debug('setting -> '+setting);
        Group testGroup = new Group();
        testGroup.Name = '14';
        testGroup.Type = 'Queue';
        insert testGroup;
        system.debug('testGroup -> '+testGroup);
        OrgManagement__c settingR = OrgManagement__c.getOrgDefaults();
        system.debug('settingR -> '+ settingR);

        CaseCDCManager.manageCDCCase(allCasesToManage);

        List<Case> valCase = [SELECT Id, Current_Queue__c, Estimated_Queue__c From Case];
        system.debug('valCase -> '+ valCase);
        system.assertEquals(valCase.size(), allCasesToManage.size());

        Test.stopTest();
    }
}
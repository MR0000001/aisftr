/**
* Created by SNEKKANTI00 on 10/12/2020.
*/

@isTest
private with sharing class TestBatchArticlesManagement {

    @testSetup static void setup() {
        TestDataFactory.createBatchArticlesSettingLists();
    }

    @isTest
    private static void batchArticlesManagementDraftTest() {
        User u = TestDataFactory.createUserWithRoleLeaderCC();
        User u2 = TestDataFactory.createAnotherUserWithRoleLeaderCC();

        List<Knowledge__kav> queriedKAV;
        List<Knowledge__kav> kavList;

        System.runAs(u2) {
            List<Employee__c> listEmployee = TestDataFactory.listEmployeeSingle();
            kavList = TestDataFactory.createKnowledgeInternalFAQ();

            Id structureId = kavList[0].MacrostructureReference__c;
            List<Structure__c> listMacroStructures = [SELECT id FROM Structure__c WHERE Id =: structureId];
            List<Structure__c> listStructures = TestDataFactory.listStructures();

            List<Role__c> roleList = TestDataFactory.listRoleSingle(listStructures, listEmployee);
            List<MacrostructureAssociation__c> listMas = TestDataFactory.listMacrostructureAssociations(listMacroStructures, u2.Id);

            queriedKAV = KnowledgeSelector.getKnowledgeKavsFromId(kavList[0].id);
        }

        System.runAs(u) {
            update queriedKAV;
        }

        Test.startTest();
        BatchArticlesManagement bam = new BatchArticlesManagement();
        Database.executeBatch(bam);
        Test.stopTest();
    }

    @isTest
    private static void batchArticlesManagementDraftCheck0FalseTest() {
        User u = TestDataFactory.createUserWithRoleLeaderCC();
        User u2 = TestDataFactory.createAnotherUserWithRoleLeaderCC();

        List<Knowledge__kav> queriedKAV;
        List<Knowledge__kav> kavList;

        System.runAs(u) {
            List<Employee__c> listEmployee = TestDataFactory.listEmployeeSingle();
            kavList = TestDataFactory.createKnowledgeInternalFAQ();

            Id structureId = kavList[0].MacrostructureReference__c;
            List<Structure__c> listMacroStructures = [SELECT id FROM Structure__c WHERE Id =: structureId];

            List<Role__c> roleList = TestDataFactory.listRoleSingle(listMacroStructures, listEmployee);

            queriedKAV = KnowledgeSelector.getKnowledgeKavsFromId(kavList[0].id);
        }

        System.runAs(u2) {
            update queriedKAV;
        }
        Test.startTest();
        BatchArticlesManagement bam = new BatchArticlesManagement();
        Database.executeBatch(bam);
        Test.stopTest();
    }

    @isTest
    private static void batchArticlesManagementArchiveTest() {
        User u = TestDataFactory.createUserWithRoleLeaderCC();
        User u2 = TestDataFactory.createAnotherUserWithRoleLeaderCC();

        List<Knowledge__kav> queriedKAV;
        List<Knowledge__kav> kavList;

        System.runAs(u) {
            List<Employee__c> listEmployee = TestDataFactory.listEmployeeSingle();
            kavList = TestDataFactory.createKnowledgeInternalFAQ();
            kavList.addAll(TestDataFactory.createKnowledgeInternalFAQ());

            List<Id> kavIds = new List<Id>();
            for(Knowledge__kav k : kavList) {
                kavIds.add(k.Id);
            }

            Id structureId = kavList[0].MacrostructureReference__c;
            List<Structure__c> listMacroStructures = [SELECT id FROM Structure__c WHERE Id =: structureId];
            List<Structure__c> listStructures = TestDataFactory.listStructures();

            List<Role__c> roleList = TestDataFactory.listRoleSingle(listStructures, listEmployee);
            List<MacrostructureAssociation__c> listMas = TestDataFactory.listMacrostructureAssociations(listMacroStructures, u2.Id);

            queriedKAV = KnowledgeSelector.getKnowledgeKavsFromListId(kavIds);

            KbManagement.PublishingService.publishArticle(queriedKAV[0].KnowledgeArticleId, false);
            KbManagement.PublishingService.archiveOnlineArticle(queriedKAV[0].KnowledgeArticleId, null);
        }

        System.runAs(u2) {
            KbManagement.PublishingService.publishArticle(queriedKAV[1].KnowledgeArticleId, false);
            KbManagement.PublishingService.archiveOnlineArticle(queriedKAV[1].KnowledgeArticleId, null);
        }

        Test.startTest();
        BatchArticlesManagement bam = new BatchArticlesManagement();
        Database.executeBatch(bam);
        Test.stopTest();
    }

    @isTest
    private static void scheduleBatch() {
        Test.startTest();
        System.schedule('Test BatchArticlesManagement', '0 17 * ? * * *', new BatchArticlesManagement());
        Test.stopTest();
    }
}
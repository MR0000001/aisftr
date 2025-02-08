/**
 * Created by LCONATO00 on 19/05/2020.
 */
@IsTest
public with sharing class KMSearchControllerTest {
    @IsTest
    public static void fetchKnowledgeWrapperTest(){
        List<Knowledge__kav> listKnowledge = TestDataFactory.createKnowledgeNews();
        String knowledgeStatus = [SELECT PublishStatus FROM Knowledge__kav WHERE Id =: listKnowledge[0].Id].PublishStatus;
        Structure__c structure = [SELECT ID FROM Structure__c LIMIT 1];
        listKnowledge[0].MacrostructureReference__c = structure.Id;
        String structureToSearch = structure.Id;
        List<KMSearchController.knowLedgeListWrapper> knowLedgeList = KMSearchController.fetchKnowledgeWrapper('News', date.today(),date.today(),knowledgeStatus,'', '');
    }
    
    @IsTest
    public static void fetchKnowledgeWrapperTest1(){
        List<Knowledge__kav> listKnowledge = TestDataFactory.createKnowledgeNews();
        String knowledgeStatus = [SELECT PublishStatus FROM Knowledge__kav WHERE Id =: listKnowledge[0].Id].PublishStatus;
        Structure__c structure = [SELECT ID FROM Structure__c LIMIT 1];
        listKnowledge[0].MacrostructureReference__c = structure.Id;
        String structureToSearch = structure.Id;
        List<KMSearchController.knowLedgeListWrapper> knowLedgeList = KMSearchController.fetchKnowledgeWrapper('News', date.today(),date.today(),knowledgeStatus,structureToSearch,'municipio');
    }

    @IsTest
    public static void getTipologiesNameTest(){
        Map<String,String> options = KMSearchController.getTipologiesName();
        system.assert(!options.keySet().isEmpty());
    }
    @IsTest
    public static void getStatusNameTest(){
        Map<String,String> options = KMSearchController.getStatusName();
        system.assert(!options.keySet().isEmpty());
    }

}
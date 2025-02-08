/**
 * Created by LCONATO00 on 08/07/2020.
 */
@isTest
public with sharing class EditAsDraftInvocableTest {

    @isTest
    public static void editOnlineArticleTest() {
        List <String> idList = new List<String>();
        List <String> kidList = new List<String>();
        List <Knowledge__kav> listKnowlKavs = TestDataFactory.createKnowledgeInternalFAQ();
        for(Knowledge__kav thisKav : listKnowlKavs){
            idList.add(thisKav.Id);

        }
        listKnowlKavs = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id IN: idList];
        for(Knowledge__kav thisKav : listKnowlKavs){
            KbManagement.PublishingService.publishArticle(thisKav.KnowledgeArticleId,true);
            kidList.add(thisKav.KnowledgeArticleId);
        }

        Test.startTest();
        EditAsDraftInvocable.editOnlineArticle(kidList);
        Test.stopTest();
    }

}
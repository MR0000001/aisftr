/**
 * Created by RGAROFALO00 on 26/03/2020.
 */

public without sharing class KnowledgeSelector {

    public static List<Knowledge__kav> getKnowledgeKavsFromId (String idKnowledgeString){
        List<Knowledge__kav> KnowledgeList = new List<Knowledge__kav>();
        KnowledgeList = [
                SELECT Id, Question__c, Answer__c, Title, Abstract__c, ThematicArea__c, Who__c, How__c, Body__c,
                        ExpirationDate__c, MacrostructureReference__r.Name, MacrostructureReference__r.ExtendedName__c, Laws__c, Priority__c, StructureTypeReference__c,
                        ArticleType__c
                FROM Knowledge__kav
                WHERE Id =: idKnowledgeString
        ];

        return KnowledgeList;
    }

    public static List<Knowledge__kav> getKnowledgeKavsFromListId (List <Id> listIds){
        List<Knowledge__kav> KnowledgeList = new List<Knowledge__kav>();
        KnowledgeList = [
                SELECT Id, Question__c, Answer__c, TechQuestionAnswer__c, KnowledgeArticleId
                FROM Knowledge__kav
                WHERE Id IN: listIds
        ];

        return KnowledgeList;
    }
    public static List<Knowledge__kav> getKnowledgeKavsByStructureId (List <String> listIds){
        List<Knowledge__kav> KnowledgeList = new List<Knowledge__kav>();
        KnowledgeList = [
                SELECT Id, Question__c, Answer__c, TechQuestionAnswer__c,MacrostructureReference__c
                FROM Knowledge__kav
                WHERE MacrostructureReference__c IN: listIds
        ];

        return KnowledgeList;
    }
}
/**
 * Created by RGAROFALO00 on 06/04/2020.
 */

public with sharing class KnowledgeUpdateInvokable {

    @InvocableMethod
    public static void updateFieldKnowledge(List<Id> recordIdList){
        String regExpAllString = '<.*?>';
        String regExpString = '<.*>';
        String questionString = '';
        String answerString = '';
        List <Knowledge__kav> listKnowledgeKavs = KnowledgeSelector.getKnowledgeKavsFromListId(recordIdList);

        system.debug('@listKnowledgeKavs: ' + listKnowledgeKavs);

        for(Knowledge__kav forKnowledge : listKnowledgeKavs){
            String knowledgeQuestion = checkHTMLStringQuestion(forKnowledge, regExpString, regExpAllString);
            String knowledgeAnswer = checkHTMLStringAnswer(forKnowledge, regExpString, regExpAllString);

            forKnowledge.TechQuestionAnswer__c = knowledgeQuestion + ' ' + knowledgeAnswer;
            system.debug('-- forKnowledge.TechQuestionAnswer__c: ' +  forKnowledge.TechQuestionAnswer__c);
        }

        update listKnowledgeKavs;

    }

    public static String checkHTMLStringQuestion (Knowledge__kav forKnowledge, String regExpString, String regExpAllString){
        String knowledgeQuestion = '';

        if(forKnowledge.Question__c.containsAny(regExpString)){
            knowledgeQuestion = forKnowledge.Question__c.replaceAll(regExpAllString, '');
        }else {
            knowledgeQuestion = forKnowledge.Question__c;
        }
        System.debug('@@knowledgeQuestion: ' + knowledgeQuestion);

        Integer integerNumber = knowledgeQuestion.length();
        system.debug('integerNumber: ' + integerNumber);

        if(integerNumber >= 80){
            knowledgeQuestion = Label.Knowledge_Question + knowledgeQuestion.left(80) + ' ...';
        }else{
                system.debug('else');
            knowledgeQuestion = Label.Knowledge_Question + knowledgeQuestion;
        }
        System.debug('@@knowledgeAnswer: ' + knowledgeQuestion);
        return knowledgeQuestion;
    }

    public static String checkHTMLStringAnswer (Knowledge__kav forKnowledge, String regExpString, String regExpAllString){
        String knowledgeAnswer = '';

        if(forKnowledge.Answer__c.containsAny(regExpString)){
            knowledgeAnswer = forKnowledge.Answer__c.replaceAll(regExpAllString, '');
        }else {
            knowledgeAnswer = forKnowledge.Answer__c;
        }
        System.debug('@knowledgeAnswer: ' + knowledgeAnswer);

        Integer integerNumber = knowledgeAnswer.length();
        system.debug('integerNumber: ' + integerNumber);

        if(integerNumber >= 80){
            knowledgeAnswer = Label.Knowledge_Answer + knowledgeAnswer.left(80) + ' ...';
        }else {
            knowledgeAnswer =  Label.Knowledge_Answer + knowledgeAnswer.left(80);
        }

        System.debug('@@knowledgeAnswer: ' + knowledgeAnswer);
        return knowledgeAnswer;
    }
}
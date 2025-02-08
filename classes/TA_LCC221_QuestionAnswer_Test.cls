@isTest
public with sharing class TA_LCC221_QuestionAnswer_Test {
    @isTest
    static void initialize_test1() {
        String jsonTest = '{"question":"TA_ReasonMalfunctionTitle","answers":[{"label":"TA_ReasonMalfunctionAssettWasOff","value":[]},{"label":"TA_ReasonMalfunctionLockClosed","value":[]},{"label":"TA_ReasonMalfunctionWrongPosition","value":[]},{"label":"TA_ReasonMalfunctionOther","value":[]}],"answersPerRow":"2"}';
        TA_LCC221_QuestionAnswer.initialize(jsonTest);
    }
}
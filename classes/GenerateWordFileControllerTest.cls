/**
 * Created by RGAROFALO00 on 26/03/2020.
 */

@IsTest
private class GenerateWordFileControllerTest {

    @isTest
    public static void GenerateWordFileControllerTestNews() {
        List <Knowledge__kav> listKavs = TestDataFactory.createKnowledgeNews();

        Test.StartTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(listKavs[0].Id));
            GenerateWordFileController controller = new GenerateWordFileController();
        Test.StopTest();
    }

    @isTest
    public static void GenerateWordFileControllerTestExternal() {
        List <Knowledge__kav> listKavs = TestDataFactory.createKnowledgeExternalFAQ();

        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(listKavs[0].Id));
        GenerateWordFileController controller = new GenerateWordFileController();
        Test.StopTest();
    }

    @isTest
    public static void GenerateWordFileControllerTestIntenral() {
        List <Knowledge__kav> listKavs = TestDataFactory.createKnowledgeInternalFAQ();

        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(listKavs[0].Id));
        GenerateWordFileController controller = new GenerateWordFileController();
        Test.StopTest();
    }

    @isTest
    public static void GenerateWordFileControllerTestCC() {
        List <Knowledge__kav> listKavs = TestDataFactory.createKnowledgeProvisionsCC();

        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(listKavs[0].Id));
        GenerateWordFileController controller = new GenerateWordFileController();
        Test.StopTest();
    }

    @isTest
    public static void GenerateWordFileControllerTestServiceCard() {
        List <Knowledge__kav> listKavs = TestDataFactory.createKnowledgeServiceCard();

        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(listKavs[0].Id));
        GenerateWordFileController controller = new GenerateWordFileController();
        Test.StopTest();
    }
}
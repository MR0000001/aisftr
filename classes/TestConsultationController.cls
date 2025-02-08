@isTest
public with sharing class TestConsultationController {
    @testSetup static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @isTest
    public static void getMetadataTest() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMesis());

        Map<String, String> positions = ConsultationController.getPositions();
        Map<String, String> typologies = ConsultationController.getTributesTypologies();
        ConsultationController.caseListWrapper caseListWrapper = new ConsultationController.caseListWrapper('test', '2012', 'Corleone', 'Capone', '1957-12-12', '', '', '', '', cases[0].id);
        List<ConsultationController.caseListWrapper> caseListWrappers;
        Test.startTest();
        try {
            caseListWrappers = ConsultationController.fetchCaseWrapper('NNNNLL69L58G813K','392', cases[0].id);
        } catch(Exception e) {
            System.debug('Exception at TestConsultationController.getMetadataTest ' + e.getMessage());
        }
        Test.stopTest();
    }

    public static void AUCTest() {

        List<Map<String, String>> paramsList = new List<Map<String, String>>();

        Map<String, String> getAUCMock = new Map<String, String>{
                'statusCode' => '200',
                'status' => 'SUCCESS',
                'body' => '{"posizioniPerAnno":[{"annoRiferimento":"2017","posizioniPerTributo":[{"tipoTributo":"CIP","numPosizioni":2,"posizioneContribuente":[{"idPosizione":"1731988","descPosizione":"MUNICIPIO 12 - 122017120000008000393413","tipoPosizione":"O","dataEmissione":"2017-01-01","dataScadenza":null,"importoDovIntero":750.72,"importoDovRidotto":0,"importoDovMaggiorato":0,"importoPagato":0,"pagamentiPosizione":[]},{"idPosizione":"4835798","descPosizione":"Municipio 03 - 042009040000004000090840","tipoPosizione":"O","dataEmissione":"2017-01-01","dataScadenza":null,"importoDovIntero":717.6,"importoDovRidotto":0,"importoDovMaggiorato":0,"importoPagato":0,"pagamentiPosizione":[]}]}]}],"listAnni":["2017"],"transazione":23223043,"errore":null,"codiceFiscale":"PZZGPP45P30F848N"}',
                'endpoint' => 'https://gw-test.ws-comune.roma.it/t/cdc_crm.comune.roma.it/crm/auc/posizioniContribuente'
        };
        paramsList.add(getAUCMock);
        HttpCalloutMockFactory.setMocks(paramsList);
        Test.startTest();
        ResponseAUC response;
        try {
            response = ConsultationController.fetchTributesWrapper('xyz',1,'2017','CIP');
        } catch(Exception e) {
            System.debug('Exception at TestConsultationController.AUCTest ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void getAnonymousIds() {
        Test.startTest();
        try {
            ConsultationController.getAnonymousIds();
        } catch(Exception e) {
            System.debug('Exception at TestConsultationController.getOrgManagementCustomSettingTest ' + e.getMessage());
        }
        Test.stopTest();
    }
}
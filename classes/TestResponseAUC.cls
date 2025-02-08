/**
 * Created by SNEKKANTI00 on 04/02/2021.
 */

@isTest
public with sharing class TestResponseAUC {

    @isTest
    public static void responseAUCTest() {
        Test.startTest();
        ResponseAUC responseAUC = new ResponseAUC();
        ResponseAUC.posizioniPerAnno posizioniPerAnno = new ResponseAUC.posizioniPerAnno();
        ResponseAUC.posizioniPerTributo posizioniPerTributo = new ResponseAUC.posizioniPerTributo();
        ResponseAUC.posizioneContribuente posizioneContribuente = new ResponseAUC.posizioneContribuente();
        Test.stopTest();
    }
}
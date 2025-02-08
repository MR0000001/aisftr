/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation  24/11/2020 
* @description XC_REST_RefreshLoadedDocument_TEST – Test class for XC_REST_RefreshLoadedDocument
*/ 

@isTest
public with sharing class XC_LCC234_RefreshLoadedDocument_TEST {
    
    @isTest
    static void callDoxee(){
        test.startTest();
        XC_LCC234_RefreshLoadedDocument.callDoxee('123');
        test.stopTest();
    }
}
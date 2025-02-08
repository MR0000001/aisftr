@isTest
public with sharing class TA_LCC205_Homepage_Test {
    @isTest
    static void test_getListView() {
    
        Test.startTest();
        TA_LCC205_Homepage.getListView('Account', 'All');
        Test.stopTest();
        
    }
}
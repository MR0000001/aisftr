/**
* Created by SNEKKANTI00 on 15/12/2020.
*/

@isTest
public with sharing class TestCaseDetailsController {

    @testSetup static void setup() {
        TestDataFactory.createSynonymous();
        TestDataFactory.createTaxonomys();
        //TestDataFactory.createGoogleMaps();
        TestDataFactory.createWSO2Keys();
    }
    
    @isTest
    private static void test() {

        List<Group> groups = TestDataFactory.createGroups();
        User u = TestDataFactory.createAnotherUserWithRoleLeaderCC();
        System.debug('u.UserRole.Name; ' + u.UserRole.Name);

        Test.startTest();
        System.runAs(u) {
            CaseDetailsController.getSynonymous();
            CaseDetailsController.getUserQueues();
            CaseDetailsController.isUserAdminOrSuperUser();

            Map<String,String> rt = CaseDetailsController.getCaseRecordTypes();
            List<String> keys = new List<String>(rt.keySet());

            CaseDetailsController.getInteractions(keys[0]);
            CaseDetailsController.getCaseFields(keys[0]);
            CaseDetailsController.findRecords('Taxonomy__c', 'Tax_Active__c', null);
            CaseDetailsController.getUserProfile();
            CaseDetailsController.getQueueName(groups[0].id);
            //CaseDetailsController.getGoogleMaps();
            //CaseDetailsController.findMunicipality('41.830142', '13.494440');
            CaseDetailsController.synonymous syn = new CaseDetailsController.synonymous('1', 'testSyn', 'syn');
            ApexPages.StandardController stdController;
            CaseDetailsController cdc = new CaseDetailsController(stdController);
        }
        Test.stopTest();
    }
}
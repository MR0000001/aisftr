/**
 * Created by FMARCHEGIA00 on 20/04/2021.
 */

@IsTest
private class TestLinkAnonymousController {
    static testMethod void testBehavior() {
        OrgManagement__c newManagement = new OrgManagement__c();
        newManagement.AnonymuosID_del__c = 'idTest';
        insert newManagement;
        String res = linkAnonymousController.getAnonymousIdFromCustomSetting();
    }
}
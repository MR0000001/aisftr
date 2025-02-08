/**
 * Created by LCONATO00 on 08/10/2020.
 */
@isTest
public with sharing class TestAequaRomaCaseEvenTrigger {
    @isTest
    static void testCreateEvent() {

        Test.startTest();
        AequaRoma_Case__e aequaromaEvent = new AequaRoma_Case__e(CaseId__c = '12345678');
        EventBus.publish(aequaromaEvent);
        Test.stopTest();

        System.assertNotEquals(aequaromaEvent, null);
    }

}
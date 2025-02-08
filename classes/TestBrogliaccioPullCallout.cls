/**
 * Created by SNEKKANTI00 on 07/07/2021.
 */

@IsTest
public with sharing class TestBrogliaccioPullCallout {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void testBrogliaccioPullCallout() {
        Map<String, Case> extBrogliaccioIdCasesMap = new Map<String, Case>();
        extBrogliaccioIdCasesMap.put('12345', new Case(ExternalSystemId_Brogliaccio__c = '12345'));

        Test.startTest();
        BrogliaccioPullCallout.brogliaccioPullCallout(extBrogliaccioIdCasesMap);
        Test.stopTest();
    }
}
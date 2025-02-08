/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_SafetyPointKPI_TEST – Test Class for XC_UTIL_SafetyPointKPI
 */
@IsTest
private without sharing class XC_UTIL_SafetyPointKPI_TEST {

    @TestSetup
    private static void testSetup() {
        List<XC_CS015_SafetyPoint_KPI__c> spKPIs = new List<XC_CS015_SafetyPoint_KPI__c>();
        XC_CS015_SafetyPoint_KPI__c spKPI0 = new XC_CS015_SafetyPoint_KPI__c();
        spKPI0.Name = 'Planning Performance Threshold 0';
        spKPI0.XC_LegalEntity__c = 'EnelXItalia';
        spKPI0.XC_Country__c = 'Italy';
        spKPI0.XC_KPI_Type__c = 'Planning Performance';
        spKPI0.XC_Min__c = null;
        spKPI0.XC_Max__c = 0;
        spKPI0.XC_Points__c = -15;
        spKPIs.add(spKPI0);

        XC_CS015_SafetyPoint_KPI__c spKPI1 = new XC_CS015_SafetyPoint_KPI__c();
        spKPI1.Name = 'Planning Performance Threshold 1';
        spKPI1.XC_LegalEntity__c = 'EnelXItalia';
        spKPI1.XC_Country__c = 'Italy';
        spKPI1.XC_KPI_Type__c = 'Planning Performance';
        spKPI1.XC_Min__c = 0;
        spKPI1.XC_Max__c = 25;
        spKPI1.XC_Points__c = -10;
        spKPIs.add(spKPI1);

        XC_CS015_SafetyPoint_KPI__c spKPI2 = new XC_CS015_SafetyPoint_KPI__c();
        spKPI2.Name = 'Planning Performance Threshold 2';
        spKPI2.XC_LegalEntity__c = 'EnelXItalia';
        spKPI2.XC_Country__c = 'Italy';
        spKPI2.XC_KPI_Type__c = 'Planning Performance';
        spKPI2.XC_Min__c = 25;
        spKPI2.XC_Max__c = 50;
        spKPI2.XC_Points__c = -5;
        spKPIs.add(spKPI2);

        insert spKPIs;
    }

    @IsTest
    private static void computeBonusMalusTest() {
        Test.startTest();
        XC_UTIL_SafetyPointKPI.ThresholdData data0 = XC_UTIL_SafetyPointKPI.computeBonusMalus(0, 'Planning Performance', 'Italy');
        XC_UTIL_SafetyPointKPI.ThresholdData data1 = XC_UTIL_SafetyPointKPI.computeBonusMalus(15, 'Planning Performance', 'Italy');
        XC_UTIL_SafetyPointKPI.ThresholdData data2 = XC_UTIL_SafetyPointKPI.computeBonusMalus(30, 'Planning Performance', 'Italy');
        Test.stopTest();

        System.assertEquals(-15, data0.bonusMalus, 'Expected -15 points, found ' + String.valueOf(data0.bonusMalus));
        System.assertEquals(-10, data1.bonusMalus, 'Expected -10 points, found ' + String.valueOf(data1.bonusMalus));
        System.assertEquals(-5, data2.bonusMalus, 'Expected -5 points, found ' + String.valueOf(data2.bonusMalus));
    }
}
/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_UTIL_PlanningPerfWorkTypes_TEST – test clas for XC_UTIL_PlanningPerfWorkTypes class 
 */
@IsTest
private without sharing class XC_UTIL_PlanningPerfWorkTypes_TEST {

    @TestSetup
    private static void testSetup() {
        List<XC_CS013_PlanningPerformanceWorkTypes__c> ppWorkTypes = new List<XC_CS013_PlanningPerformanceWorkTypes__c>();
        XC_CS013_PlanningPerformanceWorkTypes__c ppWorkType1 = new XC_CS013_PlanningPerformanceWorkTypes__c();
        ppWorkType1.Name = 'PP Work Type Italy 1';
        ppWorkType1.XC_LegalEntity__c = 'EnelXItalia';
        ppWorkType1.XC_Country__c = 'Italy';
        ppWorkType1.XC_WorkTypeName__c = 'Delivery & Installation - Air Conditioning';
        ppWorkTypes.add(ppWorkType1);

        XC_CS013_PlanningPerformanceWorkTypes__c ppWorkType2 = new XC_CS013_PlanningPerformanceWorkTypes__c();
        ppWorkType2.Name = 'PP Work Type Italy 2';
        ppWorkType2.XC_LegalEntity__c = 'EnelXItalia';
        ppWorkType2.XC_Country__c = 'Italy';
        ppWorkType2.XC_WorkTypeName__c = 'Delivery & Installation - Boiler';
        ppWorkTypes.add(ppWorkType2);

        XC_CS013_PlanningPerformanceWorkTypes__c ppWorkType3 = new XC_CS013_PlanningPerformanceWorkTypes__c();
        ppWorkType3.Name = 'PP Work Type Spain 1';
        ppWorkType3.XC_LegalEntity__c = 'EndesaX';
        ppWorkType3.XC_Country__c = 'Spain';
        ppWorkType3.XC_WorkTypeName__c = 'Delivery & Installation - Photovoltaic';
        ppWorkTypes.add(ppWorkType3);

        insert ppWorkTypes;
    }

    @IsTest
    private static void getProductsTest() {
        Test.startTest();
        Set<String> italianProds = XC_UTIL_PlanningPerfWorkTypes.getProducts('Italy');
        Set<String> spanishProds = XC_UTIL_PlanningPerfWorkTypes.getProducts('Spain');
        Test.stopTest();

        System.assertEquals(2, italianProds.size(), 'Expected 2 products, found ' + italianProds.size());
        System.assertEquals(1, spanishProds.size(), 'Expected 1 product, found ' + spanishProds.size());
    }
}
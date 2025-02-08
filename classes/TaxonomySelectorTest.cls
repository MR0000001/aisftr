/**
 * Created by FMARCHEGIA00 on 02/02/2021.
 */

@IsTest
private class TaxonomySelectorTest {

    @testSetup
    static void setup() {
        TestDataFactory.creteTaxonomyByValues('TURISMO', 'ANTIABUSIVISMO STRUTTURE RICETTIVE', 'ANTIABUSIVISMO STRUTTURE RICETTIVE', true, true, null );
        TestDataFactory.createWSO2Keys();
    }

    static testMethod void testBehavior() {
        Test.startTest();
        List<Taxonomy__c> resultTaxonomies = TaxonomySelector.getTaxonomieForCDCCase();
        //system.assertEquals(resultTaxonomies[0].Tax_Theme_Area__c, 'TURISMO');
        Test.stopTest();
    }
}
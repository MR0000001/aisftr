/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 27/02/2020
 * @description XC_TR_Individual_U_PopulateFields_TEST – Test class for XC_TR_Individual_U_PopulateFields
 */

@isTest
private class XC_TR_Individual_U_PopulateFields_TEST {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Individual_U_PopulateFields_TEST');

    @isTest
    private static void onUpdateIndividualChildren() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Individual ind = new Individual(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName'
        );
        insert ind;
        Lead ld = XC_DF_Lead.createResidentialLead();
        ld.IndividualId = ind.Id;
        insert ld;

        Test.startTest();
        ind.FirstName = 'TestChangeFirstName';
        update ind;
        System.assertEquals(ind.FirstName, 'TestChangeFirstName');
        Test.stopTest();
    }

}
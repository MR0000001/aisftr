/**
*@Author: Francesco Imperioli fimperioli@deloitte.it
*@Date creation: 22-07-2019
*@Description: Test class for XC_LCP136_CTIContactCases
**/
@isTest
public class XC_LCC136_CTIContactCases_TEST {

    @TestSetup
    static void setup(){
        
        Case c = XC_DF_Case.createCases(1)[0];
        insert c;
        
    }

    @isTest
    static void retrieveCasePageTest(){
        Test.startTest();
            Contact c = [SELECT ID FROM Contact LIMIT 1];
            XC_LCC136_CTIContactCases.retrieveCasePage('3', '1', c.Id);
        Test.stopTest();
    }
}
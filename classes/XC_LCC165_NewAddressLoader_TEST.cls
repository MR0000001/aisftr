/**
* @author Francesco Imperioli fimperioli@deloitte.it
* @date Creation 21/10/2019
* @date Modification 
* @description XC_LCC165_NewAddressLoader - TEST CLASS
*/ 
@isTest
public class XC_LCC165_NewAddressLoader_TEST {

    @isTest
    static void getComponentNameTest(){
        Test.startTest();
            XC_LCC165_NewAddressLoader.getComponentName('Spain');
        Test.stopTest();
    }

    @isTest
    static void getComponentNameTest2(){
        Test.startTest();
            XC_LCC165_NewAddressLoader.getComponentName('Test');
        Test.stopTest();
    }

    @isTest
    static void getCountryByUser(){
        Test.startTest();
            XC_LCC165_NewAddressLoader.getCountryByUser();
        Test.stopTest();
    }

}
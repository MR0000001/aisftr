/**
 * @File Name          : XC_UTIL_UUID_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 9/6/2020, 15:11:41
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/6/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/

@isTest
public without sharing class XC_UTIL_UUID_TEST {

    @isTest
    static void newGuidTest(){
        Test.startTest();
            XC_UTIL_UUID.newGuid();
        Test.stopTest();
    }
}
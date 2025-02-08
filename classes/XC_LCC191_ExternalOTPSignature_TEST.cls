/**
 * @File Name          : XC_LCC191_ExternalOTPSignature_TEST.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 9/6/2020, 15:21:32
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/6/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
public without sharing class XC_LCC191_ExternalOTPSignature_TEST {


    @TestSetup
    static void setup(){
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
    }

    @isTest
    static void manageExternalOTPTest(){
        String orderId = [SELECT Id FROM NE__Order__c LIMIT 1].Id;
        Test.startTest();
            XC_LCC191_ExternalOTPSignature.manageExternalOTP(orderId);
        Test.stopTest();
    }
}
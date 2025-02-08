/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 10-06-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   10-06-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public  class XC_UTIL_ITAFiscalCode_TEST {

    @isTest
    public static void checkItalianCF_TEST(){

        XC_UTIL_ITAFiscalCode.CFDataWrapper wrap = new XC_UTIL_ITAFiscalCode.CFDataWrapper();
        wrap.firstName = 'Francesco';
        wrap.lastName = 'Imperioli';
        wrap.sex = 'M';
        wrap.cfToValidate = 'MPRFNC92A10C858J';
        wrap.birthDate = Date.newInstance(1992, 01, 10);
        
        XC_UTIL_ITAFiscalCode.CFDataWrapper wrap1 = new XC_UTIL_ITAFiscalCode.CFDataWrapper();
        wrap1.firstName = 'Mario';
        wrap1.lastName = 'Su';
        wrap1.sex = 'M';
        wrap1.cfToValidate = 'SUXMRA95T22H501O';
        wrap1.birthDate = Date.newInstance(1995, 12, 22);

        Test.startTest();
            XC_UTIL_ITAFiscalCode.checkItalianCF(wrap);
        	XC_UTIL_ITAFiscalCode.checkItalianCF(wrap1);
        Test.stopTest();

    }

    @isTest
    public static void calculateOmocody_TEST(){
        Test.startTest();
            XC_UTIL_ITAFiscalCode.calculateOmocody('MPRFNC92A10C858J');
        Test.stopTest();
    }

}
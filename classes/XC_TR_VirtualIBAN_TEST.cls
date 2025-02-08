/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 08-11-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   08-11-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public class XC_TR_VirtualIBAN_TEST {

    @isTest
    static void testVirtualIBANInsert(){

        XC_VirtualIBAN__c vIban = new XC_VirtualIban__c(XC_LegalEntity__c = 'EnelXItalia',XC_Segment__c = 'B2C',XC_IBAN__c = 'IT81238182A1823818239');
        insert vIban;

        XC_VirtualIBANAssociation__c vibanAss = new XC_VirtualIBANAssociation__c();
        Test.startTest();
            try{
                insert vibanAss;
            }catch(Exception e){}
        Test.stopTest();

    }

}
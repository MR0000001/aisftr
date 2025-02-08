/**
 * Created by dolombardi on 25/03/2021.
 */
@isTest
public with sharing class XC_TR_Contract_U_Fill_TermDate_Test {
    static testMethod void fillDate(){
        List<Contract> contracts =XC_DF_Contract.createContracts(1);

        contracts[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId();
        contracts[0].StartDate = Date.today();
        //contracts[0].XC_LegalEntity__c='EnelXItalia';
        insert contracts;
        contracts[0].EndDate = Date.today().addDays(1);
        update contracts;

    }

}
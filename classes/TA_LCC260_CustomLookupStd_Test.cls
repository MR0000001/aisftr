/**
 * @description       : Test class for TA_LCC260_CustomLookupStd
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 07-07-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   07-07-2021   benjamin.geronimo   Initial Version
**/
@isTest
public with sharing class TA_LCC260_CustomLookupStd_Test {

    @IsTest
    static void fetchRecords(){

        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;

        
        Test.startTest();
        TA_LCC260_CustomLookupStd.fetchRecords('Account', 'Name', 'Test', '', '', '');
        TA_LCC260_CustomLookupStd.fetchRecords('Account', '', 'Test', accountList[0].Id, '', '');
        TA_LCC260_CustomLookupStd.fetchRecords('Contact', 'Name', 'Test', '', accountList[0].Id, 'AccountId');
        // TA_LCC260_CustomLookupStd.fetchRecords('Account', '', 'Test', acc2.Id, acc1.Id, 'ParentId');
        Test.stopTest();
        
    }

}
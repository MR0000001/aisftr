/**
 * @description       :
 * @author            : Amit Singh (https://sfdcpanther.com/custom-lookup-in-lightning-web-component/)
 * @group             :
 * @last modified on  : 03-05-2022
 * @last modified by  : Marco Lazzaroni (mlazzaroni@pic-informatica.it)
**/
@IsTest
private class TAMLookUpControllerTEST {

    @IsTest
    public static void searchTest(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Phone');
        fields.add('Rating');
        List<String> searchResultsIds = new List<String>();
        searchResultsIds.add(accountId);
        Test.startTest();
        Test.setFixedSearchResults(searchResultsIds);
        TAMLookupController.search('Account', fields, 'Salesforce', '');
        Test.stopTest();
    }

    @IsTest
    public static void searchTest1(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Phone');
        fields.add('Rating');
        List<String> searchResultsIds = new List<String>();
        searchResultsIds.add(accountId);
        Test.startTest();
        Test.setFixedSearchResults(searchResultsIds);
        TAMLookupController.search('Account', fields, '', '');
        Test.stopTest();
    }

    @IsTest
    public static void searchTest2(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Phone');
        fields.add('Rating');
        List<String> searchResultsIds = new List<String>();
        searchResultsIds.add(accountId);
        Test.startTest();
        Test.setFixedSearchResults(searchResultsIds);
        TAMLookupController.search('Account', fields, 'Sa', '');
        Test.stopTest();
    }

    @IsTest
    public static void getRecentlyCreatedRecordTest(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Phone');
        fields.add('Rating');
        Test.startTest();
        SObject account = TAMLookupController.getRecentlyCreatedRecord( accountId , fields, 'Account');
        String fetchedAccountId = (String)account.get('Id');
        System.assertEquals( fetchedAccountId , accountId , 'Id is not matching' );
        Test.stopTest();
    }

    @TestSetup
    private static void createAccountRecord(){
        List<Account> aList = XC_DF_Account.createSohoAccounts(1);
        Account acc = aList[0];
        acc.Name = 'Salesforce.com';
        acc.Rating = 'Hot';
        acc.Industry = 'Technology';
        acc.Description = 'This is a test account';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '94105';
        acc.BillingCountry = 'USA';
        acc.Phone = '4158889999';
        acc.Type = 'Customer';
        insert acc;
    }
}
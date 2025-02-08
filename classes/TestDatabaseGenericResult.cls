/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestDatabaseGenericResult {
    @isTest
    public static void databaseGenericResultTest() {

        Test.startTest();
        City__c city = new City__c();
        city.Name = 'Roma';
        city.Numeric_City_Code__c = '12345';
        city.Alphanumeric_City_Code__c = '12345';

        Database.SaveResult sr = Database.insert(city, false);
        DatabaseGenericResult testDatabaseGenericResult = new DatabaseGenericResult(sr);

        Database.UpsertResult ur = Database.upsert(city, false);
        DatabaseGenericResult testDatabaseGenericResult1 = new DatabaseGenericResult(ur);

        Database.DeleteResult dr = Database.delete(city);
        DatabaseGenericResult testDatabaseGenericResult2 = new DatabaseGenericResult(dr);

        Database.UndeleteResult udr = Database.undelete(city);
        DatabaseGenericResult testDatabaseGenericResult3 = new DatabaseGenericResult(udr);

        DatabaseGenericResult.resultsToGenericResults(new List<Database.SaveResult>{sr});
        DatabaseGenericResult.resultsToGenericResults(new List<Database.UpsertResult>{ur});
        DatabaseGenericResult.resultsToGenericResults(new List<Database.DeleteResult>{dr});
        DatabaseGenericResult.resultsToGenericResults(new List<Database.UndeleteResult>{udr});

        testDatabaseGenericResult.isSuccess();
        testDatabaseGenericResult.getErrors();

        Test.stopTest();
    }
}
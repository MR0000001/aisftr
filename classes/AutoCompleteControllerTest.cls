/**
 * @author        : DDesideri
 * @description   : 
 * @TestClasses   : 
**/
@isTest
public with sharing class AutoCompleteControllerTest {
    
    @TestSetup
    public static void setup() {
        TestDataFactory.createBusinessAccounts();
    }
    

    @isTest
    public static void testGetRecords(){
        List<SObject> accounts = AutoCompleteController.getRecords('municipio', 'Structure__c', 'Id', 'Name','Name_Org_Type__c' , 10);
       
    }
}
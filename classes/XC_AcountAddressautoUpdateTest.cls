@isTest
public class XC_AcountAddressautoUpdateTest {
    @isTest
    private static void fetchRecord() {
        Account acc = new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global B2B').getRecordTypeId();
        acc.XC_FirstName__c='TestAccountfirst';
        acc.XC_LastName__c='TestAccountlast';
        acc.PrimaryEmail__c='testemail@email.com';
        acc.XC_DocumentCountry__c='Spain';
        acc.IdentityType__c='Passport';
        acc.Name='Test Account';
        acc.XC_Account_Type__c = 'Competitor';
        acc.IdentityType__c = 'Partita IVA';
        acc.IdentityNumber__c = '11123434560';
        insert acc;
        XC_Address__c add = new XC_Address__c();
        add.XC_AddressCountry__c = 'Italy';
        add.XC_City__c ='Roma' ;
        add.XC_Address__c ='Acilia' ;
        add.XC_StreetNumber__c ='1';
        add.XC_Account__c = acc.Id;
        add.XC_Region__C ='Lazio' ;
        add.XC_AddressProvince__c ='Roma';
        add.XC_Postalcode__c ='00199' ;
        add.XC_Account__c = acc.Id;
        insert add;
        
        acc.PrimaryEmail__c='testupdatechange@email.com';
        acc.XC_Account_Type__c = 'Utility';
        acc.XC_Addresss__c = add.Id;
        update acc;
    }
}
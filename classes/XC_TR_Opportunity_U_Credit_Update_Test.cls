/**
 * Created by dolombardi on 29/04/2021.
 */

@isTest
public class XC_TR_Opportunity_U_Credit_Update_Test {
    @isTest
     static void submitTest(){
        User u = XC_DF_User.createUserAdmin();
        u.XC_LegalEntity__c = 'EnelXItalia';
        insert u;

        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        accList[0].XC_Segment__c = 'B2B';
        insert accList;

        List<Contact> contList = XC_DF_Contact.createCondominiumContacts(accList);
        contList[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        contList[0].XC_Segment__c = 'B2B';
        insert contList;

        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
        oppList[0].XC_Segment__c = 'B2B';
        oppList[0].XC_LegalEntity__c = 'EnelXItalia';
        oppList[0].XC_Country__c = 'Italy';
        oppList[0].XC_Productcategoryofinterest__c = 'PV';
        //oppList[0].XC_PrincingRegion__c = '';
        oppList[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        oppList[0].StageName = 'Draft';

        Opportunity opp = oppList[0].clone(false, false, false, false);

        Map<id, Opportunity> newMap = new  Map<id, Opportunity>();
        oppList[0].Amount = 1000000;
        newMap.put(oppList[0].id, oppList[0]);

        Map<id, Opportunity> oldMap = new  Map<id, Opportunity>();
        opp.Amount = 0;
        oldMap.put(oppList[0].id, opp);

        Test.startTest();
        System.runas(u) {
            XC_TR_Opportunity_U_Credit_UpdateAmount.updateAmount(newMap, oldMap );
        }
        Test.stopTest();

    }

}
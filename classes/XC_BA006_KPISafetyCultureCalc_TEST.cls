/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 29-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_BA006_KPISafetyCultureCalc_TEST {

    @TestSetup
    static void makeData(){
        List<Account> lstAccounts = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> lstContacts = XC_DF_Contact.createPartnerContacts(lstAccounts);
        insert lstContacts;

        XC_SafetyCultureEvent__c safetyCultureEvent = new XC_SafetyCultureEvent__c();
        safetyCultureEvent.XC_Name_of_the_Initiative__c = 'SP Recovery';
        safetyCultureEvent.XC_SessionDate__c = System.today().addDays(15);
        safetyCultureEvent.XC_Status__c = 'To Be Delivered';
        insert safetyCultureEvent;

        XC_Safety_Culture_Account_Participant__c safetyCultureAccountParticipant = new XC_Safety_Culture_Account_Participant__c();
        safetyCultureAccountParticipant.XC_Account__c = lstAccounts[0].Id;
        safetyCultureAccountParticipant.XC_AwarenessCampaign__c = safetyCultureEvent.Id;
        safetyCultureAccountParticipant.XC_Participation_Rate__c = 2;
        safetyCultureAccountParticipant.XC_ParticipationReason__c = 'SP Recovery';
        safetyCultureAccountParticipant.XC_ParticipationResult__c = 'Passed';
        insert safetyCultureAccountParticipant;

        XC_SafetyCultureParticipant__c safetyCultureParticipant = new XC_SafetyCultureParticipant__c();
        safetyCultureParticipant.XC_Contact__c = lstContacts[0].Id;
        safetyCultureParticipant.XC_EffectiveParticipation__c = true;
        safetyCultureParticipant.XC_Overcoming__c = 'Passed';
        safetyCultureParticipant.XC_Safety_Culture_Account_Participant__c = safetyCultureAccountParticipant.Id;
        safetyCultureParticipant.XC_SafetyCultureEventName__c = safetyCultureEvent.Id;
        insert safetyCultureParticipant;

        XC_KPI_Safety_Culture_Request__c request = new XC_KPI_Safety_Culture_Request__c();
        request.XC_Country__c = 'Italy';
        request.XC_Legal_Entity__c = 'EnelSole';
        request.XC_Request_Date__c = System.today();
        request.XC_Request_Status__c = 'In Progress';
        request.XC_Safety_Culture_Event__c = safetyCultureEvent.Id;
        request.XC_User__c = UserInfo.getUserId();
        insert request;

        XC_KPI_Safety_Culture_Request__c requestError = new XC_KPI_Safety_Culture_Request__c();
        requestError.XC_Country__c = 'Italy';
        requestError.XC_Legal_Entity__c = 'EnelSole';
        requestError.XC_Request_Date__c = System.today();
        requestError.XC_Request_Status__c = 'Error';
        requestError.XC_Safety_Culture_Event__c = safetyCultureEvent.Id;
        requestError.XC_User__c = UserInfo.getUserId();
        insert requestError;

        XC_KPISafetyCultureRequestDetail__c requestDetail = new XC_KPISafetyCultureRequestDetail__c();
        requestDetail.XC_KPI_Safety_Culture_Request__c = requestError.Id;
        requestDetail.XC_Account__c = lstAccounts[0].Id;
        requestDetail.XC_User__c = requestError.XC_User__c;
        requestDetail.XC_Request_Date__c = requestError.XC_Request_Date__c; 
        requestDetail.XC_Request_Status__c = 'Error';
        requestDetail.XC_Request_Details__c = 'error test';
        requestDetail.XC_RetryNumber__c = 0;
        insert requestDetail;
    }

    @IsTest
    static void methodTestBatch(){
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id,XC_Safety_Culture_Event__c,XC_Country__c FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];

        Test.startTest();
        Database.executeBatch(new XC_BA006_KPISafetyCultureCalc(request.XC_Safety_Culture_Event__c,request.Id, request.XC_Country__c), 1);
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'XC_BA006_KPISafetyCultureCalc'];
        System.assertEquals(1, jobs.size(), 'The batch has not been launched correctly');
    }

    @IsTest
    static void methodTestBatchWithAccounts(){
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id,XC_Safety_Culture_Event__c,XC_Country__c FROM XC_KPI_Safety_Culture_Request__c WHERE XC_Request_Status__c = 'Error' LIMIT 1];
        Set<String> accountIds = new Set<String>();
        Integer lastRetry;
        for (XC_KPISafetyCultureRequestDetail__c reqDetails : [SELECT Id, XC_Account__c,XC_RetryNumber__c 
                                                               FROM XC_KPISafetyCultureRequestDetail__c 
                                                               WHERE XC_KPI_Safety_Culture_Request__c = :request.Id]) {
            accountIds.add(reqDetails.XC_Account__c);
            lastRetry = Integer.valueOf(reqDetails.XC_RetryNumber__c);
        }
        Test.startTest();
        Database.executeBatch(new XC_BA006_KPISafetyCultureCalc(accountIds,request.XC_Safety_Culture_Event__c,request.Id, request.XC_Country__c,lastRetry+1), 1);
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'XC_BA006_KPISafetyCultureCalc'];
        System.assertEquals(1, jobs.size(), 'The batch has not been launched correctly');
    }
}
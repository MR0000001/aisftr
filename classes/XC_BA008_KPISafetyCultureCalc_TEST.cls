/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 06/07/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_BA008_KPISafetyCultureCalc_TEST – Test Class for XC_BA008_KPISafetyCultureCalc
 */

@IsTest
private without sharing class XC_BA008_KPISafetyCultureCalc_TEST {
    
    @TestSetup
    private static void testSetup() {
        List<Account> accounts = XC_DF_Account.insertPartnerAccounts(1); 
        Account acc = accounts.get(0);
        acc.XC_Country__c = 'Italy';
        acc.XC_RenewWalletAvailable__c = true;
        update acc;

        XC_CS012_SafetyPointsWalletSettings__c setting1 = new XC_CS012_SafetyPointsWalletSettings__c();
        setting1.Name = 'EnelXItalia_Italy_1';
        setting1.XC_Country__c = 'Italy';
        setting1.XC_WalletNumber__c = 1;
        setting1.XC_MinimumPoints__c = 0;
        setting1.XC_MaximumPoints__c = 50;
        insert setting1;

        XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense spl = new XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense('Italy', 'EnelSole', true, true, 50, 0, 5, 3, 3);
        XC_UTIL_SafetyPointsLicenseManagement.createNewSafetyPointsLicenseSettings(spl);

        XC_SafetyPointWallet__c sfw = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(acc.Id, 1, 50, 'Active');
        insert sfw;

        Contact contact = XC_DF_Contact.createPartnerContacts(accounts).get(0);
        insert contact;

        XC_SafetyCultureEvent__c safetyCultureEvent = new XC_SafetyCultureEvent__c();
        safetyCultureEvent.XC_Name_of_the_Initiative__c = 'Stop Work';
        safetyCultureEvent.XC_SessionDate__c = System.today().addDays(15);
        safetyCultureEvent.XC_Status__c = 'To Be Delivered';
        insert safetyCultureEvent;

        XC_Safety_Culture_Account_Participant__c safetyCultureAccountParticipant = new XC_Safety_Culture_Account_Participant__c();
        safetyCultureAccountParticipant.XC_Account__c = acc.Id;
        safetyCultureAccountParticipant.XC_AwarenessCampaign__c = safetyCultureEvent.Id;
        safetyCultureAccountParticipant.XC_Participation_Rate__c = 2;
        safetyCultureAccountParticipant.XC_ParticipationReason__c = 'SP Recovery';
        safetyCultureAccountParticipant.XC_ParticipationResult__c = 'Passed';
        insert safetyCultureAccountParticipant;

        XC_SafetyCultureParticipant__c safetyCultureParticipant = new XC_SafetyCultureParticipant__c();
        safetyCultureParticipant.XC_Contact__c = contact.Id;
        safetyCultureParticipant.XC_EffectiveParticipation__c = true;
        safetyCultureParticipant.XC_Overcoming__c = 'Passed';
        safetyCultureParticipant.XC_Safety_Culture_Account_Participant__c = safetyCultureAccountParticipant.Id;
        safetyCultureParticipant.XC_SafetyCultureEventName__c = safetyCultureEvent.Id;
        insert safetyCultureParticipant;

        XC_KPI_Safety_Culture_Request__c request = new XC_KPI_Safety_Culture_Request__c();
        request.XC_Country__c = 'Italy';
        request.XC_Legal_Entity__c = 'EnelXItalia';
        request.XC_Request_Date__c = System.today();
        request.XC_Request_Status__c = 'To Be Applied';
        request.XC_Safety_Culture_Event__c = safetyCultureEvent.Id;
        request.XC_User__c = UserInfo.getUserId();
        insert request;

        XC_KPISafetyCultureRequestDetail__c requestDetail = new XC_KPISafetyCultureRequestDetail__c();
        requestDetail.XC_KPI_Safety_Culture_Request__c = request.Id;
        requestDetail.XC_Account__c = acc.Id;
        requestDetail.XC_User__c = request.XC_User__c;
        requestDetail.XC_Request_Date__c = request.XC_Request_Date__c; 
        requestDetail.XC_Request_Status__c = 'To Be Applied';
        requestDetail.XC_RetryNumber__c = 1;
        requestDetail.XC_SPs_Added__c = -3;
        requestDetail.XC_Participation_Outcome__c = 1;
        requestDetail.XC_Participation_Rate__c = 1;
        insert requestDetail;
    }

    @IsTest
    private static void executeBatchTest() {
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];

        Test.startTest();
        Database.executeBatch(new XC_BA008_KPISafetyCultureCalc(request.Id), 1);
        Test.stopTest();

        XC_KPISafetyCultureRequestDetail__c detail = [SELECT Id, XC_Request_Status__c FROM XC_KPISafetyCultureRequestDetail__c LIMIT 1];
        System.assertEquals('Completed', detail.XC_Request_Status__c, 'Request detail has not been completed as expected');
    }

    @IsTest
    private static void executeBatchPointTankReset(){
        /*XC_SafetyPointWallet__c wallet = [SELECT Id, XC_SPW_Status__c FROM XC_SafetyPointWallet__c LIMIT 1];
        wallet.XC_SPW_Status__c = 'Cleared';
        update wallet;*/
        XC_Safety_Culture_Account_Participant__c accParticipant = [SELECT Id, XC_ParticipationReason__c FROM XC_Safety_Culture_Account_Participant__c LIMIT 1];
        accParticipant.XC_ParticipationReason__c = 'Point Tank Reset';
        update accParticipant;
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];

        Test.startTest();
        Database.executeBatch(new XC_BA008_KPISafetyCultureCalc(request.Id), 1);
        Test.stopTest();

        XC_KPISafetyCultureRequestDetail__c detail = [SELECT Id, XC_Request_Status__c FROM XC_KPISafetyCultureRequestDetail__c LIMIT 1];
        System.assertEquals('Completed', detail.XC_Request_Status__c, 'Request detail has not been completed as expected');
    }

    @IsTest
    private static void executeBatchFailTest() {
        XC_SafetyPointWallet__c wallet = [SELECT Id FROM XC_SafetyPointWallet__c LIMIT 1];
        delete wallet;
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];

        Test.startTest();
        Database.executeBatch(new XC_BA008_KPISafetyCultureCalc(request.Id), 1);
        Test.stopTest();

        XC_KPISafetyCultureRequestDetail__c detail = [SELECT Id, XC_Request_Status__c FROM XC_KPISafetyCultureRequestDetail__c LIMIT 1];
        System.assertEquals('Error', detail.XC_Request_Status__c, 'Request detail has not gone in error as expected');
    }
}
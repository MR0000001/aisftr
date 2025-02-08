/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 30-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_IN092_KPISafetyCultureUW_TEST {

    @TestSetup
    static void makeData(){

        XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense spl = new XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense('Italy', 'EnelSole', true, true, 50, 0, 5, 3, 3);
        XC_UTIL_SafetyPointsLicenseManagement.createNewSafetyPointsLicenseSettings(spl);

        XC_UTIL_SafetyPointsWalletManagement.SafetyPointsWallet spw = new XC_UTIL_SafetyPointsWalletManagement.SafetyPointsWallet('Italy','EnelSole',1,50,0,50,'Active');
        XC_UTIL_SafetyPointsWalletManagement.createNewSafetyPointWalletSettings(spw);

        List<Account> lstAccounts = XC_DF_Account.insertPartnerAccounts(1); 
        for (Account acc : lstAccounts) {
            acc.Gruppo_Merceologico__c = 'LCRI05';
            acc.XC_Partner_Contract_Standby__c = false;
            acc.XC_SafetyPointsLicenseEnabled__c = false;
            acc.XC_Country__c = 'Italy';
            acc.XC_PartnerType__c = 'Field Service;';
            acc.XC_Segment__c = 'B2C';
            acc.XC_ContractStatus__c = 'Active';
        }
        update lstAccounts;

        XC_SafetyPointWallet__c sfw = XC_UTIL_SafetyPointsWalletManagement.createSingleSafetyPointsWallet(lstAccounts[0].Id,1,40,'Active');
        insert sfw;

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

        XC_KPISafetyCultureRequestDetail__c requestDetail = new XC_KPISafetyCultureRequestDetail__c();
        requestDetail.XC_KPI_Safety_Culture_Request__c = request.Id;
        requestDetail.XC_Account__c = lstAccounts[0].Id;
        requestDetail.XC_User__c = request.XC_User__c;
        requestDetail.XC_Request_Date__c = request.XC_Request_Date__c; 
        requestDetail.XC_Request_Status__c = 'Completed';
        requestDetail.XC_Request_Details__c = 'test';
        requestDetail.XC_RetryNumber__c = 0;
        insert requestDetail;
    }

    @IsTest 
    static void methodTestUpsertWalletsRequest(){
        
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs> flowInputs = new List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs>();
        XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs flowInput = new XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs();
        flowInput.requestId = request.Id;
        flowInputs.add(flowInput);

        Test.startTest();
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowOutputs> output = XC_IN092_KPISafetyCultureUpsertWallet.upsertWalletsWithSafetyCultureKPI(flowInputs);
        Test.stopTest();

        //System.assertEquals('Wallets updated!', output[0].result);
        XC_KPI_Safety_Culture_Request__c requestUpdated = [SELECT Id, XC_Request_Status__c FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];
        System.assertEquals('Completed', requestUpdated.XC_Request_Status__c);
    }

    @IsTest
    static void methodTestUpsertWalletsRequestDetail(){
        
        XC_KPISafetyCultureRequestDetail__c requestDetail = [SELECT Id FROM XC_KPISafetyCultureRequestDetail__c LIMIT 1];
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs> flowInputs = new List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs>();
        XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs flowInput = new XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs();
        flowInput.requestId = requestDetail.Id;
        flowInputs.add(flowInput);

        Test.startTest();
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowOutputs> output = XC_IN092_KPISafetyCultureUpsertWallet.upsertWalletsWithSafetyCultureKPI(flowInputs);
        Test.stopTest();

        //System.assertEquals('Wallets updated!', output[0].result);
        XC_KPISafetyCultureRequestDetail__c requestDetailUpdated = [SELECT Id, XC_Request_Status__c FROM XC_KPISafetyCultureRequestDetail__c LIMIT 1];
        System.assertEquals('Completed', requestDetailUpdated.XC_Request_Status__c);
    }

    /*@IsTest
    static void methodTestEmptyInput(){
        
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs> flowInputs = new List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs>();

        Test.startTest();
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowOutputs> output = XC_IN092_KPISafetyCultureUpsertWallet.upsertWalletsWithSafetyCultureKPI(flowInputs);
        Test.stopTest();
        
        System.assertEquals('The record does not meet the requirements!', output[0].result);
    }*/

    @IsTest
    static void methodTestNoWallets(){
        
        XC_KPISafetyCultureRequestDetail__c requestDetail = [SELECT Id FROM XC_KPISafetyCultureRequestDetail__c LIMIT 1];
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs> flowInputs = new List<XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs>();
        XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs flowInput = new XC_IN092_KPISafetyCultureUpsertWallet.FlowInputs();
        flowInput.requestId = requestDetail.Id;
        flowInputs.add(flowInput);

        List<XC_SafetyPointWallet__c> lstWallets = [SELECT Id FROM XC_SafetyPointWallet__c LIMIT 1];
        delete lstWallets;

        Test.startTest();
        List<XC_IN092_KPISafetyCultureUpsertWallet.FlowOutputs> output = XC_IN092_KPISafetyCultureUpsertWallet.upsertWalletsWithSafetyCultureKPI(flowInputs);
        Test.stopTest();
        XC_KPISafetyCultureRequestDetail__c requestDetailUpdate = [SELECT Id, XC_Request_Details__c FROM XC_KPISafetyCultureRequestDetail__c LIMIT 1];

        System.assertEquals('No Active or Suspended wallet', requestDetailUpdate.XC_Request_Details__c);
    }
}
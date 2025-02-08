/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 29-06-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_BA006_KPISafetyCultureCalc_U_TEST {
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

        List<XC_CS_KPISafetyCulture__c> settingsList = new List<XC_CS_KPISafetyCulture__c>();
        XC_CS_KPISafetyCulture__c setting = new XC_CS_KPISafetyCulture__c();
        setting.XC_Country__c = 'Italy';
        setting.XC_Type_of_Iniative__c = 'SP Recovery';
        setting.XC_Participation_Outcome__c = 1;
        setting.XC_Participation_Outcome_Operator__c = 'equals';
        setting.XC_Participation_Rate__c = 1;
        setting.XC_Participation_Rate_Operator__c = 'equals';
        setting.XC_Points__c = 5;
        setting.Name = 'SP_Recovery_Setting1';
        settingsList.add(setting);

        XC_CS_KPISafetyCulture__c setting2 = new XC_CS_KPISafetyCulture__c();
        setting2.XC_Country__c = 'Italy';
        setting2.XC_Type_of_Iniative__c = 'SP Recovery';
        setting2.XC_Participation_Outcome__c = 1;
        setting2.XC_Participation_Outcome_Operator__c = 'lower than';
        setting2.XC_Participation_Rate__c = 1;
        setting2.XC_Participation_Rate_Operator__c = 'equals';
        setting2.XC_Points__c = 0;
        setting2.Name = 'SP_Recovery_Setting2';
        settingsList.add(setting2);

        XC_CS_KPISafetyCulture__c setting3 = new XC_CS_KPISafetyCulture__c();
        setting3.XC_Country__c = 'Italy';
        setting3.XC_Type_of_Iniative__c = 'SP Recovery';
        //setting3.XC_Participation_Outcome__c = 1;
        //setting3.XC_Participation_Outcome_Operator__c = 'na';
        setting3.XC_Participation_Rate__c = 1;
        setting3.XC_Participation_Rate_Operator__c = 'lower than';
        setting3.XC_Points__c = -2;
        setting3.Name = 'SP_Recovery_Setting3';
        settingsList.add(setting3);
        insert settingsList;

    }

    @IsTest
    static void methodTestcomputeNumKPIparticipationRate(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        XC_SafetyCultureEvent__c event = [SELECT Id FROM XC_SafetyCultureEvent__c LIMIT 1];

        Test.startTest();
        Decimal num = XC_BA006_KPISafetyCultureCalc_U.computeNumKPIparticipationRate(event.Id, acc.Id);
        //System.assertEquals(1, num, 'Should return 1 participant');
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestcomputeDenomParticipationRate(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        XC_SafetyCultureEvent__c event = [SELECT Id FROM XC_SafetyCultureEvent__c LIMIT 1];
        
        Test.startTest();
        Decimal denom = XC_BA006_KPISafetyCultureCalc_U.computeDenomParticipationRate(event.Id, acc.Id);
        //System.assertEquals(1, denom, 'Should return 1 participant');
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestcomputeNumKPIparticipationOutcome(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        XC_SafetyCultureEvent__c event = [SELECT Id FROM XC_SafetyCultureEvent__c LIMIT 1];
        
        Test.startTest();
        Decimal num = XC_BA006_KPISafetyCultureCalc_U.computeNumKPIparticipationOutcome(event.Id, acc.Id);
        //System.assertEquals(1, num, 'Should return 1 participant');
        Test.stopTest();

    }

    @IsTest
    static void methodTestcomputeDenomParticipationOutcome(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        XC_SafetyCultureEvent__c event = [SELECT Id FROM XC_SafetyCultureEvent__c LIMIT 1];
        
        Test.startTest();
        Decimal denom = XC_BA006_KPISafetyCultureCalc_U.computeDenomParticipationOutcome(event.Id, acc.Id);
        //System.assertEquals(1, denom, 'Should return 1 participant');
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestcreateKPISafetyCultureDetail(){
        //Account acc = [SELECT Id FROM Account LIMIT 1];
        XC_Safety_Culture_Account_Participant__c accountPart = [SELECT Id, XC_Account__c, XC_ParticipationReason__c FROM XC_Safety_Culture_Account_Participant__c LIMIT 1];
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];

        Test.startTest();
        XC_BA006_KPISafetyCultureCalc_U.createKPISafetyCultureDetail(request.Id, accountPart, 'Italy');
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestcreateKPISafetyCultureDetailError(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        XC_KPI_Safety_Culture_Request__c request = [SELECT Id FROM XC_KPI_Safety_Culture_Request__c LIMIT 1];

        Test.startTest();
        XC_BA006_KPISafetyCultureCalc_U.createKPISafetyCultureDetailError(request.Id, acc.Id, 'Italy', 'Exception Caught!');
        Test.stopTest();

    }
}
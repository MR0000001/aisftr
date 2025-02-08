/**
 * @author francesco imperioli - fimperioli@deloitte.it
 * @description: TestClass for XC_UTIL_CTI_CallRecording_TEST
 * @createddate 2020-02-18
 */
@IsTest
public class XC_UTIL_CTICallRecording_TEST {

    @TestSetup
    static void setup(){

        User itAdmin = XC_DF_User.createUserAdmin();
        itAdmin.XC_LegalEntity__c = 'EnelXItalia';
        itAdmin.XC_LegalEntities__c = 'EnelXItalia';
        insert itAdmin;
        
        System.runAs(itAdmin){
            NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
            Lead l = XC_DF_Lead.createResidentialLeads(1)[0];
            insert l;
        }

    }

    @Istest
    static void generateRecordingMessageTest(){

        User u = [SELECT Id FROM User WHERE FirstName = 'TestUser' LIMIT 1];

        System.runAs(u){
            Map<String,Object> testParamsMap = new Map<String,Object>();
            testParamsMap.put('CI_connectionData','test:"123"');
            String mode = 'START';
    
            XC_CTI_Interaction__c interaction = new XC_CTI_Interaction__c(XC_Connection_ID__c='AA1234',XC_InteractionStatus__c='Open');
            insert interaction;
    
            Test.startTest();
                XC_UTIL_CTICallRecording.generateRecordingMessage(testParamsMap, mode);
            Test.stopTest();
        }

    }

    @IsTest
    static void manageInboundRecordingMessageTest(){

        User u = [SELECT Id FROM User WHERE FirstName = 'TestUser' LIMIT 1];

        System.runAs(u){
            NE__Order__c ord = [SELECT Id FROM NE__Order__c LIMIT 1];
            Map<String,Object> testParamsMap = new Map<String,Object>();
            testParamsMap.put('recUrl','https://test.salesforce.com');
            testParamsMap.put('recDuration','3.00');
            testParamsMap.put('recId','1234');
            testParamsMap.put('connId','AA1234');
            testParamsMap.put('contextRecordId',ord.Id);

            XC_CTI_Interaction__c interaction = new XC_CTI_Interaction__c(XC_Connection_ID__c='AA1234',XC_InteractionStatus__c='Open');
            insert interaction;

            Test.startTest();
                XC_UTIL_CTICallRecording.manageInboundRecordingMessage(testParamsMap);
            Test.stopTest();
        }
    }


    @IsTest
    static void manageInboundRecordingMessageTest2(){

        User u = [SELECT Id FROM User WHERE FirstName = 'TestUser' LIMIT 1];

        System.runAs(u){
			Lead lead = [SELECT Id FROM Lead LIMIT 1];
            Map<String,Object> testParamsMap = new Map<String,Object>();
            testParamsMap.put('recUrl','https://test.salesforce.com');
            testParamsMap.put('recDuration','3.00');
            testParamsMap.put('recId','1234');
            testParamsMap.put('connId','AA1234');
            testParamsMap.put('extContextRecId',lead.Id);

            XC_CTI_Interaction__c interaction = new XC_CTI_Interaction__c(XC_Connection_ID__c='AA1234',XC_InteractionStatus__c='Open');
            insert interaction;

            Test.startTest();
                XC_UTIL_CTICallRecording.manageInboundRecordingMessage(testParamsMap);
            Test.stopTest();
        }
    }

    @IsTest
    static void publishStartStopRecordingEventMessageTest(){

        User u = [SELECT Id FROM User WHERE FirstName = 'TestUser' LIMIT 1];

        System.runAs(u){
            Map<String,Object> testParamsMap = new Map<String,Object>();
            testParamsMap.put('eventType','START');
            testParamsMap.put('recId','1234');
            testParamsMap.put('connId','AA1234');

            Test.startTest();
                XC_UTIL_CTICallRecording.publishStartStopRecordingEventMessage(testParamsMap);
            Test.stopTest();
        }
    }

    @isTest
    static void checkShowRecordingPanelTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'TestUser' LIMIT 1];

        System.runAs(u){
            NE__Order__c ord = [SELECT Id,NE__OptyId__c FROM NE__Order__c LIMIT 1];
            XC_CTI_Interaction__c interaction = new XC_CTI_Interaction__c(XC_Connection_ID__c='AA1234',XC_InteractionStatus__c='Open');
            insert interaction;
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :ord.NE__OptyId__c LIMIT 1];
            opp.XC_CTI_Interaction__c = interaction.Id;
            update opp;
            Map<String,Object> testParamsMap = new Map<String,Object>();
            testParamsMap.put('objectType','NE__Order__c');
            testParamsMap.put('recordId',ord.Id);

            Test.startTest();
                XC_UTIL_CTICallRecording.checkShowRecordingPanelAndSendEvent(testParamsMap);
            Test.stopTest();
        }

    }

    @isTest
    static void checkShowRecordingPanelTest2(){
        User u = [SELECT Id FROM User WHERE FirstName = 'TestUser' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        System.runAs(u){
            XC_CTI_Interaction__c interaction = new XC_CTI_Interaction__c(XC_Connection_ID__c='AA1234',XC_InteractionStatus__c='Open');
            insert interaction;
            lead.XC_CTI_Interaction__c = interaction.Id;
            update lead;
            Map<String,Object> testParamsMap = new Map<String,Object>();
            testParamsMap.put('objectType','Lead');
            testParamsMap.put('recordId',lead.Id);

            Test.startTest();
                XC_UTIL_CTICallRecording.checkShowRecordingPanelAndSendEvent(testParamsMap);
            Test.stopTest();
        }

    }


}
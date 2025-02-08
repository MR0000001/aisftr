/**
 * The Class XC_REST_SendSMS_TEST.
 *
 * @author            : Simone Trenta strenta@deloitte.it
 * @date Creation     : 03/06/2019
 * @date Modification : 26/06/2019 by Nicola Mariniello nmariniello@deloitte.it
 * @description       : TEST Class for XC_REST_SendSMS
 */

@isTest
public with sharing class XC_REST_SendSMS_TEST {

    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
		
        List<XC_Customer_Interaction__c> custInterList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        insert custInterList;
    }

    static testMethod void requestNotActive(){

        XC_REST_SendSMS.WrapperSMSRequest req = new XC_REST_SendSMS.WrapperSMSRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.OutboundInteractionID = [SELECT Id FROM XC_Customer_Interaction__c LIMIT 1].Id;
        sms.Country = 'Spain';
        sms.Mobile = '00393398229905';
        sms.Text = 'test sms integration';
        sms.TextFormat = 'GSM7';
        req.SMS = sms;

        test.startTest();

        XC_REST_SendSMS.ResultWrapper wr = XC_REST_SendSMS.callToSendSMS(req);

        system.assertEquals(true, wr.success);

        test.stopTest();

    }

    static testMethod void requestActive(){

        XC_REST_SendSMS.WrapperSMSRequest req = new XC_REST_SendSMS.WrapperSMSRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.OutboundInteractionID = [SELECT Id FROM XC_Customer_Interaction__c LIMIT 1].Id;
        sms.Country = 'Spain';
        sms.Mobile = '123';
        sms.Text = 'test sms integration';
        sms.TextFormat = 'GSM7';
        req.SMS = sms;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_interfaceName__c = Label.XC_CL_SendSMS;
        ic.name = Label.XC_CL_SendSMS;
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'https://api-qual-local.enelx.com/esb/services/sendSMS?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_SendSMS_Mock());

        test.startTest();

        XC_REST_SendSMS.ResultWrapper wr;
       
        wr = XC_REST_SendSMS.callToSendSMS(req);
        system.assertEquals(true, wr.success);
        
        test.stopTest();

    }
    
    static testMethod void requestActiveErrorOnValidate(){

        XC_REST_SendSMS.WrapperSMSRequest req = new XC_REST_SendSMS.WrapperSMSRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.Country = '';
        sms.Mobile = '123';
        sms.Text = 'test sms integration';
        sms.TextFormat = 'GSM7';
        req.SMS = sms;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_interfaceName__c = Label.XC_CL_SendSMS;
        ic.name = Label.XC_CL_SendSMS;
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'https://api-qual-local.enelx.com/esb/services/sendSMS?api_key=etxfrn5spygkanhed78emgg5';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_SendSMS_Mock());

        test.startTest();

        XC_REST_SendSMS.ResultWrapper wr;
       
        wr = XC_REST_SendSMS.callToSendSMS(req);
        system.assertEquals(false, wr.success);
        
        test.stopTest();

    }

    static testMethod void requestActiveError500(){

        XC_REST_SendSMS.WrapperSMSRequest req = new XC_REST_SendSMS.WrapperSMSRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.OutboundInteractionID = [SELECT Id FROM XC_Customer_Interaction__c LIMIT 1].Id;
        sms.Country = 'Spain';
        sms.Mobile = '123';
        sms.Text = 'err';
        sms.TextFormat = 'GSM7';
        req.SMS = sms;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_interfaceName__c = Label.XC_CL_SendSMS;
        ic.name = Label.XC_CL_SendSMS;
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'https://api-qual-local.enelx.com/esb/services/sendSMS?api_key=etxfrn5spygkanhed78emgg500';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_SendSMS_Mock());

        test.startTest();
        XC_REST_SendSMS.ResultWrapper wr = XC_REST_SendSMS.callToSendSMS(req);
        system.assertEquals(false, wr.success);
        test.stopTest();
    }
    
    
    static testMethod void requestActiveError1(){

        XC_REST_SendSMS.WrapperSMSRequest req = new XC_REST_SendSMS.WrapperSMSRequest();
        XC_REST_SMS_W.WrapperSMS sms = new XC_REST_SMS_W.WrapperSMS();
        sms.OutboundInteractionID = [SELECT Id FROM XC_Customer_Interaction__c LIMIT 1].Id;
        sms.Country = 'Spain';
        sms.Mobile = '123';
        sms.Text = 'err';
        sms.TextFormat = 'GSM7';
        req.SMS = sms;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_interfaceName__c = Label.XC_CL_SendSMS;
        ic.name = Label.XC_CL_SendSMS;
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'https://api-qual-local.enelx.com/esb/services/sendSMS?api_key=etxfrn5spygkanhed78emgg1';
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_SendSMS_Mock());

        test.startTest();
        XC_REST_SendSMS.ResultWrapper wr = XC_REST_SendSMS.callToSendSMS(req);
        system.assertEquals(false, wr.success);
        test.stopTest();
    }

}
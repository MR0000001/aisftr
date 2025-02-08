/**
* @author Federico Melella - fmelella@deloitte.it
* @date Creation 15/07/2019
* @description XC_TR_EmailMessage_U_ManageParentCase_TEST – Test Class for Case Status update from Email to Case
*/
@IsTest
public with sharing class XC_TR_EmailMessage_U_ManParCase_TEST {


    @TestSetup
    private static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //Group g= [Select id from Group where Name ='Cases from Email' LIMIT 1][0];
        Case c = XC_DF_Case.createCases(1)[0];
        //c.OwnerId = g.id;
        c.XC_LegalEntity__c = 'EnelX';
        insert c;
    }

    @isTest
    public static void emailIncoming(){
        List<XC_CM_Email2Case_ServConfig__mdt> config = [select Id, XC_ServiceEmail__c from XC_CM_Email2Case_ServConfig__mdt];
        Case c = [Select id from Case LIMIT 1][0];
        EmailMessage email = new EmailMessage();
        email.ParentId = c.id;
        email.Incoming= true;
        email.ToAddress = config[0].XC_ServiceEmail__c;
        email.CcAddress = 'clientesenelx@x.enel.com';
        
        Test.startTest();
        insert email;
        //System.debug('Incoming Lo Status del case é: '+ [Select id, Status from Case where id =: email.ParentId LIMIT 1][0].Status + ' con id: ' + email.ParentId);
        //System.assertEquals( XC_AT_Constants.TRIGGER_STATUS_ESTA001,[Select id, Status from Case where id =: email.ParentId LIMIT 1][0].Status, 'wrong assertEquals emailIncoming');
        Test.stopTest();
    }

    @isTest
    public static void emailNotIncoming(){
        Case c = [Select id from Case LIMIT 1][0];
       
        EmailMessage email = new EmailMessage();
        email.ParentId = c.id;
        email.Incoming = false;

        
        Test.startTest();
        insert email;
        System.debug('NotIncoming Lo Status del case é: '+ [Select id, Status from Case where id =: email.ParentId LIMIT 1][0].Status);
        //System.assertEquals( XC_AT_Constants.TRIGGER_STATUS_ESTA004,[Select id, Status from Case where id =: email.ParentId LIMIT 1][0].Status, 'wrong assertEquals emailNotIncoming');
        Test.stopTest();

    }

    @isTest
    public static void emailHandler(){
        Case c = [Select id from Case LIMIT 1][0];
        EmailMessage email = new EmailMessage();
        email.ParentId = c.id;
        email.Incoming= true;
        email.ToAddress = 'enelxway.italy.support@enel.com';

        Test.startTest();
        insert email;
        update email; 
        delete email;
        Test.stopTest();
        // System.assertEquals( true,email != null, 'wrong assertEquals emailHandler');
    }

    @isTest
    public static void geolocalizationCountryCaseFieldTest(){
        XC_CS017_Contact_Center__c csContactCenter = new XC_CS017_Contact_Center__c();
        csContactCenter.Name = 'Test Italy';
        csContactCenter.XC_Country__c = 'Italy';
        csContactCenter.XC_Email__c = 'enelxway.italy.support@enel.com';
    
        Case c = [Select id from Case LIMIT 1][0];

        EmailMessage email = new EmailMessage();
        email.ParentId = c.id;
        email.Incoming= true;
        email.ToAddress = 'enelxway.italy.support@enel.com';
        
        Test.startTest();
        insert csContactCenter;
        insert email;
        Test.stopTest();
        // Case cAfterUpdate = [Select id,XC_GeolocalizationCountry__c from Case LIMIT 1][0];
        // System.assertEquals('Italy', cAfterUpdate.XC_GeolocalizationCountry__c);

    }
}
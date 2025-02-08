/**
*@Author: Dario Tramontin dtramontin@deloitte.it
*@Date creation: 24-07-2019
*@Description: TEST CLASS for XC_LCC136_UpCompliantCaseIndemnif
**/

@isTest
public with sharing class XC_LCC136_UpCompliantCaseIndemnif_TEST {
    
    @TestSetup 
    static void setup(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> cases=XC_DF_Case.createCases(1);
        Case c= cases[0];
        c.Status = 'ESTA001';
        insert c;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Indemnification;
        ic.XC_interfaceName__c = Label.XC_CL_Indemnification;
        insert ic;

        List<Account> a =[ SELECT id FROM Account WHERE Id = :c.AccountId ];
        List<NE__Billing_Profile__c> billingProf= XC_DF_BillingProfile.createBillingProfile(1, a);
        List<XC_BillingProfileLineItem__C> bplist=[SELECT Id,XC_Status__c FROM XC_BillingProfileLineItem__c];
        for(XC_BillingProfileLineItem__c bpli : bplist) {
            bpli.XC_Status__c = Label.XC_CL_Billing_Active;
        }
        update bplist;

        for(NE__Billing_Profile__c bp : billingProf) {
            bp.XC_Status__c =Label.XC_CL_Billing_Active;
        }
        update billingProf;
       
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ESP_Complaint_Case').getRecordTypeId();
        c.XC_LegalEntity__c='EndesaX';
        update c; 

        XC_CS002_AccessToken__c accessToken = new XC_CS002_AccessToken__c (Name = 'DevCredential', XC_ConsumerKey__c = '456', XC_ConsumerSecret__c = '8393', 
                                                                       XC_OrgURL__c = 'https://test.salesforce.com/', XC_PasswordAndToken__c = '383983djdk00', XC_User__c ='UserTest');
        insert accessToken;  

        XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c(XC_BillingProfile__c = billingProf[0].Id);
        insert bpli;
        
    }


    static testMethod void billingInfo(){
        Case c= [SELECT id FROM Case WHERE AccountId IN (SELECT NE__Account__c FROM NE__Billing_Profile__c ) AND RecordType.Name= 'XC_ESP_Complaint_Case' LIMIT 1];
        XC_LCC136_UpCompliantCaseIndemnif.ResultWrapper rw = new XC_LCC136_UpCompliantCaseIndemnif.ResultWrapper();
       
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new getResultPicklistValues_Mock());
        rw = XC_LCC136_UpCompliantCaseIndemnif.getBillingInfo(c.id);
        test.stopTest();
        system.assert(rw != null, 'Test correct'); 
    }


    static testMethod void getAmount(){
       
        test.startTest();
        XC_LCC136_UpCompliantCaseIndemnif.ResultWrapper rw = XC_LCC136_UpCompliantCaseIndemnif.getAmount('IND012');
        test.stopTest();

        system.assert(rw != null, 'Test correct'); 
    }


    static testMethod void approvalProcessNeeded(){
        Case c= [SELECT Id FROM Case WHERE AccountId IN (SELECT NE__Account__c FROM NE__Billing_Profile__c ) AND RecordType.Name= 'XC_ESP_Complaint_Case' LIMIT 1];
        XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification caseIndem = new XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification();

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, Name, XC_ZuoraId__c  FROM XC_BillingProfileLineItem__c LIMIT 1][0];

        Map<String,Object> mapInput=  new Map<String,Object>();
        Object s= '';
        mapInput.put('XC_Billing_Profile_Line_Item__c', bpli.Id);
        mapInput.put('XC_Case_Comments__c', 'Test');
        mapInput.put('XC_Amount__c', (Object)123 );
        mapInput.put('XC_Automatic_Refund__c', (object) true);
        mapInput.put('XC_ApprovalStatus__c', 'Needed');

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_Zuora_Mock());
        caseIndem = XC_LCC136_UpCompliantCaseIndemnif.updateComplaintCase( JSON.serialize(mapInput), c.id);
        test.stopTest();
        system.assert( caseIndem!= null, 'Test correct'); 
    }


    static testMethod void approvalProcessNotNeeded(){
        Case c= [SELECT Id FROM Case WHERE AccountId IN (SELECT NE__Account__c FROM NE__Billing_Profile__c ) AND RecordType.Name= 'XC_ESP_Complaint_Case' LIMIT 1];
        XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification caseIndem = new XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification();

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, Name, XC_ZuoraId__c  FROM XC_BillingProfileLineItem__c LIMIT 1][0];

        Map<String,Object> mapInput=  new Map<String,Object>();
        Object s= '';
        mapInput.put('XC_Billing_Profile_Line_Item__c', bpli.Id);
        mapInput.put('XC_Case_Comments__c', 'test');
        mapInput.put('XC_Subtype__c',s );
        mapInput.put('XC_Amount__c', (Object)123 );
        mapInput.put('XC_Automatic_Refund__c', (object) true);
        mapInput.put('XC_ApprovalStatus__c', 'Not Needed');
        mapInput.put('XC_LegalEntity__c', 'EndesaX');

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_Zuora_Mock());
        caseIndem = XC_LCC136_UpCompliantCaseIndemnif.updateComplaintCase( JSON.serialize(mapInput), c.id);
        test.stopTest();
        system.assert( caseIndem!= null, 'Test correct'); 
    }


    static testMethod void approvalProcessRefused(){
        Case c= [SELECT Id FROM Case WHERE AccountId IN (SELECT NE__Account__c FROM NE__Billing_Profile__c ) AND RecordType.Name= 'XC_ESP_Complaint_Case' LIMIT 1];
        XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification caseIndem = new XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification();

        Map<String,Object> mapInput=  new Map<String,Object>();

        mapInput.put('XC_Case_Comments__c', 'test');
        mapInput.put('XC_Amount__c', (Object)123 );
        mapInput.put('XC_Automatic_Refund__c', (object) true);
        mapInput.put('XC_ApprovalStatus__c', 'Refused');

        test.startTest();
        caseIndem = XC_LCC136_UpCompliantCaseIndemnif.updateComplaintCase( JSON.serialize(mapInput), c.id);
        test.stopTest();
        system.assert( caseIndem!= null, 'Test correct'); 
    }


    static testMethod void approvalProcessApproved(){
        Case c= [SELECT Id FROM Case WHERE AccountId IN (SELECT NE__Account__c FROM NE__Billing_Profile__c ) AND RecordType.Name= 'XC_ESP_Complaint_Case' LIMIT 1];
        XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification caseIndem = new XC_LCC136_UpCompliantCaseIndemnif.CaseIndemnification();

        XC_BillingProfileLineItem__c bpli = [SELECT Id, XC_BillingProfile__c, Name, XC_ZuoraId__c  FROM XC_BillingProfileLineItem__c LIMIT 1][0];

        Map<String,Object> mapInput=  new Map<String,Object>();
        Object s= '';
        mapInput.put('XC_Billing_Profile_Line_Item__c', bpli.Id);
        mapInput.put('XC_Case_Comments__c', 'Test');
        mapInput.put('XC_Amount__c', (Object)123 );
        mapInput.put('XC_Automatic_Refund__c', (object) true);
        mapInput.put('XC_ApprovalStatus__c', 'Approved');
        mapInput.put('XC_SentToZuora__c', 'Yes');
        mapInput.put('XC_SendStatus__c', 'Ko');

        test.startTest();
        caseIndem = XC_LCC136_UpCompliantCaseIndemnif.updateComplaintCase( JSON.serialize(mapInput), c.id);
        test.stopTest();
        system.assert( caseIndem!= null, 'Test correct'); 
    }
    

    static testMethod void restNoLegalEntity(){
        XC_REST_Indemnification.WrapperRequest wr= new XC_REST_Indemnification.WrapperRequest();
        wr.AccountId='8adcc59c6b07724e016b08ed01a04f19';
        wr.ReasonCode='Write-off';
        wr.Amount=3;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new XC_REST_Zuora_Mock());
        XC_REST_Indemnification.WrapperResponse wresp=XC_REST_Indemnification.createIndemnification(wr);
        test.stopTest();
        system.assert( wresp!= null, 'Test correct'); 
    }


     /*
	*@ Description mock class to call getResultPicklistValues 
	*/
    public without sharing class getResultPicklistValues_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();

            if(req.getEndpoint().contains('salesforce.com/services/oauth2/token')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://salesforce.com","id":"https://test.salesforce.com/id/test/test","token_type":"Bearer","issued_at":"1562317536989","signature":"test"}');
                response.setStatusCode(200); 

            } else if(req.getEndpoint().contains('/services/data/v41.0/ui-api/object-info/Case/picklist-values')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"controllerValues":{},"defaultValue":null,"url":"/services/data/v41.0/ui-api/object-info/Case/picklist-values/0129E000000X5xOQAS/XC_Subtype__c","values":[{"attributes":null,"label":"Solicitud de ejercicio de derechos no atendida","validFor":[],"value":"XC006"}, {"label":"Solicitud de no reci","validFor":[],"value":"XC007"}]}');
                response.setStatusCode(200); 
            } 
            return response;
        }
    }

    public without sharing class XC_REST_Zuora_Mock implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest req) { 
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":48244,"name":"WF-40472-00000054","originalWorkflowId":40472,"type":"Workflow::Instance","status":"Queued","createdAt":"","updatedAt":""}');
            res.setStatusCode(200);
            
            return res;    
        }
    }

}
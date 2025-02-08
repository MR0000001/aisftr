/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation  15/05/2019 
* @description XC_LCC068_Care_NewCaseByInsistence_TEST – Test class for XC_LCC068_Care_NewCaseByInsistence
*/
@isTest
public class XC_LCC068_Care_NewCaseByInsistence_TEST {
    
    public class GetToken_Mock implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req){
            Map<String, Object> accessMap = new Map<String, Object>();
            accessMap.put('access_token', '01234567890');
            
            HttpResponse response = new  HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(accessMap, true));
            response.setStatusCode(200);
            return response;
        }
    }

    /**
    * @description Test Method createCase called from Case
    **/
    @isTest
    static void checkPrimaryContact(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        cont[0].XC_PrimaryContact__c = false;
        insert cont;
        
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].Reason = 'XCMOT011';
        caseList[0].SubCause__c = 'ATCL010';
        caseList[0].AccountId = acc[0].Id;
        caseList[0].ContactId = cont[0].Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        insert caseList;
        List<Case> cases = [SELECT id FROM Case];
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw1= XC_LCC068_Care_NewCaseByInsistence.checkPrimaryContact(cases[0].Id);
        XC_LCC068_Care_NewCaseByInsistence.checkItaly(cases[0].Id);
       
        cases[0].XC_ReclamationCounter__c = 1;
        XC_LCC068_Care_NewCaseByInsistence.incrementCaseCounter(cases[0]);
        XC_LCC068_Care_NewCaseByInsistence.updateStatus('0WO0D000000SGLuWAO');
        //XC_LCC068_Care_NewCaseByInsistence.backCompliance('5000D000007dkm5QAA');
        
        
        cont[0].XC_PrimaryContact__c = true;
        update cont;
        XC_UTIL_ResultWrapper rw2= XC_LCC068_Care_NewCaseByInsistence.checkPrimaryContact('cases[0].Id');
        System.assert(rw1!=null && rw2!=null);
        Test.stopTest();
    }
    
    /**
    * @description Test Method createCase called from Case
    **/
    @isTest
    static void callCreateCaseWithWrongId(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accounts = [SELECT id FROM Account];
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.createCase(accounts[0].Id);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    /**
* @description Test Method createCase called from Case
**/
    @isTest
    static void callCreateCaseFromCase(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].Reason = 'XCMOT011';
        caseList[0].SubCause__c = 'ATCL010';
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        insert caseList;
        
        List<Case> cases = [SELECT id FROM Case];
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.createCase(cases[0].Id);
        System.assert(rw!=null);
        Test.stopTest();
    }



    @isTest
    static  void callActiveValueByRecordType(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].XC_LegalEntity__c = 'EndesaX';
        listCase[0].XC_Segment__c = 'B2C';
        insert listCase;
        
        Map<String, Object> accessMap = new Map<String, Object>();
        accessMap.put('access_token', '09876543210');
        
        Test.setMock(HttpCalloutMock.class, new GetToken_Mock());
        Test.startTest();
        List<Map<String, String>> endpoint = XC_LCC068_Care_NewCaseByInsistence.getActiveValueByRecordType('Case', listCase[0].recordTypeId, 'apiTest');
        System.assert(endpoint!=null);
        Test.stopTest();
    }
    
    @isTest
    static void callCreateCaseFromCaseClosed(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].SubCause__c = 'ATCL010';
        caseList[0].Reason = 'XCMOT011';
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        insert caseList;
        
        caseList[0].XC_Result__c = 'RS003';
        caseList[0].XC_Resolution__c = 'R001';
        caseList[0].CaseRemarks__c = 'tect caso chiuso';
        update caseList;
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.createCase(caseList[0].Id);
        System.assert(!rw.success);
        Test.stopTest();
    }
    
    /**
    * @description Test Method createCase called from Opportunity
    **/
    @isTest
    static void callCreateCaseFromOpportunity(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Opportunity> optToInsert=XC_DF_Opportunity.createOpportunity(1, false);
        
        XC_ProductCategoryOfInterest__c prodToUp= [SELECT Id,Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        prodToUp.Name='Caldera';
        update prodToUp;
        for(Opportunity ot : optToInsert) {
            ot.XC_ProductCategoryOfInterest__c = prodToUp.Name;
            ot.XC_LegalEntity__c = 'EndesaX';
            ot.XC_Segment__c = 'B2C';
        }

        insert optToInsert;


        //List<Opportunity> opportunities = [SELECT id FROM Opportunity];
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.createCase(optToInsert[0].Id);
        System.assert(rw!=null);
      
        XC_LCC068_Care_NewCaseByInsistence.incrementOpportunityCounter(optToInsert[0]);
        Test.stopTest();
    }
    
    @isTest
    static void callCreateCaseFromOpportunityLost(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Opportunity> optToInsert=XC_DF_Opportunity.createOpportunity(1, false);
        
        XC_ProductCategoryOfInterest__c prodToUp= [SELECT Id,Name FROM XC_ProductCategoryOfInterest__c LIMIT 1];
        prodToUp.Name='Caldera';
        update prodToUp;
        for(Opportunity ot : optToInsert) {
            ot.XC_ProductCategoryOfInterest__c = prodToUp.Name;
            ot.XC_LegalEntity__c = 'EndesaX';
            ot.XC_Segment__c = 'B2C';
        }

        insert optToInsert;

        List<Opportunity> opportunities = [SELECT id FROM Opportunity];
        opportunities[0].StageName = Label.XC_CL_Opportunity_ClosedLost;
        opportunities[0].XC_LossReason__c = 'Other';
        update opportunities;
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.createCase(opportunities[0].Id);
        System.assert(!rw.success);
        Test.stopTest();
    }
    
    /**
    * @description Test Method createCase called from WO
    **/
    @isTest
    static void callCreateCaseFromWO(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        insert XC_DF_Contact.createResidentialContacts(1);
        List<WorkOrder> wos = [SELECT id FROM WorkOrder];
        List<Contact> contacts = [SELECT id FROM Contact];
        wos[0].ContactId = contacts[0].Id;
        Id rtWorkOrderXCSpain = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_WorkOrder).getRecordTypeId(); //XC_AT_Constants.WO_RECORD_TYPE_XC_ATTENTION_ESPANA
        wos[0].RecordTypeId = rtWorkOrderXCSpain;
        update wos;
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.createCase(wos[0].Id);
        System.assert(rw!=null);
       
        XC_LCC068_Care_NewCaseByInsistence.createCase(wos[0].Id);
        Test.stopTest();
    }
    
        @isTest
        static void callCreateCaseFromWOCancelled(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        insert XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_CommercialVisit);
        insert XC_DF_Contact.createResidentialContacts(1);
        List<WorkOrder> wos = [SELECT id FROM WorkOrder];
        List<Contact> contacts = [SELECT id FROM Contact];
        wos[0].ContactId = contacts[0].Id;
        Id rtWorkOrderXCSpain = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_ESP_WorkOrder).getRecordTypeId(); //XC_AT_Constants.WO_RECORD_TYPE_XC_ATTENTION_ESPANA
        wos[0].RecordTypeId = rtWorkOrderXCSpain;
        wos[0].Status = Label.XC_CL_WorkOrder_Canceled;
        update wos;
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.createCase(wos[0].Id);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    @isTest
    static void checkResultPicklistValues(){
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        cont[0].XC_PrimaryContact__c = false;
        insert cont;
        
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].Reason = 'XCMOT011';
        caseList[0].SubCause__c = 'ATCL010';
        caseList[0].AccountId = acc[0].Id;
        caseList[0].ContactId = cont[0].Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        insert caseList[0];
        
        List<Schema.PicklistEntry> picklistResult = Schema.Case.XC_Result__c.getDescribe().getPicklistValues();
        List<Map<String, String>> resultActivePicklistValues = new List<Map<String, String>>();
        for(Schema.PicklistEntry pe : picklistResult) {
            if(pe.isActive()) {
                resultActivePicklistValues.add(new Map<String, String>{'value' => pe.getValue(), 'label' => pe.getLabel()});
            }
        }
        resultActivePicklistValues.add(new Map<String, String>{'value' => 'test', 'label' => 'test'});
        
        List<Map<String, String>> resultPicklistValues = new List<Map<String, String>>();
        resultPicklistValues.add(new Map<String, String>{'value' => 'test', 'label' => 'test'});
        
        Test.startTest();
        List<Map<String, String>> values = XC_LCC068_Care_NewCaseByInsistence.checkResultPicklistValues(resultActivePicklistValues, resultPicklistValues);
        System.assert(!values.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    static  void callPicklistValuesUtils(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].XC_LegalEntity__c = 'EndesaX';
        listCase[0].XC_Segment__c = 'B2C';
        insert listCase;
        
        Map<String, Object> accessMap = new Map<String, Object>();
        accessMap.put('access_token', '09876543210');
        
        Test.startTest();
        String endpoint = XC_LCC068_Care_NewCaseByInsistence.getPicklistValuesEndpoint('Case', listCase[0].recordTypeId, 'apiTest');
        HttpRequest req = XC_LCC068_Care_NewCaseByInsistence.getPicklistValuesRequest(accessMap, 'endpointTest'); //, 
        System.assert(endpoint!=null && req!=null);
        Test.stopTest();
    }
    
    /**
    * @description Test Method setCaseStatusCancel called from Case
    **/
    @isTest
    static  void callSetCaseStatusCancel(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA001';
        listCase[0].XC_LegalEntity__c = 'EndesaX';
        listCase[0].XC_Segment__c = 'B2C';
        insert listCase;
        listCase[0].Status = 'ESTA003';
        update listCase;
        List<Case> cases = [SELECT id FROM Case];
        Map<String,String> mapUtil = new Map<String,String>{'resolution' => 'resolution', 'result' => 'result', 'caseRemarks' => 'caseRemarks'};
            
            Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.setCaseStatusCancel(cases[0].Id, JSON.Serialize(mapUtil));
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    /**
    * @description Test Method getSwitchUtil called from Case
    **/
    @isTest
    static void callGetSwitchUtil(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA001';
        listCase[0].XC_LegalEntity__c = 'EndesaX';
        listCase[0].XC_Segment__c = 'B2C';
        insert listCase;
        listCase[0].Status = 'ESTA003';
        update listCase;
        insert XC_DF_Asset.createAssets(1);
        List<Asset> assets = [SELECT id, ContactId FROM Asset];
        assets[0].ContactId = listCase[0].ContactId;
        assets[0].AccountId = listCase[0].AccountId;
        update assets;
        listCase[0].ContactId = assets[0].ContactId;
        listCase[0].AssetId = assets[0].Id;
        update listCase;
        XC_CS002_AccessToken__c accessToken = new XC_CS002_AccessToken__c (Name = 'DevCredential', XC_ConsumerKey__c = '456', XC_ConsumerSecret__c = '8393', 
                                                                           XC_OrgURL__c = 'https://test.salesforce.com/', XC_PasswordAndToken__c = '383983djdk00', XC_User__c ='UserTest');
        insert accessToken;
         XC_CS002_AccessToken__c accessToken1 = new XC_CS002_AccessToken__c (Name = 'DevHubCredential', XC_ConsumerKey__c = '456', XC_ConsumerSecret__c = '8393', 
                                                                           XC_OrgURL__c = 'https://test.salesforce.com/', XC_PasswordAndToken__c = '383983djdk00', XC_User__c ='UserTest');
        insert accessToken1;   
          XC_CS002_AccessToken__c accessToken2 = new XC_CS002_AccessToken__c (Name = 'UATCredential', XC_ConsumerKey__c = '456', XC_ConsumerSecret__c = '8393', 
                                                                           XC_OrgURL__c = 'https://test.salesforce.com/', XC_PasswordAndToken__c = '383983djdk00', XC_User__c ='UserTest');
        insert accessToken2;  
          XC_CS002_AccessToken__c accessToken3 = new XC_CS002_AccessToken__c (Name = 'PRODCredential', XC_ConsumerKey__c = '456', XC_ConsumerSecret__c = '8393', 
                                                                           XC_OrgURL__c = 'https://test.salesforce.com/', XC_PasswordAndToken__c = '383983djdk00', XC_User__c ='UserTest');
        insert accessToken3;  
        
        
        
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new getResultPicklistValues_Mock());
            XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.getSwitchUtil(listCase[0].Id);
            Test.setMock(HttpCalloutMock.class, new getResultPicklistValues_Mock());
            XC_LCC068_Care_NewCaseByInsistence.getCaseInformations(listCase[0].Id);
            System.assert(rw!=null);
        }
        catch(Exception e){
            system.debug('In Catch');
        }
        
        Test.stopTest();
    }
    @isTest
    static void callSuspendActionAsset(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
        insert invoice;
        Zuora__ZInvoice__c invoice2 = new Zuora__ZInvoice__c();
        insert invoice2;
        
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        subscription.Zuora__External_Id__c = '123';
        insert subscription;
        
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].XC_Invoice__c = invoice.Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].XC_Subscription__c = subscription.Id;
        insert listAsset;
        
        Zuora__InvoiceItem__c itemInvoice = new Zuora__InvoiceItem__c();
        itemInvoice.Zuora__Invoice__c =  invoice.Id;
        itemInvoice.Zuora__Subscription__c = subscription.Id;
        insert itemInvoice;
        
        insert caseList;
        
        List<Case> cases = [SELECT id FROM Case];
        Test.startTest();
        XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.suspendActionAsset(cases[0].Id);
        //XC_UTIL_ResultWrapper rw5= XC_LCC068_Care_NewCaseByInsistence.suspendActionAsset(caseList2[0].Id);
        XC_LCC139_DocumentVerification.ResultWrapper rw2 = XC_LCC068_Care_NewCaseByInsistence.documentVerification(cases[0].Id);
        //XC_LCC139_DocumentVerification.ResultWrapper rw3 = XC_LCC068_Care_NewCaseByInsistence.backCompliance(cases[0].Id);
        XC_LCC157_RecalculateUrgency.ResultWrapper rw4 =  XC_LCC068_Care_NewCaseByInsistence.createWorkOrder(cases[0].Id);
        XC_UTIL_ResultWrapper rw5 = XC_LCC068_Care_NewCaseByInsistence.checkPrimaryContact(cases[0].Id);
        //SS 15/12/2020
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ITA_Management_Case').getRecordTypeId();
        Case cs = cases[0];
        cs.recordTypeId = caseRecordType;
        update cs;
        List<XC_B2BG_QualityCheck__c> qualityCheckList = XC_DF_QualityCheck.createQualityChecks(1);
        XC_B2BG_QualityCheck__c qc = qualityCheckList[0];
        qc.XC_AnswerA1__c = 'NC';
        qc.XC_NotCompliance_CommentsA1__c = 'TEST';
        qc.XC_Case__c = cs.Id;
        insert qc;
        XC_LCC068_Care_NewCaseByInsistence.qualityCheckUpdate(cs.Id);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    @isTest
    static void callSuspendActionAsset2(){
        Test.startTest();
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Zuora__ZInvoice__c> listZuoraZInvoice = new List<Zuora__ZInvoice__c>();
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
        listZuoraZInvoice.add(invoice);
        Zuora__ZInvoice__c invoice2 = new Zuora__ZInvoice__c();
        listZuoraZInvoice.add(invoice2);
        insert listZuoraZInvoice;
        
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        subscription.Zuora__External_Id__c = '123';
        insert subscription;
        
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].XC_Invoice__c = invoice.Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        List<Case> caseList2 = XC_DF_Case.createCases(1);
        caseList2[0].Status = 'ESTA001';
        caseList2[0].XC_Invoice__c = invoice2.Id;
        caseList2[0].XC_LegalEntity__c = 'EndesaX';
        caseList2[0].XC_Segment__c = 'B2C';
        caseList2.addAll(caseList);
        insert caseList2;
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        listAsset[0].XC_Subscription__c = subscription.Id;
        insert listAsset;
        
        Zuora__InvoiceItem__c itemInvoice = new Zuora__InvoiceItem__c();
        itemInvoice.Zuora__Invoice__c =  invoice.Id;
        itemInvoice.Zuora__Subscription__c = subscription.Id;
        insert itemInvoice;
        
        
        List<Case> cases = [SELECT id FROM Case];
        
        //XC_UTIL_ResultWrapper rw= XC_LCC068_Care_NewCaseByInsistence.suspendActionAsset(cases[0].Id);
        XC_UTIL_ResultWrapper rw5= XC_LCC068_Care_NewCaseByInsistence.suspendActionAsset(caseList2[0].Id);
        Test.stopTest();
        XC_LCC139_DocumentVerification.ResultWrapper rw2 = XC_LCC068_Care_NewCaseByInsistence.documentVerification(cases[0].Id);
        //XC_LCC139_DocumentVerification.ResultWrapper rw3 = XC_LCC068_Care_NewCaseByInsistence.backCompliance(cases[0].Id);
        XC_LCC157_RecalculateUrgency.ResultWrapper rw4 =  XC_LCC068_Care_NewCaseByInsistence.createWorkOrder(cases[0].Id);
        System.assert(rw5!=null);
        
    }
    
    /*
    *@ Description mock class to call getResultPicklistValues 
    */
    public without sharing class getResultPicklistValues_Mock implements HttpCalloutMock {
        public HttpResponse respond (HTTPRequest req){
            HttpResponse response = new HttpResponse();
            
            if(req.getEndpoint() != null && req.getEndpoint().contains('services/oauth2/token')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://salesforce.com","id":"https://test.salesforce.com/id/test/test","token_type":"Bearer","issued_at":"1562317536989","signature":"test"}');
                response.setStatusCode(200); 
                
            } else if(req.getEndpoint() != null && req.getEndpoint().contains('/services/data/v41.0/ui-api/object-info/Case/picklist-values')) {
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"controllerValues":{},"defaultValue":null,"url":"/services/data/v41.0/ui-api/object-info/Case/picklist-values/0125E000000OUFtQAO/XC_Result__c","values":[{"attributes":null,"label":"Inappropriate","validFor":[],"value":"RS001"},{"attributes":null,"label":"Appropriate","validFor":[],"value":"RS002"},{"attributes":null,"label":"Completed","validFor":[],"value":"RS003"},{"attributes":null,"label":"Not completed","validFor":[],"value":"RS004"}]}');
                response.setStatusCode(200); 
            } 
            return response;
        }
    }
    
    /**
    * @description Test Method createCase called from Case
    **/
    @isTest
    static void checkTest_checkSubscriptionAsset(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        cont[0].XC_PrimaryContact__c = false;
        insert cont;
        
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].Status = 'ESTA001';
        caseList[0].Reason = 'XCMOT011';
        caseList[0].SubCause__c = 'ATCL010'; 
        caseList[0].AccountId = acc[0].Id;
        caseList[0].ContactId = cont[0].Id;
        caseList[0].XC_LegalEntity__c = 'EndesaX';
        caseList[0].XC_Segment__c = 'B2C';
        insert caseList;
        List<Case> cases = [SELECT id FROM Case];
        
        Test.startTest();
        XC_UTIL_ResultWrapper rw1= XC_LCC068_Care_NewCaseByInsistence.checkSubscriptionAsset(cases[0].Id);
        XC_LCC068_Care_NewCaseByInsistence.checkItaly(cases[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void checkWorkOrder(){
     
        List<Case> cases = XC_DF_Case.createCases(3);
        cases[0].XC_LegalEntity__c = 'EndesaX';
        cases[0].Reason = 'XCMOT009';
        cases[0].SubCause__c = 'ATCL194';
        cases[0].XC_Subtype__c = 'XC165';
        cases[0].XC_Segment__c = 'B2C';
        cases[1].XC_LegalEntity__c = 'EndesaX';
        cases[1].Reason = 'XCMOT009';
        cases[1].SubCause__c = 'ATCL194';
        cases[1].XC_Subtype__c = 'XC165';
        cases[1].XC_Segment__c = 'B2C';
        insert cases;
        
        Test.startTest();
        List<Asset> newAssets = XC_DF_Asset.createAssets(3);
        newAssets[0].AccountId = cases[0].AccountId;
        newAssets[0].ContactId = cases[0].ContactId;
        newAssets[1].AccountId = cases[1].AccountId;
        newAssets[1].ContactId = cases[1].ContactId;
        newAssets[2].AccountId = cases[2].AccountId;
        newAssets[2].ContactId = cases[2].ContactId;
        insert newAssets;
        
        List<Asset> assets = [SELECT id FROM Asset];
        cases[0].AssetId = assets[0].id;
        cases[1].AssetId = assets[1].id;
        cases[2].AssetId = assets[2].id;
        
        update cases;
        List<Case> caseList = [SELECT Id, Reason, SubCause__c, XC_Subtype__c, XC_Segment__c, CreatedDate, ContactId, Contact.XC_PrimaryContact__c, Contact.AccountId, AccountId, XC_LegalEntity__c, AssetId FROM Case];
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(3,'Planned Maintenance');
        wo[0].Status = 'Completed';
        wo[0].AssetId =caseList[0].AssetId;
        wo[1].AssetId =caseList[1].AssetId;
        wo[2].AssetId =caseList[2].AssetId;
        insert wo;
               
        boolean result1 = XC_LCC068_Care_NewCaseByInsistence.checkWorkOrder(caseList[0]);
        boolean result2 = XC_LCC068_Care_NewCaseByInsistence.checkWorkOrder(caseList[1]);
        boolean result3 = XC_LCC068_Care_NewCaseByInsistence.checkWorkOrder(caseList[2]);
        system.assert(result1);
        system.assert(!result2);
        system.assert(!result3);
        Test.stopTest();
    }
}
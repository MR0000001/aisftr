@isTest
private class XC_REST_DigitalSignature_Test {

    @testSetup
    static void setupData() {
        insert new NE__Order__c();
		WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        woli.WorkOrderId = workOrderTest.Id;
        woli.XC_RequestType__c ='Sospensione';
        insert woli;
        
    }

    @isTest
    static void startSignResponseTest() {
        NE__Order__c o = [SELECT Id FROM NE__Order__c];
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'AXYZ');
		System.RestContext.request = request;
        System.RestContext.request.requestBody = Blob.valueOf('{}');
            
        Test.startTest();
        List<Map<String,String>> fileItem = new List<Map<String,String>>();
        Map<String,String> m = new Map<String,String>();
        m.put('dossier_id','a_sd');
        fileItem.add(m);
        XC_REST_DigitalSignature.Response res = XC_REST_DigitalSignature.startSignResponse(fileItem);
        Test.stopTest();

        System.assert(res.result != null);
    }

    @isTest
    static void callbackPostTest() {
        NE__Order__c o = [SELECT Id FROM NE__Order__c];
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'AXYZ');
        System.RestContext.request = request;
        System.RestContext.request.requestBody = Blob.valueOf('{}');
        
        List<Map<String,String>> fileItem = new List<Map<String,String>>();
        Map<String,String> m = new Map<String,String>();
        m.put('dossier_id','a_'+o.id);
        m.put('signature_phase','1');
        m.put('status','STEP_CLOSED');
        fileItem.add(m);

        XC_REST_DigitalSignature.Response ress = XC_REST_DigitalSignature.startSignResponse(fileItem);

        Test.startTest();
        XC_REST_DigitalSignature.Response res = XC_REST_DigitalSignatureCallback.callbackPost(fileItem);
        Test.stopTest();

        System.assert(res.result != null);
    }
    
    @isTest
    static void callbackPostTest2() {
        NE__Order__c o = [SELECT Id FROM NE__Order__c];
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'AXYZ');
        System.RestContext.request = request;
        System.RestContext.request.requestBody = Blob.valueOf('{}');
        
        List<Map<String,String>> fileItem = new List<Map<String,String>>();
        Map<String,String> n = new Map<String,String>();
        n.put('dossier_id','a_'+o.id);
        n.put('signature_phase','2');
        n.put('status','STEP_CLOSED');
        fileItem.add(n);
        Map<String,String> b = new Map<String,String>();
        b.put('dossier_id','a_'+o.id);
        b.put('signature_phase','2');
        b.put('status','ENVELOPE_REJECTED'); //CR729 04.07.2022
        fileItem.add(b);

        Test.startTest();
        XC_REST_DigitalSignature.Response res = XC_REST_DigitalSignatureCallback.callbackPost(fileItem);
        Test.stopTest();

        System.assert(res.result != null);
    }
    
     @isTest
    static void callbackPostTest3() {
        NE__Order__c o = [SELECT Id FROM NE__Order__c];
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'AXYZ');
        System.RestContext.request = request;
        System.RestContext.request.requestBody = Blob.valueOf('{}');
        
        List<Map<String,String>> fileItem = new List<Map<String,String>>();

        Map<String,String> a = new Map<String,String>();
        a.put('dossier_id','a_'+o.id);
        a.put('signature_phase','1');
        a.put('status','ENVELOPE_REJECTED'); //CR729 04.07.2022
        fileItem.add(a);
        Map<String, XC_DocumentSignature__c> mapD = new Map<String, XC_DocumentSignature__c>();
        Test.startTest();
        XC_REST_DigitalSignature.Response res = XC_REST_DigitalSignatureCallback.callbackPost(fileItem);
        Test.stopTest();

        System.assert(res.result != null);
    }
    
     @isTest
    static void sentNotif() {
        
        NE__Order__c o = [SELECT Id FROM NE__Order__c];
        WorkOrderLineItem woli = [SELECT Id,XC_RequestType__c FROM WorkOrderLineItem];
        XC_DocumentSignature__c docSign=new XC_DocumentSignature__c();
        docSign.XC_Order__c=o.id;
        docSign.XC_SignerId__c=o.id;
        docSign.XC_Status__c='test';
        docSign.XC_Step__c='3';
        docSign.XC_DossierId__c='112';
        docSign.XC_WorkOrderLineItem__c=woli.id ;
        insert docSign;
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'AXYZ');
        System.RestContext.request = request;
        System.RestContext.request.requestBody = Blob.valueOf('{}');
        
        List<Map<String,String>> fileItem = new List<Map<String,String>>();

        Map<String,String> a = new Map<String,String>();
        a.put('dossier_id','a_'+o.id);
        a.put('signature_phase','1');
        a.put('status','ENVELOPE_REJECTED'); //CR729 04.07.2022
        fileItem.add(a);
        Map<String, XC_DocumentSignature__c> mapD = new Map<String, XC_DocumentSignature__c>();
        mapD.put(docsign.XC_DossierId__c,docsign);
        Test.startTest();
        XC_REST_DigitalSignatureCallback.sentNotification(mapD,'2');
        XC_REST_DigitalSignatureCallback.sentNotification(mapD,'4');
        test.stopTest();
        
        
    }

    @isTest
    static void callbackPostTest4() {
        WorkOrderLineItem woli = [SELECT Id,XC_RequestType__c FROM WorkOrderLineItem];
        XC_DocumentSignature__c docSign=new XC_DocumentSignature__c();
        docSign.XC_Status__c='test';
        docSign.XC_Step__c='3';
        docSign.XC_DossierId__c='112';
        docSign.XC_WorkOrderLineItem__c=woli.id ;
        insert docSign;
        RestContext.response = new System.RestResponse();
        RestRequest request = new RestRequest();
        request.addHeader('TransactionID', 'AXYZ');
        System.RestContext.request = request;
        System.RestContext.request.requestBody = Blob.valueOf('{}');
        
        List<Map<String,String>> fileItem = new List<Map<String,String>>();

        Map<String,String> a = new Map<String,String>();
        a.put('dossier_id','112');
        a.put('signature_phase','1');
        a.put('status','ENVELOPE_REJECTED');
        fileItem.add(a);
        Map<String, XC_DocumentSignature__c> mapD = new Map<String, XC_DocumentSignature__c>();
        mapD.put(docsign.XC_DossierId__c,docsign);
        Test.startTest();
        XC_REST_DigitalSignature.Response res = XC_REST_DigitalSignatureCallback.callbackPost(fileItem);
        test.stopTest();
        
        
    }
}
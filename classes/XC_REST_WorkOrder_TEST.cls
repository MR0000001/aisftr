@isTest
public with sharing class XC_REST_WorkOrder_TEST { 

    @TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;

    }
 
    static testMethod void emptyRequest(){
        
        Map<String,String> params = new Map<String,String>();

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');

        test.startTest();

        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        XC_REST_WorkOrder_W.Wrapper body = new XC_REST_WorkOrder_W.Wrapper();
        System.RestContext.request.requestBody = Blob.valueOf(JSON.serializePretty(body));

        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void internalError(){
        
        Map<String,String> params = new Map<String,String>();

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');

        test.startTest();

        XC_REST_WorkOrder_W.Wrapper body = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        wo.WorkType = 'test';
        body.WorkOrder = wo;
         
        System.RestContext.request.requestBody = Blob.valueOf((JSON.serializePretty(body)).replace('"test"',','));

        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void getWOById(){
        
        Map<String,String> params = new Map<String,String>();

        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');

        test.startTest();

        //error on validate
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //error on validate
        System.RestContext.request = generateGETWORequest(params, 'err');
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //ok id
        params.put('WorkOrderID', [select id from workorder][0].id);
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //error on read
        delete [select id from workorder];
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void getWOByNumb(){
        
        Map<String,String> params = new Map<String,String>();

        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        insert w;
        WorkOrderLineItem wli = new WorkOrderLineItem();
        wli.WorkOrderId = w[0].id;
        insert wli;
        List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(w);
        insert sa;
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');

        test.startTest();

        //ok numb
        params.put('WorkOrderNumber', [select id, WorkOrderNumber from workorder][0].WorkOrderNumber);
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void getWOByServRes(){
        
        Map<String,String> params = new Map<String,String>();
        WorkOrder w = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit')[0];
        insert w;
        RestContext.response = new System.RestResponse();

        test.startTest();

        params.put('ServiceResourceID', [select id from workorder][0].id);
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 

        params.put('StartDate', '2010-10-10');
        params.put('EndDate', '2020-10-10');
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 

        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void getWOByAssetAcc(){
        
        Map<String,String> params = new Map<String,String>();

        WorkOrder w = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit')[0];
        List<Asset> a = XC_DF_Asset.createAssets(1);
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert a;
        insert acc;

        //XC_DF_ServiceResource.createServiceResources(1);

        w.AssetId = a[0].id;
        insert w;
        
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');

        test.startTest();

        //error on validate
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //ok id
        params.put('AssetID', [select id from Asset][0].id);
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        params.remove('AssetID');
        params.put('AccountID', acc[0].id);
        params.put('StartDate', '2010-10-10');
        params.put('EndDate', '2020-10-10');
        System.RestContext.request = generateGETWORequest(params, 'WorkOrder');
        XC_REST_WorkOrder.doGet(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void getSlotByWONUMB(){
        
        Map<String,String> params = new Map<String,String>();

        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');

        XC_CM_Scheduling_Default_Value__mdt metad = [select id, XC_Policy_Name__c, XC_Operating_Hours_Name__c
                                                    from XC_CM_Scheduling_Default_Value__mdt][0];

        FSL__Scheduling_Policy__c p = new FSL__Scheduling_Policy__c();
        p.Name = metad.XC_Policy_Name__c;
        insert p;

        OperatingHours o = new OperatingHours();
        o.Name = metad.XC_Operating_Hours_Name__c;
        insert o;
        
        RestContext.response = new System.RestResponse();
        //System.RestContext.request = generateGETWORequest(params);

        test.startTest();

        //ok
        params.put('WorkOrderNumber', [select id, WorkOrderNumber from workorder][0].WorkOrderNumber);
        params.put('AppointmentSlotDate', '2019-05-13');
        System.RestContext.request = generateGETWORequest(params, 'Slot');
        XC_REST_WorkOrder.doGet(); 
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void getSlotByWOID(){
        
        Map<String,String> params = new Map<String,String>();

        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');

        XC_CM_Scheduling_Default_Value__mdt metad = [select id, XC_Policy_Name__c, XC_Operating_Hours_Name__c
                                                    from XC_CM_Scheduling_Default_Value__mdt][0];

        FSL__Scheduling_Policy__c p = new FSL__Scheduling_Policy__c();
        p.Name = metad.XC_Policy_Name__c;
        insert p;

        OperatingHours o = new OperatingHours();
        o.Name = metad.XC_Operating_Hours_Name__c;
        insert o;
        
        RestContext.response = new System.RestResponse();
        //System.RestContext.request = generateGETWORequest(params);

        test.startTest();

        //error on validate
        System.RestContext.request = generateGETWORequest(params, 'Slot');
        XC_REST_WorkOrder.doGet(); 
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(RestContext.response.statusCode, 200);

        //error on validate
        params.put('WorkOrderID', [select id from workorder][0].id);
        System.RestContext.request = generateGETWORequest(params, 'Slot');
        XC_REST_WorkOrder.doGet(); 
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(RestContext.response.statusCode, 200);

        //ok
        params.put('AppointmentSlotDate', '2019-05-13');
        System.RestContext.request = generateGETWORequest(params, 'Slot');
        XC_REST_WorkOrder.doGet(); 
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(RestContext.response.statusCode, 200);

        //error on validate
        params.put('WorkOrderNumber', '1');
        System.RestContext.request = generateGETWORequest(params, 'Slot');
        XC_REST_WorkOrder.doGet(); 
        system.debug(RestContext.response.responseBody.toString());
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void postWO(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper woli = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');

        woli.Status = 'test';
        wo.WorkOrderLineItem = new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        wo.WorkOrderLineItem.add(woli);
        sa.DueDate = dateTime.now();
        sa.EarliestStartPermitted = dateTime.now(); 
        wo.ServiceAppointment = new List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
        wo.ServiceAppointment.add(sa); 

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');

        test.startTest();

        //error on validate 
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        
        //error on validate 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'err', 'WorkOrder');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 
   
        //error on validate 
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //error on validate 
        wo.WorkType = 'test';
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //error on validate 
        wo.WorkType = 'Commercial Visit';
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //ok
        wo.LegalEntity = 'test';
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        //error on validate 
        wo.ParentWorkOrderNumber = '123';
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200);
        
        XC_UTIL_WorkOrder.WorkOrderWrapper wo1 = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        wo1.LegalEntity = 'test';
        wo1.WorkType = 'Commercial Visit';
        params.WorkOrder = wo1; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
        XC_REST_WorkOrder.doPost(); 

        test.stopTest();
    }
    
    static testMethod void postWO1(){
                XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper woli = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
    	XC_UTIL_WorkOrder.WorkOrderWrapper wo1 = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        wo1.LegalEntity = [select XC_LegalEntity__c from workorder][0].XC_LegalEntity__c;
        wo1.WorkType = [select XC_WorkTypeLabel__c from workorder][0].XC_WorkTypeLabel__c;
        params.WorkOrder = wo1; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'WorkOrder');
        System.RestContext.request.addHeader('Operation', 'CreateWorkOrder');
        test.startTest();

        XC_REST_WorkOrder.doPost(); 
        test.stopTest();
    }


    static testMethod void postAPPByWO(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper bo = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');

        XC_CM_Scheduling_Default_Value__mdt metad = [select id, XC_Policy_Name__c, XC_Operating_Hours_Name__c
                                                    from XC_CM_Scheduling_Default_Value__mdt][0];

        FSL__Scheduling_Policy__c p = new FSL__Scheduling_Policy__c();
        p.Name = metad.XC_Policy_Name__c;
        insert p;

        OperatingHours o = new OperatingHours();
        o.Name = metad.XC_Operating_Hours_Name__c;
        insert o;  
        
        bo.TimeSlotBegin = datetime.now();
        bo.TimeSlotFinish = datetime.now();
        bo.StartDate = datetime.now();

        RestContext.response = new System.RestResponse();

        test.startTest();

        //validate error
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'APP');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        //validate error
        params.BookAppointment = bo;
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'APP');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        //ok
        bo.WorkOrderID = [select id from workorder][0].id;
        params.BookAppointment = bo;
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'APP');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        //validate error
        bo.LeadID = [select id from workorder][0].id;
        params.BookAppointment = bo;
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'APP');
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void postAPPByLEAD(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper bo = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        insert XC_DF_Lead.createResidentialLead();

        XC_CM_Scheduling_Default_Value__mdt metad = [select id, XC_Policy_Name__c, XC_Operating_Hours_Name__c
                                                    from XC_CM_Scheduling_Default_Value__mdt][0];

        FSL__Scheduling_Policy__c p = new FSL__Scheduling_Policy__c();
        p.Name = metad.XC_Policy_Name__c;
        insert p;

        OperatingHours o = new OperatingHours();
        o.Name = metad.XC_Operating_Hours_Name__c;
        insert o;  

        bo.LeadID = [select id from Lead][0].id;
        bo.TimeSlotBegin = datetime.now();
        bo.TimeSlotFinish = datetime.now();
        bo.StartDate = datetime.now();
        params.BookAppointment = bo;

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'APP');

        test.startTest();

        //ok
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void postAPPByOPP(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper bo = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        insert XC_DF_Opportunity.createOpportunity(1, true);

        XC_CM_Scheduling_Default_Value__mdt metad = [select id, XC_Policy_Name__c, XC_Operating_Hours_Name__c
                                                    from XC_CM_Scheduling_Default_Value__mdt][0];

        FSL__Scheduling_Policy__c p = new FSL__Scheduling_Policy__c();
        p.Name = metad.XC_Policy_Name__c;
        insert p;

        OperatingHours o = new OperatingHours();
        o.Name = metad.XC_Operating_Hours_Name__c;
        insert o;  

        bo.OpportunityID = [select id from Opportunity][0].id;
        bo.TimeSlotBegin = datetime.now();
        bo.TimeSlotFinish = datetime.now();
        bo.StartDate = datetime.now();
        params.BookAppointment = bo;

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'POST', 'APP');

        test.startTest();

        //ok
        XC_REST_WorkOrder.doPost(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }

    static testMethod void putWOwithChild(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper woli = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();

        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        insert w;
        List<ServiceAppointment> sap = XC_DF_ServiceAppointment.createServiceAppointment(w);
        insert sap;

        wo.WorkType = 'Commercial Visit';
        wo.LegalEntity = 'test';
        woli.Status = 'test';
        wo.WorkOrderLineItem = new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        wo.WorkOrderLineItem.add(woli);
        sa.DueDate = dateTime.now();
        sa.EarliestStartPermitted = dateTime.now(); 
        wo.ServiceAppointment = new List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
        wo.ServiceAppointment.add(sa); 

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder');

        test.startTest();

        //error on validate 
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        //error on validate 
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder');
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 
   
        //error on insert
        wo.WorkOrderID = [select id from workorder][0].id;
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder');
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void putWO(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();

        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        insert w;
        List<ServiceAppointment> sap = XC_DF_ServiceAppointment.createServiceAppointment(w);
        insert sap;

        wo.WorkType = 'Site Inspection - Photovoltaic';
        wo.LegalEntity = 'EndesaX';

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder');

        test.startTest();

        //ok
        wo.WorkOrderID = [select id from workorder][0].id;
        params.WorkOrder = wo; 
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder');
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();

    }
    
    static testMethod void putWOwithChild1(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();

        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        insert w;
        List<ServiceAppointment> sap = XC_DF_ServiceAppointment.createServiceAppointment(w);
        insert sap;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workorderid = w[0].id;
        insert woli;

        wo.WorkType = 'Site Inspection - Photovoltaic';
        wo.LegalEntity = 'EndesaX';

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder');

        test.startTest();

        //ok
        wo.WorkOrderID = [select id from workorder][0].id;
        params.WorkOrder = wo; 
        params.WorkOrder.ServiceAppointment = new List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper wrsa = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        wrsa.ServiceAppointmentID=sap[0].id;
        params.WorkOrder.ServiceAppointment.add(wrsa);
        params.WorkOrder.WorkOrderLineItem = new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wrwoli = new  XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        wrwoli.WorkOrderLineItemNumber = [select id, LineItemNumber from workorderlineitem][0].LineItemNumber;
        params.WorkOrder.WorkOrderLineItem.add(wrwoli);
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder');
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();

    }

    static testMethod void putWOerrorOnWoli(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper woli = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');

        wo.WorkOrderID = [select id from workorder][0].id;
        wo.WorkType = 'Commercial Visit';
        wo.LegalEntity = 'test';
        woli.Status = 'test';
        woli.WorkOrderLineItemNumber = '123';
        wo.WorkOrderLineItem = new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        wo.WorkOrderLineItem.add(woli);
        sa.DueDate = dateTime.now();
        sa.EarliestStartPermitted = dateTime.now(); 
        wo.ServiceAppointment = new List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
        wo.ServiceAppointment.add(sa);
        params.WorkOrder = wo; 
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder'); 

        test.startTest();
   
        //ok
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void putWOerrorOnSa(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_WorkOrder.WorkOrderWrapper wo = new XC_UTIL_WorkOrder.WorkOrderWrapper();
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper woli = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper sa = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();
        insert XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');

        wo.WorkOrderID = [select id from workorder][0].id;
        wo.WorkType = 'Commercial Visit';
        wo.LegalEntity = 'test';
        woli.Status = 'test';
        wo.WorkOrderLineItem = new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        wo.WorkOrderLineItem.add(woli);
        sa.AppointmentNumber = '123';
        sa.DueDate = dateTime.now();
        sa.EarliestStartPermitted = dateTime.now(); 
        wo.ServiceAppointment = new List<XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper>();
        wo.ServiceAppointment.add(sa);
        params.WorkOrder = wo; 
        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'WorkOrder'); 

        test.startTest();
   
        //ok
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200);

        test.stopTest();
    }

    static testMethod void putAPP(){
        
        XC_REST_WorkOrder_W.Wrapper params = new XC_REST_WorkOrder_W.Wrapper();
        XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper bo = new XC_UTIL_ServiceAppointment.ServiceAppointmentWrapper();

        List<WorkOrder> w = XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        insert w;
        List<ServiceAppointment> sa = XC_DF_ServiceAppointment.createServiceAppointment(w);
        insert sa;

        bo.ServiceAppointmentID = sa[0].id;
        bo.TimeSlotBegin = datetime.now();
        bo.TimeSlotFinish = datetime.now();

        RestContext.response = new System.RestResponse();
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'APP');

        test.startTest();

        //error on validate
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        //error on validate
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'err', 'APP');
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        //error on validate2
        params.BookAppointment = bo;
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'APP');
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        //error on insert
        bo.StartDate = datetime.now();
        params.BookAppointment = bo;
        System.RestContext.request = generatePOSTorPUTWORequest(params, 'PUT', 'APP');
        XC_REST_WorkOrder.doPut(); 
        system.assertEquals(RestContext.response.statusCode, 200); 

        test.stopTest();
    }
    
    static testMethod void testQuery(){
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Map<String, String> params = new Map<String, String>();
        params.put('AccountID',acc[0].id);
        params.put('Email',acc[0].id);
        params.put('StartDate','2020-01-01');
        params.put('EndDate','2020-02-01');
        
    	test.startTest();
        XC_REST_WorkOrder_U_D.getWorkOrderByAccount(acc[0].id);
        XC_REST_WorkOrder_U_D.getWorkOrderByLeadEmail('asd');
        XC_REST_WorkOrder_U_D.getWoByLeadOrAccount(params);
        XC_REST_WorkOrder_U_D.getWoByLeadOrAccountWithDates(params);
        XC_REST_WorkOrder_U_D.getWorkOrderByLeadEmailAndDates(params.get('Email'),Date.valueOf(params.get('StartDate')),Date.valueOf(params.get('EndDate')));
        test.stopTest();
    }

    private static RestRequest generatePOSTorPUTWORequest(XC_REST_WorkOrder_W.Wrapper params, String method, String operation){

        RestRequest request = new RestRequest();
		
       	request.httpMethod = method;
    	request.requestURI = '/v1/WorkOrder/*';

        if(method=='POST' && operation =='WorkOrder'){
            request = addHeader(request, XC_REST_WorkOrder.POST_WO_OPERATION_LABEL);
        } else if(method=='PUT' && operation =='WorkOrder'){
            request = addHeader(request, XC_REST_WorkOrder.PUT_WO_OPERATION_LABEL);
        } else if(method=='POST' && operation =='APP'){
            request = addHeader(request, XC_REST_WorkOrder.POST_APP_OPERATION_LABEL);
        } else if(method=='PUT' && operation =='APP'){
            request = addHeader(request, XC_REST_WorkOrder.PUT_APP_OPERATION_LABEL);
        } else {
            request = addHeader(request, 'test');
        }

        request.requestBody = Blob.valueOf(JSON.serializePretty(params));

        return request;
    }

    private static RestRequest generateGETWORequest(Map<String,String> params, String operation){

        RestRequest request = new RestRequest();
		
       	request.httpMethod = 'GET';
    	request.requestURI = '/v1/WorkOrder/*';

        if(operation == 'WorkOrder'){
            request = addHeader(request, XC_REST_WorkOrder.GET_WO_OPERATION_LABEL);
        } else if(operation == 'Slot'){
            request = addHeader(request, XC_REST_WorkOrder.GET_APP_OPERATION_LABEL);
        } else {
            request = addHeader(request, 'err');
        }

        for (String s : params.keySet()){
            request.addParameter(s, params.get(s));
        }

        return request;
    }

    private static RestRequest addHeader(RestRequest request, String operation){
		request.addHeader('TransactionID', 'AXYZ');
		request.addHeader('DateTimeMessage', '20181207103900000');
		request.addHeader('Operation', operation);
		request.addHeader('Functionality', 'AXYZ');
		request.addHeader('ClientSystem', 'AXYZ');
		request.addHeader('ServerSystem', 'AXYZ');
        request.addHeader('debugMode', 'AXYZ');
        return request;
    }

}
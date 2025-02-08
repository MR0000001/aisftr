/*
@CreatedBy      - Fabrizio Fiorentini (Fabrizio.Fiorentini@webresults.it), 2020/10/20
@Description    - Class test for TA_LCC199_ButtonSection
@Updated        - 07/01/2020 new commit [AR]
*/
@isTest
public without sharing class TA_LCC199_ButtonSection_Test {

    private static List<WorkOrder> createWorkOrders(Integer numberOfWo, String workTypeName) {
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        
        WorkType workTypeToInsert = new WorkType();
        workTypeToInsert.Name = 'Commercial Visit - Boiler';
        workTypeToInsert.RecordTypeId = Schema.SObjectType.WorkType.getRecordTypeInfosByDeveloperName().get('CHL').getRecordTypeId();
        workTypeToInsert.XC_LegalEntity__c = 'Codensa';
        workTypeToInsert.XC_WorkTypeCategory__c = 'Repair';
        workTypeToInsert.DurationType = Label.XC_CL_WorkType_Hours;
        workTypeToInsert.EstimatedDuration = 1;
        insert workTypeToInsert;

        insert XC_DF_Address.createAddress(1);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        for (Integer i=0; i<numberOfWO; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeCategory__c = workTypeName;
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
        	workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_Digitized__c = true;
            workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            workOrderList.add(workOrderToInsert);
        }
        return workOrderList;
    }

    @isTest
    static void setButton_Test() {
        TA_LCC199_ButtonSection.ApexActionWrapper instance = new TA_LCC199_ButtonSection.ApexActionWrapper();
        TA_LCC199_ButtonSection.ButtonWrapper instance2 = new TA_LCC199_ButtonSection.ButtonWrapper();

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.TA_Phase__c = 'PreService_Lock';
        insert workOrderTest;

        TA_Phase_Configuration__c newPhase = new TA_Phase_Configuration__c();
        newPhase.TA_DeveloperName__c = 'PreService_Lock';
        newPhase.TA_Hidden__c = false;
        newPhase.TA_External_Id__c = 'test';
        insert newPhase;

        TA_Action_Configuration__c actionConf = new TA_Action_Configuration__c();
        actionConf.TA_Type__c = 'Closing';
        actionConf.TA_DeveloperName__c = 'CloseService';
        actionConf.TA_External_Id__c = 'test';
        insert actionConf;

        TA_Layout_Matrix_Configuration__c newCapability = new TA_Layout_Matrix_Configuration__c();
        newCapability.TA_ConfigurationSet__c = 'dummy';
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkTypeCategory__c = workOrderTest.XC_WorkTypeCategory__c;
        newCapability.TA_Action__c = actionConf.Id;
        newCapability.TA_IndexAction__c = 1;
        newCapability.TA_IndexPhase__c = 2;
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_External_Id__c = 'test';
        insert newCapability;

        Test.startTest();
        TA_LCC199_ButtonSection.setButton(workOrderTest.Id, 2);
        Test.stopTest();
    }

    @isTest
    static void manageApexAction_Test_customerInteraction() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        TA_LCC199_ButtonSection.ApexActionWrapper ddddd = new TA_LCC199_ButtonSection.ApexActionWrapper();
        TA_LCC199_ButtonSection.ButtonWrapper btnWrpEmpty = new TA_LCC199_ButtonSection.ButtonWrapper();

        String json1 = '[{"name":"customerInteraction","parameters":[{"CustomerInteraction":{"Email":"","Channel":"Email","CommunicationType":"WorkOrder_DelayTravel","ServiceAppointmentID":"'+serviceApp.Id+'","AccountID":"","WorkOrderID":"","LegalEntity":"","ContactID":""}}]}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, json1 , '', false);
        Test.stopTest();
    }

    /* @isTest
    static void manageApexAction_Test_redirectToFLS() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        TA_Phase_Configuration__c newPhase = new TA_Phase_Configuration__c();
        newPhase.TA_DeveloperName__c = 'checkIn';
        newPhase.TA_Hidden__c = false;
        newPhase.TA_External_Id__c = 'test';
        insert newPhase;

        TA_Action_Configuration__c actionConf = new TA_Action_Configuration__c();
        actionConf.TA_Type__c = 'Closing';
        actionConf.TA_DeveloperName__c = 'CloseService';
        actionConf.TA_External_Id__c = 'test';
        insert actionConf;

        TA_Layout_Matrix_Configuration__c newCapability = new TA_Layout_Matrix_Configuration__c();
        newCapability.TA_ConfigurationSet__c = 'Italy_Set';
        newCapability.TA_Active__c = true;
        newCapability.TA_WorkTypeCategory__c = 'Repair';
        newCapability.TA_Action__c = actionConf.Id;
        newCapability.TA_IndexAction__c = 1;
        newCapability.TA_IndexPhase__c = 2;
        newCapability.TA_Phase__c = newPhase.Id;
        newCapability.TA_External_Id__c = 'test';
        insert newCapability;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        workOrderTest.AccountId = accountToInsert.Id;
        update workOrderTest;

        String jsonTest = '[{"name":"redirectToFLS","parameters":[{}]}]';

        test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , newPhase.TA_DeveloperName__c, true);
        test.stopTest();
    } */

    @isTest
    static void manageApexAction_updateFields_Test() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        String jsonTest = '[{"name":"updateFields","parameters":[{"cmpName":"TA_LCP2020_DynamicLayout","objectName":"WorkOrder","fields":[{"apiName":"XC_WorkTypeCategory__c","value":"Repair","type":"TEXT"}]}]}]';

        test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        test.stopTest();
    }

    @isTest
    static void manageApexAction_leadConversion_Test() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        List<TA_LCC199_ButtonSection.ApexActionWrapper> awList = new List<TA_LCC199_ButtonSection.ApexActionWrapper>();
        TA_LCC199_ButtonSection.ApexActionWrapper aw = new TA_LCC199_ButtonSection.ApexActionWrapper();
        aw.Name = 'leadConversion';
        LIst<XC_Address__c> add = XC_DF_Address.createAddress(1);
        insert add;
        Map<String,Object> mappa = new Map<String,Object>();
        TA_LCC220_LeadConversion.InfoBag infoBag = new TA_LCC220_LeadConversion.InfoBag();
        infoBag.objectName = 'Account';
        infoBag.lookupObjectName = 'Lead';
        infoBag.fieldStructureList = new List<TA_LCC220_LeadConversion.FieldStructure>();
        infoBag.newAddress = false;
        infoBag.relatedAddress = new XC_Address__c(Id = add.get(0).Id);
        Map<String,Object> serializedAddress = new Map<String,Object>();
        serializedAddress.put('country','Spain');
        serializedAddress.put('address','test');
        serializedAddress.put('streetNumber','test');
        serializedAddress.put('door','test');
        serializedAddress.put('postalCode','test');
        serializedAddress.put('stair','test');
        serializedAddress.put('floor','test');
        serializedAddress.put('city','test');
        serializedAddress.put('province','test');
        serializedAddress.put('category','test');
        serializedAddress.put('municipality','test');
        serializedAddress.put('streetTypeText','test');
        serializedAddress.put('gas','test');
        serializedAddress.put('electric','test');
        serializedAddress.put('account','test');
        serializedAddress.put('lead','test');
        serializedAddress.put('region','test');
        serializedAddress.put('clarifType',null);
        serializedAddress.put('clarifValue','test');
        serializedAddress.put('note','test');
        TA_LCC220_LeadConversion.FieldStructure fs = new TA_LCC220_LeadConversion.FieldStructure();
        fs.apiName = 'FirstName';
        fs.value = 'Test';
        infoBag.fieldStructureList.add(fs);
        mappa.put('serializedAddress',JSON.serialize(serializedAddress));
        mappa.put('serializedInfoBag',JSON.serialize(infoBag));
        mappa.put('hasChanged',false);

        aw.parameters = new List<Map<String,Object>>{mappa};
        String jsonTest = '[{"name":"leadConversion","parameters":"[{serializedInfoBag: \\"{\\"objectName\\":\\"Account\\",\\"modalParams\\":{\\"title\\":\\"valueTestt\\",\\"apiName\\":\\"BillingPostalCode\\"}}, \\"hasChanged\\":\\"false\\"}]"}]';
        awList.add(aw);
        test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, JSON.serialize(awList) , null, false);
        test.stopTest();
    }

    @isTest
    static void manageProvisioning_Test() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        String jsonTest = '[{"name":"manageProvisioning","parameters":{"id":"'+workOrderTest.Id+'"}}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_Test() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        String jsonTest = '[{"name":"updateWorkOrder","parameters":"{\\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_GPS_Test() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;
        
        String jsonTest = '[{"name":"updateWorkOrder_GPS","parameters":"{\\"Coordinates\\": { \\"Latitude\\": { \\"apiName\\": \\"TA_Take_Charge_Latitude__c\\", \\"value\\": \\"' + 28.45 + '\\"}, \\"Longitude\\": { \\"apiName\\": \\"TA_Take_Charge_Longitude__c\\", \\"value\\": \\"' + 24.45 + '\\" }, \\"Accuracy\\": { \\"apiName\\": \\"TA_Take_Charge_Accuracy__c\\", \\"value\\": \\"' + 38.45 + '\\" }}, \\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_Test2() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'Assigned';
        insert workOrderChildTest;   

        String jsonTestChild = '[{"name":"updateWorkOrder","parameters":"{\\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":' + null + ',\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_Test3() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'Assigned';
        insert workOrderChildTest;   

        WorkOrder workOrderChildTest2 = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest2.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest2.AccountId = accountToInsert.Id;
        workOrderChildTest2.Status = 'Assigned';
        insert workOrderChildTest2;   

        String jsonTestChild = '[{"name":"updateWorkOrder","parameters":"{\\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":' + null + ',\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_Test4() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'In Progress';
        insert workOrderChildTest;   

        WorkOrder workOrderChildTest2 = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest2.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest2.AccountId = accountToInsert.Id;
        workOrderChildTest2.Status = 'Assigned';
        insert workOrderChildTest2;   

        String jsonTestChild = '[{"name":"updateWorkOrder","parameters":"{\\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"Completed\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":' + null + ',\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_Tesst5() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'In Progress';
        insert workOrderChildTest;   

        WorkOrder workOrderChildTest2 = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest2.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest2.AccountId = accountToInsert.Id;
        workOrderChildTest2.Status = 'Completed';
        insert workOrderChildTest2;   

        String jsonTestChild = '[{"name":"updateWorkOrder","parameters":"{\\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"Completed\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":' + null + ',\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_GPS_Test2() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'Assigned';
        insert workOrderChildTest;   

        String jsonTestChild = '[{"name":"updateWorkOrder_GPS","parameters":"{\\"Coordinates\\": { \\"Latitude\\": { \\"apiName\\": \\"TA_Take_Charge_Latitude__c\\", \\"value\\": \\"' + 28.45 + '\\"}, \\"Longitude\\": { \\"apiName\\": \\"TA_Take_Charge_Longitude__c\\", \\"value\\": \\"' + 24.45 + '\\" }, \\"Accuracy\\": { \\"apiName\\": \\"TA_Take_Charge_Accuracy__c\\", \\"value\\": \\"' + 38.45 + '\\" }}, \\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_GPS_Test3() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'Assigned';
        insert workOrderChildTest;   

        WorkOrder workOrderChildTest2 = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest2.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest2.AccountId = accountToInsert.Id;
        workOrderChildTest2.Status = 'Assigned';
        insert workOrderChildTest2;   

        String jsonTestChild = '[{"name":"updateWorkOrder_GPS","parameters":"{\\"Coordinates\\": { \\"Latitude\\": { \\"apiName\\": \\"TA_Take_Charge_Latitude__c\\", \\"value\\": \\"' + 28.45 + '\\"}, \\"Longitude\\": { \\"apiName\\": \\"TA_Take_Charge_Longitude__c\\", \\"value\\": \\"' + 24.45 + '\\" }, \\"Accuracy\\": { \\"apiName\\": \\"TA_Take_Charge_Accuracy__c\\", \\"value\\": \\"' + 38.45 + '\\" }}, \\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_GPS_Test4() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'In Progress';
        insert workOrderChildTest;   

        WorkOrder workOrderChildTest2 = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest2.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest2.AccountId = accountToInsert.Id;
        workOrderChildTest2.Status = 'Assigned';
        insert workOrderChildTest2;   

        String jsonTestChild = '[{"name":"updateWorkOrder_GPS","parameters":"{\\"Coordinates\\": { \\"Latitude\\": { \\"apiName\\": \\"TA_Take_Charge_Latitude__c\\", \\"value\\": \\"' + 28.45 + '\\"}, \\"Longitude\\": { \\"apiName\\": \\"TA_Take_Charge_Longitude__c\\", \\"value\\": \\"' + 24.45 + '\\" }, \\"Accuracy\\": { \\"apiName\\": \\"TA_Take_Charge_Accuracy__c\\", \\"value\\": \\"' + 38.45 + '\\" }}, \\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"Completed\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrder_GPS_Test5() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        WorkOrder workOrderChildTest = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest.AccountId = accountToInsert.Id;
        workOrderChildTest.Status = 'In Progress';
        insert workOrderChildTest;   

        WorkOrder workOrderChildTest2 = createWorkOrders(1, 'Commercial Visit')[0];
        workOrderChildTest2.ParentWorkOrderId = workOrderTest.Id;
        workOrderChildTest2.AccountId = accountToInsert.Id;
        workOrderChildTest2.Status = 'Completed';
        insert workOrderChildTest2;   

        String jsonTestChild = '[{"name":"updateWorkOrder_GPS","parameters":"{\\"Coordinates\\": { \\"Latitude\\": { \\"apiName\\": \\"TA_Take_Charge_Latitude__c\\", \\"value\\": \\"' + 28.45 + '\\"}, \\"Longitude\\": { \\"apiName\\": \\"TA_Take_Charge_Longitude__c\\", \\"value\\": \\"' + 24.45 + '\\" }, \\"Accuracy\\": { \\"apiName\\": \\"TA_Take_Charge_Accuracy__c\\", \\"value\\": \\"' + 38.45 + '\\" }}, \\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderChildTest.Id + '\\",\\"Status\\":\\"Completed\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();    
        TA_LCC199_ButtonSection.manageApexAction(workOrderChildTest.Id, jsonTestChild , null, false);
        Test.stopTest();
    }

    @isTest
    static void completeWorkOrder_Test() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        String jsonTest = '[{"name":"completeWorkOrder","parameters":"{\\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        Test.stopTest();
    }

    @isTest
    static void createNewOppty_Test() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        String jsonTest = '[{"name":"createNewOppty","parameters":{"opptyWrapper":"{\\"Opportunity\\":{\\"WorkOrderID\\":\\"' + workOrderTest.Id + '\\",\\"AccountID\\":\\"' + workOrderTest.AccountId + '\\",\\"PrincingRegion\\":\\"\\"}}","taParameters":{"newOppty":""}}}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateWorkOrderTAParameters_Test() {
        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        workOrderTest.AccountId = accountToInsert.Id;
        insert workOrderTest;

        NE__Order__c order = new NE__Order__c();
        insert order;

        String jsonTest = '[{"name":"updateWorkOrderTAParameters","parameters":{"workOrder":"' + workOrderTest.Id + '","evtParam":{"selectedQuote":"' + order.Id + '"}}}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        Test.stopTest();
    }

    @isTest
    static void fillAddressOnOrder_Test() {

        Account accountToInsert = XC_DF_Account.createResidentialAccounts(1)[0];
        insert accountToInsert;

        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;
        
        NE__Order__c myOrder = new NE__Order__c();
        insert myOrder;

        workOrderTest.AccountId = accountToInsert.Id;
        workOrderTest.Status = 'Assigned';
        workOrderTest.XC_Configuration__c = myOrder.Id;
        update workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        String jsonTest = '[{"name":"fillAddressOnOrder","parameters":"{\\"WorkOrder\\":{\\"WorkOrderID\\":\\"' + workOrderTest.Id + '\\",\\"Status\\":\\"In Progress\\",\\"ServiceAppointment\\":[{\\"ServiceAppointmentID\\":\\"' + serviceApp.Id + '\\",\\"Status\\":\\"In Progress\\"}]}}"}]';

        Test.startTest();
        TA_LCC199_ButtonSection.manageApexAction(workOrderTest.Id, jsonTest , null, false);
        Test.stopTest();
    }

    @isTest
    static void updateReasonCannotComplete_Test() {
        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        ServiceAppointment serviceApp = new ServiceAppointment(
            ArrivalWindowStartTime = Datetime.now(),
            ParentRecordId = workOrderTest.Id
        );
        insert serviceApp;

        Test.startTest();
        String response = TA_LCC199_ButtonSection.updateReasonCannotComplete(workOrderTest.Id, 'Customer is not reacheable');
        Test.stopTest();
    }

    @isTest
    static void getTechnicalAssetDefaultValues_Test() {
        WorkOrder workOrderTest = createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        Test.startTest();
        String response = TA_LCC199_ButtonSection.getTechnicalAssetDefaultValues(workOrderTest.Id);
        Test.stopTest();
    }
}
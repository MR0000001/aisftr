@isTest
public with sharing class TA_LCC217_Interventions_Test {
    @testSetup
    static void setup() {
        TA_UTIL_Test.loadSetup();
    }

    @isTest
    public static void init_Test() {
        TA_LCC217_Interventions.InfoBag wrp1 = new TA_LCC217_Interventions.InfoBag();
        TA_LCC217_Interventions.MacroBlock wrp2 = new TA_LCC217_Interventions.MacroBlock();
        TA_LCC217_Interventions.WorkOrderLineItemWrapper wrp3 = new TA_LCC217_Interventions.WorkOrderLineItemWrapper();

        User u = new User(id = UserInfo.getUserId());

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        WorkOrderLineItem woliToInsert = new WorkOrderLineItem (
            XC_MacroBlocName__c = 'Puesta en marcha',
            XC_MacroBlocNumber__c = 3,
            XC_ActivityName__c = 'test',
            XC_ActivityNumber__c = 4,
            Status = 'New',
            XC_MeasurementValueOne__c = 23,
            XC_MeasurementUnitOne__c = 'mbar',
            XC_TechnicianResponseForConfiguration__c = 'Without Defect/With Defect',
            XC_Range__c = '10##35',
            Description = 'test',
            WorkOrderId = workOrderTest.Id,
            XC_WOLIType__c = 'Technical Asset'
        );
        insert woliToInsert;        

        insert new List<XC_ProductConsumed__c>{
            new XC_ProductConsumed__c (
                XC_WorkOrder__c = workOrderTest.Id,
                XC_WorkOrderLineItem__c = woliToInsert.Id
            ),
            new XC_ProductConsumed__c (
                XC_WorkOrder__c = workOrderTest.Id,
                XC_WorkOrderLineItem__c = woliToInsert.Id
            )
        };

        insert new List<XC_RequiredPosition__c>{
            new XC_RequiredPosition__c (
                XC_Quantity__c = 1,
                XC_WorkOrderLineItem__c = woliToInsert.Id
            )
        };

        String jsonCustomConfigSerialized = '{"woliTypeConfig":{"Technical Asset":{"Products_Consumed__r":{"showAccordion":true,"showRecord":false,"newRecord":true,"fieldRecordList":["Name","TAM_Asset__r.Name","TAM_Status__c","TAM_Asset__r.TAM_AssetType__c"]},"Products_Required__r":{"showAccordion":true,"showRecord":false,"newRecord":false,"fieldRecordList":["ProductName","QuantityRequired","XC_WBSElement__c"]},"Required_Positions__r":{"showAccordion":true,"showRecord":false,"newRecord":false,"fieldRecordList":["XC_ProductName__c","XC_Quantity__c","XC_PositionCode__c"]}}}}';
        Test.startTest();
        try {
            TA_LCC217_Interventions.init(workOrderTest.Id, null, jsonCustomConfigSerialized);
            TA_LCC217_Interventions.getAction(woliToInsert.Id);
            TA_LCC217_Interventions.sendApprovalRequest(woliToInsert.Id, 'test');           
        } catch(Exception e) {
            
        }
        Test.stopTest();
    }

    @isTest
    public static void init_Test_2() {
        TA_LCC217_Interventions.InfoBag wrp1 = new TA_LCC217_Interventions.InfoBag();
        TA_LCC217_Interventions.MacroBlock wrp2 = new TA_LCC217_Interventions.MacroBlock();
        TA_LCC217_Interventions.WorkOrderLineItemWrapper wrp3 = new TA_LCC217_Interventions.WorkOrderLineItemWrapper();
        insert new TA_Org_Info__c(TA_isDevHub__c = true);

        User u = new User(id = UserInfo.getUserId());

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        WorkOrderLineItem woliToInsert = new WorkOrderLineItem (
            XC_MacroBlocName__c = 'Puesta en marcha',
            XC_MacroBlocNumber__c = 3,
            XC_ActivityName__c = 'test',
            XC_ActivityNumber__c = 4,
            Status = 'New',
            XC_MeasurementValueOne__c = 23,
            XC_MeasurementUnitOne__c = 'mbar',
            XC_TechnicianResponseForConfiguration__c = 'Without Defect/With Defect',
            XC_Range__c = '10##35',
            Description = 'test',
            WorkOrderId = workOrderTest.Id,
            XC_WOLIType__c = 'Technical Asset'
        );
        insert woliToInsert;   
        
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = Blob.valueOf('string');
        ContVerFile.Title = 'title';
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient='title.csv';
        insert ContVerFile;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
        List<String> cdIdList = new List<String>();
        cdIdList.add(conDoc);

        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = woliToInsert.id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;

        String jsonCustomConfigSerialized = '{"woliTypeConfig":{"Technical Asset":{"Products_Consumed__r":{"showAccordion":true,"showRecord":false,"newRecord":true,"fieldRecordList":["Name","TAM_Asset__r.Name","TAM_Status__c","TAM_Asset__r.TAM_AssetType__c"]},"Products_Required__r":{"showAccordion":true,"showRecord":false,"newRecord":false,"fieldRecordList":["ProductName","QuantityRequired","XC_WBSElement__c"]},"Required_Positions__r":{"showAccordion":true,"showRecord":false,"newRecord":false,"fieldRecordList":["XC_ProductName__c","XC_Quantity__c","XC_PositionCode__c"]}}}}';
        Test.startTest();
        try {
            TA_LCC217_Interventions.init(workOrderTest.Id, null, jsonCustomConfigSerialized);                    
        } catch(Exception e) {
            
        }
        Test.stopTest();
    }

    @isTest
    public static void callDoxee_Test() {
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wrp3 = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();
        XC_REST_DoxeeFileSend_U.FileWrapper rWrapper = new XC_REST_DoxeeFileSend_U.FileWrapper();        
        //WorkOrder workOrderTest = new WorkOrder(TA_Phase__c='checkIn', XC_WorkTypeCategory__c = 'Repair', XC_WorkTypeLabel__c = 'Repair' );
        //insert workOrderTest;        
        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        Contact cnt = contactList[0];       
        insert cnt;
        workOrderTest.ContactId = cnt.id;
        update workOrderTest;
        XC_PersonalDocument__c pd = new XC_PersonalDocument__c();
        pd.XC_Contact__c = cnt.id;
        pd.XC_DocumentType__c = 'PT';
        insert pd;

        WorkOrderLineItem woliToInsert = new WorkOrderLineItem(
            XC_MacroBlocName__c = 'Puesta en marcha',
            XC_MacroBlocNumber__c = 3,
            XC_ActivityName__c = 'test',
            XC_ActivityNumber__c = 4,
            Status = 'New',
            XC_MeasurementValueOne__c = 23,
            XC_MeasurementUnitOne__c = 'mbar',
            XC_TechnicianResponseForConfiguration__c = 'Without Defect/With Defect',
            XC_Range__c = '10##35',
            Description = 'test',
            WorkOrderId = workOrderTest.Id
        );
        insert woliToInsert;

        TA_Doxee_Url_Management__c taDoxeeFront = new TA_Doxee_Url_Management__c (
            TA_Work_Order__c = workOrderTest.Id,
            TA_Type__c = 'IdentityCard_Front',
            TA_WorkOrderLineItem__c = woliToInsert.Id
        );
        insert taDoxeeFront;

        wrp3.WorkOrderLineItemNumber = woliToInsert.LineItemNumber;

        rWrapper.FileSize = 274;
        rWrapper.FileName = 'imgTest';
        rWrapper.FileCategory = 'SF_PHOTO';
        rWrapper.FileBase64 = '10';
        rWrapper.ObjectType = 'WORKORDER_LINEITEM';
        rWrapper.ObjectID = workOrderTest.Id;
        rWrapper.Company = '';
        rWrapper.Country = '';

           
        test.startTest();      
        TA_LCC217_Interventions.callDoxee(JSON.serialize(rWrapper), JSON.serialize(wrp3), workOrderTest.Id,true,true);      
        test.stopTest();
        
    }

    @isTest
    public static void deletePhoto_Test() {
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wrp3 = new XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper();

        //WorkOrder workOrderTest = new WorkOrder(TA_Phase__c='checkIn', XC_WorkTypeCategory__c = 'Repair', XC_WorkTypeLabel__c = 'Repair' );
        //insert workOrderTest;

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        WorkOrderLineItem woliToInsert = new WorkOrderLineItem(
            XC_MacroBlocName__c = 'Puesta en marcha',
            XC_MacroBlocNumber__c = 3,
            XC_ActivityName__c = 'test',
            XC_ActivityNumber__c = 4,
            Status = 'New',
            XC_MeasurementValueOne__c = 23,
            XC_MeasurementUnitOne__c = 'mbar',
            XC_TechnicianResponseForConfiguration__c = 'Without Defect/With Defect',
            XC_Range__c = '10##35',
            Description = 'test',
            WorkOrderId = workOrderTest.Id
        );
        insert woliToInsert;

        TA_Doxee_Url_Management__c taDoxeeFront = new TA_Doxee_Url_Management__c (
            TA_Work_Order__c = workOrderTest.Id,
            TA_Type__c = 'IdentityCard_Front',
            TA_DoxeeURL__c = 'TestURL',
            TA_WorkOrderLineItem__c = woliToInsert.Id
        );
        insert taDoxeeFront;

        WorkOrderLineItem currentLineItemNumber = [SELECT LineItemNumber FROM WorkOrderLineItem WHERE Id =: woliToInsert.Id][0];
        wrp3.WorkOrderLineItemNumber = currentLineItemNumber.LineItemNumber;

        test.startTest();
        TA_LCC217_Interventions.deletePhoto(woliToInsert.Id, JSON.serialize(wrp3), workOrderTest.Id, 'TestURL');
        test.stopTest();
    }

    @isTest
    public static void searchPhoto_Test() {
        test.startTest();
        WorkOrder workOrderTest = new WorkOrder(TA_Phase__c = 'checkIn' ,XC_WorkTypeCategory__c = 'Delivery & Installation');
        insert workOrderTest;

        TA_Doxee_Url_Management__c taDoxeeFront = new TA_Doxee_Url_Management__c (
            TA_Work_Order__c = workOrderTest.Id,
            TA_Type__c = 'IdentityCard_Front'
        );

        taDoxeeFront.TA_WorkOrderLineItem__c = taDoxeeFront.Id;
        TA_LCC217_Interventions.searchPhoto(taDoxeeFront.Id);
        test.stopTest();
    }

    @isTest
    public static void insertMeasure_Test() {
        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        WorkOrderLineItem woliToInsert = new WorkOrderLineItem(
            XC_MacroBlocName__c = 'Puesta en marcha',
            XC_MacroBlocNumber__c = 3,
            XC_ActivityName__c = 'test',
            XC_ActivityNumber__c = 4,
            Status = 'New',
            XC_MeasurementValueOne__c = 23,
            XC_MeasurementUnitOne__c = 'mbar',
            XC_TechnicianResponseForConfiguration__c = 'Without Defect/With Defect',
            XC_Range__c = '10##35',
            Description = 'test',
            WorkOrderId = workOrderTest.Id
        );

        insert woliToInsert;

        test.startTest();
        TA_LCC217_Interventions.insertMeasure(10, woliToInsert.Id);
        test.stopTest();
    }

    @isTest
    public static void removePhoto_Test() {
        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        WorkOrderLineItem woliToInsert = new WorkOrderLineItem(
            XC_MacroBlocName__c = 'Puesta en marcha',
            XC_MacroBlocNumber__c = 3,
            XC_ActivityName__c = 'test',
            XC_ActivityNumber__c = 4,
            Status = 'New',
            XC_MeasurementValueOne__c = 23,
            XC_MeasurementUnitOne__c = 'mbar',
            XC_TechnicianResponseForConfiguration__c = 'Without Defect/With Defect',
            XC_Range__c = '10##35',
            Description = 'test',
            WorkOrderId = workOrderTest.Id
        );
        insert woliToInsert;
    
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = Blob.valueOf('string');
        ContVerFile.Title = 'title';
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient='title.csv';
        insert ContVerFile;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
        List<String> cdIdList = new List<String>();
        cdIdList.add(conDoc);

        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = woliToInsert.id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;

        List<String> woliIdList = new List<String>();
        woliIdList.add(woliToInsert.id);

        test.startTest();
        TA_LCC217_Interventions.init(workOrderTest.Id, null, null);
        TA_LCC217_Interventions.removePhoto(cdIdList, woliIdList);
        test.stopTest();
    }
}
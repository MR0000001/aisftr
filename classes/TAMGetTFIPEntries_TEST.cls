/*
* @author:		Marco Lazzaroni (mlazzaroni@pic-informatica.it)
* @description:	Test class for TAMGetTFIPEntries
*/
@IsTest
private class TAMGetTFIPEntries_TEST {
    @TestSetup
    static void init() {
        XC_DF_WorkType.createWorkTypeWithName('Installation', 'Installation');
        XC_DF_WorkType.createWorkTypeWithName('Planned Maintenance', 'Planned Maintenance');
        List<WorkOrder> WOs = XC_DF_WorkOrder.createWorkOrders(1, 'Installation');
        WOs.addAll(XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance')) ;
        insert WOs;
        List<WorkOrderLineItem> WOLIs = new List<WorkOrderLineItem>{
                new WorkOrderLineItem(
                        RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('B2B EnelXItalia Technical Asset').getRecordTypeId(),
                        WorkOrderId = WOs[0].Id,
                        XC_WOLIType__c = 'Technical Asset'
                ),
                new WorkOrderLineItem(
                        RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByName().get('B2B EnelXItalia Technical Asset').getRecordTypeId(),
                        WorkOrderId = WOs[1].Id,
                        XC_WOLIType__c = 'Technical Asset'
                )
        };
        insert WOLIs;

        List<Asset> TAMs = XC_DF_Asset.createAssets(1);
        TAMs[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        TAMs[0].TAM_IsLogical__c = true;
        insert TAMs;
        insert new List<XC_ProductConsumed__c>{
            new XC_ProductConsumed__c(
                    TAM_Asset__c = TAMs[0].Id,
                    XC_WorkOrder__c = WOs[0].Id,
                    XC_WorkOrderLineItem__c = WOLIs[0].Id
            ),
            new XC_ProductConsumed__c(
                TAM_Asset__c = TAMs[0].Id,
                XC_WorkOrder__c = WOs[1].Id,
                XC_WorkOrderLineItem__c = WOLIs[1].Id
            )
        };
        insert new Product2(
                Name = 'TAM_TEST_PROD',
                IsActive = true
        );
        insert new ProductRequired(
                Product2 = new Product2(Name = 'TAM_TEST_PROD'),
                ParentRecordId = WOs[0].Id
        );

    }

    @IsTest
    static void getInstRecordsTest() {
        WorkOrderLineItem WOLI = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrder.XC_WorkTypeCategory__c = 'Installation'];

        Test.startTest();
        TAMGetTFIPEntries.FlowInputs inputs = new TAMGetTFIPEntries.FlowInputs();
        inputs.FlowGUId = 'TESTGUID';
        inputs.WOid = WOLI.WorkOrderId;
        inputs.WOLIid = WOLI.Id;
        TAMGetTFIPEntries.getRecords(new List<TAMGetTFIPEntries.FlowInputs>{inputs});
        Test.stopTest();

    }

    @IsTest
    static void getMaintRecordsTest() {
        WorkOrderLineItem WOLI = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrder.XC_WorkTypeCategory__c = 'Planned Maintenance'];
        Asset a = [SELECT Id, Status, TAM_IsTechnical__c, TAM_Make__c, XC_Model__c, TAM_ModelOrPartNumber__c, SerialNumber FROM Asset LIMIT 1];
        a.TAM_Make__c = 'A';
        a.XC_Model__c = 'AA';
        a.TAM_ModelOrPartNumber__c = 'AAA';
        a.SerialNumber = '123456';
        a.Status = 'Uninstalled';
        a.TAM_IsTechnical__c = true;
        update a;

        Test.startTest();
        TAMGetTFIPEntries.FlowInputs inputs = new TAMGetTFIPEntries.FlowInputs();
        inputs.FlowGUId = 'TESTGUID';
        inputs.WOid = WOLI.WorkOrderId;
        inputs.WOLIid = WOLI.Id;
        TAMGetTFIPEntries.getRecords(new List<TAMGetTFIPEntries.FlowInputs>{inputs});
        Test.stopTest();

    }

}
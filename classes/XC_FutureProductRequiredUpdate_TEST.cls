@isTest
public class XC_FutureProductRequiredUpdate_TEST {
    @TestSetup
    static void setup(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();

        List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
        NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];

        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'Approved';
        WorkOrder wo = new WorkOrder();
        wo.XC_Configuration__c= o.Id;
        wo.XC_Configuration_Item__c = itemList[0].Id;
        wo.XC_PreferredPArtner__c = acc[0].Id;
        wo.State = 'Italy';
        insert wo;

        woli.WorkOrderId = wo.Id;
        //woli.AccountId = acc[0].Id;
        woli.XC_AccountId__c = acc[0].Id;
        woli.XC_WOLIType__c = 'Good Issue';
        insert woli;


        WorkOrderLineItem woliMat = new WorkOrderLineItem();
        woliMat.Status = 'Approved';
        woliMat.WorkOrderId = wo.Id;
        //woli.AccountId = acc[0].Id;
        woliMat.XC_AccountId__c = acc[0].Id;
        woliMat.XC_WOLIType__c = 'Material Supply';
        insert woliMat;

        woli.XC_MaterialRequest__c = woliMat.id;
        update woli;


        gii__WarehouseGroup__c wareHouseG = new gii__WarehouseGroup__c(Name='Test-GloviaNetwork2');
        insert wareHouseG;
        gii__Warehouse__c wa = new gii__Warehouse__c(Name = 'Local Warehouse3',
                giic_WarehouseType__c='Local',
                giic_StorageCapacity__c=400000,
                gii__Account__c = acc[0].Id,
                gii__WarehouseGroup__c = wareHouseG.Id,
                giic_WarehouseCode__c = 'CW3',
                giic_warehousecountryPick__c = 'Italy',
                giic_LegalEntity__c = 'EnelXItalia'
        );
        insert wa;

        gii__SalesOrder__c so = new gii__SalesOrder__c();
        so.gii__Account__c = acc[0].Id;
        so.giic_WorkOrderLineItem__c = woliMat.id;
        so.gii__Warehouse__c = wa.Id;
        insert so;

        giic_ErrorLog__c err = new giic_ErrorLog__c();
        err.giic_ErrorDescription__c = 'No product inventory quantity';
        err.giic_IntegrationWrapper__c = '[{"warehouse":"aA97a0000008VukCAE","salesOrderLineListForWOLI":[],"salesOrderLineList":[{"wbe":"IT1FE400ZAYS00310030BK","warehouse":"aA97a0000008VukCAE","SKUCode":null,"productRequiredID":"0Gn7a0000008dKECAY","productName":null,"productConsumedID":"0Gn7a0000008dKECAY","productCode":null,"product":"a7y7a000000Cn7YAAS","pdtLotNumbers":null,"orderQuantity":null,"openQuantity":null,"Name":null,"lstAssignedLot":[],"LocationList":null,"isSerialControlled":null,"isLotControlled":null,"consumedQuantity":1.00,"assignedSerials":[]}],"odrStatus":null,"lastGoodIssue":false,"fslWorkOrderLineItem":"1WL7a000000Q7kRGAS","fslWorkOrder":"","fromComponent":false,"account":"0017a00001FHidAAAT"}]';
        err.giic_SalesOrder__c = so.id;
        insert err;

        Product2 p2 = new Product2(
                isActive = true,
                Name = 'Test'
        );
        insert p2;

        ProductRequired pr = new ProductRequired();
        pr.ParentRecordId=woli.id;
        pr.Product2Id=p2.Id;
        insert pr;

        XC_ProductConsumed__c prodCo=new XC_ProductConsumed__c();
        prodCo.XC_WorkOrder__c  = wo.Id;
        prodCo.XC_WorkOrderLineItem__c=woli.Id;
        prodCo.XC_Product2Id__c =p2.Id;
        prodCo.XC_ProductRequired__c = pr.id;
        prodCo.XC_QuantityConsumed__c=1;
        prodCo.XC_WBE__c = '1234567';
        prodCo.XC_CostCenter__c = '1234567';
        prodCo.XC_CategoryPosition__c = '9';
        prodCo.XC_AccountAssignmentCategory__c = 'P';
        insert prodCo;
    }

    static testMethod void test1(){
        WorkOrderLineItem woli = [SELECT id from WorkOrderLineItem limit 1];
        test.startTest();
        XC_FutureProductRequiredUpdate.updateProductRequired(woli.id);
        test.stopTest();
    }

}
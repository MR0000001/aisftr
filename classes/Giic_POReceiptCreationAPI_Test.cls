/**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description Giic_POReceiptCreationAPI_Test – Test Class for Giic_IntegrationUtility.
*/
@isTest(SeeAllData=false)
public class Giic_POReceiptCreationAPI_Test {
        /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_IntegrationUtility
*/
    @isTest static void createPOReceipTest(){ 
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation(); 
        Giic_UtilityClass_Test.warehouseCreation(); 
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c= System.Label.giic_IntegrationOperationCreate;
        Set<String> values = new Set<String>();
        values.add('SAP');
        Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c, values);
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        update Giic_UtilityClass_Test.objPO;
         Test.startTest();
         List<String> stringList= new List<String>(); 
        stringList.add('PO cancelled');
        stringList.add('To craeted');
        System.assertEquals(true, stringList.size()>0);
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
       List<Giic_POReceiptCreationApi.PurchaseOrderHeader> soWrapList = new List<Giic_POReceiptCreationApi.PurchaseOrderHeader>();
        List<Giic_POReceiptCreationApi.PurchaseOrderLine> solListToCreate = new List<Giic_POReceiptCreationApi.PurchaseOrderLine>();
        List<Giic_POReceiptCreationApi.AssignedSerial> assignedSerialsList = new  List<Giic_POReceiptCreationApi.AssignedSerial>();
        Giic_POReceiptCreationApi.PurchaseOrderHeader soCreateObj = new Giic_POReceiptCreationApi.PurchaseOrderHeader();
        soCreateObj.PurchaseOrderId = Giic_UtilityClass_Test.objPO.Id;
        // serial
        Giic_POReceiptCreationApi.PurchaseOrderLine newSOL = new Giic_POReceiptCreationApi.PurchaseOrderLine();
        newSOL.PurchaseOrderLineId = Giic_UtilityClass_Test.objPOLine.Id;
        newSOL.ReceiptQuantity = 20;
        solListToCreate.add(newSOL);
        soCreateObj.PurchaseOrderLinelist = solListToCreate;
        soWrapList.add(soCreateObj);
        Giic_POReceiptCreationApi.createPOReceiptandLine(soWrapList);
        Test.stopTest();
       
    }
    private static testMethod void createPOReceipforSerialProductTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
		gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c= System.Label.giic_IntegrationOperationCreate;
        Set<String> values = new Set<String>();
        values.add('SAP');
        Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c= Giic_PurchaseOrderUtility.setTargetSystem(Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c, values);
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        update Giic_UtilityClass_Test.objPO;
         Test.startTest();
        List<String> stringList= new List<String>();
        stringList.add('PO cancelled');
        stringList.add('To craeted');
        System.assertEquals(true, stringList.size()>0);
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        objProdRef.gii__SerialControlled__c = true;
        update objProdRef;
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        List<Giic_POReceiptCreationApi.PurchaseOrderHeader> soWrapList = new List<Giic_POReceiptCreationApi.PurchaseOrderHeader>();
        List<Giic_POReceiptCreationApi.PurchaseOrderLine> solListToCreate = new List<Giic_POReceiptCreationApi.PurchaseOrderLine>();
        List<Giic_POReceiptCreationApi.AssignedSerial> assignedSerialsList = new  List<Giic_POReceiptCreationApi.AssignedSerial>();
        Giic_POReceiptCreationApi.PurchaseOrderHeader soCreateObj = new Giic_POReceiptCreationApi.PurchaseOrderHeader();
        Giic_POReceiptCreationApi.ParamsWrapper params = new Giic_POReceiptCreationApi.ParamsWrapper();    
        List<Giic_POReceiptCreationApi.ErrorList> errList = new List<Giic_POReceiptCreationApi.ErrorList>();
        Giic_POReceiptCreationApi.ErrorList er = new Giic_POReceiptCreationApi.ErrorList();
        er.errorMsg = 'ERROR';
        errList.add(er);
        params.response.errorList = errList;
        soCreateObj.PurchaseOrderId =Giic_UtilityClass_Test.objPO.Id;
        // serial
        Giic_POReceiptCreationApi.PurchaseOrderLine newSOL = new Giic_POReceiptCreationApi.PurchaseOrderLine();
        newSOL.PurchaseOrderLineId = Giic_UtilityClass_Test.objPOLine.Id;
        newSOL.ReceiptQuantity = 3;
        Giic_POReceiptCreationApi.AssignedSerial serial = new Giic_POReceiptCreationApi.AssignedSerial();
        serial.serialNumber = 'Tube-Light984';
        assignedSerialsList.add(serial);
        newSOL.assignedSerials = assignedSerialsList;
        solListToCreate.add(newSOL);
        soCreateObj.PurchaseOrderLinelist = solListToCreate;
        soWrapList.add(soCreateObj);
        Giic_POReceiptCreationApi.createPOReceiptandLine(soWrapList);
        Giic_POReceiptCreationApi.createErrorLogs(params);
        Test.stopTest();
    }
       /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_IntegrationUtility
*/
    private static testMethod void createPOReceipTestforErrorLog(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
        Giic_UtilityClass_Test.objPO.giic_IntegrationOperation__c= System.Label.giic_IntegrationOperationCreate;
        Set<String> values = new Set<String>();
        values.add('SAP');
        Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c= Giic_PurchaseOrderUtility.setTargetSystem(Giic_UtilityClass_Test.objPO.giic_MultiTargetSystem__c, values);
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        update Giic_UtilityClass_Test.objPO;
        Test.startTest();
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
     //   Giic_UtilityClass_Test.pOReceipt(); 
     //   Giic_UtilityClass_Test.pOReceiptLine();
        List<Giic_POReceiptCreationApi.PurchaseOrderHeader> soWrapList = new List<Giic_POReceiptCreationApi.PurchaseOrderHeader>();
        List<Giic_POReceiptCreationApi.PurchaseOrderLine> solListToCreate = new List<Giic_POReceiptCreationApi.PurchaseOrderLine>();
        List<Giic_POReceiptCreationApi.AssignedSerial> assignedSerialsList = new  List<Giic_POReceiptCreationApi.AssignedSerial>();
        Giic_POReceiptCreationApi.PurchaseOrderHeader soCreateObj = new Giic_POReceiptCreationApi.PurchaseOrderHeader();
        soCreateObj.PurchaseOrderId = Giic_UtilityClass_Test.objPO.Id;
        // serial
        Giic_POReceiptCreationApi.PurchaseOrderLine newSOL = new Giic_POReceiptCreationApi.PurchaseOrderLine();
        newSOL.PurchaseOrderLineId = Giic_UtilityClass_Test.objPOLine.Id;
        newSOL.ReceiptQuantity = 20;
        solListToCreate.add(newSOL);
        soCreateObj.PurchaseOrderLinelist = solListToCreate;
        soWrapList.add(soCreateObj);
        System.assertEquals(true,soWrapList.size()>0);
        Giic_POReceiptCreationApi.createPOReceiptandLine(soWrapList);
        Test.stopTest();
    }
     /**
* @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
* @date Creation 5/09/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for Giic_IntegrationUtility
*/
    private static testMethod void createPOReceipTestforErrorLogforReceipt(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj);
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= false;
        update Giic_UtilityClass_Test.objPO;
        Test.startTest();
        gii__Product2Add__c objProdRef= [Select id,Name,gii__ProductCode__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        List<Giic_POReceiptCreationApi.PurchaseOrderHeader> soWrapList = new List<Giic_POReceiptCreationApi.PurchaseOrderHeader>();
        List<Giic_POReceiptCreationApi.PurchaseOrderLine> solListToCreate = new List<Giic_POReceiptCreationApi.PurchaseOrderLine>();
        List<Giic_POReceiptCreationApi.AssignedSerial> assignedSerialsList = new  List<Giic_POReceiptCreationApi.AssignedSerial>();
        Giic_POReceiptCreationApi.PurchaseOrderHeader soCreateObj = new Giic_POReceiptCreationApi.PurchaseOrderHeader();
        soCreateObj.PurchaseOrderId = Giic_UtilityClass_Test.objPO.Id;
        // serial
        Giic_POReceiptCreationApi.PurchaseOrderLine newSOL = new Giic_POReceiptCreationApi.PurchaseOrderLine();
        newSOL.PurchaseOrderLineId = Giic_UtilityClass_Test.objPOLine.Id;
        newSOL.ReceiptQuantity = 20;
        solListToCreate.add(newSOL); 
        soCreateObj.PurchaseOrderLinelist = solListToCreate;
        soWrapList.add(soCreateObj); 
        System.assertEquals(true,soWrapList.size()>0); 
        Giic_POReceiptCreationApi.createPOReceiptandLine(soWrapList);
        Test.stopTest();
    }
}
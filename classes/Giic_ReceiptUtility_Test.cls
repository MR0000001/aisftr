/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 26/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_ReceiptUtility_Test – Test Class for Giic_ReceiptUtility.
*/
@isTest
public class Giic_ReceiptUtility_Test {
 /**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 26/08/2019
* @date Modification dd/mm/yyyy
* @description – Test Method for clearBackOrderQtyOnPI.
*/    
    public static testMethod void clearBackOrderQtyOnPITest() {
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
       Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c prodRefObj = [SELECT Id, gii__ProductReference__c FROM gii__Product2Add__c limit 1]; 
        Giic_UtilityClass_Test.objWhLocal.giic_ParentWarehouse__c=Giic_UtilityClass_Test.objWh.Id;
        Giic_UtilityClass_Test.objWhLocal.gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationlocal.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultIssueLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        Giic_UtilityClass_Test.lstWh[0].gii__DefaultReceivingLocation__c=Giic_UtilityClass_Test.objLocationCentral.Id;
        update Giic_UtilityClass_Test.objWhLocal;
        update Giic_UtilityClass_Test.objWh;
         Giic_UtilityClass_Test.salesOrderCreation();  
         Giic_UtilityClass_Test.shipmentCreation();
         Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.priceBookCreation();
        Giic_UtilityClass_Test.priceBookEntryCreation(prodRefObj); 
        Giic_UtilityClass_Test.purchaseOrderCreation();
        Giic_UtilityClass_Test.objPO.gii__Approved__c= true;
        upsert Giic_UtilityClass_Test.objPO;
        Test.startTest();
        gii__Product2Add__c objProdRef = [select id,gii__ProductReference__c,gii__PlanningPolicy__c,
                                          gii__PrimarySupplier__c from gii__Product2Add__c Limit 1];
        Giic_UtilityClass_Test.purchaseOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.pOReceipt(); 
        Giic_UtilityClass_Test.pOReceiptLine();
        Giic_UtilityClass_Test.transferOrderCreation();
        Giic_UtilityClass_Test.objTO.giic_Status__c='Open';
        Giic_UtilityClass_Test.objTO.giic_Approved__c=true;
        update Giic_UtilityClass_Test.objTO;
        Giic_UtilityClass_Test.tOLineCreation(objProdRef);
        gii__ProductInventory__c prodInvntryobj= [SELECT gii__Product__c, gii__Warehouse__r.gii__Account__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                                                  gii__BackOrderQuantity__c, gii__SalesOrderQuantity__c,
                                                  giic_BackOrderNew__c FROM gii__ProductInventory__c
                                                 ];
        prodInvntryobj.giic_BackOrderNew__c=30;
        update prodInvntryobj;
        Date receiptDate = system.today().addMonths(1);
        string receiptDateString = receiptDate.year()+'-'+receiptDate.month()+'-'+receiptDate.day();
        List<gii__Receipt__c> lstReceipt = new List<gii__Receipt__c>();
        gii__Receipt__c objTOreceiptCS = new gii__Receipt__c(gii__ReceiptDate__c =Date.valueOf(receiptDateString), 
                                                             gii__TransferOrder__c = Giic_UtilityClass_Test.objTO.id,gii__OrderType__c='Transfer', 
                                                             gii__ProductInventory__c = prodInvntryobj.Id,gii__Warehouse__c=Giic_UtilityClass_Test.objWhLocal.Id ,gii__ReceiptQuantity__c = 45);
        lstReceipt.add(objTOreceiptCS);
        insert lstReceipt;
        lstReceipt[0].gii__ReceiptQuantity__c = 47;
        update lstReceipt;
        list<gii__Receipt__c> lstReceiptNew = [SELECT id, gii__ReceiptQuantity__c,gii__Warehouse__c, gii__OrderType__c, gii__Warehouse__r.gii__DefaultReceivingLocation__c,gii__ProductInventory__c, gii__ProductInventory__r.gii__Product__c,gii__ProductInventory__r.giic_BackOrderNew__c FROM  gii__Receipt__c ];
        system.debug('lstReceiptNew' + lstReceiptNew);
        system.debug('lstReceipt333-->>>>' + lstReceiptNew[0].gii__ProductInventory__r.giic_BackOrderNew__c);
        list<gii__Receipt__c> listReceipt = [SELECT id, gii__ReceiptQuantity__c,gii__Warehouse__c, gii__OrderType__c, gii__Warehouse__r.gii__DefaultReceivingLocation__c,gii__ProductInventory__c, gii__ProductInventory__r.gii__Product__c,gii__ProductInventory__r.giic_BackOrderNew__c FROM  gii__Receipt__c WHERE  gii__ProductInventory__r.giic_BackOrderNew__c  > 0 and gii__OrderType__c='Transfer'];
        system.debug('listReceipt-->>>>' + listReceipt);
        System.assertEquals(true, lstReceiptNew.size()>0);
        Giic_ReceiptUtility.clearBackOrderQtyOnPI(lstReceipt);
       
        try{
             delete lstReceiptNew;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot delete receipt record') ? true : false;
		    System.AssertEquals(expectedExceptionThrown, true);
        }
       
        Test.stopTest();
    }
}
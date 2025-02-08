/**
* @author FirstName :  Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 26/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_RMAUtility_Test – Test Class for Giic_RMAUtility.
*/
@isTest
public class Giic_RMAUtility_Test {
    
     @isTest
    public static  void checkCreateRMAsTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.productCreation(); 
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update pref;
        System.assertEquals(true, pref.gii__PrimarySupplier__c==Giic_UtilityClass_Test.objAccountSupplier.Id);
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        List<Giic_CommonWrapper.RMAHeader> rmaList= new List<Giic_CommonWrapper.RMAHeader>();
        Giic_CommonWrapper.RMAHeader objRMA=new Giic_CommonWrapper.RMAHeader();
        objRMA.AccountId=Giic_UtilityClass_Test.objAccountLocal.Id;
        objRMA.CurrencyIsoCode ='EUR'; 
        objRMA.warehouseId =Giic_UtilityClass_Test.objWhLocal.Id;
        objRMA.RMALines= new List<Giic_CommonWrapper.RmaLine>();
        Giic_CommonWrapper.RmaLine objRMALine=new Giic_CommonWrapper.RmaLine();
        objRMALine.RmaQuantity=1.0;
        objRMALine.ProductId=pref.Id;
        objRMALine.underWarranty=true;
        objRMA.RMALines.add(objRMALine);
        rmaList.add(objRMA);
        System.assertEquals(true, rmaList.size()>0);
        Test.startTest();
        Giic_RMAUtility.createRMAs(rmaList);
        Test.stopTest();
    }
    
     @isTest
    public static  void checkCreateRMAsSerialTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.productCreation(); 
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        pref.gii__SerialControlled__c = true;
        update pref;
        Giic_UtilityClass_Test.productSerialCreation(pref.id);
        System.assertEquals(true, pref.gii__PrimarySupplier__c==Giic_UtilityClass_Test.objAccountSupplier.Id);
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        List<Giic_CommonWrapper.RMAHeader> rmaList= new List<Giic_CommonWrapper.RMAHeader>();
        Giic_CommonWrapper.RMAHeader objRMA=new Giic_CommonWrapper.RMAHeader();
        objRMA.AccountId=Giic_UtilityClass_Test.objAccountLocal.Id;
        objRMA.CurrencyIsoCode ='EUR'; 
        objRMA.warehouseId =Giic_UtilityClass_Test.objWhLocal.Id;
        objRMA.RMALines= new List<Giic_CommonWrapper.RmaLine>();
        Giic_CommonWrapper.RmaLine objRMALine=new Giic_CommonWrapper.RmaLine();
        objRMALine.RmaQuantity=1.0;
        objRMALine.ProductId=pref.Id;
        objRMALine.productSerialId=Giic_UtilityClass_Test.objPS.ID;
        objRMALine.underWarranty=true;
        objRMA.RMALines.add(objRMALine);
        rmaList.add(objRMA);
        System.assertEquals(true, rmaList.size()>0);
        Test.startTest();
        Giic_RMAUtility.createRMAs(rmaList);
        Test.stopTest();
    }
    //Cover negative case when warehouseId is not given
    @isTest
    public static void checkCreateRMAsWithoutWIdTest(){
        Giic_UtilityClass_Test.systemPolicyCreation(); 
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.productCreation(); 
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        List<Giic_CommonWrapper.RMAHeader> rmaList= new List<Giic_CommonWrapper.RMAHeader>();
        Giic_CommonWrapper.RMAHeader objRMA=new Giic_CommonWrapper.RMAHeader();
        objRMA.AccountId=Giic_UtilityClass_Test.objAccountLocal.Id;
        objRMA.CurrencyIsoCode ='EUR'; 
        objRMA.RMALines= new List<Giic_CommonWrapper.RmaLine>();
        Giic_CommonWrapper.RmaLine objRMALine=new Giic_CommonWrapper.RmaLine();
        objRMALine.RmaQuantity=1.0;
        objRMALine.ProductId=pref.Id;
        objRMALine.underWarranty=true;
        objRMA.RMALines.add(objRMALine);
        rmaList.add(objRMA);
        System.assertEquals(true, rmaList.size()>0);
        Giic_RMAUtility.createRMAs(rmaList);
    } 
    
    @isTest
    public static void cancellationRMATest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.productCreation(); 
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update pref;
        System.assertEquals(true, pref.gii__PrimarySupplier__c==Giic_UtilityClass_Test.objAccountSupplier.Id);
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        List<Giic_CommonWrapper.RMAHeader> rmaList= new List<Giic_CommonWrapper.RMAHeader>();
        Giic_CommonWrapper.RMAHeader objRMA=new Giic_CommonWrapper.RMAHeader();
        objRMA.AccountId=Giic_UtilityClass_Test.objAccountLocal.Id;
        objRMA.CurrencyIsoCode ='EUR'; 
        objRMA.warehouseId =Giic_UtilityClass_Test.objWhLocal.Id;
        objRMA.RMALines= new List<Giic_CommonWrapper.RmaLine>();
        Giic_CommonWrapper.RmaLine objRMALine=new Giic_CommonWrapper.RmaLine();
        objRMALine.RmaQuantity=1.0;
        objRMALine.ProductId=pref.Id;
        objRMALine.underWarranty=true;
        objRMA.RMALines.add(objRMALine);
        rmaList.add(objRMA);
        System.assertEquals(true, rmaList.size()>0);
        
        gii__RMA__c rmaObj = new gii__RMA__c();
        rmaObj.gii__Account__c =Giic_UtilityClass_Test.objAccountLocal.Id;
        rmaObj.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rmaObj.CurrencyIsoCode = 'EUR'; 
        insert rmaObj;
        gii__RMADetail__c rMALineObj = new gii__RMADetail__c();
        RMALineObj.gii__Product__c = pref.Id;
        RMALineObj.gii__RMAQuantity__c = 1;
        RMALineObj.gii__RMA__c = rmaObj.Id;
        insert rMALineObj;
        gii__RMAReceipt__c receipt = new gii__RMAReceipt__c();
        receipt.gii__RMA__c = rmaObj.Id;
        receipt.gii__ReceiptQuantity__c = 1;
        receipt.gii__ReceiptDate__c = Date.today(); 
        receipt.gii__RMALineDetail__c = rMALineObj.Id;
        receipt.gii__Product__c =  pref.Id;
        receipt.gii__Warehouse__c = Giic_UtilityClass_Test.objWhLocal.Id; 
        insert receipt;
        gii__RMADisposition__c dispose = new gii__RMADisposition__c();
        dispose.gii__RMAReceipt__c = receipt.Id; 
        dispose.gii__DispositionQuantity__c = 1;
        insert dispose;
        Test.startTest();
        Giic_RMAUtility.cancellation_RMA_RTS(rmaObj.ID);
        Test.stopTest();
    }
     @isTest
    public static void cancellationReturnToSupplierTest(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.productCreation(); 
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update pref;
        list<gii__Product2Add__c> lstProdRef = new list<gii__Product2Add__c>();
        lstProdRef.add(pref);
        System.assertEquals(true, pref.gii__PrimarySupplier__c==Giic_UtilityClass_Test.objAccountSupplier.Id);
        Giic_UtilityClass_Test.priceBookEntryCreation(pref);
        Giic_UtilityClass_Test.creationPI(Giic_UtilityClass_Test.objWhLocal ,lstProdRef);
        gii__ProductInventory__c objPI = [SELECT Id, gii__Warehouse__c FROM  gii__ProductInventory__c LIMIT 1];
        Giic_UtilityClass_Test.creationPILocation( objPI,pref);
        Giic_UtilityClass_Test.creationPILocationDetail(objPI,pref);
        
        List<Giic_CommonWrapper.RMAHeader> rmaList= new List<Giic_CommonWrapper.RMAHeader>();
        Giic_CommonWrapper.RMAHeader objRMA=new Giic_CommonWrapper.RMAHeader();
        objRMA.AccountId=Giic_UtilityClass_Test.objAccountLocal.Id;
        objRMA.CurrencyIsoCode ='EUR'; 
        objRMA.warehouseId =Giic_UtilityClass_Test.objWhLocal.Id;
        objRMA.RMALines= new List<Giic_CommonWrapper.RmaLine>();
        Giic_CommonWrapper.RmaLine objRMALine=new Giic_CommonWrapper.RmaLine();
        objRMALine.RmaQuantity=1.0;
        objRMALine.ProductId=pref.Id;
        objRMALine.underWarranty=true;
        objRMA.RMALines.add(objRMALine);
        rmaList.add(objRMA);
        System.assertEquals(true, rmaList.size()>0);
         List<Account> accountList = new List<Account>();
        accountList.add(Giic_UtilityClass_Test.objAccountLocal);
        List<XC_Address__c> address = XC_DF_Address.createAddress(accountList);
        insert address;
        gii__ReturntoSupplier__c rmaObj = new gii__ReturntoSupplier__c();
        rmaObj.gii__Supplier__c =Giic_UtilityClass_Test.objAccountLocal.Id;
        rmaObj.gii__ShipFrom__c = Giic_UtilityClass_Test.objWhLocal.Id;
        rmaObj.CurrencyIsoCode = 'EUR'; 
        rmaObj.gii__PriceBookName__c = Giic_UtilityClass_Test.objPriceBook.Name;
        insert rmaObj;
        gii__ReturntoSupplierLine__c rMALineObj = new gii__ReturntoSupplierLine__c();
        RMALineObj.gii__Product__c = pref.Id;
        RMALineObj.gii__OrderQuantity__c =2;
        RMALineObj.gii__ReturntoSupplier__c = rmaObj.Id;
        insert rMALineObj;
        gii__ReturntoSupplierLineShipment__c receipt = new gii__ReturntoSupplierLineShipment__c();
        receipt.gii__ReturntoSupplier__c = rmaObj.Id; 
      //  receipt.gii__ShippedQuantity__c = 1;
       // receipt.gii__ShippedDate__c = Date.today(); 
        receipt.gii__ReturntoSupplierLine__c = rMALineObj.Id; 
        insert receipt;
		        
        Test.startTest();
        Giic_RMAUtility.cancellation_RMA_RTS(rmaObj.ID);
        Test.stopTest();
    }
}
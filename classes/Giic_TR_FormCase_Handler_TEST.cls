/**
 * @author Milko Fatiga
 * @date Creation 04/05/2022
 * @description Giic_TR_FormCase_Handler_TEST - test class for Giic_TR_FormCase_Handler.
 */
@isTest
public class Giic_TR_FormCase_Handler_TEST {
    
    @TestSetup
    static void testSetup() {

        WorkOrder workOrderTest = XC_DF_WorkOrder.createWorkOrders(1, 'Repair')[0];
        insert workOrderTest;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            Status = 'New',
            XC_Form_Type__c = 'RMA',
            WorkOrderId = workOrderTest.Id,
            Country = 'Italy'
        );
        insert woli;

        XC_ProductConsumed__c product = new XC_ProductConsumed__c(XC_WorkOrderLineItem__c = woli.Id, XC_QuantityConsumed__c = 2, XC_WorkOrder__c = workOrderTest.Id);
        insert product;

        XC_FormCase__c formCase = new XC_FormCase__c(
            XC_Return_Material__c = woli.Id,
            XC_Product_Consumed__c = product.Id,
            XC_Country__c = woli.Country,
            XC_Legal_Entity__c = 'EnelXMobilityItalia',
            RecordTypeId = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId()
        );
        insert formCase;

    }
    
    @isTest
    static void TriggerTest(){
        List<XC_ProductConsumed__c> product = [SELECT Id FROM XC_ProductConsumed__c LIMIT 1];
        XC_FormCase__c formCase = new XC_FormCase__c(XC_Country__c = 'Italy',XC_Legal_Entity__c = 'EnelXMobilityItalia' , XC_Product_Consumed__c = product[0].Id, RecordTypeId = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId());
        XC_FormCase__c formCase2 = new XC_FormCase__c(XC_Country__c = 'Italy',XC_Legal_Entity__c = 'EnelXMobilityItalia', RecordTypeId = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId());
        List<XC_FormCase__c> formCases = new List<XC_FormCase__c>();
        formCases.add(formCase);
        formCases.add(formCase2);

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
        gii__RMADetail__c RMADet=new gii__RMADetail__c();
        RMADet=[Select Id from gii__RMADetail__c LIMIT 1];
        insert formCases;

        formCase.XC_RMA_Line__c = RMADet.Id;
        update formCase;

        formCase.XC_Status__c = 'To be Approved';
        update formCase;        
        
        delete formCase2;
        undelete formCase2;

        Test.stopTest();
    }

}
/**
 * @author Dimitris Karnavas - dkarnavas@deloitte.gr & Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 14/03/2022
 * @description XC_UTIL_FormCase_TEST - test class for XC_UTIL_FormCase.
 */
@isTest
public class XC_UTIL_FormCase_TEST {
    
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

        WorkOrderLineItem woli2 = new WorkOrderLineItem(
            Status = 'New',
            XC_Form_Type__c = 'NC',
            WorkOrderId = workOrderTest.Id,
            Country = 'Italy'
        );
        insert woli2;
    }
    
    @isTest
    static void createFormCasesFromProductsConsumedTest(){
        List<WorkOrderLineItem> wolis = [SELECT Id,XC_Form_Type__c, Country FROM WorkOrderLineItem];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
      
        XC_ProductConsumed__c product = new XC_ProductConsumed__c(XC_WorkOrderLineItem__c = wolis[0].Id, XC_QuantityConsumed__c = 2, XC_WorkOrder__c = wo.Id);
        List<XC_ProductConsumed__c> products = new List<XC_ProductConsumed__c>();
        products.add(product);

        Test.startTest();
        List<XC_UTIL_Sobject.WrapperResult> insertProducts = XC_UTIL_DML.insertRecords(products);
        List<XC_FormCase__c> formCases = XC_UTIL_FormCase.createFormCasesFromProductsConsumed(insertProducts, wolis[0]);
        List<XC_FormCase__c> formCases2 = XC_UTIL_FormCase.createFormCasesFromProductsConsumed(insertProducts, wolis[1]);
        System.assertEquals(2,formCases.size());
        System.assertEquals(2,formCases.size());
        Test.stopTest();
    }

}
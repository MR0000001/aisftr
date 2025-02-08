/**
 * @author Dimitris Karnavas - dkarnavas@deloitte.gr & Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @date Creation 14/03/2022
 * @description XC_TR_FormCase_Handler_TEST - test class for XC_TR_FormCase_Handler.
 */
@isTest
public class XC_TR_FormCase_Handler_TEST {
    
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
            XC_Legal_Entity__c = 'EnelXItalia',
            XC_Return_Material__c = woli.Id,
            XC_Product_Consumed__c = product.Id,
            XC_Country__c = woli.Country,
            RecordTypeId = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId()
        );
        insert formCase;

    }
    
    @isTest
    static void populateFieldsOnInsert(){
        List<XC_ProductConsumed__c> product = [SELECT Id FROM XC_ProductConsumed__c LIMIT 1];
        XC_FormCase__c formCase = new XC_FormCase__c(XC_Legal_Entity__c = 'EnelXItalia', XC_Country__c = 'Italy', XC_Product_Consumed__c = product[0].Id,
            RecordTypeId = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId());
        XC_FormCase__c formCase2 = new XC_FormCase__c(XC_Country__c = 'Italy',XC_Legal_Entity__c = 'EnelXItalia',
            RecordTypeId = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId());
        List<XC_FormCase__c> formCases = new List<XC_FormCase__c>();
        formCases.add(formCase);
        formCases.add(formCase2);

        Test.startTest();
        XC_TR_FormCase_Handler.bypassBeforeInsert = false;
        insert formCases;

        formCase.XC_Country__c = 'Spain';
        update formCase;

        delete formCase2;
        undelete formCase2;

        XC_FormCase__c form = [SELECT Id, XC_Identification_Code__c FROM XC_FormCase__c LIMIT 1];
        System.assert(String.isNotBlank(form.XC_Identification_Code__c));
        Test.stopTest();
    }

}
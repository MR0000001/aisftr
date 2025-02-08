/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  12/01/20201
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_SC039_GenerateB2WWorkOrder – Tes class for XC_SC039_GenerateB2WWorkOrder
*/

@isTest
public without sharing class XC_SC039_GenerateB2WWorkOrder_TEST {

    @isTest
    static void onRunEvent() {
        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertLogsGenerateWO';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'InsertLogsGenerateWO_OK';
        csInsertDML1.Value__c = 'true';
        insert csInsertDML1;
        
        NE__Order__c orderToReprocess = XC_DF_Order.createOrder('InOrder');
        orderToReprocess.XC_AlreadyReprocessed__c = false;
        orderToReprocess.XC_ToBeReprocessed__c = true;
        update orderToReprocess;
        

        Test.startTest();  
        String chron = '0 0 23 * * ?';        
        System.schedule('TestScheduleSC039', chron, new XC_SC039_GenerateB2WWorkOrder());
        Test.stopTest();
    }

}
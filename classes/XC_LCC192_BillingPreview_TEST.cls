/**
* @author dpalamides
* @date 16/06/2020
* @description classes.XC_LCC192_BillingPreview_TEST
*/

@IsTest
public without sharing class XC_LCC192_BillingPreview_TEST {

    static testMethod void testInit(){

        NE__Order__c o = XC_DF_Order.createOrder('InOrder');
        o.XC_LegalEntity__c= 'EnelXItalia';
        o.XC_Segment__c = 'B2B';
        update o;
        
        XC_CS_UtilityGlobalValues__c csInsertDML = new XC_CS_UtilityGlobalValues__c();
        csInsertDML.Name = 'InsertLogsGenerateWO';
        csInsertDML.Value__c = 'true';
        insert csInsertDML;
        XC_CS_UtilityGlobalValues__c csInsertDML1 = new XC_CS_UtilityGlobalValues__c();
        csInsertDML1.Name = 'InsertLogsGenerateWO_OK';
        csInsertDML1.Value__c = 'true';
        insert csInsertDML1;
        
        NE__OrderItem__c oi = [Select XC_BillingModel__c, XC_PaymentMethod__c, NE__OneTimeFeeOv__c, id from NE__OrderItem__c where NE__OrderId__c = : o.id LIMIT 1];
        oi.XC_BillingModel__c = 'Milestone';
        oi.XC_PaymentMethod__c = 'Bank Transfer';
        oi.NE__OneTimeFeeOv__c = 1;
        update oi;
        Opportunity op = [select id, RecordTypeId, XC_BusinessLine__c,  XC_ProductCategoryOfInterest__c, XC_ProductCategory__c, XC_BillingModel__c, XC_SalesChannel__c, XC_LegalEntity__c from Opportunity where id = :o.NE__OptyId__c LIMIT 1];
        op.XC_LegalEntity__c= 'EnelXItalia';
        op.XC_BillingModel__c = 'One Shot';
        op.XC_Segment__c = 'B2B';
        op.XC_BusinessLine__c = 'eIndustry';
        op.XC_ProductCategoryOfInterest__c = 'Utility Bill Management (UBM)';
        op.XC_ProductCategory__c = 'Customer Insights';
        op.XC_ContractType__c = 'Simple Contracts';
        op.XC_InvoiceType__c = 'Single Invoice - Separated by Materials';
        op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        update op;

        XC_LCC192_BillingPreview.refreshBillingPreview(o.Id);


    }
}
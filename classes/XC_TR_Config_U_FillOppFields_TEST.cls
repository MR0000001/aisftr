/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  21/05/2019 
* @description XC_TR_Config_U_FillOppFields_TEST – Test class for XC_TR_Configuration_U_FillOppFields
*/ 
    @isTest
public with sharing class XC_TR_Config_U_FillOppFields_TEST {
    // Test method for populateOpportunity 
    static testMethod void populateOpportunity(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
                opp[0].XC_ProductCategoryOfInterest__c = 'Aire acondicionado';
                insert opp; 
                List<NE__Order__c> o= XC_DF_Order.createOrders(1, 'InOrder');
                insert o; 
                o[0].NE__OptyId__c=opp[0].Id;
                update o; 
                System.assertEquals(1, o.size());
            Test.stopTest();
    }

    // Test method for populateOpportunity1
    static testMethod void populateOpportunity1(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
                opp[0].XC_CompanyCode__c='CODE 007';
                opp[0].XC_CostCenter__c='OR-0000000994';
                opp[0].XC_ProductCategoryOfInterest__c = 'Aire acondicionado';
                insert opp; 
                List<NE__Order__c> o= XC_DF_Order.createOrders(1, 'InOrder');
                o[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
                insert o; 
                o[0].NE__OptyId__c=opp[0].Id;
                o[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
                update o; 
                System.assertEquals(1, o.size());

            Test.stopTest();
    }

            // Test method for populateOpportunity2
    static testMethod void populateOpportunityAndSkipContract(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
                opp[0].XC_CompanyCode__c='';
                opp[0].XC_CostCenter__c='';
                opp[0].XC_ProductCategoryOfInterest__c = 'Aire acondicionado';
                opp[0].XC_ExternalPartner__c = 'Empresas Renting';
                insert opp; 
                List<NE__Order__c> o= XC_DF_Order.createOrders(1, 'InOrder');
                o[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
                o[0].NE__OptyId__c = opp[0].Id;
                o[0].XC_LegalEntity__c = 'EndesaX';
                o[0].NE__AccountId__c = opp[0].AccountId;
                o[0].XC_Segment__c = 'B2C';
                insert o; 
                o[0].NE__OptyId__c=opp[0].Id;
                o[0].RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
                update o; 
                System.assertEquals(1, o.size());

            Test.stopTest();
    }

}
/**
 * Created by dolombardi on 09/12/2020.
 */
@isTest
public with sharing class XC_TR_Opportunity_U_updateContract_TEST {
    static testMethod void insertOpp(){
        //List<Opportunity> listopp = XC_DF_Opportunity.createOpportunity(1,false);
        NE__Order__c o = XC_DF_Order.createOrder('test');
        Opportunity op = [select id, AccountId,XC_RevenueFullLife__c, XC_Address__c, XC_GrossMarginFullLife__c, RecordTypeId, XC_BillingModel__c, XC_SalesChannel__c, XC_LegalEntity__c from Opportunity where id = :o.NE__OptyId__c LIMIT 1];
        List<XC_Address__c> listAddress = [select id, XC_PricinRegion__c, XC_AddressCountry__c, XC_PricingRegionItaly__c  from XC_Address__c where id =:op.XC_Address__c];
        listAddress[0].XC_AddressCountry__c ='Italy';
        update listAddress;
        Account acc = [SELECT ID, XC_Segment__c, XC_Source__c FROM Account WHERE Id =:op.AccountId];
        acc.XC_Segment__c = 'B2B';
        acc.XC_ReceivingChannel__c = 'Web';
        acc.XC_Source__c = 'BLOG';
        update acc;
        /*
        Id recordTypeIdChile =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        listopp[0].RecordTypeId = recordTypeIdChile;
        listopp[0].XC_LegalEntity__c = 'EnelXItalia';
        listopp[0].XC_Segment__c = 'B2B';
        listopp[0].Name ='Opportunity B2B';
        listopp[0].XC_BusinessLine__c = 'eMobility';
        listopp[0].XC_ProductCategory__c = 'eMobility';
        listopp[0].XC_BillingModel__c = 'One Shot';
        listopp[0].XC_ContractType__c = 'B2G Standard Contracts';
        listopp[0].XC_PrincingRegion__c = 'Default';
        */
        //Opportunity op = new Opportunity();
        //op = listopp[0];
        
        op.XC_SalesChannel__c = 'Enel X KAM';
        op.XC_BusinessModel__c='Spot Sale';
        op.XC_ProductCategoryOfInterest__c = 'Demand Response';
        op.XC_ProductCategory__c = 'DR';
        op.XC_BusinessLine__c = 'eIndustry';
        op.XC_LegalEntity__c= 'EnelXItalia';
        op.XC_BillingModel__c = 'One Shot';
        op.XC_Segment__c = 'B2B';
        op.XC_RevenueFullLife__c=50.1;
        op.XC_GrossMarginFullLife__c=30.1;
        op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();

        date startDate = date.newInstance(2020, 12, 17);
        date endDate = date.newInstance(2025, 12, 17);
        Map<Id,Opportunity>mapOld = new Map<Id,Opportunity>();

            mapOld.put(op.id,op);

        op.XC_ContractualRevenueEndDate__c = endDate;
        op.XC_ContractualRevenueStartDate__c = startDate;
        op.XC_RevenueFullLife__c = 66;
        //op.XC_ProductCategoryOfInterest__c = 'Software License';
        op.XC_ContractType__c = 'Simple Contracts';
        op.XC_Source__c = 'Advertisement';
        update op;
        List<Contract> c = XC_DF_Contract.createContracts(1);
        c[0].Opportunity__c = op.id;
        c[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId();
        insert c;
        Map<Id,Opportunity> mapNew = new Map<Id,Opportunity>();

            mapNew.put(op.id,op);

        update op;
        op.XC_ContractType__c = 'B2G Standard Contracts';
        update op;
        //insert mapNew.values();
        //XC_TR_Opportunity_U_updateContract.updateContract(mapNew,mapOld);

    }

}
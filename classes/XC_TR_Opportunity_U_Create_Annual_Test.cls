/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/

@istest
public with sharing class XC_TR_Opportunity_U_Create_Annual_Test {
    static testMethod void insertOpp(){
        List<Opportunity> listopp = XC_DF_Opportunity.createOpportunity(1,false);

        Id recordTypeIdChile =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Chile').getRecordTypeId();
        listopp[0].RecordTypeId = recordTypeIdChile;
        listopp[0].XC_LegalEntity__c = 'EnelX';
        listopp[0].XC_Segment__c = 'B2B';
        listopp[0].Name ='Opportunity B2B';
        listopp[0].XC_BusinessLine__c = 'eIndustry';
        date startDate = date.newInstance(2020, 12, 17);
        date endDate = date.newInstance(2025, 12, 17);
        Map<Id,Opportunity>mapOld = new Map<Id,Opportunity>();
        for(Opportunity op : listopp){
            mapOld.put(op.id,op);
        }
        listopp[0].XC_ContractualRevenueEndDate__c = endDate;
        listopp[0].XC_ContractualRevenueStartDate__c = startDate;
        listopp[0].XC_RevenueFullLife__c = 66;
        listopp[0].XC_ProductCategoryOfInterest__c = 'Consulting';
       // listopp[0].XC_RevenueFullLife__c = 66;
        //insert listopp;
        Map<Id,Opportunity> mapNew = new Map<Id,Opportunity>();
        for(Opportunity op : listopp){
            mapNew.put(op.id,op);
        }
        XC_TR_Opportunity_U_Create_Annual_Rev.createARonAfterInsert(mapNew);
        XC_TR_Opportunity_U_Create_Annual_Rev.createARonAfterUpdate(mapNew,mapOld);

    }
    static testMethod void insertOpp2(){
        List<Opportunity> listopp = XC_DF_Opportunity.createOpportunity(1,false);

        Id recordTypeIdChile =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Chile').getRecordTypeId();
        listopp[0].RecordTypeId = recordTypeIdChile;
        listopp[0].XC_LegalEntity__c = 'EnelX';
        listopp[0].XC_Segment__c = 'B2B';
        listopp[0].Name ='Opportunity B2B';
        listopp[0].XC_BusinessLine__c = 'eCity';
        date startDate = date.newInstance(2020, 12, 17);
        date endDate = date.newInstance(2025, 12, 17);
        Map<Id,Opportunity>mapOld = new Map<Id,Opportunity>();
        for(Opportunity op : listopp){
            mapOld.put(op.id,op);
        }
        listopp[0].XC_ContractualRevenueEndDate__c = endDate;
        listopp[0].XC_ContractualRevenueStartDate__c = startDate;
        listopp[0].XC_RevenueFullLife__c = 66;
        listopp[0].XC_ProductCategoryOfInterest__c = 'Consulting';
       // listopp[0].XC_RevenueFullLife__c = 66;
        //insert listopp;
        Map<Id,Opportunity> mapNew = new Map<Id,Opportunity>();
        for(Opportunity op : listopp){
            mapNew.put(op.id,op);
        }
        XC_TR_Opportunity_U_Create_Annual_Rev.createARonAfterInsert(mapNew);
        XC_TR_Opportunity_U_Create_Annual_Rev.createARonAfterUpdate(mapNew,mapOld);

    }

}
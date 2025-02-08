/**
 * Created by dolombardi on 25/11/2020.
 */
@isTest
public with sharing class XC_TR_Configuration_U_CongaWFCusOb_TEST {
    static testMethod void congaTemplateIdForQuote_Test() {
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true);
        //opp[0].recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Chile').getRecordTypeId();
        insert opp;

        NE__Order__c o = XC_DF_Order.createOrder('InOrder');
        o.NE__OptyId__c = opp[0].Id;
        o.XC_LegalEntity__c = 'EnelX';
        o.XC_Country__c = 'Chile';
        o.XC_Segment__c = 'B2B';
        o.XC_GenerateQuoteDocument__c = true;
        o.XC_Status__c = 'In Progress';
        o.recordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Order_RecordTypeQuote).getRecordTypeId();

        update o;
        //NA 0603 add field XC_Country__c
        List<NE__Order__c> listOrde = [
                select id, XC_GenerateQuoteDocument__c, XC_Segment__c, NE__AccountId__r.XC_SohoType__c,NE__AccountId__r.XC_Country__c, XC_LegalEntity__c,XC_Country__c,recordTypeId, XC_Status__c
                from ne__order__c
                where id = :o.id
                and NE__Type__c = 'InOrder'
        ];
        Account a = [select id,XC_DocumentCountry__c,XC_SohoType__c,XC_Country__c from account where id = :o.NE__AccountId__c limit 1];


        //listOrde[0].NE__AccountId__r.XC_SohoType__c = 'B2B';
        a.XC_DocumentCountry__c = 'Chile';
        a.XC_SohoType__c = 'B2B';
        //listOrde[0].NE__AccountId__r.XC_Country__c = 'Chile';
        a.XC_Country__c = 'Chile';
        NE__OrderItem__c confitem = XC_DF_OrderItem.createOrderItem(o);
        confitem.NE__OrderId__c = listOrde[0].id;
        //confitem.NE__ProdId__c='a2b1w00000091BvAAI';
        insert confitem;


        update a;
        XC_CongaTemplateMapping__c cm = new XC_CongaTemplateMapping__c ();
        cm.XC_AccountType__c = 'B2B';
        cm.XC_Country__c = 'Chile';
        cm.XC_LegalEntity__c = 'EnelX';
        cm.XC_Bundle__c = true;
        cm.XC_CommercialProduct__c = confitem.NE__ProdId__c;
        cm.XC_CongaIdTemplate__c = 'a4h0D000000Wq5NQAS';
        cm.XC_CongaQuery__c = '[AccountType]a4Z9E00000057xgUAA,[AddressOrder]a4Z9E00000057xlUAA,[OrderQuery]a4Z1w0000001X7wEAE';
        insert cm;
        Map<id,NE__Order__c> mapNew = new Map<id,NE__Order__c>(listOrde);
        Map<id,NE__Order__c> mapOld = new Map<id,NE__Order__c>();
        for(NE__Order__c  order : mapNew.values()){
            NE__Order__c cloned = order.clone(true,false,true,true);
            cloned.XC_GenerateQuoteDocument__c = false;
            cloned.Id= order.Id; 
            mapOld.put(cloned.id, cloned);
        }
        
        XC_TR_Configuration_U_CongaWFCustomObj.checkRecordTypeForQuote(listOrde,mapOld,mapNew);
        listOrde[0].recordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        XC_TR_Configuration_U_CongaWFCustomObj.checkRecordTypeForQuote(listOrde,mapOld,mapNew);
    }


}
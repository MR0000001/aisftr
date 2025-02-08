/**
 * Created by dolombardi on 05/08/2021.
 */
@isTest
public with sharing class XC_TR_ConfiguratiItem_DurationField_Test{
    static testMethod void submitTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        update o;

        List<NE__OrderItem__c> itemList = [SELECT id, XC_Billing_Period_Recurring__c, XC_Effective_Start_Date_Recurring__c, NE__CatalogItem__c,NE__OrderId__r.name, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c, NE__EndDate__c, NE__StartDate__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_Billing_Period_Recurring__c=12;
        itemList[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        update itemList;
        itemList[0].XC_Billing_Period_Recurring__c=24;
        itemList[0].XC_Effective_Start_Date_Recurring__c = Date.today().addDays(1);
        itemList[0].NE__StartDate__c =Date.today();
        itemList[0].NE__StartDate__c =Date.today().addDays(1);
        itemList[0].NE__EndDate__c =Date.today().addDays(2);
		
        update itemList;


    }
    static testMethod void changeorder(){
         //insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        o.NE__Type__c = 'ChangeOrder';
        update o;
        List<NE__OrderItem__c> itemList = [SELECT id, XC_Billing_Period_Recurring__c, NE__Qty__c, XC_Effective_Start_Date_Recurring__c, NE__CatalogItem__c,NE__OrderId__r.name, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_Billing_Period_Recurring__c=12;
        itemList[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        itemList[0].NE__StartDate__c =Date.today().addDays(1);
        itemList[0].NE__EndDate__c =Date.today().addDays(2);
        itemList[0].NE__RecurringChargeFrequency__c = 'Monthly';
        update itemList;
        NE__OrderItem__c neClone = itemList[0].clone(false,true,true,true);
        neClone.NE__Parent_Order_Item__c = itemList[0].id;
        neClone.NE__Action__c = 'Add';
        neClone.NE__Qty__c =1;
        neClone.NE__StartDate__c =Date.today();
        insert neClone;
        update itemList;
        neClone.XC_Billing_Period_Recurring__c = 2;
        neClone.NE__StartDate__c =Date.today().addDays(1);
        update neClone;
        Integer i = 0;
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Monthly');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Annual');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Bi-Monthly');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Four-Monthly');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Biennial');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Biannual');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Quarter');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('d');
    }
    
    static testMethod void orderChildUpd(){
        System.debug('@@@ orderChildUpd' );
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c o = XC_DF_Order.createOrder('InOrder');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        Id ord = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        o.RecordTypeId = ord; 
        update o;
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        System.debug('@@@@order-->' +o);
        Contract contr = new Contract();
        contr.Opportunity__c = oppList.get(0).Id;
		contr.AccountId = o.NE__AccountId__c;
        contr.StartDate = System.today().addDays(-1);
        insert contr;
        System.debug('@@@@contr-->' +contr);
        List<NE__OrderItem__c> itemList = [SELECT id, XC_Billing_Period_Recurring__c, NE__Qty__c, XC_Effective_Start_Date_Recurring__c, NE__CatalogItem__c,NE__OrderId__r.name, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c where NE__OrderId__c = :o.id];
        itemList[0].XC_Billing_Period_Recurring__c=12;
        itemList[0].XC_Effective_Start_Date_Recurring__c = Date.today();
        itemList[0].NE__StartDate__c =Date.today().addDays(1);
        itemList[0].NE__EndDate__c =Date.today().addDays(2);
        itemList[0].NE__RecurringChargeFrequency__c = 'Monthly';
        update itemList;
        NE__OrderItem__c neClone = itemList[0].clone(false,true,true,true);
        neClone.NE__Parent_Order_Item__c = itemList[0].id;
        neClone.NE__Action__c = 'Add';
        neClone.NE__Qty__c =1;
        neClone.NE__StartDate__c =Date.today();
        insert neClone;
        update itemList;
        neClone.XC_Billing_Period_Recurring__c = 2;
        neClone.NE__StartDate__c =Date.today().addDays(1);
        update neClone;
        Integer i = 0;
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Monthly');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Annual');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Bi-Monthly');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Four-Monthly');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Biennial');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Biannual');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('Quarter');
         i =  XC_TR_ConfigurationItem_U_DurationField.getRecurringNumberOfMonths('d');
    }
	
       static testMethod void updateTestMethod(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        NE__Order__c o = XC_DF_Order.createOrder('test');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        update o; 
           
        Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c> ([SELECT id,  NE__StartDate__c,NE__EndDate__c,XC_RecurringDuration__c    from NE__OrderItem__c where NE__OrderId__c = :o.id]);
		Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
           for (NE__OrderItem__c oiOld : mapOld.values()){ 
            oiOld .NE__StartDate__c = Date.today().addDays(2);
            
            NE__OrderItem__c oiNew = new NE__OrderItem__c();
            oiNew.id = oiOld.id;
            oiNew.NE__StartDate__c = Date.today().addDays(1); 
            oiNew.NE__EndDate__c = oiOld.NE__EndDate__c;
            oiNew.XC_RecurringDuration__c = 3;			
			mapNew.put(oiOld.Id, oiNew);
		} 
		System.debug('mapOld'+mapOld);
        System.debug('mapNew'+mapNew);
        Test.startTest();
        XC_TR_ConfigurationItem_U_DurationField.updateEndDate(mapOld,mapNew);
        Test.stopTest();
    }

    static testMethod void setRecurringDurationFromDate_Test(){
        Test.startTest();
        Id ordRT = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        NE__Order__c o = XC_DF_Order.createOrder('InOrder');
        o.XC_Segment__c='B2B';
        o.XC_LegalEntity__c='EnelXItalia';
        o.XC_PlantOwnership__c='Enel';
        o.RecordTypeId = ordRT; 
        update o; 

        List<NE__Order__c> ordList = [SELECT Id, NE__OptyId__c, NE__AccountId__c FROM NE__Order__c WHERE Id =: o.Id]; 
        Id oppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B_Opportunity_Italy').getRecordTypeId();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id =: ordList.get(0).NE__OptyId__c];  
        oppList.get(0).XC_Segment__c = 'B2B';
        oppList.get(0).RecordTypeId = oppRT;
        oppList.get(0).XC_Source__c = 'Web';
        update oppList;

        List<Contract> con = XC_DF_Contract.createContracts(1);
        con.get(0).AccountId = ordList.get(0).NE__AccountId__c;
        con.get(0).Opportunity__c = ordList.get(0).NE__OptyId__c;
        con.get(0).StartDate = System.today().addDays(-1);
        insert con;

        List<NE__OrderItem__c> oiList = [SELECT Id, NE__Parent_Order_Item__c, NE__StartDate__c, NE__EndDate__c, NE__Account__c FROM NE__OrderItem__c WHERE NE__OrderId__c =: o.Id];

        NE__OrderItem__c oiChild = new NE__OrderItem__c();
        oiChild.NE__Parent_Order_Item__c = oiList.get(0).id;
        oiChild.NE__Action__c = 'Add';
        oiChild.NE__Qty__c =1;
        oiChild.NE__StartDate__c =Date.today();
        oiChild.NE__Account__c = oiList.get(0).NE__Account__c;
        oiChild.NE__OrderId__c = o.Id;
        insert oiChild;

        oiList.get(0).NE__Parent_Order_Item__c = null;
        oiList.get(0).NE__StartDate__c =Date.today().addDays(1);
        oiList.get(0).NE__EndDate__c =Date.today().addDays(2);
        update oiList;
        Test.stopTest();
    }
}
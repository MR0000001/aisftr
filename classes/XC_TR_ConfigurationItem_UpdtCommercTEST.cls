@isTest
public without sharing class XC_TR_ConfigurationItem_UpdtCommercTEST{

    static testMethod void checkCostValueUpdate(){
        test.startTest();

        RecordType techItem = [Select id from RecordType Where DeveloperName = 'Technical_Item' AND SobjectType = 'NE__OrderItem__c' ];
        List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        //listNew[0].XC_ParentCommercialItem__c= listNew[].id;
        listNew[0].NE__One_Time_Cost__c= 10;
        listNew[0].NE__Qty__c = 1;
        listNew[0].Recordtypeid = techItem.id;
        insert listNew;

        listNew[0].XC_ParentCommercialItem__c= listNew[1].id;
        update listNew[0];

        //NE__OrderItem__c olditem =  listNew[0].clone(true,false,false,false);
        NE__Order_Item_Attribute__c attri = new NE__Order_Item_Attribute__c();
        attri.name ='cost';
        attri.NE__Order_Item__c= listNew[1].id;
        attri.NE__Value__c = '10';
        insert attri;


        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
        mapOld.put(listNew[0].id, listNew[0]);

        XC_TR_ConfigurationItem_UpdtCommercItem.calculateCommercialItemCost(mapOld);

        test.stopTest();
    }

}
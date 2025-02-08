@istest
public class XC_TR_ConfigurationItem_U_Attribut_TEST {
    static testMethod void checkForCostValueUpdate(){
    test.startTest();
        List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        listNew[0].NE__One_Time_Cost__c=0;
        listNew[0].XC_ParentCommercialItem__c= listNew[0].id;
        insert listNew;
        listNew[0].XC_ParentCommercialItem__c= listNew[1].id;
		update listNew;
        NE__OrderItem__c olditem =  listNew[0].clone(true,false,false,false);   
        NE__Order_Item_Attribute__c attri = new NE__Order_Item_Attribute__c();
        attri.name ='cost';
        attri.NE__Order_Item__c= listNew[0].id;
        insert attri;
        listNew[0].NE__One_Time_Cost__c=1;
        update listNew;
        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
        mapOld.put(olditem.id,olditem);
        Map<id,NE__OrderItem__c> mapNew= new Map <id,NE__OrderItem__c>();
        mapNew.put(listNew.get(0).id,listNew.get(0));
        XC_TR_ConfigurationItem_U_AttributesUpd.checkForCostValueUpdate(listNew,mapOld,mapNew);
    
    test.stopTest();
    }
     static testMethod void updateOneTimeCostOncommercialItem(){
    test.startTest();
        Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('Technical_Item').getRecordTypeId();
        List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        listNew[0].NE__One_Time_Cost__c=0;
        listNew[0].XC_ParentCommercialItem__c=listNew[0].id; 
        insert listNew;
        NE__OrderItem__c olditem =  listNew[0].clone(true,false,false,false);   
        NE__Order_Item_Attribute__c attri = new NE__Order_Item_Attribute__c();
        attri.name ='cost';
        attri.NE__Order_Item__c= listNew[0].id;
        insert attri;
        Id rtId = Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('Technical_Item').getRecordTypeId();
        listNew[0].XC_ParentCommercialItem__c=listNew[1].id;
        listNew[0].NE__Qty__c=1;
        listNew[0].NE__One_Time_Cost__c=1;
        listNew[0].RecordTypeId = rtId;
         
        update listNew;
        system.debug('parent'+''+ listNew[0].XC_ParentCommercialItem__c);
        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
        mapOld.put(olditem.id,olditem);
        Map<id,NE__OrderItem__c> mapNew= new Map <id,NE__OrderItem__c>();
        mapNew.put(listNew.get(0).id,listNew.get(0));
        XC_TR_ConfigurationItem_U_AttributesUpd.updateOneTimeCostOncommercialItem(mapOld,mapNew);    
    test.stopTest();
    }
      static testMethod void updateOneTimePriceOnParent(){
    test.startTest();
        List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        listNew[0].XC_BillingModel__c='One Shot';
        listNew[0].NE__Qty__c=0;
        listNew[0].NE__One_Time_Cost__c=0;
        listNew[0].NE__BaseRecurringCharge__c=0;
        listNew[0].NE__RecurringChargeOv__c=0;
        listNew[0].NE__BaseOneTimeFee__c=0;
        listNew[0].NE__OneTimeFeeOv__c=0;
        listNew[0].NE__Parent_Order_Item__c= listNew[0].id;
        insert listNew;
        NE__OrderItem__c olditem =  listNew[0].clone(true,false,false,false);  
        listNew[0].NE__Parent_Order_Item__c= listNew[1].id;
        listNew[0].NE__Qty__c=1;
        listNew[0].NE__One_Time_Cost__c=1;
        listNew[0].NE__BaseRecurringCharge__c=1;
        listNew[0].NE__RecurringChargeOv__c=1;
        listNew[0].NE__BaseOneTimeFee__c=1;
        listNew[0].NE__OneTimeFeeOv__c=1;
        update listNew; 
        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
        mapOld.put(olditem.id,olditem);
        Map<id,NE__OrderItem__c> mapNew= new Map <id,NE__OrderItem__c>();
        mapNew.put(listNew.get(0).id,listNew.get(0));
        XC_TR_ConfigurationItem_U_AttributesUpd.updateOneTimePriceOnParent(mapOld,mapNew);   
    test.stopTest();
      }
        static testMethod void rollUpPriceOnParent(){
    test.startTest();
        List<NE__OrderItem__c> listNew = XC_DF_OrderItem.createOrderItems(2);
        listNew[0].NE__Root_Order_Item__c= listNew[0].id;
        insert listNew;
        NE__OrderItem__c olditem =  listNew[0].clone(true,false,false,false); 
        listNew[0].NE__Root_Order_Item__c= listNew[1].id;
        update listNew;

        Map<id,NE__OrderItem__c> mapOld= new Map <id,NE__OrderItem__c>();
        mapOld.put(olditem.id,olditem);
        Map<id,NE__OrderItem__c> mapNew= new Map <id,NE__OrderItem__c>();
        mapNew.put(listNew.get(0).id,listNew.get(0));
        XC_TR_ConfigurationItem_U_AttributesUpd.rollUpPriceOnParent(mapOld,mapNew);   
    test.stopTest();
      }
}
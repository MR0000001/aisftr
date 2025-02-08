/**
* @author Simone Bernard sbernard@deloitte.it
* @date Creation  19/07/2021 
* @description XC_TR_ConfigurationItem_U_ManageFL_TEST – Test class for XC_TR_ConfigurationItem_U_ManageFullLife
*/ 
@isTest(SeeAllData=false)
public class XC_TR_ConfigurationItem_U_ManageFL_TEST {    
    
    static testMethod void insertItem() {
        System.debug('### ENTER IN THE METHOD');
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EnelXItalia';
        insert admin;
        System.debug('### after admin insert');
        System.runAs(admin){ 
            insert XC_DF_OneOrg.createOneOrg('Spain');
            insert new XC_CS_UtilityGlobalValues__c(Name='FullLife_Calculation_Management', Value__c = 'Demand Response');
            Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
            NE__Order__c order = new NE__Order__c();
            
            /* This method creates also the account and the related address */
            List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);            
            insert o;                        
            System.debug('### after opportunity insert');
            order.NE__Type__c = 'InOrder';
            order.NE__OptyId__c = o[0].Id;
            order.XC_DeliveryAddress__c = o[0].XC_Address__c;
            order.NE__AccountId__c = o[0].AccountId;
            order.XC_Country__c = 'Italy';
            order.XC_Segment__c = 'B2B';
            order.XC_LegalEntity__c = 'EnelXItalia';                        
            order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
            
            insert order;
            System.debug('### after order insert');
            order.XC_Segment__c = 'B2B';
            update order;
            System.debug('### after order update');
            
            
            
            //List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
            //insert orderList;
            NE__Item_Header__c Item_Header = new NE__Item_Header__c();
            insert Item_Header;
            System.debug('### after item header insert');
            NE__Catalog_Item__c cat = XC_DF_CatalogItem.createCatalogItem();
            cat.NE__Item_Header__c = Item_Header.id;
            insert cat;
            System.debug('### after catalog item 1 insert');
            NE__Catalog_Item__c cat2 = XC_DF_CatalogItem.createCatalogItem();            
            insert cat2;
            System.debug('### after catalog item 2 insert');
           
           
            
            
                     
            NE__OrderItem__c item = new NE__OrderItem__c(
                RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = order.Id,                  
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat.Id,
                XC_Installation_Address__c=o[0].XC_Address__c,
                XC_CapexFullLife__c=100,
                NE__Account__c=o[0].AccountId,
                XC_BillingModel__c = 'Recurring');                            
            
            Test.startTest();
            insert item;           
            System.debug('### after order item 1 insert');
            
            NE__OrderItem__c item2 = new NE__OrderItem__c(
                RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                XC_Product_Type__c = 'Bundle',              
                XC_Product_Subtype__c = 'Bundle',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = order.Id,
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = cat2.Id,   
                XC_Installation_Address__c=o[0].XC_Address__c,
                NE__Account__c=o[0].AccountId,
                XC_BillingModel__c = 'Capex');                            
            
            insert item2;
            System.debug('### after order item 2 insert');
            
            List<NE__OrderItem__c> listNew2 = new List<NE__OrderItem__c>();
            integer n = 2;
            for(Integer i = 0; i<n ; i++){            
                NE__OrderItem__c item3 = new NE__OrderItem__c(
                    RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                    XC_Product_Type__c = 'Bundle',              
                    XC_Product_Subtype__c = 'Bundle',           
                    NE__Status__c = 'Pending',                  
                    NE__Qty__c = 1,                           
                    NE__BaseRecurringCharge__c = 0,             
                    NE__OrderId__c = order.Id,                  
                    NE__RecurringChargeOv__c = 0,               
                    NE__CatalogItem__c = cat.Id, 
                    NE__Parent_Order_Item__c=item.id,
                    XC_Installation_Address__c=o[0].XC_Address__c,
                    NE__Account__c=o[0].AccountId,
                    XC_CapexFullLife__c=100,
                    XC_BillingModel__c = 'Recurring');            
                listNew2.add(item3);           
            }
            insert listNew2;
            System.debug('### after list of order item  insert');
            List<NE__OrderItem__c> listFinal = new List<NE__OrderItem__c>();
            
            for(NE__OrderItem__c configurationItem : listNew2) {
                mapOld.put(configurationItem.id,configurationItem);
                listFinal.add(configurationItem);
            } 
            listFinal.add(item);
            listFinal.add(item2);
            mapOld.put(item.id,item);
            mapOld.put(item2.id,item2);
            system.debug('listFinal size='+ listFinal.size());
            system.debug('mapOld.values size='+ mapOld.values().size());
            
            List<NE__Order_Item_Attribute__c> orderItemAttributes = new List<NE__Order_Item_Attribute__c>();
            List<NE__OrderItem__c> orderItems = [SELECT Id FROM NE__OrderItem__c limit 50];
            for(Integer i = 0; i<orderItems.size(); i++){
                NE__Order_Item_Attribute__c orderItemAttribute = new NE__Order_Item_Attribute__c();
                orderItemAttribute.NE__Order_Item__c = orderItems[i].Id;
                orderItemAttribute.Name = 'Cost';
                orderItemAttribute.NE__Value__c = '100';
                orderItemAttributes.add(orderItemAttribute);
            }
            
            insert orderItemAttributes;       
            System.debug('### after list of attributes insert');
           // test.startTest();
            /*XC_TR_ConfigurationItem_U_ManageFullLife.skipTestMFL();*/
            //test.stopTest();
            Test.stopTest();
        }       
    }    
    static testMethod void testDRMethod () {
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EnelXItalia';
        insert admin;
        System.runAs(admin){ 
            insert XC_DF_OneOrg.createOneOrg('Spain');
            insert new XC_CS_UtilityGlobalValues__c(Name='FullLife_Calculation_Management', Value__c = 'Demand Response');
            Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
            NE__Order__c order = new NE__Order__c();
            NE__Order__c order2 = new NE__Order__c();

            /* This method creates also the account and the related address */
            List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);            
            insert o;                        
            
            order.NE__Type__c = 'InOrder';
            order.NE__OptyId__c = o[0].Id;
            order.XC_DeliveryAddress__c = o[0].XC_Address__c;
            order.NE__AccountId__c = o[0].AccountId;
            order.XC_Country__c = 'Italy';
            order.XC_Segment__c = 'B2B';
            order.XC_LegalEntity__c = 'EnelXItalia';                        
            order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();

            order2.NE__Type__c = 'InOrder';
            order2.NE__OptyId__c = o[0].Id;
            order2.XC_DeliveryAddress__c = o[0].XC_Address__c;
            order2.NE__AccountId__c = o[0].AccountId;
            order2.XC_Country__c = 'Italy';
            order2.XC_Segment__c = 'B2B';
            order2.XC_LegalEntity__c = 'EnelXItalia';                        
            order2.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
            
            insert new List <NE__Order__c>{order,order2};
            order.XC_Segment__c = 'B2B';
            order2.XC_Segment__c = 'B2B';
            update new List <NE__Order__c>{order,order2};
            
            
            NE__Item_Header__c DemandResponse = new NE__Item_Header__c(name= 'Demand Response');
            insert DemandResponse;
            NE__Product__c DR = XC_DF_Product.createProducts(1).get(0);
            DR.name = 'Demand Response';
            DR.XC_LIC_Product_Name__c = 'Demand Response';
            insert DR;
            NE__Product__c Zone = XC_DF_Product.createProducts(1).get(0);
            Zone.name = 'Zone kW';
            Zone.XC_LIC_Product_Name__c = 'Zone kW';
            insert Zone;
            NE__Product__c Period = XC_DF_Product.createProducts(1).get(0);
            Period.name = 'Period';
            Period.XC_LIC_Product_Name__c = 'Period';
            insert Period;
            NE__Catalog_Item__c DRcitem = XC_DF_CatalogItem.createCatalogItem();
            DRcitem.NE__Item_Header__c = DemandResponse.id;
            DRcitem.NE__ProductId__c = DR.id;
            insert DRcitem;
            NE__Catalog_Item__c Zonecitem = XC_DF_CatalogItem.createCatalogItem();
            Zonecitem.NE__Item_Header__c = DemandResponse.id;
            Zonecitem.NE__ProductId__c = Zone.id;
            insert Zonecitem;
            NE__Catalog_Item__c Periodcitem = XC_DF_CatalogItem.createCatalogItem();
            Periodcitem.NE__Item_Header__c = DemandResponse.id;
            Periodcitem.NE__ProductId__c = Period.id;
            insert Periodcitem;

            NE__OrderItem__c DRitem = new NE__OrderItem__c(
                RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                XC_Product_Type__c = 'Service',              
                XC_Product_Subtype__c = 'Flexibility',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = order.Id,                  
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = DRcitem.Id,
                XC_Installation_Address__c=o[0].XC_Address__c,
                NE__Account__c=o[0].AccountId,
                XC_BillingModel__c = 'Recurring');  
                
            NE__OrderItem__c DR2item = new NE__OrderItem__c(
                RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                XC_Product_Type__c = 'Service',              
                XC_Product_Subtype__c = 'Flexibility',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = order.Id,                  
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = DRcitem.Id,
                XC_Installation_Address__c=o[0].XC_Address__c,
                NE__Account__c=o[0].AccountId,
                XC_BillingModel__c = 'Recurring');   
                
            NE__OrderItem__c DR3item = new NE__OrderItem__c(
                    RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                    XC_Product_Type__c = 'Service',              
                    XC_Product_Subtype__c = 'Flexibility',           
                    NE__Status__c = 'Pending',                  
                    NE__Qty__c = 1,                           
                    NE__BaseRecurringCharge__c = 0,             
                    NE__OrderId__c = order2.Id,                  
                    NE__RecurringChargeOv__c = 0,               
                    NE__CatalogItem__c = DRcitem.Id,
                    XC_Installation_Address__c=o[0].XC_Address__c,
                    NE__Account__c=o[0].AccountId,
                    XC_BillingModel__c = 'Recurring');
            
            
                       
            
            NE__OrderItem__c Zone1Item = new NE__OrderItem__c(
                RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                XC_Product_Type__c = 'Service',              
                XC_Product_Subtype__c = 'Flexibility',           
                NE__Status__c = 'Pending',                  
                NE__Qty__c = 1,                           
                NE__BaseRecurringCharge__c = 0,             
                NE__OrderId__c = order.Id,                  
                NE__RecurringChargeOv__c = 0,               
                NE__CatalogItem__c = Zonecitem.Id,
                XC_Installation_Address__c=o[0].XC_Address__c,
                NE__Account__c=o[0].AccountId,
                XC_BillingModel__c = 'Recurring');                            
            
            NE__OrderItem__c Zone2Item = new NE__OrderItem__c(
                    RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                    XC_Product_Type__c = 'Service',              
                    XC_Product_Subtype__c = 'Flexibility',           
                    NE__Status__c = 'Pending',                  
                    NE__Qty__c = 1,                           
                    NE__BaseRecurringCharge__c = 0,             
                    NE__OrderId__c = order.Id,                  
                    NE__RecurringChargeOv__c = 0,               
                    NE__CatalogItem__c = Zonecitem.Id,
                    XC_Installation_Address__c=o[0].XC_Address__c,
                    NE__Account__c=o[0].AccountId,
                    XC_BillingModel__c = 'Recurring');

            NE__OrderItem__c Zone3Item = new NE__OrderItem__c(
                        RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                        XC_Product_Type__c = 'Service',              
                        XC_Product_Subtype__c = 'Flexibility',           
                        NE__Status__c = 'Pending',                  
                        NE__Qty__c = 1,                           
                        NE__BaseRecurringCharge__c = 0,             
                        NE__OrderId__c = order.Id,                  
                        NE__RecurringChargeOv__c = 0,               
                        NE__CatalogItem__c = Zonecitem.Id,
                        XC_Installation_Address__c=o[0].XC_Address__c,
                        NE__Account__c=o[0].AccountId,
                        XC_BillingModel__c = 'Recurring');

            NE__OrderItem__c Zone4Item = new NE__OrderItem__c(
                            RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                            XC_Product_Type__c = 'Service',              
                            XC_Product_Subtype__c = 'Flexibility',           
                            NE__Status__c = 'Pending',                  
                            NE__Qty__c = 1,                           
                            NE__BaseRecurringCharge__c = 0,             
                            NE__OrderId__c = order2.Id,                  
                            NE__RecurringChargeOv__c = 0,               
                            NE__CatalogItem__c = Zonecitem.Id,
                            XC_Installation_Address__c=o[0].XC_Address__c,
                            NE__Account__c=o[0].AccountId,
                            XC_BillingModel__c = 'Recurring');
                       
            NE__OrderItem__c Period1Item = new NE__OrderItem__c(
                        RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                        XC_Product_Type__c = 'Service',              
                        XC_Product_Subtype__c = 'Flexibility',           
                        NE__Status__c = 'Pending',                  
                        NE__Qty__c = 1,                           
                        NE__BaseRecurringCharge__c = 0,             
                        NE__OrderId__c = order.Id,                  
                        NE__RecurringChargeOv__c = 0,               
                        NE__CatalogItem__c = Periodcitem.Id,
                        XC_Installation_Address__c=o[0].XC_Address__c,
                        NE__Account__c=o[0].AccountId,
                        XC_BillingModel__c = 'Recurring');                            
                    
            NE__OrderItem__c Period2Item = new NE__OrderItem__c(
                            RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                            XC_Product_Type__c = 'Service',              
                            XC_Product_Subtype__c = 'Flexibility',           
                            NE__Status__c = 'Pending',                  
                            NE__Qty__c = 1,                           
                            NE__BaseRecurringCharge__c = 0,             
                            NE__OrderId__c = order.Id,                  
                            NE__RecurringChargeOv__c = 0,               
                            NE__CatalogItem__c = Periodcitem.Id,
                            XC_Installation_Address__c=o[0].XC_Address__c,
                            NE__Account__c=o[0].AccountId,
                            XC_BillingModel__c = 'Recurring');

            NE__OrderItem__c Period3Item = new NE__OrderItem__c(
                        RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                        XC_Product_Type__c = 'Service',              
                        XC_Product_Subtype__c = 'Flexibility',           
                        NE__Status__c = 'Pending',                  
                        NE__Qty__c = 1,                           
                        NE__BaseRecurringCharge__c = 0,             
                        NE__OrderId__c = order.Id,                  
                        NE__RecurringChargeOv__c = 0,               
                        NE__CatalogItem__c = Periodcitem.Id,
                        XC_Installation_Address__c=o[0].XC_Address__c,
                        NE__Account__c=o[0].AccountId,
                        XC_BillingModel__c = 'Recurring');

            NE__OrderItem__c Period4Item = new NE__OrderItem__c(
                        RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                        XC_Product_Type__c = 'Service',              
                        XC_Product_Subtype__c = 'Flexibility',           
                        NE__Status__c = 'Pending',                  
                        NE__Qty__c = 1,                           
                        NE__BaseRecurringCharge__c = 0,             
                        NE__OrderId__c = order.Id,                  
                        NE__RecurringChargeOv__c = 0,               
                        NE__CatalogItem__c = Periodcitem.Id,
                        XC_Installation_Address__c=o[0].XC_Address__c,
                        NE__Account__c=o[0].AccountId,
                        XC_BillingModel__c = 'Recurring');
            Test.startTest();
            insert new List <NE__OrderItem__c> {DRitem,DR2item,DR3item,Zone1Item,Zone2Item,Zone3Item,Zone4Item,Period1Item,Period2Item,Period3Item,Period4Item};
            Period1Item.NE__Parent_Order_Item__c = Zone1Item.id;
            Period1Item.NE__Root_Order_Item__c = DRitem.id;
            Period1Item.XC_RevenueFullLife__c = 1000;
            Period1Item.XC_GrossMarginFullLife__c = 1000;
            Period2Item.NE__Parent_Order_Item__c = Zone2Item.id;
            Period2Item.NE__Root_Order_Item__c = DRitem.id;
            Period2Item.XC_RevenueFullLife__c = 1000;
            Period2Item.XC_GrossMarginFullLife__c = 1000;
            Period3Item.NE__Parent_Order_Item__c = Zone3Item.id;
            Period3Item.NE__Root_Order_Item__c = DR2item.id;
            Period3Item.XC_RevenueFullLife__c = 1000;
            Period3Item.XC_GrossMarginFullLife__c = 1000;
            Period4Item.NE__Parent_Order_Item__c = Zone4Item.id;
            Period4Item.NE__Root_Order_Item__c = DR3item.id;
            Period4Item.XC_RevenueFullLife__c = 1000;
            Period4Item.XC_GrossMarginFullLife__c = 1000;
            Zone1Item.NE__Parent_Order_Item__c = DRitem.id;
            Zone1Item.NE__Root_Order_Item__c = DRitem.id;
            Zone2Item.NE__Parent_Order_Item__c = DRitem.id;
            Zone2Item.NE__Root_Order_Item__c = DRitem.id;
            Zone3Item.NE__Parent_Order_Item__c = DR2item.id;
            Zone3Item.NE__Root_Order_Item__c = DR2item.id;
            Zone4Item.NE__Parent_Order_Item__c = DR3item.id;
            Zone4Item.NE__Root_Order_Item__c = DR3item.id;
            update new List <NE__OrderItem__c> {Zone1Item,Zone2Item,Zone3Item,Zone4Item,Period1Item,Period2Item,Period3Item,Period4Item};
            Period1Item.XC_RevenueFullLife__c = 1500;
            Period2Item.XC_RevenueFullLife__c = 1500;
            Period3Item.XC_RevenueFullLife__c = 1500;
            Period4Item.XC_RevenueFullLife__c = 1500;
            Period1Item.XC_GrossMarginFullLife__c = 1500;
            Period2Item.XC_GrossMarginFullLife__c = 1500;
            Period3Item.XC_GrossMarginFullLife__c = 1500;
            Period4Item.XC_GrossMarginFullLife__c = 1500;
            

            update new List <NE__OrderItem__c> {Zone1Item,Period1Item,Period2Item,Period3Item,Period4Item};

            delete Period1Item;
            Test.stopTest();
        }
    }
    
    static testMethod void test_skipTestMFL () {
        XC_TR_ConfigurationItem_U_ManageFullLife.skipTestMFL();
    }
}
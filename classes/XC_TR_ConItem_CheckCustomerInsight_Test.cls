@isTest
    public class XC_TR_ConItem_CheckCustomerInsight_Test {
        static testMethod void insertItem() {
                Map<Id, NE__OrderItem__c> mapOld = new Map<Id, NE__OrderItem__c>();
                NE__Order__c order = new NE__Order__c();
                
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
                
                insert order;
                order.XC_Segment__c = 'B2B';
                update order;
                System.debug(order);
                
                
                
                //List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, Label.XC_CL_Configuration_TypeInOrder);
                //insert orderList;
                NE__Item_Header__c Item_Header = new NE__Item_Header__c();
                insert Item_Header;

            NE__Catalog__c catalog = new NE__Catalog__c();
            catalog.XC_LIC_Name__c = 'Enel X Catalog B2B2G - Italy';
            insert catalog;


            NE__Catalog_Category__c catalogCat = new NE__Catalog_Category__c();
            catalogCat.XC_LIC_Category_Name__c = 'Monitoring And Verification';
            catalogCat.NE__CatalogId__c = catalog.Id;
            insert catalogCat;

            

                NE__Catalog_Category__c catalogCatchild = new NE__Catalog_Category__c();
                catalogCatchild.XC_LIC_Category_Name__c = 'Monitoring And Verification';
                catalogCatchild.NE__CatalogId__c = catalog.Id;
                catalogCatchild.NE__Parent_Category_Name__c = catalogCat.id;
                insert catalogCatchild;

                catalogCat.XC_LIC_Category_Name__c = 'Monitoring And Verification';
                update catalogCat;

                system.debug('catalogCatchild :' +catalogCatchild.id +' : ' + catalogCatchild.NE__Parent_Category_Name__c);
                system.debug('catalogCatchild :' +catalogCatchild.id +' : ' + catalogCatchild.NE__Parent_Category_Name__r.XC_LIC_Category_Name__c);
        
                
            
                NE__Catalog_Item__c cat = new NE__Catalog_Item__c();
                cat.NE__Catalog_Category_Name__c = catalogCatchild.Id;
                cat.NE__Catalog_Id__c = catalog.Id;
                cat.NE__Type__c = 'Product';
                cat.NE__Engine_Code__c = '134135';
                insert cat;
                
                
                system.debug('NE__Catalog_Item__c :' +cat.id +' : ' + cat.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.XC_LIC_Category_Name__c);
                NE__Catalog_Item__c cat2 = XC_DF_CatalogItem.createCatalogItem();            
                insert cat2;

                NE__Family__c fam = new NE__Family__c();
                fam.name = 'Price Definition';
                insert fam;

                NE__Product__c prod = new NE__Product__c();
                prod.XC_Product_Subtype__c = 'Solar Thermal';
                prod.XC_Product_Type__c = 'Equipment';
                prod.XC_LIC_Product_Name__c = 'Test';
                insert prod;
        
                NE__ProductFamily__c pfam = new NE__ProductFamily__c();
                pfam.NE__FamilyId__c = fam.id;
                pfam.NE__ProdId__c = prod.id;
                insert pfam;
        

                
                
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
                    XC_Country__c = 'Italy',
                    NE__Prodid__c=prod.id,
                    XC_RevenueFullLife__c=717.6,
                    XC_BillingModel__c = 'Recurring');                            
                
                insert item;           
                
                
                NE__OrderItem__c item2 = new NE__OrderItem__c(
                    RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                    XC_Product_Type__c = 'Bundle',              
                    XC_Product_Subtype__c = 'Bundle',           
                    NE__Status__c = 'Pending',                  
                    NE__Qty__c = 1,                           
                    NE__BaseRecurringCharge__c = 0,             
                    NE__OrderId__c = order.Id,
                    NE__Parent_Order_Item__c=item.id,
                    NE__RecurringChargeOv__c = 0,               
                    NE__CatalogItem__c = cat.Id,   
                    XC_Installation_Address__c=o[0].XC_Address__c,
                    NE__Account__c=o[0].AccountId,
                    XC_Country__c = 'Italy',
                    NE__Prodid__c=prod.id,
                    XC_RevenueFullLife__c=717.6,
                    XC_BillingModel__c = 'Capex');                            
                
                insert item2;

                    
                NE__OrderItem__c item3 = new NE__OrderItem__c(
                    RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                    XC_Product_Type__c = 'Bundle',              
                    XC_Product_Subtype__c = 'Bundle',           
                    NE__Status__c = 'Pending',                  
                    NE__Qty__c = 1,                           
                    NE__BaseRecurringCharge__c = 0,             
                    NE__OrderId__c = order.Id,
                    NE__RecurringChargeOv__c = 0, 
                    NE__Parent_Order_Item__c=item2.id,              
                    NE__CatalogItem__c = cat.Id,   
                    XC_Installation_Address__c=o[0].XC_Address__c,
                    NE__Account__c=o[0].AccountId,
                    XC_Country__c = 'Italy',
                    NE__Prodid__c=prod.id,
                    XC_RevenueFullLife__c=717.6,
                    XC_BillingModel__c = 'Capex');                            
                
                insert item3;

                    
                NE__OrderItem__c item4 = new NE__OrderItem__c(
                    RecordTypeId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId(),
                    XC_Product_Type__c = 'Bundle',              
                    XC_Product_Subtype__c = 'Bundle',           
                    NE__Status__c = 'Pending',                  
                    NE__Qty__c = 1,                           
                    NE__BaseRecurringCharge__c = 0,             
                    NE__OrderId__c = order.Id,
                    NE__Parent_Order_Item__c=item3.id,
                    NE__RecurringChargeOv__c = 0,               
                    NE__CatalogItem__c = cat.Id,   
                    XC_Installation_Address__c=o[0].XC_Address__c,
                    NE__Account__c=o[0].AccountId,
                    XC_Country__c = 'Italy',
                    NE__Prodid__c=prod.id,
                    XC_RevenueFullLife__c=717.6,
                    XC_BillingModel__c = 'Capex');                            
                
                insert item4;
                
                List<NE__Order_Item_Attribute__c> orderItemAttributes = new List<NE__Order_Item_Attribute__c>();
                List<NE__OrderItem__c> orderItems = [SELECT Id, NE__CatalogItem__c,XC_Country__c, NE__Parent_Order_Item__c ,
                                                    XC_RevenueFullLife__c                                             
                                                    FROM NE__OrderItem__c limit 4];
                
                
                
                system.debug('orderItems: '+orderItems);
                for(Integer i = 0; i<orderItems.size(); i++){
                    NE__Order_Item_Attribute__c orderItemAttribute = new NE__Order_Item_Attribute__c();
                    orderItemAttribute.NE__Order_Item__c = orderItems[i].Id;
                            if(i<=1)
                {
                    orderItemAttribute.Name = 'Cost';
                }
                else
                {
                    orderItemAttribute.Name = 'Markup %';
                }
                    orderItemAttribute.NE__Value__c = null;
                    orderItemAttributes.add(orderItemAttribute);
                    
                }
        


                
                insert orderItemAttributes;  
                
                List<NE__Order_Item_Attribute__c> testcata = [SELECT  NE__Order_Item__c,Name, NE__Value__c,NE__Order_Item__r.XC_Country__c,
                NE__Order_Item__r.NE__Parent_Order_Item__c,NE__Order_Item__r.NE__CatalogItem__r.NE__Catalog_Category_Name__r.NE__Parent_Category_Name__r.XC_LIC_Category_Name__c
                                                                        FROM NE__Order_Item_Attribute__c  WHERE NE__Value__c = null and Name IN ('Cost','Markup %') 
                                                                            order by NE__Order_Item__c,LastModifiedDate desc
                                                                        ];


                
                system.debug('orderitemsattributes: '+testcata); 
                system.debug('orderitems: '+orderitems);  
                Map<Id, NE__OrderItem__c> listNew = new Map<Id, NE__OrderItem__c>();
                for(NE__OrderItem__c oi:orderItems){
                    listNew.put(oi.id,oi);
                }  
                test.startTest();
                XC_TR_ConItem_CheckCustomerInsight.checkProductsCustomerInsight(testcata);
                XC_TR_ConItem_CheckCustomerInsight.checkProductsCustomerInsight(listNew);  
            // XC_TR_ConItem_CheckCustomerInsight.skipTestMFL();
                test.stopTest();
            
        }
    }
public without sharing class XC_TR_ConItem_CheckCustomerInsight {
    
    public static void checkProductsCustomerInsight(List<NE__Order_Item_Attribute__c> listNew) { 
        /*try{
            Set<Id> orderItemIds = new Set<Id>(); 
            for(NE__Order_Item_Attribute__c oiAttr : listNew){
                if(oiAttr.NE__Value__c == null && (oiAttr.name == 'Cost' || oiAttr.name == 'Markup %')){
                    orderItemIds.add(oiAttr.NE__Order_Item__c);
                }
            }
            if(!orderItemIds.isEmpty()){
    
                
                
                System.debug( 'orderItemIds in new class = ' + orderItemIds);
                List<NE__Order_Item_Attribute__c> orderItemAttributes = [SELECT Name,NE__Order_Item__r.NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c,NE__Value__c,NE__Order_Item__r.NE__OrderId__c, NE__Order_Item__r.XC_RevenueFullLife__c, NE__Order_Item__r.NE__Prodid__c
                                                                            FROM NE__Order_Item_Attribute__c 
                                                                            WHERE NE__Value__c = null and Name IN ('Cost','Markup %') and NE__Order_Item__c in :orderItemIds 
                                                                              	AND NE__Order_Item__r.XC_Country__c = 'Italy'
                                                                            order by NE__Order_Item__c,LastModifiedDate desc];
                if(!orderItemAttributes.isEmpty()){                                        
                    System.debug( 'orderItemAttributes in new class = ' + orderItemAttributes);
                    Map<Id,Decimal> costsMaps = new Map<Id,Decimal>();    
                    Map<Id,Decimal> markupMaps = new Map<Id,Decimal>();
                    Map<Id,Decimal> orderToRevenueMap = new Map<Id,Decimal>();
                    Set<Id> prodid= new set<Id>();

                    for(NE__Order_Item_Attribute__c oia : orderItemAttributes) {      
                        if( oia.Name == 'Cost'){
                            Decimal valueCost = oia.NE__Value__c == null ? 0: decimal.valueOf(oia.NE__Value__c);             
                            costsMaps.put(oia.NE__Order_Item__r.NE__OrderId__c, valueCost); 
                            
                        }else if( oia.Name == 'Markup %'){
                            Decimal valueMarkup = oia.NE__Value__c == null ? 0: decimal.valueOf(oia.NE__Value__c);
                            markupMaps.put(oia.NE__Order_Item__r.NE__OrderId__c, valueMarkup);
                        }
						system.debug('testRevenue: '+oia.NE__Order_Item__r.XC_RevenueFullLife__c);
                        system.debug('testRevenueOpp: '+oia.NE__Order_Item__r.NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c);
						
                        orderToRevenueMap.put(oia.NE__Order_Item__r.NE__OrderId__c, oia.NE__Order_Item__r.XC_RevenueFullLife__c); 
                        prodid.add(oia.NE__Order_Item__r.NE__Prodid__c);
                    }    
                    
                    List<NE__ProductFamily__c> result = [SELECT id, NE__FamilyId__r.name, NE__ProdId__c
                                                            FROM NE__ProductFamily__c
                                                             WHERE NE__ProdId__c IN: prodId]; 

                    Map<id, String> prodIdFamily =new Map<id, String>();
                    for(NE__ProductFamily__c i : result)
                    {
                        system.debug('i.NE__FamilyId__r.name: '+i.NE__FamilyId__r.name);
                        system.debug('i.NE__ProdId__c: '+i.NE__ProdId__c);
                        if(i.NE__FamilyId__r.name == 'Price Definition'){
                            prodIdFamily.put(i.NE__ProdId__c, i.NE__FamilyId__r.name); 
                        }
                    }  

                    List<NE__OrderItem__c> allOiList = [SELECT id, NE__OrderId__c, NE__Prodid__c 
                                                        FROM NE__OrderItem__c
                                                        WHERE NE__OrderId__c IN :orderToRevenueMap.keySet()];

                    List<NE__OrderItem__c> oi2Update = new List<NE__OrderItem__c>();
                    for(NE__OrderItem__c currentOI : allOiList) {
                        if(prodIdFamily.containsKey(currentOI.NE__Prodid__c) && (markupMaps.containsKey(currentOI.NE__OrderId__c) || costsMaps.containsKey(currentOI.NE__OrderId__c))){
                            
                            Decimal markupValue = markupMaps.containsKey(currentOI.NE__OrderId__c) && markupMaps.get(currentOI.NE__OrderId__c)  != null ? markupMaps.get(currentOI.NE__OrderId__c) : 0;
                            Decimal costValue = costsMaps.containsKey(currentOI.NE__OrderId__c) && costsMaps.get(currentOI.NE__OrderId__c)  != null ? costsMaps.get(currentOI.NE__OrderId__c) : 0;
                            
                            if(costValue == 0 && markupValue == 0){
                                oi2Update.add(new NE__OrderItem__c(id = currentOI.id, XC_GrossMarginFullLife__c = orderToRevenueMap.get(currentOI.NE__OrderId__c)));
                            }
                            
                        }           
                    }
                    if(!oi2Update.isEmpty()){
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                        update oi2Update;   
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
                        
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception:  '+ex.getMessage());
        }*/
    }

	public static void checkProductsCustomerInsight(Map<Id, NE__OrderItem__c> listNew) { 
        /*try{
            Set<Id> orderItemIds = new Set<Id>(); 
            Map<Id,Decimal> orderToRevenueMap = new Map<Id,Decimal>();
            Set<Id> prodid= new set<Id>();

            for(NE__OrderItem__c currentOI : listNew.values()){
				system.debug('currentRevenueFullLife: '+currentOI.XC_RevenueFullLife__c);
                system.debug('currentId: '+currentOI.Id);
                if(currentOI.XC_RevenueFullLife__c != null && currentOI.XC_RevenueFullLife__c !=  0){
                    orderToRevenueMap.put(currentOI.NE__OrderId__c, currentOI.XC_RevenueFullLife__c); 
                    prodid.add(currentOI.NE__Prodid__c);
                }
            }

            if(!prodid.isEmpty()){
                List<NE__ProductFamily__c> result = [SELECT id, NE__FamilyId__r.name, NE__ProdId__c
                                                            FROM NE__ProductFamily__c
                                                             WHERE NE__ProdId__c IN: prodId]; 

                Map<id, String> prodIdFamily =new Map<id, String>();
                for(NE__ProductFamily__c i : result)
                {
                    system.debug('i.NE__FamilyId__r.name: '+i.NE__FamilyId__r.name);
                    system.debug('i.NE__ProdId__c: '+i.NE__ProdId__c);
                    if(i.NE__FamilyId__r.name == 'Price Definition'){
                        prodIdFamily.put(i.NE__ProdId__c, i.NE__FamilyId__r.name); 
                    }
                }

                for(NE__OrderItem__c currentOI : listNew.values()){
                    if(prodIdFamily.containsKey(currentOI.NE__Prodid__c)){
                        orderItemIds.add(currentOI.id);
                    }
                }
                
                
                System.debug( 'orderm = ' + orderItemIds);
                List<NE__Order_Item_Attribute__c> orderItemAttributes = [SELECT Name,NE__Order_Item__r.NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c,NE__Value__c,NE__Order_Item__r.NE__OrderId__c, NE__Order_Item__r.XC_RevenueFullLife__c, NE__Order_Item__r.NE__Prodid__c
                                                                            FROM NE__Order_Item_Attribute__c 
                                                                            WHERE NE__Value__c = null and Name IN ('Cost','Markup %') and NE__Order_Item__c in :orderItemIds 
                                                                              	AND NE__Order_Item__r.XC_Country__c = 'Italy'
                                                                            order by NE__Order_Item__c,LastModifiedDate desc];
                if(!orderItemAttributes.isEmpty()){                                        
                    System.debug( 'orderItemAttributes in new class = ' + orderItemAttributes);
                    Map<Id,Decimal> costsMaps = new Map<Id,Decimal>();    
                    Map<Id,Decimal> markupMaps = new Map<Id,Decimal>();
                    

                    for(NE__Order_Item_Attribute__c oia : orderItemAttributes) {      
                        if( oia.Name == 'Cost'){
                            Decimal valueCost = oia.NE__Value__c == null ? 0: decimal.valueOf(oia.NE__Value__c);             
                            costsMaps.put(oia.NE__Order_Item__r.NE__OrderId__c, valueCost); 
                            
                        }else if( oia.Name == 'Markup %'){
                            Decimal valueMarkup = oia.NE__Value__c == null ? 0: decimal.valueOf(oia.NE__Value__c);
                            markupMaps.put(oia.NE__Order_Item__r.NE__OrderId__c, valueMarkup);
                        }					
                    }    
                    
                   

                    List<NE__OrderItem__c> allOiList = [SELECT id, NE__OrderId__c, NE__Prodid__c 
                                                        FROM NE__OrderItem__c
                                                        WHERE NE__OrderId__c IN :orderToRevenueMap.keySet()];

                    List<NE__OrderItem__c> oi2Update = new List<NE__OrderItem__c>();
                    for(NE__OrderItem__c currentOI : allOiList) {
                        if(markupMaps.containsKey(currentOI.NE__OrderId__c) || costsMaps.containsKey(currentOI.NE__OrderId__c)){
                            
                            Decimal markupValue = markupMaps.containsKey(currentOI.NE__OrderId__c) && markupMaps.get(currentOI.NE__OrderId__c)  != null ? markupMaps.get(currentOI.NE__OrderId__c) : 0;
                            Decimal costValue = costsMaps.containsKey(currentOI.NE__OrderId__c) && costsMaps.get(currentOI.NE__OrderId__c)  != null ? costsMaps.get(currentOI.NE__OrderId__c) : 0;
                            system.debug('markupValue: ' +markupValue  );
							system.debug('costValue: ' +costValue  );
							
                            if(costValue == 0 && markupValue == 0){
                                if(listNew.containsKey(currentOI.id)){
									listNew.get(currentOI.id).XC_GrossMarginFullLife__c = orderToRevenueMap.get(currentOI.NE__OrderId__c);
								}else{
									oi2Update.add(new NE__OrderItem__c(id = currentOI.id, XC_GrossMarginFullLife__c = orderToRevenueMap.get(currentOI.NE__OrderId__c)));
								}
							}
                            
                        }           
                    }
                    if(!oi2Update.isEmpty()){
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
                        update oi2Update;   
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
                        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
                        
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception:  '+ex.getMessage());
        }*/
    }
}
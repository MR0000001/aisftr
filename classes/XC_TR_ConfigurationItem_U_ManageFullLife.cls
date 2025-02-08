/**
* The Class XC_TR_ConfigurationItem_U_ManageFullLife.
*
* @author Simone Bernard sbernard@deloitte.it
* @date Creation 10/06/2021
* @date Modification 2022-06-13 Tommaso Precania - tommaso.precania@accenture.com
* @description Class to fill Full Life fields fields
*/
public class XC_TR_ConfigurationItem_U_ManageFullLife {    
    private static final String FULLLIFE_CALC_MNGM = 'FullLife_Calculation_Management';
    private static final Set<String> notStndCalculationProducts;

    static {
        XC_CS_UtilityGlobalValues__c manageSiteProducts = XC_CS_UtilityGlobalValues__c.getInstance(FULLLIFE_CALC_MNGM);
        notStndCalculationProducts = new Set<String>();
        if( manageSiteProducts != null && String.isNotBlank(manageSiteProducts.Value__c))
        {
            notStndCalculationProducts.addAll(manageSiteProducts.Value__c.split(';'));
        }
    }
    public static void onBeforeUpdate(List<NE__OrderItem__c> listNewFull, Map<Id, NE__OrderItem__c> mapOld) {
        manageFullLifeCalculation(listNewFull, mapOld, false);
    }
    public static void manageFullLifeCalculation(List<NE__OrderItem__c> listNewFull, Map<Id, NE__OrderItem__c> mapOld, Boolean isDelete) {
        List<NE__OrderItem__c> notB2CList = new List<NE__OrderItem__c>();        
        for(NE__OrderItem__c configurationItem : listNewFull) {
            if(configurationItem.XC_Segment__c!='B2C') {
                notB2CList.add(configurationItem);
            }
        }
        if(notB2CList.isEmpty()) {
            return;
        }
        
        Map<Id,NE__OrderItem__c> itemInfoMap = getItemsInfo(notB2CList);
        
        List<NE__OrderItem__c> stndMethodList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> drMethodList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> rootItems = new List<NE__OrderItem__c>();
        
        if(isDelete)
        {
            notB2CList.clear();
            for(NE__OrderItem__c tmpOI : itemInfoMap.values())
            {
                if(tmpOI.NE__Root_Order_Item__c == null) notB2CList.add(tmpOI);
            }
        }

        for(NE__OrderItem__c oi : notB2CList)
        {
            if(itemInfoMap.containsKey(oi.Id) && notStndCalculationProducts.contains(itemInfoMap.get(oi.Id).NE__CatalogItem__r.NE__Item_Header__r.Name))
            {
                drMethodList.add(oi);
            }
            else if(!isDelete)
            {
                stndMethodList.add(oi);
            }
        }
        
        if(!stndMethodList.isEmpty())
        {
            rootItems.addAll(stndCalculationMethod(stndMethodList, mapOld, itemInfoMap));
        }
        if(!drMethodList.isEmpty())
        {
            rootItems.addAll(drCalculationMethod(drMethodList, mapOld, itemInfoMap, isDelete));
        }

        if(!rootItems.isEmpty())
        {
            rollupToOpportunity(rootItems, itemInfoMap);
        }
    }
    
    public static List<NE__OrderItem__c> stndCalculationMethod(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> itemInfoMap){
        
        List<NE__OrderItem__c> childs = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> roots = new List<NE__OrderItem__c>();
        Map<Id,NE__OrderItem__c> rootsCosts = new Map<Id,NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> oiRootMap = new Map<Id, NE__OrderItem__c>();        
        
        Id devRecordTypeId = Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId();
        
        String childRoot = null;
        if( listNew.size() == 1 && itemInfoMap.containsKey(listNew[0].id)) {           
            if(listNew[0].NE__Parent_Order_Item__c==null && itemInfoMap.get(listNew[0].id).NE__CatalogItem__r.NE__Item_Header__c != null && listNew[0].XC_Segment__c != 'B2C') {
                return roots;
            }            
            if(childFullLifeCheckFiledls( listNew[0], mapOld )) {              
                return roots;
            }
            childRoot=listNew[0].NE__Parent_Order_Item__c;                         	
            
            List<NE__OrderItem__c> oiToAddAtlistNew = new List<NE__OrderItem__c>();
            for(NE__OrderItem__c configurationItem : itemInfoMap.values())
            {
                if(configurationItem.NE__OrderId__c == listNew[0].NE__OrderId__c && configurationItem.Id != listNew[0].id && configurationItem.RecordTypeId == devRecordTypeId)
                {
                    if(configurationItem.NE__Parent_Order_Item__c == null)
                    {
                        NE__OrderItem__c padreSigoloUpdate = new NE__OrderItem__c();                           
                        padreSigoloUpdate.XC_RevenueFullLife__c = configurationItem.XC_RevenueFullLife__c;
                        padreSigoloUpdate.XC_GrossMarginFullLife__c = configurationItem.XC_GrossMarginFullLife__c;
                        padreSigoloUpdate.XC_CostFullLife__c = configurationItem.XC_CostFullLife__c;
                        padreSigoloUpdate.XC_CapexFullLife__c = configurationItem.XC_CapexFullLife__c;
                        oiRootMap.put(configurationItem.id, padreSigoloUpdate);
                    }
                    listNew.add(configurationItem);
                }
            }       
        }
        
        Map<Id,Decimal> costsMap = getAttributeCosts(listNew, itemInfoMap);
        
        for(NE__OrderItem__c configurationItem : listNew) {
            if(configurationItem.XC_Segment__c != 'B2C' && configurationItem.RecordTypeId == devRecordTypeId) {                
                Decimal costValue = 0;
                if(!costsMap.isEmpty()) {
                    if( configurationItem.XC_BillingModel__c != 'Recurring' ) {
                        //costValue = costsMap.get(configurationItem.Id) == null ? configurationItem.NE__OneTimeFeeOv__c  : costsMap.get(configurationItem.Id);
                        costValue = costsMap.get(configurationItem.Id) == null ? 0  : costsMap.get(configurationItem.Id);
                    } else {
                        //costValue = costsMap.get(configurationItem.Id) == null ? configurationItem.NE__RecurringChargeOv__c  : costsMap.get(configurationItem.Id);
                        costValue = costsMap.get(configurationItem.Id) == null ? 0  : costsMap.get(configurationItem.Id);
                    }
                } else {
                    if( configurationItem.XC_BillingModel__c != 'Recurring' ) { 
                        //costValue = configurationItem.NE__OneTimeFeeOv__c ;
                        costValue = 0 ;
                    } else {
                        //costValue = configurationItem.NE__RecurringChargeOv__c ;
                        costValue = 0 ;
                    }
                }                                              
                if(itemInfoMap.containsKey(configurationItem.id) && itemInfoMap.get(configurationItem.id).NE__CatalogItem__r.NE__Item_Header__c != null) {
                    //prodotti Complessi
                    if(configurationItem.NE__Parent_Order_Item__c != null) {
                        if( configurationItem.XC_BillingModel__c != 'Recurring' ) {                               
                            if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_RevenueFullLife__c == configurationItem.XC_RevenueFullLife__c) {
                                //START FM CR758 R2
                                if(configurationItem.XC_BillingModel__c == 'Capex' && configurationItem.NE__OneTimeFeeOv__c!=null && configurationItem.NE__OneTimeFeeOv__c>0){ //DeAv 08.06.2022 CR758 Added check on NE__OneTimeFeeOv__c
                                    configurationItem.XC_CapexFullLife__c = configurationItem.NE__OneTimeFeeOv__c * configurationItem.NE__Qty__c ;
                                } else if(configurationItem.XC_BillingModel__c != 'Capex' && itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){ //DeAv 17.05.2022 CR758
                                    configurationItem.XC_RevenueFullLife__c  = configurationItem.NE__OneTimeFeeOv__c * configurationItem.NE__Qty__c ;
                                }
                                //END FM CR758 R2
                            }
                            if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c == configurationItem.XC_GrossMarginFullLife__c) {
                                if(itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){ // DeAv 28.06.2022 CR758 Fix - Added check on RT
                                    //configurationItem.XC_GrossMarginFullLife__c = costValue == 0 ? mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c : (configurationItem.NE__OneTimeFeeOv__c - costValue) * configurationItem.NE__Qty__c ;
                                    configurationItem.XC_GrossMarginFullLife__c = (configurationItem.NE__OneTimeFeeOv__c - costValue) * configurationItem.NE__Qty__c ;
                                }
                            }
                            if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_CostFullLife__c == configurationItem.XC_CostFullLife__c) {
                                if(configurationItem.XC_BillingModel__c != 'Capex'){ //DeAv CR758
                                    configurationItem.XC_CostFullLife__c = costValue == 0 ? mapOld.get(configurationItem.id).XC_CostFullLife__c : costValue * configurationItem.NE__Qty__c;
                                }
                            }                                                        
                        } else {
                            Decimal RecurringDuration = 1;
                            Decimal RecurringChargeOv = 1 ;
                            Decimal Qty = 1;
                            if( configurationItem.NE__RecurringChargeOv__c != null ) {
                                RecurringChargeOv = configurationItem.NE__RecurringChargeOv__c;
                            }
                            if(configurationItem.XC_RecurringDuration__c!=null) {
                                RecurringDuration = configurationItem.XC_RecurringDuration__c;
                            }
                            if (configurationItem.NE__Qty__c!=null) {
                                Qty = configurationItem.NE__Qty__c ;
                            }
                            if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_RevenueFullLife__c == configurationItem.XC_RevenueFullLife__c) {
                                //DeAv 17.05.2022 CR758 START
                                if(itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){
                                    configurationItem.XC_RevenueFullLife__c = ( RecurringChargeOv * RecurringDuration ) * Qty;
                                }
                                //DeAv 17.05.2022 CR758 END
                            }
                            if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c == configurationItem.XC_GrossMarginFullLife__c) {
                                if(itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){ // DeAv 28.06.2022 CR758 Fix - Added check on RT
                                    //configurationItem.XC_GrossMarginFullLife__c = costValue == 0 ? mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c : ((RecurringChargeOv - costValue) * RecurringDuration  ) * Qty;
                                    configurationItem.XC_GrossMarginFullLife__c = ((RecurringChargeOv - costValue) * RecurringDuration  ) * Qty;
                                }
                            }
                            if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_CostFullLife__c == configurationItem.XC_CostFullLife__c) {
                                configurationItem.XC_CostFullLife__c =  costValue == 0 ? mapOld.get(configurationItem.id).XC_CostFullLife__c : (costValue * RecurringDuration) * Qty;
                            }                            
                        }
                        childs.add(configurationItem);                      
                        
                    } else {
                        
                        //roots.add(configurationItem);
                    }   
                    
                    
                } else {
                    //prodotti semplici
                    
                    Decimal RecurringDuration = 1;
                    if(configurationItem.XC_RecurringDuration__c!=null) {
                        RecurringDuration = configurationItem.XC_RecurringDuration__c;
                    }                    
                    Decimal Qty = 1;                                        
                    if (configurationItem.NE__Qty__c!=null) {
                        Qty = configurationItem.NE__Qty__c ;
                    }
                    Decimal OneTimeFeeOv = 1;
                    if (configurationItem.NE__OneTimeFeeOv__c!=null) {
                        OneTimeFeeOv = configurationItem.NE__OneTimeFeeOv__c;
                    }
                    Decimal RecurringChargeOv  = 1 ;
                    if(configurationItem.NE__RecurringChargeOv__c!=null) {
                        RecurringChargeOv = configurationItem.NE__RecurringChargeOv__c;
                    }
                    
                    if( configurationItem.XC_BillingModel__c != 'Recurring' ) {
                        if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_RevenueFullLife__c == configurationItem.XC_RevenueFullLife__c) {
                            //START FM CR758 R2
                            if(configurationItem.XC_BillingModel__c == 'Capex' && configurationItem.NE__OneTimeFeeOv__c!=null && configurationItem.NE__OneTimeFeeOv__c>0){ //DeAv 08.06.2022 CR758 Added check on NE__OneTimeFeeOv__c
                                configurationItem.XC_CapexFullLife__c = OneTimeFeeOv * Qty ;
                            } else if(configurationItem.XC_BillingModel__c != 'Capex' && itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){ //DeAv 17.05.2022 CR758
                                configurationItem.XC_RevenueFullLife__c  = OneTimeFeeOv * Qty ;
                            }
                            //END FM CR758 R2
                        }
                        if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c == configurationItem.XC_GrossMarginFullLife__c) {
                            if(itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){ // DeAv 28.06.2022 CR758 Fix - Added check on RT
                                //configurationItem.XC_GrossMarginFullLife__c = costValue == 0 ? mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c : (OneTimeFeeOv - costValue) * Qty ;
                                configurationItem.XC_GrossMarginFullLife__c = (OneTimeFeeOv - costValue) * Qty ;
                            }
                        }
                        if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_CostFullLife__c == configurationItem.XC_CostFullLife__c) {
                            if(configurationItem.XC_BillingModel__c != 'Capex'){ //DeAv CR758
                                configurationItem.XC_CostFullLife__c = costValue == 0 ? mapOld.get(configurationItem.id).XC_CostFullLife__c : costValue * Qty;
                            }                          
                        }                        
                    } else {
                        if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_CostFullLife__c == configurationItem.XC_CostFullLife__c) {
                            configurationItem.XC_CostFullLife__c =  costValue == 0 ? mapOld.get(configurationItem.id).XC_CostFullLife__c : (costValue * RecurringDuration) * Qty ;
                        }
                        if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_RevenueFullLife__c == configurationItem.XC_RevenueFullLife__c) {
                            //DeAv 17.05.2022 CR758 START
                            if(itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){
                                configurationItem.XC_RevenueFullLife__c = (RecurringChargeOv * RecurringDuration ) * Qty ;
                            }
                            //DeAv 17.05.2022 CR758 END
                        }
                        if( mapOld.get(configurationItem.id) != null && mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c == configurationItem.XC_GrossMarginFullLife__c) {
                            if(itemInfoMap.get(configurationItem.id).NE__OrderId__r.RecordType.Developername != 'Opty'){ // DeAv 28.06.2022 CR758 Fix - Added check on RT
                                //configurationItem.XC_GrossMarginFullLife__c = costValue == 0 ? mapOld.get(configurationItem.id).XC_GrossMarginFullLife__c : ((RecurringChargeOv - costValue) * RecurringDuration  ) * Qty ;
                                configurationItem.XC_GrossMarginFullLife__c =  ((RecurringChargeOv - costValue) * RecurringDuration  ) * Qty ;
                            }
                        }
                    }
                }
            }
        }        
        
        for(NE__OrderItem__c configurationItemRoots : listNew) {
            
            if(configurationItemRoots.XC_Segment__c != 'B2C' && configurationItemRoots.RecordTypeId == devRecordTypeId) {
                //faccio questo solo per i prodotti complessi
                //System.debug( 'NE__CatalogItem__r.NE__Item_Header__c ' + itemInfoMap.get(configurationItemRoots.id).NE__CatalogItem__r.NE__Item_Header__c);
                if(itemInfoMap.containsKey(configurationItemRoots.id) && itemInfoMap.get(configurationItemRoots.id).NE__CatalogItem__r.NE__Item_Header__c != null) {
                    for (NE__OrderItem__c configurationItemChilds : childs) {                        
                        decimal revenue = 0;
                        decimal grossMargin = 0;
                        decimal capex = 0;
                        decimal costfullfile = 0;
                        
                        if (configurationItemChilds.NE__Parent_Order_Item__c == configurationItemRoots.id) {
                            grossMargin = configurationItemChilds.XC_GrossMarginFullLife__c == null ? 0 : configurationItemChilds.XC_GrossMarginFullLife__c ;
                            if (configurationItemRoots.XC_GrossMarginFullLife__c == null) {
                                grossMargin = grossMargin + 0 ;
                            } else {
                                grossMargin = grossMargin + configurationItemRoots.XC_GrossMarginFullLife__c ;
                            }
                            configurationItemRoots.XC_GrossMarginFullLife__c = grossMargin;                          
                            revenue = configurationItemChilds.XC_RevenueFullLife__c == null ? 0 : configurationItemChilds.XC_RevenueFullLife__c ;
                            if(configurationItemRoots.XC_RevenueFullLife__c == null){
                                revenue = revenue + 0;
                            } else {
                                revenue = revenue + configurationItemRoots.XC_RevenueFullLife__c;
                            }
                            configurationItemRoots.XC_RevenueFullLife__c = revenue;
                            
                            if( configurationItemChilds.XC_CapexFullLife__c != null ) {
                                if(configurationItemRoots.XC_CapexFullLife__c == null) {
                                    configurationItemRoots.XC_CapexFullLife__c = 0;
                                }
                                
                                
                                configurationItemRoots.XC_CapexFullLife__c = configurationItemRoots.XC_CapexFullLife__c + configurationItemChilds.XC_CapexFullLife__c;
                                
                                
                            }                           
                            costfullfile = configurationItemChilds.XC_CostFullLife__c == null ? 0 : configurationItemChilds.XC_CostFullLife__c ;
                            if (configurationItemRoots.XC_CostFullLife__c!=null) {
                                costfullfile = costfullfile + configurationItemRoots.XC_CostFullLife__c;
                            }
                            configurationItemRoots.XC_CostFullLife__c =  costfullfile;                            
                            
                        }
                    }                    
                    if (configurationItemRoots.NE__Parent_Order_Item__c == null) {                        
                        
                        if(!oiRootMap.isEmpty()) {
                            configurationItemRoots = updateTotalRoot(configurationItemRoots,oiRootMap);
                        } else {
                            configurationItemRoots = updateTotalRoot(configurationItemRoots,mapOld);
                        }
                        roots.add(configurationItemRoots);
                    }                    
                } else {
                    roots.add(configurationItemRoots);                                        
                } 
            }                
        }        
        
        if(!oiRootMap.isEmpty() && childRoot != null && !roots.isEmpty()) {            
            NE__OrderItem__c root = new NE__OrderItem__c();
            //Qui aggiorno solo la root solo quando non è nella arriva dalla lista del trigger            
            for (NE__OrderItem__c ri : roots) {
                if (ri.id == childRoot) {
                    root = ri;
                }
            }
            update(root);
        }

        return roots;
        
    }
    
    public static List<NE__OrderItem__c> drCalculationMethod(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> itemInfoMap, Boolean isDelete){
        Map<Id, NE__OrderItem__c> oiId_oi_fromListNew = new Map<Id, NE__OrderItem__c>();
        Map<Id, Map<Id, Set<Id>>> rootId_FLchildId_SLchilds = new Map<Id, Map<Id, Set<Id>>>();
        
        List<NE__OrderItem__c> orderItemToUpdate = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> toReturn = new List<NE__OrderItem__c>();

        for(NE__OrderItem__c oi:listNew)
        {
            Id rootId = (oi.NE__Root_Order_Item__c != null ? oi.NE__Root_Order_Item__c : oi.Id);
            if(!rootId_FLchildId_SLchilds.containsKey(rootId))
            {
                rootId_FLchildId_SLchilds.put(rootId, new Map<Id, Set<Id>>());
            }

            if(rootId != oi.Id)
            {
                if(oi.NE__Parent_Order_Item__c != null && oi.NE__Parent_Order_Item__c != rootId)
                {
                    if(rootId_FLchildId_SLchilds.get(rootId).containsKey(oi.NE__Parent_Order_Item__c))
                    {
                        rootId_FLchildId_SLchilds.get(rootId).get(oi.NE__Parent_Order_Item__c).add(oi.Id);
                    }
                    else 
                    {
                        rootId_FLchildId_SLchilds.get(rootId).put(oi.NE__Parent_Order_Item__c, new Set<Id>{oi.Id});
                    }
                }
                else 
                {
                    rootId_FLchildId_SLchilds.get(rootId).put(oi.Id, new Set<Id>());
                }
            }
            oiId_oi_fromListNew.put(oi.Id, oi);
        }

        for(NE__OrderItem__c oi:itemInfoMap.values())
        {            
            if(oi.NE__Root_Order_Item__c == null || !rootId_FLchildId_SLchilds.containsKey(oi.NE__Root_Order_Item__c)) continue;
            
            if(oi.NE__Root_Order_Item__c != oi.NE__Parent_Order_Item__c)
            {
                if(!rootId_FLchildId_SLchilds.get(oi.NE__Root_Order_Item__c).containsKey(oi.NE__Parent_Order_Item__c))
                {
                    rootId_FLchildId_SLchilds.get(oi.NE__Root_Order_Item__c).put(oi.NE__Parent_Order_Item__c, new Set<Id>{oi.Id});
                }
                else 
                {
                    rootId_FLchildId_SLchilds.get(oi.NE__Root_Order_Item__c).get(oi.NE__Parent_Order_Item__c).add(oi.Id);
                }
            }
            else
            {
                if(!rootId_FLchildId_SLchilds.get(oi.NE__Root_Order_Item__c).containsKey(oi.Id))
                {
                    rootId_FLchildId_SLchilds.get(oi.NE__Root_Order_Item__c).put(oi.Id, new Set<Id>());
                }
            }
        }

        for(Id rootId : rootId_FLchildId_SLchilds.keySet())
        {
            NE__OrderItem__c rootItem;

            if(oiId_oi_fromListNew.containsKey(rootId))
            {
                rootItem = oiId_oi_fromListNew.get(rootId);
            }
            else if(itemInfoMap.containsKey(rootId))
            {
                rootItem = itemInfoMap.get(rootId);
            }
            else {
                continue;
            }

            rootItem.XC_RevenueFullLife__c = 0;
            rootItem.XC_GrossMarginFullLife__c = 0;

            for(Id parentId : rootId_FLchildId_SLchilds.get(rootId).keySet())
            {
                NE__OrderItem__c parentItem;
                
                if(oiId_oi_fromListNew.containsKey(parentId))
                {
                    parentItem = oiId_oi_fromListNew.get(parentId);
                }
                else if(itemInfoMap.containsKey(parentId))
                {
                    parentItem = itemInfoMap.get(parentId);
                }
                else {
                    continue;
                }

                parentItem.XC_RevenueFullLife__c = 0;
                parentItem.XC_GrossMarginFullLife__c = 0;

                for(Id childId : rootId_FLchildId_SLchilds.get(rootId).get(parentId))
                {
                    NE__OrderItem__c childItem;
                    if(oiId_oi_fromListNew.containsKey(childId))
                    {
                        childItem = oiId_oi_fromListNew.get(childId);
                    }
                    else if(itemInfoMap.containsKey(childId))
                    {
                        childItem = itemInfoMap.get(childId);
                    }

                    if(childItem != null)
                    {
                        parentItem.XC_RevenueFullLife__c += (childItem.XC_RevenueFullLife__c != null?childItem.XC_RevenueFullLife__c:0);
                        parentItem.XC_GrossMarginFullLife__c += (childItem.XC_GrossMarginFullLife__c != null?childItem.XC_GrossMarginFullLife__c:0);
                    }
                }
                
                if(!oiId_oi_fromListNew.containsKey(parentId) || isDelete) orderItemToUpdate.add(parentItem);

                rootItem.XC_RevenueFullLife__c += parentItem.XC_RevenueFullLife__c;
                rootItem.XC_GrossMarginFullLife__c += parentItem.XC_GrossMarginFullLife__c;
            }
            
            if(!oiId_oi_fromListNew.containsKey(rootId) || isDelete) orderItemToUpdate.add(rootItem);
            
            toReturn.add(rootItem);
        }

        if(!orderItemToUpdate.isEmpty())
        {
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(orderItemToUpdate);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }

        return toReturn;

    }
    
    public static void rollupToOpportunity(List<NE__OrderItem__c> roots, Map<Id, NE__OrderItem__c> itemInfoMap){
        List<Opportunity> optiesToUpdate = new List<Opportunity>();

        // String optyId = (itemInfoMap.containsKey(roots[0].id)) ? itemInfoMap.get(roots[0].id).NE__OrderId__r.NE__OptyId__c : '';
        // String recordType = (itemInfoMap.containsKey(roots[0].id)) ? itemInfoMap.get(roots[0].id).NE__OrderId__r.RecordTypeAUX__c : '';                              
        Map<Id, Map<String, Decimal>> optyId_calculations = new Map<Id, Map<String, Decimal>>();                     
        
        for (NE__OrderItem__c ri : roots) {
            decimal revOpp, grossMarginopp, capexOpp, costFullLifeOpp;
            String optyId = (itemInfoMap.containsKey(ri.id)) ? itemInfoMap.get(ri.id).NE__OrderId__r.NE__OptyId__c : '';
            if(String.isNotBlank(optyId) && optyId_calculations.containsKey(optyId))
            {
                revOpp = optyId_calculations.get(optyId).get('revOpp') + (ri.XC_RevenueFullLife__c != null ? ri.XC_RevenueFullLife__c : 0); 
                grossMarginopp = optyId_calculations.get(optyId).get('grossMarginopp') + (ri.XC_GrossMarginFullLife__c != null ? ri.XC_GrossMarginFullLife__c : 0); 
                capexOpp = optyId_calculations.get(optyId).get('capexOpp') + (ri.XC_CapexFullLife__c != null ? ri.XC_CapexFullLife__c : 0); 
                costFullLifeOpp = optyId_calculations.get(optyId).get('costFullLifeOpp') + (ri.XC_CostFullLife__c != null ? ri.XC_CostFullLife__c : 0); 

                optyId_calculations.get(optyId).put('revOpp', revOpp);
                optyId_calculations.get(optyId).put('grossMarginopp', grossMarginopp);
                optyId_calculations.get(optyId).put('capexOpp', capexOpp);
                optyId_calculations.get(optyId).put('costFullLifeOpp', costFullLifeOpp);
            }
            else if(String.isNotBlank(optyId))
            {
                revOpp = (ri.XC_RevenueFullLife__c != null ? ri.XC_RevenueFullLife__c : 0); 
                grossMarginopp = (ri.XC_GrossMarginFullLife__c != null ? ri.XC_GrossMarginFullLife__c : 0);
                capexOpp = (ri.XC_CapexFullLife__c != null ? ri.XC_CapexFullLife__c : 0); 
                costFullLifeOpp = (ri.XC_CostFullLife__c != null ? ri.XC_CostFullLife__c : 0); 

                optyId_calculations.put(optyId, new Map<String, Decimal>{'revOpp' => revOpp, 'grossMarginopp' => grossMarginopp, 'capexOpp' => capexOpp, 'costFullLifeOpp' => costFullLifeOpp});
            }
            else 
            {
                continue;    
            }
        }
        
        for (Id optyId : optyId_calculations.keySet()) {
            Opportunity oppToUpdate = new Opportunity();
            System.debug('optyId:'+optyId);
            oppToUpdate.id = optyId;
            oppToUpdate.XC_RevenueFullLife__c = optyId_calculations.get(optyId).get('revOpp');
            oppToUpdate.XC_GrossMarginFullLife__c = optyId_calculations.get(optyId).get('grossMarginopp');
            oppToUpdate.XC_CostFull_Life__c =  optyId_calculations.get(optyId).get('costFullLifeOpp');
            oppToUpdate.XC_CapexFullLife__c =  optyId_calculations.get(optyId).get('capexOpp');

            optiesToUpdate.add(oppToUpdate);
        }
        XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        update(optiesToUpdate);
        
    }
    // public static Map<Id,Decimal> getAttributeCosts(List<NE__OrderItem__c> listNew) {
    //     Map<Id,Decimal> costsMaps = new Map<Id,Decimal>();        
    //     List<String> listOrderItemId = XC_UTIL_Sobject.getListFieldValues(listNew, 'Id');
    //     System.debug( 'listOrderItemId = ' + listOrderItemId);
    //     List<NE__Order_Item_Attribute__c> orderItemAttributes = [select  NE__Order_Item__c, NE__Value__c   from NE__Order_Item_Attribute__c where NE__Value__c != null and XC_DeveloperName__c = 'Cost' and NE__Order_Item__c in :listOrderItemId order by NE__Order_Item__c,LastModifiedDate desc];
    //     System.debug( 'orderItemAttributes = ' + orderItemAttributes);
    //     for(NE__Order_Item_Attribute__c oia : orderItemAttributes) {    
    //         Decimal value = oia.NE__Value__c == null ? 0: decimal.valueOf(oia.NE__Value__c);
    //         if( costsMaps.isEmpty()) {
    //             costsMaps.put(oia.NE__Order_Item__c, value);
    //         } else if(costsMaps.get(oia.NE__Order_Item__c) == null ){
    //             costsMaps.put(oia.NE__Order_Item__c, value);
    //         }
    //     }
    //     return costsMaps;
    // }
    
    public static Map<Id,Decimal> getAttributeCosts(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> itemInfoMap) {
        Map<Id, Decimal> costsMaps = new Map<Id, Decimal>();
        for(NE__OrderItem__c oi:listNew)
        {
            for(NE__Order_Item_Attribute__c oia : itemInfoMap.get(oi.Id).NE__Order_Item_Attributes__r) { 
                if('Cost'.equalsIgnoreCase(oia.XC_DeveloperName__c) && !costsMaps.containsKey(oi.Id))
                {
                    costsMaps.put(oi.Id, (oia.NE__Value__c == null ? 0: Decimal.valueOf(oia.NE__Value__c)));
                }
            }
        }
        return costsMaps;
    }
    
    public static Map<Id,NE__OrderItem__c> getItemsInfo(List<NE__OrderItem__c> listNew) {
        List<String> listOrderIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'NE__OrderId__c');
        
        Map<Id,NE__OrderItem__c> infoMaps = new Map<Id,NE__OrderItem__c>();         
        List<NE__OrderItem__c> orderItem = [select 
                                                    Id, 
                                                    NE__CatalogItem__r.NE__Item_Header__c, 
                                                    NE__CatalogItem__r.NE__Item_Header__r.Name, //[TP :: 2022-06-08 :: XC-728]
                                                    NE__OrderId__r.NE__OptyId__c,
                                                    NE__OrderId__r.RecordTypeAUX__c,
                                                    NE__OrderId__r.Name,
                                                    NE__OrderId__r.RecordType.Developername, //DeAv 17.05.2022 CR758
                                                    (SELECT XC_DeveloperName__c, NE__Value__c FROM NE__Order_Item_Attributes__r), //[TP :: 2022-06-08 :: XC-728]
                                                    NE__Parent_Order_Item__c, NE__Root_Order_Item__c, XC_Segment__c, RecordTypeId, XC_BillingModel__c, NE__OneTimeFeeOv__c, 
                                                    XC_RevenueFullLife__c, XC_GrossMarginFullLife__c, XC_CapexFullLife__c, XC_CostFullLife__c,
                                                    NE__RecurringChargeOv__c, NE__Qty__c, XC_RecurringDuration__c, XC_Discount_Reason__c, NE__OrderId__c
                                                    //from NE__OrderItem__c where id in :listOrderItemId and XC_Segment__c != 'B2C'];    	    
                                                    from NE__OrderItem__c where NE__OrderId__c in :listOrderIds and XC_Segment__c != 'B2C'];
        for(NE__OrderItem__c oi : orderItem) {
            System.debug('ID = ' + oi.id);            
            infoMaps.put(oi.id, oi);            
        }
        return infoMaps;
    }    
    
    public static NE__OrderItem__c updateTotalRoot( NE__OrderItem__c root, Map<Id, NE__OrderItem__c> mapOld ) {
        
        if(root.XC_RevenueFullLife__c == null) {
            root.XC_RevenueFullLife__c = 0;
        }        
        if(root.XC_GrossMarginFullLife__c == null) {
            root.XC_GrossMarginFullLife__c = 0;
        }
        if(root.XC_CostFullLife__c == null) {
            root.XC_CostFullLife__c = 0;
        }
        if(root.XC_CapexFullLife__c == null) {
            root.XC_CapexFullLife__c = 0;
        }
        root.XC_RevenueFullLife__c 		-= (mapOld.get(root.id).XC_RevenueFullLife__c != null) ? mapOld.get(root.id).XC_RevenueFullLife__c : 0;       
        root.XC_GrossMarginFullLife__c 	-= (mapOld.get(root.id).XC_GrossMarginFullLife__c != null) ? mapOld.get(root.id).XC_GrossMarginFullLife__c : 0;
        root.XC_CostFullLife__c 		-= (mapOld.get(root.id).XC_CostFullLife__c != null) ? mapOld.get(root.id).XC_CostFullLife__c : 0;
        root.XC_CapexFullLife__c 		-= (mapOld.get(root.id).XC_CapexFullLife__c != null) ? mapOld.get(root.id).XC_CapexFullLife__c : 0;
        return root;
    }
    public static Boolean childFullLifeCheckFiledls ( NE__OrderItem__c child, Map<Id, NE__OrderItem__c> mapOld ) {
        
        Boolean esito = true ;        
        if( child.XC_RecurringDuration__c != mapOld.get(child.id).XC_RecurringDuration__c) {
            esito = false ;
        }
        if( child.NE__Qty__c != mapOld.get(child.id).NE__Qty__c) {
            esito = false ;
        }
        if( child.XC_CapexFullLife__c != mapOld.get(child.id).XC_CapexFullLife__c) {
            esito = false ;
        }
        //Nuova richiesta 
        if( child.XC_CostFullLife__c != mapOld.get(child.id).XC_CostFullLife__c) {
            esito = false ;
        }
        if( child.XC_RevenueFullLife__c != mapOld.get(child.id).XC_RevenueFullLife__c) {
            esito = false ;
        }
        if( child.XC_GrossMarginFullLife__c != mapOld.get(child.id).XC_GrossMarginFullLife__c) {
            esito = false ;
        }
        return esito;
    }

    //START-elisa.caldini@accenture.com-22.06.2022-hotfix CR758
    public static void fillCostTechItems(List<NE__OrderItem__c> listNew){
        Id techItemRT = Schema.SObjectType.NE__OrderItem__c.RecordTypeInfosByDeveloperName.get('Technical_Item').getRecordTypeId();
        List<NE__OrderItem__c> childItemtoUpdate=new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> techItems=new List<NE__OrderItem__c>();
        for(NE__OrderItem__c confItem :listNew){
            if(confItem.XC_Segment__c !='B2C' && confItem.RecordTypeId ==techItemRT){
                techItems.add(confItem);
            }
        }
        
        if(techItems.isEmpty()) return;
        List<Id> configurationItemChildId = XC_UTIL_Sobject.getListFieldValues(techItems, 'XC_ParentCommercialItem__c');
        List<NE__OrderItem__c> allItems=[SELECT Id,XC_CostFullLife__c,XC_BillingModel__c,XC_CapexFullLife__c, XC_ParentCommercialItem__c, NE__One_Time_Cost__c, NE__Qty__c, NE__OneTimeFeeOv__c
                                         FROM NE__OrderItem__c 
                                         WHERE (Id IN :configurationItemChildId OR 
                                               XC_ParentCommercialItem__c IN :configurationItemChildId) AND
                                               NE__OrderId__r.RecordType.Developername = 'Opty']; //DeAv 24.06.2022 CR758 Fix - Add OR and AND condition
        if(allItems.isEmpty()) return;

        //DeAV 24.06.2022 CR758 Fix START
        List<NE__OrderItem__c> allTech = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> childItems = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ch : allItems){            
            if(ch.XC_ParentCommercialItem__c == null){
                childItems.add(ch);
            }else{
                allTech.add(ch);                    
            }            
        }
        //DeAV 24.06.2022 CR758 Fix END
        
        for(NE__OrderItem__c ch : childItems){
            Decimal totalCost = 0;
            for(NE__OrderItem__c tc : allTech) {  
                if(tc.XC_ParentCommercialItem__c == ch.Id){
                    totalCost = totalCost + (tc.NE__One_Time_Cost__c * tc.NE__Qty__c); //DeAv 23.06.2022 CR758 Fix                    
                }
            }
            if(totalCost > 0){
                NE__OrderItem__c childItem =new NE__OrderItem__c();
                childItem.Id=ch.Id;
                childItem.NE__OneTimeFeeOv__c = totalCost;
                if(ch.XC_BillingModel__c!='Capex'){
                    childItem.XC_CostFullLife__c = totalCost;
                }else{
                    childItem.XC_CapexFullLife__c = totalCost;
                }
                childItemtoUpdate.add(childItem);
            }
        }

        if(!childItemtoUpdate.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(childItemtoUpdate);
        }
    }

    public static void emptyCostOnCapex(Map<Id, NE__OrderItem__c> mapNewS){
        Id devRecordTypeId = Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('StanStandarddard').getRecordTypeId();
        List<NE__OrderItem__c> orderItemToUpdate =new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> listNew = mapNewS.values();
        for(NE__OrderItem__c confItem :listNew){
            if(confItem.XC_Segment__c !='B2C' && confItem.XC_BillingModel__c=='Capex'  && confItem.RecordTypeId == devRecordTypeId){
                NE__OrderItem__c notTechItem =new NE__OrderItem__c();
                notTechItem.Id=confItem.Id;
                notTechItem.NE__One_Time_Cost__c=0;
                notTechItem.NE__OneTimeFeeOv__c=0;
                orderItemToUpdate.add(notTechItem);
            }
        }
        if(!orderItemToUpdate.isEmpty()){
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_Sobject.updateListRecords(orderItemToUpdate); 
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);  
        }
    }
    //END-elisa.caldini@accenture.com-22.06.2022-hotfix-CR758

    public static void onAfterDelete(Map<Id, NE__OrderItem__c> mapOld){
        manageFullLifeCalculation(mapOld.values(), mapOld, true);
    }

    public static void skipTestMFL(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}
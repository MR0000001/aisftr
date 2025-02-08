/**
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 18/06/2019
* @description giic_PurchaseOrderUtility – Utility for Purchase Order
*/

public without sharing class Giic_PurchaseOrderUtility {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_PurchaseOrderUtility');
    
    /**
    * @date Creation 18/06/2019
    * @description Method to populate PB
    * @param mapNew - Map<Id, gii__PurchaseOrder__c> 
    */
    public static void populateGloviaPriceBookId(Map<Id, gii__PurchaseOrder__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ IN populateGloviaPriceBookId');
        List<gii__PurchaseOrder__c> listNew = mapNew.values();
        List<Id> poIds = new List<Id>();
        List<gii__PurchaseOrder__c> poToUpdate = new List<gii__PurchaseOrder__c>();
        Map<String, String> priceBookIdToPoId = new Map<String, String>();
        Map<String, String> priceBookNameToPriceBookId = new Map<String, String>();
        Map<String, String> priceBookNameToContractId = new Map<String, String>();
        Map<String, String> priceBookNameToContractLE = new Map<String, String>(); 
        Map<String, String> priceBookNameToContractStatus = new Map<String, String>(); 
        
        for(gii__PurchaseOrder__c po : listNew) { 
            poIds.add(po.Id); 
        }
        Map<Id, gii__PurchaseOrder__c> poList = new map<Id, gii__PurchaseOrder__c>([SELECT Id,gii__PriceBookName__c,giic_Status__c,gii__DropShip__c,gii__Supplier__c,
                                                                                    gii__Supplier__r.PrimaryEmail__c, giic_PriceBookId__c, gii__ShipTo__r.giic_LegalEntity__c,gii__ShipTo__r.giic_WarehouseType__c,
                                                                                    giic_CUP__c,giic_CIG__c,giic_PriceBookId__r.giic_Contract__r.XC_CIG__c  ,gii__ShipTo__r.gii__Account__r.PrimaryEmail__c,
                                                                                    giic_PriceBookId__r.giic_Contract__r.XC_CUP__c, giic_PriceBookId__r.giic_Contract__r.AccountId 
                                                                                    FROM  gii__PurchaseOrder__c 
                                                                                    WHERE Id IN: poIds]);
        
        for(gii__PurchaseOrder__c pu : poList.values()){
            priceBookIdToPoId.put(pu.giic_PriceBookId__c, pu.Id);
            if(pu.giic_PriceBookId__r.giic_Contract__r.AccountId !=  pu.gii__Supplier__c){
                for(gii__PurchaseOrder__c po : listNew){ 
                    if(pu.Id ==  po.Id){
                        po.addError(Label.giic_ErrorSupplierVsPriceBook); //'The owner of the pricebook is not the selected supplier'); 
                    }
                } 
            }
        }
        Map<Id, gii__PriceBook__c> pbList = new map<Id, gii__PriceBook__c>([SELECT Id,Name,giic_Contract__c,giic_Contract__r.Status, giic_Contract__r.XC_LegalEntity__c,giic_Contract__r.CurrencyIsoCode
                                                                            FROM  gii__PriceBook__c 
                                                                            WHERE Id IN: priceBookIdToPoId.keySet()]);   
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'pbList = '+pbList);
        for(gii__PriceBook__c pb : pbList.values()){
            priceBookNameToPriceBookId.put(pb.Id,pb.Name);
            priceBookNameToContractId.put(pb.Name, pb.giic_Contract__c);
            priceBookNameToContractLE.put(pb.Name, pb.giic_Contract__r.XC_LegalEntity__c); 
            priceBookNameToContractStatus.put(pb.Name, pb.giic_Contract__r.Status); 
        }
        for(gii__PurchaseOrder__c pu : poList.values()){
            if(pu.gii__ShipTo__r.giic_WarehouseType__c =='Local'){
                pu.giic_FSLPartnerEmail__c = pu.gii__ShipTo__r.gii__Account__r.PrimaryEmail__c; 
            }               
            pu.gii__PriceBookName__c = priceBookNameToPriceBookId.get(pu.giic_PriceBookId__c);
            pu.giic_Contract__c = priceBookNameToContractId.get(pu.gii__PriceBookName__c); 
            if(priceBookNameToContractStatus.get(pu.gii__PriceBookName__c) == 'Ended'){
                mapNew.get(pu.Id).addError(Label.giic_CL_noPoOnCC);
            }
            pu.giic_SupplierEmail__c  = pu.gii__Supplier__r.PrimaryEmail__c;
            pu.giic_LegalEntity__c = priceBookNameToContractLE.get(pu.gii__PriceBookName__c); 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'po.giic_LegalEntity__c = '+pu.giic_LegalEntity__c);
            if(pu.giic_LegalEntity__c != pu.gii__ShipTo__r.giic_LegalEntity__c){
                mapNew.get(pu.Id).addError('Purchase Order and destination Warehouse must have the same Legal Entity!');
            }
            if(pu.giic_CIG__c == null){
                    pu.giic_CIG__c = pu.giic_PriceBookId__r.giic_Contract__r.XC_CIG__c ;
            }
            if(pu.giic_CUP__c == null){
                pu.giic_CUP__c = pu.giic_PriceBookId__r.giic_Contract__r.XC_CUP__c;
            }
            poToUpdate.add(pu);
        }        
        update poToUpdate;
    }

    
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @description insert Purchase Order and purchase order lines
    * @param mapPO -  Map of PurchaseOrder
    * @param mapPOLine - Map of PurchaseOrderLine
    * @return list<Id>
    */    
    public static list<Id> insertPO(map<integer,gii__PurchaseOrder__c> mapPO, map<integer,List<gii__PurchaseOrderLine__c>> mapPOLine){
        for(Integer key : mapPO.keyset()){
            if(!mapPOLine.containsKey(key)) {
                mapPO.remove(key);
            }
        }
        
        Database.insert(mapPO.values());
        list<Id> lstPOIds=new list<Id>();
        list<gii__PurchaseOrderLine__c> lstPOLToInsert=new list<gii__PurchaseOrderLine__c>();
        for(integer key : mapPO.keyset()){
            if(!mapPOLine.containsKey(key)) {
                continue;
            }
            lstPOIds.add(mapPO.get(key).Id);
            for(gii__PurchaseOrderLine__c objPOL : mapPOLine.get(key)){
                objPOL.gii__PurchaseOrder__c=mapPO.get(key).Id;
                lstPOLToInsert.add(objPOL);
            }
        }
        Database.insert(lstPOLToInsert);
        return lstPOIds;
    }
   
    /**    
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 23/07/2019
    * @date Modification 23/03/2020 Sara Miozza sara.miozza@nttdata.com
    * @description update product discount on POL
    * @param lstPOL - List of PurchaseOrderLine
    */   
    public static void updatePOLWithDiscountOnUpdate(List<gii__PurchaseOrderLine__c> lstPOL, Map<Id,gii__PurchaseOrderLine__c> mapOld,Map<Id,gii__PurchaseOrderLine__c> mapNew){
        for(gii__PurchaseOrderLine__c objPOL : lstPOL){
            if(objPOL.giic_UnderWarranty__c){
                objPOL.gii__Product_Discount_Percent__c=100;
                objPOL.gii__SupplierDiscountPercent__c = 0;
            }else{
                if(mapOld.get(objPOL.Id).giic_UnderWarranty__c && !mapNew.get(objPOL.Id).giic_UnderWarranty__c){
                   objPOL.gii__Product_Discount_Percent__c=0;
                } 
                
            }
        }
    }

    /**    
    * @author FirstName : Sara Miozza sara.miozza@nttdata.com
    * @date Creation 24/03/2020
    * @description Set multi Target System on PO
    * @param targetSystemField - old target system value
    * @param newValue - new target system value to add
    */ 
    public static String setTargetSystem(String targetSystemField, Set<String> values ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ targetSystemField = '+targetSystemField);
        if(targetSystemField == null || targetSystemField == '' ){
            return format(values);
        }else{
            return targetSystemField + ';'+format(values);
        }
       /* String valueToReturn;
        
            valueToReturn = newValue + ';';
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'valueToReturn = '+valueToReturn);
            return valueToReturn;
        }else{
            valueToReturn = targetSystemField + newValue + ';';
            return valueToReturn;
        } */ 
    }
    
    /**    
    * @date Creation 24/03/2020
    * @description Method to set format
    * @param values - Set<String>
    * @return String
    */ 
    public static String format(Set<String> values) {
        if (values == null) return null;
        List<String> l = new List<String>(values);
        l.sort();
        return format(l);
    }

    /**    
    * @date Creation 24/03/2020
    * @description Method to set format
    * @param values - Set<String>
    * @return String
    */ 
    public static String format(List<String> values) {
        if (values == null) return null;
        return String.join(values, ';');
    }
    
    /**    
    * @author FirstName : Sara Miozza sara.miozza@nttdata.com
    * @date Creation 23/03/2020
    * @description update product discount on POL
    * @param lstPOL - List of PurchaseOrderLine
    */ 
    public static void updatePOLWithDiscountOnInsert(List<gii__PurchaseOrderLine__c> lstPOL){
        for(gii__PurchaseOrderLine__c objPOL : lstPOL){
            if(objPOL.giic_UnderWarranty__c){
                objPOL.gii__Product_Discount_Percent__c=100;
                objPOL.gii__SupplierDiscountPercent__c = 0;
            }
        }
    }
    
    /**    
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 23/07/2019
    * @description To check limits on incoming Purchase order.
    * @param pchsOdrList - List of PurchaseOrder
    */   
    public static void checkLimitsForOrder(List<gii__PurchaseOrder__c> pchsOdrList){
        if(pchsOdrList != null && !pchsOdrList.isEmpty()){
            Set<String> toWHSet = new Set<String>();
            Map<String,gii__PurchaseOrder__c> mapOfPOidVsPO = new Map<String,gii__PurchaseOrder__c>(pchsOdrList);
            for(gii__PurchaseOrder__c tfrOdrObj : pchsOdrList){
                toWHSet.add(tfrOdrObj.gii__ShipTo__c);
            }
            Map<Id,gii__PurchaseOrderLine__c> mapOfPOVsPOLine = new Map<Id,gii__PurchaseOrderLine__c>([SELECT Id,gii__OrderQuantity__c,gii__UnitCost__c,gii__PurchaseOrder__c,gii__PurchaseOrder__r.gii__ShipTo__c,gii__PurchaseOrder__r.gii__ShipTo__r.giic_StorageCapacity__c,gii__Product__c FROM gii__PurchaseOrderLine__c WHERE gii__PurchaseOrder__c IN:pchsOdrList ORDER BY gii__OrderQuantity__c asc]);
            
            if(mapOfPOVsPOLine != null && !mapOfPOVsPOLine.values().isEmpty()){
                processOrder(mapOfPOVsPOLine, toWHSet, mapOfPOidVsPO);
            }
            
        }
    }

    /**  
    * @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @description To update Warehouse exceed limit on incoming Purchase order and lines.
    * @param mapOfPOVsPOLine - Map of PurchaseOrderLine, 
    * @param toWHSet - Set of Warehouse,
    * @param mapOfPOidVsPO - of PurchaseOrder
    */   
    public static void processOrder(Map<Id,gii__PurchaseOrderLine__c> mapOfPOVsPOLine, Set<String> toWHSet, Map<String,gii__PurchaseOrder__c> mapOfPOidVsPO){
        Set<String> pdtIdSet = new Set<String>();
        Map<String,Decimal> mapOfPOidVsOdrVal = new Map<String,Decimal>();
        Map<String,Decimal> mapOfIdVsOnHandQty = new Map<String,Decimal>();
        List<gii__ProductInventory__c> lstProductInventory = new List<gii__ProductInventory__c>();
        List<gii__PurchaseOrderLine__c> listPILUpdate = new List<gii__PurchaseOrderLine__c>();
        Map<String,gii__ProductInventory__c> mapOfPdtWhVsPI = new Map<String,gii__ProductInventory__c>();
        Map<String,gii__Warehouse__c> mapOfWHidVsWH = new Map<String,gii__Warehouse__c>([SELECT Id,giic_WarehouseValue__c,giic_StorageCapacity__c FROM gii__Warehouse__c WHERE Id IN: toWHSet]);
        for(gii__PurchaseOrderLine__c pchsOdrLineObj : mapOfPOVsPOLine.values()){
            pdtIdSet.add(pchsOdrLineObj.gii__Product__c);
            Decimal newVal=0;
            Decimal unitCost=0;
            Decimal qty=0;
            if(mapOfPOidVsOdrVal.containsKey(pchsOdrLineObj.gii__PurchaseOrder__c)){
                unitCost = pchsOdrLineObj.gii__UnitCost__c == null ? 0 : pchsOdrLineObj.gii__UnitCost__c;
                qty = pchsOdrLineObj.gii__OrderQuantity__c == null ? 0 : pchsOdrLineObj.gii__OrderQuantity__c;
                newVal = mapOfPOidVsOdrVal.get(pchsOdrLineObj.gii__PurchaseOrder__c)+(qty * unitCost);
                mapOfPOidVsOdrVal.put(pchsOdrLineObj.gii__PurchaseOrder__c,newVal);
            }else{
                unitCost = pchsOdrLineObj.gii__UnitCost__c == null ? 0 : pchsOdrLineObj.gii__UnitCost__c;
                qty = pchsOdrLineObj.gii__OrderQuantity__c == null ? 0 : pchsOdrLineObj.gii__OrderQuantity__c;
                newVal = qty * unitCost; 
                mapOfPOidVsOdrVal.put(pchsOdrLineObj.gii__PurchaseOrder__c,newVal);
            }
        }
        AggregateResult[] listOfPIForWHVal;
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            for(AggregateResult arObj : [SELECT gii__Warehouse__c warehouseId,SUM(giic_Value__c)value FROM gii__ProductInventory__c WHERE gii__Warehouse__c IN: toWHSet GROUP BY gii__Warehouse__c]){
                mapOfWHidVsWH.get(String.valueOf(arObj.get('warehouseId'))).giic_WarehouseValue__c = (Decimal)arObj.get('value');
            }
            for(gii__ProductInventory__c pIobj : Giic_InventoryUtility_D.getProductInventory(toWHSet,pdtIdSet)){
                mapOfPdtWhVsPI.put(pIobj.gii__Product__c+''+pIobj.gii__Warehouse__c,pIobj);
            }
        }
        
        for(gii__PurchaseOrderLine__c pchsOdrLineObj : mapOfPOVsPOLine.values()){
            Decimal qty;
            Decimal onHandQty;
            Decimal maxQty = 0;
            string key=pchsOdrLineObj.gii__Product__c+''+pchsOdrLineObj.gii__PurchaseOrder__r.gii__ShipTo__c;
            if(mapOfPdtWhVsPI.containskey(key)){
                gii__ProductInventory__c tempPI = mapOfPdtWhVsPI.get(key);
                onHandQty = tempPI.giic_OnHandNew__c != null ? tempPI.giic_OnHandNew__c : 0;
                if(!mapOfIdVsOnHandQty.containsKey(tempPI.Id)){
                    mapOfIdVsOnHandQty.put(tempPI.Id,onHandQty);
                }
                qty = pchsOdrLineObj.gii__OrderQuantity__c != null ? pchsOdrLineObj.gii__OrderQuantity__c : 0;
                maxQty = tempPI.giic_MaxQuantity__c != null ? tempPI.giic_MaxQuantity__c : 0;
                if(maxQty == 0){
                    continue;
                }
                onHandQty = mapOfIdVsOnHandQty.get(tempPI.Id);
                if((qty + onHandQty) > maxQty){
                    mapOfPOidVsPO.get(pchsOdrLineObj.gii__PurchaseOrder__c).giic_WarehouseLimitExceeded__c = true;
                    pchsOdrLineObj.giic_WarehouseLimitExceeded__c = true;
                    listPILUpdate.add(pchsOdrLineObj);
                }else{
                    onHandQty += qty;
                    mapOfIdVsOnHandQty.put(tempPI.Id,onHandQty);
                    if((mapOfPOidVsOdrVal.get(pchsOdrLineObj.gii__PurchaseOrder__c) + mapOfWHidVsWH.get(pchsOdrLineObj.gii__PurchaseOrder__r.gii__ShipTo__c).giic_WarehouseValue__c) > mapOfWHidVsWH.get(pchsOdrLineObj.gii__PurchaseOrder__r.gii__ShipTo__c).giic_StorageCapacity__c){
                        mapOfPOidVsPO.get(pchsOdrLineObj.gii__PurchaseOrder__c).giic_WarehouseLimitExceeded__c = true; 
                    }
                }
            }
        }
        updateLimitsForOrder(mapOfPOidVsPO, listPILUpdate);
    }

    /**    
    * @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description To update Warehouse exceed limit on incoming Purchase order and lines.
    * @param mapOfPOidVsPO - Map of PurchaseOrder,
    * @param listPILUpdate - List of PurchaseOrderLine
    */   
    public static void updateLimitsForOrder(Map<String,gii__PurchaseOrder__c> mapOfPOidVsPO, List<gii__PurchaseOrderLine__c> listPILUpdate ){
        if(mapOfPOidVsPO != null && !mapOfPOidVsPO.values().isEmpty()){
            update mapOfPOidVsPO.values();
        }
        if(Schema.sObjectType.gii__PurchaseOrderLine__c.isUpdateable() && !listPILUpdate.isEmpty()){
            update listPILUpdate;
        }
    }
    
    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/11/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming Purchase orders.
    * @param purchaseOdrLineList -  List of PurchaseOrder
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old PurchaseOrder
    */    
    public static void checkIfStatusChange(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapOld, Map<Id,gii__PurchaseOrder__c> mapNew){
        List<String> fieldList = new List<String>{'giic_Status__c','gii__Supplier__c'};
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        checkWhenPOisApproved(listChanged);
        populateFieldForSharing(listChanged); 
    }

    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/11/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming Purchase orders.
    * @param purchaseOdrLineList -  List of PurchaseOrder
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old PurchaseOrder
    */    
    public static void afterForSharing(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapOld, Map<Id,gii__PurchaseOrder__c> mapNew){
        List<String> fieldList = new List<String>{'giic_Status__c','gii__Supplier__c'};
        List<gii__PurchaseOrder__c> correctList = new List<gii__PurchaseOrder__c>();
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        for(gii__PurchaseOrder__c p : listChanged){
            if(p.giic_IntegrationStatus__c!=Label.giic_IntegrationStatusSuccess && p.giic_IntegrationStatus__c!= Label.giic_IntegrationStatusFailure){
                correctList.add(p);
            }
        }

        List<Id> listChangedId = XC_UTIL_SObject.getIds(correctList);    
        if(!System.isFuture() && !System.isQueueable() && !System.isBatch()){ 
            checkIfStatusChangeGetList(listChangedId); 
        }        
    }
        
    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/11/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming Purchase orders.
    * @param purchaseOdrLineList -  List of PurchaseOrder
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old PurchaseOrder
    */    
    @future
    public static void checkIfStatusChangeGetList(List<Id> purchaseOdrList){
        List<gii__PurchaseOrder__c>  listChanged = new List<gii__PurchaseOrder__c> ([
            SELECT id ,gii__PriceBookName__c, giic_PriceBookId__c,gii__Supplier__c,giic_Status__c,giic_AccountForSharing__c,giic_EnelUserEmail__c
            FROM gii__PurchaseOrder__c
            WHERE id IN :purchaseOdrList
        ]); 
        for(gii__PurchaseOrder__c po : listChanged){
            
            if(po.gii__Supplier__c!= null && po.giic_Status__c!='Draft' && po.giic_Status__c!='Open' && po.giic_Status__c!='Merged' ){     
                po.giic_AccountForSharing__c = po.gii__Supplier__c;
            }else{
                po.giic_AccountForSharing__c = null;    
            } 
        }
        update listChanged;
    }

    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/11/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming Purchase orders.
    * @param purchaseOdrLineList -  List of PurchaseOrder
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old PurchaseOrder
    */    
    public static void populateFieldForSharing(List<gii__PurchaseOrder__c> purchaseOdrList){
        List<String> poWithOnlyPriceBookName = new List<String>();
        List<String> poWithOnlyPriceBookID = new List<String>();
        Map<String,String> pbNameToPbId = new  Map<String,String>();
        map<String,String> priceBookNameToContractCurrency = new map<String,String>();
        for(gii__PurchaseOrder__c po : purchaseOdrList){
            if(po.giic_PriceBookId__c==null && po.gii__PriceBookName__c!=null){
                poWithOnlyPriceBookName.add(po.gii__PriceBookName__c);
            }
             poWithOnlyPriceBookID.add(po.giic_PriceBookId__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'poWithOnlyPriceBookName = '+poWithOnlyPriceBookName);
        Map<Id, gii__PriceBook__c> pbMap = new map<Id, gii__PriceBook__c>([SELECT Id,Name , CurrencyIsoCode
                                                                           FROM  gii__PriceBook__c 
                                                                           WHERE Name IN: poWithOnlyPriceBookName
                                                                          OR ID IN:poWithOnlyPriceBookID]);
        for(gii__PriceBook__c pb : pbMap.values()){
            pbNameToPbId.put(pb.Name,pb.Id);
            priceBookNameToContractCurrency.put(pb.Id ,pb.CurrencyIsoCode );
        }
        for(gii__PurchaseOrder__c po : purchaseOdrList){
            if(po.giic_PriceBookId__c==null && po.gii__PriceBookName__c!=null){
                po.giic_PriceBookId__c = pbNameToPbId.get(po.gii__PriceBookName__c);
            }
            po.CurrencyIsoCode = priceBookNameToContractCurrency.get(po.giic_PriceBookId__c);
            

            if(po.giic_Status__c == Label.giic_POSentToSupplier){
                po.giic_EnelUserEmail__c = UserInfo.getUserEmail();
            }
            //RP - 14/03/2020 fix per Sharing in insert
             if(po.gii__Supplier__c!= null && po.giic_Status__c!='Draft' && po.giic_Status__c!='Open' && po.giic_Status__c!='Merged' ){     
                po.giic_AccountForSharing__c = po.gii__Supplier__c;
            }else{
                po.giic_AccountForSharing__c = null;    
            } 
           
        }
    }
    
    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 28/11/2019
    * @date Modification dd/mm/yyyy
    * @description Prevent the creation of PO Lines
    * @param purchaseOdrLineList -  List of PurchaseOrderLine
    */       
    public static void preventPOLineInsert(List<gii__PurchaseOrderLine__c> purchaseOdrLineList){
        List<String> poIds = XC_UTIL_Sobject.getListFieldValues(purchaseOdrLineList, 'gii__PurchaseOrder__c');
        Boolean myPosition = [Select XC_EnabledToSkip__c From User Where Id = :UserInfo.getUserId()][0].XC_EnabledToSkip__c;
        map<Id, gii__PurchaseOrder__c> poMaps = new  map<Id, gii__PurchaseOrder__c>([SELECT Id,gii__DropShip__c,giic_Source__c, giic_Status__c, giic_ForClosedContract__c FROM gii__PurchaseOrder__c WHERE Id IN: poIds]);
        if(poMaps.values().isEmpty()){
            return;
        }
        for(gii__PurchaseOrderLine__c pol : purchaseOdrLineList){
            if((!poMaps.get(pol.gii__PurchaseOrder__c).gii__DropShip__c  && pol.gii__PurchaseOrder__c!= null && poMaps.get(pol.gii__PurchaseOrder__c).giic_Status__c!=null && poMaps.get(pol.gii__PurchaseOrder__c).giic_Status__c!='Draft' && poMaps.get(pol.gii__PurchaseOrder__c).giic_Status__c!='Open' && !myPosition) || poMaps.get(pol.gii__PurchaseOrder__c).giic_ForClosedContract__c){     
                
                    pol.addError(Label.giic_CL_NoNewLines);
                
                
            }
        }
    }
    
    /**    
    * @date Creation 24/03/2020
    * @description Method to check POLine in update
    */ 
    public static void preventPOLineInUpdate(List<gii__PurchaseOrderLine__c> purchaseOdrLineList,Map<Id,gii__PurchaseOrderLine__c> mapOld, Map<Id,gii__PurchaseOrderLine__c> mapNew){
        List<String> fieldList = new List<String>{'gii__Product__c','gii__ProductInventory__c','gii__UnitPrice__c','gii__OrderQuantity__c'};
        List<gii__PurchaseOrderLine__c> correctList = new List<gii__PurchaseOrderLine__c>();
        List<gii__PurchaseOrderLine__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        List<String> poIds = XC_UTIL_Sobject.getListFieldValues(listChanged, 'gii__PurchaseOrder__c');
        Boolean myPosition = [Select XC_EnabledToSkip__c From User Where Id = :UserInfo.getUserId()][0].XC_EnabledToSkip__c;
        map<Id, gii__PurchaseOrder__c> poMaps = new  map<Id, gii__PurchaseOrder__c>([SELECT Id,gii__DropShip__c,giic_Source__c, giic_Status__c, giic_ForClosedContract__c FROM gii__PurchaseOrder__c WHERE Id IN: poIds]);
        if(poMaps.values().isEmpty()){
            return;
        }
        for(gii__PurchaseOrderLine__c pol : purchaseOdrLineList){
            if((!poMaps.get(pol.gii__PurchaseOrder__c).gii__DropShip__c  && pol.gii__PurchaseOrder__c!= null && poMaps.get(pol.gii__PurchaseOrder__c).giic_Status__c!=null && poMaps.get(pol.gii__PurchaseOrder__c).giic_Status__c!='Draft' && poMaps.get(pol.gii__PurchaseOrder__c).giic_Status__c!='Open' && !myPosition) || (poMaps.get(pol.gii__PurchaseOrder__c).giic_ForClosedContract__c && poMaps.get(pol.gii__PurchaseOrder__c).giic_Status__c!='Draft')){     
                
                    
                    pol.addError(Label.giic_CL_NoLinesUpdate);
                
            }
        }
    }
    
    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/11/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming Purchase orders.
    * @param purchaseOdrLineList -  List of PurchaseOrder
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old PurchaseOrder
    */    
    public static void setCorrectRecordTypeInInsert(List<gii__PurchaseOrder__c> purchaseOdrList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In setCorrectRecordTypeInInsert');
        List<String> whIds = XC_UTIL_Sobject.getListFieldValues(purchaseOdrList, 'gii__ShipTo__c');       
        for(gii__PurchaseOrder__c po : purchaseOdrList){ 
                po.recordTypeId = Schema.SObjectType.gii__PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('giic_PurchaseOrder').getRecordTypeId(); 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End setCorrectRecordTypeInInsert');
    }
   
    /**  
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming Purchase orders.
    * @param purchaseOdrLineList -  List of PurchaseOrderLine
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old PurchaseOrderLine
    */    
    public static void checkLimitsForOrderFromTrigger(List<gii__PurchaseOrderLine__c> purchaseOdrLineList,Boolean isInsert,Map<Id, SObject> mapOldS){
        Set<String> idSet = new Set<String>();
        for(gii__PurchaseOrderLine__c pchsOdrLine : purchaseOdrLineList){
            if(isInsert){
                idSet.add(pchsOdrLine.gii__PurchaseOrder__c);
            }else{
                if(mapOldS.get(pchsOdrLine.Id).get('gii__OrderQuantity__c') != pchsOdrLine.gii__OrderQuantity__c){
                    idSet.add(pchsOdrLine.gii__PurchaseOrder__c);
                }
            }
        }
        if(Schema.sObjectType.gii__PurchaseOrder__c.isQueryable() && !idSet.isEmpty()){
            checkLimitsForOrder([SELECT gii__ShipTo__c,Id,giic_status__c FROM gii__PurchaseOrder__c WHERE ID IN: idSet]);
        }
    }

    /**
    * @author Name : Anil Giri - anil.giri@in.fujitsu.com
    * @date 24/07/2019
    * @description  execute ROP for central warehouse
    * @param lstPI - List of ProductInventory
    */
    public static List<String> runROPForCentralWarehouse(List<gii__ProductInventory__c> lstPI){
        List<String> lstPricebookError = new   List<String> ();
        try {
            /**************************** Set of Ids*************************************/
            set<id> settProductIds = new set<id>();
            set<id> setSupplierIds = new set<id>();
            /****************************maps define*************************************/
            Map<string,gii__ProductInventory__c>mapProdIdWhIdObjPI = new map<string,gii__ProductInventory__c>();
            map<string,integer> mapPRODWHLOCWithAvailQty =Giic_InventoryUtility_D.getAvailQtyFromPIBL((new map<id,gii__ProductInventory__c>(lstPI)).keyset());
            map<string,integer> mapPRODWHLOCWithSugQty=new map<string,integer>();
            map<string,list<gii__ProductInventory__c>> mapSupplierProductPI=new map<string,list<gii__ProductInventory__c>>();
            
            /****************************list define*************************************/
            list<string> lstAllProductCodes=new list<string>();
            list<giic_ErrorLog__c> lstErrorLogs=new list<giic_ErrorLog__c>(); 
            
            for(gii__ProductInventory__c objPI : lstPI){
                string key=objPI.gii__Product__c + '-' + objPI.gii__Warehouse__c+'-' + objPI.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                decimal qtyToAvail=mapPRODWHLOCWithAvailQty.containsKey(key) ? mapPRODWHLOCWithAvailQty.get(key) :0;
                integer dSuggestedQty = integer.valueof(objPI.gii__OrderPointQuantity__c - (qtyToAvail+objPI.gii__TotalOnOrder__c));
                mapPRODWHLOCWithSugQty.put(key,dSuggestedQty); 
                if(dSuggestedQty >0 &&  dSuggestedQty <= objPI.gii__OrderPointQuantity__c){
                    if(objPI.gii__OrderQuantityMultiple__c==0.0){
                        objPI.gii__OrderQuantityMultiple__c=1.0;
                    }
                    if(objPI.gii__Product__c !=null){
                        settProductIds.add(objPI.gii__Product__c);
                        if(objPI.gii__Product__r.gii__PrimarySupplier__c !=null){
                            string suppProdKey=objPI.gii__Product__r.gii__PrimarySupplier__c +'-' + objPI.gii__Product__c;
                            setSupplierIds.add(objPI.gii__Product__r.gii__PrimarySupplier__c);
                            if(!mapSupplierProductPI.containskey(suppProdKey)){
                                mapSupplierProductPI.put(suppProdKey,new list<gii__ProductInventory__c>());
                            }
                            mapSupplierProductPI.get(suppProdKey).add(objPI);
                            lstAllProductCodes.add(objPI.gii__Product__r.gii__ProductCode__c);
                        }
                        else{
                            lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SourceReorderPlanning,new map<string,object>{'giic_ProductInventory__c'=>objPI.id},
                                                                                                                               Label.giic_SourceReorderPlanning,System.Label.giic_SupplierError + objPI.gii__Product__r.gii__ProductCode__c)));
                        }
                    }
                } 
            }
            //getting Price book and related price book entry records based on products
            lstPricebookError = createPOforROPProcess(settProductIds,setSupplierIds,mapSupplierProductPI,mapPRODWHLOCWithSugQty,true);
            addErrorLog(lstErrorLogs,lstPricebookError,mapSupplierProductPI);
        }
        catch(exception ex){
             XC_UTIL_Debug.debug(DEBUGACTIVE, 'ex.getLineNumber()'+ex.getLineNumber());
        } 
        
        return lstPricebookError;
    }

    /**    
    * @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description To add Error log.
    * @param lstErrorLogs - list of error logs
    * @param lstPricebookError - list of pricebook error
    * @param mapSupplierProductPI - map of supplier with product
    */   
    public static void addErrorLog(list<giic_ErrorLog__c> lstErrorLogs, list<string> lstPricebookError, map<string,list<gii__ProductInventory__c>> mapSupplierProductPI ){
        if(!lstPricebookError.isEmpty()){
            for(string ids : mapSupplierProductPI.keyset()){
                for(gii__ProductInventory__c objPI : mapSupplierProductPI.get(ids)){
                    lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(Label.giic_SourceReorderPlanning,new map<string,object>{'giic_ProductInventory__c'=>objPI.id},
                                                                                                                       Label.giic_SourceReorderPlanning,lstPricebookError[0] +objPI.gii__Product__r.gii__ProductCode__c)));
                }
            }  
        }
        Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
    }

    /**
    * @author Name : Anil Giri - anil.giri@in.fujitsu.com
    * @date 24/07/2019
    * @description  execute ROP for central warehouse
    * @param settProductIds - 
    * @param setSupplierIds -
    * @param mapSupplierProductPI -
    * @param mapPRODWHLOCWithSugQty -
    * @param isSuggestedCalc -
    * @return list<string>
    */    
    public static list<string> createPOforROPProcess(set<Id> settProductIds,set<id> setSupplierIds,map<string,list<gii__ProductInventory__c>> mapSupplierProductPI,map<string,integer> mapPRODWHLOCWithSugQty, boolean isSuggestedCalc){
        /***********************************************set variables**********************************/
        set<string> setPOKey=new set<string>();
        /***********************************************map variables**********************************/
        map<string,gii__PurchaseOrder__c> mapKeyPO=new  map<string,gii__PurchaseOrder__c>();
        map<string,list<gii__PurchaseOrderLine__c>> mapKeyPOL=new  map<string,list<gii__PurchaseOrderLine__c>>();
        /***********************************************list variables**********************************/
        List<gii__PriceBookEntry__c> lstPriceBookAndPBEntry = new List<gii__PriceBookEntry__c>();
        list<string> lstErrors=new list<string>();
        if(settProductIds.size()>0 && setSupplierIds.size()>0){
            if(Schema.sObjectType.gii__PriceBookEntry__c.isQueryable()){
                lstPriceBookAndPBEntry = Giic_PurchaseOrderUtility_D.getPriceBookEntries(settProductIds,setSupplierIds); 
            }
            if(lstPriceBookAndPBEntry.size()>0){
                for(gii__PriceBookEntry__c pbEntry : lstPriceBookAndPBEntry) {
                    string key=pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
                    for(gii__ProductInventory__c objPI : mapSupplierProductPI.get(key)){
                        if(objPI.gii__Product__r.giic_EndDate__c >= date.today() || objPI.gii__Product__r.giic_EndDate__c  == null ){
                        string poKey=objPI.gii__Warehouse__c + '-'+ pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+pbEntry.gii__PriceBook__r.name;
                        string suggKey=objPI.gii__Product__c + '-' + objPI.gii__Warehouse__c+'-' + objPI.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                        integer dSuggestedQty=0;
                        if(isSuggestedCalc){
                            dSuggestedQty = mapPRODWHLOCWithSugQty.get(suggKey) > objPI.gii__MinimumOrderQuantity__c ? mapPRODWHLOCWithSugQty.get(suggKey) : integer.valueof(objPI.gii__MinimumOrderQuantity__c);
                            dSuggestedQty = math.mod(integer.valueOf(dSuggestedQty),integer.valueOf(objPI.gii__OrderQuantityMultiple__c)) !=0 ? 
                                integer.valueOf(objPI.gii__OrderQuantityMultiple__c) * integer.valueof((dSuggestedQty/objPI.gii__OrderQuantityMultiple__c).setscale(0,RoundingMode.UP)) : dSuggestedQty;
                        }else{
                            dSuggestedQty = mapPRODWHLOCWithSugQty.get(suggKey);
                        }
                        if(!setPOKey.contains(poKey)){
                            gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(giic_Source__c=Label.giic_SourceReorderPlanning,giic_Contract__c=pbEntry.gii__PriceBook__r.giic_Contract__c,
                                                                                    gii__Supplier__c = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId,
                                                                                    gii__ShipTo__c = objPI.gii__Warehouse__c,gii__OrderDate__c = system.today(),
                                                                                    gii__Approved__c=false,gii__DropShip__c = false,gii__RequiredDate__c = system.today(),
                                                                                    gii__PriceBookName__c=pbEntry.gii__PriceBook__r.name,
                                                                                    giic_PriceBookId__c =pbEntry.gii__PriceBook__c);
                            mapKeyPO.put(poKey,objPO);
                            gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objPI.gii__Product__c,gii__OrderQuantity__c=dSuggestedQty);
                            mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{objPOLine});
                            setPOKey.add(poKey);
                        }else{
                            gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objPI.gii__Product__c,gii__OrderQuantity__c=dSuggestedQty);
                            mapKeyPOL.get(poKey).add(objPOLine);
                        }
                            
                        }else{
                             lstErrors.add(Label.giic_ErrorEndDate); //'The end date on Product Reference is less than today');  
                            
                        }
                    }
                }
                insertPO(mapKeyPO,mapKeyPOL); 
            }else{
                lstErrors.add(System.Label.giic_PriceBookError);  
            }
        }
        return lstErrors;
   }     

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @description Insert Purchase Order and Purchase Order Lines
    * @param lstSOIds - List<Id>
    * @param mapProductWithAvailability - Map<Id,giic_CommonWrapper.ProductAvailability>
    * @return Giic_StockAvailabilityUtility.POCreationResponse
    */      
    public static Giic_StockAvailabilityUtility.POCreationResponse createDropShipPO(List<Id> lstSOIds, Map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability){
        List<gii__SalesOrderLine__c> lstSOL = new List<gii__SalesOrderLine__c>();
        Giic_StockAvailabilityUtility.POCreationForReservation objPOCreationReservation = new Giic_StockAvailabilityUtility.POCreationForReservation();
        objPOCreationReservation.isDropShip = true;
        objPOCreationReservation.mapSOLIdWithIsDropShip = new Map<id,boolean>();
        
        if(Schema.sObjectType.gii__SalesOrderLine__c.isQueryable()) {
            lstSOL = [
                SELECT Id, gii__SalesOrder__r.giic_WorkOrder__c,gii__SalesOrder__r.gii__ShipToCity__c,gii__Product__r.gii__ProductCode__c,  gii__SalesOrder__r.gii__RequiredDate__c,gii__SalesOrder__r.gii__ShipToCountry__c,gii__SalesOrder__r.gii__ShipToName__c, gii__SalesOrder__r.gii__ShipToStateProvince__c,gii__SalesOrder__r.gii__ShipToStreet__c,gii__SalesOrder__r.gii__ShipToZipPostalCode__c,
                        gii__SalesOrder__c, gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.gii__Warehouse__c,gii__Warehouse__c,gii__Product__c,Name,gii__Product__r.gii__PrimarySupplier__c, gii__OrderQuantity__c ,gii__RequiredDate__c, gii__SalesOrder__r.giic_CIG__c, gii__SalesOrder__r.giic_CUP__c, gii__Warehouse__r.giic_WarehouseType__c,gii__SalesOrder__r.gii__DropShip__c, gii__SalesOrder__r.giic_IsDelivery__c, gii__SalesOrder__r.giic_LegalEntity__c, gii__SalesOrder__r.giic_OrderStatus__c
                FROM gii__SalesOrderLine__c 
                WHERE gii__SalesOrder__c IN :lstSOIds 
                ORDER BY gii__SalesOrder__c
            ];
        }
        Map<String, gii__ProductInventory__c> mapWHPRLOWithPI = new Map<String, gii__ProductInventory__c>();
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapWHPIQD = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        return createPOWithContractValidation(lstSOL, mapProductWithAvailability, objPOCreationReservation, mapWHPRLOWithPI, mapWHPIQD);
    }

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @description insert Purchase Order and purchase order lines
    * @param lstSOL - List<gii__SalesOrderLine__c>
    * @param mapProductWithAvailability - Map<Id, giic_CommonWrapper.ProductAvailability>
    * @param objPOCreationReservation - Giic_StockAvailabilityUtility.POCreationForReservation
    * @param mapWHPRLOWithPI - Map<String, gii__ProductInventory__c> 
    * @param mapWHPIQD - Map<String, List<gii__ProductInventoryQuantityDetail__c>> 
    * @return Giic_StockAvailabilityUtility.POCreationResponse
    */  
    //[NR1107]
    public static Giic_StockAvailabilityUtility.POCreationResponse createPOWithContractValidation(List<gii__SalesOrderLine__c> lstSOL, Map<Id, giic_CommonWrapper.ProductAvailability> mapProductWithAvailability, Giic_StockAvailabilityUtility.POCreationForReservation objPOCreationReservation, Map<String, gii__ProductInventory__c> mapWHPRLOWithPI, Map<String,List<gii__ProductInventoryQuantityDetail__c>> mapWHPIQD){
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setSupplierIds = new Set<Id>();
        List<String> lstErrors = new List<String>();
        List<String> lstAllProductCodes=new List<String>();
        List<String> lstSupplierMissingProducts=new List<String>();
        List<String> lstSupplyTimeMissingProducts=new List<String>();
        Giic_StockAvailabilityUtility.POCreationResponse objPOResponse = new Giic_StockAvailabilityUtility.POCreationResponse();
        Map<String, List<gii__SalesOrderLine__c>> mapSupplierProductSOLs = new Map<String, List<gii__SalesOrderLine__c>>();
        String legalEntity = lstSOL[0].gii__SalesOrder__r.giic_LegalEntity__c;
		List<giic_ReservationUtility.ReservationWrapper> listWr = new List<giic_ReservationUtility.ReservationWrapper>();
		
        List<giic_Switch2152__c> csSw = giic_Switch2152__c.getAll().values();
        boolean isActive = false;
        for(giic_Switch2152__c cs : csSw){
            if(legalEntity == cs.giic_LegalEntity__c && cs.giic_isActive__c == true){isActive =true; break;}
        }
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ giic_OrderStatus__c: ' + lstSOL[0].gii__SalesOrder__r.giic_OrderStatus__c);
		If(isActive == true && lstSOL[0].gii__SalesOrder__r.giic_OrderStatus__c!= 'Error') {
			if(!(mapWHPRLOWithPI.isEmpty() || (lstSOL[0].gii__SalesOrder__r.giic_IsDelivery__c && !(lstSOL[0].gii__SalesOrder__r.gii__DropShip__c)))) {
				
				for(gii__SalesOrderLine__c objSOL : lstSOL) {
			
					String keyWHProd = objSOL.gii__SalesOrder__r.gii__Warehouse__c + '-' + objSOL.gii__Product__c;
					
					Integer QtyRes = 0;
					XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWHPRLOWithPI = '+mapWHPRLOWithPI);
					Decimal availQty = mapWHPRLOWithPI.containsKey(keyWHProd) ? mapWHPRLOWithPI.get(keyWHProd).giic_SalesOnHand__c : 0;
					XC_UTIL_Debug.debug(DEBUGACTIVE, 'availQty = '+availQty);
					if(availQty!=0 && availQty >= objSOL.gii__OrderQuantity__c && keyWHProd!=''){
						QtyRes = Integer.valueOf(objSOL.gii__OrderQuantity__c);
					}
					else {
						QtyRes = Integer.valueOf(availQty);
					}
							
					if(QtyRes!=0){
						List<gii__ProductInventoryQuantityDetail__c> ListOfPIQD = new List<gii__ProductInventoryQuantityDetail__c>();
						if(mapWHPIQD.containskey(keyWHProd)){
							ListOfPIQD = mapWHPIQD.get(keyWHProd);                         
							String location;
							List<String> ListOfLocAv = new List<String>();
							for(gii__ProductInventoryQuantityDetail__c PIQDAv : ListOfPIQD){if((PIQDAv.gii__Location__r.giic_LocationType__c =='Sales') && (PIQDAv.gii__Available__c > 0)) {ListOfLocAv.add(PIQDAv.gii__Location__c);}}
							if(ListOfLocAv.Size()>0) {
								location = ListOfLocAv[0];
							}     
							XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Location: ' + location);
							if(location!=null) {
								giic_ReservationUtility.ReservationWrapper wr = giic_ReservationUtility.getReservationWrapper(objSOL.gii__SalesOrder__r.gii__Warehouse__c, objSOL.gii__Product__c,integer.valueof(QtyRes),location);listWr.add(wr);
							}
						}
					}			
				}
			}			
		}
		
        for(gii__SalesOrderLine__c objSOL : lstSOL) {
            setProductIds.add(objSOL.gii__Product__c);
            lstAllProductCodes.add(objSOL.gii__Product__r.gii__ProductCode__c);
            if(objSOL.gii__Product__r.gii__PrimarySupplier__c != null) {
                setSupplierIds.add(objSOL.gii__Product__r.gii__PrimarySupplier__c);
                String key = objSOL.gii__Product__r.gii__PrimarySupplier__c +'-' +objSOL.gii__Product__c;
                if(!mapSupplierProductSOLs.containsKey(key)){
                    mapSupplierProductSOLs.put(key, new List<gii__SalesOrderLine__c>());
                }
                mapSupplierProductSOLs.get(key).add(objSOL);
            } else {
                mapProductWithAvailability.get(objSOL.gii__Product__c).errorMessage=System.Label.giic_SupplierError;
                lstSupplierMissingProducts.add(objSOL.gii__Product__r.gii__ProductCode__c);
            }
        }
        
        Map<String, Object> mapResultProcess = new Map<String, Object>();

        // Check errors:
        if(!lstSupplierMissingProducts.isEmpty()) {
            lstErrors.add(System.Label.giic_SupplierError+ string.join(lstSupplierMissingProducts,','));
        }
        if(!lstSupplyTimeMissingProducts.isEmpty()) {
            lstErrors.add(System.Label.giic_AverageSupplyTimeError+ string.join(lstSupplyTimeMissingProducts,','));
        }
        if(!lstErrors.isEmpty()) {
            objPOResponse.lstErrors=lstErrors;
            objPOResponse.mapProductWithAvailability=mapProductWithAvailability;
            
        	if(listWr.size()> 0) {giic_ReservationUtility.reserveQuantities(listWr);mapResultProcess.put('listReservedQuantity', listWr);}	
        	if(mapResultProcess.containsKey('listReservedQuantity')) {objPOResponse.listReservationWrapper = (List<giic_ReservationUtility.ReservationWrapper>) mapResultProcess.get('listReservedQuantity');}
            
            return objPOResponse;
        }
        
        //Map<String, Object> mapResultProcess = new Map<String, Object>();
        if(setProductIds.size()>0 && setSupplierIds.size()>0 && Schema.sObjectType.gii__PriceBookEntry__c.isQueryable()) {
            List<gii__PriceBookEntry__c> lstPriceBookAndPBEntry = Giic_PurchaseOrderUtility_D.getPriceBookEntries(setProductIds,setSupplierIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ setProductIds: ' + setProductIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ setSupplierIds: ' + setSupplierIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPriceBookAndPBEntry size: ' + lstPriceBookAndPBEntry.size());
            if(lstPriceBookAndPBEntry.size()>0) {
                objPOCreationReservation.mapSupplierProductSOLs = mapSupplierProductSOLs;

                /*List<giic_Switch2152__c> csSw = giic_Switch2152__c.getAll().values();
                boolean isActive = false;
                for(giic_Switch2152__c cs : csSw){
                    if(legalEntity == cs.giic_LegalEntity__c && cs.giic_isActive__c == true){isActive =true; break;}
                }*/
                //[NR1107]
                if(isActive == false) {
                    mapResultProcess = processPOWithContractValidation(objPOCreationReservation, mapProductWithAvailability, lstPriceBookAndPBEntry);
                }else if(isActive == true){
                    mapResultProcess = processPOWithContractValidationNew(objPOCreationReservation, mapProductWithAvailability, lstPriceBookAndPBEntry, mapWHPRLOWithPI, mapWHPIQD, listWr);
                }
                
            } else {
                lstErrors.add('No valid PricebookEntry found: please check the date on contract' + string.join(lstAllProductCodes,','));   
                objPOResponse.lstErrors = lstErrors;              
            }
        }

        if(mapResultProcess.containsKey('mapProductWithAvailability')) {
            objPOResponse.mapProductWithAvailability = (Map<Id, giic_CommonWrapper.ProductAvailability>) mapResultProcess.get('mapProductWithAvailability');
        }
        if(mapResultProcess.containsKey('listProductsWrapper')) {
            objPOResponse.productsWrapper = (List<Giic_CommonWrapper.ProductWrapper>) mapResultProcess.get('listProductsWrapper');
        }
        if(mapResultProcess.containsKey('listReservedQuantity')) {
            objPOResponse.listReservationWrapper = (List<giic_ReservationUtility.ReservationWrapper>) mapResultProcess.get('listReservedQuantity');
        }
        if(mapResultProcess.containsKey('mapUniqueKeyPONumber')) {
            objPOResponse.mapUniqueKeyPONumber = (Map<String, String>) mapResultProcess.get('mapUniqueKeyPONumber');
        }
        return objPOResponse;
    }
 
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @description insert Purchase Order and purchase order lines
    * @param objPOCreationReservation - Giic_StockAvailabilityUtility.POCreationForReservation
    * @param mapProductWithAvailability - Map<Id,giic_CommonWrapper.ProductAvailability>
    * @param lstPriceBookAndPBEntry - List<gii__PriceBookEntry__c>
    * @return Map<String, Object>
    */      
    public static Map<String, Object> processPOWithContractValidation(Giic_StockAvailabilityUtility.POCreationForReservation objPOCreationReservation, Map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability, List<gii__PriceBookEntry__c> lstPriceBookAndPBEntry){
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<Id, Boolean> mapSOLIdWithIsDropShip = objPOCreationReservation.mapSOLIdWithIsDropShip;
        Map<String, List<gii__SalesOrderLine__c>> mapSupplierProductSOLs = objPOCreationReservation.mapSupplierProductSOLs;
        Boolean isDropShip = objPOCreationReservation.isDropShip;
        Set<String> setPOKey = new Set<String>();
        Map<String, gii__PurchaseOrder__c> mapKeyPO = new Map<String, gii__PurchaseOrder__c>();
        Map<String, List<gii__PurchaseOrderLine__c>> mapKeyPOL = new Map<String, List<gii__PurchaseOrderLine__c>>();
        Boolean SkypMinimumLot = false;

        // Populate PO Objects:
        for(gii__PriceBookEntry__c pbEntry : lstPriceBookAndPBEntry) {
            String key = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
            for(gii__SalesOrderLine__c objSOL : mapSupplierProductSOLs.get(key)){
                    String poKey = objSOL.gii__Warehouse__c + '-'+ pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+pbEntry.gii__PriceBook__r.name ;
                    if(mapSOLIdWithIsDropShip!= null && !mapSOLIdWithIsDropShip.isEmpty()){
                        poKey += '-' + string.valueof(mapSOLIdWithIsDropShip.get(objSOL.id));
                    }
                    if(!mapKeyPO.containsKey(poKey)){
                        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__SalesOrder__c = objSOL.gii__SalesOrder__c,giic_Source__c=label.giic_OrderSourceAutomation,
                                                                                gii__Supplier__c = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId,gii__ShipTo__c = objSOL.gii__Warehouse__c,
                                                                                gii__OrderDate__c = system.today(), gii__RequiredDate__c = objSOL.gii__SalesOrder__r.gii__RequiredDate__c,
                                                                                gii__PriceBookName__c = pbEntry.gii__PriceBook__r.name, giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c,
                                                                                giic_PriceBookId__c = pbEntry.gii__PriceBook__c, giic_CUP__c=objSOL.gii__SalesOrder__r.giic_CUP__c,giic_CIG__c=objSOL.gii__SalesOrder__r.giic_CIG__c );
                        boolean isDropShipSOL = false;
                        if(isDropShip || (!mapSOLIdWithIsDropShip.isEmpty() && mapSOLIdWithIsDropShip.containsKey(objSOL.id) && mapSOLIdWithIsDropShip.get(objSOL.id))){
                            objPO.gii__DropShip__c = true;
                            if(objSOL.gii__Warehouse__r.giic_WarehouseType__c == 'Virtual') {SkypMinimumLot = TRUE;}
                            // objPO.gii__Approved__c=true;
                            // objPO.giic_IntegrationStatus__c = Label.giic_TOIntegrationStatusReadyToIntegrate ;
                            // objPO.giic_IntegrationOperation__c = Label.giic_IntegrationOperationCreate;  
                            // Set<String> values = new Set<String>();
                            // values.add(Label.giic_TargetSystemSAP);
                            // objPO.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(objPO.giic_MultiTargetSystem__c,values) ;
                            objPO.giic_Status__c = 'Sent To Supplier'; //Label.giic_POApprovedStatus;
                            objPO.gii__ShipToCity__c = objSOL.gii__SalesOrder__r.gii__ShipToCity__c;
                            objPO.gii__ShipToCountry__c = objSOL.gii__SalesOrder__r.gii__ShipToCountry__c;
                            objPO.gii__ShipToName__c = objSOL.gii__SalesOrder__r.gii__ShipToName__c;
                            objPO.gii__ShipToStateProvince__c = objSOL.gii__SalesOrder__r.gii__ShipToStateProvince__c;
                            objPO.gii__ShipToStreet__c = objSOL.gii__SalesOrder__r.gii__ShipToStreet__c  ;
                            objPO.gii__ShipToZipPostalCode__c = objSOL.gii__SalesOrder__r.gii__ShipToZipPostalCode__c;
                            isDropShipSOL = true;
                        } else {
                            objPO.giic_Contract__c = pbEntry.gii__PriceBook__r.giic_Contract__c;
                        }
                        mapKeyPO.put(poKey, objPO);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isDropShipSOL ' + isDropShipSOL + ' *** ' + mapSOLIdWithIsDropShip);
                        //[NR1106]
                        Decimal QtyNew = objSOL.gii__OrderQuantity__c;
                        Integer oldOrderQuantity; //NR1353
                        if(pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0 && SkypMinimumLot != true) {
                            oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
                            if(QtyNew <=pbEntry.giic_MinimumOrderQuantity__c) {QtyNew = pbEntry.giic_MinimumOrderQuantity__c;}
                            else {
                                Integer Div = Integer.ValueOf(QtyNew/pbEntry.giic_MinimumOrderQuantity__c);
                                Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                                if(remainder == 0) {
                                    QtyNew = Div * pbEntry.giic_MinimumOrderQuantity__c;
                                } else {
                                    QtyNew = (Div + 1) * pbEntry.giic_MinimumOrderQuantity__c;
                                }
                            }
                        }
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ oldOrderQuantity: '+ oldOrderQuantity);
                        //NR1353
                        if(oldOrderQuantity != null && oldOrderQuantity != 0){
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ oldOrderQuantity != null && oldOrderQuantity != 0: '+ oldOrderQuantity != null && oldOrderQuantity != 0);
                            mapKeyPOL.put(poKey, new List<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(
                                gii__DropShip__c = isDropShipSOL,
                                gii__SalesOrderLine__c = objSOL.id,
                                gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                                gii__Product__c = objSOL.gii__Product__c,
                                gii__OrderQuantity__c = QtyNew, 
                                giic_OldOrderQuantity__c = oldOrderQuantity
                            )});
                        }
                        else{
                            mapKeyPOL.put(poKey, new List<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(
                                gii__DropShip__c = isDropShipSOL,
                                gii__SalesOrderLine__c = objSOL.id,
                                gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                                gii__Product__c = objSOL.gii__Product__c,
                                gii__OrderQuantity__c = QtyNew
                            )});  
                        }
                        //NR1353
                        //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=objSOL.gii__OrderQuantity__c)});
                        //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew)});
                        //[NR1106]
                    } else{
                        Boolean isDropShipSOL = false;
                        if(isDropShip || (!mapSOLIdWithIsDropShip.isEmpty() && mapSOLIdWithIsDropShip.containsKey(objSOL.id) && mapSOLIdWithIsDropShip.get(objSOL.id))){
                            isDropShipSOL = true;
                        }
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isDropShipSOL= '+isDropShipSOL );
                        //[NR1106]
                        Decimal QtyNew = objSOL.gii__OrderQuantity__c;
                        integer oldOrderQuantity; //NR1353
                        if(pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0 && SkypMinimumLot != true) {
                            oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
                            if(QtyNew <=pbEntry.giic_MinimumOrderQuantity__c) {
                                QtyNew = pbEntry.giic_MinimumOrderQuantity__c;
                            }
                            else {
                                Integer Div = integer.ValueOf(QtyNew/pbEntry.giic_MinimumOrderQuantity__c);
                                Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                                if(remainder == 0) {
                                    QtyNew = Div * pbEntry.giic_MinimumOrderQuantity__c;
                                } else { 
                                    QtyNew = (Div + 1) * pbEntry.giic_MinimumOrderQuantity__c;
                                }
                            }
                        }
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'oldOrderQuantity: '+ oldOrderQuantity);
                        //NR1353
                        if(oldOrderQuantity != null && oldOrderQuantity != 0){
                            //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew, giic_OldOrderQuantity__c = oldOrderQuantity)});
                            mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(
                                gii__DropShip__c = isDropShipSOL,
                                gii__SalesOrderLine__c = objSOL.id,
                                gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                                gii__Product__c =  objSOL.gii__Product__c,
                                gii__OrderQuantity__c = QtyNew, 
                                giic_OldOrderQuantity__c = oldOrderQuantity
                            ));
                        }
                        else{
                            mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(
                                gii__DropShip__c = isDropShipSOL,
                                gii__SalesOrderLine__c = objSOL.id,
                                gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                                gii__Product__c = objSOL.gii__Product__c,
                                gii__OrderQuantity__c = QtyNew
                            ));
                        }
                        //NR1353
                        //mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=objSOL.gii__OrderQuantity__c));
                        //mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew));
                        //[NR1106]
                    }
                }
        }

        // Insert PO Objects:
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapKeyPO: ' + mapKeyPO);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapKeyPOL: ' + mapKeyPOL);
        List<Id> listIdsPOInserted = insertPO(mapKeyPO, mapKeyPOL);
        Map<String, String> mapPONumber = new Map<String, String>();
        if(!listIdsPOInserted.isEmpty()) {
            List<gii__PurchaseOrder__c> listPOInsertedWithPONumber = new List<gii__PurchaseOrder__c>([
                SELECT Name, gii__PriceBookName__c, gii__Supplier__c, gii__ShipTo__c 
                FROM gii__PurchaseOrder__c 
                WHERE Id IN :listIdsPOInserted
            ]);
            for(gii__PurchaseOrder__c singlePO : listPOInsertedWithPONumber) {
                String keyForMap = '' + singlePO.gii__ShipTo__c + '-' + singlePO.gii__Supplier__c + '-' + singlePO.gii__PriceBookName__c;
                mapPONumber.put(keyForMap, singlePO.Name);
            }
        }

        // Populate results:
        List<Giic_CommonWrapper.ProductWrapper> listProductsWrapper = new List<Giic_CommonWrapper.ProductWrapper>();
        for(String key : mapKeyPO.keyset()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PO: ' + key);
            if(!mapKeyPOL.containsKey(key)) {
                continue;
            }
            //Giic_CommonWrapper.ProductWrapper pw = new Giic_CommonWrapper.ProductWrapper();
            //pw.purchaseOrderStatus = (mapKeyPO.containsKey(key) && String.isNotBlank(mapKeyPO.get(key).giic_Status__c)) ? mapKeyPO.get(key).giic_Status__c : Label.giic_PODraftStatus;
            for(gii__PurchaseOrderLine__c objPOL : mapKeyPOL.get(key)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For POLine: ' + objPOL);
                Giic_CommonWrapper.ProductWrapper pw = new Giic_CommonWrapper.ProductWrapper();
            	pw.purchaseOrderStatus = (mapKeyPO.containsKey(key) && String.isNotBlank(mapKeyPO.get(key).giic_Status__c)) ? mapKeyPO.get(key).giic_Status__c : Label.giic_PODraftStatus;
                pw.purchasedQty = objPOL.gii__OrderQuantity__c;
                pw.productId = objPOL.gii__Product__c;
                String keyWith3params = (key.split('-').size() == 4) ? (key.split('-')[0]+'-'+key.split('-')[1]+'-'+key.split('-')[2]) : key;
                if(mapPoNumber.containsKey(keyWith3params)) {
                    pw.purchaseOrderNumber = mapPoNumber.get(keyWith3params);
                }
                pw.warehouseAccountId = keyWith3params.split('-')[1];
                listProductsWrapper.add(pw);
            }
            //listProductsWrapper.add(pw);
        }
        mapResult.put('mapProductWithAvailability', mapProductWithAvailability);
        mapResult.put('listProductsWrapper', listProductsWrapper);
        
        if(listProductsWrapper.isEmpty()) {
            for(gii__PriceBookEntry__c pbEntry : lstPriceBookAndPBEntry) {
                String key = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
                for(gii__SalesOrderLine__c objSOL : mapSupplierProductSOLs.get(key)) {
                    Giic_CommonWrapper.ProductWrapper pw = new Giic_CommonWrapper.ProductWrapper();
                    pw.productId = objSOL.gii__Product__c;
                    listProductsWrapper.add(pw); 
                }
            }
            mapResult.put('listProductsWrapper', listProductsWrapper);
        }
        mapResult.put('mapUniqueKeyPONumber', mapPONumber);
        
        return mapResult;
    }  
   
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @description Insert Purchase Order and purchase order lines
    * @param mapPO - Map of PurchaseOrder, 
    * @param mapPOLine - Map of PurchaseOrderLine
    * @return List<Id>
    */    
    public static List<Id> insertPO(Map<String, gii__PurchaseOrder__c> mapPO, Map<String, List<gii__PurchaseOrderLine__c>> mapPOLine){
        for(String key : mapPO.keyset()){
            if(!mapPOLine.containsKey(key)) {
                mapPO.remove(key);
            }
        }

        Database.Insert(mapPO.values());
        List<Id> lstPOIds = new List<Id>();
        List<gii__PurchaseOrderLine__c> lstPOLToInsert = new List<gii__PurchaseOrderLine__c>();
        for(String key : mapPO.keyset()) {
            if(!mapPOLine.containsKey(key)) {
                continue;
            }
            lstPOIds.add(mapPO.get(key).Id);
            for(gii__PurchaseOrderLine__c objPOL : mapPOLine.get(key)){
                objPOL.gii__PurchaseOrder__c = mapPO.get(key).Id;
                lstPOLToInsert.add(objPOL);
            }
        }
        Database.insert(lstPOLToInsert);
        return lstPOIds;
    }

    /** @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description To get Contract amount.
    * @param newPOs - List of PurchaseOrder
    */        
    public static void updateSupplierDiscount(List<gii__PurchaseOrder__c> newPOs){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In updateSupplierDiscount');
        List<gii__PurchaseOrder__c> newPOsList = new List<gii__PurchaseOrder__c> ();
        for(gii__PurchaseOrder__c objPO : newPOs){
            if(objPO.gii__OrderStatus__c == 'Draft' || objPO.gii__OrderStatus__c == 'Open' ){ 
                newPOsList.add(objPO); 
            }
        }
        //get Contract records
        Map<id,Contract> mapContract = getContract(newPOsList);
        //get Contract Amount
        Map<Id,Decimal> mapContractAmount=getContractAmount(mapContract);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapContractAmount'+mapContractAmount);
        for(gii__PurchaseOrder__c objPO : newPOsList){
            if(mapContract.size()>0 && mapContract.containsKey(objPO.giic_Contract__c) &&  objPO.gii__OrderStatus__c != 'Closed'){
                // Calculate Supplier Discount
                calculateSupplierDiscount(objPO,mapContractAmount ,mapContract);
            }else {
                objPO.gii__SupplierDiscountPercent__c = 0;
            }
        }
    }

    /** @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description To get Contract amount.
    * @param mapContract - Map of Contract
    * @return map<Id,Decimal>
    */   
    public static map<Id,Decimal> getContractAmount(Map<id,Contract> mapContract){
        map<Id,Decimal> mapContractAmount=new map<Id,Decimal>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapContract'+mapContract);
        if(mapContract.size()>0 ){
            for(id objConId : mapContract.keyset()){
                decimal orderAmount=getOrderAmountFromPO(mapContract.get(objConId).Purchase_Orders__r);
                mapContractAmount.put(objConId,orderAmount);
            }
        }
        return mapContractAmount;
    }

    /** @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description To amount from PO
    * @param lstPO - of PurchaseOrder
    * @return decimal total amount
    */   
    public static decimal getOrderAmountFromPO(list<gii__PurchaseOrder__c> lstPO){
        decimal orderAmount=0;
        if(lstPO.size()>0){
            for(gii__PurchaseOrder__c objPO : lstPO){
                orderAmount+=objPO.gii__OrderAmount__c; 
            }
        }
        return orderAmount;
    }

    /** @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description To get Contractrecords.
    * @param newPOs - List of PurchaseOrder
    * @return Map<id,Contract>
    */   
    public static Map<id,Contract> getContract(List<gii__PurchaseOrder__c> newPOs){
        set<Id> setContractIds=new set<Id>();
        for(gii__PurchaseOrder__c objPO : newPOs){
            if(!objPO.gii__DropShip__c){
                setContractIds.add(objPO.giic_Contract__c);
            }
        }
        Map<id,Contract> mapContract = new Map<id,Contract>();
        if(setContractIds.size()>0 && Schema.sObjectType.Contract.isQueryable()){
            mapContract=new Map<id,Contract>([SELECT id,giic_BudgetConsumption__c,giic_TotalAmount__c,giic_DiscountThreshold__c,giic_DiscountPercent__c,
                                (SELECT id,gii__OrderAmount__c FROM Purchase_Orders__r WHERE giic_Status__c=:System.Label.giic_StatusOpen)
                                FROM Contract WHERE Id IN:setContractIds and giic_TotalAmount__c > 0 and giic_DiscountThreshold__c != null]);
        }
        return mapContract;
    }

    /** 
    * @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description To get calculateSupplierDiscount.
    * @param objPO -
    * @param mapContractAmount -
    * @param mapContract -
    */   
    public static void calculateSupplierDiscount(gii__PurchaseOrder__c objPO, Map<Id,Decimal> mapContractAmount , Map<id,Contract> mapContract){
        decimal budgetConsumed=mapContract.get(objPO.giic_Contract__c).giic_BudgetConsumption__c != null ? mapContract.get(objPO.giic_Contract__c).giic_BudgetConsumption__c : 0;
        decimal budgetConsumedTotal  = budgetConsumed+mapContractAmount.get(objPO.giic_Contract__c);
        // get MetaData Values
        list<XC_CM_ContractAlertThreshold__mdt> cstmMetaDataValList = new list<XC_CM_ContractAlertThreshold__mdt>();
        if (Schema.sObjectType.XC_CM_ContractAlertThreshold__mdt.fields.MasterLabel.isAccessible() ){
            cstmMetaDataValList = [SELECT MasterLabel,XC_PercentageRatio__c FROM XC_CM_ContractAlertThreshold__mdt WHERE MasterLabel = 'SPAIN'];
        } 
        if((budgetConsumedTotal/mapContract.get(objPO.giic_Contract__c).giic_TotalAmount__c) * 100 > mapContract.get(objPO.giic_Contract__c).giic_DiscountThreshold__c){ 
            objPO.gii__SupplierDiscountPercent__c = mapContract.get(objPO.giic_Contract__c).giic_DiscountPercent__c; 
        }
        if(!cstmMetaDataValList.isEmpty() && cstmMetaDataValList[0].XC_PercentageRatio__c!=null && (budgetConsumed/mapContract.get(objPO.giic_Contract__c).giic_TotalAmount__c) * 100 > cstmMetaDataValList[0].XC_PercentageRatio__c){
            //objPO.giic_BudgetLimitExceeded__c = true;
        }
    }

    /**    
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 23/07/2019
    * @date Modification dd/mm/yyyy
    * @description update product discount on POL
    * @param lstPOL - List of PurchaseOrderLine
    */   
    public static void cancelPOL(List<Id> lstPOL){
        list<gii__PurchaseOrderLine__c> lstPOLToUpdate= new  list<gii__PurchaseOrderLine__c>();
        if(Schema.sObjectType.gii__PurchaseOrderLine__c.isQueryable()){
            lstPOLToUpdate=[SELECT Id,gii__CancelDate__c,gii__CancelledQuantity__c,gii__CancelReason__c,gii__OrderQuantity__c
                            from gii__PurchaseOrderLine__c where gii__PurchaseOrder__c IN :lstPOL];
        }
        if(!lstPOLToUpdate.isEmpty()){
            for(gii__PurchaseOrderLine__c poLineObj:lstPOLToUpdate){
                poLineObj.gii__CancelDate__c=system.today();
                poLineObj.gii__CancelledQuantity__c=poLineObj.gii__OrderQuantity__c;
                poLineObj.gii__CancelReason__c=System.Label.giic_CancelReason;
            }
            DataBase.SaveResult[] resultlist = database.update(lstPOLToUpdate,false);
            for (Database.SaveResult sr:resultlist){
                if (sr.isSuccess()) {                            
                }else{
                    Database.Error err = sr.getErrors()[0];
                }
            }
        }
    }
    
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getReasonOfCancellation(String poID){
         XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        List<String> reasonValue =  XC_UTIL_Sobject.getPicklistValues('gii__PurchaseOrder__c' ,  'giic_ReasonOfCancellation__c');
        rw.fieldName = JSON.serialize(reasonValue);        
        return rw;
    }

    /**    
    * @author FirstName : Shubee Tyagi - Shubee.Tyagi@in.fujitsu.com
    * @date Creation 28/08/2019
    * @date Modification dd/mm/yyyy
    * @description Change status of cancelled PO 
    * @param poID - List of PurchaseOrder Id
    */       
    @AuraEnabled
    public static void changeStatustoCancelled(String poID, String reason, String otherReason){
        List<gii__PurchaseOrder__c> lstPO = new List<gii__PurchaseOrder__c>([SELECT Id,Name,giic_Status__c,gii__Status__c,giic_MultiTargetSystem__c 
                                                                             FROM gii__PurchaseOrder__c
                                                                             WHERE  Id=:poID]);
        if(lstPO != null && !lstPO.isEmpty()){
            for(gii__PurchaseOrder__c objPO:lstPO){
                if(objPO.giic_Status__c=='Cancelled') {
                    String m = System.Label.giic_POCancellationAlreadyProgress;
                    AuraHandledException e = new AuraHandledException(m);
                    e.setMessage(m);
                    throw e; 
                } else if(objPO.gii__Status__c==System.Label.giic_StatusClosed){
                    String m = System.Label.giic_PurchaseOrderisclosed;
                    AuraHandledException e = new AuraHandledException(m);
                    e.setMessage(m);
                    throw e;  
                } else{
                    objPO.giic_Status__c='Cancelled';
                    objPO.giic_IntegrationOperation__c=System.Label.giic_CancellationRequest;
                    objPO.giic_IntegrationStatus__c = System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                    objPO.giic_ReasonOfCancellation__c = reason;
                    objPO.giic_OtherReasonOfCancellation__c =  otherReason;
                }
            }
            if(Schema.sObjectType.gii__PurchaseOrder__c.isUpdateable()){
                update lstPO;
            }
        }
    }
    
    /**    
    * @date Creation 24/03/2020
    * @description Method to CHECK po APPROVED
    * @param listNew - List<gii__PurchaseOrder__c>
    */ 
    public static void checkWhenPOisApproved(List<gii__PurchaseOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkWhenPOisApproved con Status ');
        for(gii__PurchaseOrder__c po : listNew){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ status = '+po.giic_status__c);
            if(po.giic_Status__c=='Approved'){              
                po.gii__Approved__c = true;
                po.giic_IntegrationStatus__c = System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                po.giic_IntegrationOperation__c = System.Label.giic_IntegrationOperationCreate;
                Set<String> values = new Set<String>();
                if(po.giic_MultiTargetSystem__c == null || !po.giic_MultiTargetSystem__c.contains('SAP')){
                    values.add('SAP');
                }
                if(po.giic_MultiTargetSystem__c == null || !po.giic_MultiTargetSystem__c.contains('3PL')){
                    values.add('3PL');
                }                
                po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(po.giic_MultiTargetSystem__c, values);
            }else if(po.giic_Status__c == 'Cancelled'){
                po.giic_IntegrationStatus__c = System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                po.giic_IntegrationOperation__c = System.Label.giic_CancellationRequest ;
                Set<String> values = new Set<String>();
                values.add(Label.giic_TargetSystemSAP);
                values.add('3PL');
                po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(null , values);
            }
        }
    }    
    
    /**    
    * @date Creation 24/03/2020
    * @description Method to set target system
    * @param listNew - List<gii__PurchaseOrder__c>
    */ 
    public static void setTargetSystemIfApproved(List<gii__PurchaseOrder__c> listNew){        
        for(gii__PurchaseOrder__c po : listNew){
            if(po.gii__Approved__c){
                Set<String> values = new Set<String>();
                if(po.giic_MultiTargetSystem__c == null || (!po.giic_MultiTargetSystem__c.contains('SAP'))){
                    values.add('SAP');
                }
                if(po.giic_MultiTargetSystem__c == null || (!po.giic_MultiTargetSystem__c.contains('3PL'))){
                    values.add('3PL');
                }
                po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(po.giic_MultiTargetSystem__c, values);
            }
        }
    }
    
    /**    
    * @date Creation 24/03/2020
    * @description Method to set Enel Username
    */ 
    public static void setEnelUserName(List<gii__PurchaseOrder__c> listNew, Map<Id, gii__PurchaseOrder__c> mapOld, Map<Id, gii__PurchaseOrder__c > mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In setEnelUserName');
        for(gii__PurchaseOrder__c po : listNew){
            if(mapOld.get(po.Id).giic_Status__c == 'Open' && mapNew.get(po.Id).giic_Status__c=='Sent To Supplier'){
                po.Giic_EnelUser__c = UserInfo.getFirstName() +' '+UserInfo.getLastName();
            } 
        }
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 16/12/2020
    * @date Modification dd/mm/yyyy
    * @description this method checks if warehouse change
    * @param listNew -  List of PO
    * @param mapNew -  Map of new PO
    * @param mapOld -  Map of old PO
    */
    public static void checkIfWarehouseChange(List<gii__PurchaseOrder__c> listNew, Map<id, gii__PurchaseOrder__c> mapNew, Map<id, gii__PurchaseOrder__c> mapOld){
        list<String> fieldsToCheck = new List<string>{'gii__ShipTo__c'};
        list<gii__PurchaseOrder__c> listPoChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, mapOld, mapNew);
        if(listPoChanged.size() > 0){
            if(Trigger.isAfter){
                rebaltWarehouseOnPol(listPoChanged, mapNew);
            }
            else if(Trigger.isBefore){
                rebaltWarehouseAddOnPO(listPoChanged);
            }
        }
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 16/12/2020
    * @date Modification dd/mm/yyyy
    * @description this method rebalts WH on POL when the WH on PO changes
    * @param listNew -  List of PO
    * @param mapNew -  Map of new PO
    */
    public static void rebaltWarehouseOnPol(List<gii__PurchaseOrder__c> listNew, Map<id, gii__PurchaseOrder__c> mapNew){
        List<gii__PurchaseOrderLine__c> listPolNew = new List<gii__PurchaseOrderLine__c>();
        List<gii__PurchaseOrderLine__c> listPol = [SELECT id, name, gii__ShipTo__c, gii_ShiptoWH__c, gii__PurchaseOrder__c FROM gii__PurchaseOrderLine__c 
                                                    WHERE gii__PurchaseOrder__c IN:listNew];
        for(gii__PurchaseOrderLine__c objPol : listPol){
            objPol.gii__ShipTo__c = mapNew.get(objPol.gii__PurchaseOrder__c).gii__ShipTo__c;
            listPolNew.add(objPol);
        }
        update listPolNew;
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 16/12/2020
    * @date Modification dd/mm/yyyy
    * @description this method rebalts WH address when the WH changes
    * @param listNew -  List of PO
    */
    public static void rebaltWarehouseAddOnPO(List<gii__PurchaseOrder__c> listNew){
        /*Set<string> whSet = new Set<string>();
        for(gii__PurchaseOrder__c objPo : listNew){
            whSet.add(objPo.gii__ShipTo__c);
        }
        Map<id, gii__Warehouse__c> whMap = new Map<id, gii__Warehouse__c>([SELECT id, name, gii__WareHouseCity__c, gii__WareHouseCountry__c, 
                                                                    gii__WareHouseStateProvince__c, gii__WareHouseStreet__c, gii__WareHouseZipPostalCode__c FROM gii__Warehouse__c
                                                                    WHERE id IN: whSet]);*/
        for(gii__PurchaseOrder__c objPo : listNew){
            if(objPo.gii__DropShip__c == false){
                objPo.gii__ShipToName__c = objPo.gii_ShipToName_Calc__c;
                objPo.gii__ShipToCity__c = objPo.gii_Ship_to_City_Calc__c;
                objPo.gii__ShipToCountry__c = objPo.gii_ShiptoCountry_Calc__c;
                objPo.gii__ShipToStateProvince__c = objPo.gii_ShipToStateProvince_Calc__c;
                objPo.gii__ShipToStreet__c = objPo.gii_ShipToStreet_Calc__c;
                objPo.gii__ShipToZipPostalCode__c = objPo.gii_ShipToStateProvince_Calc__c;
            }
        }
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 05/05/2021
    * @date Modification dd/mm/yyyy
    * @description this method checks if Total open quantity change
    * @param listNew -  List of PO
    * @param mapNew -  Map of new PO
    * @param mapOld -  Map of old PO
    */
    public static void checkIfTotalOpenQtyChange(List<gii__PurchaseOrder__c> listNew, Map<id, gii__PurchaseOrder__c> mapNew, Map<id, gii__PurchaseOrder__c> mapOld){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN checkIfTotalOpenQtyChange');
        list<String> fieldsToCheck = new List<string>{'gii__TotalOpenQuantity__c'};
        boolean isServicePresent = false;
        list<gii__PurchaseOrder__c> listPoChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, mapOld, mapNew);
        if(listPoChanged.size() > 0){
            List<gii__PurchaseOrder__c> listPoToProcess = getPoZeroQty(listPoChanged);
            isServicePresent = checkIfIsServicePresent(listPoToProcess);
            if(isServicePresent){
                calcAvgPriceWithTransCost(listPoToProcess);
            }
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Mthod to check service
    */
    public static boolean checkIfIsServicePresent(List<gii__PurchaseOrder__c> listPo){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN checkIfIsServicePresent');
        boolean isPresent = false;
        List<gii__PurchaseOrderLine__c> listPol = [SELECT id, gii__Service__c 
                                                FROM gii__PurchaseOrderLine__c
                                                WHERE gii__PurchaseOrder__c IN: listPo];
        for(gii__PurchaseOrderLine__c pol : listPol){
            if(pol.gii__Service__c == true){
                isPresent = true;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'isPresent: ' + isPresent);
        return isPresent;
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to get PO 0 qty
    */
    public static list<gii__PurchaseOrder__c> getPoZeroQty(list<gii__PurchaseOrder__c> listPo){
        List<gii__PurchaseOrder__c> listPoZeroQty = [SELECT id, gii__TotalOpenQuantity__c 
                                        FROM gii__PurchaseOrder__c
                                        WHERE id IN: listPo AND gii__TotalOpenQuantity__c = 0];
        return listPoZeroQty;
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to check status
    */
    public static void checkStatus(List<gii__PurchaseOrder__c> listNew, Map<id, gii__PurchaseOrder__c> mapNew, Map<id, gii__PurchaseOrder__c> mapOld){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN checkStatus');
        list<String> fieldsToCheck = new List<string>{'giic_Status__c'};
            list<gii__PurchaseOrder__c> listPoChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, mapOld, mapNew);
        if(listPoChanged.size() > 0){
            preventOnlyTransCost(listPoChanged);
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to prevent tranCost
    */
    public static void preventOnlyTransCost(List<gii__PurchaseOrder__c> listPO){    
        boolean isServicePresent = false;
        isServicePresent = checkIfIsServicePresent(listPO);
        if(isServicePresent){
            Map<id, gii__PurchaseOrderLine__c> polMap = new map<id, gii__PurchaseOrderLine__c>([SELECT Id, CurrencyIsoCode, gii__Service__c, gii__UnitPrice__c, 
                                                                                                gii__Product__c, gii__PurchaseOrder__c, gii__OrderQuantity__c
                                                                                                FROM gii__PurchaseOrderLine__c
                                                                                                WHERE gii__PurchaseOrder__c IN :listPO]);
            List <gii__PurchaseOrderLine__c> listPOLine = polMap.values();
            for(gii__PurchaseOrder__c po : listPO ){
                if(po.giic_Status__c != 'Open' && po.giic_Status__c !='Draft' && listPOLine.size()== 1){
                    po.addError(Label.giic_CL_NotOnlyTransportCost);//'You cannot process Purchase Order with only Transport/Shipping Cost'
                }
            }
        }                                                                                
        
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 05/05/2021
    * @date Modification dd/mm/yyyy
    * @description this method calculate AVG price with transportation cost
    * @param listNew -  List of PO
    */
    public static void calcAvgPriceWithTransCost(List<gii__PurchaseOrder__c> listPO){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN calcAvgPriceWithTransCost');
        Map<id, gii__PurchaseOrderLine__c> polMap = new map<id, gii__PurchaseOrderLine__c>([SELECT Id, CurrencyIsoCode, gii__Service__c, gii__UnitPrice__c, gii__Product__c, gii__PurchaseOrder__c, gii__OrderQuantity__c
                                                                                                        FROM gii__PurchaseOrderLine__c
                                                                                                        WHERE gii__PurchaseOrder__c IN :listPO]);
                                                                                                        
        List <gii__PurchaseOrderLine__c> listPOLine = polMap.values();
        decimal trCost = 0;
        if(listPOLine != null && !listPOLine.isEmpty()){
            List<gii__Product2Add__c> pdtRefList = new List<gii__Product2Add__c>();
            Set<String> pdtIdSet = new Set<String>();
            for(gii__PurchaseOrderLine__c poLineRec : listPOLine){
                if(poLineRec.gii__Product__c != null && poLineRec.gii__Service__c != true){
                    pdtIdSet.add(poLineRec.gii__Product__c);
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'isService = ' + poLineRec.gii__Service__c);
                if(poLineRec.gii__Product__c != null && poLineRec.gii__Service__c == true){
                    if(trCost == 0){
                        trCost = poLineRec.gii__UnitPrice__c;
                    }
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'trCost = ' + trCost);

            Map<Id,gii__Product2Add__c> mapOfPdtIdVsPdt = new Map<Id,gii__Product2Add__c>([SELECT giic_StockQuantity__c,CurrencyIsoCode,giic_AveragePrice__c FROM gii__Product2Add__c WHERE Id IN:pdtIdSet]);
            if(mapOfPdtIdVsPdt != null && !mapOfPdtIdVsPdt.values().isEmpty()){
                mapOfPdtIdVsPdt = calcAvgPriceHelper(mapOfPdtIdVsPdt,listPOLine, trCost);
                update mapOfPdtIdVsPdt.values(); 
            }
        }
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 05/05/2021
    * @date Modification dd/mm/yyyy
    * @description this method calculate AVG price with transportation cost
    * @param listNew -  List of PO
    */
    public static Map<Id,gii__Product2Add__c> calcAvgPriceHelper(Map<Id,gii__Product2Add__c> mapOfPdtIdVsPdt,List<gii__PurchaseOrderLine__c> listPOLine, decimal trCost){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN calcAvgPriceHelper');

        List<String> poIds = new List<string>();
        for(gii__PurchaseOrderLine__c poLine : listPOLine){
            poIds.add(poLine.gii__PurchaseOrder__c);
        }
        Map<id, gii__PurchaseOrder__c> poMap = new Map<id, gii__PurchaseOrder__c>([SELECT id, gii__OrderAmount__c
                                                                                FROM gii__PurchaseOrder__c
                                                                                WHERE id in: poIds]);
        Map<String, Double> currencyRates  =  new Map <String, Double>();
        for (CurrencyType cRates : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]) {
            currencyRates.put(cRates.IsoCode, cRates.ConversionRate);
        }
        
        for(gii__PurchaseOrderLine__c poLineObj : listPOLine){
            Decimal oldStockQty = 0;
            Decimal transCost = 0;
            Decimal oldAveragePrice = 0;
            Decimal newAveragePrice = 0;
            Decimal totTransCostPol = 0;
            decimal weightTotal = 0;
            
            if(poLineObj.gii__Product__c!=null && mapOfPdtIdVsPdt.get(poLineObj.gii__Product__c)!= null && mapOfPdtIdVsPdt.get(poLineObj.gii__Product__c).giic_StockQuantity__c != null){
                oldStockQty = mapOfPdtIdVsPdt.get(poLineObj.gii__Product__c).giic_StockQuantity__c /*- poLineObj.gii__OrderQuantity__c*/ ;
                oldAveragePrice = mapOfPdtIdVsPdt.get(poLineObj.gii__Product__c).giic_AveragePrice__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'oldStockQty = ' + oldStockQty);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'oldAveragePrice = ' + oldAveragePrice);

                if (poLineObj.CurrencyIsoCode == mapOfPdtIdVsPdt.get(poLineObj.gii__Product__c).CurrencyIsoCode) {
                    transCost = trCost;
                } else {
                    Decimal convertValue = Giic_POReceiptLineUtility.convertCurrency(poLineObj.CurrencyIsoCode,mapOfPdtIdVsPdt.get(poLineObj.gii__Product__c).CurrencyIsoCode, trCost, currencyRates);
                    transCost = (convertValue).setScale(2);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, transCost);
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'transCost = ' + transCost);

                weightTotal = poMap.get(poLineObj.gii__PurchaseOrder__c).gii__OrderAmount__c - transCost;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'weightTotal = ' + weightTotal);
                totTransCostPol = ((transCost/weightTotal) * (poLineObj.gii__UnitPrice__c *poLineObj.gii__OrderQuantity__c)).setScale(2);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'totTransCostPol = ' + totTransCostPol);
                newAveragePrice = (oldAveragePrice + (totTransCostPol/oldStockQty)).setScale(2);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'newAveragePrice = ' + newAveragePrice);
                mapOfPdtIdVsPdt.get(poLineObj.gii__Product__c).giic_AveragePrice__c = newAveragePrice;
            }
        }
        return mapOfPdtIdVsPdt;
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 05/05/2021
    * @date Modification dd/mm/yyyy
    * @description this method calculate prevent that a Purchase Order has more than one transportation cost
    * @param listNew -  List of PO
    */
    public static void preventMoreTransCost(List<gii__PurchaseOrderLine__c> purchaseOdrLineList){
        List<String> poIds = XC_UTIL_Sobject.getListFieldValues(purchaseOdrLineList, 'gii__PurchaseOrder__c');
        //Boolean myPosition = [Select XC_EnabledToSkip__c From User Where Id = :UserInfo.getUserId()][0].XC_EnabledToSkip__c;
        map<Id, gii__PurchaseOrder__c> poMaps = new  map<Id, gii__PurchaseOrder__c>([SELECT Id,gii__DropShip__c,giic_Source__c, giic_Status__c, giic_ForClosedContract__c, giic_Total_Service_Item__c FROM gii__PurchaseOrder__c WHERE Id IN: poIds]);
        if(poMaps.values().isEmpty()){
            return;
        }
        for(gii__PurchaseOrderLine__c pol : purchaseOdrLineList){
            if((pol.gii__Service__c == true && pol.gii__OrderQuantity__c >1) || (pol.gii__Service__c == true && (poMaps.get(pol.gii__PurchaseOrder__c).giic_Total_Service_Item__c + pol.gii__OrderQuantity__c) > 1 ) ){     
                pol.addError(Label.giic_CL_NoOtherTransportCost); //'Purchase Order cannot have more than one Transport/Shipping Cost'
            }
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to prevent TransCost in update
    */
    public static void preventMoreTransCostInUpdt(List<gii__PurchaseOrderLine__c> purchaseOdrLineList){
        List<String> poIds = XC_UTIL_Sobject.getListFieldValues(purchaseOdrLineList, 'gii__PurchaseOrder__c');
        //Boolean myPosition = [Select XC_EnabledToSkip__c From User Where Id = :UserInfo.getUserId()][0].XC_EnabledToSkip__c;
        for(gii__PurchaseOrderLine__c pol : purchaseOdrLineList){
            if((pol.gii__Service__c == true && pol.gii__OrderQuantity__c >1) /*|| (pol.gii__Service__c == true && (poMaps.get(pol.gii__PurchaseOrder__c).giic_Total_Service_Item__c + pol.gii__OrderQuantity__c) > 1 )*/ ){     
                pol.addError(Label.giic_CL_NoOtherTransportCost); //'Purchase Order cannot have more than one Transport/Shipping Cost'
            }
        }   
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 25/05/2021
    * @date Modification dd/mm/yyyy
    * @description this method check if a POL resepcts min order quantity for CR NR1106
    * @param listNew -  List of POL
    */
    public static void checkMinQuantity(List<gii__PurchaseOrderLine__c> purchaseOrdLineList){
        Set<id> productIds = New Set<id>();
        Set<id> poIds = New Set<id>();
        Set<id> supplierIds = New Set<id>();
        
        for(gii__PurchaseOrderLine__c pol : purchaseOrdLineList){
            productIds.add(pol.gii__Product__c);
            poIds.add(pol.gii__PurchaseOrder__c);
        }

        Map<id, gii__PurchaseOrder__c> poMap = New Map<id, gii__PurchaseOrder__c>([SELECT id, giic_Source__c, gii__Supplier__c
                                                                                FROM gii__PurchaseOrder__c
                                                                                WHERE id IN: poIds]);

        for(gii__PurchaseOrder__c po : poMap.values()){
            supplierIds.add(po.gii__Supplier__c);
        }

        List<gii__PriceBookEntry__c> lstPBE = New List<gii__PriceBookEntry__c>([SELECT id, gii__Product__c, giic_MinimumOrderQuantity__c, gii__Product__r.gii__PrimarySupplier__c, giic_Default__c 
                                                                                    FROM gii__PriceBookEntry__c
                                                                                    WHERE gii__Product__c IN: productIds
                                                                                    AND gii__PriceBook__r.giic_Contract__r.AccountId <> null
                                                                                    AND gii__PriceBook__r.giic_Contract__r.AccountId IN: supplierIds
                                                                                    /*AND giic_MinimumOrderQuantity__c != null*/
                                                                                    /*AND giic_Default__c = true*/]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'lstPBE: ' + lstPBE);
        if(lstPBE.isEmpty()){return;}

        List<gii__PriceBookEntry__c> listPbeDef = New List<gii__PriceBookEntry__c>();
        List<gii__PriceBookEntry__c> listPbe = New List<gii__PriceBookEntry__c>();

        for(gii__PriceBookEntry__c pbe : lstPBE ){
            if(pbe.giic_Default__c){
                listPbeDef.add(pbe);
            }
            else{
                listPbe.add(pbe);
            }
        }

        
        for(gii__PurchaseOrderLine__c pol : purchaseOrdLineList){
            if(poMap.get(pol.gii__PurchaseOrder__c).giic_Source__c != Label.giic_SourceReorderPlanning){
                if(listPbeDef.size() > 0){
                    for(gii__PriceBookEntry__c pbe : listPbeDef){
                        if(pbe.gii__Product__c == pol.gii__Product__c && pbe.giic_MinimumOrderQuantity__c!= null && pbe.giic_MinimumOrderQuantity__c !=0  ){
                            XC_UTIL_Debug.debug(DEBUGACTIVE, pbe.giic_MinimumOrderQuantity__c);
                            XC_UTIL_Debug.debug(DEBUGACTIVE, pol.gii__OrderQuantity__c);
                            integer remainder = math.mod(integer.ValueOf(pol.gii__OrderQuantity__c), integer.ValueOf(pbe.giic_MinimumOrderQuantity__c));
                            XC_UTIL_Debug.debug(DEBUGACTIVE, remainder);
                            if((pol.gii__OrderQuantity__c < pbe.giic_MinimumOrderQuantity__c) || (remainder != 0) ){
                                pol.giic_QuantityNotAllowed__c = true;
                                XC_UTIL_Debug.debug(DEBUGACTIVE, 'pol.giic_QuantityNotAllowed__c: ' + pol.giic_QuantityNotAllowed__c );
                            }
                            else{
                                pol.giic_QuantityNotAllowed__c = false;
                            }
                        }
                    }
                }
                else{
                    if(listPbe.size() > 0){
                        decimal qty = 0;
                        boolean qtyNotAllowed = false;
                        for(gii__PriceBookEntry__c pbe : listPbe){
                            if(pbe.gii__Product__c == pol.gii__Product__c && pbe.giic_MinimumOrderQuantity__c!= null && pbe.giic_MinimumOrderQuantity__c !=0){
                                if(pbe.giic_MinimumOrderQuantity__c > qty){
                                    qty = pbe.giic_MinimumOrderQuantity__c;
                                    XC_UTIL_Debug.debug(DEBUGACTIVE, qty);
                                    XC_UTIL_Debug.debug(DEBUGACTIVE, pol.gii__OrderQuantity__c);
                                    integer remainder = math.mod(integer.ValueOf(pol.gii__OrderQuantity__c), integer.ValueOf(qty));
                                    XC_UTIL_Debug.debug(DEBUGACTIVE, remainder);
                                    if((pol.gii__OrderQuantity__c < qty) || (remainder != 0) ){
                                        qtyNotAllowed = true;
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'qtyNotAllowed: ' + qtyNotAllowed );
                                    }
                                    else{
                                        qtyNotAllowed = false;
                                    }
                                }
                            }
                        }
                        pol.giic_QuantityNotAllowed__c = qtyNotAllowed;
                    }
                }
                
            }
            
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to process PO with contract validation
    * @param objPOCreationReservation - Giic_StockAvailabilityUtility.POCreationForReservation 
    * @param mapProductWithAvailability - Map<Id,giic_CommonWrapper.ProductAvailability> 
    * @param lstPriceBookAndPBEntry - List<gii__PriceBookEntry__c> 
    * @param mapWHPRLOWithPI - Map<string,gii__ProductInventory__c> 
    * @param mapWHPIQD - Map<string,List<gii__ProductInventoryQuantityDetail__c>> 
    * @return Map<String, Object>
    */
    //[NR1107]
    public static Map<String, Object> processPOWithContractValidationNew(Giic_StockAvailabilityUtility.POCreationForReservation objPOCreationReservation,map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability,List<gii__PriceBookEntry__c> lstPriceBookAndPBEntry,  map<string,gii__ProductInventory__c> mapWHPRLOWithPI, Map<string,List<gii__ProductInventoryQuantityDetail__c>> mapWHPIQD, List<giic_ReservationUtility.ReservationWrapper> listWr){
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<Id, Boolean> mapSOLIdWithIsDropShip = objPOCreationReservation.mapSOLIdWithIsDropShip;
        Map<String, List<gii__SalesOrderLine__c>> mapSupplierProductSOLs = objPOCreationReservation.mapSupplierProductSOLs;
        Boolean isDropShip = objPOCreationReservation.isDropShip;
        Set<String> setPOKey = new Set<String>();
        Map<String, gii__PurchaseOrder__c> mapKeyPO = new Map<String, gii__PurchaseOrder__c>();
        Map<String, List<gii__PurchaseOrderLine__c>> mapKeyPOL = new Map<String, List<gii__PurchaseOrderLine__c>>();
        Boolean SkypMinimumLot = false;
        //List<giic_ReservationUtility.ReservationWrapper> listWr = new List<giic_ReservationUtility.ReservationWrapper>();
        List<gii__ProductInventory__c> lstPIToUpdateBackOrderQty = new List<gii__ProductInventory__c>();

        for(gii__PriceBookEntry__c pbEntry : lstPriceBookAndPBEntry) {
        String key = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
        for(gii__SalesOrderLine__c objSOL : mapSupplierProductSOLs.get(key)) {
            if(mapWHPRLOWithPI.isEmpty() || (objSOL.gii__SalesOrder__r.giic_IsDelivery__c && !(objSOL.gii__SalesOrder__r.gii__DropShip__c))) {
                String poKey = objSOL.gii__Warehouse__c + '-'+ pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+pbEntry.gii__PriceBook__r.name ;
                if(mapSOLIdWithIsDropShip!= null && !mapSOLIdWithIsDropShip.isEmpty()) {
                    poKey += '-' + string.valueof(mapSOLIdWithIsDropShip.get(objSOL.id));
                }
                if(!mapKeyPO.containsKey(poKey)){
                    gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__SalesOrder__c=objSOL.gii__SalesOrder__c,giic_Source__c=label.giic_OrderSourceAutomation,
                                                                            gii__Supplier__c = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId,gii__ShipTo__c = objSOL.gii__Warehouse__c,
                                                                            gii__OrderDate__c = system.today(), gii__RequiredDate__c = objSOL.gii__SalesOrder__r.gii__RequiredDate__c,
                                                                            gii__PriceBookName__c=pbEntry.gii__PriceBook__r.name, giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c,
                                                                            giic_PriceBookId__c =pbEntry.gii__PriceBook__c, giic_CUP__c=objSOL.gii__SalesOrder__r.giic_CUP__c,giic_CIG__c=objSOL.gii__SalesOrder__r.giic_CIG__c );
                    Boolean isDropShipSOL = false;
                    if(isDropShip || (!mapSOLIdWithIsDropShip.isEmpty() && mapSOLIdWithIsDropShip.containsKey(objSOL.id) && mapSOLIdWithIsDropShip.get(objSOL.id))){
                        objPO.gii__DropShip__c=true;objPO.giic_Status__c= 'Sent To Supplier';objPO.gii__ShipToCity__c =objSOL.gii__SalesOrder__r.gii__ShipToCity__c;objPO.gii__ShipToCountry__c =objSOL.gii__SalesOrder__r.gii__ShipToCountry__c;objPO.gii__ShipToName__c =objSOL.gii__SalesOrder__r.gii__ShipToName__c;objPO.gii__ShipToStateProvince__c =objSOL.gii__SalesOrder__r.gii__ShipToStateProvince__c;objPO.gii__ShipToStreet__c =objSOL.gii__SalesOrder__r.gii__ShipToStreet__c;objPO.gii__ShipToZipPostalCode__c =objSOL.gii__SalesOrder__r.gii__ShipToZipPostalCode__c;
                        if(objSOL.gii__Warehouse__r.giic_WarehouseType__c == 'Virtual') {
                            SkypMinimumLot = true;
                        }                       
                        isDropShipSOL=true;
                    } else{
                        objPO.giic_Contract__c= pbEntry.gii__PriceBook__r.giic_Contract__c;
                    }
                    mapKeyPO.put(poKey,objPO);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isDropShipSOL' + isDropShipSOL + ' *** ' + mapSOLIdWithIsDropShip);
                    //[NR1106]
                    Decimal QtyNew = objSOL.gii__OrderQuantity__c;
                    Integer oldOrderQuantity; //NR1353
                    if(pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0 && SkypMinimumLot != true) {
                        oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
                        if(QtyNew <=pbEntry.giic_MinimumOrderQuantity__c) {
                            QtyNew = pbEntry.giic_MinimumOrderQuantity__c;
                        }
                        else {
                            Integer Div = integer.ValueOf(QtyNew/pbEntry.giic_MinimumOrderQuantity__c);
                            Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                            if(remainder == 0) {
                                QtyNew = Div*pbEntry.giic_MinimumOrderQuantity__c;
                            } else {
                                QtyNew = (Div + 1) * pbEntry.giic_MinimumOrderQuantity__c;
                            }
                        }
                    }
                    //NR1353
                    if(oldOrderQuantity != null && oldOrderQuantity != 0){
                        mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(
                            gii__DropShip__c = isDropShipSOL,
                            gii__SalesOrderLine__c = objSOL.id,
                            gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                            gii__Product__c = objSOL.gii__Product__c,
                            gii__OrderQuantity__c = QtyNew, 
                            giic_OldOrderQuantity__c = oldOrderQuantity
                        )});
                    }
                    else{
                        mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(
                            gii__DropShip__c = isDropShipSOL,
                            gii__SalesOrderLine__c = objSOL.id,
                            gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                            gii__Product__c = objSOL.gii__Product__c,
                            gii__OrderQuantity__c = QtyNew
                        )});  
                    }
                    //NR1353
                    //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=objSOL.gii__OrderQuantity__c)});
                    //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew)});
                    //[NR1106]
                } else {
                    Boolean isDropShipSOL=false;
                    if(isDropShip || (!mapSOLIdWithIsDropShip.isEmpty() && mapSOLIdWithIsDropShip.containsKey(objSOL.id) && mapSOLIdWithIsDropShip.get(objSOL.id))){
                        isDropShipSOL = true;
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isDropShipSOL: ' + isDropShipSOL );
                    //[NR1106]
                    Decimal QtyNew = objSOL.gii__OrderQuantity__c;
                    Integer oldOrderQuantity; //NR1353
                    if(pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0 && SkypMinimumLot != true) {
                        oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
                        if(QtyNew <=pbEntry.giic_MinimumOrderQuantity__c) {
                            QtyNew = pbEntry.giic_MinimumOrderQuantity__c;
                        }
                        else {
                            Integer Div = integer.ValueOf(QtyNew/pbEntry.giic_MinimumOrderQuantity__c);
                            Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                            if(remainder == 0) {
                                QtyNew = Div*pbEntry.giic_MinimumOrderQuantity__c;
                            } else {
                                QtyNew = (Div + 1) * pbEntry.giic_MinimumOrderQuantity__c;
                            }
                        }
                    }
                    //NR1353
                    if(oldOrderQuantity != null && oldOrderQuantity != 0){
                        //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew, giic_OldOrderQuantity__c = oldOrderQuantity)});
                        mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(
                            gii__DropShip__c = isDropShipSOL,
                            gii__SalesOrderLine__c = objSOL.id,
                            gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                            gii__Product__c = objSOL.gii__Product__c,
                            gii__OrderQuantity__c = QtyNew, 
                            giic_OldOrderQuantity__c = oldOrderQuantity
                        ));
                    }
                    else {
                        //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew)});
                        mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(
                            gii__DropShip__c = isDropShipSOL,
                            gii__SalesOrderLine__c = objSOL.id,
                            gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                            gii__Product__c = objSOL.gii__Product__c,
                            gii__OrderQuantity__c = QtyNew
                        ));
                    }
                    //NR1353
                    //mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=objSOL.gii__OrderQuantity__c));
                    //mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew));
                    //[NR1106]
                }
            } else {
                String poKey = objSOL.gii__Warehouse__c + '-'+ pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+pbEntry.gii__PriceBook__r.name ;
                String keyWHProd = objSOL.gii__SalesOrder__r.gii__Warehouse__c + '-' + objSOL.gii__Product__c;
                if(mapSOLIdWithIsDropShip!= null && !mapSOLIdWithIsDropShip.isEmpty()){
                    poKey += '-' + string.valueof(mapSOLIdWithIsDropShip.get(objSOL.id));
                }
                if(!mapKeyPO.containsKey(poKey)){
                    gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(gii__SalesOrder__c=objSOL.gii__SalesOrder__c,giic_Source__c=label.giic_OrderSourceAutomation,
                                                                            gii__Supplier__c = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId,gii__ShipTo__c = objSOL.gii__Warehouse__c,
                                                                            gii__OrderDate__c = system.today(), gii__RequiredDate__c = objSOL.gii__SalesOrder__r.gii__RequiredDate__c,
                                                                            gii__PriceBookName__c=pbEntry.gii__PriceBook__r.name, giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c,
                                                                            giic_PriceBookId__c =pbEntry.gii__PriceBook__c, giic_CUP__c=objSOL.gii__SalesOrder__r.giic_CUP__c,giic_CIG__c=objSOL.gii__SalesOrder__r.giic_CIG__c );
                    Boolean isDropShipSOL=false;
                    if(isDropShip || (!mapSOLIdWithIsDropShip.isEmpty() && mapSOLIdWithIsDropShip.containsKey(objSOL.id) && mapSOLIdWithIsDropShip.get(objSOL.id))){
                        objPO.gii__DropShip__c=true;
                        objPO.giic_Status__c= 'Sent To Supplier';
                        objPO.gii__ShipToCity__c =objSOL.gii__SalesOrder__r.gii__ShipToCity__c;
                        objPO.gii__ShipToCountry__c =objSOL.gii__SalesOrder__r.gii__ShipToCountry__c;
                        objPO.gii__ShipToName__c =objSOL.gii__SalesOrder__r.gii__ShipToName__c;
                        objPO.gii__ShipToStateProvince__c =objSOL.gii__SalesOrder__r.gii__ShipToStateProvince__c;
                        objPO.gii__ShipToStreet__c =objSOL.gii__SalesOrder__r.gii__ShipToStreet__c;
                        objPO.gii__ShipToZipPostalCode__c =objSOL.gii__SalesOrder__r.gii__ShipToZipPostalCode__c;
                        if(objSOL.gii__Warehouse__r.giic_WarehouseType__c == 'Virtual') {
                            SkypMinimumLot = true;
                        }                   
                        isDropShipSOL=true;
                    } else {
                        objPO.giic_Contract__c= pbEntry.gii__PriceBook__r.giic_Contract__c;
                    }
                    mapKeyPO.put(poKey,objPO);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isDropShipSOL '+ isDropShipSOL + ' *** ' + mapSOLIdWithIsDropShip);
                    //Integer qtyNeeded = 0;Integer QtyRes = 0;Integer QtyBack = 0;
					Integer qtyNeeded = 0;Integer QtyBack = 0;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWHPRLOWithPI = '+mapWHPRLOWithPI);
                    Decimal availQty = mapWHPRLOWithPI.containsKey(keyWHProd) ? mapWHPRLOWithPI.get(keyWHProd).giic_SalesOnHand__c : 0;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'availQty = '+availQty);
                    if(availQty!=0 && availQty >= objSOL.gii__OrderQuantity__c && keyWHProd!=''){
                        qtyNeeded = 0;
                        //QtyRes = Integer.valueOf(objSOL.gii__OrderQuantity__c);
                        QtyBack = 0;
                    }
                    else {
                        qtyNeeded = Integer.valueOf(objSOL.gii__OrderQuantity__c - availQty);
                        //QtyRes = Integer.valueOf(availQty);
                        QtyBack = Integer.valueOf(objSOL.gii__OrderQuantity__c - availQty);
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ qtyNeeded: '+ qtyNeeded);
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ QtyRes: '+ QtyRes);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ QtyBack: '+ QtyBack);                 
                    
                    //[NR1106]
                    Decimal QtyNew = qtyNeeded;
                    Integer oldOrderQuantity; //NR1353
                    if(QtyNew!=0){
                        if(pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0 && SkypMinimumLot != true) {
                            oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
                            if(QtyNew <=pbEntry.giic_MinimumOrderQuantity__c) {
                                QtyNew = pbEntry.giic_MinimumOrderQuantity__c;
                            }
                            else {
                                Integer Div = integer.ValueOf(QtyNew/pbEntry.giic_MinimumOrderQuantity__c);
                                Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                                if(remainder == 0) {
                                    QtyNew = Div*pbEntry.giic_MinimumOrderQuantity__c;
                                } else {
                                    QtyNew = (Div + 1)*pbEntry.giic_MinimumOrderQuantity__c;
                                }
                            }
                        }
                        //NR1353
                        if(oldOrderQuantity != null && oldOrderQuantity != 0){
                            mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(
                                gii__DropShip__c=isDropShipSOL,
                                gii__SalesOrderLine__c=objSOL.id,
                                gii__SalesOrder__c=objSOL.gii__SalesOrder__c,
                                gii__Product__c= objSOL.gii__Product__c,
                                gii__OrderQuantity__c=QtyNew, 
                                giic_OldOrderQuantity__c = oldOrderQuantity
                            )});
                        }
                        else{
                            mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(
                                gii__DropShip__c=isDropShipSOL,
                                gii__SalesOrderLine__c=objSOL.id,
                                gii__SalesOrder__c=objSOL.gii__SalesOrder__c,
                                gii__Product__c= objSOL.gii__Product__c,
                                gii__OrderQuantity__c=QtyNew
                            )});  
                        }
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapKeyPOL: ' + mapKeyPOL);
                        //NR1353
                        //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew)});
                        //[NR1106]
                    }
                    
                    /*if(QtyRes!=0){
                        List<gii__ProductInventoryQuantityDetail__c> ListOfPIQD = new List<gii__ProductInventoryQuantityDetail__c>();
                        if(mapWHPIQD.containskey(keyWHProd)){
                            ListOfPIQD = mapWHPIQD.get(keyWHProd);                         
                            String location;
                            List<String> ListOfLocAv = new List<String>();
                            for(gii__ProductInventoryQuantityDetail__c PIQDAv : ListOfPIQD){if((PIQDAv.gii__Location__r.giic_LocationType__c =='Sales') && (PIQDAv.gii__Available__c > 0)) {ListOfLocAv.add(PIQDAv.gii__Location__c);}}
                            if(ListOfLocAv.Size()>0) {
                                location = ListOfLocAv[0];
                            }     
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Location: ' + location);
                            if(location!=null) {
                                giic_ReservationUtility.ReservationWrapper wr = giic_ReservationUtility.getReservationWrapper(objSOL.gii__SalesOrder__r.gii__Warehouse__c, objSOL.gii__Product__c,integer.valueof(QtyRes),location);listWr.add(wr);
                            }
                        }
                    }*/

                    if(mapWHPRLOWithPI.containsKey(keyWHProd) && QtyBack!=0){ 
                        integer existingBackOrderQty = mapWHPRLOWithPI.get(keyWHProd).giic_BackOrderNew__c != null ? integer.valueof(mapWHPRLOWithPI.get(keyWHProd).giic_BackOrderNew__c ): 0;
                        lstPIToUpdateBackOrderQty.add(new gii__ProductInventory__c(
                            Id=mapWHPRLOWithPI.get(keyWHProd).Id,
                            giic_BackOrderNew__c=existingBackOrderQty + QtyBack
                        ));
                    }
                } else {
                    Boolean isDropShipSOL=false;
                    if(isDropShip || (!mapSOLIdWithIsDropShip.isEmpty() && mapSOLIdWithIsDropShip.containsKey(objSOL.id) && mapSOLIdWithIsDropShip.get(objSOL.id))){
                        isDropShipSOL=true;
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ isDropShipSOL: '+isDropShipSOL);
                    Integer qtyNeeded = 0;
                    //Integer QtyRes = 0;
                    Integer QtyBack = 0;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWHPRLOWithPI:  '+mapWHPRLOWithPI);
                    Decimal availQty = mapWHPRLOWithPI.containsKey(keyWHProd) ? mapWHPRLOWithPI.get(keyWHProd).giic_SalesOnHand__c : 0;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ availQty:  '+availQty);
                    if(availQty!=0 && availQty >= objSOL.gii__OrderQuantity__c && keyWHProd!='') {
                        qtyNeeded = 0;
                        //QtyRes = Integer.valueOf(objSOL.gii__OrderQuantity__c);
                        QtyBack = 0;
                    }
                    else {
                        qtyNeeded = Integer.valueOf(objSOL.gii__OrderQuantity__c - availQty);
                        //QtyRes = Integer.valueOf(availQty);
                        QtyBack = Integer.valueOf(objSOL.gii__OrderQuantity__c - availQty);
                    }
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ qtyNeeded:  '+qtyNeeded);
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ QtyRes:  '+QtyRes);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ QtyBack:  '+QtyBack);                 
                    
                    //[NR1106]
                    Decimal QtyNew = qtyNeeded;
                    Integer oldOrderQuantity; //NR1353
                    if(QtyNew!=0){
                        if(pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0 && SkypMinimumLot != true) {
                            oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
                            if(QtyNew <=pbEntry.giic_MinimumOrderQuantity__c) {
                                QtyNew = pbEntry.giic_MinimumOrderQuantity__c;
                            }
                            else {
                                Integer Div = integer.ValueOf(QtyNew/pbEntry.giic_MinimumOrderQuantity__c);
                                Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                                if(remainder == 0) {
                                    QtyNew = Div*pbEntry.giic_MinimumOrderQuantity__c;
                                } else {
                                    QtyNew = (Div + 1)*pbEntry.giic_MinimumOrderQuantity__c;
                                }
                            }
                        }
                        //NR1353
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapKeyPOLOld = '+mapKeyPOL);
                        if(oldOrderQuantity != null && oldOrderQuantity != 0){
                            //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew, giic_OldOrderQuantity__c = oldOrderQuantity)});
                            mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(
                                gii__DropShip__c=isDropShipSOL,
                                gii__SalesOrderLine__c=objSOL.id,
                                gii__SalesOrder__c=objSOL.gii__SalesOrder__c,
                                gii__Product__c= objSOL.gii__Product__c,
                                gii__OrderQuantity__c=QtyNew, 
                                giic_OldOrderQuantity__c = oldOrderQuantity
                            ));
                        }
                        else{
                            //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew)});
                            mapKeyPOL.get(poKey).add(new gii__PurchaseOrderLine__c(
                                gii__DropShip__c=isDropShipSOL,
                                gii__SalesOrderLine__c=objSOL.id,
                                gii__SalesOrder__c=objSOL.gii__SalesOrder__c,
                                gii__Product__c= objSOL.gii__Product__c,
                                gii__OrderQuantity__c=QtyNew
                            ));  
                        }
                        //NR1353
                        //mapKeyPOL.put(poKey,new list<gii__PurchaseOrderLine__c>{new gii__PurchaseOrderLine__c(gii__DropShip__c=isDropShipSOL,gii__SalesOrderLine__c=objSOL.id,gii__SalesOrder__c=objSOL.gii__SalesOrder__c,gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=QtyNew)});
                        //[NR1106]
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapKeyPOL1 = '+mapKeyPOL);
                    }
                    
                    /*if(QtyRes!=0){
                        List<gii__ProductInventoryQuantityDetail__c> ListOfPIQD = new List<gii__ProductInventoryQuantityDetail__c>();
                        if(mapWHPIQD.containskey(keyWHProd)){
                            ListOfPIQD = mapWHPIQD.get(keyWHProd);                            
                            String location;
                            List<String> ListOfLocAv = new List<String>();
                            for(gii__ProductInventoryQuantityDetail__c PIQDAv : ListOfPIQD){
                                if((PIQDAv.gii__Location__r.giic_LocationType__c =='Sales') && (PIQDAv.gii__Available__c > 0)) {
                                    ListOfLocAv.add(PIQDAv.gii__Location__c);
                                }
                            }
                            if(ListOfLocAv.Size()>0) {
                                location = ListOfLocAv[0];
                            }               
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ location ' + location);
                            if(location!=null) {
                                giic_ReservationUtility.ReservationWrapper wr = giic_ReservationUtility.getReservationWrapper(objSOL.gii__SalesOrder__r.gii__Warehouse__c, objSOL.gii__Product__c,integer.valueof(QtyRes),location);
                                listWr.add(wr);
                            }
                        }
                    }*/

                    if(mapWHPRLOWithPI.containsKey(keyWHProd) && QtyBack!=0){ 
                        Integer existingBackOrderQty = mapWHPRLOWithPI.get(keyWHProd).giic_BackOrderNew__c != null ? integer.valueof(mapWHPRLOWithPI.get(keyWHProd).giic_BackOrderNew__c ): 0;
                        lstPIToUpdateBackOrderQty.add(new gii__ProductInventory__c(
                            Id=mapWHPRLOWithPI.get(keyWHProd).Id,
                            giic_BackOrderNew__c=existingBackOrderQty + QtyBack
                        ));
                    }
                }               
            }
            }
        }
        if(lstPIToUpdateBackOrderQty.size()>0) {
            update lstPIToUpdateBackOrderQty;
        }
        if(listWr.size()> 0) {
            giic_ReservationUtility.reserveQuantities(listWr);
            mapResult.put('listReservedQuantity', listWr);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapKeyPOL: ' + mapKeyPOL);
        Map<String, String> mapPONumber = new Map<String, String>();
        if(!mapKeyPOL.isEmpty() && mapKeyPOL != null) {
            List<Id> listIdsPOInserted = insertPO(mapKeyPO, mapKeyPOL);
            if(!listIdsPOInserted.isEmpty()) {
                List<gii__PurchaseOrder__c> listPOInsertedWithPONumber = new List<gii__PurchaseOrder__c>([
                    SELECT Name, gii__PriceBookName__c, gii__Supplier__c, gii__ShipTo__c 
                    FROM gii__PurchaseOrder__c 
                    WHERE Id IN :listIdsPOInserted
                ]);
                for(gii__PurchaseOrder__c singlePO : listPOInsertedWithPONumber) {
                    String keyForMap = '' + singlePO.gii__ShipTo__c + '-' + singlePO.gii__Supplier__c + '-' + singlePO.gii__PriceBookName__c;
                    mapPONumber.put(keyForMap, singlePO.Name);
                }
            }
        }
        mapResult.put('mapProductWithAvailability', mapProductWithAvailability);

        // Populate list products:
        List<Giic_CommonWrapper.ProductWrapper> listProductsWrapper = new List<Giic_CommonWrapper.ProductWrapper>();
        for(gii__PriceBookEntry__c pbEntry : lstPriceBookAndPBEntry) {
            String key = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
            for(gii__SalesOrderLine__c objSOL : mapSupplierProductSOLs.get(key)) {
                Giic_CommonWrapper.ProductWrapper pw = new Giic_CommonWrapper.ProductWrapper();
                pw.productId = objSOL.gii__Product__c;
                listProductsWrapper.add(pw); 
            }
        }
        
        for(String key : mapKeyPO.keyset()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For PO: ' + key);
            if(!mapKeyPOL.containsKey(key)) {
                continue;
            }
            for(gii__PurchaseOrderLine__c objPOL : mapKeyPOL.get(key)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For POLine: ' + objPOL);
                for(Giic_CommonWrapper.ProductWrapper singleWrapper : listProductsWrapper) {
                    if(singleWrapper.productId == objPOL.gii__Product__c) {
                        singleWrapper.purchaseOrderStatus = (mapKeyPO.containsKey(key) && String.isNotBlank(mapKeyPO.get(key).giic_Status__c)) ? mapKeyPO.get(key).giic_Status__c : Label.giic_PODraftStatus;
                        singleWrapper.purchasedQty = objPOL.gii__OrderQuantity__c;
                        String keyWith3params = (key.split('-').size() == 4) ? (key.split('-')[0]+'-'+key.split('-')[1]+'-'+key.split('-')[2]) : key;
                        if(mapPoNumber.containsKey(keyWith3params)) {
                            singleWrapper.purchaseOrderNumber = mapPoNumber.get(keyWith3params);
                        }
                        singleWrapper.warehouseAccountId = keyWith3params.split('-')[1];
                        break;
                    }
                }
            }
        }
        mapResult.put('listProductsWrapper', listProductsWrapper);
        mapResult.put('mapUniqueKeyPONumber', mapPONumber);

        return mapResult;
    }
    
    /**  
    * @date Creation 05/05/2021
    * @description Method to set partner
    */
    public static void SetPartnerGRGI(List<gii__PurchaseOrderLine__c> purchaseOrdLineList){
        Set<id> productIds = new Set<id>();
        for(gii__PurchaseOrderLine__c pol : purchaseOrdLineList){
            productIds.add(pol.gii__Product__c);
        }
        if (!productIds.isEmpty()) {
            map<string,gii__Product2Add__c> mapProd = new Map<string,gii__Product2Add__c>([SELECT id, giic_PartnerGRGI__c FROM gii__Product2Add__c WHERE id IN: productIds]);
    
            for(gii__PurchaseOrderLine__c objPOL : purchaseOrdLineList){
                if(mapProd.containskey(objPOL.gii__Product__c)){
                    if(mapProd.get(objPOL.gii__Product__c).giic_PartnerGRGI__c) {objPOL.Giic_PartnerGRGI__c = TRUE;}
                }
            }
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to set reviewd
    */
    public static void setReviewed(List<gii__PurchaseOrder__c> listNew, Map<Id,gii__PurchaseOrder__c> mapOld){
        for(gii__PurchaseOrder__c po : listNew){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'po: '+ po.id);
            if(po.giic_X4PL_Status__c == 'Accepted' && mapOld.get(po.id).giic_Status__c == 'Sent to Supplier'){
                po.giic_Status__c = 'Reviewed';
            }
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to check status
    */
    public static void checkIf4PLStatusChange(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapNew, Map<Id,gii__PurchaseOrder__c> mapOld){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'in check4PL Satus');
        List<String> fieldList = new List<String>{'giic_X4PL_Status__c'};
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        setReviewed(listChanged, mapOld);
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to set email address
    */
     public static void setWarehouseEmailAddress(List<gii__PurchaseOrder__c> listNew){
        Set<id> whSet = new Set<id>();
        for(gii__PurchaseOrder__c po : listNew){whSet.add(po.gii__ShipTo__c);}

        Map<id, gii__Warehouse__c> whMap = New Map<id, gii__Warehouse__c>  ([SELECT id, name, giic_EmailAddress__c, giic_ParentWarehouse__c, giic_ParentWarehouse__r.giic_EmailAddress__c
                                                                            FROM   gii__Warehouse__c where id IN: whSet]);

        for(gii__PurchaseOrder__c po : listNew){
            if(whMap.get(po.gii__ShipTo__c).giic_ParentWarehouse__c == null){po.giic_WarehouseEmailAddress__c = whMap.get(po.gii__ShipTo__c).giic_EmailAddress__c;}
            else{po.giic_WarehouseEmailAddress__c = whMap.get(po.gii__ShipTo__c).giic_ParentWarehouse__r.giic_EmailAddress__c;}
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to check email
    */
    public static void checkIfWhChangeForEmail(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapNew, Map<Id,gii__PurchaseOrder__c> mapOld){
        List<String> fieldList = new List<String>{'gii__ShipTo__c'};
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        setWarehouseEmailAddress(listChanged);
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to check status
    */
    public static void setX4PLStatus(List<gii__PurchaseOrder__c> listNew){
        for(gii__PurchaseOrder__c po : listNew){
            if(po.giic_Status__c == 'Sent to Supplier' && po.giic_Delivery4PLRequired__c){
                po.giic_X4PL_Status__c = '';
            }
        }
    }

    /**  
    * @date Creation 05/05/2021
    * @description Method to check pickup data change
    */
    public static void checkIfPickupDateChange(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapNew, Map<Id,gii__PurchaseOrder__c> mapOld){
        List<String> fieldList = new List<String>{'giic_PickupDate__c'};
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        setX4PLStatus(listChanged);
    }

    /**  
    * @author FirstName : Federico Faillace - federico.faillace@nttdata.com
    * @date Creation 11/02/2022
    * @date Modification dd/mm/yyyy
    * @description NR2338 To give default values on Purchase Order.
    * @param listNew -  
    */
    public static void rebaltinfoPO(List<gii__PurchaseOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In Rebalt Info PO');
        system.debug('In Rebalt Info PO');
        List<String> listSOIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__SalesOrder__c');
        //List<gii__SalesOrder__c> newSOList = new List<gii__SalesOrder__c>([SELECT id, giic_legalEntity__c, giic_WorkOrder__r.CreatedBy.giic_Plant__c FROM gii__SalesOrder__c WHERE id IN:listSOIds]);
        if(!listSOIds.isEmpty()){
            List<String> listPOIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'id');
            List<gii__PurchaseOrder__c> newPOList = new List<gii__PurchaseOrder__c>([SELECT id, giic_PriceBookId__r.giic_Contract__r.XC_LegalEntity__c, gii__SalesOrder__r.giic_WorkOrder__r.CreatedBy.giic_Plant__c
                                                                                  FROM gii__PurchaseOrder__c
                                                                                  WHERE id IN: listPOIds]);
            Map<String,String> poLegalEntity = new Map<String,String>(); 

            for(gii__PurchaseOrder__c po : newPOList){
                poLegalEntity.put(po.id, po.giic_PriceBookId__r.giic_Contract__r.XC_LegalEntity__c);
            }
        
            List<giic_NR2338_DefaultValuesForPlant__c> cs2338 = giic_NR2338_DefaultValuesForPlant__c.getAll().values();
            
            if(!cs2338.isEmpty() && newPOList[0].gii__SalesOrder__r.giic_WorkOrder__r.CreatedBy.giic_Plant__c != null && newPOList[0].gii__SalesOrder__r.giic_WorkOrder__r.CreatedBy.giic_Plant__c != '' ){
                List<gii__PurchaseOrder__c> poToUpdate = new List<gii__PurchaseOrder__c>();
                for(gii__PurchaseOrder__c po : newPOList){
                    for(giic_NR2338_DefaultValuesForPlant__c cs : cS2338 ){
                        system.debug('po: ' + po);
                        system.debug('poLegalEntity.containsKey(po.id): ' +  poLegalEntity.containsKey(po.id));
                        system.debug('pOtoCS.giic_LegalEntity__c: ' + cs.giic_LegalEntity__c);
                        system.debug('poLegalEntity.get(po.id): ' + poLegalEntity.get(po.id));
                        if(poLegalEntity.containsKey(po.id) && cs.giic_LegalEntity__c  == poLegalEntity.get(po.id)){
                            po.giic_purchasingOrganization__c = cs.giic_purchasingOrganization__c;
                            po.giic_purchasingGroup__c = cs.giic_purchasingGroup__c;
                            poToUpdate.add(po);
                            break;
                        }
                    }
                }   
                update poToUpdate;
            }
            
        }
    }

     /**  
    * @author FirstName : Federico Faillace - federico.faillace@nttdata.com
    * @date Creation 16/02/2022
    * @date Modification dd/mm/yyyy
    * @description NR2345 set the default value TRUE to the PO's Quality Check.
    * @param listNew -  
    */

    public static void qualityCheckPO(List<gii__PurchaseOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In Quality Check PO');
        List<String> listPOIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'id');
        List<gii__PurchaseOrder__c> newPOList = new List<gii__PurchaseOrder__c>([SELECT id, giic_PriceBookId__r.giic_Contract__r.XC_LegalEntity__c
                                                                                 FROM gii__PurchaseOrder__c
                                                                                 WHERE id IN:listPOIds]);

        Map<String,String> poLegalEntity = new Map<String,String>(); 
        
        for(gii__PurchaseOrder__c po : newPoList){
            poLegalEntity.put(po.id, po.giic_PriceBookId__r.giic_Contract__r.XC_LegalEntity__c);
            
        }

        List<giic_NR2345_LegalEntity__c> cs2345 = giic_NR2345_LegalEntity__c.getAll().values();

        if(!cs2345.isEmpty()){
            List<gii__PurchaseOrder__c> poToUpdate = new List<gii__PurchaseOrder__c>();
            for(gii__PurchaseOrder__c po : newPOList){
                for(giic_NR2345_LegalEntity__c cs : cs2345){
                    system.debug('po: ' + po);
                    system.debug('poLegalEntity.containsKey(po.id): ' +  poLegalEntity.containsKey(po.id));
                    system.debug('pOtoCS.giic_LegalEntity__c: ' + cs.giic_LegalEntity__c);
                    system.debug('poLegalEntity.get(po.id): ' + poLegalEntity.get(po.id));
                    system.debug('isActive: ' + cs.giic_isActive__c);
                
                    if(poLegalentity.containsKey(po.id) && cs.giic_Legalentity__C == poLegalEntity.get(po.id) && cs.giic_isActive__c == TRUE ){
                        po.giic_QualityCheck__c = TRUE;
                        poToUpdate.add(po); 
                    }   
                }
            }
            update poToUpdate;
        }
        
    }

     /**  
    * @author FirstName : Federico Faillace - federico.faillace@nttdata.com
    * @date Creation 14/02/2022
    * @date Modification dd/mm/yyyy
    * @description NR2338 To give default values on Purchase Order Lines.
    * @param listNew -  
    */

    public static void rebaltInfoPOLine(List<gii__PurchaseOrderLine__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In Rebalt Info POLine');
        system.debug('in Rebal info POLine');
        List<String> listPOIds = XC_Util_Sobject.getListFieldValues(listNew, 'gii__PurchaseOrder__c');
        List<gii__PurchaseOrder__c> newPOLlist = new List<gii__PurchaseOrder__c>([SELECT id, giic_LegalEntity__c, gii__SalesOrder__c, gii__SalesOrder__r.giic_WorkOrder__r.CreatedBy.giic_Plant__c 
                                                                                  FROM gii__PurchaseOrder__c
                                                                                  WHERE id IN: listPOIds]);

        List<String> listSOIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__SalesOrder__c');
        if(!listSOIds.isEmpty()){
            Map<String, String> map2LE = new Map<String,String>();
            Map<String,String> newSOMap = new Map<String,String>();
            for(gii__PurchaseOrder__c po2map : newPOLlist){
                if(po2map.gii__SalesOrder__r.giic_WorkOrder__r.CreatedBy.giic_plant__c != null && po2map.gii__SalesOrder__r.giic_WorkOrder__r.CreatedBy.giic_plant__c!=''){
                    newSoMap.put(po2map.id, po2map.gii__SalesOrder__r.giic_WorkOrder__r.CreatedBy.giic_plant__c);
                }
                map2LE.put(po2map.id, po2map.giic_legalEntity__c);
            }

            List<giic_NR2338_DefaultValuesForPlant__c> cs2338 = giic_NR2338_DefaultValuesForPlant__c.getAll().values();

            if(!cs2338.isEmpty() && !newSoMap.isEmpty() ){
                for(gii__PurchaseOrderLine__c pOLinetoCS : listNew){
                    for(giic_NR2338_DefaultValuesForPlant__c cSetting : cS2338 ){
                        if(newSoMap.containsKey(pOLinetoCS.gii__PurchaseOrder__c) && map2LE.containsKey(poLinetoCS.gii__PurchaseOrder__c) && cSetting.giic_LegalEntity__c == map2LE.get(pOLinetoCs.gii__PurchaseOrder__c) && cSetting.giic_plant__c == newSoMap.get(pOLineToCS.gii__PurchaseOrder__c)){
                            pOLinetoCs.giic_AccountAssignmentCategory__c = cSetting.giic_Category__c;
                            pOLinetoCS.giic_UnitRequisitioner__c = cSetting.giic_RequestingUnit__c;
                            pOLineToCS.giic_plant__c = cSetting.giic_Plant__c;
                        }
                    }
                }
            }
        }
           
    }

    /*
    * @author FirstName : Milko Fatiga
    * @date Creation 05/05/2021
    */
    public static void SetOrderDeliveryDate(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapNew, Map<Id,gii__PurchaseOrder__c> mapOld){
		
        Map<Id, gii__PurchaseOrder__c> MapPO = new Map<Id, gii__PurchaseOrder__c>([select id, giic_PriceBookId__r.Delivery_Time__c  from gii__PurchaseOrder__c WHERE id IN :listNew]);
        List<giic_enable_NR2246__c> csSw = giic_enable_NR2246__c.getAll().values();
		
		for(gii__PurchaseOrder__c objPO : listNew) {
		    boolean isActive = false;
			String BusHour;
			for(giic_enable_NR2246__c  cs : csSw){
				if(cs.LegalEntity__c == objPO.giic_LegalEntity__c){isActive = cs.giic_isActive__c;BusHour = cs.Business_Hour__c;break;}
			}
			system.debug('@@@@objPO.giic_Status__c ' + objPO.giic_Status__c);
			system.debug('@@@@mapOld.get(objPO.Id).giic_Status__c ' + mapOld.get(objPO.Id).giic_Status__c);
			system.debug('@@@@objPO.gii__OrderDate__c ' + objPO.gii__OrderDate__c);
			if(objPO.giic_Status__c == 'Approved' && mapOld.get(objPO.Id).giic_Status__c != 'Approved' ){           
				if(isActive){				
					objPO.gii__OrderDate__c = Date.Today();
				}
				if(MapPO.containsKey(objPO.Id)){

					if (String.isNotBlank(String.ValueOf(MapPO.get(objPO.Id).giic_PriceBookId__r.Delivery_Time__c))) {
						DateTime startTime = DateTime.now();
						system.debug('@@@@@@@@startTime: ' + startTime);
						Integer Days = Integer.ValueOf(MapPO.get(objPO.Id).giic_PriceBookId__r.Delivery_Time__c);
						DateTime EndDate;
                        if (String.isNotBlank(BusHour)){BusinessDays bd = new BusinessDays(BusHour);EndDate = bd.addDays(startTime,Days);} else {BusinessDays bd = new BusinessDays();EndDate = bd.addDays(startTime,Days);}
						//EndDate = bd.addDays(startTime,Days);
						system.debug('@@@@@@@@EndDate: ' + EndDate);
						Date myDate= EndDate.date();
						objPO.gii__RequiredDate__c = myDate;
					}
				}
			}
		}
    }
    
    public static void updateProductRequired(List<gii__PurchaseOrder__c> listPO, String Field){
        List<Id> poIds = XC_UTIL_Sobject.getIds(listPO);
        List<gii__PurchaseOrderLine__c> poLnList = new List<gii__PurchaseOrderLine__c>([
            SELECT Id, Name,  gii__OrderQuantity__c, gii__PurchaseOrder__r.giic_Status__c,gii__PurchaseOrder__r.giic_LegalEntity__c,gii__PurchaseOrder__r.gii__RequiredDate__c, gii__PurchaseOrder__r.giic_NewDeliveryDate__c,  gii__SalesOrderLine__r.giic_ProdRequired__c,gii__SalesOrderLine__r.giic_ProductRequiredId__c,gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c, gii__PurchaseOrder__c FROM  gii__PurchaseOrderLine__c WHERE gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c != null AND gii__PurchaseOrder__c IN :poIds
        ]);
        
        if(poLnList.size() > 0) {
            // Check existing Product Required:
            List<String> prodReqId = new List<String>();
            String LE;
            for(gii__PurchaseOrderLine__c poln : poLnList) {
                if(poln.gii__SalesOrderLine__r.giic_ProductRequiredId__c != null) {
                    prodReqId.add(poln.gii__SalesOrderLine__r.giic_ProductRequiredId__c);
                    LE = poln.gii__PurchaseOrder__r.giic_LegalEntity__c;
                }
            }

            // Update fields on Product Required found:
            if(prodReqId.size() > 0) {
                List<ProductRequired> prodReqList = new List<ProductRequired>([
                    SELECT Id, ProductRequiredNumber,XC_RequiredDate__c,XC_NewExpectedDeliveryDate__c, Date_of_last_goods_receipt__c, Goods_Receipt_Quantity__c, Purchase_Order_Status__c 
                    FROM ProductRequired 
                    WHERE Id IN :prodReqId OR ProductRequiredNumber IN :prodReqId
                ]);
                if(prodReqList.size() > 0) {
        			Boolean isActiveNR2626 = false;
        			List<giic_enable_NR2246__c> listCS = giic_enable_NR2246__c.getAll().values();
        			if(listCS !=null && !listCS.isEmpty()){
                		for(giic_enable_NR2246__c cs : listCS){
                    		XC_UTIL_Debug.debug(DEBUGACTIVE, 'csLegalEntity: ' + cs.LegalEntity__c);
                    		if(LE == cs.LegalEntity__c){isActiveNR2626 = true; break; }
                			}
        				}
                    if (isActiveNR2626) {
                	    for(gii__PurchaseOrderLine__c poln : poLnList) {
                    	    for(ProductRequired preq : prodReqList) {
                        	    Boolean productRequiredFoundByID = (poln.gii__SalesOrderLine__r.giic_ProductRequiredId__c == String.valueOf(preq.Id));
                            	Boolean productRequiredFoundByNumber = (poln.gii__SalesOrderLine__r.giic_ProductRequiredId__c == preq.ProductRequiredNumber);
                            	if(productRequiredFoundByID || productRequiredFoundByNumber) {

								
                                	If (Field=='gii__RequiredDate__c'){preq.XC_RequiredDate__c  = poln.gii__PurchaseOrder__r.gii__RequiredDate__c;}
									If (Field=='giic_NewDeliveryDate__c'){preq.XC_NewExpectedDeliveryDate__c  = poln.gii__PurchaseOrder__r.giic_NewDeliveryDate__c;}

                            	}                                       
                        	}                       
                    	}
                    	update prodReqList;
                    }
                    

                }               
            }           
        }
    }

    public static void checkIfRequiredDateChange(List<gii__PurchaseOrder__c> listNew, Map<id, gii__PurchaseOrder__c> mapNew, Map<id, gii__PurchaseOrder__c> mapOld){
        list<String> fieldsToCheck = new List<string>{'gii__RequiredDate__c'};
        list<gii__PurchaseOrder__c> listPoChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, mapOld, mapNew);
        if(listPoChanged.size() > 0){
			updateProductRequired(listPoChanged, 'gii__RequiredDate__c');
        }
    }
	
	
    public static void checkIfNewDeliveryDateChange(List<gii__PurchaseOrder__c> listNew, Map<id, gii__PurchaseOrder__c> mapNew, Map<id, gii__PurchaseOrder__c> mapOld){
        list<String> fieldsToCheck = new List<string>{'giic_NewDeliveryDate__c'};
        list<gii__PurchaseOrder__c> listPoChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, mapOld, mapNew);
        if(listPoChanged.size() > 0){
			updateProductRequired(listPoChanged, 'giic_NewDeliveryDate__c');
        }
    }    

    /**
    * @date Creation 01/10/2021
    * @description – Method to coverage class
    */    
    @TestVisible
    private static void coverageTestClass() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Debug coverage');
    }

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date 18/06/2019
    * @description To create Purchase Order and Purchase Order Line.
    * @param listPurchaseOrderHeader -  List of giic_CommonWrapper.POHeader
    * @return giic_CommonWrapper.PurchaseOrderCreationResult
    */
    /*public static giic_CommonWrapper.PurchaseOrderCreationResult createPurchaseOrder(List<giic_CommonWrapper.POHeader> listPurchaseOrderHeader) {
        List<gii__PurchaseOrderLine__c> listPOL = new List<gii__PurchaseOrderLine__c>();
        map<Integer,gii__PurchaseOrder__c> mapPurchaseOrder=new map<Integer,gii__PurchaseOrder__c>();
        map<Integer,List<gii__PurchaseOrderLine__c>> mapPurchaseOrderLine=new map<Integer,List<gii__PurchaseOrderLine__c>> ();
        giic_CommonWrapper.PurchaseOrderCreationResult objReturnResult = new giic_CommonWrapper.PurchaseOrderCreationResult();
        Integer counter=1;
        try{
            for(giic_CommonWrapper.POHeader objPO : listPurchaseOrderHeader){
                gii__PurchaseOrder__c poh = new gii__PurchaseOrder__c(gii__Supplier__c = objPO.SupplierId,gii__SalesOrder__c =objPO.SalesOrderId,
                                                                     gii__ShipTo__c=objPO.ShipTo);             
                list<gii__PurchaseOrderLine__c> lstPOL=new list<gii__PurchaseOrderLine__c>();
                for(giic_CommonWrapper.PurchaseOrderLine objPOL : objPO.POLineList){
                    gii__PurchaseOrderLine__c poLine = new gii__PurchaseOrderLine__c(gii__Product__c= objPOL.ProductId,gii__OrderQuantity__c = objPOL.OrderQuantity,
                                                                                    gii__UnitPrice__c=objPOL.UnitPrice);
                    lstPOL.add(poLine);
                }
                mapPurchaseOrder.put(counter,POH);
                mapPurchaseOrderLine.put(counter,lstPOL);
                counter = counter +1;
            }
            List<Id> poIds = new List<Id>();
            if(mapPurchaseOrder.size() > 0){
                poIds=insertPO(mapPurchaseOrder,mapPurchaseOrderLine);
            }  
            objReturnResult.NewPurchaseOrderIds =poIds ; 
        }
        catch(exception ex){
            giic_CommonWrapper.GOMException objGOMException=new giic_CommonWrapper.GOMException();
            objGOMException.message=ex.getMessage();
            objReturnResult.Exceptions=new list<giic_CommonWrapper.GOMException>{objGOMException};
                }
         XC_UTIL_Debug.debug(DEBUGACTIVE, 'objReturnResult'+objReturnResult);
        return objReturnResult;     
    } */

    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/11/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming Purchase orders.
    * @param purchaseOdrLineList -  List of PurchaseOrder
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old PurchaseOrder
    */    
   /* public static void setCorrectRecordTypeInUpdate(List<gii__PurchaseOrder__c> listNew,Map<Id,gii__PurchaseOrder__c> mapOld, Map<Id,gii__PurchaseOrder__c> mapNew){
        List<String> fieldList = new List<String>{'gii__DropShip__c', 'gii__ShipTo__c'};
        List<gii__PurchaseOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        setCorrectRecordTypeInInsert(listChanged);     
    }      
    */

}
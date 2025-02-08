/** 
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 02/09/2019
* @description Class of future methods for integration with glovia
*/
public without sharing class giic_UTIL_CheckInventory {
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018
* @date Modification
* @description Giic_InputInventoryWrapper
*/
    public class Giic_InputInventoryWrapper  {
        public String wareHouseCode;
        public String prod2Code;
        public String eanCode;
        public String sku_code;
        public Integer quantity;
        public String reason;
        public String location;
        public String locationTo;
        public List<String> serials;
        public Map<String, Integer> lots;
    }
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_UTIL_CheckInventory');
    
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param inventoryWrappers
* @return  List<XC_UTIL_Sobject.WrapperResult>
* @description inventoryAdjustment 
*/  
    public static List<XC_UTIL_Sobject.WrapperResult> checkInventory(List<Giic_InputInventoryWrapper> inventoryWrappers){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'giic_UTIL_CheckInventory -  checkInventory');
        List<Giic_InputInventoryWrapper> adjustmentList = new List<Giic_InputInventoryWrapper>();
        List<Giic_InputInventoryWrapper> movementList = new List<Giic_InputInventoryWrapper>();
        List<XC_UTIL_Sobject.WrapperResult> rwList = new List<XC_UTIL_Sobject.WrapperResult>();     
        for(Giic_InputInventoryWrapper iiw : inventoryWrappers){ 
            if( (iiw.prod2Code == null && iiw.eanCode == null)  ||  iiw.wareHouseCode == null || iiw.location == null ||
               iiw.quantity == null  ||  iiw.reason == null){
                   XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                   rw.success = false;
                   rw.errorMessage = 'Missing mandatory field : product ,warehouse , location,  quantity , reason';
                   rwList.add(rw);    
               } 
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ serial:' + iiw.serials);
            if(iiw.serials != null ){
                if(!iiw.serials.isEmpty()  && math.abs(iiw.quantity) != iiw.serials.size() ){ 
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ serial:' + iiw.serials);
                    XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                    rw.success = false;
                    rw.errorMessage = 'The quantity does not match with the number of serial';
                    rwList.add(rw);
                }
            }
            System.debug('iiw.locationTo = '+iiw.locationTo);
            if(iiw.locationTo != null && iiw.locationTo != ''){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'dentro if');
                System.debug('aggiungo per movement');
                movementList.add(iiw);  
            }else{ 
                 System.debug('aggiungo per adjustment');
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro else:' );
                adjustmentList.add(iiw);
            }   
            
        }
        if(!rwList.isEmpty()){  return rwList;    } 
        if(!adjustmentList.isEmpty()){
            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ inventoryAdjustment:');
            rwList.addAll(inventoryAdjustment(adjustmentList));
        } 
        if(!movementList.isEmpty()){
            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ inventoryMovement:');
            rwList.addAll(inventoryMovement(movementList));
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ rwList' + rwList);
        return rwList;
    }
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param inventoryWrappers
* @return  List<XC_UTIL_Sobject.WrapperResult>
* @description inventoryAdjustment
*/  
    public static List<XC_UTIL_Sobject.WrapperResult> inventoryAdjustment(List<Giic_InputInventoryWrapper> inventoryWrappers){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'giic_UTIL_CheckInventory -  inventoryAdjustment');
        Map<String,List<gii__ProductInventoryQuantityDetail__c>> reasonPIQD = new Map<String,List<gii__ProductInventoryQuantityDetail__c>>();
        List<XC_UTIL_Sobject.WrapperResult> rwList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        List<String> prodCode = new List<String>();
        List<String> eanCode = new List<String>();
        List<String> skuCode = new List<String>();
        List<String> warehouseCode = new List<String>();
        List<String> serialName = new List<String>();
        List<String> lotName = new List<String>();
        List<String> locations = new List<String>();
        Map<String,Id> mapProdCodeProdId = new Map<String,Id> ();
        Map<String,String> mapEanCodeProdCode = new Map<String,String> ();
        Map<String,Id> mapEanCodeProdId = new Map<String,Id> ();
        Map<String,Boolean> mapProdCodeSerialControlled = new Map<String,Boolean> ();
        Map<String,Boolean> mapProdCodeLotControlled = new Map<String,Boolean> ();
        Map<String,Id> mapWHCodeWHId = new Map<String,Id> ();
        Map<String,Id> mapLocCodeLocId = new Map<String,Id> (); 
        Map<String, List<String>> serialToBeCreated = new Map<String, List<String>>(); 
        Map<String, Map<String, Integer>> lotToBeCreated = new Map<String, Map<String, Integer>>(); 
        List<gii__ProductSerial__c> serialToInsert = new List<gii__ProductSerial__c>();
        List<gii__ProductLot__c> lotToInsert = new List<gii__ProductLot__c>();
        List<gii__ProductInventoryQuantityDetail__c> piqdToInsert = new List<gii__ProductInventoryQuantityDetail__c>();
        Map<String,gii__ProductInventoryQuantityDetail__c> mapOfPdtWhLocVsListPIQD = new Map<String,gii__ProductInventoryQuantityDetail__c>();
        Map<String,gii__ProductInventoryQuantityDetail__c> mapOfPdtWhLocSerialVsPIQD = new Map<String,gii__ProductInventoryQuantityDetail__c>(); 
        Map<String,gii__ProductInventoryQuantityDetail__c> mapOfPdtWhLocLotVsPIQD = new Map<String,gii__ProductInventoryQuantityDetail__c>(); 
        Map<String,gii__ProductInventory__c> mapOfPdtWhLocVsPI = new Map<String,gii__ProductInventory__c>();
        
        Savepoint sp = Database.setSavepoint();
        
        Map<String,Id> mapSerialNameSerialProduct = new Map<String,Id>();
        Map<String,Id> mapLotNameLotProduct = new Map<String,Id>();
        for(Giic_InputInventoryWrapper iiw : inventoryWrappers){ 
            prodCode.add(iiw.prod2Code);
            eanCode.add(iiw.eanCode); 
            if(iiw.sku_code != null && iiw.sku_code != ''){
                skuCode.add(iiw.sku_code);
            }
            warehouseCode.add(iiw.wareHouseCode);
            locations.add(iiw.location);
            if(iiw.serials != null ){
                
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                if(iiw.quantity > 0 && !iiw.serials.isEmpty() ){ // iiw.serials!=null
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                    if(iiw.eanCode != null){    serialToBeCreated.put(iiw.eanCode,iiw.serials);  
                                           }else{ serialToBeCreated.put(iiw.prod2Code,iiw.serials); } 
                }
                if(!iiw.serials.isEmpty() ){ // != null
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ iiw.serials:' + iiw.serials);
                    serialName.addAll(iiw.serials);  
                }
            }
            if(iiw.lots != null ){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro  if:');
                if(iiw.quantity > 0 && !iiw.lots.keySet().isEmpty() ){ // iiw.serials!=null
                    
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro  if:');
                    if(iiw.eanCode != null){ lotToBeCreated.put(iiw.eanCode,iiw.lots);  
                                           }else{ lotToBeCreated.put(iiw.prod2Code,iiw.lots); } 
                }
                if(!iiw.lots.keySet().isEmpty() ){ // != null
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ iiw.lots:' + iiw.lots);
                    lotName.addAll(iiw.lots.keySet());  
                }
            }
        }
        Map<Id,gii__Product2Add__c> prodRefs = new Map<Id,gii__Product2Add__c>();
        // INC000090188137
        System.debug('size: '+ skuCode.size());
        System.debug('skuCode = '+ skuCode);
        if(skuCode != null && !skuCode.isEmpty()){
            System.debug('skuCode size > 0');
            prodRefs = giic_UTIL_CheckInventory_D.getProductRef(prodCode, eanCode, skuCode);
        }else{
            System.debug('skuCode size = 0');
            prodRefs = giic_UTIL_CheckInventory_D.getProductRef(prodCode, eanCode);
        }
        // INC000090188137
        System.debug('prodRefs TROVATE = '+prodRefs);
        Map<Id,gii__Warehouse__c> was = giic_UTIL_CheckInventory_D.getWarehouse(warehouseCode, locations);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'giic_UTIL_CheckInventory -  inventoryAdjustment');
        if(!prodRefs.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ PROD');
            for(gii__Product2Add__c p2 : prodRefs.values()){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
                mapProdCodeProdId.put(p2.gii__ProductCode__c, p2.Id);
                mapProdCodeProdId.put(p2.giic_EANReference__c, p2.Id); 
                mapProdCodeProdId.put(p2.giic_SKUCode__c, p2.Id);
                mapEanCodeProdId.put(p2.giic_EANReference__c, p2.Id); 
                mapEanCodeProdCode.put(p2.giic_EANReference__c, p2.gii__ProductCode__c);
                prodCode.add(p2.gii__ProductCode__c); 
                 XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ prodCode:'+ prodCode);
            }
        }
        if(!was.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ warehouse' );
            for(gii__Warehouse__c w : was.values()){
                mapWHCodeWHId.put(w.giic_WarehouseCode__c, w.Id); 
                if(!w.gii__Locations__r.isEmpty()){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                    for(gii__Location__c l : w.gii__Locations__r){
                        mapLocCodeLocId.put(l.Name, l.Id); 
                    }
                } 
            }
        }
        if(serialName != null){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
            List<gii__ProductSerial__c> mapSerial = giic_UTIL_CheckInventory_D.getSerial(serialName,prodCode); 
            if(!mapSerial.isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                for(gii__ProductSerial__c serial : mapSerial){
                    mapSerialNameSerialProduct.put(serial.Name+serial.gii__Product__r.gii__ProductCode__c, serial.Id);
                    mapSerialNameSerialProduct.put(serial.Name+serial.gii__Product__r.giic_EANReference__c, serial.Id);
                }
            } 
        }        
        if(!serialToBeCreated.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
            for(String prod : serialToBeCreated.keyset()){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro fro:');
                for(String serial : serialToBeCreated.get(prod)){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
                    if(!mapSerialNameSerialProduct.containskey(serial+prod)){
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                        gii__ProductSerial__c ps = new gii__ProductSerial__c();
                        if(mapEanCodeProdId.containskey(prod)){ ps.gii__Product__c = mapEanCodeProdId.get(prod);}
                        else{ ps.gii__Product__c = mapProdCodeProdId.get(prod); } 
                        ps.Name = serial;
                        serialToInsert.add(ps);  
                    } 
                }
            } 
        }
        if(!serialToInsert.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro  if:');
            List<XC_UTIL_Sobject.WrapperResult> serialInsert = XC_UTIL_Sobject.insertListRecords(serialToInsert); 
            rwList.addAll(serialInsert);
            List<String> serialId = new List<String>();
            for(XC_UTIL_Sobject.WrapperResult res : serialInsert){
                if(res.success){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                    serialId.add(res.recordId);
                }
            }
            List<gii__ProductSerial__c> serialList = giic_UTIL_CheckInventory_D.getSerialFromId(serialId);
            
            if(!serialList.isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'giic_UTIL_CheckInventory -  serialList '+serialList);
                for(gii__ProductSerial__c serial : serialList){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
                    mapSerialNameSerialProduct.put(serial.Name+serial.gii__Product__r.gii__ProductCode__c, serial.Id); 
                    mapSerialNameSerialProduct.put(serial.Name+serial.gii__Product__r.giic_EANReference__c, serial.Id);
                }
            } 
        } 
        if(lotName != null){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro else if:');
            List<gii__ProductLot__c> mapLot = giic_UTIL_CheckInventory_D.getLot(lotName,prodCode); 
            if(!mapLot.isEmpty()){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro else if:');
                for(gii__ProductLot__c lot : mapLot){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for');
                    mapLotNameLotProduct.put(lot.Name+lot.gii__Product__r.gii__ProductCode__c, lot.Id);
                    mapLotNameLotProduct.put(lot.Name+lot.gii__Product__r.giic_EANReference__c, lot.Id);
                }
            } 
        }        
        if(!lotToBeCreated.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro  if:');
            for(String prod : lotToBeCreated.keyset()){
                for(String lot : lotToBeCreated.get(prod).keyset()){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
                    if(!mapLotNameLotProduct.containskey(lot+prod)){
                        gii__ProductLot__c pl = new gii__ProductLot__c();
                        if(mapEanCodeProdId.containskey(prod)){  pl.gii__Product__c = mapEanCodeProdId.get(prod);
                         }else{  pl.gii__Product__c = mapProdCodeProdId.get(prod);   } 
                        pl.Name = lot;
                        lotToInsert.add(pl);  
                    } 
                }
            } 
        }
        if(!lotToInsert.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> lotInsert = XC_UTIL_Sobject.insertListRecords(lotToInsert); 
            rwList.addAll(lotInsert);
            List<String> lotId = new List<String>();
            for(XC_UTIL_Sobject.WrapperResult res : lotInsert){
                if(res.success){  lotId.add(res.recordId); }
            }
            List<gii__ProductLot__c> lotList = giic_UTIL_CheckInventory_D.getLotFromId(lotId);
            
            if(!lotList.isEmpty()){
                for(gii__ProductLot__c lot : lotList){
                    mapLotNameLotProduct.put(lot.Name+lot.gii__Product__r.gii__ProductCode__c, lot.Id); 
                    mapLotNameLotProduct.put(lot.Name+lot.gii__Product__r.giic_EANReference__c, lot.Id);
                }
            } 
        } 
        Map<Id,gii__ProductInventory__c> mapOfIdVsPIQD = giic_UTIL_CheckInventory_D.getProductInventory(warehouseCode,locations,prodCode);  
        if(!mapOfIdVsPIQD.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'giic_UTIL_CheckInventory -  mapOfIdVsPIQD '+mapOfIdVsPIQD);
            for(gii__ProductInventory__c pi : mapOfIdVsPIQD.values()){ 
                String piPdtId = (String)pi.gii__Product__r.gii__ProductCode__c;
                String piWhId = (String)pi.gii__Warehouse__r.giic_WarehouseCode__c; 
                String keyPI = piPdtId + piWhId;  
                mapOfPdtWhLocVsPI.put(keyPI, pi); 
                for(gii__ProductInventoryQuantityDetail__c pIQD : pi.gii__ProductInventoryQuantityDetails__r){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
                    String pdtId = (String)pIQD.gii__Product__r.gii__ProductCode__c;
                    String whId = (String)pIQD.gii__Warehouse__r.giic_WarehouseCode__c;
                    String locId = (String)pIQD.gii__Location__r.Name; 
                    String key = pdtId + whId + locId; 
                    if(pIQD.gii__ProductSerial__c != null){
                        String serial = (String)pIQD.gii__ProductSerial__c;
                        String keySerial =key + serial; 
                        mapOfPdtWhLocSerialVsPIQD.put(keySerial,pIQD); 
                    }else if(pIQD.gii__ProductLot__c != null){
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro else if:');
                        String lot = (String)pIQD.gii__ProductLot__c;
                        String keyLot =key + lot; 
                        mapOfPdtWhLocLotVsPIQD.put(keyLot,pIQD); 
                    }else{  mapOfPdtWhLocVsListPIQD.put(key,pIQD);  }
                }
            } 
        } 
        
        List<gii__ProductInventory__c> piToInsert = new List<gii__ProductInventory__c>();
        for(Giic_InputInventoryWrapper iiw : inventoryWrappers){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
            String key  = iiw.prod2Code + iiw.wareHouseCode ; 
            String prod =  iiw.prod2Code;
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ key :' + key);
            if(iiw.eanCode != null ){
                key = mapEanCodeProdCode.get(iiw.eanCode) + iiw.wareHouseCode ;
                prod = mapEanCodeProdCode.get(iiw.eanCode);
            }  
            if(prodRefs.containsKey(mapProdCodeProdId.get(prod)) && prodRefs.get(mapProdCodeProdId.get(prod)).gii__SerialControlled__c && iiw.serials == null){ 
                XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                rw.success = false;
                rw.errorMessage = 'The product is serial controlled,  you must enter the list of serials';
                rwList.add(rw); 
            }else if(prodRefs.containsKey(mapProdCodeProdId.get(prod)) && prodRefs.get(mapProdCodeProdId.get(prod)).gii__LotControlled__c && iiw.lots == null){ 
                XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                rw.success = false;
                rw.errorMessage = 'The product is lot controlled,  you must enter the list of lots';
                rwList.add(rw); 
            }
            if(!mapOfPdtWhLocVsPI.containsKey(key)){ 
                if(iiw.quantity > 0){
                    // inserire la product inventory
                    gii__ProductInventory__c pi = new gii__ProductInventory__c(gii__Product__c=mapProdCodeProdId.get(prod), 
                                                                               gii__Warehouse__c=mapWHCodeWHId.get(iiw.wareHouseCode));
                    piToInsert.add(pi);   
                    mapOfPdtWhLocVsPI.put(key, pi); 
                }else {
                    XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                    rw.success = false;
                    rw.errorMessage = 'You cannot insert a new product inventory with negative quantity';
                    rwList.add(rw);
                }  
            }
        } 
        List<Id> piIdInsert = new List<Id>();
        System.debug('piToInsert = '+piToInsert);
        if(!piToInsert.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> piInsert = XC_UTIL_Sobject.insertListRecords(piToInsert); 
            rwList.addAll(piInsert);
            for(XC_UTIL_Sobject.WrapperResult result : piInsert){
                if(result.success){   piIdInsert.add(result.recordId);  }
            }
        }
        
        for(Giic_InputInventoryWrapper iiw : inventoryWrappers){
            String key  = iiw.prod2Code + iiw.wareHouseCode ; 
            String prod =  iiw.prod2Code;
            if(iiw.eanCode != null ){
                key = mapEanCodeProdCode.get(iiw.eanCode) + iiw.wareHouseCode ;
                prod = mapEanCodeProdCode.get(iiw.eanCode);
            } 
            if(!reasonPIQD.containsKey(iiw.reason)){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                reasonPIQD.put(iiw.reason , new List<gii__ProductInventoryQuantityDetail__c>());
            }
            if(iiw.serials != null && !iiw.serials.isEmpty()  ){ // !=null
                if(iiw.quantity < 0){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                    for(String serial : iiw.serials){  
                        String keySerial = key + iiw.location + mapSerialNameSerialProduct.get(serial+prod);
                        gii__ProductInventoryQuantityDetail__c pIqd = mapOfPdtWhLocSerialVsPIQD.get(keySerial);
                        pIqd.gii__OnHandQuantity__c = 0; 
                        reasonPIQD.get(iiw.reason).add(pIqd);
                    }
                }else{
                    for(String serial : iiw.serials){ 
                        String keySerial = key + iiw.location + mapSerialNameSerialProduct.get(serial+prod);
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ serial:' + serial);
                        if(!mapOfPdtWhLocSerialVsPIQD.containskey(keySerial)){
                            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ keySerial:' + keySerial);
                            gii__ProductInventoryQuantityDetail__c piqd = new gii__ProductInventoryQuantityDetail__c();
                            piqd.gii__OnHandQuantity__c= 1;
                            piqd.gii__ProductSerial__c =  mapSerialNameSerialProduct.get(serial+ prod);
                            piqd.gii__Location__c = mapLocCodeLocId.get(iiw.location);
                            piqd.gii__Warehouse__c = mapWHCodeWHId.get(iiw.wareHouseCode);
                            piqd.gii__Product__c = mapProdCodeProdId.get(prod);
                            piqd.gii__ProductInventory__c = mapOfPdtWhLocVsPI.get(key).Id;
                            piqdToInsert.add(piqd);
                            reasonPIQD.get(iiw.reason).add(piqd);
                        }else{
                            gii__ProductInventoryQuantityDetail__c pIqd = mapOfPdtWhLocSerialVsPIQD.get(keySerial);
                            pIqd.gii__OnHandQuantity__c = 1; 
                            reasonPIQD.get(iiw.reason).add(pIqd);
                        }
                        
                    }
                }
            }else if(iiw.lots != null && !iiw.lots.keySet().isEmpty()  ){ // !=null
                if(iiw.quantity < 0){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                    for(String lot : iiw.lots.keySet()){  
                        String keyLot = key + iiw.location + mapLotNameLotProduct.get(lot+prod);
                        gii__ProductInventoryQuantityDetail__c pIqd = mapOfPdtWhLocLotVsPIQD.get(keyLot);
                        pIqd.gii__OnHandQuantity__c = mapOfPdtWhLocLotVsPIQD.get(keyLot).gii__OnHandQuantity__c - math.abs(iiw.lots.get(lot)) ; 
                        reasonPIQD.get(iiw.reason).add(pIqd);
                    }
                }else{
                    for(String lot : iiw.lots.keySet()){ 
                        String keyLot = key + iiw.location + mapLotNameLotProduct.get(lot+prod);
                        if(!mapOfPdtWhLocLotVsPIQD.containskey(keyLot)){
                            gii__ProductInventoryQuantityDetail__c piqd = new gii__ProductInventoryQuantityDetail__c();
                            piqd.gii__OnHandQuantity__c= iiw.lots.get(lot);
                            piqd.gii__ProductLot__c =  mapLotNameLotProduct.get(lot+prod);
                            piqd.gii__Location__c = mapLocCodeLocId.get(iiw.location);
                            piqd.gii__Warehouse__c = mapWHCodeWHId.get(iiw.wareHouseCode);
                            piqd.gii__Product__c = mapProdCodeProdId.get(prod);
                            piqd.gii__ProductInventory__c = mapOfPdtWhLocVsPI.get(key).Id;
                            piqdToInsert.add(piqd);
                            reasonPIQD.get(iiw.reason).add(piqd);
                        }else{
                            gii__ProductInventoryQuantityDetail__c pIqd = mapOfPdtWhLocLotVsPIQD.get(keyLot);
                            pIqd.gii__OnHandQuantity__c = pIqd.gii__OnHandQuantity__c + iiw.lots.get(lot); 
                            reasonPIQD.get(iiw.reason).add(pIqd);
                        }
                    }
                }
            }else{
                System.debug('Entrato in caso non Serializzati');
                //caso non seriali , se esiste la piqd faccio l'aggiornamento senno la creo nuova
                System.debug('mapOfPdtWhLocVsListPIQD = '+mapOfPdtWhLocVsListPIQD);
                String keyLocation = prod + iiw.wareHouseCode + iiw.location;
                System.debug('keyLocation = '+keyLocation);
                if(mapOfPdtWhLocVsListPIQD.containsKey(keyLocation)){
                    gii__ProductInventoryQuantityDetail__c pIqd = mapOfPdtWhLocVsListPIQD.get(keyLocation);
                    if(iiw.quantity > 0 ){
                        pIqd.gii__OnHandQuantity__c =  pIqd.gii__OnHandQuantity__c + iiw.quantity ; 
                        reasonPIQD.get(iiw.reason).add(piqd);
                    }else if(iiw.quantity < 0 && pIqd.gii__OnHandQuantity__c >= math.abs(iiw.quantity)){
                        System.debug('qua');
                        pIqd.gii__OnHandQuantity__c =  pIqd.gii__OnHandQuantity__c + iiw.quantity ; 
                        reasonPIQD.get(iiw.reason).add(piqd);
                    }else{
                        XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                        rw.success = false;
                        rw.errorMessage = 'Quantity on hand is less than quantity to be remove';
                        rwList.add(rw); 
                        Database.rollback(sp); 
                        return rwList;
                    }
                    
                }else{
                    if(iiw.quantity < 0 ){
                        System.debug('caso quantity < 0');
                        XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                        rw.success = false;
                        rw.errorMessage = 'You cannot insert a new product inventory quantity detail with negative quantity';
                        rwList.add(rw); 
                        Database.rollback(sp); 
                        return rwList;
                    }else{
                        System.debug('mapLocCodeToLocId = '+mapLocCodeLocId);
                        if(mapLocCodeLocId.containsKey(iiw.location)){
                        gii__ProductInventoryQuantityDetail__c piqd = new gii__ProductInventoryQuantityDetail__c();
                        piqd.gii__OnHandQuantity__c = iiw.quantity; 
                        
                        piqd.gii__Location__c = mapLocCodeLocId.get(iiw.location);
                        piqd.gii__Warehouse__c = mapWHCodeWHId.get(iiw.wareHouseCode);
                        piqd.gii__Product__c = mapProdCodeProdId.get(prod);
                        piqd.gii__ProductInventory__c = mapOfPdtWhLocVsPI.get(key).Id;
                        piqdToInsert.add(piqd);
                        reasonPIQD.get(iiw.reason).add(piqd);
                        }else{
                               System.debug('location non trovata');
                          	   XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                        	   rw.success = false;
                               rw.errorMessage = 'Location code not found!';
                               rwList.add(rw); 
                               Database.rollback(sp); 
                               return rwList;
                            
                        }
                    }
                } 
            }  
        } 
        List<gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult> resultList = new List<gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult>();
        if(reasonPIQD != null && !reasonPIQD.values().isEmpty() ){
            for(String reason : reasonPIQD.keySet()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ reason ' + reason);
                gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult result = doInventoryAdjustments(reason , reasonPIQD.get(reason));
                resultList.add(result);
            }
        } 
        System.debug('resultList = '+resultList);
        for(gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult res : resultList){
            if(res.Exceptions!=null && !res.Exceptions.isEmpty()){ 
                XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                rw.success = false;
                rw.errorMessage = 'Inventory adjustment error!!' + res.Exceptions;
                rwList.add(rw); 
                Database.rollback(sp); 
            }else{
                XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                rw.success = true; 
                rwList.add(rw);
            } 
        }
        return rwList;
    }
    
    /**
* @author FirstName : Pradeep  Kumar pradeep.p.kumar@in.fujitsu.com
* @date Creation 29/07/2019
* @date Modification dd/mm/yyyy
* @description - This method  performs Inventory Adjustements
* @param lstPIQDToSendForInv List<gii__ProductInventoryQuantityDetail__c>  
*@return gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult
*/   
    public static gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult doInventoryAdjustments(String reason ,List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInv){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'giic_UTIL_CheckInventory -  doInventoryAdjustments');
        gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultObj = new gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult(); 
        if(!lstPIQDToSendForInv.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
            gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails quantityDetailsObj = new gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails();
            quantityDetailsObj.listProductInventoryQuantityDetails = lstPIQDToSendForInv;
            quantityDetailsObj.AdjustmentDate = system.today(); 
            quantityDetailsObj.AdjustmentReason = reason;                             
            resultObj = gii.InventoryAdjustmentforLocation.CreateInventoryAdustments(quantityDetailsObj);
        } 
        return resultObj;
    }
    
    /**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 21/11/2018 
* @param inventoryWrappers
* @return  List<XC_UTIL_Sobject.WrapperResult>
* @description inventoryMovement
*/  
    public static List<XC_UTIL_Sobject.WrapperResult> inventoryMovement(List<Giic_InputInventoryWrapper> inventoryWrappers){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'giic_UTIL_CheckInventory -  inventoryMovement');
        List<XC_UTIL_Sobject.WrapperResult> rwList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        List<String> prodCode = new List<String>();
        List<String> eanCode = new List<String>();
        List<String> warehouseCode = new List<String>();
        List<String> serialName = new List<String>();
        List<String> lotName = new List<String>();
        List<String> locations = new List<String>();
        List<String> locationTo = new List<String>();
        Savepoint sp = Database.setSavepoint(); 
        for(Giic_InputInventoryWrapper iiw : inventoryWrappers){ 
            prodCode.add(iiw.prod2Code);
            eanCode.add(iiw.eanCode);
            warehouseCode.add(iiw.wareHouseCode);
            if(iiw.quantity < 0){
                XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                rw.success = false;
                rw.errorMessage = 'Quantity must be greater than 0';
                rwList.add(rw);
            }
            if(iiw.serials != null ){
                if(!iiw.serials.isEmpty()){ serialName.addAll(iiw.serials);   }
            }
            if(iiw.lots != null ){
                if(!iiw.lots.keyset().isEmpty()){ // != null 
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ lots:' + iiw.lots);
                    lotName.addAll(iiw.lots.keyset());  
                }
            }
            locations.add(iiw.location); 
            locationTo.add(iiw.locationTo); 
        }
        if(!rwList.isEmpty()){  return rwList;   }
        
        Map<Id,gii__Product2Add__c> prodRefs = giic_UTIL_CheckInventory_D.getProductRef(prodCode, eanCode);
        
        Map<String,String> mapEanCodeProdCode = new Map<String,String> ();
        Map<String,Boolean> mapProdCodeSerialControlled = new Map<String,Boolean> ();
        Map<String,Boolean> mapProdCodeLotControlled = new Map<String,Boolean> ();
        if(!prodRefs.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@prod ref');
            for(gii__Product2Add__c p2 : prodRefs.values()){  
                mapProdCodeSerialControlled.put(p2.gii__ProductCode__c,p2.gii__SerialControlled__c);
                mapProdCodeSerialControlled.put(p2.giic_EANReference__c,p2.gii__SerialControlled__c);
                mapProdCodeLotControlled.put(p2.gii__ProductCode__c,p2.gii__LotControlled__c);
                mapProdCodeLotControlled.put(p2.giic_EANReference__c,p2.gii__LotControlled__c);
                mapEanCodeProdCode.put(p2.giic_EANReference__c, p2.gii__ProductCode__c);
                prodCode.add(p2.gii__ProductCode__c); 
            }
        }
        Map<Id,gii__Location__c> mapLocationTo = giic_UTIL_CheckInventory_D.getLocationsByWH(locationTo,warehouseCode);
        
        Map<String,Id> mapLocCodeLocId = new Map<String,Id> (); 
        if(!mapLocationTo.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
            for(gii__Location__c l : mapLocationTo.values()){
                mapLocCodeLocId.put(l.Name, l.Id); 
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
            }
        }
        List<gii__ProductInventoryQuantityDetail__c> piqdList = giic_UTIL_CheckInventory_D.getPIQD( warehouseCode, locations, prodCode);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'piqdList = '+piqdList);
        Map<String,gii__ProductInventoryQuantityDetail__c> mapOfPdtWhLocVsListPIQD = new Map<String,gii__ProductInventoryQuantityDetail__c>();
        Map<String,gii__ProductInventoryQuantityDetail__c> mapOfPdtWhLocSerialVsPIQD = new Map<String,gii__ProductInventoryQuantityDetail__c>(); 
        Map<String,gii__ProductInventoryQuantityDetail__c> mapOfPdtWhLocLotVsPIQD = new Map<String,gii__ProductInventoryQuantityDetail__c>(); 
        
        if(!piqdList.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
            for(gii__ProductInventoryQuantityDetail__c pIQD : piqdList){ 
                String pdtId = (String)pIQD.gii__Product__r.gii__ProductCode__c;
                String whId = (String)pIQD.gii__Warehouse__r.giic_WarehouseCode__c;
                String locId = (String)pIQD.gii__Location__r.Name; 
                String key = pdtId + whId + locId; 
                XC_UTIL_Debug.debug(DEBUGACTIVE,'pIQD = '+pIQD);
                if(pIQD.gii__ProductSerial__c != null){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                    String serial = (String)pIQD.gii__ProductSerial__r.Name;
                    String keySerial = key + serial; 
                    mapOfPdtWhLocSerialVsPIQD.put(keySerial,pIQD); 
                }else if(pIQD.gii__ProductLot__c != null){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro else if:');
                    String lot = (String)pIQD.gii__ProductLot__r.Name;
                    String keyLot = key + lot; 
                    mapOfPdtWhLocLotVsPIQD.put(keyLot,pIQD); 
                }else{
                    
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro else:');
                    mapOfPdtWhLocVsListPIQD.put(key,pIQD);
                }
            }
        }else{
            XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
            rw.success = false;
            rw.errorMessage = 'The product inventory quantity detail does not exist';
            rwList.add(rw);
        } 
        if(!rwList.isEmpty()){ return rwList;}
        List<gii.InventoryMovement.InventoryMovementDetails> listwr = new list<gii.InventoryMovement.InventoryMovementDetails>();
        List<giic_InventoryMovement__c> listInvMov = new list<giic_InventoryMovement__c>();
        for(Giic_InputInventoryWrapper iiw : inventoryWrappers){
            String prod =  iiw.prod2Code;
            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro for:');
            if(iiw.eanCode != null ){   prod = mapEanCodeProdCode.get(iiw.eanCode); } 
            if(iiw.serials != null ){   
                if(mapProdCodeSerialControlled.get(prod) && iiw.serials.isEmpty() ){ // == null
                    XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                    rw.success = false;
                    rw.errorMessage = 'The product is serial controlled,  you must enter the list of serials ';
                    rwList.add(rw); 
                }
                if(!iiw.serials.isEmpty()){ // != null
                    for(String serial : iiw.serials ){ 
                        String key = prod + iiw.wareHouseCode + iiw.location + serial; 
                        if(!mapOfPdtWhLocSerialVsPIQD.containsKey(key)){
                            XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                            rw.success = false;
                            rw.errorMessage = 'The serial '+ serial + 'does not belong to this warehouse' ;
                            rwList.add(rw);   
                            break;
                        }
                        gii.InventoryMovement.InventoryMovementDetails wr = new gii.InventoryMovement.InventoryMovementDetails(); 
                        wr.QuantitytoBeMoved = 1;
                        wr.BlockedQuantity = 0;
                        wr.SourceProductInventoryQuantityDetail = mapOfPdtWhLocSerialVsPIQD.get(key);
                        wr.TargetLocationId = mapLocCodeLocId.get(iiw.locationTo);
                        if(mapOfPdtWhLocSerialVsPIQD.get(key)!=null){
                            giic_InventoryMovement__c invMov = new giic_InventoryMovement__c();
                            invMov.giic_MovementDate__c = Date.today() ;
                            invMov.giic_MovedQuantity__c = 1 ;
                            invMov.giic_Location__c = mapOfPdtWhLocSerialVsPIQD.get(key).gii__Location__c;
                            System.debug('invMov.giic_Location__c  = '+invMov.giic_Location__c );
                            invMov.giic_LocationTo__c = mapLocCodeLocId.get(iiw.locationTo);
                            System.debug('invMov.giic_LocationTo__c = '+invMov.giic_LocationTo__c);
                           
                            invMov.giic_Product__c= mapOfPdtWhLocSerialVsPIQD.get(key).gii__Product__c;
                            invMov.giic_ProductInventoryQuantityDetail__c= mapOfPdtWhLocSerialVsPIQD.get(key).Id;
                            invMov.giic_ProductInventory__c= mapOfPdtWhLocSerialVsPIQD.get(key).gii__ProductInventory__c;
                            invMov.giic_ProductSerial__c= mapOfPdtWhLocSerialVsPIQD.get(key).gii__ProductSerial__c;
                            invMov.giic_Warehouse__c =mapOfPdtWhLocSerialVsPIQD.get(key).gii__Warehouse__c;
                            invMov.giic_Reason__c= iiw.reason ;
                            listInvMov.add(invMov);
                        }
                        listwr.add(wr); 
                    }
                }
            }else if(iiw.lots != null){ 
                if(mapProdCodeLotControlled.get(prod) && iiw.lots.keyset().isEmpty()){ // == null
                    XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                    rw.success = false;
                    rw.errorMessage = 'The product is lot controlled,  you must enter the list of lots ';
                    rwList.add(rw); 
                }
                if(!iiw.lots.keySet().isEmpty()){ // != null
                    for(String lot : iiw.lots.keySet()){ 
                        String key = prod + iiw.wareHouseCode + iiw.location + lot; 
                        if(!mapOfPdtWhLocLotVsPIQD.containsKey(key)){
                            XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
                            rw.success = false;
                            rw.errorMessage = 'The lot '+ lot + 'does not belong to this warehouse' ;
                            rwList.add(rw);   
                            break;
                        }
                        gii.InventoryMovement.InventoryMovementDetails wr = new gii.InventoryMovement.InventoryMovementDetails(); 
                        wr.QuantitytoBeMoved = iiw.lots.get(lot) ;
                        wr.BlockedQuantity = 0; 
                        wr.SourceProductInventoryQuantityDetail = mapOfPdtWhLocLotVsPIQD.get(key); 
                        wr.TargetLocationId = mapLocCodeLocId.get(iiw.locationTo); 
                        if(mapOfPdtWhLocLotVsPIQD.get(key)!=null){
                            
                            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                            giic_InventoryMovement__c invMov = new giic_InventoryMovement__c();
                            invMov.giic_MovementDate__c = Date.today() ;
                            invMov.giic_MovedQuantity__c = 1 ;
                            invMov.giic_LocationTo__c = mapLocCodeLocId.get(iiw.locationTo);
                            invMov.giic_Location__c = mapOfPdtWhLocLotVsPIQD.get(key).gii__Location__c;
                            invMov.giic_Product__c= mapOfPdtWhLocLotVsPIQD.get(key).gii__Product__c;
                            invMov.giic_ProductInventoryQuantityDetail__c= mapOfPdtWhLocLotVsPIQD.get(key).Id;
                            invMov.giic_ProductInventory__c= mapOfPdtWhLocLotVsPIQD.get(key).gii__ProductInventory__c;
                            invMov.giic_ProductLot__c= mapOfPdtWhLocLotVsPIQD.get(key).gii__ProductLot__c;
                            invMov.giic_Warehouse__c =mapOfPdtWhLocLotVsPIQD.get(key).gii__Warehouse__c;
                            invMov.giic_Reason__c= iiw.reason ;
                            listInvMov.add(invMov);
                        }
                        listwr.add(wr); 
                    }
                }
            }else{ // CASO NORMALI
                System.debug('In caso normali');
                gii.InventoryMovement.InventoryMovementDetails wr = new gii.InventoryMovement.InventoryMovementDetails();
                wr.QuantitytoBeMoved = iiw.quantity;
                wr.BlockedQuantity = 0;
                String key = prod + iiw.wareHouseCode + iiw.location;
                wr.SourceProductInventoryQuantityDetail = mapOfPdtWhLocVsListPIQD.get(key); 
                wr.TargetLocationId = mapLocCodeLocId.get(iiw.locationTo); 
                System.debug('wr.TargetLocationId = '+ wr.TargetLocationId);
                if(mapOfPdtWhLocVsListPIQD.get(key)!=null){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ dentro if:');
                    giic_InventoryMovement__c invMov = new giic_InventoryMovement__c();
                    invMov.giic_MovementDate__c = Date.today() ;
                    invMov.giic_MovedQuantity__c = iiw.quantity ;
                    System.debug('invMov.giic_MovedQuantity__c  = '+invMov.giic_MovedQuantity__c );
                    invMov.giic_Location__c = mapOfPdtWhLocVsListPIQD.get(key).gii__Location__c;
                    System.debug(' invMov.giic_Location__c = '+ invMov.giic_Location__c);
                    invMov.giic_LocationTo__c = mapLocCodeLocId.get(iiw.locationTo);
                    System.debug('invMov.giic_LocationTo__c = '+invMov.giic_LocationTo__c );
                   
                    invMov.giic_Product__c= mapOfPdtWhLocVsListPIQD.get(key).gii__Product__c;
                    invMov.giic_ProductInventoryQuantityDetail__c= mapOfPdtWhLocVsListPIQD.get(key).Id;
                    invMov.giic_ProductInventory__c= mapOfPdtWhLocVsListPIQD.get(key).gii__ProductInventory__c;
                    invMov.giic_Warehouse__c =mapOfPdtWhLocVsListPIQD.get(key).gii__Warehouse__c;
                    invMov.giic_Reason__c= iiw.reason ;
                    listInvMov.add(invMov);
                }
                listwr.add(wr); 
                
            }
        }
        System.debug('listwr = '+listwr);
        gii.InventoryMovement.InventoryMovementResult res = gii.InventoryMovement.TransferInventory(listwr) ;  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'res = '+res);
        System.debug('res = '+res);
        if(res==null || res.Exceptions==null || !res.Exceptions.isEmpty()){ 
            XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
            rw.success = false;
            rw.errorMessage = 'Inventory movement error';
            rwList.add(rw); 
            Database.rollback(sp); 
        }else{
            XC_UTIL_Sobject.WrapperResult rw = new XC_UTIL_Sobject.WrapperResult(); 
            rw.success = true; 
            rwList.add(rw); 
            if(!listInvMov.isEmpty()){
                List<XC_UTIL_Sobject.WrapperResult> invMovInsert = XC_UTIL_Sobject.insertListRecords(listInvMov);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@ invMovInsert ' + invMovInsert);
                rwList.addAll(invMovInsert);
            }
        } 
        return rwList;
        
    } 
    
}
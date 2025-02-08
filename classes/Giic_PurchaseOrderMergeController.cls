/**
* @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
* @date Creation 20/07/2019
* @date Modification 07/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description giic_PurchaseOrderMerge – Apex Controller for component giic_MergePurchaseOrder
*/

public with sharing class Giic_PurchaseOrderMergeController {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_PurchaseOrderMergeController');
     
    /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @description Wrapper Class for Lightning Page
    */   
    public class DisplayPO {
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public String key;
        @AuraEnabled public String poName;
        @AuraEnabled public String supplier;
        @AuraEnabled public String cig;
        @AuraEnabled public String cup;
        @AuraEnabled public String warehouse;
        @AuraEnabled public String orderStatus;
        @AuraEnabled public Date orderDate;
        @AuraEnabled public String priceBook;
        @AuraEnabled public String contract;
        @AuraEnabled public String codeCluster;
        @AuraEnabled public gii__PurchaseOrder__c cwrapperpo;
        @AuraEnabled public Integer pageSize;
        public DisplayPO() {
            isSelected = false;
            cwrapperpo = new gii__PurchaseOrder__c();
            pageSize= (integer)giic_PageSizeforPOTable__c.getInstance().giic_PageSize__c;//added to store Pagesize value             
        }
    }

    /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @description ParamsWrapper Wrapper
    */ 
    public class ParamsWrapper{
        public List<DisplayPO> lstPORecords = new List<DisplayPO>();
        public Id recordId;
        public Set<String> setNewPOIDs = new Set<String>();
        public Map<string, gii__PurchaseOrder__c> insMap = new Map<string,gii__PurchaseOrder__c>();
        public Set<String> setPOIDs = new Set<String>();
        public List<gii__PurchaseOrderLine__c> lstPOLToUpdate = new List<gii__PurchaseOrderLine__c>();
        public List<gii__PurchaseOrder__c> lstPOtoUPdate =new List<gii__PurchaseOrder__c>();
        public List<gii__PurchaseOrderLine__c> updlst = new List<gii__PurchaseOrderLine__c>();
        public Set<String> pBForPO = new Set<String>();
        public Map<string,Id> mapforPB = new Map<string,Id>();
        public Map<string,gii__PriceBook__c> mapNameToPB = new Map<string,gii__PriceBook__c>();
        public Map<string, Boolean> mapTocheckWL = new Map<string, Boolean>();
    }

    /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @date Mod 07/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description To fetch Purchase Order and Merge Purchase Order and Purchase Order Line
    * @param suppKey - String 
    * @param whkey - String 
    * @param clusters - String
    * @return Map<String, Object>
    */   
    @AuraEnabled
    public static Map<String, Object> fetchPOdata(String suppKey, String whkey, String clusters) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In fetchPOdata');
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<String, Integer> mapCodeRows = new Map<String, Integer>();
        // Query PO with filters:
        List<DisplayPO> lstPORecords = new List<DisplayPO>();
        String statusLabel = System.Label.giic_PODraftStatus;
        String query = 'SELECT ID,Name, gii__Supplier__c, gii__SupplierName__c, giic_Contract__c, giic_WarehouseLimitExceeded__c, giic_PriceBookId__c,gii__PriceBookName__c,gii__TotalOrderQuantity__c,gii__Buyer__c,gii__ShipTo__c,gii__ShipTo__r.Name,gii__ShipToName__c,giic_Status__c,gii__OrderDate__c,giic_CUP__c,giic_CIG__c FROM gii__PurchaseOrder__c  WHERE gii__DropShip__c = false and  gii__Approved__c = false and giic_Status__c = :statusLabel  ';
        if(!String.isBlank(suppKey)) {
            query  = query +' and gii__SupplierName__c = \'' +String.escapeSingleQuotes(suppKey)+ '\'';    
        }
        if(!String.isBlank(whkey)) {
            query = query +' and gii__ShipToName__c = \'' +String.escapeSingleQuotes(whkey)+ '\'';   
        }        
        query = query + 'ORDER BY gii__SupplierName__c, gii__ShipTo__r.Name, gii__PriceBookName__c ASC';
        List<gii__PurchaseOrder__c> lstPO = new List<gii__PurchaseOrder__c>();
        if(Schema.sObjectType.gii__PurchaseOrder__c.isQueryable()){
            lstPO = Database.query(query);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ PO retrieved:' + lstPO);

        if(lstPO != null && lstPO.size() > 0) {
            Map<String, String> mapCluster = new Map<String, String>();
            List<String> listCluster = clusters.split(',');
            for(gii__PurchaseOrder__c poobj : lstPO) {
                DisplayPO porec = new DisplayPO();
                String supplier = poobj.gii__SupplierName__c;
                String wh = poobj.gii__ShipTo__r.Name;
                String pricebook = poobj.gii__PriceBookName__c;          
                String keyCluster = '';
                String cig = poobj.giic_CIG__c;
                String cup = poobj.giic_CUP__c;
                if(listCluster.contains('All')) {
                    keyCluster = wh+pricebook+supplier+cig+cup;
                } else if(listCluster.contains('wh') && listCluster.contains('supplier')) {
                    keyCluster = wh+supplier;
                } else if(listCluster.contains('wh') && listCluster.contains('pricebook')) {
                    keyCluster = wh+pricebook;
                } else if(listCluster.contains('pricebook') && listCluster.contains('supplier')) {
                    keyCluster = pricebook+supplier;
                } else if(listCluster.contains('pricebook')) {
                    keyCluster = pricebook;
                } else if(listCluster.contains('wh')) {
                    keyCluster = wh;
                } else if(listCluster.contains('supplier')) {
                    keyCluster = supplier;
                }

                if(!mapCluster.containsKey(keyCluster)) {
                    String codeCluster = String.valueOf(Integer.valueOf((Math.random() * 10000)));
                    while(mapCluster.values().contains(codeCluster)) {
                        codeCluster = String.valueOf(Integer.valueOf((Math.random() * 10000)));
                    }    
                    mapCluster.put(keyCluster, codeCluster);
                    mapCodeRows.put(codeCluster, 1);
                } else {
                    Integer oldValue = mapCodeRows.get(mapCluster.get(keyCluster));
                    mapCodeRows.put(mapCluster.get(keyCluster), oldValue+1);
                }
                porec.codeCluster = mapCluster.get(keyCluster);
                porec.key = poobj.gii__Supplier__c+'-'+poobj.gii__ShipTo__c+'-'+poobj.gii__PriceBookName__c;
                porec.poName = poobj.Name;
                porec.supplier = poobj.gii__SupplierName__c;
                porec.warehouse = poobj.gii__ShipTo__r.Name;
                porec.orderStatus = poobj.giic_Status__c;
                porec.orderDate = poobj.gii__OrderDate__c;
                porec.priceBook = poobj.gii__PriceBookName__c;
                porec.contract=poobj.giic_Contract__c; 
                porec.cig =poobj.giic_CIG__c;
                porec.cup =poobj.giic_CUP__c;
                porec.cwrapperpo = poobj;
                lstPORecords.add(porec);
            }

            // Order by cluster:
            for(Integer i=0; i<lstPORecords.size()-1; i++) {
                for(Integer k=i+1; k<lstPORecords.size(); k++) {
                    if(lstPORecords[i].codeCluster > lstPORecords[k].codeCluster) {
                        DisplayPO temp = lstPORecords[i];
                        lstPORecords[i] = lstPORecords[k];
                        lstPORecords[k] = temp;
                    }
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result: ' + lstPORecords);
        mapResult.put('lstPORecords', lstPORecords);
        mapResult.put('mapCodeRows', mapCodeRows);
        return mapResult;
    }

    /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @description To Merge Purchase Order  and Purchase Order Line.
    * @param mergeRecords String 
    * @return Id
    */ 
    @AuraEnabled
    public static XC_UTIL_ResultWrapper mergePOData(String mergeRecords){ 
    	XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'mergeRecords'+mergeRecords);
		Giic_PurchaseOrderMergeController.ParamsWrapper params= new Giic_PurchaseOrderMergeController.ParamsWrapper();
        params.lstPORecords = (List<DisplayPO>) System.JSON.deserialize(mergeRecords,List<DisplayPO>.class);

        for(DisplayPO objPositionRecords: params.lstPORecords) {                
            gii__PurchaseOrder__c record=objPositionRecords.cwrapperpo;
            params.pBForPO.add(record.gii__PriceBookName__c);
        }
        if(Schema.sObjectType.gii__PriceBook__c.isQueryable()){
            for(gii__PriceBook__c objPB:[SELECT id,Name,giic_Contract__c From gii__PriceBook__c WHERE Name IN:params.pBForPO]){
                params.mapforPB.put(objPB.Name,objPB.giic_Contract__c);
                params.mapNameToPB.put(objPB.Name, objPB);
            }
        }
        Boolean canMerge = sameGigAndCup(params.lstPORecords);
        if(!canMerge){
            rw.success = false;
            rw.resultMessage = 'CUP and CIG must be the same!';
            return rw;
        }
        params=mergePODataFor(params);

        if(params.insMap.size()>0 && params.insMap.size()<2){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.insMap'+params.insMap);
            for(gii__PurchaseOrder__c objPO : params.insMap.values()){
                objPO.giic_WarehouseLimitExceeded__c= params.mapTocheckWL.containsKey(objPO.gii__Supplier__c+'-'+objPO.gii__ShipTo__c+'-'+objPO.gii__PriceBookName__c)? params.mapTocheckWL.get(objPO.gii__Supplier__c+'-'+objPO.gii__ShipTo__c+'-'+objPO.gii__PriceBookName__c) :false;  
                params.insMap.put(objPO.gii__Supplier__c+'-'+objPO.gii__ShipTo__c+'-'+objPO.gii__PriceBookName__c,objPO);
            }
            Map<String, String> mapResult = mergePODataSaveResult(params);
            params.recordId = (Id) mapResult.get('recordId');
            if(mapResult.get('success') == 'false') {
                rw.resultMessage = mapResult.containsKey('errorMessage') ? mapResult.get('errorMessage') : 'Error to save operation';
            } else if(mapResult.containsKey('recordId') && String.isNotBlank(mapResult.get('recordId'))) {
                rw.success = true;
                rw.recordId = mapResult.get('recordId');
            } else {
                rw.success = false;
                rw.resultMessage = 'Internal error';
            }
        } else {
            String m = System.Label.giic_ErrorforPOMerge;
            AuraHandledException e = new AuraHandledException(m);
            e.setMessage(m);
            throw e; 
        }     
        return rw;
    }
    
    /**
    * @description Metod to check for cig and cup
    * @param poList - List<DisplayPO> 
    * @return Boolean
    */ 
    public static Boolean sameGigAndCup(List<DisplayPO> poList){
        System.debug('Enter in sameGigAndCup con '+poList);
        String initialCup = poList[0].cup;
        String initialCig = poList[0].cig;
        for(DisplayPO po : poList){
            if(po.cup!=initialCup){
                return false;
            }
            if(po.cig!=initialCig){
                return false;
            }
        }
        return true;
    }
    
    /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @description To Merge Purchase Order  and Purchase Order Line.
    * @param params Giic_PurchaseOrderMergeController.ParamsWrapper  
    * @return  Giic_PurchaseOrderMergeController.ParamsWrapper
    */ 
    public static Giic_PurchaseOrderMergeController.ParamsWrapper mergePODataFor(Giic_PurchaseOrderMergeController.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In mergePODataFor');
        for(DisplayPO objPositionRecords: params.lstPORecords){                
            gii__PurchaseOrder__c record=objPositionRecords.cwrapperpo;
            if(!params.insMap.containsKey(record.gii__Supplier__c+'-'+record.gii__ShipTo__c+'-'+record.gii__PriceBookName__c)){
                gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c();
                objPO.gii__Supplier__c      = record.gii__Supplier__c; 
                objPO.gii__ShipTo__c        = record.gii__ShipTo__c;
                objPO.giic_Status__c =  System.Label.giic_StatusOpen;
                objPO.giic_Contract__c=params.mapforPB.get(record.gii__PriceBookName__c);
                objPO.gii__Approved__c	 =false;
                objPO.giic_CUP__c = record.giic_CUP__c;
                objPO.giic_CIG__c = record.giic_CIG__c;
                objPO.giic_IsMergedPO__c=true;
                objPO.giic_PriceBookId__c = params.mapNameToPB.get(record.gii__PriceBookName__c).Id;
                objPO.gii__PriceBookName__c=record.gii__PriceBookName__c;
                objPO.giic_Source__c=System.Label.giic_sourceManual;
                if(record.giic_WarehouseLimitExceeded__c== true){
                    //WarehouseLimitExceed
                    params.mapTocheckWL.put(record.gii__Supplier__c+'-'+record.gii__ShipTo__c+'-'+record.gii__PriceBookName__c,true);
                }
                params.insMap.put(record.gii__Supplier__c+'-'+record.gii__ShipTo__c+'-'+record.gii__PriceBookName__c,objPO);                   
            }
            params.setPOIDs.add(record.id);
        } 
        return params;
    }

    /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @date Mod 08/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description To Merge Purchase Order  and Purchase Order Line.
    * @param params Giic_PurchaseOrderMergeController.ParamsWrapper  
    * @return Map<String, String>
    */  
    public static Map<String, String> mergePODataSaveResult(Giic_PurchaseOrderMergeController.ParamsWrapper params) {
        Map<String, String> mapResult = new Map<String, String>();
        DataBase.SaveResult[] result = Database.Insert(params.insMap.values(), false);        
        for(Database.SaveResult sr:result) {
            if(sr.isSuccess()){                            
                params.setNewPOIDs.add(sr.getId());
                params.recordId=sr.getId();
                mapResult.put('success', 'true');
            } else{ 
                Database.Error err = sr.getErrors()[0]; 
                mapResult.put('errorMessage', sr.getErrors()[0].getMessage());
                mapResult.put('success', 'false');
            }
        }
        if(params.setNewPOIDs.size() > 0){
            mergePODataHelper(params);            
        }
        mapResult.put('recordId', params.recordId);
        return mapResult;
    }

   /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @description To Merge Purchase Order  and Purchase Order Line.
    * @param params Giic_PurchaseOrderMergeController.ParamsWrapper 
    */   
    public static void mergePODataHelper(Giic_PurchaseOrderMergeController.ParamsWrapper params) {
        Map<Id,gii__PurchaseOrder__c> mapWHGIdsandWH=new Map<Id,gii__PurchaseOrder__c>([
             SELECT  Id,Name,gii__Supplier__c,gii__SupplierName__c,gii__PriceBookName__c, gii__TotalOrderQuantity__c,gii__Buyer__c,gii__ShipTo__c,gii__ShipToName__c 
             FROM gii__PurchaseOrder__c 
             WHERE Id IN:params.setNewPOIDs
         ]); 
         List<gii__PurchaseOrder__c> lstPOtoUPdate = new List<gii__PurchaseOrder__c>();              
         for(DisplayPO objPositionRecords: params.lstPORecords){                
             gii__PurchaseOrder__c objPO = objPositionRecords.cwrapperpo;                      
             objPO.giic_MergedPurchaseOrder__c = mapWHGIdsandWH.get(params.insMap.get(objPO.gii__Supplier__c+'-'+objPO.gii__ShipTo__c+'-'+objPO.gii__PriceBookName__c).Id).Id;
              XC_UTIL_Debug.debug(DEBUGACTIVE,'objPO.giic_Status__c = '+objPO.giic_Status__c );
             objPO.giic_Status__c = System.Label.giic_StatusMerged;
             params.lstPOtoUPdate.add(objPO);                    
         }
         /*if(Schema.sObjectType.gii__PurchaseOrderLine__c.isQueryable()){
             for(AggregateResult poLineObj:[SELECT gii__PurchaseOrder__r.gii__Supplier__c supplier,gii__PurchaseOrder__r.gii__ShipTo__c shipto, gii__PurchaseOrder__r.gii__PriceBookName__c PBname ,gii__Product__c, 
                                           sum(gii__OrderQuantity__c) sum  
                                           from gii__PurchaseOrderLine__c where gii__PurchaseOrder__c  IN :params.setPOIDs 
                              group by gii__Product__c,gii__PurchaseOrder__r.gii__Supplier__c,gii__PurchaseOrder__r.gii__ShipTo__c,gii__PurchaseOrder__r.gii__PriceBookName__c]){
                 gii__PurchaseOrderLine__c updlistPOLine = new gii__PurchaseOrderLine__c();
                 //updlistPOLine.gii__PurchaseOrder__c =(Id)poLineObj.get('mergedpo')	;
                 updlistPOLine.gii__PurchaseOrder__c=params.insMap.get((Id)poLineObj.get('supplier')+'-'+(Id)poLineObj.get('shipto')+'-'+(String)poLineObj.get('PBname')).Id;
                 updlistPOLine.gii__Product__c = (Id)poLineObj.get('gii__Product__c');
                 updlistPOLine.gii__OrderQuantity__c = (Decimal)poLineObj.get('sum');
                 params.updlst.add(updlistPOLine);  
             }
         }*/
         // MERGE POL WITH UNDER WARRANTY
         List<gii__PurchaseOrderLine__c> polLine = new List<gii__PurchaseOrderLine__c>([
             SELECT gii__PurchaseOrder__r.gii__Supplier__c ,gii__PurchaseOrder__r.gii__ShipTo__c , gii__PurchaseOrder__r.gii__PriceBookName__c  ,gii__PurchaseOrder__r.giic_PriceBookId__c,gii__Product__c, 
             gii__Product__r.gii__PrimarySupplier__c,gii__OrderQuantity__c  , giic_UnderWarranty__c,giic_ProductSerial__c, gii__Product__r.gii__SerialControlled__c, gii__Product_Discount_Percent__c, giic_OldOrderQuantity__c //NR1353
             FROM gii__PurchaseOrderLine__c 
             WHERE gii__PurchaseOrder__c  IN :params.setPOIDs 
         ]);
         Map<String, Decimal> mapProductQuantity = new  Map<String, Decimal> ();
         Map<String,gii__PurchaseOrderLine__c > polToCreate = new Map<String,gii__PurchaseOrderLine__c >();
         //[NR1106]
         Set<Id> setProductIds=new set<Id>();
         Set<Id> setSupplierIds=new set<Id>();
         for(gii__PurchaseOrderLine__c poLineObj:  polLine ){
             setProductIds.add(poLineObj.gii__Product__c);
             //setSupplierIds.add(poLineObj.gii__Product__r.gii__PrimarySupplier__c);
             setSupplierIds.add(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c);
             //[NR1106]
             String keyProduct = params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id + '-' + poLineObj.gii__Product__c ;
             gii__PurchaseOrderLine__c updlistPOLine = new gii__PurchaseOrderLine__c();  
             if(poLineObj.giic_UnderWarranty__c){
                 keyProduct = keyProduct + 'true';
                 if(poLineObj.gii__Product__r.gii__SerialControlled__c){
                     updlistPOLine.gii__PurchaseOrder__c=params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id;
                     updlistPOLine.gii__Product__c = poLineObj.gii__Product__c;
                     updlistPOLine.giic_UnderWarranty__c = true;
                     updlistPOLine.gii__OrderQuantity__c = poLineObj.gii__OrderQuantity__c;
                     updlistPOLine.giic_ProductSerial__c = poLineObj.giic_ProductSerial__c;
                     polToCreate.put(keyProduct, updlistPOLine);
                 }else{
                     if(!mapProductQuantity.containsKey(keyProduct)){
                         updlistPOLine.gii__PurchaseOrder__c=params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id;
                         updlistPOLine.gii__Product__c = poLineObj.gii__Product__c;
                         updlistPOLine.giic_UnderWarranty__c = true;
                         //NR1353
                         if(poLineObj.giic_OldOrderQuantity__c != 0 && poLineObj.giic_OldOrderQuantity__c != null){
                             updlistPOLine.gii__OrderQuantity__c = poLineObj.giic_OldOrderQuantity__c;
                         }
                         else{
                             updlistPOLine.gii__OrderQuantity__c = poLineObj.gii__OrderQuantity__c;
                         }
                         polToCreate.put(keyProduct, updlistPOLine);
                         //mapProductQuantity.put(keyProduct, poLineObj.gii__OrderQuantity__c );
                         mapProductQuantity.put(keyProduct, updlistPOLine.gii__OrderQuantity__c);
                         //NR1353
                     }else{
                         polToCreate.remove(keyProduct); 
                         updlistPOLine.gii__PurchaseOrder__c=params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id;
                         updlistPOLine.gii__Product__c =  poLineObj.gii__Product__c;
                         updlistPOLine.giic_UnderWarranty__c = true;
                         //NR1353
                         if(poLineObj.giic_OldOrderQuantity__c != 0 && poLineObj.giic_OldOrderQuantity__c != null){
                             updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.giic_OldOrderQuantity__c;
                         }
                         else{
                             updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.gii__OrderQuantity__c;
                         }
                         //updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.gii__OrderQuantity__c;
                         mapProductQuantity.remove(keyProduct);
                         polToCreate.put(keyProduct, updlistPOLine);
                         mapProductQuantity.put(keyProduct, updlistPOLine.gii__OrderQuantity__c );
                         //NR1353
                     } 
                 }
             }else{
                 if(poLineObj.gii__Product_Discount_Percent__c != null && poLineObj.gii__Product_Discount_Percent__c > 0){
                     XC_UTIL_Debug.debug(DEBUGACTIVE,'########## poLineObj.gii__Product_Discount_Percent__c' + poLineObj.gii__Product_Discount_Percent__c);
                     keyProduct = keyProduct + String.valueOf(poLineObj.gii__Product_Discount_Percent__c);
                     if(!mapProductQuantity.containsKey(keyProduct)){
                         updlistPOLine.gii__PurchaseOrder__c=params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id;
                         updlistPOLine.gii__Product__c =  poLineObj.gii__Product__c;
                         //updlistPOLine.gii__OrderQuantity__c = poLineObj.gii__OrderQuantity__c;
                         updlistPOLine.gii__Product_Discount_Percent__c = poLineObj.gii__Product_Discount_Percent__c;
                         //NR1353
                         if(poLineObj.giic_OldOrderQuantity__c != 0 && poLineObj.giic_OldOrderQuantity__c != null){
                             updlistPOLine.gii__OrderQuantity__c = poLineObj.giic_OldOrderQuantity__c;
                         }
                         else{
                             updlistPOLine.gii__OrderQuantity__c = poLineObj.gii__OrderQuantity__c;
                         }
                         polToCreate.put(keyProduct, updlistPOLine); 
                         //mapProductQuantity.put(keyProduct, poLineObj.gii__OrderQuantity__c );
                         mapProductQuantity.put(keyProduct, updlistPOLine.gii__OrderQuantity__c);
                         //NR1353
                     }else{
                         polToCreate.remove(keyProduct); 
                         updlistPOLine.gii__PurchaseOrder__c=params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id;
                         updlistPOLine.gii__Product__c =  poLineObj.gii__Product__c;
                         //updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.gii__OrderQuantity__c;
                         updlistPOLine.gii__Product_Discount_Percent__c = poLineObj.gii__Product_Discount_Percent__c;
                         //NR1353
                         if(poLineObj.giic_OldOrderQuantity__c != 0 && poLineObj.giic_OldOrderQuantity__c != null){
                             updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.giic_OldOrderQuantity__c;
                         }
                         else{
                             updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.gii__OrderQuantity__c;
                         }
                         mapProductQuantity.remove(keyProduct);
                         polToCreate.put(keyProduct, updlistPOLine);
                         //mapProductQuantity.put(keyProduct, poLineObj.gii__OrderQuantity__c );
                         mapProductQuantity.put(keyProduct, updlistPOLine.gii__OrderQuantity__c);
                         //NR1353
                     } 
                 }else{
                     if(!mapProductQuantity.containsKey(keyProduct)){
                         updlistPOLine.gii__PurchaseOrder__c=params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id;
                         updlistPOLine.gii__Product__c =  poLineObj.gii__Product__c;
                         //updlistPOLine.gii__OrderQuantity__c = poLineObj.gii__OrderQuantity__c;
                         //NR1353
                         if(poLineObj.giic_OldOrderQuantity__c != 0 && poLineObj.giic_OldOrderQuantity__c != null){
                             updlistPOLine.gii__OrderQuantity__c = /*mapProductQuantity.get(keyProduct)*/ +  poLineObj.giic_OldOrderQuantity__c;
                         }
                         else{
                             updlistPOLine.gii__OrderQuantity__c = /*mapProductQuantity.get(keyProduct)*/ +  poLineObj.gii__OrderQuantity__c;
                         }
                         polToCreate.put(keyProduct, updlistPOLine); 
                         //mapProductQuantity.put(keyProduct, poLineObj.gii__OrderQuantity__c );
                         mapProductQuantity.put(keyProduct, updlistPOLine.gii__OrderQuantity__c);
                         //NR1353
                     }else{
                         polToCreate.remove(keyProduct); 
                         updlistPOLine.gii__PurchaseOrder__c=params.insMap.get(poLineObj.gii__PurchaseOrder__r.gii__Supplier__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__ShipTo__c+'-'+poLineObj.gii__PurchaseOrder__r.gii__PriceBookName__c).Id;
                         updlistPOLine.gii__Product__c =  poLineObj.gii__Product__c;
                         //updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.gii__OrderQuantity__c;
                         //NR1353
                         if(poLineObj.giic_OldOrderQuantity__c != 0 && poLineObj.giic_OldOrderQuantity__c != null){
                             updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.giic_OldOrderQuantity__c;
                         }
                         else{
                             updlistPOLine.gii__OrderQuantity__c = mapProductQuantity.get(keyProduct) +  poLineObj.gii__OrderQuantity__c;
                         }
                         mapProductQuantity.remove(keyProduct);
                         polToCreate.put(keyProduct, updlistPOLine);
                         //mapProductQuantity.put(keyProduct, poLineObj.gii__OrderQuantity__c );
                         mapProductQuantity.put(keyProduct, updlistPOLine.gii__OrderQuantity__c);
                         //NR1353
                         
                     }
                 }
             }
         }
         //[NR1106]
         List<gii__PriceBookEntry__c> lstPBE = New List<gii__PriceBookEntry__c>([
             SELECT id, gii__Product__c, giic_MinimumOrderQuantity__c, gii__Product__r.gii__PrimarySupplier__c, giic_Default__c 
             FROM gii__PriceBookEntry__c
             WHERE gii__Product__c IN: setProductIds
             AND gii__PriceBook__r.giic_Contract__r.AccountId <> null
             AND gii__PriceBook__r.giic_Contract__r.AccountId IN: setSupplierIds
             /*AND giic_MinimumOrderQuantity__c != null*/
             /*AND giic_Default__c = true*/
         ]);
 
         for(gii__PurchaseOrderLine__c pol : polToCreate.values()) {
             List<gii__PriceBookEntry__c> listPbeDef = New List<gii__PriceBookEntry__c>();
             List<gii__PriceBookEntry__c> listPbe = New List<gii__PriceBookEntry__c>();
             for(gii__PriceBookEntry__c pbe : lstPBE ){
                 if (pol.gii__Product__c == pbe.gii__Product__c) { 
                     if(pbe.giic_Default__c){
                         listPbeDef.add(pbe);
                     }
                     else{
                         listPbe.add(pbe);
                     }
                 }
             }            
             
             String key = pol.gii__Product__c;
             Decimal QtyNew = pol.gii__OrderQuantity__c;
             if(listPbeDef.size() > 0) {
                 for(gii__PriceBookEntry__c pbe : listPbeDef ){
                     if(pbe.gii__Product__c == pol.gii__Product__c && pbe.giic_MinimumOrderQuantity__c!= null && pbe.giic_MinimumOrderQuantity__c !=0){
                         if(QtyNew <= pbe.giic_MinimumOrderQuantity__c) {
                             QtyNew = pbe.giic_MinimumOrderQuantity__c;
                         }
                         else {
                             Integer Div = integer.ValueOf(QtyNew/pbe.giic_MinimumOrderQuantity__c);
                             system.debug('div: '+ div);
                             Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(pbe.giic_MinimumOrderQuantity__c));
                             system.debug('remainder: '+ remainder);
                             if (remainder == 0) {QtyNew = Div*pbe.giic_MinimumOrderQuantity__c;}
                             else {QtyNew = (Div + 1)*pbe.giic_MinimumOrderQuantity__c;}
                         }
                         pol.gii__OrderQuantity__c = QtyNew ;
                     }
                 }
             }
             else {
                 if(listPbe.size() > 0) {
                     decimal qty = 0;
                     for(gii__PriceBookEntry__c pbe : listPbe){
                         if(pbe.gii__Product__c == pol.gii__Product__c && pbe.giic_MinimumOrderQuantity__c!= null && pbe.giic_MinimumOrderQuantity__c !=0){
                             if(pbe.giic_MinimumOrderQuantity__c > qty){
                                 qty = pbe.giic_MinimumOrderQuantity__c;
                                 if(QtyNew <= qty){QtyNew = qty;}
                                 else{
                                     Integer Div = integer.ValueOf(QtyNew/qty);
                                     system.debug('div: '+ div);
                                     Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(qty));
                                     system.debug('remainder: '+ remainder);
                                     if (remainder == 0) {QtyNew = Div*qty;}
                                     else {QtyNew = (Div + 1)*qty;}
                                 }
                             }
                         }
                     }
                     pol.gii__OrderQuantity__c = QtyNew ;
                 }
             }
             //[NR1106]
             params.updlst.add(pol);
         }
         
         if(Schema.sObjectType.gii__PurchaseOrderLine__c.isQueryable()){
             params.lstPOLToUpdate = [
                 SELECT Id,gii__CancelDate__c,gii__CancelledQuantity__c,gii__CancelReason__c,gii__PurchaseOrder__r.gii__Supplier__c,gii__PurchaseOrder__r.gii__ShipTo__c,gii__PurchaseOrder__r.gii__PriceBookName__c,gii__Product__c,gii__OrderQuantity__c
                 FROM gii__PurchaseOrderLine__c 
                 WHERE gii__PurchaseOrder__c  IN :params.setPOIDs
             ];
             for(gii__PurchaseOrderLine__c poLineObj:params.lstPOLToUpdate){
                 poLineObj.gii__CancelDate__c=system.today();
                 poLineObj.gii__CancelledQuantity__c=poLineObj.gii__OrderQuantity__c;
                 poLineObj.gii__CancelReason__c=Label.giic_StatusMerged;
             }
         }
         mergePODatasecondHelper(params);
     }

    /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @description To Merge Purchase Order  and Purchase Order Line.
    * @param params Giic_PurchaseOrderMergeController.ParamsWrapper 
    */ 
    public static void mergePODatasecondHelper(Giic_PurchaseOrderMergeController.ParamsWrapper params){
        List<String> lstNewPOLineIDs = new List<String>();
        if(params.lstPOtoUPdate.size()>0 && Schema.sObjectType.gii__PurchaseOrder__c.isUpdateable()){
            for(gii__PurchaseOrder__c p : params.lstPOtoUPdate){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'parametro: '+p.giic_Status__c);
            }
            update params.lstPOtoUPdate;
        }
        if(params.lstPOLToUpdate.size()>0 && Schema.sObjectType.gii__PurchaseOrderLine__c.isUpdateable()){
            Database.update(params.lstPOLToUpdate,false); 
        }
        if(params.updlst.size()>0){  
            DataBase.SaveResult[] resultlist = Database.Insert(params.updlst, false);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Po Lines Ins: '+ params.updlst);
            for(Database.SaveResult sr:resultlist) {
                if(sr.isSuccess()) {                            
                    lstNewPOLineIDs.add(sr.getId()); 
                }
                else {
                    Database.Error err = sr.getErrors()[0];
                    AuraHandledException e = new AuraHandledException(err.getMessage());
                    e.setMessage(err.getMessage());
                    throw e;  
                }   
            }  
        }
    }

   /**
    * @author Pradeep Kumar - Pradeep.P.Kumar@in.fujitsu.com
    * @date 20/07/2019
    * @description getListViews
    * @return List<ListView> 
    */ 
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'gii__PurchaseOrder__c'];
        return listviews;
    }
    
}
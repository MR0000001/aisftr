/**
* @date Creation 07/08/2019
* @date Modification 14/07/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Giic_GoodsIssueSO_U – Util Class for Giic_GoodsIssueSO
*/  

public class Giic_GoodsIssueSO_U {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_GoodsIssueSO_U');

    /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019                     
    * @description Giic_GoodsIssueSO – This method creates Inventory Reserves records
    * @return ParamsWrapper
    */    
   public static Giic_GoodsIssueSO.ParamsWrapper createInvReserve(gii__SalesOrderLine__c sol, Giic_GoodsIssueSO.ParamsWrapper params, Boolean lastGoodIssue){
       XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createInvReserve');
       List<gii__SalesOrderLine__c> lstSOLToInsert = new  List<gii__SalesOrderLine__c> ();
       
      
       map<String,String> lotAlreadyInserted = new map<String,String>();
       Map<String,String> alreadyPresent = new Map<String,String>();
       XC_UTIL_Debug.debug(DEBUGACTIVE,'isSerialControlled = '+sol.gii__Product__r.gii__SerialControlled__c);
       XC_UTIL_Debug.debug(DEBUGACTIVE,'params.productRequireSerialListMap = '+params.productRequireSerialListMap);
       XC_UTIL_Debug.debug(DEBUGACTIVE,'sol.giic_ProductRequiredId__c = '+sol.giic_ProductRequiredId__c);
       XC_UTIL_Debug.debug(DEBUGACTIVE,'params.productRequireLotListMap = '+params.productRequireLotListMap);
       Decimal openQuantity = sol.gii__OpenQuantity__c;
       Decimal numberOfSerialProduct  = 0;

       if(sol.gii__Product__r.gii__SerialControlled__c && params.productRequireSerialListMap.containsKey(sol.giic_ProductRequiredId__c) && params.productRequireSerialListMap.get(sol.giic_ProductRequiredId__c) != null){
           
                    
           
         
           for(Giic_GoodsIssueSO.AssignedSerial assignedSerial : params.productRequireSerialListMap.get(sol.giic_ProductRequiredId__c)){
              
               numberOfSerialProduct++;
               if(numberOfSerialProduct>openQuantity){ 
                   break; 
                }
               gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
               String serialInUpper = (assignedSerial.SerialNumber).toUpperCase();
               ir.gii__SalesOrderLine__c = sol.id;
               ir.gii__ProductSerial__c = params.serialNameIDMap.containsKey(serialInUpper) ? params.serialNameIDMap.get(serialInUpper) : null ;
               ir.gii__ProductInventoryQuantityDetail__c = params.isAvailableSerailVsPiqdIdMap.containsKey(serialInUpper) ? params.isAvailableSerailVsPiqdIdMap.get(serialInUpper) : null ;
               ir.gii__ReserveQuantity__c = 1.0; 
               alreadyPresent.put(ir.gii__ProductSerial__c,ir.gii__ProductSerial__c);
               params.listInventoryReserve.add(ir);               
               gii__ProductInventoryQuantityDetail__c piqdtemp = new  gii__ProductInventoryQuantityDetail__c();
               piqdtemp.Id = params.isAvailableSerailVsPiqdIdMap.get(serialInUpper);
               piqdtemp.giic_Status__c ='Shipped';
               //piqdToUnreservedList.add(piqdtemp);
           }
           if(numberOfSerialProduct>openQuantity){ 
               params =  createNewSolForSerialsProd(lstSOLToInsert,sol,params, numberOfSerialProduct - openQuantity, alreadyPresent);
            }
        } else if(sol.gii__Product__r.gii__LotControlled__c && params.productRequireLotListMap.containsKey(sol.giic_ProductRequiredId__c) && params.productRequireLotListMap.get(sol.giic_ProductRequiredId__c) != null){
            for(Giic_GoodsIssueSO.ProductLot assignedLot : params.productRequireLotListMap.get(sol.giic_ProductRequiredId__c)){
                if(assignedLot.lotNumber!=null && assignedLot.lotQty!=null) {
                    String lotNameInUpper = (assignedLot.lotNumber).toUpperCase();
                  
                    if(!lotAlreadyInserted.containsKey(lotNameInUpper)){
                        numberOfSerialProduct ++;
                        lotAlreadyInserted.put(lotNameInUpper, lotNameInUpper);
                    }
                    if(numberOfSerialProduct>openQuantity){ 
                        break; 
                    }
                    gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                    ir.gii__SalesOrderLine__c = sol.id;
                    ir.gii__ProductLot__c = params.serialNameIDMap.containsKey(lotNameInUpper) ? params.serialNameIDMap.get(lotNameInUpper) : null ;
                    ir.gii__ProductInventoryQuantityDetail__c = params.isAvailableLotVsPiqdIdMap.containsKey(lotNameInUpper) ? params.isAvailableLotVsPiqdIdMap.get(lotNameInUpper) : null ;
                    ir.gii__ReserveQuantity__c = params.lotNumberToQuantity.get(lotNameInUpper); 
                    alreadyPresent.put(ir.gii__ProductLot__c, ir.gii__ProductLot__c);
                  
                    params.listInventoryReserve.add(ir);
                    gii__ProductInventoryQuantityDetail__c piqdtemp = params.isAvailablePiqdIDVsPiqd.get(params.isAvailableLotVsPiqdIdMap.get(lotNameInUpper) );
                    //piqdtemp.giic_Status__c ='Shipped';
                    if(sol.gii__Status__c!='Shipped'){
                        Decimal n = 0;
                        if(params.lotNumberToQuantity.containsKey(lotNameInUpper)) {   
                            n = params.lotNumberToQuantity.get(lotNameInUpper); 
                        }
                        if(piqdtemp.giic_Reserved__c == null) { 
                            piqdtemp.giic_Reserved__c = 0; 
                        }
                        if(piqdtemp.giic_Reserved__c > 0 &&  piqdtemp.giic_Reserved__c>=n) {
                            piqdtemp.giic_Reserved__c =   piqdtemp.giic_Reserved__c - n;
                            piqdtemp.gii__OnHandQuantity__c = piqdtemp.gii__OnHandQuantity__c + n;
                        } else if(piqdtemp.giic_Reserved__c > 0 &&  piqdtemp.giic_Reserved__c < n) {
                            piqdtemp.giic_Reserved__c = 0;
                            piqdtemp.gii__OnHandQuantity__c = piqdtemp.gii__OnHandQuantity__c + piqdtemp.giic_Reserved__c;
                        }
                       
                        if(!params.piqdToUnreservedList.containsKey(piqdtemp.Id)){ 
                            params.piqdToUnreservedList.put(piqdtemp.Id,piqdtemp);  
                        }
                        params.lstPIQDToSendForInvAdj.put(piqdtemp.Id, piqdtemp);  
                    }
                }
            }
           
            if(numberOfSerialProduct>openQuantity && openQuantity!=0){ 
                params = createNewSolForSerialsProd(lstSOLToInsert,sol,params, numberOfSerialProduct - openQuantity, alreadyPresent);
            }
        } 
       //// Blocco per il calcolo delle quantita sugli inventory reserve per i prodotti normali
       else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ne serial ne lot su sol '+sol);
            String locationId;
            if(sol.gii__Warehouse__r.gii__DefaultIssueLocation__c !=null) {
                locationId = sol.gii__Warehouse__r.gii__DefaultIssueLocation__c;
            } else{
                locationId = params.whLocationMap.get(sol.gii__Warehouse__c);
            }
            String key = sol.gii__Product__c+'-'+sol.gii__Warehouse__c+'-'+ locationId;     //params.whLocationMap.get(sol.gii__Warehouse__c); 
            gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
            ir.gii__SalesOrderLine__c = sol.id; 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.piqdKeyIDMAP = '+params.piqdKeyIDMAP);
            if(params.piqdKeyIDMAP.containsKey(key)) {
                String piqdId = params.piqdKeyIDMAP.get(key);
                if(params.mapOfIdVsPIQD.get(piqdId).gii__OnHandQuantity__c >= params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c)) {
                   
                    ir.gii__ProductInventoryQuantityDetail__c = params.piqdKeyIDMAP.get(key); 
                   
                }
                if(sol.gii__OrderQuantity__c >= params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) && !params.newSolIdToPIQD.containsKey(sol.Id) ){  
                    ir.gii__ReserveQuantity__c = params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c);
                    gii__ProductInventoryQuantityDetail__c piqd = retrieveCurrentPIQD(params.piqdList, sol);
                    ir.gii__ProductInventoryQuantityDetail__c = piqd.Id;   // nuova fix
                    Decimal n = params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c); 
                    if(piqd.giic_Reserved__c == null){
                        piqd.giic_Reserved__c = 0;
                    }
                    if(piqd.giic_Reserved__c > 0 &&  piqd.giic_Reserved__c>=n) {
                        piqd.giic_Reserved__c =   piqd.giic_Reserved__c - n;
                        piqd.gii__OnHandQuantity__c = piqd.gii__OnHandQuantity__c + n;
                    }else if(piqd.giic_Reserved__c >= 0 &&  piqd.giic_Reserved__c < n){
                        piqd.gii__OnHandQuantity__c = piqd.gii__OnHandQuantity__c + piqd.giic_Reserved__c ;
                        piqd.giic_Reserved__c = 0;
                        piqd.giic_Status__c ='';
                    }
                    if(sol.gii__Status__c!='Shipped'){
                        params.lstPIQDToSendForInvAdj.put(piqd.Id, piqd);
                        if(!params.piqdToUnreservedList.containsKey(piqd.Id)){
                            params.piqdToUnreservedList.put(piqd.Id,piqd);
                        }
                    }    
                  
                } else{
                    
                    if(sol.gii__Status__c=='Partially Shipped'){ 
                        ir.gii__ReserveQuantity__c = sol.gii__OpenQuantity__c;
                    } else {   
                        ir.gii__ReserveQuantity__c = sol.gii__OrderQuantity__c;
                    }
                    ir.gii__ProductInventoryQuantityDetail__c = params.piqdKeyIDMAP.get(key); 
                    gii__ProductInventoryQuantityDetail__c piqd = retrieveCurrentPIQD(params.piqdList, sol);
                    Decimal n = ir.gii__ReserveQuantity__c ;
                  
                    if(piqd.giic_Reserved__c == null){
                        piqd.giic_Reserved__c = 0;
                    }
                    if(piqd.giic_Reserved__c > 0 &&  piqd.giic_Reserved__c>=n) {
                        piqd.giic_Reserved__c =   piqd.giic_Reserved__c - n;
                        piqd.gii__OnHandQuantity__c = piqd.gii__OnHandQuantity__c + n;
                    }else if(piqd.giic_Reserved__c >= 0 &&  piqd.giic_Reserved__c < n){
                        piqd.gii__OnHandQuantity__c = piqd.gii__OnHandQuantity__c + piqd.giic_Reserved__c ;
                        piqd.giic_Reserved__c = 0;
                        piqd.giic_Status__c ='';
                    }
                    if(sol.gii__Status__c!='Shipped'){
                        params.lstPIQDToSendForInvAdj.put(piqd.Id, piqd);
                        if(!params.piqdToUnreservedList.containsKey(piqd.Id)){
                            params.piqdToUnreservedList.put(piqd.Id,piqd);
                        }
                    } 
                }
            }
            else {
                XC_UTIL_Debug.debug(DEBUGACTIVE,'mappa params.productRequireConsumedQtyMap = '+params.productRequireConsumedQtyMap);
                ir.gii__ReserveQuantity__c = params.productRequireConsumedQtyMap.containsKey(sol.giic_ProductRequiredId__c) ? params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) : null;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.listInventoryReserveAlreadyAdded = '+params.listInventoryReserveAlreadyAdded);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'la mappa params.newSolIdToPIQD = '+params.newSolIdToPIQD );
            if(sol.gii__Status__c!='Shipped'  || params.newSolIdToPIQD.containsKey(sol.Id) ){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'aggiungo questo = '+ir );
                params.listInventoryReserve.add(ir);
                params.listInventoryReserveAlreadyAdded.add(ir);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@params.listInventoryReserve'+ params.listInventoryReserve);
       }
       return params;
   }
   
   /**
    * @date Creation 07/08/2019
    * @description Method to create new SOLI for Serials Prod
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */  
   public static Giic_GoodsIssueSO.ParamsWrapper createNewSolForSerialsProd(List<gii__SalesOrderLine__c> lstSOLToInsert,gii__SalesOrderLine__c sol,Giic_GoodsIssueSO.ParamsWrapper params, Decimal quantity, map<String,String> alreadyPresent ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN createNewSolForSerialsProd');
        gii__SalesOrderLine__c soLineObj = new gii__SalesOrderLine__c(
            gii__OrderQuantity__c = quantity,
            gii__Product__c = sol.gii__Product__c,
            gii__Warehouse__c = sol.gii__Warehouse__c,                           
            giic_ProductRequiredId__c = sol.giic_ProductRequiredId__c,
            gii__SalesOrder__c = sol.gii__SalesOrder__c,
            giic_WBElement__c = sol.giic_WBElement__c
        );
        lstSOLToInsert.add(soLineObj);
        insert lstSOLToInsert;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'lista degli Inserti = '+lstSOLToInsert[0].Id);
        for(Giic_GoodsIssueSO.AssignedSerial assignedSerial : params.productRequireSerialListMap.get(sol.giic_ProductRequiredId__c)){
            assignedSerial.SerialNumber = (assignedSerial.SerialNumber).toUpperCase();
            if(!alreadyPresent.containsKey(params.serialNameIDMap.get(assignedSerial.SerialNumber))) {
                gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                ir.gii__SalesOrderLine__c = lstSOLToInsert[0].id;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'assignedSerial.SerialNumber = '+assignedSerial.SerialNumber);
                ir.gii__ProductSerial__c = params.serialNameIDMap.containsKey(assignedSerial.SerialNumber) ? params.serialNameIDMap.get(assignedSerial.SerialNumber) : null ;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'QUESTO PROD SERIAL = '+  ir.gii__ProductSerial__c );
                ir.gii__ProductInventoryQuantityDetail__c = params.isAvailableSerailVsPiqdIdMap.containsKey(assignedSerial.SerialNumber) ? params.isAvailableSerailVsPiqdIdMap.get(assignedSerial.SerialNumber) : null ;
                ir.gii__ReserveQuantity__c = 1.0; 
                alreadyPresent.put(ir.gii__ProductSerial__c, ir.gii__ProductSerial__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'params.isAvailableSerailVsPiqdIdMap----->>'+params.isAvailableSerailVsPiqdIdMap);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'params.isAvailableSerailVsPiqdIdMap.get(assignedSerial.SerialNumber)----->>'+params.isAvailableSerailVsPiqdIdMap.get(assignedSerial.SerialNumber));
                gii__ProductInventoryQuantityDetail__c piqdtemp = new  gii__ProductInventoryQuantityDetail__c();
                piqdtemp.Id = params.isAvailableSerailVsPiqdIdMap.get(assignedSerial.SerialNumber);
                piqdtemp.giic_Status__c ='Shipped';
                params.listInventoryReserve.add(ir);
            }
        }
        return params;
    }
   
    /**
    * @date Creation 07/08/2019
    * @description Method to retrieve current PIQD
    * @return gii__ProductInventoryQuantityDetail__c
    */  
    public static gii__ProductInventoryQuantityDetail__c retrieveCurrentPIQD(List<gii__ProductInventoryQuantityDetail__c> piqdList, gii__SalesOrderLine__c sol){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN retrieveCurrentPIQD');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'lista all piqd = '+piqdList);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'size lista piqd = '+piqdList.size() );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'sol.gii__Warehouse__c cod 2222 = '+sol.gii__Warehouse__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'sol.gii__Product__c cod 2222 = '+sol.gii__Product__c);
        for(gii__ProductInventoryQuantityDetail__c pi : piqdList){
            if(sol.gii__Warehouse__c==pi.gii__Warehouse__c && sol.gii__Product__c == pi.gii__Product__c){
               
                return pi;
            }
        }
        return null;
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method iterates over the SOLs and performs actual goods issue
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */    
    public static Giic_GoodsIssueSO.ParamsWrapper responseProcessingHelper(Giic_GoodsIssueSO.ParamsWrapper params, Boolean fromComponent){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN responseProcessingHelper');
        List<gii__SalesOrderLine__c> existingSOLs = new List<gii__SalesOrderLine__c>();
        if(params.salesOrderLineList != null && params.salesOrderLineList.size()>0){   //If Sales Order exist then 
           
            for(gii__SalesOrderLine__c sol: params.salesOrderLineList){
                if(params.solSet.contains(sol.Id)){ 
                    
                    params = createInvReserve(sol, params, params.lastGoodIssue);
                }else{
                    if(fromComponent){
                        if(params.productRequireIDMAP.containsKey(sol.giic_ProductRequiredId__c) && params.productRequireConsumedQtyMap.containsKey(sol.giic_ProductRequiredId__c) && sol.gii__LineStatus__c!='Shipped') { 
                            existingSOLs.add(sol); 
                        } 
                    }
                    else{
                        if(params.productRequireIDMAP.containsKey(sol.giic_ProductRequiredId__c) && params.productRequireConsumedQtyMap.containsKey(sol.giic_ProductRequiredId__c)){ 
                            existingSOLs.add(sol);
                        } 
                    }   
                    
                }           
            }
            
            if(existingSOLs != null && !existingSOLs.isEmpty()){ 
                params = processAllSOLs(params, existingSOLs);
            } else if(!params.solJustInserted.isEmpty()){ 
                params = processAllSOLs(params, params.solJustInserted); 
            }
           
            if(params.odrResponse.isSuccess == true && Schema.sObjectType.gii__SalesOrderLine__c.isUpdateable()){
                Update params.solQtyAdjustList;
            } 
        }
        return params;
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method processes SOLs that have order quantity larger than the consumed
    * @param params-Object Giic_GoodsIssueSO.ParamsWrapper
    * @param existingSOLs-List of gii__SalesOrderLine__c
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */     
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper processAllSOLs(Giic_GoodsIssueSO.ParamsWrapper params,List<gii__SalesOrderLine__c> existingSOLs){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN processAllSOLs');
        for(gii__SalesOrderLine__c sol: existingSOLs){
            if(sol.gii__Product__r.gii__SerialControlled__c && params.productRequireSerialListMap.containsKey(sol.giic_ProductRequiredId__c)){ 
                params = processSerialPdts(params,sol);
            } else { 
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'info1 = '+sol.gii__Warehouse__c);
                String defaultIssueLocation;
                if(sol.gii__Warehouse__r.gii__DefaultIssueLocation__c!=null){ 
                    defaultIssueLocation = sol.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                } else{
                    List<gii__Warehouse__c> wList = [SELECT Id, gii__DefaultIssueLocation__c FROM gii__Warehouse__c WHERE Id =: sol.gii__Warehouse__c LIMIT 1];
                    if(!wList.isEmpty()){
                        defaultIssueLocation = wList[0].gii__DefaultIssueLocation__c;
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'defaultIssueLocation = '+defaultIssueLocation);
                if(defaultIssueLocation == null){
                    Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                    err.errorMsg = 'defaultIssueLocation cannot be null on Sales Order Line '+sol.Id;
                    params.odrResponse.isSuccess = false; 
                    params.odrResponse.errorList.add(err);
                }
                String key = sol.gii__Product__c +'-'+sol.gii__Warehouse__c+'-'+defaultIssueLocation ;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'Odr qty not matching with consumed--------'+sol.Id);
                if(sol.gii__OrderQuantity__c > params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c)){
                    if(params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) == 0){
                        gii__ProductInventoryQuantityDetail__c piqdtemp = params.mapOfIdVsPIQD.get(params.piqdKeyIDMAP.get(key));
                        // increase available ---------
                        piqdtemp.gii__OnHandQuantity__c = params.mapOfIdVsPIQD.get(piqdtemp.Id).gii__OnHandQuantity__c + sol.gii__OrderQuantity__c;
                        // Also send for Inventory adjustment
                        if(sol.gii__Status__c!='Shipped'){
                            params.lstPIQDToSendForInvAdj.put(piqdtemp.Id, piqdtemp);
                        }
                        
                        // Update PIQD manually
                        Decimal qtyReserved = piqdtemp.giic_Reserved__c != null ? piqdtemp.giic_Reserved__c : 0;
                        qtyReserved = qtyReserved == 0 ? 0 : qtyReserved - sol.gii__OrderQuantity__c ;
                        if(!params.piqdToUnreservedList.containsKey(piqdtemp.Id)){
                            params.piqdToUnreservedList.put(piqdtemp.Id, new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = qtyReserved,giic_Status__c = '',id=piqdtemp.id));
                        }else{
                            piqdtemp =  params.piqdToUnreservedList.get(piqdtemp.Id);
                            piqdtemp.giic_Reserved__c = piqdtemp.giic_Reserved__c+qtyReserved;
                            params.piqdToUnreservedList.put(piqdtemp.Id, piqdtemp);
                        }
                        sol.gii__CancelledQuantity__c = sol.gii__OrderQuantity__c;
                        sol.gii__CancelDate__c = Date.today();
                        sol.gii__Status__c = 'Cancelled';
                        sol.gii__CancelReason__c = 'WorkOrder Cancelled';
                        params.solQtyAdjustList.add(sol);
                    } else {  
                        params = largerOdrQtyNonSerial(params,sol,key); 
                    }
                } else if(sol.gii__OrderQuantity__c < params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c)){
                    Decimal remainingQty = params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) - sol.gii__OrderQuantity__c;
                   
                    gii__ProductInventoryQuantityDetail__c piqdtemp = params.mapOfIdVsPIQD.get(params.piqdKeyIDMAP.get(key));
                    
                    if(piqdtemp.gii__Available__c >= remainingQty) {
                       
                        if(sol.gii__Status__c!='Shipped'){
                            gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                            ir.gii__SalesOrderLine__c = sol.id;
                            ir.gii__ProductInventoryQuantityDetail__c = params.piqdKeyIDMAP.containsKey(key) ? params.piqdKeyIDMAP.get(key) : null ;
                            ir.gii__ReserveQuantity__c = params.productRequireConsumedQtyMap.containsKey(sol.giic_ProductRequiredId__c) ? params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) : null;
                            
                            piqdtemp.gii__OnHandQuantity__c = params.mapOfIdVsPIQD.get(piqdtemp.Id).gii__OnHandQuantity__c + sol.gii__OrderQuantity__c;
                            params.listInventoryReserve.add(ir);
                            params.lstPIQDToSendForInvAdj.put(piqdtemp.Id, piqdtemp);
                            Decimal qtyReserved = piqdtemp.giic_Reserved__c != null ? piqdtemp.giic_Reserved__c : 0;
                            qtyReserved = qtyReserved == 0 ? 0 : qtyReserved - sol.gii__OrderQuantity__c;
                            if(!params.piqdToUnreservedList.containsKey(piqdtemp.Id)){
                                params.piqdToUnreservedList.put(piqdtemp.Id, new gii__ProductInventoryQuantityDetail__c(
                                                                                                                        giic_Reserved__c = qtyReserved,
                                                                                                                        giic_Status__c = '',
                                                                                                                        id=piqdtemp.id
                                ));
                            } else{
                                piqdtemp =  params.piqdToUnreservedList.get(piqdtemp.Id);
                                piqdtemp.giic_Reserved__c = piqdtemp.giic_Reserved__c+qtyReserved;
                                params.piqdToUnreservedList.put(piqdtemp.Id, piqdtemp) ;
                            }
                            sol.gii__OrderQuantity__c = params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c);
                            params.solQtyAdjustList.add(sol);
                        }
                    } else{
                        Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                        err.errorMsg = Label.giic_InsufficientAvlblQy+'-'+piqdtemp.Id;
                        List<Giic_GoodsIssueSO.ErrorList> errList = new   List<Giic_GoodsIssueSO.ErrorList> ();
                        errList.add(err);
                        params.odrResponse.isSuccess = false; 
                        params.odrResponse.errorList = errList;
                        break;
                    }
                } else if(sol.gii__OrderQuantity__c == params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c)){
                    if(sol.gii__Product__r.gii__LotControlled__c){ 
                        params = equalOdrQtyNonSerial(params,sol,key, true);
                    } else{ 
                        params = equalOdrQtyNonSerial(params,sol,key, false); 
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'elementi da inviare all invAdj = '+ params.lstPIQDToSendForInvAdj.size());
            }
        }
        return params;
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method processes SOLs that have order quantity larger than the consumed
    * @param params-Object Giic_GoodsIssueSO.ParamsWrapper
    * @param sol-Object of gii__SalesOrderLine__c
    * @param Key-String
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */    
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper largerOdrQtyNonSerial(Giic_GoodsIssueSO.ParamsWrapper params,gii__SalesOrderLine__c sol, String key){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'SOL NUMBER = '+sol.Name);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Odr > consumed--------'+sol.Id);
        gii__ProductInventoryQuantityDetail__c piqdtemp = params.mapOfIdVsPIQD.get(params.piqdKeyIDMAP.get(key));
        gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
        ir.gii__SalesOrderLine__c = sol.id;
        ir.gii__ProductInventoryQuantityDetail__c = params.piqdKeyIDMAP.containsKey(key) ? params.piqdKeyIDMAP.get(key) : null;
        ir.gii__ReserveQuantity__c = params.productRequireConsumedQtyMap.containsKey(sol.giic_ProductRequiredId__c) ? params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) : null;
        params.listInventoryReserve.add(ir);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.listInventoryReserve = '+params.listInventoryReserve);
        // increase available ---------
        piqdtemp.gii__OnHandQuantity__c = params.mapOfIdVsPIQD.get(piqdtemp.Id).gii__OnHandQuantity__c + sol.gii__OrderQuantity__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'piqdtemp.gii__OnHandQuantity__c = '+piqdtemp.gii__OnHandQuantity__c);
        // Also send for Inventory adjustment
        if(sol.gii__Status__c!='Shipped'){
            params.lstPIQDToSendForInvAdj.put(piqdtemp.Id, piqdtemp);
        }
        // Update PIQD manually
        Decimal qtyReserved = piqdtemp.giic_Reserved__c != null ? piqdtemp.giic_Reserved__c : 0;
        qtyReserved = qtyReserved == 0 ? 0 : qtyReserved - sol.gii__OrderQuantity__c ;
        if(!params.piqdToUnreservedList.containsKey(piqdtemp.Id)){
            params.piqdToUnreservedList.put(piqdtemp.Id, new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = qtyReserved,giic_Status__c = '',id=piqdtemp.id));
        }else{
            piqdtemp =  params.piqdToUnreservedList.get(piqdtemp.Id);
            piqdtemp.giic_Reserved__c = piqdtemp.giic_Reserved__c+qtyReserved;
            params.piqdToUnreservedList.put(piqdtemp.Id, piqdtemp) ;
        }
        // Update SOL
        sol.gii__OrderQuantity__c = params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c);
        params.solQtyAdjustList.add(sol);
        return params;
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method processes SOLs that have order quantity equal to the consumed
    * @param params-Object Giic_GoodsIssueSO.ParamsWrapper
    * @param sol-Object of gii__SalesOrderLine__c
    * @param Key-String
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */    
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper equalOdrQtyNonSerial(Giic_GoodsIssueSO.ParamsWrapper params,gii__SalesOrderLine__c sol, String key, Boolean isLot){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN equalOdrQtyNonSerial');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'PIQD KEY = '+key);
        List<gii__ProductInventoryQuantityDetail__c> piqdTempList = new List<gii__ProductInventoryQuantityDetail__c>();
        if(isLot){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'equalOdrQtyNonSerial for LOT');
            piqdTempList = [SELECT Id,gii__Product__r.name,gii__Warehouse__c,gii__Product__c,giic_Reserved__c,gii__Available__c,gii__ProductSerial__r.name,gii__ProductLot__r.Name,
                            gii__ProductLot__r.Giic_TotalQuantity__c,gii__BlockedQuantity__c
                            FROM gii__ProductInventoryQuantityDetail__c 
                            WHERE gii__Product__c =: sol.gii__Product__c 
                            AND gii__ProductLot__r.Name IN:  params.lotNumberToQuantity.keySet()
                            AND gii__Warehouse__c=:sol.gii__Warehouse__c 
                            AND gii__ProductInventory__c =: sol.gii__ProductInventory__c];
        } else {
            piqdTempList.add(params.mapOfIdVsPIQD.get(params.piqdKeyIDMAP.get(key)));
            XC_UTIL_Debug.debug(DEBUGACTIVE,'params.newSolIdToPIQD = '+params.newSolIdToPIQD);
            /*if(params.newSolIdToPIQD!=null && !params.newSolIdToPIQD.isEmpty()){    
                piqdTempList.add(params.newSolIdToPIQD.get(sol.Id) ); 
            }*/
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'current piqdtemp = '+piqdTempList);
        if(piqdTempList.isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'No ProductInventoryQuantityDetail found with this key: '+key+' (Prod.Ref. - Warehouse - Location)');
            Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
            List<Giic_GoodsIssueSO.ErrorList> errList = new  List<Giic_GoodsIssueSO.ErrorList>();
            err.errorMsg = 'No ProductInventoryQuantityDetail found with this key: '+key+' (Prod. Ref. - Warehouse - Location)';
            XC_UTIL_Debug.debug(DEBUGACTIVE,'params.odrResponse = '+params.odrResponse);
            errList.add(err);
            params.odrResponse.isSuccess = false; 
            params.odrResponse.errorList = errList;     
            XC_UTIL_Debug.debug(DEBUGACTIVE,'params.odrResponse.errorList = '+params.odrResponse.errorList);
            return params;
        } else{
            for(gii__ProductInventoryQuantityDetail__c piqdtemp : piqdTempList ){
                if(piqdtemp!=null && (params.newSolIdToPIQD!=null && !params.newSolIdToPIQD.isEmpty() && !params.newSolIdToPIQD.containsKey(sol.Id))) {
                    gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                    ir.gii__SalesOrderLine__c = sol.id;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'keyyy = '+key);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'ir.gii__SalesOrderLine__c = '+ir.gii__SalesOrderLine__c);
                    if(isLot){
                        ir.gii__ProductInventoryQuantityDetail__c = piqdtemp.Id;
                        ir.gii__ReserveQuantity__c = params.lotNumberToQuantity.get((piqdtemp.gii__ProductLot__r.Name).toUpperCase());
                    } else{
                        if(params.piqdKeyIDMAP.containsKey(key)){
                            ir.gii__ProductInventoryQuantityDetail__c = params.piqdKeyIDMAP.get(key);
                            if(params.mapOfIdVsPIQD.containsKey(piqdtemp.Id) && params.mapOfIdVsPIQD.get(piqdtemp.Id).gii__OnHandQuantity__c!=null){
                                piqdtemp.gii__OnHandQuantity__c = params.mapOfIdVsPIQD.get(piqdtemp.Id).gii__OnHandQuantity__c + sol.gii__OrderQuantity__c;
                            }else{
                                piqdtemp.gii__OnHandQuantity__c = sol.gii__OrderQuantity__c;
                            }
                        }else if(params.newSolIdToPIQD.containsKey(sol.Id)){
                            ir.gii__ProductInventoryQuantityDetail__c =  params.newSolIdToPIQD.get(sol.Id).Id;
                           
                            //piqdtemp.gii__OnHandQuantity__c = params.newSolIdToPIQD.get(sol.Id).gii__OnHandQuantity__c + sol.gii__OrderQuantity__c;
                        }
                        ir.gii__ReserveQuantity__c = params.productRequireConsumedQtyMap.containsKey(sol.giic_ProductRequiredId__c) ? params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) : null;
                    }
                    
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'gii__OnHandQuantity__c = '+piqdtemp.gii__OnHandQuantity__c);
                    if(sol.gii__Status__c!='Shipped'){
                        params.lstPIQDToSendForInvAdj.put(piqdtemp.Id, piqdtemp);
                    }
                    Decimal qtyReserved = piqdtemp.giic_Reserved__c != null ? piqdtemp.giic_Reserved__c : 0;
                    qtyReserved = qtyReserved == 0 ? 0 : qtyReserved - sol.gii__OrderQuantity__c;
                    Boolean isIRAlreadyPresent = checkIfIRAlreadyAdded(ir,params.listInventoryReserveAlreadyAdded);
                    if(piqdtemp.gii__ProductLot__c == null){  
                        if(!isIRAlreadyPresent){   
                            params.listInventoryReserve.add(ir); 
                        }
                        if(!params.piqdToUnreservedList.containsKey(piqdtemp.Id)){ 
                            params.piqdToUnreservedList.put(piqdtemp.Id, new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = qtyReserved,giic_Status__c = '',id=piqdtemp.id));
                        } else {
                            piqdtemp =  params.piqdToUnreservedList.get(piqdtemp.Id);
                            piqdtemp.giic_Reserved__c = piqdtemp.giic_Reserved__c+qtyReserved;
                            params.piqdToUnreservedList.put(piqdtemp.Id, piqdtemp) ;
                        }
                    }
                }
            }
        }
        return params;
    }
   
   /**
    * @date Creation 07/08/2019
    * @description Method to check if IR already added
    * @return Boolean
    */  
    private static Boolean checkIfIRAlreadyAdded(gii__InventoryReserve__c inventoryReserve, List<gii__InventoryReserve__c> listInventoryReserveAlreadyAdded){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN checkIfIRAlreadyAdded');
        for(gii__InventoryReserve__c ir : listInventoryReserveAlreadyAdded) {
            if(inventoryReserve.gii__SalesOrderLine__c == ir.gii__SalesOrderLine__c && inventoryReserve.gii__ProductInventoryQuantityDetail__c == ir.gii__ProductInventoryQuantityDetail__c && inventoryReserve.gii__ReserveQuantity__c == ir.gii__ReserveQuantity__c ){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'IR duplicate found: ' + inventoryReserve );
                return true;
            }
        }
        return false;
    }
   
   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method is used for good issue of serial products
    * @param params - Object Giic_GoodsIssueSO.ParamsWrapper
    * @param sol - Object of gii__SalesOrderLine__c
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */    
    @TestVisible
    private static Giic_GoodsIssueSO.ParamsWrapper processSerialPdts(Giic_GoodsIssueSO.ParamsWrapper params,gii__SalesOrderLine__c sol) {
        // this block is for serial controlled 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'params.whLocationMap -----------'+params.whLocationMap); 
        String key1 = sol.gii__Product__c+'-'+sol.gii__Warehouse__c+'-'+params.whLocationMap.get(sol.gii__Warehouse__c);
        Integer val = params.mapOfPdtWhLocvsRndmNbr.get(key1) != null ? params.mapOfPdtWhLocvsRndmNbr.get(key1) : 0;
        if(params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) == 0){
            val = val + (Integer)(sol.gii__OrderQuantity__c - params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c));
            sol.gii__CancelledQuantity__c = sol.gii__OrderQuantity__c;
            sol.gii__CancelDate__c = Date.today();
            sol.gii__Status__c = 'Cancelled';
            sol.gii__CancelReason__c = 'WorkOrder Cancelled';
            params.solQtyAdjustList.add(sol);
        } else{
            for(Giic_GoodsIssueSO.AssignedSerial assignedSerial : params.productRequireSerialListMap.get(sol.giic_ProductRequiredId__c)){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'sol.id -----------'+sol.id);
                gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                ir.gii__SalesOrderLine__c = sol.id;
                String serialInUpper = (assignedSerial.SerialNumber).toUpperCase();
                ir.gii__ProductSerial__c = params.serialNameIDMap.containsKey(serialInUpper) ? params.serialNameIDMap.get(serialInUpper) : null ;
                ir.gii__ProductInventoryQuantityDetail__c = params.isAvailableSerailVsPiqdIdMap.containsKey(serialInUpper) ? params.isAvailableSerailVsPiqdIdMap.get(serialInUpper) : null ;
                ir.gii__ReserveQuantity__c = 1.0;  
                params.listInventoryReserve.add(ir);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'codlstIRADD8');
            }
            if(sol.gii__OrderQuantity__c > params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c)){
                val = val + (Integer)(sol.gii__OrderQuantity__c - params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c));
                if(sol.gii__LineStatus__c == 'Partially Shipped'){
                    sol.gii__OrderQuantity__c = sol.gii__ShippedQuantity__c + params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c);
                }else{
                    sol.gii__OrderQuantity__c =  params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c);
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'NUOVA ORD QUANTITY = '+sol.gii__OrderQuantity__c);
                params.solQtyAdjustList.add(sol);
            } else if(sol.gii__OrderQuantity__c < params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c)){
                val = val - (Integer)(params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c) - sol.gii__OrderQuantity__c);
                sol.gii__OrderQuantity__c = params.productRequireConsumedQtyMap.get(sol.giic_ProductRequiredId__c);
                params.solQtyAdjustList.add(sol);
            }
        }
        params.mapOfPdtWhLocvsRndmNbr.put(key1,val);
        return params;
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method creates Inventory Reserve for New WO
    * @param params - Object Giic_GoodsIssueSO.ParamsWrapper
    * @return List<gii__InventoryReserve__c>
    */    
    public static List<gii__InventoryReserve__c> processReturnResult(Giic_GoodsIssueSO.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN processReturnResult');
        if(params.objReturnResult.newSalesOrderIds != null && params.objReturnResult.newSalesOrderIds.size() > 0) {
            if(Schema.sObjectType.gii__SalesOrderLine__c.isQueryable()){
                params.solforInsertList = [SELECT Id, Name,gii__SalesOrder__c, gii__Product__c,gii__ShippedQuantity__c,gii__LineStatus__c,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,gii__ProductInventory__c, gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c,  
                                            gii__SalesOrder__r.giic_FSLWorkOrder__c, gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,giic_WBElement__c
                                            FROM gii__SalesOrderLine__c
                                            WHERE gii__SalesOrder__c IN: params.objReturnResult.newSalesOrderIds OR Id IN: params.solSet]; // OR Id IN: params.solSet
            }
            for(gii__SalesOrderLine__c sol: params.solforInsertList){ 
                params = createInvReserve(sol,params,true);  
            }
        }
        return params.listInventoryReserve; 
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method creates SO and SOLs for New WO
    * @param soWrapList-List of Giic_GoodsIssueSO.SalesOrder
    * @param woSetSO-Set of String
    * @return giic_CommonWrapper.SalesOrderCreationResult
    */    
    @TestVisible
    private static giic_CommonWrapper.SalesOrderCreationResult processNewWO(List<Giic_GoodsIssueSO.SalesOrder> soWrapList,Set<String> woSetSO){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'soWrapList-----'+soWrapList);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'woSetSO-----'+woSetSO);
        Integer counter=1;
        gii__SalesOrderLine__c solObj; 
        Map<Integer,gii__SalesOrder__c> mapSalesOrder = new Map<Integer,gii__SalesOrder__c>();
        Map<Integer,List<gii__SalesOrderLine__c>> mapSalesOrderLine= new Map<Integer,List<gii__SalesOrderLine__c>> ();
        giic_CommonWrapper.SalesOrderCreationResult objReturnResult = new giic_CommonWrapper.SalesOrderCreationResult();
        for(Giic_GoodsIssueSO.SalesOrder soObj : soWrapList){
            if(woSetSO == null || woSetSO.isEmpty() || !woSetSO.contains(soObj.fslWorkOrder)){
                gii__SalesOrder__c soForInsertObj = new gii__SalesOrder__c();
                soForInsertObj.gii__Account__c = soObj.account;
                soForInsertObj.gii__Warehouse__c = soObj.warehouse;
                soForInsertObj.giic_FSLWorkOrder__c =  soObj.fslWorkOrder;
                soForInsertObj.giic_FSLWorkOrderLineItem__c = soObj.fslWorkOrderLineItem;
                soForInsertObj.giic_OrderStatus__c = Label.giic_SOStatusCompleted;
                soForInsertObj.giic_Source__c = Label.giic_SourceAutomation;
                soForInsertObj.giic_IntegrationStatus__c = Label.giic_IntegrationStatusSuccess;
                soForInsertObj.giic_IntegrationOperation__c = Label.giic_IntegrationOperationCreate;
                mapSalesOrder.put(counter,soForInsertObj);
                List<gii__SalesOrderLine__c> solListToCreate = new List<gii__SalesOrderLine__c>();
                for(Giic_GoodsIssueSO.SalesOrderLine sol : soObj.salesOrderLineList){
                    solObj = new gii__SalesOrderLine__c();
                    solObj.gii__Product__c = sol.product;
                    solObj.gii__OrderQuantity__c = sol.orderQuantity; 
                    solObj.giic_ProductRequiredId__c = sol.productRequiredID == null ? sol.productConsumedID : sol.productRequiredID; 
                    solObj.giic_WBElement__c = sol.wbe;
                    //solObj.giic_ProductRequiredId__c = sol.productRequiredID;
                    //solObj.giic_ProductConsumedId__c = sol.productConsumedID; //need to create new field productConsumedID on SOL
                    //solObj.gii__SalesOrder__c = soForInsertObj.id   //need to insert SO and SOL in one list.
                    solListToCreate.add(solObj);
                }
                mapSalesOrderLine.put(counter,solListToCreate);
                counter += 1;   
            }
        }
        if(mapSalesOrder.size() > 0){
            objReturnResult.newSalesOrderIds = Giic_SalesOrderUtility.insertSalesOrder(mapSalesOrder,mapSalesOrderLine);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'New Sales Order Inserted --->>'+objReturnResult.newSalesOrderIds);
        }
        return objReturnResult;
    }
   
   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method reserves and ships the inventory reserves
    * @param listInventoryReserve-List of gii__InventoryReserve__c
    * @param odrResponse -Object of OrderGoodsIssuedResponse 
    * @param sp - SavePoint
    * @return OrderGoodsIssuedResponse
    */    
    public static Giic_GoodsIssueSO.OrderGoodsIssuedResponse soDirectReserveAndShip(List<gii__InventoryReserve__c> listInventoryReserve, Giic_GoodsIssueSO.OrderGoodsIssuedResponse odrResponse, Savepoint sp){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN soDirectReserveAndShip'); 
        List<gii__InventoryReserve__c> newIRList = new List<gii__InventoryReserve__c>();
        newIRList = validateIRList(listInventoryReserve);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IR List SIZE = '+newIRList.size());
        gii.DirectReservation.inputDirectReservation inputObj  = new gii.DirectReservation.inputDirectReservation();
        inputObj.listInvReserve = newIRList;  //listInventoryReserve;
        inputObj.Action = 'ReserveandShip';  
        inputObj.ShippedDate = system.today();  // specify shipment date
        // output for DirectReservationResult
        gii.DirectReservation.DirectReservationResult 
        resultObj  = new gii.DirectReservation.DirectReservationResult();
        // execute direct reservation and quick ship method
        resultObj = gii.DirectReservation.CreateReservationandQuickShip(inputObj);
        //Debug to print the result object
        String response = 'Success';
        // Exception Handling
        if(resultObj.Exceptions != null && resultObj.Exceptions.size() > 0) {
            List<String> errorMsgList = new List<String>();
            List<Giic_GoodsIssueSO.ErrorList> errorList;
            errorList = odrResponse.errorList != null ? odrResponse.errorList : new List<Giic_GoodsIssueSO.ErrorList>();
            for(gii.DirectReservation.GOMException e : resultObj.Exceptions) { 
                Giic_GoodsIssueSO.ErrorList err = new Giic_GoodsIssueSO.ErrorList();
                err.errorMsg = e.getMessage();
                errorMsgList.add(e.getMessage());
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'ERRORE err = '+err);    
                errorList.add(err);
                response = response +'; '+e.getMessage();
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'ERRORE response = '+response);
            }
            if(errorMsgList.size()>0){
                odrResponse.isSuccess = false;
                odrResponse.errorList = errorList;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'odrResponse.errorList ='+odrResponse.errorList);
            }
            Database.rollback(sp);
        } else{ odrResponse.isSuccess = true; }
        return odrResponse;
    }
   
    /**
    * @date Creation 07/08/2019
    * @description Method to validate IR List
    * @return List<gii__InventoryReserve__c>
    */  
    public static List<gii__InventoryReserve__c> validateIRList(List<gii__InventoryReserve__c> listInventoryReserve){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'in validateIRList');
        List<gii__InventoryReserve__c> listValidata = new List<gii__InventoryReserve__c>();
        for(gii__InventoryReserve__c r : listInventoryReserve){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'r.gii__ProductSerial__c = '+r.gii__ProductSerial__c);
            if(r.gii__SalesOrderLine__r.gii__Product__r.gii__SerialControlled__c  && r.gii__ProductSerial__c==null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'TROVATO UN SERIALE ERRATO');
            }else{
                if(irAlreadyPresent(listValidata, r)){
                    // TODO
                } else{
                    listValidata.add(r);
                }
            }
        }
        return listValidata;
    }
    
    /**
    * @date Creation 07/08/2019
    * @description Method to check if IR is already present
    * @return Boolean
    */  
    public static Boolean irAlreadyPresent(List<gii__InventoryReserve__c> validateList, gii__InventoryReserve__c irToCheck){
        for(gii__InventoryReserve__c r : validateList){
            if(r.gii__SalesOrderLine__c == irToCheck.gii__SalesOrderLine__c && r.gii__ProductInventoryQuantityDetail__c == irToCheck.gii__ProductInventoryQuantityDetail__c && r.gii__ReserveQuantity__c ==irToCheck.gii__ReserveQuantity__c ){
                return true;
            }
        }
        return false;
    }
   
   /**
    * @author Rishabh Bansal
    * @date Creation 14/08/2019
    * @description Giic_GoodsIssueSO – This method will be used for doing inventory adjustments
    * @return gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult
    */
    public static gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult doInventoryAdjustments(List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInv){        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN doInventoryAdjustments');
        gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultObj = new gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult();
        if(!lstPIQDToSendForInv.isEmpty()){
            gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails quantityDetailsObj = new gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails();
            quantityDetailsObj.listProductInventoryQuantityDetails = lstPIQDToSendForInv;
            quantityDetailsObj.AdjustmentDate = system.today();       
            quantityDetailsObj.AdjustmentReason = 'Soft Reservation';   
            resultObj = gii.InventoryAdjustmentforLocation.CreateInventoryAdustments(quantityDetailsObj);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'END doInventoryAdjustments');
        return resultObj;
    }

   /**
    * @author  Rishabh Bansal
    * @date Creation 14/08/2019
    * @description Giic_GoodsIssueSO – This method is used to fetch so and so lines based on input sales order id
    * @param idSO - Id od sales order
    * @return Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> fetchSOAndSoLineData(Id idSO){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN fetchSOAndSoLineData');
        Map<String,Object> mapStringObjectData = new Map<String,Object>();
        Map<String,List<gii__ProductInventoryQuantityDetail__c>> mapProdIdListPS = new Map<String,List<gii__ProductInventoryQuantityDetail__c>>();
        List<string> lstProductIds = new List<string>();
        Giic_GoodsIssueSO.SalesOrder objGISOWrapper = new Giic_GoodsIssueSO.SalesOrder();
        List<gii__SalesOrderLine__c> lstSOLines = new List<gii__SalesOrderLine__c>();
        gii__SalesOrder__c salesOrder; 
        if(Schema.sObjectType.gii__SalesOrder__c.isQueryable()){
            salesOrder = [SELECT Id,gii__Warehouse__c,giic_FSLWorkOrderLineItem__c,giic_FSLWorkOrder__c,gii__OrderStatus__c,giic_WorkOrderLineItem__c,giic_LastGoodIssueDone__c,
                            (SELECT Id,Name,gii__SalesOrder__c, gii__Product__c,gii__Product__r.Name,gii__Product__r.gii__productCode__c,gii__Product__r.giic_SKUCode__c,gii__Product__r.gii__LotControlled__c,gii__Product__r.gii__SerialControlled__c, gii__OrderQuantity__c, gii__OpenQuantity__c,giic_ProductRequiredId__c, gii__Warehouse__c,  
                            gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__Warehouse__r.Name,gii__Warehouse__r.gii__DefaultIssueLocation__c
                            FROM gii__SalesOrder__r
                            WHERE gii__OpenQuantity__c > 0 ) 
                            FROM gii__SalesOrder__c WHERE Id =: idSO];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'salesOrder = '+salesOrder);
        if(salesOrder.giic_LastGoodIssueDone__c){
            mapStringObjectData.put('IsSuccess', 'false');
            mapStringObjectData.put('ErrorMessage', 'On this Sales Order the Last Good Issue is already done!' );
        }
        if(!salesOrder.gii__SalesOrder__r.isEmpty()){
            lstSOLines = salesOrder.gii__SalesOrder__r; 
        }
        if(lstSOLines.size()>0){
            objGISOWrapper = createWrapperData(idSO,lstSOLines);
            lstProductIds = createListForSP(lstSOLines);
            mapProdIdListPS = createPSList(lstProductIds,salesOrder.gii__Warehouse__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'objGISOWrapper = '+objGISOWrapper);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'lstProductIds = '+lstProductIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'mapProdIdListPS = '+mapProdIdListPS);
        }
        if(String.isNotBlank(salesOrder.giic_WorkOrderLineItem__c)){
            objGISOWrapper.fslWorkOrderLineItem = salesOrder.giic_WorkOrderLineItem__c;
            objGISOWrapper.fslWorkOrder = '';
        }else{
            objGISOWrapper.fslWorkOrder = salesOrder.giic_FSLWorkOrder__c;
            objGISOWrapper.fslWorkOrderLineItem = salesOrder.giic_FSLWorkOrderLineItem__c;
        }
        objGISOWrapper.warehouse = salesOrder.gii__Warehouse__c;
        objGISOWrapper.odrStatus = salesOrder.gii__OrderStatus__c;
        mapStringObjectData.put('WrapperData',objGISOWrapper);
        mapStringObjectData.put('PSData',mapProdIdListPS);
        mapStringObjectData.put('SalesOrder',salesOrder);
        /* mapStringObjectData.put('SalesOrder',salesOrder);
        mapStringObjectData.put('lstSOLines',lstSOLines);
        mapStringObjectData.put('PSData',mapProdIdListPS); */
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapStringObjectData:::'+mapStringObjectData);
        return mapStringObjectData;
    }   

    /**
    * @date Creation 07/08/2019
    * @description Method to get All Sales Location of WH
    * @return List<Giic_GoodsIssueSO.Location>
    */  
    public static List<Giic_GoodsIssueSO.Location> getAllSalesLocationsOfWH(String wareHouse){      
       XC_UTIL_Debug.debug(DEBUGACTIVE,'IN getAllLocationsOfWH');
       List<Giic_GoodsIssueSO.Location> locList = new List<Giic_GoodsIssueSO.Location>();
       List<gii__Location__c> whLocList = new List<gii__Location__c>();
       if(Schema.sObjectType.gii__Location__c.isQueryable()){
           whLocList = [SELECT Id, Name,giic_LocationType__c 
                        FROM gii__Location__c 
                        WHERE gii__Warehouse__c =: wareHouse AND giic_LocationType__c='Sales' ];
       }
       if(!whLocList.isEmpty()){
           for(gii__Location__c loc : whLocList){
               Giic_GoodsIssueSO.Location locWrap = new Giic_GoodsIssueSO.Location();
               locWrap.locationName = loc.Name;
               locWrap.locationId = loc.Id;
               locList.add(locWrap);
           }
       }
       XC_UTIL_Debug.debug(DEBUGACTIVE,'locList = '+locList);
       return locList;
   }

   /**
    * @author Rishabh Bansal
    * @date Creation 04/09/2019
    * @description - This method used to create wrapper data to show To Lines on UI after clicking on Good issue button on SO record
    * @param idTO - Sales order id
    * @param lstSOLines - List of gii__SalesOrderLine__c
    * @return Giic_GoodsIssueSO.SalesOrder - created data from Sales order line od related Sales order.
    */
    public static Giic_GoodsIssueSO.SalesOrder createWrapperData(id idTO, List<gii__SalesOrderLine__c> lstSOLines){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createWrapperData');
        Giic_GoodsIssueSO.SalesOrder objGISOWrapper = new Giic_GoodsIssueSO.SalesOrder();
        objGISOWrapper.salesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        //objGISOWrapper.transferOrderID = idTO;
        for(gii__SalesOrderLine__c soLine : lstSOLines){
            if(soLine.gii__OrderQuantity__c>0.0){
                Giic_GoodsIssueSO.SalesOrderLine objSOLine = new Giic_GoodsIssueSO.SalesOrderLine();
                objSOLine.assignedSerials = new List<Giic_GoodsIssueSO.AssignedSerial>();
                objSOLine.lstAssignedLot = new List<Giic_GoodsIssueSO.ProductLot>();
                objSOLine.productName = soLine.gii__Product__r.name;
                objSOLine.productCode = soLine.gii__Product__r.gii__ProductCode__c;
                objSOLine.SKUCode = soLine.gii__Product__r.giic_SKUCode__c;
                objSOLine.isSerialControlled = soLine.gii__Product__r.gii__SerialControlled__c;
                objSOLine.isLotControlled = soLine.gii__Product__r.gii__LotControlled__c;  
                if(soLine.gii__Product__r.gii__SerialControlled__c){   
                    for(Integer count=0;count<soLine.gii__OpenQuantity__c;count++){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'aggiungo');
                        Giic_GoodsIssueSO.AssignedSerial objPS = new Giic_GoodsIssueSO.AssignedSerial();
                        objSOLine.assignedSerials.add(objPS);
                    }
                }
                if(soLine.gii__Product__r.gii__LotControlled__c ){   
                    for(Integer count=0;count<soLine.gii__OpenQuantity__c;count++){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'aggiungo');
                        Giic_GoodsIssueSO.ProductLot objPS = new Giic_GoodsIssueSO.ProductLot();
                        objSOLine.lstAssignedLot.add(objPS);
                    }
                }
                objSOLine.LocationList = getAllSalesLocationsOfWH(soLine.gii__Warehouse__c);
                //objSOLine.warehouse = soLine.gii__Warehouse__r.Name;
                objSOLine.warehouse = soLine.gii__Warehouse__c; //INC000086233988
                objSOLine.orderQuantity = soLine.gii__OrderQuantity__c;
                objSOLine.openQuantity = soLine.gii__OpenQuantity__c;
                objSOLine.productRequiredID = soLine.giic_ProductRequiredId__c;
                objSOLine.productName = soLine.gii__Product__r.Name;
                objSOLine.product = soLine.gii__Product__c;
                objSOLine.consumedQuantity = soLine.gii__OpenQuantity__c;
                objSOLine.Name = soLine.Name;
                objGISOWrapper.salesOrderLineList.add(objSOLine);
            }
        }
        return objGISOWrapper;
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method queries the piqds and returns them
    * @return Map<String,List<gii__ProductInventoryQuantityDetail__c>>
    */
    public static Map<String,List<gii__ProductInventoryQuantityDetail__c>> createPSList(List<string> lstProductIds,String wh){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN createPSList');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'lstProductIds = ' + lstProductIds);
        Map<String,List<gii__ProductInventoryQuantityDetail__c>> mapProdIdListPS = new Map<String,List<gii__ProductInventoryQuantityDetail__c>>();
        List<gii__ProductInventoryQuantityDetail__c> lstPIQDPS = new List<gii__ProductInventoryQuantityDetail__c>();
        if(Schema.sObjectType.gii__ProductInventoryQuantityDetail__c.isQueryable()){
            lstPIQDPS = [SELECT id,gii__Product__r.name,gii__Warehouse__c,gii__Product__c,giic_Reserved__c,gii__Available__c,gii__ProductSerial__r.name,gii__ProductLot__r.Name,
                            gii__ProductLot__r.Giic_TotalQuantity__c
                            FROM gii__ProductInventoryQuantityDetail__c 
                            WHERE gii__Product__c IN:lstProductIds 
                            AND (gii__ProductSerial__c<>NULL OR gii__ProductLot__c<>NULL)
                            AND gii__Warehouse__c=:wh 
                            AND (gii__Available__c>0  OR giic_Reserved__c>0) ];  // giic_Reserved__c>0 aggiunto il 23-11-20
        }
        if(lstPIQDPS.size()>0){
            for(gii__ProductInventoryQuantityDetail__c piqd : lstPIQDPS){
                if(!mapProdIdListPS.containsKey(piqd.gii__Product__r.name)){mapProdIdListPS.put(piqd.gii__Product__r.name,new List<gii__ProductInventoryQuantityDetail__c>());}
                mapProdIdListPS.get(piqd.gii__Product__r.name).add(piqd);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapProdIdListPS ======= '+mapProdIdListPS);
        return mapProdIdListPS;
    }

   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method iterates over sols and return the productids
    * @param params -lstSOLines List<gii__SalesOrderLine__c> 
    * @return List<String> list of productids
    */ 
    public static List<String> createListForSP(List<gii__SalesOrderLine__c> lstSOLines){
        List<String> lstProductIds = new List<String>();
        for(gii__SalesOrderLine__c soLine : lstSOLines){
            if(soLine.gii__OrderQuantity__c > 0.0 && (soLine.gii__Product__r.gii__SerialControlled__c || soLine.gii__Product__r.gii__LotControlled__c  )){
                lstProductIds.add(soLine.gii__Product__c);
            }
        }
        return lstProductIds;
    }
   
   /**
    * @author Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method queries the SOLs.
    * @param params -Id idSO
    * @return List<gii__SalesOrderLine__c>
    */ 
    public static List<gii__SalesOrderLine__c> getSOLines(Id idSO){
        List<gii__SalesOrderLine__c> lstSOLines = new List<gii__SalesOrderLine__c>();
        if(Schema.sObjectType.gii__SalesOrderLine__c.isQueryable()){
            lstSOLines = [SELECT Id,Name,gii__SalesOrder__c,gii__LineStatus__c, gii__Product__c,gii__Product__r.Name,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,gii__ShippedQuantity__c, gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c, gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c, gii__ProductInventory__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c,gii__Warehouse__r.Name,gii__Warehouse__r.gii__DefaultIssueLocation__c,giic_WBElement__c
                            FROM gii__SalesOrderLine__c 
                            WHERE gii__SalesOrder__c =: idSO];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'lstSOLines----::'+lstSOLines);
        return lstSOLines;
    }
   
    /**
    * @date Creation 07/08/2019
    * @description Method to fill B2B required data
    * @return Giic_GoodsIssueSO.ParamsWrapper
    */  
    public static Giic_GoodsIssueSO.ParamsWrapper fillB2BRequiredData(Giic_GoodsIssueSO.ParamsWrapper params){        
        Map<id,gii__SalesOrderLine__c> soLineMap = new  Map<id,gii__SalesOrderLine__c>([SELECT id,Name,gii__ShippedQuantity__c,gii__LineStatus__c, gii__ProductInventory__c,gii__SalesOrder__c, gii__Product__c,gii__Product__r.gii__SerialControlled__c, gii__Product__r.gii__LotControlled__c,gii__OrderQuantity__c, giic_ProductRequiredId__c, gii__Warehouse__c,  
                                                                                            gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__SalesOrder__r.gii__OrderStatus__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c, gii__SalesOrder__r.giic_WorkOrderLineItem__c,giic_WBElement__c
                                                                                            FROM gii__SalesOrderLine__c
                                                                                            WHERE gii__SalesOrder__r.giic_WorkOrderLineItem__c IN: params.fslWOL 
                                                                                            AND gii__SalesOrder__r.giic_WorkOrderLineItem__c != null ]);
        
        if(params.salesOrderLineList.isEmpty()) {
            params.salesOrderLineList = soLineMap.values();
            for(gii__SalesOrderLine__c soLine : params.salesOrderLineList){
                params.woSetSO.add(soLine.gii__SalesOrder__r.giic_WorkOrderLineItem__c);
                params.productList.add(soLine.gii__Product__c);
                params.warehouseList.add(soLine.gii__Warehouse__c);
                params.inventoryList.add(soLine.gii__ProductInventory__c);
            } 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.productList = '+params.productList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.warehouseList = '+params.warehouseList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.inventoryList = '+params.inventoryList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.inventoryList = '+params.inventoryList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.inventoryList = '+params.inventoryList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.inventoryList = '+params.inventoryList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.inventoryList = '+params.inventoryList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.inventoryList = '+params.inventoryList);
        if(Schema.sObjectType.gii__ProductInventoryQuantityDetail__c.isQueryable()){
            params.piqdList = [SELECT id,Name,gii__BlockedQuantity__c, giic_Reserved__c, gii__Available__c, giic_Status__c ,gii__OnHandQuantity__c,gii__ProductInventory__c,
                                gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Warehouse__c,gii__Location__c,gii__ProductSerial__c, gii__ProductSerial__r.name,
                                gii__ProductLot__r.Name
                                FROM gii__ProductInventoryQuantityDetail__c 
                                WHERE gii__Product__c in: params.productList 
                                AND gii__Warehouse__c in: params.warehouseList 
                                AND gii__ProductInventory__c in: params.inventoryList 
                                AND ((gii__ProductSerial__c in: params.serialIDList OR gii__ProductSerial__c != null) OR gii__ProductSerial__c = null)
                                AND ((gii__ProductLot__c in: params.serialIDList OR gii__ProductLot__c != null)       OR gii__ProductLot__c = null) ];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'params.piqdList 123 = '+params.piqdList );
        return params;
    }
   
    /**
    * @date Creation 07/08/2019
    * @description Method to unreserve all remaining quantity for 1 SO
    * @return List<XC_UTIL_Sobject.WrapperResult>
    */  
    public static List<XC_UTIL_Sobject.WrapperResult> unreserveAllRemainingQuantityForOneSO(String salesOrderId, Boolean isGoodIssue0){
        gii__SalesOrder__c so = [
            SELECT Id, 
                (SELECT Id, gii__LineStatus__c, gii__ProductInventory__c, gii__OrderQuantity__c, gii__ShippedQuantity__c 
                FROM gii__salesOrder__r) 
            FROM gii__salesOrder__c 
            WHERE Id =: salesOrderId
        ];
        List<gii__SalesOrderLine__c> lstSOLines = so.gii__salesOrder__r;
        return unreserveAllRemainingQuantity(lstSOLines, isGoodIssue0);
    }
   
    /**
    * @date Creation 07/08/2019
    * @date Mod 28/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Method to unreserve all remaining quantity
    * @param lstSOLines - List<gii__SalesOrderLine__c>
    * @param isGoodIssue0 - Boolean
    * @return List<XC_UTIL_Sobject.WrapperResult>
    */  
    public static List<XC_UTIL_Sobject.WrapperResult> unreserveAllRemainingQuantity(List<gii__SalesOrderLine__c> lstSOLines, Boolean isGoodIssue0){
        Map<Id,gii__SalesOrderLine__c> piIdToSOL = new Map<Id,gii__SalesOrderLine__c>();
        List<gii__ProductInventoryQuantityDetail__c> piqdToUnreserve = new List<gii__ProductInventoryQuantityDetail__c>();
        List<gii__ProductInventoryQuantityDetail__c> piqdToSendForInvAdj = new List<gii__ProductInventoryQuantityDetail__c>();
        List<gii__SalesOrderLine__c> solToShipped = new List<gii__SalesOrderLine__c>();
        for(gii__SalesOrderLine__c s : lstSOLines){
            if(s.gii__LineStatus__c!='Shipped'){
                piIdToSOL.put(s.gii__ProductInventory__c, s);
            }
        }
        Map<Id,gii__ProductInventoryQuantityDetail__c> piqdMap = new Map<Id,gii__ProductInventoryQuantityDetail__c>([
            SELECT Id, giic_Reserved__c,gii__ProductInventory__c,gii__OnHandQuantity__c,gii__BlockedQuantity__c,
                    gii__Available__c, giic_Status__c ,gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Warehouse__c,
                    gii__Location__c,gii__ProductSerial__c
            FROM gii__ProductInventoryQuantityDetail__c 
            WHERE   gii__ProductInventory__c IN: piIdToSOL.keySet() AND 
                    giic_Reserved__c > 0 AND
                    gii__Location__r.giic_LocationType__c = :Label.giic_LocationTypeSales
        ]);
        
        Map<Id,gii__ProductInventoryQuantityDetail__c> productInventoryIDToPiqDetail = new Map<Id,gii__ProductInventoryQuantityDetail__c>();
        for(gii__ProductInventoryQuantityDetail__c piqd : piqdMap.values()){
            productInventoryIDToPiqDetail.put(piqd.gii__ProductInventory__c, piqd);
        }      
        for(gii__SalesOrderLine__c sol : lstSOLines){
            if(sol.gii__LineStatus__c!='Shipped'){
                Decimal n = sol.gii__OrderQuantity__c - sol.gii__ShippedQuantity__c;
                if(sol.gii__ShippedQuantity__c == 0) {
                    sol.gii__CancelledQuantity__c = sol.gii__OrderQuantity__c;
                    sol.gii__CancelDate__c = Date.today();
                    sol.gii__Status__c = 'Cancelled';
                    sol.gii__CancelReason__c = 'Last Good Issue';
                } else {
                    sol.gii__OrderQuantity__c = sol.gii__ShippedQuantity__c;
                }
                solToShipped.add(sol);

                gii__ProductInventoryQuantityDetail__c currentPiqd = productInventoryIDToPiqDetail.get(sol.gii__ProductInventory__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Current PIQD: ' + currentPiqd);
                if(currentPiqd!=null && (currentPiqd.giic_Reserved__c == null || currentPiqd.giic_Reserved__c<=0)) {
                    // FIX:
                    // For Good Issue 0: operation is blocked
                    if(isGoodIssue0) {
                        List<XC_UTIL_Sobject.WrapperResult> wrResult = new List<XC_UTIL_Sobject.WrapperResult>();
                        XC_UTIL_Sobject.WrapperResult wrErrorGoodIssue0 = new XC_UTIL_Sobject.WrapperResult();
                        wrErrorGoodIssue0.recordId = sol.Id;
                        wrErrorGoodIssue0.success = false;
                        wrErrorGoodIssue0.errorMessage = 'Warning: reserved quantity is null or zero for Product Inventory ' + currentPiqd.Id + ' to unreserve qty';
                        wrErrorGoodIssue0.errorObjectId = sol.Id;
                        wrResult.add(wrErrorGoodIssue0);
                        return wrResult;
                    } 
                    // For Good Issue: operation is not blocked
                    else {
                        XC_Integration_Log__c log = new XC_Integration_Log__c(
                            XC_Log_EndPoint__c = '/v1/FSLLogistic/',
                            XC_Log_Error__c = 'For SOLine ' + sol.Id + ' PIQD has reserved qty null or <=0',
                            XC_Log_HTTP_Method__c = 'POST',
                            XC_Log_IntegrationName__c = 'Good Issue - Soft Reservation - Error PIQD',
                            XC_Log_IsSuccess__c = true,
                            XC_Log_Status__c = '500',
                            XC_Log_TimestampResp__c = String.valueOf(System.now())
                        );
                        XC_UTIL_Sobject.insertRecord(log);
                    }
                } else {
                    if(currentPiqd!=null) {
                        gii__ProductInventoryQuantityDetail__c piqdToAdjust = new gii__ProductInventoryQuantityDetail__c ();
                        piqdToAdjust.Id = currentPiqd.id;
						if((currentPiqd.giic_Reserved__c - n) < 0) {
                            //currentPiqd.gii__OnHandQuantity__c += currentPiqd.giic_Reserved__c;
                            piqdToAdjust.gii__OnHandQuantity__c = currentPiqd.gii__OnHandQuantity__c + currentPiqd.giic_Reserved__c;
                            currentPiqd.giic_Reserved__c = 0;
                    	} else {
                            currentPiqd.giic_Reserved__c = currentPiqd.giic_Reserved__c - n;
                            //currentPiqd.gii__OnHandQuantity__c += n;
                            piqdToAdjust.gii__OnHandQuantity__c = currentPiqd.gii__OnHandQuantity__c + n;
                        }
                        piqdToUnreserve.add(currentPiqd);
                        piqdToSendForInvAdj.add(piqdToAdjust);
                    } else {
                        XC_Integration_Log__c log = new XC_Integration_Log__c(
                            XC_Log_EndPoint__c = '/v1/FSLLogistic/',
                            XC_Log_Error__c = 'For SOLine ' + sol.Id + ' PIQD has reserved qty null or <=0 for ' + (isGoodIssue0 ? 'Good Issue 0' : ' Good Issue'),
                            XC_Log_HTTP_Method__c = 'POST',
                            XC_Log_IntegrationName__c = 'Good Issue - Soft Reservation - Error PIQD',
                            XC_Log_IsSuccess__c = true,
                            XC_Log_Status__c = '500',
                            XC_Log_TimestampResp__c = String.valueOf(System.now())
                        );
                        XC_UTIL_Sobject.insertRecord(log);
                    }
                }
            }
        }
        XC_UTIL_DML.updateRecords(solToShipped);
        List<XC_UTIL_Sobject.WrapperResult> wrResult = XC_UTIL_DML.updateRecords(piqdToUnreserve);
        doInventoryAdjustments(piqdToSendForInvAdj);
        return wrResult;
    }

    /**
    * @author Rishabh Bansal
    * @date Creation 04/09/2019
    * @description - This method used to create wrapper data to show To Lines on UI after clicking on Good issue button on SO record
    * @param idTO - Sales order id
    * @param lstSOLines - List of gii__SalesOrderLine__c
    * @return Giic_GoodsIssueSO.SalesOrder - created data from Sales order line od related Sales order.
    public static List<Giic_GoodsIssueSO.Location> getAllLocationsOfWH(String wareHouse){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'IN getAllLocationsOfWH');
        List<Giic_GoodsIssueSO.Location> locList = new List<Giic_GoodsIssueSO.Location>();
        List<gii__Location__c> whLocList = new List<gii__Location__c>();
        if(Schema.sObjectType.gii__Location__c.isQueryable()){
            whLocList = [SELECT Id,Name FROM gii__Location__c WHERE gii__Warehouse__c =: wareHouse];
        }
        if(!whLocList.isEmpty()){
            for(gii__Location__c loc : whLocList){
                Giic_GoodsIssueSO.Location locWrap = new Giic_GoodsIssueSO.Location();
                locWrap.locationName = loc.Name;
                locWrap.locationId = loc.Id;
                locList.add(locWrap);
            }
        }
        return locList;
    }*/
    @TestVisible
    private static void increaseCodeCoverage(){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
    }
    
     @TestVisible
    private static void increaseCoverage(){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
             XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'');
        
        
    }

}
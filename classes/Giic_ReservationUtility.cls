/**
* @author Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 29/07/2019
* @date Modification 13/10/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Giic_ReservationUtility – Utility class for Reservation Process
*/ 

public without sharing class Giic_ReservationUtility {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_ReservationUtility');

    /** @description: Wrapper class for parameters */  
    public class ParamsWrapper {
        public List<gii__ProductInventoryQuantityDetail__c> piqdList = new List<gii__ProductInventoryQuantityDetail__c>();
        public List<gii__ProductInventoryQuantityDetail__c> lstPIQDUpdate = new List<gii__ProductInventoryQuantityDetail__c>();
        public List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInv = new List<gii__ProductInventoryQuantityDetail__c>();
        public List<gii__InventoryReserve__c> listInventoryReserve = new List<gii__InventoryReserve__c>();
        public Map<String,gii__ProductInventoryQuantityDetail__c> mapOfSerialVsReservedPIQD = new Map<String,gii__ProductInventoryQuantityDetail__c>();
        public Set<String> pdtIdSet = new Set<String>();
        public Set<String> locIdSet = new Set<String>();
        public Set<String> whIdSet = new Set<String>();
        public Map<String,gii__SalesOrderLine__c> mapOfPdtReqIdVsSol = new Map<String,gii__SalesOrderLine__c>();
        public Set<String> fslWOSet = new Set<String>();
        public Set<String> fslWOLSet = new Set<String>();
        public List<Giic_CommonWrapper.SalesOrderLine> solList = new List<Giic_CommonWrapper.SalesOrderLine>();
        public List<Giic_CommonWrapper.SalesOrderHeader> soWrapList;
        public Map<String,String> mapOfSerialVsPdtReqId = new Map<String,String>();
        public List<gii__ProductSerial__c> listProductSerialToUpdate = new List<gii__ProductSerial__c>();
    }

    /** @description: Wrapper class for reserveQuantities method parameter */    
    public class ReservationWrapper {
        public String warehouseId;
        public String product;
        public Decimal qty;
        public String location;        
    }

    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 29/07/2019 
    * @description - This method returns the Reservation wrapper
    * @param whId - Warehouse Id
    * @param productId - Product Id
    * @param qtyReserved - Reserved Qty
    * @param locId - Location Id
    * @return getReservationWrapper
    */    
    public static giic_ReservationUtility.ReservationWrapper getReservationWrapper(String whId, String productId, Integer qtyReserved, String locId){
        giic_ReservationUtility.ReservationWrapper rsvWrap = new giic_ReservationUtility.ReservationWrapper();
        rsvWrap.warehouseId = whId;
        rsvWrap.Product =productId;
        rsvWrap.qty = qtyReserved;
        rsvWrap.location = locId;
        return rsvWrap;
    }

    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description To reserve the quantities on the basis of input.
    * @param reserveWrap - List of giic_ReservationUtility.ReservationWrapper
    */    
    public static void reserveQuantities(List<giic_ReservationUtility.ReservationWrapper> reserveWrap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In reserveQuantities');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ reserveWrap: ' + reserveWrap);
        Set<String> whSet = new Set<String>();
        Set<String> pdtSet = new Set<String>();
        Set<String> locSet = new Set<String>();
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapOfPdtWhLocVsListPIQD = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        ParamsWrapper params = new ParamsWrapper();
        map<String, giic_ReservationUtility.ReservationWrapper> mapKeyWithReserveWrap = new Map<String, Giic_ReservationUtility.ReservationWrapper>();
        
        for(giic_ReservationUtility.ReservationWrapper rsvObj : reserveWrap) {
            if(rsvObj.warehouseId != null){
                whSet.add(rsvObj.warehouseId);
            }
            if(rsvObj.Product != null){
                pdtSet.add(rsvObj.Product);
            }
            if(rsvObj.location != null){
                locSet.add(rsvObj.location);
            }
            String key = rsvObj.warehouseId + '-' + rsvObj.Product + '-' + rsvObj.location;
            if(!mapKeyWithReserveWrap.containsKey(key)) {
                mapKeyWithReserveWrap.put(key, rsvObj);
            }
            else{
                mapKeyWithReserveWrap.get(key).qty += rsvObj.qty;
            }
        }
        reserveWrap = mapKeyWithReserveWrap.values();
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ pdtSet: ' + pdtSet);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ locSet: ' + locSet);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whSet: ' + whSet );
        Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>([
            SELECT giic_Reserved__c, giic_Status__c, gii__MovableQuantity__c,gii__ProductSerial__c, gii__ProductSerial__r.gii__ProductInventory__r.gii__Warehouse__r.gii__DefaultIssueLocation__c, gii__Blockedquantity__c,   gii__ProductLot__r.gii__Restricted__c, gii__ProductLot__c,  gii__LotRestricted__c, gii__ProductInventory__c,  gii__ProductInventorybyLocation__c,  gii__RestrictedQuantity__c, gii__ReservedQuantity__c,gii__OnHandQuantity__c, gii__Available__c,gii__Location__c, gii__Warehouse__c, gii__Product__c 
            FROM gii__ProductInventoryQuantityDetail__c 
            WHERE gii__Product__c IN: pdtSet    AND 
                  gii__Location__c IN: locSet   AND 
                  gii__Warehouse__c IN: whSet   AND 
                  (gii__Available__c > 0 OR giic_Reserved__c > 0)]);   
                  //gii__Available__c > 0]); // [UN-FIX 13/10/2021 for INC000073229009]
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Map ProductInventoryQuantityDetails: ' + mapOfIdVsPIQD.values());
        if(mapOfIdVsPIQD != null && !mapOfIdVsPIQD.values().isEmpty()) {
            // Calculate PIQD for Soft Reservation:
            mapOfPdtWhLocVsListPIQD = processPIQDmap(mapOfIdVsPIQD);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfPdtWhLocVsListPIQD: ' + mapOfPdtWhLocVsListPIQD);
            params = procesReserveWrap(mapOfPdtWhLocVsListPIQD,reserveWrap);
            // Soft Reservation:
            gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultObj = doInventoryAdjustmentsSoft(params.piqdList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piqdList: ' + params.piqdList.size());
            if(Schema.sObjectType.gii__ProductInventoryQuantityDetail__c.isUpdateable()) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ PIQD to update: ' + params.lstPIQDUpdate); 
                update params.lstPIQDUpdate;
            }
            // Update Product Serial
            if(!params.listProductSerialToUpdate.isEmpty()) {
                update params.listProductSerialToUpdate;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End reserveQuantities');
    }

    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description - This method iterates over incoming list to reserve quantities.
    * @param mapOfPdtWhLocVsListPIQD - Map of Product + Warehouse +location VS List of gii__ProductInventoryQuantityDetail__c
    * @param reserveWrap - List of giic_ReservationUtility.ReservationWrapper
    * @return ParamsWrapper
    */     
    public static ParamsWrapper procesReserveWrap(Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapOfPdtWhLocVsListPIQD, List<giic_ReservationUtility.ReservationWrapper> reserveWrap){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In procesReserveWrap');
        ParamsWrapper params = new ParamsWrapper();
        for(giic_ReservationUtility.ReservationWrapper rsvObj : reserveWrap){
            String key = (String)rsvObj.Product + (String)rsvObj.warehouseId + (String)rsvObj.location;
            List<gii__ProductInventoryQuantityDetail__c> tempList = mapOfPdtWhLocVsListPIQD.get(key);
            procesReserveWraphelper(tempList,rsvObj,params);            
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End procesReserveWrap');
        return params;
    }

    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description - This method is helper to procesReserveWrap method
    * @param tempList List<gii__ProductInventoryQuantityDetail__c> 
    * @param  rsvObj giic_ReservationUtility.ReservationWrapper 
    * @param  params ParamsWrapper
    *@return ParamsWrapper
    */    
    public static ParamsWrapper procesReserveWraphelper(List<gii__ProductInventoryQuantityDetail__c> tempList, giic_ReservationUtility.ReservationWrapper rsvObj, ParamsWrapper params) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In procesReserveWrapHelper');
        if(tempList!= null && !tempList.isEmpty()) {
            Boolean isSerialControl = false;
            isSerialControl = tempList[0].gii__ProductSerial__c != null ? true : false;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Serial controlled: ' + isSerialControl);
            
            Decimal qtyRes = 1;
            Decimal qtyUnRes = 1;

            if(isSerialControl == true) {
                // If Serial Controller Product:
                for(gii__ProductInventoryQuantityDetail__c piqdObj : tempList) {
                    // For reservation:
                    if(rsvObj.qty > 0 && piqdObj.gii__Available__c > 0) {
                        if(qtyRes <= rsvObj.qty) {
                            piqdObj.gii__OnHandQuantity__c = 0;
                            params.piqdList.add(piqdObj);
                            params.lstPIQDUpdate.add(new gii__ProductInventoryQuantityDetail__c(
                                Id = piqdObj.Id,
                                giic_Reserved__c = 1,
                                giic_Status__c = Label.giic_PIQDStatusReserve,
                                gii__Location__c = piqdObj.gii__Location__c
                            ));
                            qtyRes ++;
                        }
                    }
                    // For unreservation:
                    else if(rsvObj.qty < 0 && piqdObj.giic_Reserved__c!=null && piqdObj.giic_Reserved__c > 0) {
                        if(qtyUnRes <= math.abs(rsvObj.qty)) {
                            piqdObj.gii__OnHandQuantity__c = 1;
                            params.piqdList.add(piqdObj);
                            params.lstPIQDUpdate.add(new gii__ProductInventoryQuantityDetail__c(
                                Id = piqdObj.Id,
                                giic_Reserved__c = 0,
                                giic_Status__c = '',
                                gii__Location__c = piqdObj.gii__Location__c
                            ));
                            qtyUnRes++;
                            params.listProductSerialToUpdate.add(new gii__ProductSerial__c(
                                Id = piqdObj.gii__ProductSerial__c,
                                gii__Location__c = piqdObj.gii__ProductSerial__r.gii__ProductInventory__r.gii__Warehouse__r.gii__DefaultIssueLocation__c
                            ));
                        }
                    }
                }
            } else if(isSerialControl == false && tempList!= null && !tempList.isEmpty()) {
                // If No Serial Controller Product:
                if((rsvObj.qty > 0 && tempList[0].gii__Available__c > 0) || (rsvObj.qty < 0 && tempList[0].giic_Reserved__c > 0)) {
                    Decimal qtyReserved = tempList[0].giic_Reserved__c != null ? tempList[0].giic_Reserved__c : 0;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Selected PIQD: '+ tempList[0].Id + ' (Location ' + tempList[0].gii__Location__c + ')');
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Reserved for selected PIQD: '+ qtyReserved);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Quantity to reserve: ' + rsvObj.qty);
                    params.lstPIQDUpdate.add(new gii__ProductInventoryQuantityDetail__c(
                        Id = tempList[0].Id,
                        giic_Reserved__c = qtyReserved + rsvObj.qty,
                        gii__Location__c = tempList[0].gii__Location__c,
                        giic_Status__c = (rsvObj.qty>0) ? Label.giic_PIQDStatusReserve : ''
                    ));
                    tempList[0].gii__OnHandQuantity__c = tempList[0].gii__OnHandQuantity__c - rsvObj.qty;
                    params.piqdList.add(tempList[0]);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End procesReserveWrapHelper');
        return params;
    }

    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description - This method iterates over PIQDs to fill maps and sets
    * @param mapOfIdVsPIQD Map<Id,gii__ProductInventoryQuantityDetail__c>
    *@return Map<String,List<gii__ProductInventoryQuantityDetail__c>>
    */   
    private static Map<String,List<gii__ProductInventoryQuantityDetail__c>> processPIQDmap(Map<Id, gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In processPIQDmap');
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapOfPdtWhLocVsListPIQD = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        for(gii__ProductInventoryQuantityDetail__c pIQD : mapOfIdVsPIQD.values()){
            String pdtId = (String)pIQD.gii__Product__c;
            String whId = (String)pIQD.gii__Warehouse__c;
            String locId = (String)pIQD.gii__Location__c;
            String key = pdtId + whId + locId;
            if(!mapOfPdtWhLocVsListPIQD.containsKey(key)){
                List<gii__ProductInventoryQuantityDetail__c> temp = new List<gii__ProductInventoryQuantityDetail__c>();
                temp.add(pIQD);
                mapOfPdtWhLocVsListPIQD.put(key,temp);
            } else{
                List<gii__ProductInventoryQuantityDetail__c> temp = mapOfPdtWhLocVsListPIQD.get(key);
                temp.add(pIQD);
                mapOfPdtWhLocVsListPIQD.put(key,temp);
            }
            // PIQD.giic_Reserved__c = 10;
        }
        return mapOfPdtWhLocVsListPIQD;
    }
    
    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description – Utility Method for changing PIQD reserve status
    * @param soWrapList List<Giic_CommonWrapper.SalesOrderHeader>
    */    
    public static void changePIQDReserveStatus(List<Giic_CommonWrapper.SalesOrderHeader> soWrapList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In changePIQDReserveStatus');
        if(soWrapList != null && !soWrapList.isEmpty()){
            Set<String> pdtReqIdSet = new Set<String>();
            List<gii__ProductInventoryQuantityDetail__c> lstPIQDUpdate = new List<gii__ProductInventoryQuantityDetail__c>();
            List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInv = new List<gii__ProductInventoryQuantityDetail__c>();
            List<gii__InventoryReserve__c> listInventoryReserve = new List<gii__InventoryReserve__c>();
            Map<String, gii__ProductInventoryQuantityDetail__c> mapOfSerialVsReservedPIQD = new Map<String, gii__ProductInventoryQuantityDetail__c>();
            Map<String, String> mapOfSerialVsPdtReqId = new Map<String, String>();
            ParamsWrapper params = new ParamsWrapper();
            
            params.soWrapList = soWrapList; 
            params = processInputList(params);
            for(Giic_CommonWrapper.SalesOrderLine sol : params.solList){
                pdtReqIdSet.add(sol.ProductRequiredID);
                mapOfSerialVsPdtReqId.put(sol.batchNumber,sol.ProductRequiredID);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfSerialVsPdtReqId: ' + mapOfSerialVsPdtReqId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ fslWOSet: ' + params.fslWOSet);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ pdtReqIdSet: ' + pdtReqIdSet);

            Map<Id,gii__SalesOrderLine__c> mapOfIdVsSOL = new Map<Id,gii__SalesOrderLine__c>([
                SELECT Id, gii__SalesOrder__c, gii__SalesOrderLine__c.giic_ProductRequiredId__c, gii__Product__c, gii__SalesOrder__r.gii__Warehouse__c, gii__SalesOrder__r.gii__Warehouse__r.gii__DefaultIssueLocation__c 
                FROM gii__SalesOrderLine__c 
                WHERE   gii__SalesOrder__r.giic_FSLWorkOrder__c IN :params.fslWOSet             AND 
                        gii__SalesOrder__r.giic_FSLWorkOrderLineItem__c IN :params.fslWOLSet    AND 
                        giic_ProductRequiredId__c IN:pdtReqIdSet 
            ]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfIdVsSOL: ' + mapOfIdVsSOL);

            if(mapOfIdVsSOL != null && !mapOfIdVsSOL.values().isEmpty()){
                params = processSOL(mapOfIdVsSOL);
                Map<Id,gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD = new Map<Id,gii__ProductInventoryQuantityDetail__c>([
                    SELECT giic_Reserved__c,giic_Status__c, gii__MovableQuantity__c,gii__ProductSerial__c, gii__Blockedquantity__c,   gii__ProductLot__r.gii__Restricted__c, gii__ProductLot__c,  gii__LotRestricted__c, gii__ProductInventory__c,  gii__ProductInventorybyLocation__c,  gii__RestrictedQuantity__c, gii__ReservedQuantity__c,gii__OnHandQuantity__c, gii__Available__c,gii__Location__c, gii__Warehouse__c, gii__Product__c 
                    FROM gii__ProductInventoryQuantityDetail__c 
                    WHERE   gii__Product__c IN: params.pdtIdSet     AND 
                            gii__Location__c IN: params.locIdSet    AND 
                            gii__Warehouse__c IN: params.whIdSet    AND
                            gii__ProductSerial__c != null
                ]);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfIdVsPIQD: ' + mapOfIdVsPIQD);
                params = processPIQD(mapOfIdVsPIQD,mapOfSerialVsPdtReqId,params.mapOfPdtReqIdVsSol);
                callGloviaApisAndUpdate(params);
            }
        }
    }

    /**
    * @author FirstName : Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method reserves and ships the inventory reserves
    * @param params ParamsWrapper  
    *@return ParamsWrapper
    */  
    private static ParamsWrapper processInputList(ParamsWrapper params) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In processInputList');
        for(Giic_CommonWrapper.SalesOrderHeader soObj : params.soWrapList){
            if(soObj.FSLWorkOrder != null){
                params.fslWOSet.add(soObj.FSLWorkOrder);
            }
            if(soObj.FSLWorkOrderLineItem != null){
                params.fslWOLSet.add(soObj.FSLWorkOrderLineItem); 
            }
            params.solList.addAll(soObj.SalesOrderLineList);
        }
        return params;
    }

    /**
    * @author FirstName : Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method reserves and ships the inventory reserves
    * @param params ParamsWrapper 
    */ 
    public static void callGloviaApisAndUpdate(ParamsWrapper params){
        if(!params.lstPIQDToSendForInv.isEmpty()){
            gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultObj1 = doInventoryAdjustments(params.lstPIQDToSendForInv);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listInventoryReserve: ' + params.listInventoryReserve);
        if(!params.listInventoryReserve.isEmpty()){
            gii.DirectReservation.DirectReservationResult resultObj = soDirectReserveAndShip(params.listInventoryReserve);
        }
        if(!params.lstPIQDUpdate.isEmpty() && Schema.sObjectType.gii__ProductInventoryQuantityDetail__c.isUpdateable()){
            update params.lstPIQDUpdate;
        }
    }

    /**
    * @author FirstName : Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method reserves and ships the inventory reserves
    * @param mapOfIdVsSOL Map<Id,gii__SalesOrderLine__c>  
    *@return ParamsWrapper
    */ 
    public static ParamsWrapper processSOL(Map<Id,gii__SalesOrderLine__c> mapOfIdVsSOL){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In processSOL');
        ParamsWrapper params = new ParamsWrapper();
        for(gii__SalesOrderLine__c solObj : mapOfIdVsSOL.values()){
            params.pdtIdSet.add(solObj.gii__Product__c);
            if(solObj.gii__SalesOrder__r.gii__Warehouse__c != null){
                params.whIdSet.add(solObj.gii__SalesOrder__r.gii__Warehouse__c);
            }
            if(solObj.gii__SalesOrder__r.gii__Warehouse__r.gii__DefaultIssueLocation__c != null){
                params.locIdSet.add(solObj.gii__SalesOrder__r.gii__Warehouse__r.gii__DefaultIssueLocation__c);
            }
            params.mapOfPdtReqIdVsSol.put(solObj.giic_ProductRequiredId__c,solObj);
        }
        return params;
    }
    
    /**
    * @author FirstName : Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method reserves and ships the inventory reserves
    * @param listInventoryReserve List<gii__InventoryReserve__c>  
    *@return gii.DirectReservation.DirectReservationResult
    */    
    @TestVisible
    private static gii.DirectReservation.DirectReservationResult soDirectReserveAndShip(List<gii__InventoryReserve__c> listInventoryReserve){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In soDirectReserveAndShip');
        // Input object for reservation creation
        gii.DirectReservation.inputDirectReservation inputObj = new gii.DirectReservation.inputDirectReservation();
        inputObj.listInvReserve = listInventoryReserve;
        inputObj.Action = 'ReserveandShip';  
        inputObj.ShippedDate = system.today();  //Specify shipment date

        // Output for DirectReservationResult and execute direct reservation and quick ship method
        gii.DirectReservation.DirectReservationResult resultObj = new gii.DirectReservation.DirectReservationResult();
        resultObj = gii.DirectReservation.CreateReservationandQuickShip(inputObj);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ resultObj for CreateReservationandQuickShip: ' + resultObj);    
        return resultObj;
    }

    /**
    * @author FirstName : Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method updates PIQDs
    * @param mapOfIdVsPIQD Map<Id,gii__ProductInventoryQuantityDetail__c> 
    * @param mapOfSerialVsPdtReqId Map<String,String>  
    * @param mapOfPdtReqIdVsSol Map<String,gii__SalesOrderLine__c> 
    *@return ParamsWrapper
    */        
    public static ParamsWrapper processPIQD(Map<Id, gii__ProductInventoryQuantityDetail__c> mapOfIdVsPIQD, Map<String, String> mapOfSerialVsPdtReqId, Map<String, gii__SalesOrderLine__c> mapOfPdtReqIdVsSol) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In processPIQD');
        ParamsWrapper params = new ParamsWrapper();
        Integer countToReserve = 0;
        for(gii__ProductInventoryQuantityDetail__c piqdObj : mapOfIdVsPIQD.values()) {
            params = processPIQDhelper(piqdObj,params,countToReserve);
        }
        params.mapOfPdtReqIdVsSol = mapOfPdtReqIdVsSol;
        params.mapOfSerialVsPdtReqId = mapOfSerialVsPdtReqId;
        if(countToReserve > 0 && params.mapOfSerialVsReservedPIQD.values().size() >= countToReserve){
            for(Integer i=0 ; i<countToReserve ; i++){
                params.lstPIQDUpdate.add(new gii__ProductInventoryQuantityDetail__c(
                    Id=params.lstPIQDUpdate[i].Id,
                    giic_Reserved__c = 0,
                    giic_Status__c = null,
                    gii__Location__c = params.lstPIQDUpdate[i].gii__Location__c
                ));
            }
        }
        return params;
    }

    /**
    * @author FirstName : Rishabh Bansal
    * @date Creation 07/08/2019
    * @description Giic_GoodsIssueSO – This method is helper to processPIQD method.
    * @param piqdObj gii__ProductInventoryQuantityDetail__c   
    * @param params ParamsWrapper 
    * @param countToReserve Integer 
    *@return ParamsWrapper
    */       
    public static ParamsWrapper processPIQDhelper(gii__ProductInventoryQuantityDetail__c piqdObj, ParamsWrapper params, Integer countToReserve){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In processPIQDhelper');
        String pdtReqId = params.mapOfSerialVsPdtReqId.get(piqdObj.gii__ProductSerial__c);
        if(params.mapOfPdtReqIdVsSol.keySet().contains(pdtReqId)){
            gii__SalesOrderLine__c tempSOL = params.mapOfPdtReqIdVsSol.get(pdtReqId);
            piqdObj.gii__OnHandQuantity__c = piqdObj.giic_Reserved__c;
            gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
            ir.gii__SalesOrderLine__c = tempSOL.Id;
            ir.gii__ProductInventoryQuantityDetail__c = piqdObj.Id;
            //ir.gii__ReserveQuantity__c = 1.0;  

            if(piqdObj.giic_Status__c == Label.giic_PIQDStatusReserve){
                // If Status Reserve:
                params.lstPIQDToSendForInv.add(piqdObj);
                params.lstPIQDUpdate.add(new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = 0,giic_Status__c = null,gii__Location__c = piqdObj.gii__Location__c,id=piqdObj.id));
                params.listInventoryReserve.add(ir);
            } else if(piqdObj.giic_Status__c != Label.giic_PIQDStatusReserve && piqdObj.giic_Status__c != Label.giic_PIQDStatusShipped){
                // If Status is not Reserve/Shipped:
                params.lstPIQDToSendForInv.add(piqdObj);
                params.lstPIQDUpdate.add(new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = 0,giic_Status__c = null,gii__Location__c = piqdObj.gii__Location__c,id=piqdObj.id));
                params.listInventoryReserve.add(ir);
                XC_UTIL_Debug.debug(DEBUGACTIVE, ' listInventoryReserve-->>111' + params.listInventoryReserve);
                countToReserve++;
            }
        } else if(piqdObj.giic_Status__c == Label.giic_PIQDStatusReserve && !params.mapOfPdtReqIdVsSol.keySet().contains(pdtReqId)){
            params.mapOfSerialVsReservedPIQD.put(piqdObj.gii__ProductSerial__c,piqdObj);
        }
        return params;
    }

    /**
    * @author FirstName : Pradeep  Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description - This method  performs Inventory Adjustements
    * @param lstPIQDToSendForInv List<gii__ProductInventoryQuantityDetail__c>  
    *@return gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult
    */   
    public static gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult doInventoryAdjustments(List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInv){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In doInventoryAdjustment');
        gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultObj = new gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult();
        if(!lstPIQDToSendForInv.isEmpty()){
            gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails quantityDetailsObj = new gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails();
            quantityDetailsObj.listProductInventoryQuantityDetails = lstPIQDToSendForInv;
            quantityDetailsObj.AdjustmentDate = system.today();                
            resultObj = gii.InventoryAdjustmentforLocation.CreateInventoryAdustments(quantityDetailsObj);
        }
        return resultObj;
    }

    /**
    * @author Glovia Team
    * @description - This method create Soft Reservation Inv Adj
    * @param lstPIQDToSendForInv List<gii__ProductInventoryQuantityDetail__c>  
    *@return gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult
    */ 
    public static gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult doInventoryAdjustmentsSoft(List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInv){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In doInventoryAdjustmentSoft');
        gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultObj = new gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult();
        if(!lstPIQDToSendForInv.isEmpty()){
            gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails quantityDetailsObj = new gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails();
            quantityDetailsObj.listProductInventoryQuantityDetails = lstPIQDToSendForInv;
            quantityDetailsObj.AdjustmentDate = system.today();  
            quantityDetailsObj.AdjustmentReason = 'Soft Reservation';                   
            resultObj = gii.InventoryAdjustmentforLocation.CreateInventoryAdustments(quantityDetailsObj); 
        }
        return resultObj;
    }
    
    /**
    * @author FirstName : Pradeep  Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description clear back order quantity for Product inventory for receipt case, 
    * @param reserveWrap List<giic_ReservationUtility.ReservationWrapper>   
    *@param mapProductInventory map<Id,gii__ProductInventory__c> 
    */    
    public static void clearBackOrderQty(List<giic_ReservationUtility.ReservationWrapper> reserveWrap, Map<Id, gii__ProductInventory__c> mapProductInventory) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In clearBackOrderQty');
        reserveQuantitiesInFuture(JSON.serialize(reserveWrap));
        update mapProductInventory.values();
    }

    /**
    * @author FirstName : Pradeep  Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description clear back order quantity for Product inventory for PO
    * @param reserveWrap reservation wrapper
    * @param mapProductInventory map of product inventory
    */    
    public static void clearBackOrderQtyPO(List<giic_ReservationUtility.ReservationWrapper> reserveWrap, Map<Id, gii__ProductInventory__c> mapProductInventory) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In clearBackOrderQtyPO');
        reserveQuantities(reserveWrap);
        if(Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
            update mapProductInventory.values();
        }
    }

    /**
    * @author FirstName : Pradeep  Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 29/07/2019
    * @description clear back order quantity for Product inventory using future
    * @param reserveWrapJSON reserve wrap
    */ 
    @Future
    public static void reserveQuantitiesInFuture(string reserveWrapJSON) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In reserveQuantitiesInFuture');
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap = (List<giic_ReservationUtility.ReservationWrapper>)JSON.deserialize(reserveWrapJSON,List<giic_ReservationUtility.ReservationWrapper>.class);
        reserveQuantities(reserveWrap);
    }
    
}
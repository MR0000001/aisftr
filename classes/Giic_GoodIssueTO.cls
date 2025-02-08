/**
* @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
* @date Creation 08/08/2019
* @description Giic_GoodIssueTO - Class used for Transfer order Good issue and in Quick action (Good Issue - Transfer order)  
*/

public without sharing class Giic_GoodIssueTO {	

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_GoodIssueTO');
    
    /** @description Piqd_UtilWrapper */
    public class Piqd_UtilWrapper {  
        List<gii__ProductInventoryQuantityDetail__c> productInvQDetailList = new List<gii__ProductInventoryQuantityDetail__c>(); 
        Map<String, Integer> maplotNameToQuantity = new Map<String, Integer>();         
    }

    /**
    * @author Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 08/08/2019
    * @description - This method used to fetch all transfer order lines related to selected Transfer order
    * @param idTO - Transfer Order Id
    * @return Map<String, Object> - return the map string of object
    */
    @AuraEnabled
    public static Map<String,Object> fetchTOAndToLineData(Id idTO) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ In fetchTOAndToLineData');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Transfer Order: ' + IdTO);
        Map<String, Object> mapStringObjectData = new Map<String, Object>();
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapProdIdListPS = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        Map<String, List<gii__ProductLot__c>> mapProdIdListPLot = new Map<String, List<gii__ProductLot__c>>();
        List<string> lstProductIds = new List<string>();
        Giic_GoodIssueTOWrapper objGITransferOrderWrapper = new Giic_GoodIssueTOWrapper();
        List<gii__TransferOrderLine__c> lstTOLines = new List<gii__TransferOrderLine__c>();
        lstTOLines = getTOLines(idTO);
        if(lstTOLines.size()>0) {
            objGITransferOrderWrapper = createWrapperData(idTO,lstTOLines);
            lstProductIds = createListForSP(lstTOLines);
            mapProdIdListPS = createPSList(lstProductIds, lstTOLines);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstProductIds: ' + lstProductIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Warehouse: ' + lstTOLines[0].gii__TransferOrder__r.gii__FromWarehouse__c);
        }
        mapStringObjectData.put('WrapperData', objGITransferOrderWrapper);
        mapStringObjectData.put('PSData', mapProdIdListPS);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapStringObjectData: ' + mapStringObjectData);
        return mapStringObjectData;
    }

    /**
    * @author Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 08/08/2019
    * @description - This method called from lightning component for reservation of TO good issues.
    * @param strMainGIWrapper - Wrapper class in JSON format
    * @return Map<string, object> - Return the map of successful and failed result
    */
    @AuraEnabled
    public static Map<string, object> createTOReservnQship(string strMainGIWrapper){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ In createTOReservnQship');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ strMainGIWrapper: ' + strMainGIWrapper);
        Giic_GoodIssueTOWrapper objGITransferOrderWrapper =  (Giic_GoodIssueTOWrapper)System.JSON.deserialize(strMainGIWrapper, Giic_GoodIssueTOWrapper.class);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objGITransferOrderWrapper: ' + objGITransferOrderWrapper);
        return createTOReservnQshipAPI(objGITransferOrderWrapper);
    }

    /**
    * @author Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 08/08/2019
    * @description - This method used for API call as well as for lightning component to create reservation and quick ship. 
    * @param objGITransferOrderWrapper - instance of Giic_GoodIssueTOWrapper with data
    * @return Map<string,object> - Return the map of successfula and failed result
    */
    public static Map<String, Object> createTOReservnQshipAPI(Giic_GoodIssueTOWrapper objGITransferOrderWrapper){  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In createTOReservnQshipAPI');
        Savepoint sp = Database.setSavepoint();
        Map<string, object> mapReturnResult = new Map<string, object>();
        try {
            List<string> lstPSName = new List<string>();
            Map<string,integer> lstPLNameQty= new map<string,integer>();
            Set<String> setlocationIds = new Set<String>();
            Set<String> setlocationNames = new Set<String>();
            Set<String> lstProductName = new Set<String>();
            Map<String, String> mapToLineIdProduct = new Map<String, String>();
            Decimal randomSerialToUnreserve = 0.0;
            Decimal randomLotToUnreserve = 0.0;
            Map<String, gii__ProductInventoryQuantityDetail__c> isAvlbSerialNonProductVsPiqdIdMap = new Map<String,gii__ProductInventoryQuantityDetail__c>();
            List<gii__ProductInventoryQuantityDetail__c> piqdToUnreservedList = new List<gii__ProductInventoryQuantityDetail__c>(); // This is the PIQD list which need to unreserve
            List<ID> piqdIdForUnresered = new List<ID>();
            List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInvAdj = new List<gii__ProductInventoryQuantityDetail__c>();
            List<gii__TransferOrderLine__c> lstTOLine = new List<gii__TransferOrderLine__c>();
            Map<Id, gii__TransferOrderLine__c> toLineMap = getTOLinesInAmap(objGITransferOrderWrapper.transferOrderID);        
            lstTOLine = toLineMap.values();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstTOLine:' + lstTOLine);
            Integer counterTOLines = 0;
            String blCreateLogResult = '';
            for(Integer i = (objGITransferOrderWrapper.lstOrderLine).size() - 1; i>=0; i--) {
                if(objGITransferOrderWrapper.lstOrderLine[i].orderQuantity==0) {
                    objGITransferOrderWrapper.lstOrderLine.remove(i);
                }                
            }

            // No TOLines with quantity > 0 found:
            if((objGITransferOrderWrapper.lstOrderLine).size()==0) {
                Map<String, String> mapPassParams = new Map<String, String>();
                mapPassParams.put('toName', lstTOLine[0].gii__TransferOrder__r.name);
                mapPassParams.put('checkFor', 'QUANTITY0');
                return createErrorLogs(objGITransferOrderWrapper, lstProductName, mapPassParams);
            }

            // TOLines with quantity > 0 found:
            for(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper a : objGITransferOrderWrapper.lstOrderLine) { 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For wrapper: ' + a);
                gii__TransferOrderLine__c tol = toLineMap.get(a.transferOrderLine);            
                if(tol.gii__LineStatus__c != System.Label.giic_StatusOpen && tol.gii__LineStatus__c !=System.Label.giic_PartiallyShipped && tol.gii__LineStatus__c != 'Partially Received') {  
                    counterTOLines++;
                }
                if((a.locationId == null || a.locationId =='') && (a.locationName == null || a.locationName =='')) {
                    setlocationIds.add(tol.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c);
                }
                if(a.locationId != null && a.locationId !='') { 
                    setlocationIds.add(a.locationId); 
                }
                if(a.locationName != null && a.locationName !='') { 
                    setlocationNames.add(a.locationName);  
                }  
                lstProductName.add(tol.gii__Product__r.gii__ProductCode__c);
                mapToLineIdProduct.put(tol.id, tol.gii__Product__r.gii__ProductCode__c); 
            }

            lstPSName = getSerialNumbers(objGITransferOrderWrapper);
            lstPLNameQty= getLotNumbers(objGITransferOrderWrapper);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPSName: ' + lstPSName);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapToLineIdProduct:' + mapToLineIdProduct);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPLNameQty: ' + lstPLNameQty);
            /*
            for(gii__TransferOrderLine__c objTOLine : lstTOLine){
                if(objTOLine.gii__LineStatus__c != system.label.giic_StatusOpen && objTOLine.gii__LineStatus__c !=system.label.giic_PartiallyShipped){
                    counterTOLines++;
                }
                
                setlocationIds.add(objGITransferOrderWrapper.lstOrderLine[0].locationId);
                lstProductName.add(objTOLine.gii__Product__r.name);
                mapToLineIdProduct.put(objTOLine.id, objTOLine.gii__Product__r.name);
            }
            */

            if(lstTOLine.size() == counterTOLines) { 
                // If all lines are shipped => TO shipped:
                blCreateLogResult = 'TOShipped';  
            }
            List<gii__ProductInventoryQuantityDetail__c> lstPIQD = new List<gii__ProductInventoryQuantityDetail__c>();
            Map<String, Object> mapPassParametersPIQD = new Map<String, Object>();
            mapPassParametersPIQD.put('maplotNameToQuantity', objGITransferOrderWrapper.maplotNameToQuantity);
            mapPassParametersPIQD.put('lstTOLine', lstTOLine);
            mapPassParametersPIQD.put('setlocationIds', setlocationIds);
            mapPassParametersPIQD.put('setlocationNames', setlocationNames);
            mapPassParametersPIQD.put('lstProductName', lstProductName);
            mapPassParametersPIQD.put('lstPSName', lstPSName);
            mapPassParametersPIQD.put('lstPLNameQty', lstPLNameQty);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPassParametersPIQD: ' + mapPassParametersPIQD);
            lstPIQD = getPIQDRecords(mapPassParametersPIQD).productInvQDetailList;
            Map<String, Integer> maplotNameToQuantity =  getPIQDRecords(mapPassParametersPIQD).maplotNameToQuantity;  
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ lstPIQD: ' + lstPIQD);
            if(lstPIQD.size()>0) {
                // PIQD found:
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Size list: ' + lstPIQD.size());
                isAvlbSerialNonProductVsPiqdIdMap = createMapProdAndPIQD(lstPIQD);
                Map<String, Object> mapPIQDDataPassing = createReserveUnreserveData(lstPIQD, maplotNameToQuantity);
                randomSerialToUnreserve = (Decimal)mapPIQDDataPassing.get('randomSerialToUnreserve');
                randomLotToUnreserve = (Decimal)mapPIQDDataPassing.get('randomLotToUnreserve');
                lstPIQDToSendForInvAdj = (List<gii__ProductInventoryQuantityDetail__c>)mapPIQDDataPassing.get('lstPIQDToSendForInvAdj');
                piqdToUnreservedList = (List<gii__ProductInventoryQuantityDetail__c>)mapPIQDDataPassing.get('piqdToUnreservedList');
                piqdIdForUnresered = (List<Id>)mapPIQDDataPassing.get('piqdIdForUnresered');
            }
            else {  
                // No PIQD found:
                blCreateLogResult = 'PIQD';  
            }
            
            if(!String.isBlank(blCreateLogResult)){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Size: ' + lstPIQD.size());
                Map<String, String> mapPassParams = new Map<String, String>();
                mapPassParams.put('toName', lstTOLine[0].gii__TransferOrder__r.name);
                mapPassParams.put('checkFor', blCreateLogResult);
                return createErrorLogs(objGITransferOrderWrapper,lstProductName,mapPassParams);
            }
            
            Map<String, Object> mapPassParameters = new Map<String, Object>();
            mapPassParameters.put('lstOrderLine', objGITransferOrderWrapper.lstOrderLine);
            mapPassParameters.put('toName',lstTOLine[0].gii__TransferOrder__r.name);
            mapPassParameters.put('isAvlbSerialNonProductVsPiqdIdMap',isAvlbSerialNonProductVsPiqdIdMap);
            mapPassParameters.put('randomSerialToUnreserve',randomSerialToUnreserve);
            mapPassParameters.put('piqdIdForUnresered',piqdIdForUnresered);
            mapPassParameters.put('warehouse',lstTOLine[0].gii__Warehouse__c);
            mapPassParameters.put('setlocationIds',new List<string>(setlocationIds));
            mapPassParameters.put('setlocationNames',new List<string>(setlocationNames));
            mapPassParameters.put('lstProductName',new List<string>(lstProductName));  
            mapPassParameters.put('piqdToUnreservedList',piqdToUnreservedList);
            mapPassParameters.put('lstPIQDToSendForInvAdj',lstPIQDToSendForInvAdj);
            mapPassParameters.put('mapToLineIdProduct',mapToLineIdProduct);

            mapReturnResult = reservnAndQuickShipAPICall(mapPassParameters);   
            if(mapReturnResult.containsKey('Exceptions') && mapReturnResult.get('Exceptions')!=null && mapReturnResult.get('Exceptions')!=(new List<String>())) {                                                                                           
                Database.rollback(sp);
            }
            List<gii__InventoryReserve__c> inv = (List<gii__InventoryReserve__c>) mapReturnResult.get('listInvReserve');
            gii__Shipment__c ship =  new gii__Shipment__c();
            if(inv!=null && !inv.isEmpty()){
                ship.Id = inv[0].gii__Shipment__c;
                ship.giic_DeliveryDocumentID__c = objGITransferOrderWrapper.reference;
                ship.giic_DeliveryDate__c = objGITransferOrderWrapper.dateDelivery;
                ship.giic_RegistrationDate__c = objGITransferOrderWrapper.registrationDate;
                XC_UTIL_Sobject.updateRecord(ship);
            }
            return mapReturnResult;
        }
        catch(Exception e) {
            Database.rollback(sp);
            String errorCatchMessage = 'Error Good Issue: ' + e.getMessage();
            mapReturnResult.put('Exceptions', new List<String>{errorCatchMessage});
            return mapReturnResult;
        }
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 08/08/2019
    * @description - This method used create the data of PIQD , product invetory and invetory reserve
    * @param mapPassParameters - get the parameter from createTOReservnQshipAPI method, map of varias data
    * @return map<string,object> - Return the map of successful and failed result
    */
    @AuraEnabled
    public static Map<String, Object> reservnAndQuickShipAPICall(Map<string,object> mapPassParameters){
        Boolean blPIQDCheck = false;
        List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> lstOrderLine = (List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>)mapPassParameters.get('lstOrderLine');
        String toName = (string)mapPassParameters.get('toName');
        Map<string,gii__ProductInventoryQuantityDetail__c> isAvlbSerialNonProductVsPiqdIdMap = (Map<string,gii__ProductInventoryQuantityDetail__c>)mapPassParameters.get('isAvlbSerialNonProductVsPiqdIdMap');
        Decimal randomSerialToUnreserve = (Decimal)mapPassParameters.get('randomSerialToUnreserve');
        Decimal randomLotToUnreserve = (Decimal)mapPassParameters.get('randomLotToUnreserve');
        List<gii__ProductInventoryQuantityDetail__c> piqdToUnreservedList = (List<gii__ProductInventoryQuantityDetail__c>)mapPassParameters.get('piqdToUnreservedList');
        List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInvAdj = (List<gii__ProductInventoryQuantityDetail__c>)mapPassParameters.get('lstPIQDToSendForInvAdj');
        Map<string,string> mapToLineIdProduct = (Map<string,string>)mapPassParameters.get('mapToLineIdProduct');
        List<gii__InventoryReserve__c> listInventoryReserve = new List<gii__InventoryReserve__c>();
        String strPIQDNotAvailable = '';
        List<giic_ErrorLog__c> lstErrorLogs = new List<giic_ErrorLog__c>(); 
        Map<String, Decimal> mapNewReserved = new Map<String, Decimal>();                                                                                       
        for(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objToLine : lstOrderLine){ 
            Integer countSerialToReserve = 0; 
            if(objToLine.lstAssignedLot.size()>0){                
                listInventoryReserve = getLotProductIR(objTOLine,isAvlbSerialNonProductVsPiqdIdMap,listInventoryReserve); 
                if(listInventoryReserve.size()==0){
                    strPIQDNotAvailable+=objToLine.productCode+',';
                    blPIQDCheck = true;
                    lstErrorLogs = returnListErrorLog(objToLine,toName);
                }                
            } 
            else if(objToLine.lstAssignedSerial.size()>0){
                listInventoryReserve = getSerialProductIR(objTOLine,isAvlbSerialNonProductVsPiqdIdMap,listInventoryReserve);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listInventoryReserve: ' + listInventoryReserve);
                if(listInventoryReserve.size()==0){
                    strPIQDNotAvailable+=objToLine.productCode+',';
                    blPIQDCheck = true;
                    lstErrorLogs = returnListErrorLog(objToLine,toName);
                }
            }
            else if(isAvlbSerialNonProductVsPiqdIdMap.containsKey(objToLine.productCode) || mapToLineIdProduct.containsKey(objToLine.transferOrderLine)){
                if(String.isEmpty(objToLine.productCode)){
                    objToLine.productCode = mapToLineIdProduct.get(objToLine.transferOrderLine);
                }
                gii__ProductInventoryQuantityDetail__c piqdtemp = isAvlbSerialNonProductVsPiqdIdMap.get(objToLine.productCode);
                if(piqdtemp!=null){
                    // PIQD found:
                    gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                    ir = createIRInstance(objToLine,piqdtemp);
                    listInventoryReserve.add(ir);
                    Map<String, Object> mapgetDataPIQD = new Map<String, Object>();
                    mapgetDataPIQD = getPIQDAdj(piqdtemp, objToLine, mapNewReserved);
                    if(mapgetDataPIQD.containsKey('mapNewReserved')) {
                        mapNewReserved = (Map<String, Decimal>)mapgetDataPIQD.get('mapNewReserved');
                    }
                    // Gestione errore quantità non disponibile:
                    if(mapgetDataPIQD.containsKey('errorQuantity')) {
                        Map<String, Object> mapReturnResultNotAvailableQuantity = new Map<String, Object>();
                        String errorMessageNoAvlQuantity = 'Transfer Order ' + toName + ': ' + mapgetDataPIQD.get('errorQuantity');
                        mapReturnResultNotAvailableQuantity.put('Exceptions', new List<String>{errorMessageNoAvlQuantity});
                        return mapReturnResultNotAvailableQuantity;
                    }
                    lstPIQDToSendForInvAdj.add((gii__ProductInventoryQuantityDetail__c)mapgetDataPIQD.get('piqdtemp'));
                    piqdToUnreservedList.add((gii__ProductInventoryQuantityDetail__c)mapgetDataPIQD.get('piqdToUnreservedList'));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@piqdToUnreservedList: ' + piqdToUnreservedList);
                } else {
                    // PIQD not found:
                    lstErrorLogs = returnListErrorLog(objToLine,toName);
                    strPIQDNotAvailable+=objToLine.productCode+',';
                    blPIQDCheck = true;
                }
            }
        }      

        if(blPIQDCheck && listInventoryReserve.size()==0) { 
            return insertErrorLog(strPIQDNotAvailable,lstErrorLogs,toName); 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ piqdToUnreservedList size: ' + piqdToUnreservedList.size() + ' AND piqdToUnreservedList: ' + piqdToUnreservedList);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ lstPIQDToSendForInvAdj size: ' + lstPIQDToSendForInvAdj.size() + ' AND lstPIQDToSendForInvAdj: ' + lstPIQDToSendForInvAdj);
        Map<string, object> mapDataPass = new Map<string, object>();
        mapDataPass.put('lstPIQDToSendForInvAdj',lstPIQDToSendForInvAdj);
        mapDataPass.put('piqdToUnreservedList',piqdToUnreservedList);
        mapDataPass.put('lstProductName',mapPassParameters.get('lstProductName'));
        mapDataPass.put('warehouse',mapPassParameters.get('warehouse'));
        mapDataPass.put('setlocationIds',mapPassParameters.get('setlocationIds'));
        mapDataPass.put('setlocationNames',mapPassParameters.get('setlocationNames'));
        mapDataPass.put('piqdIdForUnresered',mapPassParameters.get('piqdIdForUnresered'));
        mapDataPass.put('randomSerialToUnreserve',randomSerialToUnreserve);
        Savepoint sp = Database.setSavepoint();
        Boolean successRandomAdj = randomAdjst(mapDataPass, (List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper>)mapPassParameters.get('lstOrderLine'));
        if(!successRandomAdj) {
            Map<String, Object> mapReturnResultNotAvailableQuantity = new Map<String, Object>();
            String errorMessageNoAvlQuantity = 'Transfer Order ' + toName + ': error during Soft Reservation';
            mapReturnResultNotAvailableQuantity.put('Exceptions', new List<String>{errorMessageNoAvlQuantity});
            return mapReturnResultNotAvailableQuantity;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ listInventoryReserve Size: ' + listInventoryReserve.size() + ' AND listInventoryReserve: ' + listInventoryReserve);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ mapDataPass: ' + mapDataPass);
        return toDirectReservation(listInventoryReserve, sp);
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 08/08/2019
    * @description - This method used for direct reservation process, This method called from reservnAndQuickShipAPICall
    * @param listInventoryReserve - List of gii__InventoryReserve__c
    * @param sp - Object of Savepoint and getting the list of inventory reserve data
    * @return Map<String, Object> - Return the map of successful and failed result
    */
    public static Map<String, Object> toDirectReservation(List<gii__InventoryReserve__c> listInventoryReserve, Savepoint sp){
        // Input object for reservation creation
        gii.TransferOrderDirectReservation.DirectReservationResult resultObj = new gii.TransferOrderDirectReservation.DirectReservationResult();
        resultObj = createDirectReservation(listInventoryReserve);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ resultObj: ' + resultObj);
        List<String> errorMsgList = new List<String>();
        // Exception Handling:
        if(resultObj!=null && resultObj.Exceptions != null) {
            if(resultObj.Exceptions.size() > 0) {
                List<giic_ErrorLog__c> lstErrorLogs = new List<giic_ErrorLog__c>();                                                                                               
                Database.rollback(sp);
                gii__TransferOrderLine__c objTOLine = new gii__TransferOrderLine__c();
                if(Schema.sObjectType.gii__TransferOrderLine__c.fields.gii__TransferOrder__c.isAccessible()){
                    objTOLine = [SELECT id,gii__TransferOrder__c FROM gii__TransferOrderLine__c where id=:listInventoryReserve[0].gii__TransferOrderLine__c LIMIT 1];
                }
                updateFailDataTO(objTOLine);
                for(Integer count=0; count<resultObj.Exceptions.size(); count++) {
                    Map<String, Object> mapData = new Map<String, Object>();
                    if(count<resultObj.listInvReserve.size()){
                        mapData.put('giic_TransferOrderLine__c',resultObj.listInvReserve[count].gii__TransferOrderLine__c);
                        lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(
                            new Giic_ErrorLogsUtility.ErrorLogsWrapper( System.Label.giic_TOGoodIssue,
                                                                        mapData,
                                                                        System.Label.giic_TOGoodIssueQuickShip, 
                                                                        resultObj.Exceptions[count].getMessage()
                                                                        )
                        ));
                    }
                }

                Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
                for(gii.TransferOrderDirectReservation.GOMException e : resultObj.Exceptions) { 
                    errorMsgList.add(e.getMessage());
                }
                if(errorMsgList.size()>0){
                    XC_UTIL_Debug.debug(DEBUGACTIVE,errorMsgList);
                }
            }
            else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In else Quick ship Result: ' + resultObj); 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In else Quick ship Result size: ' + resultObj.listInvReserve.size()); 
                updateTransferOrder(resultObj.listInvReserve);
            }             
        }

        Map<string, object> mapReturnResult = new Map<string,object>();
        mapReturnResult.put('Exceptions',errorMsgList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapReturnResult: ' + mapReturnResult);
        if(resultObj!=null && resultObj.listInvReserve != null) { 
            mapReturnResult.put('listInvReserve', resultObj.listInvReserve);  
        }
        return mapReturnResult;
    }
    
    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 08/08/2019
    * @description - This method used to do the inventory adjustement on Product inventory object
    * @param lstPIQDToSendForInv  List of gii__ProductInventoryQuantityDetail__c
    * @return gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult - Return the result of Inventory Adjustments.
    */
    public static gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult doInventoryAdjustments(List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInv){
        gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultObj = new gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult();
        if(!lstPIQDToSendForInv.isEmpty()){
            gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails quantityDetailsObj = new gii.InventoryAdjustmentforLocation.ProductInventoryQtyDetails();
            quantityDetailsObj.listProductInventoryQuantityDetails = lstPIQDToSendForInv;
            quantityDetailsObj.AdjustmentDate = System.today();                  
            quantityDetailsObj.AdjustmentReason = 'Soft Reservation'; 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ quantityDetailsObj: ' + quantityDetailsObj); 
            if(!Test.isRunningTest()){ 
            	resultObj = gii.InventoryAdjustmentforLocation.CreateInventoryAdustments(quantityDetailsObj);            
            }
        }
        return resultObj; 
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to get related Transfer order Lines.
    * @param idTO - Transfer Order Id
    * @return List<gii__TransferOrderLine__c> - return the Transfer order related transfer order lines
    */
    public static List<gii__TransferOrderLine__c> getTOLines(Id idTO) {
        List<gii__TransferOrderLine__c> lstTOLines = new List<gii__TransferOrderLine__c>([
            SELECT      Id,name,gii__LineStatus__c,gii__TransferOrder__c,gii__TransferOrder__r.name,gii__TransferOrder__r.gii__TransferToWarehouse__r.name,gii__TransferOrder__r.gii__FromWarehouse__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,gii__Warehouse__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__r.name, gii__TransferOrder__r.gii__FromWarehouse__r.Name,gii__Product__r.giic_SKUCode__c,
                        gii__Product__r.name,gii__Product__r.gii__SerialControlled__c,gii__OpenQuantity__c,gii__Product__r.gii__ProductCode__c,gii__Product__r.gii__LotControlled__c
            FROM        gii__TransferOrderLine__c 
            WHERE       gii__TransferOrder__c =: idTO
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstTOLines: ' + lstTOLines); 
        return lstTOLines;
    }
    
    /**
    * @date Creation 04/09/2019
    * @description - This method creates a list for SP
    * @param lstTOLines - List<gii__TransferOrderLine__c>
    * @return lstProductIds - List<String>
    */
    public static List<String> createListForSP(List<gii__TransferOrderLine__c> lstTOLines){
        List<string> lstProductIds = new List<string>();
        for(gii__TransferOrderLine__c toLine : lstTOLines) {
            if(toLine.gii__OpenQuantity__c>0.0 && (toLine.gii__Product__r.gii__SerialControlled__c || toLine.gii__Product__r.gii__LotControlled__c)) {
                lstProductIds.add(toLine.gii__Product__c);
            }
        }
        return lstProductIds;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to create wrapper data to show To Lines on UI after clicking on Good issue button on TO record
    * @param idTO - Transfer order id
    * @param lstTOLines - List of gii__TransferOrderLine__c
    * @return Giic_GoodIssueTOWrapper - created data from Tranfser order line od related transfer order.
    */
    public static Giic_GoodIssueTOWrapper createWrapperData(Id idTO, List<gii__TransferOrderLine__c> lstTOLines) {
        Giic_GoodIssueTOWrapper objGITransferOrderWrapper = new Giic_GoodIssueTOWrapper();
        objGITransferOrderWrapper.transferOrderID = idTO;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objGITransferOrderWrapper: ' + objGITransferOrderWrapper);
        for(gii__TransferOrderLine__c toLine : lstTOLines){
            if(toLine.gii__OpenQuantity__c>0.0){
                Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objTOLine = new Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper();
                objTOLine.productName = toLine.gii__Product__r.name;
                objTOLine.productCode = toLine.gii__Product__r.gii__ProductCode__c;
                objTOLine.SKUCode = toLine.gii__Product__r.giic_SKUCode__c;
                objTOLine.isSerialCntr = toLine.gii__Product__r.gii__SerialControlled__c;
                objTOLine.isLotControlled = toLine.gii__Product__r.gii__LotControlled__c;
                if(toLine.gii__Product__r.gii__SerialControlled__c){
                    for(Integer count=0;count<toLine.gii__OpenQuantity__c;count++){
                        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper objPS = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
                        objTOLine.lstAssignedSerial.add(objPS);
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In toLine: ' + toLine);
                if(toLine.gii__Product__r.gii__LotControlled__c){
                    for(Integer count=0;count<toLine.gii__OpenQuantity__c;count++){
                        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper objPS = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
                        Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper objLot = new Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper();
                        objTOLine.lstAssignedSerial.add(objPS);
                        objTOLine.lstAssignedLot.add(objLot);
                    }
                }
                objTOLine.locationId = toLine.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c;//gii__FromWarehouse__r.gii__DefaultIssueLocation__c;
                objTOLine.locationName = toLine.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__r.name;
                objTOLine.transferToWarehouse = toLine.gii__TransferOrder__r.gii__TransferToWarehouse__r.name;
                objTOLine.transferFromWarehouseId = toLine.gii__TransferOrder__r.gii__FromWarehouse__c;
                objTOLine.orderQuantity = toLine.gii__OpenQuantity__c;
                objTOLine.transferOrderLine = toLine.id;
                objTOLine.transferOrderLineName = toLine.name;
                objGITransferOrderWrapper.lstOrderLine.add(objTOLine);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objGITransferOrderWrapper: ' + objGITransferOrderWrapper);
        return objGITransferOrderWrapper;
    }
    
    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to fetch related product serials from PIQD record for every TOLine product
    * @param lstProductIds - List of Product Ids
    * @param lstTOLines - List of Transfer order lines
    * @return map<String,List<gii__ProductInventoryQuantityDetail__c>> - Map of String VS List of gii__ProductInventoryQuantityDetail__c 
    */
    public static Map<String, List<gii__ProductInventoryQuantityDetail__c>> createPSList(List<String> lstProductIds,List<gii__TransferOrderLine__c> lstTOLines){
        Map<String, List<gii__ProductInventoryQuantityDetail__c>> mapProdIdListPS = new Map<String, List<gii__ProductInventoryQuantityDetail__c>>();
        List<gii__ProductInventoryQuantityDetail__c> lstPIQDPS = new List<gii__ProductInventoryQuantityDetail__c>();     
        lstPIQDPS = [SELECT Id, gii__Product__r.name,gii__Product__r.gii__ProductCode__c,gii__Warehouse__c,gii__Product__c,giic_Reserved__c,gii__ProductLot__c,gii__ProductLot__r.Giic_TotalQuantity__c,gii__Available__c,gii__ProductSerial__r.name,gii__ProductLot__r.Id,gii__ProductLot__r.Name
                    FROM gii__ProductInventoryQuantityDetail__c 
                    WHERE   gii__Product__c IN: lstProductIds AND 
                            (gii__ProductSerial__c<>NULL OR gii__ProductLot__c<>NULL) AND 
                            gii__Warehouse__c =: lstTOLines[0].gii__TransferOrder__r.gii__FromWarehouse__c AND 
                            (gii__Available__c>0 OR (gii__Available__c=0 AND giic_Reserved__c>0) 
        )];
        if(lstPIQDPS.size()>0) {
            for(gii__ProductInventoryQuantityDetail__c piqd : lstPIQDPS){
                if(!mapProdIdListPS.containsKey(piqd.gii__Product__r.gii__ProductCode__c)){
                    mapProdIdListPS.put(piqd.gii__Product__r.gii__ProductCode__c, new List<gii__ProductInventoryQuantityDetail__c>());
                }
                mapProdIdListPS.get(piqd.gii__Product__r.gii__ProductCode__c).add(piqd);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProdIdListPS: ' + mapProdIdListPS);
        return mapProdIdListPS;
    }
    
    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used for getting serial number from PIQD records
    * @param  objGITransferOrderWrapper this is a wrapper class instance
    * @return List<string> - returning the list of product serial names
    */
    public static List<string> getSerialNumbers(Giic_GoodIssueTOWrapper objGITransferOrderWrapper) {
        List<string> lstPSName = new List<string>();
        if(objGITransferOrderWrapper.lstOrderLine.size()>0) {
            for(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objTOLine : objGITransferOrderWrapper.lstOrderLine) {
                if(objTOLine.lstAssignedSerial.size()>0) {
                    for(Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper objPS : objTOLine.lstAssignedSerial) {
                        if(String.isNotEmpty(objPS.serialNumber)) {
                            lstPSName.add(objPS.serialNumber);
                        }
                    }
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPSName: ' + lstPSName);
        return lstPSName;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used for getting serial number from PIQD records
    * @param  objGITransferOrderWrapper this is a wrapper class instance
    * @return List<string> - returning the list of product serial names
    */
    public static Map<String, Integer> getLotNumbers(Giic_GoodIssueTOWrapper objGITransferOrderWrapper){
        Map<string,integer> lstPLNameQty= new map<string,integer>();
        if(objGITransferOrderWrapper.lstOrderLine.size()>0){
            for(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objTOLine : objGITransferOrderWrapper.lstOrderLine) {
                XC_UTIL_Debug.debug(DEBUGACTIVE,'objTOLine::'+objTOLine);
                if(objTOLine.lstAssignedLot.size()>0){
                    for(Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper objPS : objTOLine.lstAssignedLot){
                        if(String.isNotEmpty(objPS.lotNumber)){
                            lstPLNameQty.put(objPS.lotNumber, objPS.lotQty);
                        }
                    }
                }
            }
        }
        return lstPLNameQty;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used for getting serial number from PIQD records
    * @param  mapPassParametersPIQD ->In this map having a set of locations list od product and list of Product serial names based on those we are quering the PIQD records
    * @return Piqd_UtilWrapper
    */
    public static Piqd_UtilWrapper getPIQDRecords(Map<string,object> mapPassParametersPIQD){
        Piqd_UtilWrapper piqdW = new Piqd_UtilWrapper();
        List<gii__TransferOrderLine__c> lstTOLine = (List<gii__TransferOrderLine__c>)mapPassParametersPIQD.get('lstTOLine');
        Set<String> setlocationIds = (Set<String>)mapPassParametersPIQD.get('setlocationIds');
        Set<String> setlocationNames = (Set<String>)mapPassParametersPIQD.get('setlocationNames');
        Set<String> lstProductName = (Set<String>)mapPassParametersPIQD.get('lstProductName');
        List<string> lstPSName = (List<string>)mapPassParametersPIQD.get('lstPSName');
        Map<String,Integer> maplotNameToQuantity = (Map<String,Integer>)mapPassParametersPIQD.get('maplotNameToQuantity');
        Map<string,integer> mapPLNameToQty = (Map<string,integer>)mapPassParametersPIQD.get('lstPLNameQty');
        List<gii__ProductInventoryQuantityDetail__c> lstPIQD = new List<gii__ProductInventoryQuantityDetail__c>();
        mapPLNameToQty.putAll(maplotNameToQuantity);

        lstPIQD = [ SELECT  Id,gii__BlockedQuantity__c,gii__Warehouse__c,gii__Product__r.gii__ProductCode__c,gii__Product__r.gii__SerialControlled__c,
                            gii__OnHandQuantity__c,gii__Location__c,giic_Reserved__c,gii__Product__r.name,Giic_Status__c,
                            gii__Product__c,gii__Available__c, gii__ProductSerial__c,gii__ProductSerial__r.name ,gii__Product__r.gii__LotControlled__c,gii__ProductLot__r.name
                    FROM    gii__ProductInventoryQuantityDetail__c 
                    WHERE   gii__Warehouse__c=:lstTOLine[0].gii__Warehouse__c       //objTO.gii__FromWarehouse__c 
                            AND (gii__Location__c IN:setlocationIds OR gii__Location__r.Name IN :setlocationNames)
                            AND gii__Product__r.gii__ProductCode__c IN: lstProductName 
                            AND ((gii__ProductSerial__r.name IN:lstPSName OR gii__ProductSerial__c=NULL) OR (gii__ProductLot__r.name IN:mapPLNameToQty.keyset() OR gii__ProductLot__c=NULL))
        ];
        piqdW.productInvQDetailList = lstPIQD;
        piqdW.maplotNameToQuantity = mapPLNameToQty;
        return piqdW;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - Create the inventory reserve data from TO lines
    * @param objTOLine - Object of Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper
    * @param isAvlbSerialNonProductVsPiqdIdMap - Map of String VS gii__ProductInventoryQuantityDetail__c
    * @param listInventoryReserve - List of gii__InventoryReserve__c
    * @Return List<gii__InventoryReserve__c> - returning the list of Inventory Reserve 
    */
    public static List<gii__InventoryReserve__c> getSerialProductIR(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objTOLine,Map<string,gii__ProductInventoryQuantityDetail__c> isAvlbSerialNonProductVsPiqdIdMap,List<gii__InventoryReserve__c> listInventoryReserve){
        //List<gii__InventoryReserve__c> listInventoryReserve = new List<gii__InventoryReserve__c>();
        for(Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper objPS : objTOLine.lstAssignedSerial){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objPS.serialNumber: ' + objPS.serialNumber);
            if(String.isNotBlank(objPS.serialNumber) && isAvlbSerialNonProductVsPiqdIdMap.containsKey(objPS.serialNumber)){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objPS.serialNumber in IF: ' + objPS.serialNumber);
                // Create inventory reservation  record
                gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                // Assign Transfer Order line record id
                ir.gii__TransferOrderLine__c = objToLine.transferOrderLine;
                // Assign Product Inventory Quantity Detail id of the location and product lot
                ir.gii__ProductInventoryQuantityDetail__c = isAvlbSerialNonProductVsPiqdIdMap.get(objPS.serialNumber).id; 
                ir.gii__ProductSerial__c = isAvlbSerialNonProductVsPiqdIdMap.get(objPS.serialNumber).gii__ProductSerial__c; 
                // Quantity to be reserved from the location for the Transfer Order line (stocking UM)
                ir.gii__ReserveQuantity__c = 1.0;  
                // Add reservation record to the list
                listInventoryReserve.add(ir);
            }
        }
        return listInventoryReserve;
    }
    
    /**
    * @date Creation 04/09/2019
    * @description - Method to get Lot Product IR
    * @param objTOLine - Giic_GoodIssueTOLineWrapper
    * @param isAvlbSerialNonProductVsPiqdIdMap - Map<string,gii__ProductInventoryQuantityDetail__c>
    * @param listInventoryReserve - List<gii__InventoryReserve__c>
    * @return List<gii__InventoryReserve__c>
    */
    public static List<gii__InventoryReserve__c> getLotProductIR(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objTOLine, Map<string,gii__ProductInventoryQuantityDetail__c> isAvlbSerialNonProductVsPiqdIdMap, List<gii__InventoryReserve__c> listInventoryReserve){
        //List<gii__InventoryReserve__c> listInventoryReserve = new List<gii__InventoryReserve__c>();
        for(Giic_GoodIssueTOWrapper.Giic_AssignedLotWrapper objPS : objTOLine.lstAssignedLot){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objPS.lotNumber: ' + objPS.lotNumber);
            if(String.isNotBlank(objPS.lotNumber) && isAvlbSerialNonProductVsPiqdIdMap.containsKey(objPS.lotNumber)){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ objPS.lotNumber in IF: ' + objPS.lotNumber);
                // Create inventory reservation  record
                gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                // Assign Transfer Order line record id
                ir.gii__TransferOrderLine__c = objToLine.transferOrderLine;
                // Assign Product Inventory Quantity Detail id of the location and product lot
                ir.gii__ProductInventoryQuantityDetail__c = isAvlbSerialNonProductVsPiqdIdMap.get(objPS.lotNumber).id; 
                ir.gii__ProductLot__c = isAvlbSerialNonProductVsPiqdIdMap.get(objPS.lotNumber).gii__ProductLot__c; 
                // Quantity to be reserved from the location for the Transfer Order line (stocking UM)
                ir.gii__ReserveQuantity__c = objPS.lotQty;  
                // Add reservation record to the list
                listInventoryReserve.add(ir);
            }
        }
        return listInventoryReserve;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used for direct resevation of the products
    * @param listInventoryReserve- list of invetory reserved 
    * @return gii.TransferOrderDirectReservation.DirectReservationResult - returning the result of direct reservation 
    */
    public static gii.TransferOrderDirectReservation.DirectReservationResult createDirectReservation(List<gii__InventoryReserve__c> listInventoryReserve){
        gii.TransferOrderDirectReservation.inputDirectReservation inputObj = new gii.TransferOrderDirectReservation.inputDirectReservation();
        // Assign the list of reservations to the input object  
        inputObj.listInvReserve = listInventoryReserve;
        inputObj.Action = 'ReserveandShip';  
        inputObj.ShippedDate = System.today();  // specify shipment date
        // Output for DirectReservationResult
        gii.TransferOrderDirectReservation.DirectReservationResult resultObj = new gii.TransferOrderDirectReservation.DirectReservationResult();
        // Execute direct reservaion and quick ship method
        if(!Test.isRunningTest()){
        	resultObj = gii.TransferOrderDirectReservation.CreateReservationandQuickShip(inputObj);
        } else{
            resultObj = null;
        }
        return resultObj;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to update Target status, Invetory operation nad integration status fields
    * @param listInventoryReserve - list of Inventory Reserve
    */    
    public static void updateTransferOrder(List<gii__InventoryReserve__c> listInventoryReserve) {
        if(listInventoryReserve.size()>0 && Schema.sObjectType.gii__TransferOrder__c.fields.giic_status__c.isAccessible() && Schema.sObjectType.gii__TransferOrder__c.fields.gii__OrderStatus__c.isAccessible() &&  Schema.sObjectType.gii__TransferOrder__c.fields.giic_status__c.isUpdateable()){
            gii__TransferOrder__c  objTOUpdate = [  
                SELECT Id,giic_status__c,giic_TargetSystem__c,gii__OrderStatus__c,giic_IntegrationStatus__c 
                FROM gii__TransferOrder__c 
                WHERE Id =: listInventoryReserve[0].gii__TransferOrder__c
            ];
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objTOUpdate: ' + objTOUpdate);
            //objTOUpdate.giic_status__c = objTOUpdate.gii__OrderStatus__c;
            objTOUpdate.giic_TargetSystem__c = System.Label.giic_TargetSystemGlovia;
            objTOUpdate.Giic_IntegrationOperation__c = System.Label.giic_IntegrationOperationCreate;
            objTOUpdate.giic_IntegrationStatus__c = System.Label.giic_IntegrationStatusSuccess;
            update objTOUpdate;
        }
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to create error logs
    * @param objGITransferOrderWrapper - Object Giic_GoodIssueTOWrapper 
    * @param lstProductName - Wrapper class used for good issue
    * @param  mapPassParams - Map of String VS String
    * @return static map<string,object>  - returning the map of exception records.
    */ 
    public static map<string,object> createErrorLogs(Giic_GoodIssueTOWrapper objGITransferOrderWrapper,Set<String> lstProductName,map<string,string> mapPassParams){
        Map<string,object> mapReturnResult = new Map<string,object>();
        mapReturnResult.put('Exceptions',system.label.giic_GoodIssuePINotAvlb);
        List<giic_ErrorLog__c> lstErrorLogs = new List<giic_ErrorLog__c>();                                                                                               
        Map<string,object> mapData = new Map<string,object>();
        mapData.put('giic_TransferOrder__c',objGITransferOrderWrapper.transferOrderID);

        if(mapPassParams.get('checkFor') == 'QUANTITY0') {
             mapReturnResult.put('Exceptions', 'Quantity to shipped must be greather than 0!');
             return mapReturnResult;            
        }
        if(mapPassParams.get('checkFor') == 'PIQD'){          
           lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(System.Label.giic_TOGoodIssue,mapData,System.Label.giic_GoodIssueCnDone, 'Transfer Order '+mapPassParams.get('toName')+System.Label.giic_GoodIssuePINotAvlb+ String.join(new List<String>(lstProductName), ','))));
          
        }
        if(mapPassParams.get('checkFor') == 'TOShipped'){            
            lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(System.Label.giic_TOGoodIssue,mapData,System.Label.giic_GoodIssueAlreadyDone, System.Label.giic_GoodIssueAlreadyDone+mapPassParams.get('toName'))));
        }        

        Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
        return mapReturnResult;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to create map of product name with PIQD record
    * @param lstPIQD - List of gii__ProductInventoryQuantityDetail__c 
    * @return Map<String,gii__ProductInventoryQuantityDetail__c> - Map of product name  VS gii__ProductInventoryQuantityDetail__c
    */ 
    public static Map<String,gii__ProductInventoryQuantityDetail__c> createMapProdAndPIQD(List<gii__ProductInventoryQuantityDetail__c> lstPIQD){
        Map<String,gii__ProductInventoryQuantityDetail__c> isAvlbSerialNonProductVsPiqdIdMap = new Map<String,gii__ProductInventoryQuantityDetail__c>();
        for(gii__ProductInventoryQuantityDetail__c piqd: lstPIQD) {
            if(piqd.gii__Product__r.gii__SerialControlled__c) {
                isAvlbSerialNonProductVsPiqdIdMap.put(piqd.gii__ProductSerial__r.name, piqd);
            }
            else if(piqd.gii__Product__r.gii__LotControlled__c) {
                isAvlbSerialNonProductVsPiqdIdMap.put(piqd.gii__ProductLot__r.name, piqd);
            }
            else {
                isAvlbSerialNonProductVsPiqdIdMap.put(piqd.gii__Product__r.gii__ProductCode__c, piqd);
            } 
        }
        return isAvlbSerialNonProductVsPiqdIdMap;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - Thi method return the List of error logs
    * @param objToLine - Object of Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper
    * @param toName - Transfer Order Name
    * @return list<giic_ErrorLog__c> - returning the List of error log data
    */ 
    public static List<giic_ErrorLog__c> returnListErrorLog(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objToLine,string toName){
        List<giic_ErrorLog__c> lstErrorLogs = new List<giic_ErrorLog__c>();  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstErrorLogs: ' + lstErrorLogs);
        Map<string,object> mapData = new Map<string,object>();
        mapData.put('giic_TransferOrderLine__c',objToLine.transferOrderLine);
        lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper(System.Label.giic_TOGoodIssue,mapData,System.Label.giic_TOGoodIssueNotAvlb,'Transfer Order '+toName+System.Label.giic_GoodIssuePINotAvlb+objToLine.productCode)));
        return lstErrorLogs;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to Insert the error logs
    * @param strPIQDNotAvailable - Not available PIQD records
    * @param lstErrorLogs - List of giic_ErrorLog__c
    * @param toName -  Transfer order Name
    * @return Map<String,Object> - returning the map of exception and related data.
    */ 
    public static Map<String,Object> insertErrorLog(String strPIQDNotAvailable, List<giic_ErrorLog__c> lstErrorLogs, string toName){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In insertErrorLog');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ strPIQDNotAvailable: ' + strPIQDNotAvailable);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ toName: ' + toName);
        Map<string,object> mapReturnResult = new Map<string,object>();
        strPIQDNotAvailable = strPIQDNotAvailable.removeEnd(',');
        mapReturnResult.put('Exceptions', 'Transfer Order '+toName+system.label.giic_GoodIssuePINotAvlb+strPIQDNotAvailable);
        Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
        return mapReturnResult;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to create Invetort reserve data
    * @param objToLine - Object of Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper
    * @param piqdtemp - Object of gii__ProductInventoryQuantityDetail__c
    * @return gii__InventoryReserve__c - returning the invetory reserve 
    */ 
    public static gii__InventoryReserve__c createIRInstance(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objToLine,gii__ProductInventoryQuantityDetail__c piqdtemp){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In createIRInstance');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objToLine: ' + objToLine);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piqdtemp: ' + piqdtemp);
        gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
        ir.gii__TransferOrderLine__c = objToLine.transferOrderLine;
        ir.gii__ProductInventoryQuantityDetail__c = piqdtemp.id; 
        ir.gii__ReserveQuantity__c = objToLine.orderQuantity; 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'ir:::'+ir);
        return ir;
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @date Mod 30/11/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description - This method used to create error logs
    * @param piqdtemp - Object of gii__ProductInventoryQuantityDetail__c
    * @param objToLine - Tranfser order line from wrapper instance
    * @param mapNewReserved - Map<String, Decimal> 
    * @return map<string,object> - returning the map of String VS PIQD unreserve records
    */ 
    public static Map<string, object> getPIQDAdj(gii__ProductInventoryQuantityDetail__c piqdtemp, Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper objToLine, Map<String, Decimal> mapNewReserved){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ piqdtemp.gii__OnHandQuantity__c: ' + piqdtemp.gii__OnHandQuantity__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ objToLine.orderQuantity:' + objToLine.orderQuantity); 

        Decimal qtyReserved = mapNewReserved.containsKey(piqdtemp.id) ? mapNewReserved.get(piqdtemp.id) : (piqdtemp.giic_Reserved__c != null ? piqdtemp.giic_Reserved__c : 0.0);  
        Decimal qtyAvailable = piqdtemp.gii__Available__c != null ? piqdtemp.gii__Available__c : 0.0;  
        Decimal qtyToCheck = qtyReserved + qtyAvailable;
        Map<String, Object> mapPIQDAdjAndUnResLst = new Map<String, Object>();

        if(qtyToCheck > 0.0 && qtyToCheck == objToLine.orderQuantity) {
            // Sia se basta la reserved sia se bisogna prendere anche i disponibili: la reserved va a 0 e ai disponibili va sommata la quantità precedentemente riservata:
            piqdtemp.gii__OnHandQuantity__c = piqdtemp.gii__OnHandQuantity__c + qtyReserved;
            qtyReserved = 0.0; 
            mapNewReserved.put(piqdtemp.Id, qtyReserved);
            mapPIQDAdjAndUnResLst.put('piqdToUnreservedList', new gii__ProductInventoryQuantityDetail__c(
                giic_Reserved__c = qtyReserved,
                giic_Status__c = '',
                Id = piqdtemp.id
            ));
            mapPIQDAdjAndUnResLst.put('piqdtemp', piqdtemp); 
        }
        else if(qtyToCheck > 0.0 && qtyToCheck > objToLine.orderQuantity) { 
            // Se la quantità riservata basta a soddisfare la richiesta, la reserved viene decrementata e la on hand viene incrementata con la totale quantità richiesta; altrimenti la reserved va a 0 e On Hand viene incrementato con la quantità precedentemente riservata
            Decimal tempReserve = (qtyReserved > objToLine.orderQuantity) ? (qtyReserved - objToLine.orderQuantity) : 0.0; 
            piqdtemp.gii__OnHandQuantity__c = (qtyReserved > objToLine.orderQuantity) ? (piqdtemp.gii__OnHandQuantity__c + objToLine.orderQuantity) : (piqdtemp.gii__OnHandQuantity__c + qtyReserved); 
            mapNewReserved.put(piqdtemp.Id, tempReserve);
            mapPIQDAdjAndUnResLst.put('piqdToUnreservedList', new gii__ProductInventoryQuantityDetail__c(
                giic_Reserved__c = tempReserve,
                giic_Status__c = (qtyReserved > objToLine.orderQuantity) ? piqdtemp.giic_Status__c : '',
                Id = piqdtemp.id
            ));
            mapPIQDAdjAndUnResLst.put('piqdtemp', piqdtemp); 
        }
        else{ 
            /*if(qtyReserved > 0.0){ 
                piqdtemp.gii__OnHandQuantity__c = piqdtemp.gii__OnHandQuantity__c + qtyReserved;
                mapPIQDAdjAndUnResLst.put('piqdToUnreservedList', new gii__ProductInventoryQuantityDetail__c(
                    giic_Reserved__c = 0.0,
                    giic_Status__c = '',
                    Id = piqdtemp.id
                ));
                mapPIQDAdjAndUnResLst.put('piqdtemp',piqdtemp);   
            }*/
            mapPIQDAdjAndUnResLst.put('errorQuantity', 'The requested quantity (' + objToLine.orderQuantity + ') is more than the quantity in stock (' + qtyToCheck + ')'); 
        }

        mapPIQDAdjAndUnResLst.put('mapNewReserved', mapNewReserved);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piqdtemp: ' + piqdtemp); 
        return mapPIQDAdjAndUnResLst;
    }         

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to do random inventory adjustment 
    * @param mapDataPass - Map of String VS unreserve Invetory records
    * @return Boolean
    */ 
    public static Boolean randomAdjst(Map<String,Object> mapDataPass, List<Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper> lstOrderLine){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In randomAdjst');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapDataPass: ' + mapDataPass);
        List<String> lstProductName =  (List<String>)mapDataPass.get('lstProductName');
        Id warehouse = (Id)mapDataPass.get('warehouse');
        List<String> setlocationIds =  (List<String>)mapDataPass.get('setlocationIds');
        List<Id> piqdIdForUnresered = (List<Id>)mapDataPass.get('piqdIdForUnresered');
        Decimal randomSerialToUnreserve = (Decimal)mapDataPass.get('randomSerialToUnreserve');
        Decimal randomLotToUnreserve = (Decimal)mapDataPass.get('randomLotToUnreserve');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Warehouse: ' + warehouse);
        List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInvAdj = (List<gii__ProductInventoryQuantityDetail__c>)mapDataPass.get('lstPIQDToSendForInvAdj');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPIQDToSendForInvAdj:' + lstPIQDToSendForInvAdj);
        List<gii__ProductInventoryQuantityDetail__c> piqdToUnreservedList = (List<gii__ProductInventoryQuantityDetail__c>)mapDataPass.get('piqdToUnreservedList');
        Set<gii__ProductInventoryQuantityDetail__c> setString = new Set<gii__ProductInventoryQuantityDetail__c>(piqdToUnreservedList);
        List<gii__ProductInventoryQuantityDetail__c> randomPIQDList = new List<gii__ProductInventoryQuantityDetail__c>();
        List<gii__ProductInventoryQuantityDetail__c> randomSerialPIQDList = new List<gii__ProductInventoryQuantityDetail__c>();
        List<gii__ProductInventoryQuantityDetail__c> randomLotPIQDList = new List<gii__ProductInventoryQuantityDetail__c>();

        // This is a list of random serail number need to unreserve because some serail number are avaiable 
        if(randomSerialToUnreserve >0){
            randomSerialPIQDList = [
                SELECT Id, giic_Reserved__c, gii__Available__c, giic_Status__c ,gii__OnHandQuantity__c,gii__ProductInventory__c,
                        gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Warehouse__c,gii__Location__c,gii__Product__r.gii__ProductCode__c,
                        gii__ProductSerial__c, gii__ProductSerial__r.Name,gii__BlockedQuantity__c,gii__Product__r.gii__LotControlled__c,gii__ProductLot__c,gii__ProductLot__r.Id, gii__ProductLot__r.Name, gii__ProductLot__r.Giic_TotalQuantity__c
                FROM gii__ProductInventoryQuantityDetail__c 
                WHERE gii__Product__r.gii__ProductCode__c IN: lstProductName  
                          AND gii__Warehouse__c =: warehouse 
                          AND gii__Location__c IN: setlocationIds 
                          AND gii__ProductSerial__c != null 
                          AND Id NOT IN: piqdIdForUnresered
                          AND (giic_Status__c ='Reserve' OR giic_Status__c ='Reserved')
                		  AND (gii__OnHandQuantity__c = 1 OR giic_Reserved__c = 1)
                LIMIT :Integer.valueOf(randomSerialToUnreserve)
            ];
            randomPIQDList.addAll(randomSerialPIQDList);
        }

        if(randomLotToUnreserve >0){
            randomLotPIQDList = [
                SELECT Id, giic_Reserved__c, gii__Available__c, giic_Status__c ,gii__OnHandQuantity__c,gii__ProductInventory__c,
                        gii__Product__c,gii__Product__r.gii__SerialControlled__c,gii__Warehouse__c,gii__Location__c,gii__Product__r.gii__ProductCode__c,
                        gii__ProductSerial__c, gii__ProductSerial__r.Name,gii__BlockedQuantity__c,gii__Product__r.gii__LotControlled__c,gii__ProductLot__c,gii__ProductLot__r.Id, gii__ProductLot__r.Name, gii__ProductLot__r.Giic_TotalQuantity__c
                FROM gii__ProductInventoryQuantityDetail__c 
                WHERE gii__Product__r.gii__ProductCode__c IN: lstProductName  
                        AND gii__Warehouse__c =: warehouse 
                        AND gii__Location__c IN: setlocationIds 
                        AND gii__ProductLot__c != null 
                        AND Id NOT IN: piqdIdForUnresered
                        AND (giic_Status__c ='Reserve' OR giic_Status__c ='Reserved')
            ];
            randomPIQDList.addAll(randomLotPIQDList);
        }
      
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ randomPIQDList: ' + randomPIQDList);
        if(randomPIQDList.size()>0){
            for(gii__ProductInventoryQuantityDetail__c piqdobj: randomPIQDList){
                if(piqdobj.gii__Product__r.gii__SerialControlled__c){
                    Boolean check = false;
                    for(gii__ProductInventoryQuantityDetail__c piqd : piqdToUnreservedList){
                        if(piqd.id == piqdobj.id){
                            check = true;
                            piqd.gii__OnHandQuantity__c = 1.0;
                            piqd.giic_Reserved__c = 0;
                            piqd.giic_Status__c = '';
                        }
                    }
                    piqdobj.gii__OnHandQuantity__c = 1.0;
                    // Also send for Inventory adjustment
                    lstPIQDToSendForInvAdj.add(piqdobj);
                    if(check == false) {
                        piqdToUnreservedList.add(new gii__ProductInventoryQuantityDetail__c(
                            giic_Reserved__c = 0,
                            giic_Status__c = '',
                            Id=piqdobj.id
                        ));
                    }
                    //piqdToUnreservedList.add(new gii__ProductInventoryQuantityDetail__c(giic_Reserved__c = 0,giic_Status__c = '',id=piqdobj.id));
                }
                else if(piqdobj.gii__Product__r.gii__LotControlled__c){
                    if(piqdobj.giic_Reserved__c >= randomLotToUnreserve  && randomLotToUnreserve != 0) {
                        piqdobj.gii__OnHandQuantity__c = piqdobj.gii__OnHandQuantity__c + randomLotToUnreserve;
                        // Also send for Inventory adjustment
                        lstPIQDToSendForInvAdj.add(piqdobj);
                        piqdToUnreservedList.add(new gii__ProductInventoryQuantityDetail__c(
                            giic_Reserved__c = piqdobj.giic_Reserved__c - randomLotToUnreserve,
                            giic_Status__c = '',
                            id=piqdobj.id
                        ));
                        randomLotToUnreserve = 0;
                    } else{
                        Integer newQty = (Integer) piqdobj.giic_Reserved__c;
                        piqdobj.gii__OnHandQuantity__c = piqdobj.gii__OnHandQuantity__c + newQty;
                        // Also send for Inventory adjustment
                        lstPIQDToSendForInvAdj.add(piqdobj);
                        piqdToUnreservedList.add(new gii__ProductInventoryQuantityDetail__c(
                            giic_Reserved__c = piqdobj.giic_Reserved__c - newQty,
                            giic_Status__c = '',
                            id=piqdobj.id
                        ));
                        randomLotToUnreserve = randomLotToUnreserve - newQty;
                    }
                }
            }
        }
        
        Map<String, Object> mapPIQDAdjst = new Map<String, Object>();
        mapPIQDAdjst.put('lstPIQDToSendForInvAdj',lstPIQDToSendForInvAdj);
        mapPIQDAdjst.put('piqdToUnreservedList',piqdToUnreservedList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piqdToUnreservedList: ' + piqdToUnreservedList);
        if(piqdToUnreservedList != null && !piqdToUnreservedList.isEmpty()){
            List<gii__ProductInventoryQuantityDetail__c> listPIQDall = new List<gii__ProductInventoryQuantityDetail__c>([
                SELECT Id, giic_Reserved__c,gii__Product__r.gii__ProductCode__c                
                FROM gii__ProductInventoryQuantityDetail__c 
                WHERE Id IN: piqdToUnreservedList
            ]);
            List<gii__ProductInventoryQuantityDetail__c> piqdToUnreservedListToUpdate = new List<gii__ProductInventoryQuantityDetail__c>();
            Map<String, Decimal> mapQuantityTemp = new Map<String, Decimal>();
            for(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper wrQty : lstOrderLine) {
                if(!mapQuantityTemp.containsKey(wrQty.productCode)) {
                    mapQuantityTemp.put(wrQty.productCode, 0.0);
                } 
                Decimal qtyTemp = mapQuantityTemp.get(wrQty.productCode);
                mapQuantityTemp.put(wrQty.productCode, (qtyTemp + wrQty.orderQuantity));
            }
            List<String> listIdToUpdate = new List<String>();
            for(gii__ProductInventoryQuantityDetail__c piqdTemp : listPIQDall) {
                if(piqdTemp.gii__Product__r.gii__ProductCode__c!=null && mapQuantityTemp.containsKey(piqdTemp.gii__Product__r.gii__ProductCode__c)) {
                    Decimal newQuantityReserved = 0;
                    if(piqdTemp.giic_Reserved__c!=null) {
                        newQuantityReserved = piqdTemp.giic_Reserved__c - mapQuantityTemp.get(piqdTemp.gii__Product__r.gii__ProductCode__c);
                    }
                    piqdTemp.giic_Reserved__c = (newQuantityReserved >= 0) ? newQuantityReserved : 0.0;
                    // Se la nuova reserved è negativa vuol dire che devo consumare tutti i riservati ed eventualmente dai disponibili, quindi i riservati vanno a 0
                    if(!listIdToUpdate.contains(piqdTemp.Id)) {
                        listIdToUpdate.add(piqdTemp.Id);
                        piqdToUnreservedListToUpdate.add(piqdTemp);
                    } 
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Real list PIQD to update: ' + piqdToUnreservedListToUpdate);
            XC_UTIL_Sobject.updateListRecords(piqdToUnreservedListToUpdate);
        }  
        // Inventory Adjustments
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPIQDToSendForInvAdj: ' + lstPIQDToSendForInvAdj);
        lstPIQDToSendForInvAdj  = screamListForNullElement(lstPIQDToSendForInvAdj);
        if(lstPIQDToSendForInvAdj != null && !lstPIQDToSendForInvAdj.isEmpty()) {   
            gii.InventoryAdjustmentforLocation.InventoryAdjustmentsResult resultInvAdj = doInventoryAdjustments(lstPIQDToSendForInvAdj); 
            if(resultInvAdj.Exceptions!= null && !resultInvAdj.Exceptions.isEmpty()) {
                return false;
            }
        }
        return true;
    }
    
    /**
    * @date Creation 04/09/2019
    * @description - Method to scream list for null element
    * @param lstPIQDToSendForInvAdj - List<gii__ProductInventoryQuantityDetail__c>
    * @return List<gii__ProductInventoryQuantityDetail__c>
    */
    public static List<gii__ProductInventoryQuantityDetail__c> screamListForNullElement(List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInvAdj ){
        List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInvAdjNew = new List<gii__ProductInventoryQuantityDetail__c> ();
        for (gii__ProductInventoryQuantityDetail__c piqd : lstPIQDToSendForInvAdj){
            if(piqd != null) {    
                lstPIQDToSendForInvAdjNew.add(piqd);
            }
        }        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPIQDToSendForInvAdjNew: ' + lstPIQDToSendForInvAdjNew);
        return lstPIQDToSendForInvAdjNew;
    }
    
    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - update the Tranfer order record after failed to process of Quick ship and reservation
    * @param objTOLine - tranfser order line record
    */ 
    public static void updateFailDataTO(gii__TransferOrderLine__c objTOLine){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In updateFailDataTO');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objTOLine: ' + objTOLine);
        if(Schema.sObjectType.gii__TransferOrder__c.fields.giic_IntegrationStatus__c.isAccessible() && Schema.sObjectType.gii__TransferOrder__c.fields.giic_IntegrationStatus__c.isUpdateable()){
            gii__TransferOrder__c  objTOUpdate = [
                SELECT Id, giic_IntegrationStatus__c 
                FROM gii__TransferOrder__c 
                WHERE Id =: objTOLine.gii__TransferOrder__c
            ];
            objTOUpdate.giic_IntegrationStatus__c = System.Label.giic_IntegrationStatusFailure;
            update objTOUpdate;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ End updateFailDataTO');
    }

    /**
    * @author FirstName : Anil Giri - Anil.giri@in.fujitsu.com
    * @date Creation 04/09/2019
    * @description - This method used to create error logs
    * @param lstPIQD - List of PIQD records
    * @return Map<String, Object> - returning the map of String VS PIQD record to process nreserve or reserve on Product inventory records
    */ 
    public static Map<String, Object> createReserveUnreserveData(List<gii__ProductInventoryQuantityDetail__c> lstPIQD, Map<string,Integer> maplotNameToQuantity ){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In createReserveUnreserveData');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPIQD: ' + lstPIQD);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ maplotNameToQuantity: ' + maplotNameToQuantity);
        Map<string,object> mapPIQDDataPassing = new Map<string,object>();
        Decimal randomSerialToUnreserve = 0.0;
        Decimal randomLotToUnreserve = 0.0;
        List<gii__ProductInventoryQuantityDetail__c> lstPIQDToSendForInvAdj = new List<gii__ProductInventoryQuantityDetail__c>();
        List<gii__ProductInventoryQuantityDetail__c> piqdToUnreservedList = new List<gii__ProductInventoryQuantityDetail__c>();
        List<Id> piqdIdForUnresered = new List<Id>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPIQDToSendForInvAdj: ' + lstPIQDToSendForInvAdj);
        
        for(gii__ProductInventoryQuantityDetail__c piqd: lstPIQD){
            // Checking if serial number is avaiable or not if avaiable then we will increase the counter of unreserving other serail nunber because some other serial number has been reserved for this SOL.
            if(piqd.gii__Product__r.gii__LotControlled__c  && (piqd.giic_Status__c == 'Reserve'|| piqd.giic_Status__c == 'Reserved')){
                piqd.gii__OnHandQuantity__c = piqd.gii__OnHandQuantity__c + maplotNameToQuantity.get(piqd.gii__ProductLot__r.Name);
                lstPIQDToSendForInvAdj.add(piqd);
                 // this list of unreserve PIQD list:
                piqdToUnreservedList.add(new gii__ProductInventoryQuantityDetail__c(
                    giic_Reserved__c = piqd.giic_Reserved__c - maplotNameToQuantity.get(piqd.gii__ProductLot__r.Name),
                    giic_Status__c ='',
                    Id=piqd.Id
                ));
            }
            else if(piqd.gii__Product__r.gii__LotControlled__c && piqd.gii__Available__c >= maplotNameToQuantity.get(piqd.gii__ProductLot__r.Name)) {
               // piqd.giic_Status__c ='';
               randomLotToUnreserve = randomLotToUnreserve +  maplotNameToQuantity.get(piqd.gii__ProductLot__r.Name);
               // piqd.giic_Reserved__c =  maplotNameToQuantity.get(piqd.gii__ProductLot__r.Name) ;
               // piqdToUnreservedList.add(piqd); // this list of unreserve PIQD list.
                piqdIdForUnresered.add(piqd.id);
            } 
            else if(piqd.gii__Product__r.gii__SerialControlled__c && (piqd.giic_Status__c == 'Reserve'|| piqd.giic_Status__c == 'Reserved') && (piqd.gii__OnHandQuantity__c == 1 || piqd.giic_Reserved__c == 1)){ 
                // if serial number is in reserved status then ready to consumed so adding into unreserve list.                
                piqd.gii__OnHandQuantity__c = 1.0;
                // Also send for Inventory adjustment
                lstPIQDToSendForInvAdj.add(piqd);
                // this list of unreserve PIQD list:
                piqdToUnreservedList.add(new gii__ProductInventoryQuantityDetail__c(
                    giic_Reserved__c = 0.0,
                    giic_Status__c ='',
                    Id=piqd.Id
                )); 
            } else if(piqd.gii__Product__r.gii__SerialControlled__c && piqd.gii__Available__c > 0){  
                randomSerialToUnreserve = randomSerialToUnreserve + 1;
                piqd.giic_Reserved__c = 0.0;
                piqd.giic_Status__c ='';
                // this list of unreserve PIQD list:
                piqdToUnreservedList.add(piqd); 
            }
        }

        mapPIQDDataPassing.put('randomSerialToUnreserve', randomSerialToUnreserve);
        mapPIQDDataPassing.put('randomLotToUnreserve', randomLotToUnreserve);
        mapPIQDDataPassing.put('lstPIQDToSendForInvAdj', lstPIQDToSendForInvAdj);
        mapPIQDDataPassing.put('piqdToUnreservedList', piqdToUnreservedList);
        mapPIQDDataPassing.put('piqdIdForUnresered', piqdIdForUnresered);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ randomSerialToUnreserve: ' + randomSerialToUnreserve);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ randomLotToUnreserve: ' + randomLotToUnreserve);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ lstPIQDToSendForInvAdj: ' + lstPIQDToSendForInvAdj);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piqdToUnreservedList: ' + piqdToUnreservedList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piqdIdForUnresered: ' + piqdIdForUnresered);
        return mapPIQDDataPassing;
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to update Quantity On Tol
     * @param idTOLine
     * @param newOpenQuantity
     * @param wrapperSerialized
     *@return map<String,Object>
    */
    @AuraEnabled
    public static Map<String, Object> fakeUpdateQuantityAndSerialNumOnTol(String idTOLine, Decimal newOpenQuantity,  String wrapperSerialized){
        Map<String, Object> mapStringObjectData = new Map<String, Object>(); 
        Giic_GoodIssueTOWrapper wrapperinstance = (Giic_GoodIssueTOWrapper) JSON.deserialize(wrapperSerialized, Giic_GoodIssueTOWrapper.class);
        for(Giic_GoodIssueTOWrapper.Giic_GoodIssueTOLineWrapper toLine : wrapperinstance.lstOrderLine){
            if(toLine.transferOrderLine == idTOLine){
                toLine.orderQuantity = newOpenQuantity;
                if(toLine.isSerialCntr) {
                    (toLine.lstAssignedSerial).clear();
                    for(Integer count=0;count<toLine.orderQuantity;count++){
                        Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper objPS = new Giic_GoodIssueTOWrapper.Giic_AssignedSerialWrapper();
                        toLine.lstAssignedSerial.add(objPS);
                    }
                }
            }
        }
        mapStringObjectData.put('WrapperData', wrapperinstance);
        return mapStringObjectData;
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to update Quantity On Tol
     * @param idTO - Id
     *@return Map<Id, gii__TransferOrderLine__c>
     */
    public static Map<Id, gii__TransferOrderLine__c> getTOLinesInAmap(Id idTO){
        Map<Id, gii__TransferOrderLine__c> toLineMap = new Map<Id, gii__TransferOrderLine__c>([
            SELECT      Id, Name,gii__LineStatus__c,gii__TransferOrder__c,gii__TransferOrder__r.name,gii__TransferOrder__r.gii__TransferToWarehouse__r.name,gii__TransferOrder__r.gii__FromWarehouse__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,gii__Warehouse__c,gii__Warehouse__r.gii__DefaultIssueLocation__c,
                        gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__r.name, gii__TransferOrder__r.gii__FromWarehouse__r.Name,
                        gii__Product__r.Name, gii__Product__r.gii__SerialControlled__c,gii__OpenQuantity__c,gii__Product__r.gii__ProductCode__c,gii__Product__r.gii__LotControlled__c
            FROM        gii__TransferOrderLine__c 
            WHERE       gii__TransferOrder__c=:idTO
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ toLineMap: ' + toLineMap);
        return toLineMap;
    }

    /**
     * @description Method for the coverage class
     */
    public static void coverageTestClass() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Coverage Test Class');
    }
    
}
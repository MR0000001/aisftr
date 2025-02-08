/**
* @author FirstName : LORENZO ORLANDUCCI
* @date Creation 11/11/2019
* @date Modification dd/mm/yyyy
* @description - 
*/

public without sharing class Giic_LCC002_ProcessDropShip {

private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC002_ProcessDropShip');
 /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description getPurchaseOrderLine
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getPurchaseOrderLine(String purchaseOrderId){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ getPurchaseOrderLine - recordId='+purchaseOrderId);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = false;
        Map<Id, gii__PurchaseOrderLine__c> idPol = new Map<Id, gii__PurchaseOrderLine__c> ([
            SELECT Id,Name,gii__SalesOrderLine__c,gii__SalesOrderLine__r.Name, gii__SalesOrderLine__r.gii__SalesOrder__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c,
            gii__Product__r.Name,gii__ShipTo__c,gii__ShipTo__r.Name,gii__OrderQuantity__c,gii__OpenQuantity__c,gii__ReceivedQuantity__c,gii__StockUM__c,gii__Product__r.gii__LotControlled__c, gii__Product__r.gii__ProductCode__c ,gii__Product__r.giic_SKUCode__c
            FROM gii__PurchaseOrderLine__c 
            WHERE gii__PurchaseOrder__c=:purchaseOrderId /*AND gii__OpenQuantity__c!=0*/]);
        
        if(!idPol.values().isEmpty() ){
            rw.success = true;
            rw.objectInfo = JSON.serialize(idPol.values());
        }
        return rw;
        
    }
    
    
     /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description getPurchaseOrderLine
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkIfCanPress(String purchaseOrderId){
         XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
         rw.success = true;
         Id currentUserId = UserInfo.getProfileId();
         Profile userProfile = [SELECT id,Name FROM Profile where Id =: currentUserId limit 1];
         String userProfileName = userProfile.Name;
         gii__PurchaseOrder__c po = [SELECT Id, gii__ShipTo__c,gii__ShipTo__r.giic_WarehouseType__c, giic_LegalEntity__c FROM gii__PurchaseOrder__c WHERE Id =: purchaseOrderId LIMIT 1];
         if((po.gii__ShipTo__r.giic_WarehouseType__c== 'Central' || po.gii__ShipTo__r.giic_WarehouseType__c== 'Local') && userProfileName.contains('_Supplier') ){
                 rw.success = false;
                 rw.resultMessage = Label.giic_SupplierReceiveError; // *'Warning: Supplier cannot process purchase order receive on Warehouse';
         } 

         /** Addedd for NR2626 */
        List<giic_enable_NR2246__c> cs = giic_enable_NR2246__c.getAll().values();
        Boolean isActiveNR2626 = false;
        for(giic_enable_NR2246__c csett : cs){
            if(csett.LegalEntity__c == po.giic_legalEntity__c){isActiveNR2626 = true; break;}
        }
        rw.NR2626 = isActiveNR2626;
         return rw; 
    }
    

    @AuraEnabled
    public static XC_UTIL_ResultWrapper updatePoLine(Map<String, String>  mapReceivedPolId){
            List<gii__PurchaseOrderLine__c> polToUpdate = new List<gii__PurchaseOrderLine__c> ();              
            XC_UTIL_Debug.debug(DEBUGACTIVE,'Id = '+mapReceivedPolId );
             for(String idPol : mapReceivedPolId.keySet()){
                    gii__PurchaseOrderLine__c pol = new gii__PurchaseOrderLine__c(Id=idPol, gii__ReceivedQuantity__c=Integer.valueOf(mapReceivedPolId.get(idPol)));
                    polToUpdate.add(pol);
             } 
             XC_UTIL_Sobject.WrapperResult updateRes = XC_UTIL_Sobject.updateListRecords(polToUpdate)[0];
             XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper(updateRes);
             return wr; 
    }
        
 
 /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description getPurchaseOrderLine
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createPOReceiptandLine(String purchaseOrderId , List<String> purchaseOrderLineIds, String options, Map<String, String>  mapPolIdToQuantity, Map<String, List<String>> mapPolToSerialList, Map<String,map<String,Integer>> idPOLToLotMap){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = false;
        Savepoint sp = Database.setSavepoint();
        rw.resultMessage = 'Warning: error in creation';
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createPOReceiptandLine con purchaseOrderId = '+purchaseOrderId);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'e purchaseOrderLineIds = '+purchaseOrderLineIds); 
        gii__PurchaseOrder__c po = [SELECT Id, gii__DropShip__c,gii__Supplier__c,gii__Supplier__r.XC_CodeSAP__c, gii__SalesOrder__r.giic_FSLWorkOrder__c,gii__ShipTo__c,gii__SalesOrder__r.gii__Account__c, gii__TotalOpenQuantity__c, giic_RelatedPo__c, giic_RelatedPO__r.name, giic_LegalEntity__c, //NR2626 added giic_LegalEntity__c
                                    (SELECT id,gii__Product__c,gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c,gii__ReceivedQuantity__c,gii__ProductSerial__r.Name
                                     FROM gii__Purchase_Order_Receipt_Lines__r)
                                     FROM gii__PurchaseOrder__c WHERE Id =: purchaseOrderId LIMIT 1];
        

        System.debug('Ho pescato: '+po.gii__Purchase_Order_Receipt_Lines__r);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Ho pescato: '+po.gii__Purchase_Order_Receipt_Lines__r);
        List<Giic_POReceiptCreationApi.PurchaseOrderHeader> soWrapList = new List<Giic_POReceiptCreationApi.PurchaseOrderHeader>();
        List<Giic_POReceiptCreationApi.PurchaseOrderLine> solListToCreate = new List<Giic_POReceiptCreationApi.PurchaseOrderLine>();
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(options);  
        Map<Id,Giic_POReceiptCreationApi.PurchaseOrderLine> idPolToNewSOL = new  Map<Id,Giic_POReceiptCreationApi.PurchaseOrderLine>();
        XC_UTIL_Debug.debug(DEBUGACTIVE,'jsonMap = '+jsonMap);
        Giic_POReceiptCreationApi.PurchaseOrderHeader soCreateObj = new Giic_POReceiptCreationApi.PurchaseOrderHeader();
        soCreateObj.PurchaseOrderId = purchaseOrderId;// Purchase Order ID MAndatory
        String newDate = '';
        Boolean dateOk = false;
        Date correctDate;
        if(jsonMap.containsKey('deliveryDate')){
            newDate = String.valueOf(jsonMap.get('deliveryDate'));
            if(newDate!=null){
                correctDate = Date.valueOf(String.valueOf(jsonMap.get('deliveryDate')));
            }
            if(correctDate!=null){
                dateOk = true;
            }
        }
        if(dateOk){
            soCreateObj.deliveryDate =  correctDate;
        }else{
            soCreateObj.deliveryDate =  Date.valueOf(String.valueOf(jsonMap.get('receiptDate')));

        }
        String deliveryId;
        if(jsonMap.containsKey('deliveryDoc') && (String.valueOf(jsonMap.get('deliveryDoc')) !='') ){
            deliveryId = String.valueOf(jsonMap.get('deliveryDoc'));
        }else{
            deliveryId = po.gii__Supplier__r.XC_CodeSAP__c;
        }
        soCreateObj.deliveryId = deliveryId;

        /* NR2626 per ribaltare l'info del flag quality check e controllo sul periodo contabile */
        Boolean isActiveNR2626 = false;

        Integer endMonth;
        Integer startMonth;
    
        Date today = Date.Today();
        Integer day = today.Day();
        Integer month = today.month();
        Integer year = today.year();
        Integer dayInMonth = date.daysInMonth(year, month);
        
        
        List<giic_enable_NR2246__c> listCS = giic_enable_NR2246__c.getAll().values();
        if(listCS !=null && !listCS.isEmpty()){
                for(giic_enable_NR2246__c cs : listCS){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'csLegalEntity: ' + cs.LegalEntity__c);
                    if(po.giic_LegalEntity__c == cs.LegalEntity__c){isActiveNR2626 = true; endMonth = Integer.valueOf(cs.giic_endMonth__c); startMonth = Integer.valueOf(cs.giic_startMonth__c);break; }
 
                }
        }
        System.debug('isActiveNR2626: '+isActiveNR2626);
        if(isActiveNR2626){
            if(day <= startMonth || day >= (dayInMonth - endMonth)){
                rw.resultMessage = 'Periodo contabile chiuso, non è possibile eseguire entrata merci. Riprova domani.';
                return rw;
            }
            Boolean qualityCheckFlag = false;
            if(jsonMap.containsKey('qualityNoteRequire') && (Boolean.valueOf(jsonMap.get('qualityNoteRequire')) != null)){
                qualityCheckFlag= Boolean.valueOf(jsonMap.get('qualityNoteRequire'));
            }
            soCreateObj.qualityNoteRequire = qualityCheckFlag;
            
            /** per ribaltare l'info relativa all'arrival material */
            if(jsonMap.containsKey('arrivalMaterial') && (Date.valueOf(String.valueOf(jsonMap.get('arrivalMaterial'))) != null)){
                soCreateObj.arrivalMaterial = Date.valueOf(String.valueOf(jsonMap.get('arrivalMaterial')));
                System.debug(jsonMap.get('arrivalMaterial'));
                System.debug(String.valueOf(jsonMap.get('arrivalMaterial')));
                System.debug( Date.valueOf(String.valueOf(jsonMap.get('arrivalMaterial'))));

            }

            /** per ribaltare il valore del quality check fail */
            if(jsonMap.containsKey('qualityCheckFail') && Boolean.valueOf(jsonMap.get('qualityCheckFail')) != null){
                soCreateObj.qualityCheckFail = Boolean.valueOf(jsonMap.get('qualityCheckFail'));
            }

            /* per ribaltare il valore del quality check note */
            if(jsonMap.containsKey('qualityNote') && String.valueOf(jsonMap.get('qualityNote')) != ''){
                soCreateObj.qualityNote = String.valueOf(jsonMap.get('qualityNote'));
            }
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'DELIVERYID ='+soCreateObj.deliveryId);
        soCreateObj.receiptDate = Date.valueOf(String.valueOf(jsonMap.get('receiptDate')));
        Map<Id, gii__PurchaseOrderLine__c> idPolToPol = new Map<Id, gii__PurchaseOrderLine__c> ([
            SELECT Id,Name,gii__SalesOrderLine__c,gii__SalesOrderLine__r.Name,gii__Product__r.gii__SerialControlled__c,gii__Product__r.gii__LotControlled__c,gii__SalesOrderLine__r.gii__SalesOrder__c,gii__Product__c,giic_ProductSerial__c,gii__Product__r.Name,gii__ShipTo__c,gii__PurchaseOrder__r.gii__Supplier__c ,gii__ShipTo__r.Name, gii__ShipTo__r.gii__DefaultReceivingLocation__c,gii__ProductInventory__c,gii__OrderQuantity__c,gii__OpenQuantity__c,gii__ReceivedQuantity__c,gii__StockUM__c, gii__Service__c 
            FROM gii__PurchaseOrderLine__c
            WHERE (Id IN: mapPolIdToQuantity.keyset() OR Id IN: mapPolToSerialList.keyset() ) ]);

        for(gii__PurchaseOrderLine__c pol : idPolToPol.values()){
        Giic_POReceiptCreationApi.PurchaseOrderLine newSOL = new Giic_POReceiptCreationApi.PurchaseOrderLine();
        newSOL.PurchaseOrderLineId = pol.Id;// Purchase Order Line Id Mandatory
       
        XC_UTIL_Debug.debug(DEBUGACTIVE,'newSOL.ReceiptQuantity ='+newSOL.receiptQuantity );
        if(pol.gii__Product__r.gii__SerialControlled__c){
            List<String> serialNumbers = mapPolToSerialList.get(pol.Id);
            if(serialNumbers!=null && !serialNumbers.isEmpty() && mapPolIdToQuantity.get(pol.Id)!=null && (serialNumbers.size() == Integer.valueOf(mapPolIdToQuantity.get(pol.Id))) ){
                 newSOL.receiptQuantity = serialNumbers.size();
                 List<Giic_POReceiptCreationApi.AssignedSerial> assignedSerialsList = new  List<Giic_POReceiptCreationApi.AssignedSerial>();
                 for(String sn : serialNumbers){
                 		Giic_POReceiptCreationApi.AssignedSerial serial = new Giic_POReceiptCreationApi.AssignedSerial();
                 		serial.serialNumber = sn;// Mandatory for Serial controlled Product
                 		assignedSerialsList.add(serial);
            	 }
            newSOL.assignedSerials = assignedSerialsList;
                
            }else{
                 rw.success = false;
                 if(serialNumbers==null){
                     rw.resultMessage = 'Open quantity is 0 on '+pol.gii__Product__r.Name;
                 }else{
                     rw.resultMessage = 'Serial numbers and received quantity must be the same on '+pol.gii__Product__r.Name;
                 }
                 return rw;
                
            }
           
        }else if(pol.gii__Product__r.gii__LotControlled__c){
            Integer totalForAllLot = 0;
            map<String,Integer> lotNameToQuantity = idPOLToLotMap.get(pol.Id);
            Set<String> lotNumbers = lotNameToQuantity.keySet();
            for(String l : lotNumbers){
                totalForAllLot = totalForAllLot + Integer.valueOf(lotNameToQuantity.get(l));
            }
            
            System.debug('totalForAllLot = '+totalForAllLot);
            if(lotNumbers!=null && !lotNumbers.isEmpty() && mapPolIdToQuantity.get(pol.Id)!=null && (totalForAllLot == Integer.valueOf(mapPolIdToQuantity.get(pol.Id))) ){
                 newSOL.receiptQuantity = totalForAllLot;
                 List<Giic_POReceiptCreationApi.AssignedLot> assignedLotList = new  List<Giic_POReceiptCreationApi.AssignedLot>();
                 for(String sn : lotNumbers){
                 Giic_POReceiptCreationApi.AssignedLot lot = new Giic_POReceiptCreationApi.AssignedLot();
                 lot.LotNumber = sn;
                 lot.LotQuantity = lotNameToQuantity.get(sn);
                 assignedLotList.add(lot);
            }
            newSOL.assignedLots = assignedLotList;
                
            }else{
                 rw.success = false;
                 if(lotNumbers==null){
                     rw.resultMessage = 'Open quantity is 0 on '+pol.gii__Product__r.Name;
                 }else{
                     rw.resultMessage = 'Serial numbers and received quantity must be the same on '+pol.gii__Product__r.Name;
                 }
                 return rw;
                
            }
            
            
            
        }
        else{
             newSOL.receiptQuantity = (mapPolIdToQuantity.containsKey(pol.Id)) ? Integer.valueOf(mapPolIdToQuantity.get(pol.Id)) : pol.gii__ReceivedQuantity__c;
             XC_UTIL_Debug.debug(DEBUGACTIVE,'ReceiptQuantity = '+newSOL.ReceiptQuantity);
        }
            
        idPolToNewSOL.put(pol.Id, newSOL);
        solListToCreate.add(newSOL);
        }
       // createInventoryReserve(idPolToPol,idPolToNewSOL);
        soCreateObj.PurchaseOrderLinelist = solListToCreate;
        soWrapList.add(soCreateObj);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'soWrapList = '+soWrapList);
        System.debug('sto per chiamare la createPOReceiptandLine con ');
        System.debug('soWrapList = '+soWrapList);
        if(idPolToPol.values().isEmpty()){ 
            rw.resultMessage = Label.giic_ErrorProcessDropShipReceivedQuantity; // 'Received Quantity must be greater than 0';
            return rw;
        }
        /////////////////// added for CR NR1798 Trasportation Cost Management /////////////////////////
        integer received = 0;
        boolean isServicePresent = false;
        boolean isServiceChecked = false;
        
        Map<id, gii__PurchaseOrderLine__c> polMap = new Map<id, gii__PurchaseOrderLine__c> ([SELECT id, gii__Service__c, gii__PurchaseOrder__c FROM gii__PurchaseOrderLine__c WHERE gii__PurchaseOrder__c =: po.Id] );
        
        for(gii__PurchaseOrderLine__c pol : polMap.values()){
            if(pol.gii__Service__c){
                isServicePresent = true;
            }
        }
        
        system.debug(isServicePresent);
        
        if(isServicePresent){
           for(gii__PurchaseOrderLine__c pol : idPolToPol.values()){
           		if(pol.gii__Service__c != true){
              	received = received + Integer.valueOf(mapPolIdToQuantity.get(pol.Id));
            	}
            	else{
                	if(Integer.valueOf(mapPolIdToQuantity.get(pol.Id)) != 0){
					isServiceChecked = true;	
               		}
            	}    
       		}
            system.debug('isServiceChecked'+ isServiceChecked);
        	system.debug('received' + received);
            
            if((po.gii__TotalOpenQuantity__c - 1) > received && isServiceChecked){
        		rw.resultMessage = label.giic_CL_NoTransportCost; //'You cannot add Transport/Shipping cost if is not total Receipt';
            	return rw;
        	}
       		else if((po.gii__TotalOpenQuantity__c - 1) == received && !isServiceChecked){
				rw.ResultMessage = label.giic_CL_AddTransportCost; //'Add Transport/Shipping Cost before performing total Receipt';
            	return rw;
        	}
        }
        
        ///////////////////////////////////////////// NR2345 ///////////////////////////////////////////////////////        
        if(po.giic_RelatedPo__c != null){
            List<gii__PurchaseOrderReceipt__c> list2POR = [SELECT Id 
                                                            FROM gii__PurchaseOrderReceipt__c 
                                                            WHERE gii__PurchaseOrder__c =: po.giic_relatedPo__c];
            if(list2POR.size() == 0){ 
                rw.resultMessage = Label.giic_GRtoRelatedPO + ' ' + po.giic_relatedPO__r.name;
                return rw;
            }
        }



        
        
        ///////////////////////////////////////////
        Giic_POReceiptCreationApi.POReceiptResponse pr = Giic_POReceiptCreationApi.createPOReceiptandLine(soWrapList);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'pr result = '+pr);
        if(pr.isSuccess==null && idPolToPol.values().isEmpty()){ 
            rw.resultMessage = Label.giic_ErrorProcessDropShip; // 'Select at least one line item';
            return rw;
        }
        if(pr.isSuccess){
           if(po.gii__DropShip__c){
                
                XC_UTIL_ResultWrapper rw2 = closeSalesOrder(po);
                if(!rw2.success){ 
                    Database.rollback(sp);
                    return rw2; 
                }
				
              //System.enqueueJob(new Giic_closeSalesOrderAsync(po));
            }
             rw.success = true;
             rw.resultMessage = Label.giic_PORSuccess ; // 'Purchase Order Receipt correctly created';
        }else{ rw.resultMessage = manageCreatePorError(String.valueOf(pr.errorList[0])); }


        List<gii__PurchaseOrderReceipt__c> por = [SELECT id, XC_Quality_Check__c, giic_QualityCheckKONOEMFlag__c, giic_NoteQualityCheck__c, giic_MaterialReceiptDate__c
                                                  FROM gii__PurchaseOrderReceipt__c
                                                  ];

        /*
        for(gii__PurchaseOrderReceipt__c poReceipt : por){
            poReceipt.XC_Quality_Check__c = por.qualityCheck;
            poReceipt.giic_QualityCheckKONOEMFlag__c = por.qualityCheckFail;
            poReceipt.giic_NoteQualityCheck__c = por.qualityCheckNote;
            poReceipt.giic_MaterialReceiptDate__c = por.arrivalMaterial;
        }

        */

        
    /*
       List<String> cSList = new List<String>();
        List<giic_enable_NR2246__c> cs = giic_enable_NR2246__c.getAll().value();

        for(giic_enable_NR2246__c csett : cs){
            if(csett.giic_legalEntity__c == po.giic_legalEntity__c){
                CSList.add(csett.giic_legalEntity__c);
            }
        }*/

        return rw;


    }
    
    
    public static String manageCreatePorError(String errorString){
        if(errorString.startsWith('ErrorList:[errorMsg=')){
             errorString = errorString.removeStart('ErrorList:[errorMsg=');
        }
        if(errorString.contains('Duplicate id in list:')){
            errorString = Label.Giic_SameSerialNumberError;
        }
        if(errorString.contains('Open Quantity + Receiving Over Tolerance Quantity')){
            errorString = Label.giic_CL_QuantityLinesError;
        } 
        return errorString; 
    }


/*
    private static void createInventoryReserve(Map<Id, gii__PurchaseOrderLine__c> idToPol ,   Map<Id,Giic_POReceiptCreationApi.PurchaseOrderLine> idPolToNewSOL){
        List<gii__InventoryReserve__c> reserveToInsert = new List<gii__InventoryReserve__c>();
        List<gii__Shipment__c> shipmentToInsert = new List<gii__Shipment__c>();
            for(gii__PurchaseOrderLine__c p : idToPol.values()){
                      gii__Shipment__c s = new gii__Shipment__c();
                      gii__InventoryReserve__c ir = new gii__InventoryReserve__c();
                      ir.gii__ReserveQuantity__c = idPolToNewSOL.get(p.Id).ReceiptQuantity;
                      ir.gii__SalesOrderLine__c = p.gii__SalesOrderLine__c;
                      ir.gii__ProductInventorySequence__c = p.gii__ProductInventory__c;
                      ir.gii__Product__c = p.gii__Product__c;
                      ir.gii__Account__c = p.gii__PurchaseOrder__r.gii__Supplier__c;
                      ir.gii__Warehouse__c = p.gii__ShipTo__c;
                      ir.gii__StockUM__c = p.gii__StockUM__c;
                      ir.gii__SalesOrder__c = p.gii__SalesOrderLine__r.gii__SalesOrder__c;
                      s.gii__SalesOrder__c = p.gii__SalesOrderLine__r.gii__SalesOrder__c;
                      s.gii__Account__c = p.gii__PurchaseOrder__r.gii__Supplier__c;
                      s.gii__ShippedDate__c = Date.today();
                      ir.gii__Location__c = p.gii__ShipTo__r.gii__DefaultReceivingLocation__c;
                      ir.gii__ProductSerial__c =  p.giic_ProductSerial__c;
                      reserveToInsert.add(ir);
                      shipmentToInsert.add(s);
            }
            insert reserveToInsert;
            insert shipmentToInsert;

    }
*/    
    
    public static XC_UTIL_ResultWrapper closeSalesOrder(gii__PurchaseOrder__c po){
        System.debug('entrato in closeSalesOrder');
       XC_UTIL_ResultWrapper rw2 = new XC_UTIL_ResultWrapper();
       rw2.success = false;
       po = [SELECT Id, gii__DropShip__c,gii__Supplier__c,gii__SalesOrder__r.giic_FSLWorkOrder__c, gii__ShipTo__c,gii__SalesOrder__r.gii__Account__c,
             gii__SalesOrder__r.giic_WorkOrderLineItem__c, 
                                    (SELECT id,gii__Product__c,gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c,gii__ReceivedQuantity__c,
                                     gii__ProductSerial__r.Name, gii__ProductLot__c, gii__ProductLot__r.Name
                                     FROM gii__Purchase_Order_Receipt_Lines__r WHERE Giic_AlreadySend__c=false)
                                     FROM gii__PurchaseOrder__c WHERE Id =: po.Id ];
        
       System.debug('Purchase_Order_Receipt_Lines = '+po.gii__Purchase_Order_Receipt_Lines__r);
       List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
       Map<Id, List<String>> mapProductSerials = new Map<Id, List<String>>();
       Map<String, List<String>> mapProductLots = new Map<String, List<String>>(); 
       Map<String, Integer> mapProductLotsQuantity = new Map<String, Integer>(); 
       Map<Id, Decimal> mapProductReceivedQuantity = new Map<Id, Decimal>(); 
       Map<Id, gii__PurchaseOrderReceiptLine__c> mapProductsPORec = new Map<id, gii__PurchaseOrderReceiptLine__c>(); 
            Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
            soWrap.account = po.gii__SalesOrder__r.gii__Account__c;
            soWrap.warehouse = po.gii__ShipTo__c;
            soWrap.fslWorkOrder = po.gii__SalesOrder__r.giic_FSLWorkOrder__c; 
            soWrap.fslWorkOrderLineItem = po.gii__SalesOrder__r.giic_WorkOrderLineItem__c;
            soWrap.SalesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
        	soWrap.lastGoodIssue = false;
        
        	for(gii__PurchaseOrderReceiptLine__c recLine : po.gii__Purchase_Order_Receipt_Lines__r){
                mapProductsPORec.put(recLine.gii__Product__c, recLine);
                if(recLine.gii__ProductSerial__c != null){ 
                    if(!mapProductSerials.containsKey(recLine.gii__Product__c)){
                        mapProductSerials.put(recLine.gii__Product__c, new List<String>() ); 
                    }
                    mapProductSerials.get(recLine.gii__Product__c).add(recLine.gii__ProductSerial__r.Name); 
                }
                if(recLine.gii__ProductLot__c != null){ 
                    if(!mapProductLots.containsKey(recLine.gii__Product__c)){
                        mapProductLots.put(recLine.gii__Product__c, new List<String>()); 
                    }
                    mapProductLots.get(recLine.gii__Product__c).add(recLine.gii__ProductLot__r.Name); 
                    mapProductLotsQuantity.put(recLine.gii__ProductLot__r.Name, (Integer) recLine.gii__ReceivedQuantity__c);
                }
                 if(!mapProductReceivedQuantity.containsKey(recLine.gii__Product__c)){
                        mapProductReceivedQuantity.put(recLine.gii__Product__c,  0 ); 
                    } 
                  mapProductReceivedQuantity.put(recLine.gii__Product__c, mapProductReceivedQuantity.get(recLine.gii__Product__c)+ recLine.gii__ReceivedQuantity__c ); 
            }
            for(Id product  : mapProductsPORec.keyset()){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'ship -');
                Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
                sol.product = product ;  
                sol.productRequiredID = mapProductsPORec.get(product).gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c;   
                
                sol.consumedQuantity = (Integer) mapProductReceivedQuantity.get(product);
                sol.warehouse =  po.gii__ShipTo__c;    //INC000086233988
                sol.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>(); 
                sol.lstAssignedLot =  new List<Giic_GoodsIssueSO.ProductLot>(); 
                if(mapProductSerials.containskey(product)){ 
                    for(String ser : mapProductSerials.get(product)){
                        Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
                        serials.serialNumber = ser;   //Adding first Serial TODO verificare
                        sol.assignedSerials.add(serials);
                        sol.isSerialControlled = true;  //NR2493
                    } 
                }
                System.debug('mapProductSerials = '+mapProductSerials);
                System.debug('mapProductSerials size = '+mapProductSerials.size());
                if(mapProductLots.containskey(product)){ 
                    for(String lot : mapProductLots.get(product)){
                        Giic_GoodsIssueSO.ProductLot lots = new Giic_GoodsIssueSO.ProductLot();
                        lots.lotNumber = lot;  
                        lots.lotQty = (Integer) mapProductLotsQuantity.get(lot); //Adding first Serial TODO verificare
                        sol.lstAssignedLot.add(lots);  
                    }
                }
                soWrap.salesOrderLineList.add(sol);
            }
            soWrapList.add(soWrap);
      
        Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList); 
         if(goodsIssueResponse!=null && goodsIssueResponse.isSuccess!=null && goodsIssueResponse.isSuccess){
            rw2.success=true;
            List<Id> purchaseOrderRIds = XC_UTIL_Sobject.getIds(po.gii__Purchase_Order_Receipt_Lines__r);
            markReceiptAsClosed(purchaseOrderRIds);
        }else{
            if(goodsIssueResponse!=null && goodsIssueResponse.errorList != null && !goodsIssueResponse.errorList.isEmpty() ){
                rw2.resultMessage = String.valueOf(goodsIssueResponse.errorList[0]);
            }else{
                 rw2.resultMessage = 'Error in Close WorkOrder';
            }
        }
        return rw2;
    } 
    
    
    
    @future
    public static void markReceiptAsClosed(List<Id> porIdsList){
        List<gii__PurchaseOrderReceiptLine__c> porToUpdate = new List<gii__PurchaseOrderReceiptLine__c>();
        for(Id porId : porIdsList){
            gii__PurchaseOrderReceiptLine__c p = new gii__PurchaseOrderReceiptLine__c(id = porId, Giic_AlreadySend__c = true);
            porToUpdate.add(p);
        }
        update porToUpdate;
    }

    

}
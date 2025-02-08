public without sharing class Giic_TR_ManageOrderTracking {
    
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TR_ManageOrderTracking');  
    /**
* manageOrderTracking
*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param contacts the contacts
* @date Creation 28/07/2019
* @description method for manage Order Tracking
*/
    public static void manageOrderTracking(List<gii__PurchaseOrder__c> listNew, Map<Id, gii__PurchaseOrder__c> mapOld, Map<Id, gii__PurchaseOrder__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In manageOrderTracking');
        List<String> fieldToCheck = new List<String> { 'giic_NewDeliveryDate__c', 'giic_CarrierName__c', 'giic_DeliveryTracking__c'};
            listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(listNew.isEmpty()){
            return; 
        } 
        rebaltTracking(listNew);
    }
    
    
    /**
* manageOrderTracking
*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param contacts the contacts
* @date Creation 28/07/2019
* @description method for manage Order Tracking
*/
    public static void checkIfAmountChange(List<gii__PurchaseOrderLine__c> listNew, Map<Id, gii__PurchaseOrderLine__c> mapOld, Map<Id, gii__PurchaseOrderLine__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkIfAmountChange');
        List<String> fieldToCheck = new List<String> { 'gii__Calc_LineGrossAmount__c'};
            listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(listNew.isEmpty()){
            return; 
        } 
        updateAlertFlagOnPO(listNew);
    }
    
    
    public static void  updateAlertFlagOnPO(List<gii__PurchaseOrderLine__c> purchaseOrderLines){
        System.debug('In updateAlertFlagOnPO');    
        List<Id> polIds = XC_UTIL_Sobject.getIds(purchaseOrderLines);
        map<Id,Id> productRefToPO = new map<Id,Id>();
        List<gii__PurchaseOrderLine__c> listPOLine = new List<gii__PurchaseOrderLine__c>([
            SELECT Id, gii__PurchaseOrder__c, gii__OpenAmount__c, gii__PurchaseOrder__r.Id, gii__PurchaseOrder__r.giic_Contract__c,gii__Product__c,gii__Product__r.Id FROM gii__PurchaseOrderLine__c WHERE Id IN :polIds
        ]);
        
        map<String,Double> legalToPercent = new  map<String,Double>();
        List<XC_CM_ContractAlertThreshold__mdt> mList = [SELECT Id, XC_PercentageRatio__c,XC_LegalEntity__c FROM XC_CM_ContractAlertThreshold__mdt ];
        for(XC_CM_ContractAlertThreshold__mdt m : mList){
            legalToPercent.put(m.XC_LegalEntity__c, m.XC_PercentageRatio__c);
        }
        map<Id,gii__PurchaseOrder__c> purchaseOrderToUpdate = new map<Id,gii__PurchaseOrder__c> ();
        map<Id,gii__PurchaseOrderLine__c> idPOToLine = new map<Id,gii__PurchaseOrderLine__c>();
        
        map<Id, Double> purchaseOrderLineAmount = new  map<Id,Double>();
        List<String> contractList = new List<String>();
        for(gii__PurchaseOrderLine__c pol : listPOLine){
            productRefToPO.put(pol.gii__Product__r.Id, pol.gii__PurchaseOrder__r.Id);
            idPOToLine.put(pol.gii__PurchaseOrder__c , pol);
            contractList.add(pol.gii__PurchaseOrder__r.giic_Contract__c);
            if(!purchaseOrderLineAmount.containskey(pol.gii__PurchaseOrder__c)){
                purchaseOrderLineAmount.put(pol.gii__PurchaseOrder__c, 0);
            }
            Double lineAmount = purchaseOrderLineAmount.get(pol.gii__PurchaseOrder__c);
            purchaseOrderLineAmount.put(pol.gii__PurchaseOrder__c,lineAmount + pol.gii__OpenAmount__c );
        }
        map<Id,gii__Product2Add__c> prodRefMap = new map<Id,gii__Product2Add__c>([Select Id, Name, (SELECT Id FROM gii__Price_Book_Entries__r where gii__IsActive__c=true) FROM gii__Product2Add__c WHERE Id IN:productRefToPO.keySet() ]);
        for(gii__Product2Add__c p2a : prodRefMap.values()){
            if(p2a.gii__Price_Book_Entries__r.size()>1){
                gii__PurchaseOrder__c pNew = new gii__PurchaseOrder__c(Id=productRefToPO.get(p2a.Id), giic_MultipleSuppliersForProduct__c=true );
                purchaseOrderToUpdate.put(pNew.Id, pNew);
            }
            
            
        }
        
        
        
        
        
        map<Id,gii__PurchaseOrder__c> poMap = new map<Id,gii__PurchaseOrder__c>([SELECT Id, gii__OrderAmount__c, giic_Contract__c, giic_Contract__r.XC_LegalEntity__c,giic_Contract__r.giic_BudgetConsumption__c, giic_Contract__r.giic_TotalAmount__c FROM gii__PurchaseOrder__c 
                                                                                 WHERE giic_Contract__c IN: contractList AND giic_Status__c!='Closed' AND giic_Status__c!='Cancelled' AND giic_Status__c!='Merged']);
        
        
        
        System.debug('mettopoMap' + poMap.size());
        map<Id, List<gii__PurchaseOrder__c>> contractIdToPurchase = new  map<Id,List<gii__PurchaseOrder__c>>();
        map<Id, Double> contractIdToBudgetConsumed = new  map<Id,Double>();
        map<Id, String> contractIdToLegalEntity = new  map<Id,String>();
        map<Id, Double> contractIdToTotalAmount = new  map<Id,Double>();
        
        for(gii__PurchaseOrder__c p : poMap.values()){
            contractIdToLegalEntity.put(p.giic_Contract__c, p.giic_Contract__r.XC_LegalEntity__c);
            Double budgetCons;
            Double totalAmount;
            if(p.giic_Contract__r.giic_BudgetConsumption__c!= null){
                budgetCons = p.giic_Contract__r.giic_BudgetConsumption__c;  
            }else{
                budgetCons = 0;
            }
            contractIdToBudgetConsumed.put(p.giic_Contract__c, budgetCons);
            if(p.giic_Contract__r.giic_TotalAmount__c!=null){
                totalAmount = p.giic_Contract__r.giic_TotalAmount__c;
            }else{
                totalAmount = 1;
            }
            
            contractIdToTotalAmount.put(p.giic_Contract__c, totalAmount);
            if(!contractIdToPurchase.containsKey(p.giic_Contract__c)){
                contractIdToPurchase.put(p.giic_Contract__c, new List<gii__PurchaseOrder__c>() ); 
            }
            contractIdToPurchase.get(p.giic_Contract__c).add(p);    
        }
        
        for(id i : contractIdToPurchase.keySet()){
            List<gii__PurchaseOrder__c> purchaseList = contractIdToPurchase.get(i);
            double orderAmount =0;
            for(gii__PurchaseOrder__c po : purchaseList){ 
                orderAmount = orderAmount+po.gii__OrderAmount__c ;
                if(purchaseOrderLineAmount.containskey(po.Id)){
                    orderAmount = orderAmount  + purchaseOrderLineAmount.get(po.Id);
                }
            }
            if((((orderAmount+contractIdToBudgetConsumed.get(i))/contractIdToTotalAmount.get(i))*100) > legalToPercent.get(contractIdToLegalEntity.get(i))) {
                for(gii__PurchaseOrder__c po : purchaseList){
                    if(!purchaseOrderToUpdate.containsKey(po.Id)){
                        po.giic_BudgetLimitExceeded__c = true;
                        purchaseOrderToUpdate.put(po.Id,po);
                    }else{
                        purchaseOrderToUpdate.get(po.Id).giic_BudgetLimitExceeded__c = true;
                    }
                    
                    
                }
            }
            
        }
        
        update purchaseOrderToUpdate.values();
        
    }
    
    
    
    /**
* rebaltTracking
*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param contacts the contacts
* @date Creation 28/07/2019
* @description method for rebalt Tracking
*/
    public static void rebaltTracking(List<gii__PurchaseOrder__c> purchaseOrders){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In rebaltTracking');
        map<Id,gii__PurchaseOrder__c> salesOrdIdToPurchaseOrd = new map<Id,gii__PurchaseOrder__c>();
        List<gii__SalesOrder__c> soToUpdate =  new List<gii__SalesOrder__c>();
        List<WorkOrder> woToUpdate =  new List<WorkOrder>();
        List<WorkOrderLineItem> woliToUpdate =  new List<WorkOrderLineItem>();
        for(gii__PurchaseOrder__c po : purchaseOrders){  
            salesOrdIdToPurchaseOrd.put(po.gii__SalesOrder__c,po); 
        } 
        map<Id, gii__SalesOrder__c> soList = new map<Id, gii__SalesOrder__c>([SELECT Id,gii__OrderDate__c,gii__RequiredDate__c,giic_WorkOrder__c, giic_WorkOrder__r.XC_DeliveryDate__c,giic_WorkOrder__r.XC_Delivery_Tracking_URL__c, giic_NewDeliveryDate__c,giic_CarrierName__c,giic_WorkOrderLineItem__c,
                                                                              giic_DeliveryTracking__c FROM gii__SalesOrder__c WHERE Id IN:salesOrdIdToPurchaseOrd.keySet()]);
        
        for(gii__SalesOrder__c so : soList.values()){ 
            so.giic_NewDeliveryDate__c = salesOrdIdToPurchaseOrd.get(so.Id).giic_NewDeliveryDate__c;
            so.giic_CarrierName__c = salesOrdIdToPurchaseOrd.get(so.Id).giic_CarrierName__c;
            so.giic_DeliveryTracking__c = salesOrdIdToPurchaseOrd.get(so.Id).giic_DeliveryTracking__c;
            soToUpdate.add(so);
            /* 
WorkOrder wo = new WorkOrder(Id=so.giic_WorkOrder__c,XC_Delivery_Tracking_URL__c=salesOrdIdToPurchaseOrd.get(so.Id).giic_DeliveryTracking__c,XC_Courier_Partner__c=salesOrdIdToPurchaseOrd.get(so.Id).giic_CarrierName__c,XC_EffectiveProductAvailabilityDate__c=salesOrdIdToPurchaseOrd.get(so.Id).giic_NewDeliveryDate__c);
woToUpdate.add(wo); */
        } 
        XC_UTIL_SObject.updateListRecords(soToUpdate);
        updateWO(soToUpdate); 
        
    }
    
    /**
* rebaltOrderTrackOnPo
*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param contacts the contacts
* @date Creation 28/07/2019
* @description method for manage Order Tracking
*/
    public static void rebaltOrderTrackOnPo(List<gii__PurchaseOrderLine__c> listNew, Map<Id, gii__PurchaseOrderLine__c> mapOld, Map<Id, gii__PurchaseOrderLine__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In rebaltOrderTrackOnPo');
        map<Id,gii__PurchaseOrderLine__c> idPOtoPol = new map<Id,gii__PurchaseOrderLine__c>();
        List<String> fieldToCheck = new List<String> {'giic_NewDeliveryDate__c', 'giic_CarrierName__c', 'giic_DeliveryTracking__c'};
            listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        for(gii__PurchaseOrderLine__c pol : listNew){
            if(pol.giic_CarrierName__c!=null || pol.giic_DeliveryTracking__c!=null || pol.giic_NewDeliveryDate__c!=null){
                idPOtoPol.put(pol.gii__PurchaseOrder__c, pol);
            }
        }
        foundWorstDate(idPOtoPol); 
    }
    
    /**
* foundWorstDate
*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param contacts the contacts
* @date Creation 28/07/2019
* @description method for manage Order Tracking
*/
    public static void foundWorstDate(map<Id,gii__PurchaseOrderLine__c> idPOtoPoLine){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In foundWorstDate');
        List<gii__PurchaseOrder__c> poToUpdate = new List<gii__PurchaseOrder__c>();
        List<gii__PurchaseOrder__c> poList = [SELECT Id, gii__OrderDate__c,gii__RequiredDate__c, giic_NewDeliveryDate__c, giic_CarrierName__c, giic_DeliveryTracking__c, 
                                              (SELECT Id,gii__PromisedDate__c, giic_NewDeliveryDate__c, giic_CarrierName__c, giic_DeliveryTracking__c 
                                               FROM gii__Purchase_Order_Lines__r) FROM gii__PurchaseOrder__c
                                              WHERE Id IN: idPOtoPoLine.keySet()]; 
        for(gii__PurchaseOrder__c po : poList){
            List<gii__PurchaseOrderLine__c> poLineList = po.gii__Purchase_Order_Lines__r;
            if(!poLineList.isEmpty()){
                po.giic_CarrierName__c = poLineList[0].giic_CarrierName__c;
                po.giic_DeliveryTracking__c = poLineList[0].giic_DeliveryTracking__c;
                for(gii__PurchaseOrderLine__c pol : poLineList){
                    if(pol.giic_NewDeliveryDate__c > po.gii__RequiredDate__c){
                        po.giic_NewDeliveryDate__c = pol.giic_NewDeliveryDate__c;
                        po.giic_CarrierName__c = pol.giic_CarrierName__c;
                        po.giic_DeliveryTracking__c = pol.giic_DeliveryTracking__c;
                    }
                } 
                poToUpdate.add(po);
            }	
        }
        update poToUpdate;
    }
    
    
    /**     
* @author Roberta Porrega - roberta.porrega@nttdata.com
* @param listNew the listNew
* @param mapOld the mapOld
* @param mapNew the mapNew
* @date Creation 23/10/2019
* @description method for rebalt Tracking
*/
    public static void fillFieldsOrderTracking(List<gii__TransferOrder__c > listNew, Map<Id, gii__TransferOrder__c > mapOld, Map<Id, gii__TransferOrder__c > mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In fillFieldsOrderTracking');
        List<String> fieldList = new List<String>{'giic_CarrierName__c','giic_DeliveryTracking__c','giic_NewDeliveryDate__c'};
            List<gii__TransferOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        retrieveSalesOrder(listChanged);
    }
    
    /**     
* @author Roberta Porrega - roberta.porrega@nttdata.com
* @param listNew the listNew
* @date Creation 23/10/2019
* @description method for rebalt Tracking
*/
    public static void retrieveSalesOrder(List<gii__TransferOrder__c > listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In retrieveSalesOrder');
        
        List<Id> toIds = XC_UTIL_Sobject.getIds(listNew);
        Map<Id, gii__TransferOrder__c> mapTransferOrder = new Map<Id, gii__TransferOrder__c>([ SELECT Id, giic_CarrierName__c,giic_DeliveryTracking__c,giic_NewDeliveryDate__c, gii__OrderDate__c,
                                                                                              (SELECT Id,giic_SalesOrderLine__c,giic_SalesOrderLine__r.gii__SalesOrder__c, giic_CarrierName__c,giic_DeliveryTracking__c,giic_NewDeliveryDate__c, gii__RequiredDate__c ,giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__c,giic_SalesOrderLine__r.giic_ProdRequired__c,giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c
                                                                                               FROM gii__TransferOrderLines__r)
                                                                                              FROM gii__TransferOrder__c WHERE Id IN: toIds AND giic_status__c != :Label.giic_StatusMerged AND giic_Approved__c = true ]); 
        
        if(mapTransferOrder.isEmpty()){ return;             } 
        List<gii__SalesOrder__c> soListToUp = new List<gii__SalesOrder__c>();
        List<gii__SalesOrderLine__c> solListToUp = new List<gii__SalesOrderLine__c>();
        
        List<Id> woIds = new List<Id>();
        for(gii__TransferOrder__c to : mapTransferOrder.values()){
            for(gii__TransferOrderLine__c tol : to.gii__TransferOrderLines__r){
                if(!woIds.contains(tol.giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__c)){
                    gii__SalesOrder__c soToUp = new gii__SalesOrder__c(Id = tol.giic_SalesOrderLine__r.gii__SalesOrder__c,
                                                                       giic_CarrierName__c =  to.giic_CarrierName__c,
                                                                       giic_DeliveryTracking__c =  to.giic_DeliveryTracking__c,
                                                                       giic_NewDeliveryDate__c = to.giic_NewDeliveryDate__c ,
                                                                       giic_WorkOrder__c = tol.giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__c,
                                                                       giic_WorkOrderLineItem__c = tol.giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c
                                                                      );
                    woIds.add(tol.giic_SalesOrderLine__r.gii__SalesOrder__r.giic_WorkOrder__c);
                    soListToUp.add(soToUp);   
                }
                
                gii__SalesOrderLine__c solToUp = new gii__SalesOrderLine__c(Id = tol.giic_SalesOrderLine__c,
                                                                            giic_CarrierName__c =  tol.giic_CarrierName__c,
                                                                            giic_DeliveryTracking__c =  tol.giic_DeliveryTracking__c,
                                                                            giic_NewDeliveryDate__c = tol.giic_NewDeliveryDate__c ,
                                                                            giic_ProdRequired__c = tol.giic_SalesOrderLine__r.giic_ProdRequired__c
                                                                           );
                solListToUp.add(solToUp);
            }
        }
        XC_UTIL_SObject.updateListRecords(soListToUp);
        XC_UTIL_SObject.updateListRecords(solListToUp); 
        updateWO(soListToUp);
        updateProductRequired(solListToUp); 
    }
    /**     
* @author Roberta Porrega - roberta.porrega@nttdata.com
* @param listNew the listNew
* @date Creation 23/10/2019
* @description method for rebalt Tracking
*/
    public static void updateWO(List<gii__SalesOrder__c > listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In updateWO');
        List<WorkOrder> woToUpdate =  new List<WorkOrder>();
        List<WorkOrderLineItem> woliToUpdate =  new List<WorkOrderLineItem>();
        for(gii__SalesOrder__c so : listNew){
            if(so.giic_WorkOrderLineItem__c == null){
                WorkOrder wo = new WorkOrder(Id = so.giic_WorkOrder__c,XC_Delivery_Tracking_URL__c = so.giic_DeliveryTracking__c,
                                             XC_Courier_Partner__c = so.giic_CarrierName__c,XC_EffectiveProductAvailabilityDate__c = so.giic_NewDeliveryDate__c);
                woToUpdate.add(wo); 
            }else{
                WorkOrderLineItem woli = new WorkOrderLineItem(Id = so.giic_WorkOrderLineItem__c, XC_Delivery_Tracking_URL__c = so.giic_DeliveryTracking__c,
                                                               XC_Courier_Partner__c = so.giic_CarrierName__c,XC_EffectiveProductAvailabilityDate__c = so.giic_NewDeliveryDate__c);
                woliToUpdate.add(woli); 
            }
            
        }  
        system.debug('@@@ woToUpdate' + woToUpdate);
        XC_UTIL_SObject.updateListRecords(woToUpdate);
        XC_UTIL_SObject.updateListRecords(woliToUpdate);
    }
    
    /**     
* @author Roberta Porrega - roberta.porrega@nttdata.com
* @param listNew the listNew
* @date Creation 23/10/2019
* @description method for rebalt Tracking
*/    
    public static void updateProductRequired(List<gii__SalesOrderLine__c > listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In updateProductRequired');
        List<ProductRequired> prToUpdate =  new List<ProductRequired>();
        for(gii__SalesOrderLine__c so : listNew){
            ProductRequired pr = new ProductRequired(Id = so.giic_ProdRequired__c,XC_DeliveryTracking__c = so.giic_DeliveryTracking__c,
                                                     XC_CarrierName__c = so.giic_CarrierName__c,XC_NewDeliveryDate__c = so.giic_NewDeliveryDate__c);
            prToUpdate.add(pr); 
        } 
        XC_UTIL_SObject.updateListRecords(prToUpdate);
    }
    
    
    /**
* rebaltOrderTrackOnPo
*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param contacts the contacts
* @date Creation 28/07/2019
* @description method for manage Order Tracking
*/
    public static void rebaltOrderTrackOnTO(List<gii__TransferOrderLine__c> listNew, Map<Id, gii__TransferOrderLine__c> mapOld, Map<Id, gii__TransferOrderLine__c> mapNew){
        
        map<Id,gii__TransferOrderLine__c> idTOtoTol = new map<Id,gii__TransferOrderLine__c>();
        List<String> fieldToCheck = new List<String> {'giic_NewDeliveryDate__c', 'giic_CarrierName__c', 'giic_DeliveryTracking__c'};
            listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        for(gii__TransferOrderLine__c tol : listNew){
            if(tol.giic_CarrierName__c!=null || tol.giic_DeliveryTracking__c!=null || tol.giic_NewDeliveryDate__c!=null){
                idTOtoTol.put(tol.gii__TransferOrder__c, tol);
            }
        }
        foundWorstDate(idTOtoTol);
    }
    
    
    /**
* foundWorstDate
*
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @param contacts the contacts
* @date Creation 28/07/2019
* @description method for manage Order Tracking
*/
    public static void foundWorstDate(map<Id,gii__TransferOrderLine__c> idTOtoToLine){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In foundWorstDate');
        List<gii__TransferOrder__c> toToUpdate = new List<gii__TransferOrder__c>();
        List<gii__TransferOrder__c> toList = [SELECT Id, gii__OrderDate__c,gii__RequiredDate__c, giic_NewDeliveryDate__c, giic_CarrierName__c, giic_DeliveryTracking__c, 
                                              (SELECT Id,gii__RequiredDate__c, giic_NewDeliveryDate__c, giic_CarrierName__c, giic_DeliveryTracking__c 
                                               FROM gii__TransferOrderLines__r) 
                                              FROM gii__TransferOrder__c
                                              WHERE Id IN: idTOtoToLine.keySet()]; 
        for(gii__TransferOrder__c to : toList){
            List<gii__TransferOrderLine__c> toLineList = to.gii__TransferOrderLines__r;
            if(!toLineList.isEmpty()){
                to.giic_CarrierName__c = toLineList[0].giic_CarrierName__c;
                to.giic_DeliveryTracking__c = toLineList[0].giic_DeliveryTracking__c;
                for(gii__TransferOrderLine__c tol : toLineList){
                    if(tol.giic_NewDeliveryDate__c > to.gii__RequiredDate__c){
                        to.giic_NewDeliveryDate__c = tol.giic_NewDeliveryDate__c;
                        to.giic_CarrierName__c = tol.giic_CarrierName__c;
                        to.giic_DeliveryTracking__c = tol.giic_DeliveryTracking__c;
                    }
                } 
                toToUpdate.add(to);
            }	
        }
        update toToUpdate;
    }
    
    
}
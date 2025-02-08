/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – Utility class for trigger on TOL.
*/
public without sharing class Giic_TransferOrderLineUtility {
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TransferOrderLineUtility');
/**
* @author FirstName : Rishabh Bansal Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – method for reserving quantities on TOL with TO source as manual
* @param tolList-List of gii__TransferOrderLine__c
*/
    public static void reserveQuantitiesForTOL(List<gii__TransferOrderLine__c> tolList, boolean fromWhChanged){    
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
        Set<String> whSet = new Set<String>();
        Set<String> pdtSet = new Set<String>();
        Set<String> locSet = new Set<String>();
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        List<gii__TransferOrderLine__c> tolListNew = new List<gii__TransferOrderLine__c>();
        
        if(Schema.sObjectType.gii__TransferOrderLine__c.isQueryable()){
            tolListNew = [SELECT Id,gii__TransferOrder__c,gii__TransferOrder__r.gii__FromWarehouse__c,
                          gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,
                          gii__Product__c,gii__Warehouse__c,gii__Quantity__c,gii__TransferOrder__r.giic_Source__c,gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__c
                          FROM gii__TransferOrderLine__c WHERE Id IN:tolList];
        }
        for(gii__TransferOrderLine__c tolObj : tolListNew){
            whSet.add(tolObj.gii__TransferOrder__r.gii__FromWarehouse__c);
            pdtSet.add(tolObj.gii__Product__c);
            locSet.add(tolObj.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c);
        }
        // Querying PIQD's
        Map<Id,gii__ProductInventory__c> mapOfIdVsPI;
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__Warehouse__c,gii__AvailableQuantity__c, giic_SalesOnHand__c, giic_Reserved__c, giic_BackOrderNew__c FROM 
                                                                gii__ProductInventory__c WHERE 
                                                                gii__Product__c IN: pdtSet AND gii__Warehouse__c IN: whSet]);   
        }

        
        if(mapOfIdVsPI != null && !mapOfIdVsPI.values().isEmpty()){
            mapRW = reserveQuantitiesForTOLHelper(tolListNew,mapOfIdVsPI, fromWhChanged);
            if(Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
                System.debug('aggiorno : '+mapOfIdVsPI.values() );
                update mapOfIdVsPI.values();
            }
            if(!mapRW.values().isEmpty()){
                giic_ReservationUtility.reserveQuantities(mapRW.values());
            }
        }
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'reserveQuantitiesForTOL-------');
    }
 /**
* @author FirstName : Rishabh Bansal Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – method for reserving quantities on TOL with TO source as manual
* @param tolListNew-List of gii__TransferOrderLine__c
* @param mapOfIdVsPI-Map of Id VS Product Inventory
* @return reserveQuantitiesForTOLHelper-Map of String VS giic_ReservationUtility.ReservationWrapper
*/
    public static Map<string,giic_ReservationUtility.ReservationWrapper> reserveQuantitiesForTOLHelper(List<gii__TransferOrderLine__c> tolListNew,Map<Id,gii__ProductInventory__c> mapOfIdVsPI, boolean fromWhChanged){
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        Map<String,gii__ProductInventory__c> mapKeyVsPI = new Map<String,gii__ProductInventory__c>();
        for(gii__ProductInventory__c piRec : mapOfIdVsPI.values()){
            String key = piRec.gii__Product__c +'-'+piRec.gii__Warehouse__c;
            mapKeyVsPI.put(key,piRec);
        }
        for(gii__TransferOrderLine__c tolObj : tolListNew){
            if(tolObj.gii__TransferOrder__r.giic_Source__c == 'Manual' || fromWhChanged){
                String key = tolObj.gii__Product__c +'-'+tolObj.gii__TransferOrder__r.gii__FromWarehouse__c;
                if(mapKeyVsPI.containskey(key)){
                    giic_ReservationUtility.ReservationWrapper objRW = new giic_ReservationUtility.ReservationWrapper();
                    objRW.warehouseId = tolObj.gii__TransferOrder__r.gii__FromWarehouse__c;
                    objRW.Product = tolObj.gii__Product__c;
                    objRW.location = tolObj.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__c;
                    if(mapKeyVsPI.get(key).giic_SalesOnHand__c >= tolObj.gii__Quantity__c ){
                        objRW.qty = tolObj.gii__Quantity__c; 
                    }
                    else{
                        Decimal boQty = mapKeyVsPI.get(key).giic_BackOrderNew__c == null ? 0 : mapKeyVsPI.get(key).giic_BackOrderNew__c;
                        boQty = boQty + (tolObj.gii__Quantity__c - mapKeyVsPI.get(key).giic_SalesOnHand__c);
                        mapKeyVsPI.get(key).giic_BackOrderNew__c = boQty;
                        objRW.qty = mapKeyVsPI.get(key).giic_SalesOnHand__c;
                    }
                    system.debug('objRW.qty = '+objRW.qty );
                    /*if(tolObj.gii__Quantity__c > mapKeyVsPI.get(key).gii__AvailableQuantity__c){
                        Decimal boQty = mapKeyVsPI.get(key).giic_BackOrderNew__c == null ? 0 : mapKeyVsPI.get(key).giic_BackOrderNew__c;
                        boQty = boQty + (tolObj.gii__Quantity__c - mapKeyVsPI.get(key).gii__AvailableQuantity__c);
                        mapKeyVsPI.get(key).giic_BackOrderNew__c = boQty;
                        objRW.qty = mapKeyVsPI.get(key).gii__AvailableQuantity__c;
                    }else{
                        objRW.qty = tolObj.gii__Quantity__c;
                    }*/
                    mapRW.put(key,objRW);  
                } 
            }
        }
        return mapRW;
    }
    
/**
* @author FirstName : Rishabh Bansal Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – method for changing PI Work Order Value based on new TOL qty
* @param tolList-List of gii__TransferOrderLine__c
*/
    public static void addQtyToWOPI(List<gii__TransferOrderLine__c> tolList){
        Set<String> whSet = new Set<String>();
        Set<String> pdtSet = new Set<String>();
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        List<gii__TransferOrderLine__c> tolListNew = new List<gii__TransferOrderLine__c>();
        Map<String,gii__ProductInventory__c> mapKeyVsPI = new Map<String,gii__ProductInventory__c>();
        
        if(Schema.sObjectType.gii__TransferOrderLine__c.isQueryable()){
            tolListNew = [SELECT Id,gii__TransferOrder__c,gii__TransferOrder__r.gii__FromWarehouse__c,gii__TransferOrder__r.gii__TransferToWarehouse__c,
                          gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,
                          gii__Product__c,gii__Warehouse__c,gii__Quantity__c,gii__TransferOrder__r.giic_Source__c
                          FROM gii__TransferOrderLine__c WHERE Id IN:tolList];
        }
        for(gii__TransferOrderLine__c tolObj : tolListNew){
            whSet.add(tolObj.gii__TransferOrder__r.gii__TransferToWarehouse__c);
            pdtSet.add(tolObj.gii__Product__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'pdtSet-------'+pdtSet);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'whSet-------'+whSet);
        // Querying PIQD's
        Map<Id,gii__ProductInventory__c> mapOfIdVsPI;
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__WorkOrderQuantity__c,gii__Warehouse__c,gii__AvailableQuantity__c,giic_Reserved__c,giic_BackOrderNew__c FROM 
                                                                gii__ProductInventory__c WHERE 
                                                                gii__Product__c IN: pdtSet AND gii__Warehouse__c IN: whSet]);   
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI-------'+mapOfIdVsPI);
        for(gii__ProductInventory__c piRec : mapOfIdVsPI.values()){
            String key = piRec.gii__Product__c +'-'+piRec.gii__Warehouse__c;
            mapKeyVsPI.put(key,piRec);
        }
        for(gii__TransferOrderLine__c tolObj : tolListNew){
            String key = tolObj.gii__Product__c +'-'+tolObj.gii__TransferOrder__r.gii__TransferToWarehouse__c;
            if(mapKeyVsPI != null && !mapKeyVsPI.values().isEmpty() &&  mapKeyVsPI.containsKey(key)){
                mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = mapKeyVsPI.get(key).gii__WorkOrderQuantity__c != null ? mapKeyVsPI.get(key).gii__WorkOrderQuantity__c : 0;
                mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = mapKeyVsPI.get(key).gii__WorkOrderQuantity__c + tolObj.gii__Quantity__c;
            }
        }
       XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI-------'+mapOfIdVsPI);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI-------'+mapOfIdVsPI);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI-------'+mapOfIdVsPI);
        if(mapKeyVsPI != null && !mapKeyVsPI.values().isEmpty() && Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
            update mapKeyVsPI.values();
        }
    }
    
/**  
* @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 13/02/2020
* @date Modification dd/mm/yyyy
* @description cancel TO line
* @param transferOdrLineList -  List of TransferOrderLine
*/       
    public static void cancelQtyToWOPI(List<Id> toIds ){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
        Set<String> whSet = new Set<String>();
        Set<String> pdtSet = new Set<String>();
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>(); 
        Map<String,gii__ProductInventory__c> mapKeyVsPI = new Map<String,gii__ProductInventory__c>();
    
        List<gii__TransferOrderLine__c> tolListNew = new List<gii__TransferOrderLine__c>([SELECT Id,gii__TransferOrder__c,gii__TransferOrder__r.gii__FromWarehouse__c,gii__TransferOrder__r.gii__TransferToWarehouse__c,
                          gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,
                          gii__Product__c,gii__Warehouse__c,gii__Quantity__c,gii__TransferOrder__r.giic_Source__c
                          FROM gii__TransferOrderLine__c WHERE gii__TransferOrder__c IN:toIds]);
        
        for(gii__TransferOrderLine__c tolObj : tolListNew){
            whSet.add(tolObj.gii__TransferOrder__r.gii__TransferToWarehouse__c);
            pdtSet.add(tolObj.gii__Product__c);
        }
        Map<Id,gii__ProductInventory__c> mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__WorkOrderQuantity__c,gii__Warehouse__c,gii__AvailableQuantity__c,giic_Reserved__c,giic_BackOrderNew__c FROM 
                                                                gii__ProductInventory__c WHERE 
                                                                gii__Product__c IN: pdtSet AND gii__Warehouse__c IN: whSet]);   
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI-------'+mapOfIdVsPI);
        for(gii__ProductInventory__c piRec : mapOfIdVsPI.values()){
            String key = piRec.gii__Product__c +'-'+piRec.gii__Warehouse__c;
            mapKeyVsPI.put(key,piRec);
        }
        for(gii__TransferOrderLine__c tolObj : tolListNew){
            String key = tolObj.gii__Product__c +'-'+tolObj.gii__TransferOrder__r.gii__TransferToWarehouse__c;
            if(mapKeyVsPI != null && !mapKeyVsPI.values().isEmpty() &&  mapKeyVsPI.containsKey(key)){
                mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = mapKeyVsPI.get(key).gii__WorkOrderQuantity__c != null ? mapKeyVsPI.get(key).gii__WorkOrderQuantity__c : 0;
                mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = mapKeyVsPI.get(key).gii__WorkOrderQuantity__c - tolObj.gii__Quantity__c;

                if(mapKeyVsPI.get(key).giic_BackOrderNew__c != null && mapKeyVsPI.get(key).giic_BackOrderNew__c>=tolObj.gii__Quantity__c) {
                    mapKeyVsPI.get(key).giic_BackOrderNew__c = mapKeyVsPI.get(key).giic_BackOrderNew__c - tolObj.gii__Quantity__c;
                } else if(mapKeyVsPI.get(key).giic_BackOrderNew__c == null) {
                    mapKeyVsPI.get(key).giic_BackOrderNew__c = 0;
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'cancelQtyToWOPI-------');
       XC_UTIL_Debug.debug(DEBUGACTIVE,'mapOfIdVsPI-------'+mapOfIdVsPI);
        if(mapKeyVsPI != null && !mapKeyVsPI.values().isEmpty() && Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
            update mapKeyVsPI.values();
        } 
    }
     
    /**  
* @author FirstName : Sara Miozza - sara.miozza@nttdata.com
* @date Creation 13/02/2020
* @date Modification dd/mm/yyyy
* @description Prevent the creation of TO Lines
* @param transferOdrLineList -  List of TransferOrderLine
*/       
     public static void preventTOLineInsert(List<gii__TransferOrderLine__c> transferOdrLineList){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         XC_UTIL_Debug.debug(DEBUGACTIVE,'preventTOLineInsert-------');
         
         
         
        List<String> toIds = XC_UTIL_Sobject.getListFieldValues(transferOdrLineList, 'gii__TransferOrder__c');
        map<Id, gii__TransferOrder__c> toMaps = new  map<Id, gii__TransferOrder__c>([SELECT Id, giic_status__c ,giic_Source__c FROM gii__TransferOrder__c WHERE Id IN: toIds]);
        for(gii__TransferOrderLine__c tol : transferOdrLineList){
            if(tol.gii__TransferOrder__c!= null && toMaps.get(tol.gii__TransferOrder__c).giic_status__c!=null &&
               toMaps.get(tol.gii__TransferOrder__c).giic_status__c!='Draft' && toMaps.get(tol.gii__TransferOrder__c).giic_status__c!='Open' &&
              toMaps.get(tol.gii__TransferOrder__c).giic_Source__c != Label.giic_OrderSourceAutomation &&  toMaps.get(tol.gii__TransferOrder__c).giic_Source__c != Label.giic_SourceReorderPlanning){     
                tol.addError(Label.giic_CL_NoNewLines);
            }
        
    	}
    }

   /**  
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation 02/12/2020
* @date Modification dd/mm/yyyy
* @description this method checks if tol quantity change
* @param transferOdrLineList -  List of TransferOrderLine
*/
    public static void checkIfQuantityChange(List<gii__TransferOrderLine__c> listNew, Map<id, gii__TransferOrderLine__c> mapNew, Map<id, gii__TransferOrderLine__c> mapOld){
        list<String> fieldsToCheck = new List<string>{'gii__Quantity__c'};
        list<gii__TransferOrderLine__c> listTolChanged = XC_UTIL_Sobject.getListChanged(fieldsToCheck, mapOld, mapNew);
        Giic_TransferOrderLineUtility.reserveQuantitiesForTOL(listTolChanged, mapNew, mapOld);
    }

/**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation  02/12/2020
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – method for reserving quantities on TOL with TO source as manual
* @param tolList-List of gii__TransferOrderLine__c
* @param mapNew map of gii__TransferOrderLine__c
* @param mapOld map of gii__TransferOrderLine__c
*/
public static void reserveQuantitiesForTOL(List<gii__TransferOrderLine__c> tolList, Map<id, gii__TransferOrderLine__c> mapNew, Map<id, gii__TransferOrderLine__c> mapOld){    
    Set<String> whSet = new Set<String>();
    Set<String> pdtSet = new Set<String>();
    Set<String> locSet = new Set<String>();
    Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
    List<gii__TransferOrderLine__c> tolListNew = new List<gii__TransferOrderLine__c>();
    
    if(Schema.sObjectType.gii__TransferOrderLine__c.isQueryable()){
        tolListNew = [SELECT Id,gii__TransferOrder__c,gii__TransferOrder__r.gii__FromWarehouse__c,
                      gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,
                      gii__Product__c,gii__Warehouse__c,gii__Quantity__c,gii__TransferOrder__r.giic_Source__c, gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__c
                      FROM gii__TransferOrderLine__c WHERE Id IN:tolList];
    }
    for(gii__TransferOrderLine__c tolObj : tolListNew){
        whSet.add(tolObj.gii__TransferOrder__r.gii__FromWarehouse__c);
        pdtSet.add(tolObj.gii__Product__c);
        locSet.add(tolObj.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c);
    }
    // Querying PIQD's
    Map<Id,gii__ProductInventory__c> mapOfIdVsPI;
    if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
        mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__Warehouse__c,gii__AvailableQuantity__c, giic_SalesOnHand__c, giic_Reserved__c, giic_BackOrderNew__c, gii__WorkOrderQuantity__c 
                                                            FROM gii__ProductInventory__c WHERE
                                                            gii__Product__c IN: pdtSet AND gii__Warehouse__c IN: whSet]);   
    }
    if(mapOfIdVsPI != null && !mapOfIdVsPI.values().isEmpty()){
        mapRW = reserveQuantitiesForTOLHelperOnUp(tolListNew, mapNew, mapOld, mapOfIdVsPI);
        if(Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
            update mapOfIdVsPI.values();
        }
        if(!mapRW.values().isEmpty()){
            giic_ReservationUtility.reserveQuantities(mapRW.values());
        }
    }
}
    
/**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation  02/12/2020
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – method for reserving quantities on TOL with TO source as manual
* @param tolList List of gii__TransferOrderLine__c
* @param mapNew map of gii__TransferOrderLine__c
* @param mapOld map of gii__TransferOrderLine__c
* @param mapOfIdVsPI Map of Id VS Product Inventory
*/
    public static Map<string,giic_ReservationUtility.ReservationWrapper> reserveQuantitiesForTOLHelperOnUp(List<gii__TransferOrderLine__c> tolListNew, Map<id, gii__TransferOrderLine__c> mapNew, Map<id, gii__TransferOrderLine__c> mapOld, Map<Id,gii__ProductInventory__c> mapOfIdVsPI){
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        Map<String,gii__ProductInventory__c> mapKeyVsPI = new Map<String,gii__ProductInventory__c>();
        for(gii__ProductInventory__c piRec : mapOfIdVsPI.values()){
            String key = piRec.gii__Product__c +'-'+piRec.gii__Warehouse__c;
            mapKeyVsPI.put(key,piRec);
        }
        for(gii__TransferOrderLine__c tolObj : tolListNew){
            if(tolObj.gii__TransferOrder__r.giic_Source__c == 'Manual'){
                String key = tolObj.gii__Product__c +'-'+tolObj.gii__TransferOrder__r.gii__FromWarehouse__c;
                if(mapKeyVsPI.containskey(key)){
                    giic_ReservationUtility.ReservationWrapper objRW = new giic_ReservationUtility.ReservationWrapper();
                    objRW.warehouseId = tolObj.gii__TransferOrder__r.gii__FromWarehouse__c;
                    objRW.Product = tolObj.gii__Product__c;
                    objRW.location = tolObj.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__c;
                    decimal delta = (mapOld.get(tolObj.id).gii__Quantity__c - mapNew.get(tolObj.id).gii__Quantity__c);
                    Decimal boQty = mapKeyVsPI.get(key).giic_BackOrderNew__c == null ? 0 : mapKeyVsPI.get(key).giic_BackOrderNew__c;
                    Decimal woQty = mapKeyVsPI.get(key).gii__WorkOrderQuantity__c == null ? 0 : mapKeyVsPI.get(key).gii__WorkOrderQuantity__c;
                    system.debug('res='+mapKeyVsPI.get(key).giic_Reserved__c );
                    system.debug('delta= '+ delta);
                    system.debug('objRW.qty= '+ objRW.qty);
                    if(delta >= 0){
                        woQty = woQty - delta;
                        mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = woQty;
                        if(boQty >= delta){
                            boQty = boQty - delta;
                            mapKeyVsPI.get(key).giic_BackOrderNew__c = boQty;
                            objRW.qty = 0;
                        }
                        else{
                            mapKeyVsPI.get(key).giic_BackOrderNew__c = 0;
                            objRW.qty = /*tolObj.gii__Quantity__c*/ /*mapKeyVsPI.get(key).giic_Reserved__c*/- (delta - boQty ); 
                            system.debug('objRW.qty= '+ objRW.qty);
                        }
                    }
                    else if(delta < 0){
                        woQty = woQty + math.abs(delta);
                        mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = woQty;
                        if( mapKeyVsPI.get(key).giic_SalesOnHand__c >= math.abs(delta)){
                            objRW.qty = /*mapKeyVsPI.get(key).giic_Reserved__c +*/ math.abs(delta); //sommare alla quantità reserved dalla pi
                        }
                        else{
                            objRW.qty = /*mapKeyVsPI.get(key).giic_Reserved__c +*/ mapKeyVsPI.get(key).giic_SalesOnHand__c;
                            boQty =  boQty + (math.abs(delta) - mapKeyVsPI.get(key).giic_SalesOnHand__c );
                            mapKeyVsPI.get(key).giic_BackOrderNew__c = boQty;
                        }
                    }
                    mapRW.put(key,objRW);  
                } 
            }
        }
        return mapRW;
    }

    /**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation  04/12/2020
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – method for reserve quantities after TOL deletion with TO source as manual
* @param tolList-List of gii__TransferOrderLine__c
* @param mapOld map of gii__TransferOrderLine__c
*/
public static void reserveQuantitiesForTOL(List<gii__TransferOrderLine__c> tolListOld, Map<id, gii__TransferOrderLine__c> mapOld){    
    system.debug('sono entrato');
    system.debug('tolList: '+ tolListOld);
    Set<String> whSet = new Set<String>();
    Set<String> toSet = new Set<String>();
    Set<String> pdtSet = new Set<String>();
    Set<String> locSet = new Set<String>();
    Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
    //List<gii__TransferOrderLine__c> tolListOld = new List<gii__TransferOrderLine__c>();
    
    /*if(Schema.sObjectType.gii__TransferOrderLine__c.isQueryable()){
        tolListOld = [SELECT Id,gii__TransferOrder__c,gii__TransferOrder__r.gii__FromWarehouse__c,
                      gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c,
                      gii__Product__c,gii__Warehouse__c,gii__Quantity__c,gii__TransferOrder__r.giic_Source__c, gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__c
                      FROM gii__TransferOrderLine__c WHERE Id IN:tolList ALL ROWS];
    }*/
    for(gii__TransferOrderLine__c tolObj : tolListOld){
        toSet.add(mapOld.get(tolObj.id).gii__TransferOrder__c/*.gii__FromWarehouse__c*/);
        pdtSet.add(mapOld.get(tolObj.id).gii__Product__c);
        //locSet.add(mapOld.get(tolObj.id).gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c);
    }
    Map<id, gii__TransferOrder__c> toMap = new Map<id, gii__TransferOrder__c>([SELECT id, gii__FromWarehouse__c, gii__FromWarehouse__r.gii__DefaultIssueLocation__c, giic_Source__c FROM
                                                                             gii__TransferOrder__c WHERE 
                                                                             id IN:toSet]); 

    for(gii__TransferOrder__c toObj : toMap.values()){
        whSet.add(toObj.gii__FromWarehouse__c);
    }
    Map<id, gii__Warehouse__c> whMap = new Map<id, gii__Warehouse__c>([SELECT id, gii__DefaultIssueLocation__c, gii__DefaultReceivingLocation__c FROM
                                                                        gii__Warehouse__c WHERE
                                                                         id IN:whSet]);
    for(gii__Warehouse__c whObj : whMap.values()){
        locSet.add(whObj.gii__DefaultIssueLocation__c);
    }
    system.debug('whSet: '+ whSet);
    system.debug('pdtSet: '+ pdtSet);
    system.debug('locSet: '+ locSet);
    // Querying PIQD's
    Map<Id,gii__ProductInventory__c> mapOfIdVsPI;
    if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
        mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__Warehouse__c,gii__AvailableQuantity__c, giic_SalesOnHand__c, giic_Reserved__c, giic_BackOrderNew__c, gii__WorkOrderQuantity__c FROM 
                                                            gii__ProductInventory__c WHERE 
                                                            gii__Product__c IN: pdtSet AND gii__Warehouse__c IN: whSet]);   
    }
    system.debug('mapOfIdVsPI: '+ mapOfIdVsPI);
    if(mapOfIdVsPI != null && !mapOfIdVsPI.values().isEmpty()){
        mapRW = reserveQuantitiesForTOLHelperOnDel(tolListOld, mapOld, mapOfIdVsPI, toMap, whMap);
        if(Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
            update mapOfIdVsPI.values();
        }
        if(!mapRW.values().isEmpty()){
            giic_ReservationUtility.reserveQuantities(mapRW.values());
        }
    }
}

/**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation  02/12/2020
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderLineUtility – method for reserving quantities on TOL with TO source as manual
* @param tolList List of gii__TransferOrderLine__c
* @param mapOld map of gii__TransferOrderLine__c
* @param mapOfIdVsPI Map of Id VS Product Inventory
*/
    public static Map<string,giic_ReservationUtility.ReservationWrapper> reserveQuantitiesForTOLHelperOnDel(List<gii__TransferOrderLine__c> tolListOld, Map<id, gii__TransferOrderLine__c> mapOld, Map<Id,gii__ProductInventory__c> mapOfIdVsPI, Map<id, gii__TransferOrder__c> toMap, Map<id, gii__Warehouse__c> whMap){
        system.debug('sono entrato');
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        Map<String,gii__ProductInventory__c> mapKeyVsPI = new Map<String,gii__ProductInventory__c>();
        for(gii__ProductInventory__c piRec : mapOfIdVsPI.values()){
            String key = piRec.gii__Product__c +'-'+piRec.gii__Warehouse__c;
            mapKeyVsPI.put(key,piRec);
        }
        system.debug('mapKeyVsPI: '+ mapKeyVsPI);
        for(gii__TransferOrderLine__c tolObj : tolListOld){
            //if(toMap.get(tolObj.gii__TransferOrder__c).giic_Source__c == 'Manual'){
                String key = tolObj.gii__Product__c +'-'+toMap.get(tolObj.gii__TransferOrder__c).gii__FromWarehouse__c;
                system.debug('contain: '+mapKeyVsPI.containskey(key) );
                if(mapKeyVsPI.containskey(key)){
                    giic_ReservationUtility.ReservationWrapper objRW = new giic_ReservationUtility.ReservationWrapper();
                    objRW.warehouseId = toMap.get(tolObj.gii__TransferOrder__c).gii__FromWarehouse__c;
                    objRW.Product = tolObj.gii__Product__c;
                    objRW.location = whMap.get(toMap.get(tolObj.gii__TransferOrder__c).gii__FromWarehouse__c).gii__DefaultReceivingLocation__c;
                    decimal delta = mapOld.get(tolObj.id).gii__Quantity__c;
                    Decimal boQty = mapKeyVsPI.get(key).giic_BackOrderNew__c == null ? 0 : mapKeyVsPI.get(key).giic_BackOrderNew__c;
                    Decimal woQty = mapKeyVsPI.get(key).gii__WorkOrderQuantity__c == null ? 0 : mapKeyVsPI.get(key).gii__WorkOrderQuantity__c;
                    system.debug('res='+mapKeyVsPI.get(key).giic_Reserved__c );
                    system.debug('delta= '+ delta);
                    system.debug('objRW.qty= '+ objRW.qty);
                    woQty = woQty - delta;
                    mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = woQty;
                    if(boQty >= delta){
                        boQty = boQty - delta;
                        mapKeyVsPI.get(key).giic_BackOrderNew__c = boQty;
                        objRW.qty = 0;
                    }
                    else{
                        mapKeyVsPI.get(key).giic_BackOrderNew__c = 0;
                        objRW.qty = /*tolObj.gii__Quantity__c*/ /*mapKeyVsPI.get(key).giic_Reserved__c*/- delta + boQty; 
                        system.debug('objRW.qty= '+ objRW.qty);
                    }
                    mapRW.put(key,objRW);  
                } 
            //}
        }
        return mapRW;
    }

/**
* @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation  10/12/2020
* @date Modification dd/mm/yyyy
* @description  method for reserve quantities for Tol after TO deletion with TO source as manual
* @param tolList List of gii__TransferOrderLine__c
*/
    public static void reserveQuantitiesForTolAfterToDel(List<gii__TransferOrderLine__c> tolList){
        Set<String> whSet = new Set<String>();
        Set<String> pdtSet = new Set<String>();
        Set<String> locSet = new Set<String>();
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        
        for(gii__TransferOrderLine__c tolObj : tolList){
            whSet.add(tolObj.gii__TransferOrder__r.gii__FromWarehouse__c);
            pdtSet.add(tolObj.gii__Product__c);
            locSet.add(tolObj.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultIssueLocation__c);
        }
        // Querying PIQD's
        Map<Id,gii__ProductInventory__c> mapOfIdVsPI;
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__Warehouse__c,gii__AvailableQuantity__c, giic_SalesOnHand__c, giic_Reserved__c, giic_BackOrderNew__c FROM 
                                                                gii__ProductInventory__c WHERE 
                                                                gii__Product__c IN: pdtSet AND gii__Warehouse__c IN: whSet]);   
        }

        
        if(mapOfIdVsPI != null && !mapOfIdVsPI.values().isEmpty()){
            mapRW = reserveQuantitiesForTolAfterToDelHelper(tolList,mapOfIdVsPI);
            if(Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
                System.debug('aggiorno : '+mapOfIdVsPI.values() );
                update mapOfIdVsPI.values();
            }
            if(!mapRW.values().isEmpty()){
                giic_ReservationUtility.reserveQuantities(mapRW.values());
            }
        }
    }

    /**
* @author FirstName : Alberto Pompei alberto.pompei@nttdata.com
* @date Creation 10/12/2020
* @date Modification dd/mm/yyyy
* @description method for reserving quantities on TOL after TO deletion with TO source as manual
* @param tolList List of gii__TransferOrderLine__c
* @param mapOfIdVsPI Map of Id VS Product Inventory
* @return reserveQuantitiesForTOLHelper-Map of String VS giic_ReservationUtility.ReservationWrapper
*/
public static Map<string,giic_ReservationUtility.ReservationWrapper> reserveQuantitiesForTolAfterToDelHelper(List<gii__TransferOrderLine__c> tolList,Map<Id,gii__ProductInventory__c> mapOfIdVsPI){
    Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
    Map<String,gii__ProductInventory__c> mapKeyVsPI = new Map<String,gii__ProductInventory__c>();
    for(gii__ProductInventory__c piRec : mapOfIdVsPI.values()){
        String key = piRec.gii__Product__c +'-'+piRec.gii__Warehouse__c;
        mapKeyVsPI.put(key,piRec);
    }
    for(gii__TransferOrderLine__c tolObj : tolList){
        
            String key = tolObj.gii__Product__c +'-'+tolObj.gii__TransferOrder__r.gii__FromWarehouse__c;
            if(mapKeyVsPI.containskey(key)){
                giic_ReservationUtility.ReservationWrapper objRW = new giic_ReservationUtility.ReservationWrapper();
                objRW.warehouseId = tolObj.gii__TransferOrder__r.gii__FromWarehouse__c;
                objRW.Product = tolObj.gii__Product__c;
                objRW.location = tolObj.gii__TransferOrder__r.gii__FromWarehouse__r.gii__DefaultReceivingLocation__c;
                Decimal boQty = mapKeyVsPI.get(key).giic_BackOrderNew__c == null ? 0 : mapKeyVsPI.get(key).giic_BackOrderNew__c;
                decimal delta = tolObj.gii__Quantity__c;
                if(boQty >= delta ){
                    boQty = boQty - delta;
                    mapKeyVsPI.get(key).giic_BackOrderNew__c = boQty;
                    objRW.qty = 0; 
                }
                else{
                    mapKeyVsPI.get(key).giic_BackOrderNew__c = 0;
                    objRW.qty = - delta + boQty;
                }
                system.debug('objRW.qty = '+objRW.qty );
                mapRW.put(key,objRW);  
            } 
        
    }
    return mapRW;
}

/**
* @author FirstName : Alberto Pompei alberto.pompei@nttdata.com
* @date Creation 11/12/2020
* @date Modification dd/mm/yyyy
* @description method to check if a TO of a TOL is merged
* @param tolList List of gii__TransferOrderLine__c
* @return List<gii__TransferOrderLine__c> tolList - list of TOL with TO not merged
*/
    public static List<gii__TransferOrderLine__c> getTolWithToNotMerged(List<gii__TransferOrderLine__c> tolList){
        List<gii__TransferOrderLine__c> tolListToNotMerged = new List<gii__TransferOrderLine__c>();
        Set<string> toSet = New Set<string>();
        for(gii__TransferOrderLine__c tolObj : tolList){
            toSet.add(tolObj.gii__TransferOrder__c);
        }
        Map<id, gii__TransferOrder__c> toMap = new Map<id, gii__TransferOrder__c>([SELECT id, Giic_IsMergedResult__c FROM gii__TransferOrder__c WHERE id IN: toSet]);
        for(gii__TransferOrderLine__c tolObj : tolList){
            if(toMap.get(tolObj.gii__TransferOrder__c).Giic_IsMergedResult__c != true){
                tolListToNotMerged.add(tolObj);
            }
        }
        return tolListToNotMerged;
    }
    
	public static void SetPartnerGRGI(List<gii__TransferOrderLine__c> TolList){
		Set<id> productIds = New Set<id>();
		
		for(gii__TransferOrderLine__c tol : TolList){
			productIds.add(tol.gii__Product__c);
		}

        if (!productIds.isEmpty()) {
			map<string,gii__Product2Add__c> mapProd = new Map<string,gii__Product2Add__c>([SELECT id, giic_PartnerGRGI__c FROM gii__Product2Add__c WHERE id IN: productIds]);
	
				for(gii__TransferOrderLine__c objTOL : TolList){
					if(mapProd.containskey(objTOL.gii__Product__c)){
						if(mapProd.get(objTOL.gii__Product__c).giic_PartnerGRGI__c) {objTOL.Giic_PartnerGRGI__c = TRUE;}
					}
				}
        }
	}
    /**  
* @author FirstName :Alberto Pompei - alberto.pompei@nttdata.com
* @date Creation 07/09/2021
* @date Modification dd/mm/yyyy
* @description to check if the warehouse change and align quantities
* @param List<gii__TransferOrderLine__c> -  List of transfer order line
* @param Map<Id,gii__TransferOrderLine__c> -  Map of transfer order line old
* @param Map<Id,gii__TransferOrderLine__c> -  Map of transfer order line new
*/
    //NR2097
    public static void checkIfWhChange(List<gii__TransferOrderLine__c> listNew,Map<Id,gii__TransferOrderLine__c> mapOld, Map<Id,gii__TransferOrderLine__c> mapNew){
        system.debug('entrato in checkIfWhChange');   
        List<String> fieldList = new List<String>{'gii__Warehouse__c'};
        List<gii__TransferOrderLine__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        alignQuantity(listChanged, mapOld);
        system.debug('uscito da checkIfWhChange');   
    }

    public static void alignQuantity(List<gii__TransferOrderLine__c> listNew, Map<Id,gii__TransferOrderLine__c> mapOld ){
        system.debug('entrato in alignQuantity');
        //to reserve quantities on new WH
        reserveQuantitiesForTOL(listNew, true);
        //to unreserve quantities on old WH
        unreserveQuantitiesOnWhOld(mapOld.values(), mapOld);
        system.debug('uscito da alignQuantity');
    }

    public static void unreserveQuantitiesOnWhOld(List<gii__TransferOrderLine__c> tolListOld, Map<id, gii__TransferOrderLine__c> mapOld){    
        system.debug('entrato in unresrveQuantitiesOnWhOld');
        system.debug('tolList: '+ tolListOld);
        Set<String> whSet = new Set<String>();
        Set<String> pdtSet = new Set<String>();
        Set<String> locSet = new Set<String>();
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        
        for(gii__TransferOrderLine__c tolObj : tolListOld){
            pdtSet.add(mapOld.get(tolObj.id).gii__Product__c);
            whSet.add(mapOld.get(tolObj.id).gii__Warehouse__c);
        }
        
        Map<id, gii__Warehouse__c> whMap = new Map<id, gii__Warehouse__c>([SELECT id, gii__DefaultIssueLocation__c, gii__DefaultReceivingLocation__c FROM
                                                                            gii__Warehouse__c WHERE
                                                                             id IN:whSet]);
        for(gii__Warehouse__c whObj : whMap.values()){
            locSet.add(whObj.gii__DefaultIssueLocation__c);
        }

        system.debug('whSet: '+ whSet);
        system.debug('pdtSet: '+ pdtSet);
        system.debug('locSet: '+ locSet);
        // Querying PIQD's
        Map<Id,gii__ProductInventory__c> mapOfIdVsPI;
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            mapOfIdVsPI = new Map<Id,gii__ProductInventory__c>([SELECT gii__Product__c,gii__Warehouse__c,gii__AvailableQuantity__c, giic_SalesOnHand__c, giic_Reserved__c, giic_BackOrderNew__c, gii__WorkOrderQuantity__c FROM 
                                                                gii__ProductInventory__c WHERE 
                                                                gii__Product__c IN: pdtSet AND gii__Warehouse__c IN: whSet]);   
        }
        system.debug('mapOfIdVsPI: '+ mapOfIdVsPI);
        if(mapOfIdVsPI != null && !mapOfIdVsPI.values().isEmpty()){
            mapRW = unreserveQuantitiesOnWhOldHelper(tolListOld, mapOld, mapOfIdVsPI, whMap);
            if(Schema.sObjectType.gii__ProductInventory__c.isUpdateable()){
                update mapOfIdVsPI.values();
            }
            if(!mapRW.values().isEmpty()){
                giic_ReservationUtility.reserveQuantities(mapRW.values());
            }
        }
    }

    public static Map<string,giic_ReservationUtility.ReservationWrapper> unreserveQuantitiesOnWhOldHelper(List<gii__TransferOrderLine__c> tolListOld, Map<id, gii__TransferOrderLine__c> mapOld, Map<Id,gii__ProductInventory__c> mapOfIdVsPI, Map<id, gii__Warehouse__c> whMap){
        system.debug('entrato in unreserveQuantitiesOnWhOldHelper ');
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        Map<String,gii__ProductInventory__c> mapKeyVsPI = new Map<String,gii__ProductInventory__c>();
        for(gii__ProductInventory__c piRec : mapOfIdVsPI.values()){
            String key = piRec.gii__Product__c +'-'+piRec.gii__Warehouse__c;
            mapKeyVsPI.put(key,piRec);
        }
        system.debug('mapKeyVsPI: '+ mapKeyVsPI);
        Map<id,id> mapWhVsLoc = New Map<id,id>();
        for(gii__Warehouse__c wh : whMap.values()){
            mapWhVsLoc.put(wh.Id, wh.gii__DefaultReceivingLocation__c);
        }
        for(gii__TransferOrderLine__c tolObj : tolListOld){
                String key = tolObj.gii__Product__c +'-'+mapOld.get(tolObj.id).gii__Warehouse__c;
                system.debug('contain: '+mapKeyVsPI.containskey(key) );
                if(mapKeyVsPI.containskey(key)){
                    giic_ReservationUtility.ReservationWrapper objRW = new giic_ReservationUtility.ReservationWrapper();
                    objRW.warehouseId = mapOld.get(tolObj.id).gii__Warehouse__c;
                    objRW.Product = tolObj.gii__Product__c;
                    objRW.location = mapWhVsLoc.get(mapOld.get(tolObj.id).gii__Warehouse__c);
                    system.debug('warehouseId: '+ objRW.warehouseId);
                    system.debug('Product: '+ objRW.Product);
                    system.debug('location: '+ objRW.location);
                    decimal delta = mapOld.get(tolObj.id).gii__Quantity__c;
                    Decimal boQty = mapKeyVsPI.get(key).giic_BackOrderNew__c == null ? 0 : mapKeyVsPI.get(key).giic_BackOrderNew__c;
                    Decimal woQty = mapKeyVsPI.get(key).gii__WorkOrderQuantity__c == null ? 0 : mapKeyVsPI.get(key).gii__WorkOrderQuantity__c;
                    system.debug('res='+mapKeyVsPI.get(key).giic_Reserved__c );
                    system.debug('delta= '+ delta);
                    system.debug('objRW.qty= '+ objRW.qty);
                    woQty = woQty - delta;
                    mapKeyVsPI.get(key).gii__WorkOrderQuantity__c = woQty;
                    if(boQty >= delta){
                        boQty = boQty - delta;
                        mapKeyVsPI.get(key).giic_BackOrderNew__c = boQty;
                        objRW.qty = 0;
                    }
                    else{
                        mapKeyVsPI.get(key).giic_BackOrderNew__c = 0;
                        objRW.qty = - delta + boQty; 
                        system.debug('objRW.qty= '+ objRW.qty);
                    }
                    mapRW.put(key,objRW);  
                } 
        }
        return mapRW;
    }

}
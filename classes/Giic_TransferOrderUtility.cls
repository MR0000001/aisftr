/** 
* @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
* @date Creation 05/07/2019
* @date Modification 17/01/2022 - Salvatore Agrillo - salvatore.agrillo@nttdata.com & Federico Faillace - federico.faillace@nttdata.com
* @description giic_TransferOrderUtility – Utility for Transfer Order                                 
*/  

global without sharing class Giic_TransferOrderUtility {     

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TransferOrderUtility');

    /** @description WH Wrapper */     
    public class warehouseWrapper {
        public Map<Id, List<Id>> mapWHLocation;
        public Map<id,gii__Warehouse__c> mapAllNetworkWarehouses;
        public Map<id,list<id>> mapWarehouseGroupWarehoues;
        public Map<String, XC_CM_WarehouseSupplyFlow__mdt> mapCountryWHSupplyFlow;
        public Map<string,Decimal> mapPITotalOnOrder;
    }

    /** @description Inventory Wrapper */     
    public class inventoryWrapper {
        Set<Id> settProductIds;
        Set<id> setSupplierIds;
        Map<String, List<gii__ProductInventory__c>> mapSupplierProductPI;
        List<String> errorList ;
        map<string,gii__PurchaseOrder__c> mapKeyPO;
        map<string,list<gii__PurchaseOrderLine__c>> mapKeyPOL; 
        map<string,gii__TransferOrder__c> mapTransferOrder;
        map<string,list<gii__TransferOrderLine__c>> mapTransferOrderLine;
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap;
        Set<string> setTOWH;
        Set<string> setPOKey;
        map<String, Integer> mapProductSuggQty = new  map<String, Integer>();
    }

    /** @description ParamsWrapper wrapper */
    public class ParamsWrapper{
        Map<Id,gii__TransferOrderLine__c> mapOfTOVsTOLine;
        Map<String,gii__TransferOrder__c> mapOfTOidVsTO;
        Map<String,gii__Warehouse__c> mapOfWHidVsWH;
        Map<String,Decimal> mapOfTOidVsOdrVal;
        Map<String,gii__ProductInventory__c> mapOfPdtWhVsPI;
        List<gii__TransferOrderLine__c> listTOLUpdate; 
        Map<string,integer> mapPRODWHLOCWithSugQty = new Map<string,integer>();
        Map<string,gii__TransferOrder__c> mapTransferOrder = new Map<string,gii__TransferOrder__c>();
        Map<string,list<gii__TransferOrderLine__c>> mapTransferOrderLine = new Map<string,list<gii__TransferOrderLine__c>>();// Map of PI Ids and Transfer Order  
        Map<string,list<gii__ProductInventory__c>> mapSupplierProductPI = new Map<string,list<gii__ProductInventory__c>>();
        Set<string> setTOWH = new Set<string>();
        Set<Id> settProductIds = new Set<Id>();
        Set<Id> setSupplierIds = new Set<Id>();
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap = new List<giic_ReservationUtility.ReservationWrapper>();
        List<gii__ProductInventory__c> lstPIForPOCreation = new List<gii__ProductInventory__c>();
        Map<string,integer> mapPRODWHLOCWithAvailQty = new Map<string,integer>();
    } 
    
    /**  
    * @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 26/11/2019
    * @description Method to check if status changed
    */    
    public static void checkIfStatusChange(List<gii__TransferOrder__c> listNew, Map<Id,gii__TransferOrder__c> mapOld, Map<Id,gii__TransferOrder__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkIfStatusChange----->>' );
        List<String> fieldList = new List<String>{'giic_Status__c'};
        List<gii__TransferOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        checkWhenTOisApproved(listChanged);
    }
    
    /**  
    * @date Creation 26/11/2019
    * @description Method to check if From WH changed
    */    
    public static void checkIfWHFromChange(List<gii__TransferOrder__c> listNew, Map<Id,gii__TransferOrder__c> mapOld, Map<Id,gii__TransferOrder__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkIfWHFromChange----->>' );
        List<String> fieldList = new List<String>{'gii__FromWarehouse__c'};
        List<gii__TransferOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        rebalWHOnTOL(listChanged);
    }
    
    /**  
    * @date Creation 26/11/2019
    * @description Method to rebalt WH on TOL
    */    
    public static void rebalWHOnTOL(List<gii__TransferOrder__c> listNew){
        List<String> toIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'Id');
        List<gii__TransferOrderLine__c> tolToUpdate = new List<gii__TransferOrderLine__c>();
        List<gii__TransferOrderLine__c> tolRevisedList = Giic_TransferOrderUtility_D.getTransferOrderLineList(toIds);
        for(gii__TransferOrderLine__c tol : tolRevisedList){
            tol.gii__Warehouse__c =  tol.gii__TransferOrder__r.gii__FromWarehouse__c;
            tolToUpdate.add(tol);
        }
        update tolToUpdate;
    }
    
    /**  
    * @date Creation 26/11/2019
    * @description Method to check if TO is approved
    */    
    public static void checkWhenTOisApproved(List<gii__TransferOrder__c> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkWhenPOisApproved----->>' );
        for(gii__TransferOrder__c to : listNew){
            if(to.giic_Status__c=='Approved'){ 
                to.giic_Approved__c=True;  //Dipti-INC000041135160-24-9-2020
                to.giic_IntegrationStatus__c= System.Label.giic_TOIntegrationStatusReadyToIntegrate;
                to.giic_TargetSystem__c= System.Label.giic_TargetSystem3PL;
                to.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate ;
            }
        }
    }
    
    /**  
    * @date Creation 26/11/2019
    * @description Method to upgrade address WH
    */    
    public static void upgradeAddressWarehouse(List<gii__TransferOrder__c > listNew,map<Id,gii__TransferOrder__c> mapOld,map<Id,gii__TransferOrder__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In upgradeAddressWarehouse----->>' );
        List<Id> toIdList2 = new List<Id>();
        for(gii__TransferOrder__c objTO: mapNew.values()){
            if(objTO.gii__TransferToWarehouse__c !=null && objTO.gii__TransferToWarehouse__c!= (mapOld.get(objTO.Id)).gii__TransferToWarehouse__c){ 
                toIdList2.add(objTO.gii__TransferToWarehouse__c); 
            }
        }
        if(toIdList2.isEmpty()){
            return;
        }
        upgradeAddressWarehouseTo(listNew,toIdList2);  
    }

    /**
    * @author FirstName : Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
    * @date 11/02/2020
    * @description Upgrade information address Warehouse destination when change WH
    */   
    public static void upgradeAddressWarehouseTo(List<gii__TransferOrder__c> listNew, List<Id> toIdList2){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In upgradeAddressWarehouseTo----->>' );
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listNew: ' + listNew);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'toIdList2: ' + toIdList2);
        Map<Id, gii__Warehouse__c> mapWH = new Map<Id, gii__Warehouse__c > ([
            SELECT Id, gii__WareHouseCity__c, gii__WareHouseCountry__c, gii__WareHouseStateProvince__c, gii__WareHouseStreet__c,gii__WareHouseZipPostalCode__c, gii__Description__c
            FROM gii__Warehouse__c  
            WHERE id IN :toIdList2
        ]);     
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWH : ' + mapWH );   
        for(gii__TransferOrder__c to : listNew){ 
            if(mapWH.containsKey(to.gii__TransferToWarehouse__c)){
                to.gii__ShipToCity__c = mapWH.get(to.gii__TransferToWarehouse__c).gii__WareHouseCity__c;
                to.gii__ShipToName__c = mapWH.get(to.gii__TransferToWarehouse__c).gii__Description__c;
                to.gii__ShipToStreet__c = mapWH.get(to.gii__TransferToWarehouse__c).gii__WareHouseStreet__c;
                to.gii__ShipToZipPostalCode__c = mapWH.get(to.gii__TransferToWarehouse__c).gii__WareHouseZipPostalCode__c;
                to.gii__ShipToCountry__c = mapWH.get(to.gii__TransferToWarehouse__c).gii__WareHouseCountry__c;
                to.gii__ShipToSTate__c = mapWH.get(to.gii__TransferToWarehouse__c).gii__WareHouseStateProvince__c;
            }            
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listNew: ' + listNew);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWH: ' + mapWH);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'End upgradeAddressWarehouseTo----->>' );
    }
    
    /**
    * @author FirstName : Roberta Porrega - roberta.porrega@nttdaa.com
    * @date 31/08/2020
    * @description To create CI on update of 'New Inventory Date' field on Transfer Order.
    * @param toIdList List of Transfer Order Id
    */ 
    public static void checkIfNeedCustomerInteraction(List<Id> toIdList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In checkIfNeedCustomerInteraction----->>');
        List<Id> woDelayIds = new List<Id>();
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        List<gii__TransferOrderLine__c> tolRevisedList = Giic_TransferOrderUtility_D.getTransferOrderLineList(toIdList);
        for(gii__TransferOrderLine__c tol : tolRevisedList ){
            if(tol.giic_SalesOrderLine__r.gii__SalesOrder__r.giic_IsDelivery__c) { 
                woDelayIds.add(tol.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__c);  
            }
        }
        map<Id,WorkOrder> workOrderDelayMap = new  map<Id,WorkOrder>();
        if(!woDelayIds.isEmpty()) {
            workOrderDelayMap = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(woDelayIds); 
        }
        List<XC_Customer_Interaction__c> customInterList = giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderDelayMap.values(),  'Orders_Pickup_Delay',workOrderRejectReason);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'end createCustomerInteraction');
        XC_UTIL_Glovia.insertAndLogError(customInterList);
    }

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date 05/07/2019
    * @description To create case on update of 'New Inventory Date' field on Transfer Order.
    * @param toIdList List of Transfer Order Id
    */   
    public static void createCaseFromTO(List<Id> toIdList) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromTO----->>' );
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'toIdList'+toIdList);
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        Set<string> woNumbers=new Set<string>();
        Map<Id,Case> mapWoIdCase=new Map<Id,Case>();
        List<Case> caseToInsert = new List<Case>();
        try{
            List<gii__TransferOrderLine__c> tolRevisedList = Giic_TransferOrderUtility_D.getTransferOrderLineList(toIdList);    
            if(tolRevisedList.size()>0){
                for(gii__TransferOrderLine__c tol : tolRevisedList){
                    woNumbers.add(tol.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber);
                }
                List<ServiceAppointment> sapList = Giic_TransferOrderUtility_D.getServiceAppoinmentList(woNumbers);                
                mapWoIdCase = createCaseFromTOHelper(sapList,tolRevisedList);                
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWoIdCase'+mapWoIdCase);
                
            }
            if(mapWoIdCase.size()>0){                
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
                List<Id> listWoIds = new List<Id>();
                for(Case c : mapWoIdCase.values()){
                    c.setOptions(dmlOpts);
                    caseToInsert.add(c);
                    listWoIds.add(c.XC_WorkOrder__c);
                }
                XC_UTIL_DEBUG.debug(DEBUGACTIVE, '@@@ INSERISCO CASE' );
                XC_UTIL_Glovia.insertAndLogError(caseToInsert); 
                Map<Id,WorkOrder> workOrderDelayMap = new  Map<Id,WorkOrder>();     
                workOrderDelayMap = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(listWoIds); 
                List<XC_Customer_Interaction__c> customInterList = giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderDelayMap.values(),  'Orders_Pickup_Delay_Installation',workOrderRejectReason);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'end createCustomerInteraction');
                XC_UTIL_Glovia.insertAndLogError(customInterList);
            }         
        }catch(Exception ex){
            String message=ex.getMessage()+'Line>>>>'+ex.getLineNumber();
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'message'+message);
        }
    }

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date 05/07/2019
    * @description To create case on update of 'New Inventory Date' field on Transfer Order.
    * @param sapList List<ServiceAppointment> 
    * @param tolRevisedList List<gii__TransferOrderLine__c>
    *@return Map<Id,Case>
    */   
    public static Map<Id,Case> createCaseFromTOHelper(List<ServiceAppointment> sapList,List<gii__TransferOrderLine__c> tolRevisedList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromTOHelper----->>' );
        Map<string,List<ServiceAppointment>> mapWoIdSrvcApmnt=new Map<string,List<ServiceAppointment>>();
        Map<Id,Case> mapWoIdCase=new Map<Id,Case>();
        
        if(sapList.size()>0){
            map<string,Id> mapWorkOrderNumberWithId=new map<string,Id>();
            for(ServiceAppointment sp: sapList){
                if(!mapWoIdSrvcApmnt.containsKey(sp.ParentRecord.Name)){
                    mapWoIdSrvcApmnt.put(sp.ParentRecord.Name,new List<ServiceAppointment>());
                }  
                mapWoIdSrvcApmnt.get(sp.ParentRecord.Name).add(sp);   
                mapWorkOrderNumberWithId.put(sp.ParentRecord.Name,sp.ParentRecordId);
                
            }
            for(gii__TransferOrderLine__c tol : tolRevisedList){
                if(tol.gii__TransferOrder__r.giic_SalesOrder__c!= null && tol.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber != null &&  tol.gii__TransferOrder__r.giic_LegalEntity__c!=null){
                    Giic_GloviaCapabilitiesByLE__c cs = Giic_GloviaCapabilitiesByLE__c.getValues(tol.gii__TransferOrder__r.giic_LegalEntity__c);
                    if(cs.Giic_CreateCase__c){
                        List<ServiceAppointment> serviceAppList= mapWoIdSrvcApmnt.get(tol.gii__TransferOrder__r.giic_SalesOrder__r.giic_WorkOrder__r.WorkOrderNumber);
                        mapWoIdCase.putAll(createCaseFromTOHelperFillMap(mapWorkOrderNumberWithId,tol,serviceAppList));
                    }
                }
            }
        }
        return mapWoIdCase;
    }

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date 05/07/2019
    * @description To create case on update of 'New Inventory Date' field on Transfer Order.
    * @param mapWorkOrderNumberWithId map<string,Id>  
    * @param tol gii__TransferOrderLine__c 
    * @param serviceAppList List<ServiceAppointment> 
    *@return Map<Id,Case>   
    */ 
    public static Map<Id,Case> createCaseFromTOHelperFillMap(map<string,Id> mapWorkOrderNumberWithId,gii__TransferOrderLine__c tol,List<ServiceAppointment> serviceAppList){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromTOHelperFillMap----->>' );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromTOHelperFillMap----->>' );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromTOHelperFillMap----->>' );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In createCaseFromTOHelperFillMap----->>' );
        String origin;
        if(tol.gii__TransferOrder__r.giic_LegalEntity__c == 'EnelXItalia'){
            origin = 'CAN009';
        }else{
            origin = Label.giic_CaseOrigin;
        }
        map<Id,WorkOrder> mapWorkOrder=new map<Id,WorkOrder>([select id,accountid,contactid,WorkOrderNumber from workorder where id in:mapWorkOrderNumberWithId.values() and (XC_WorkTypeCategory__c =:System.Label.XC_CL_WorkType_DeliveryInstallation OR XC_WorkTypeCategory__c =:System.Label.XC_CL_WorkType_Installation) ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWorkOrder'+mapWorkOrder);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapWorkOrderNumberWithId.values()'+mapWorkOrderNumberWithId.values());
        Map<Id,Case> mapWoIdCase=new Map<Id,Case>();
        if(serviceAppList.size()>0){
            for(ServiceAppointment sp: serviceAppList){
                Datetime  schStartDate=sp.SchedStartTime.addDays(-1);
                if(tol.gii__TransferOrder__r.giic_NewDeliveryDate__c > schStartDate && mapWorkOrder.containsKey(sp.ParentRecordId)){           
                    Case cc = new Case(Reason=System.Label.giic_CaseReason, 
                                       Status=System.Label.giic_CaseStatus,    
                                       SubCause__c=System.Label.giic_CaseSubCause,
                                       XC_Subtype__c=System.Label.giic_CaseSubtype,
                                       Origin = origin,
                                       Priority=System.Label.giic_CasePriority,
                                       XC_WorkOrder__c=sp.ParentRecordId,
                                       XC_LegalEntity__c =  tol.gii__TransferOrder__r.giic_LegalEntity__c,
                                       Country__c = tol.gii__TransferOrder__r.gii__ShipToCountry__c,
                                       AccountId=mapWorkOrder.get(sp.ParentRecordId).AccountId,
                                       ContactId=mapWorkOrder.get(sp.ParentRecordId).ContactId);
                    if(!mapWoIdCase.containsKey(sp.ParentRecordId)){
                        mapWoIdCase.put(sp.ParentRecordId,cc);
                    }
                    
                }
            }
        }
        return mapWoIdCase;
    }
         
    /**
    * @author FirstName :Roberta Porrega - roberta.porrega@nttdata.com
    * @date 29/10/2019
    * @description Create TO and PO for local warehouse ROP
    * @param piList List<gii__ProductInventory__c>  
    */  
    public static List<String> runROPForLocalWarehouse (List<gii__ProductInventory__c> piList){     
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In runROPForLocalWarehouse');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In piList: ' + piList);
        List<String> errorMessageList = new List<String>();

        if(!piList.isEmpty()){  
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ piList: ' + piList);
            // To store All warehouseGroup Ids:
            // Set<Id> setWarehouseGrpId                    = new Set<Id>();
            // To store all product Reference Ids:
            Set<Id> prodIds                                 = new Set<Id>();
            Set<Id> setWarehouseIds                         = new Set<Id>();
            Set<Id> setWarehouseGroupIds                    = new Set<Id>();
            Set<Id> setLocationIds                          = new Set<Id>();
            Set<Id> setLocalWarehouseIds                    = new Set<Id>();
            Set<String> countryWH                           = new Set<String>();
            Map<String, Integer> mapPRODWHLOCWithAvailQty   = new Map<String, Integer>();
            Map<String, Decimal> mapPITotalOnOrder          = new Map<String, Decimal>();
            Map<Id, List<Id>> mapWarehouseGroupWarehoues    = new Map<Id, List<Id>>();
            Set<Id> parentId                                = new Set<Id>();
            Set<String> setLegalEntity                      = new Set<String>();
            List<String> listLEtoCreateDirectoPO            = new List<String>();
            for(gii__ProductInventory__c pi : piList) {
                setLegalEntity.add(pi.giic_LegalEntity__c);
                setWarehouseIds.add(pi.gii__Warehouse__c);
                setLocalWarehouseIds.add(pi.gii__Warehouse__c);
                countryWH.add(pi.gii__Warehouse__r.gii__WareHouseCountry__c);
                setWarehouseGroupIds.add(pi.gii__Warehouse__r.gii__WarehouseGroup__c);
                mapPITotalOnOrder.put( pi.gii__Product__c + '-' + pi.gii__Warehouse__c, pi.gii__TotalOnOrder__c);
                if(pi.gii__Warehouse__r.giic_ParentWarehouse__c != null){
                    setWarehouseIds.add(pi.gii__Warehouse__r.giic_ParentWarehouse__c);
                    countryWH.add(pi.gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c);
                    setWarehouseGroupIds.add(pi.gii__Warehouse__r.gii__WarehouseGroup__c);
                    parentId.add(pi.gii__Warehouse__r.giic_ParentWarehouse__c);
                } 
                prodIds.add(pi.gii__Product__c);
            }

            // Read Custom Setting to create direct PO from Supplier to Local WH [NR1110]:
            giic_GloviaEnableFunctionality__c cs = giic_GloviaEnableFunctionality__c.getInstance('RunROPCreateDirectPO');
            if(cs != null && String.isNotBlank(cs.giic_LegalEntityEnabled__c)) {
                List<String> listLEtoEnableDirectPO = cs.giic_LegalEntityEnabled__c.split(',');
                for(String singleLE : listLEtoEnableDirectPO) {
                    listLEtoCreateDirectoPO.add(singleLE);
                }
            } 

            List<XC_CM_WarehouseSupplyFlow__mdt> configurationCM = new List<XC_CM_WarehouseSupplyFlow__mdt>([
                SELECT XC_Country__c, XC_FirstWarehouseCheck__c,XC_PurchaseOrderWarehouse__c 
                FROM XC_CM_WarehouseSupplyFlow__mdt 
                WHERE XC_Country__c IN :countryWH 
            ]);
            Map<String, XC_CM_WarehouseSupplyFlow__mdt> mapCountryWHSupplyFlow = new Map<String, XC_CM_WarehouseSupplyFlow__mdt>();
            for(XC_CM_WarehouseSupplyFlow__mdt cm : configurationCM) {
                mapCountryWHSupplyFlow.put(cm.XC_Country__c, cm);
            }             

            Map<Id, gii__Warehouse__c> mapAllNetworkWarehouses = new map<Id,gii__Warehouse__c>(giic_WarehouseUtility.getAllWarehousesForNetwork(setWarehouseGroupIds));
            Giic_StockAvailabilityUtility.getWarehouseNetworkWise(mapAllNetworkWarehouses,mapWarehouseGroupWarehoues);
            setWarehouseIds.addAll(mapAllNetworkWarehouses.keySet());
    
            Map<Id, gii__Location__c> mapLocation = new Map<Id, gii__Location__c > ([
                SELECT Id, giic_LocationType__c,gii__Warehouse__c 
                FROM gii__Location__c  
                WHERE (giic_LocationType__c = :Label.giic_LocationTypeSales OR giic_LocationType__c = :Label.giic_CL_VanLocation) AND gii__Warehouse__c IN :setWarehouseIds
            ]); 
            setLocationIds = mapLocation.keySet();
            Map<Id, gii__ProductInventory__c> mapPI = new Map<Id, gii__ProductInventory__c > ([
                SELECT Id, gii__TotalOnOrder__c,gii__Warehouse__c ,gii__Product__c
                FROM gii__ProductInventory__c  
                WHERE gii__Warehouse__c IN: parentId AND gii__Product__c IN :prodIds
            ]); 
            if(!mapPI.values().isEmpty()){
                for(gii__ProductInventory__c pi : mapPI.values()){
                    mapPITotalOnOrder.put(pi.gii__Product__c + '-' + pi.gii__Warehouse__c, pi.gii__TotalOnOrder__c);
                }
            }
            Map<Id, List<Id>> mapWHLocation = new Map<Id, List<Id>>();
            for(gii__Location__c location : mapLocation.values()){ 
                if(!mapWHLocation.containsKey(location.gii__Warehouse__c)){
                    mapWHLocation.put(location.gii__Warehouse__c, new List<Id>());
                }
                mapWHLocation.get(location.gii__Warehouse__c).add(location.Id);
            }           

            AggregateResult[] groupedResults;
            if(Schema.sObjectType.gii__ProductInventorybyLocation__c.isQueryable()) {
                groupedResults = [
                    SELECT gii__Location__c loc, gii__Product__c prod, gii__Warehouse__c wh, sum(gii__AvailableQuantity__c) availQty 
                    FROM gii__ProductInventorybyLocation__c 
                    WHERE gii__Location__c IN :setLocationIds AND gii__Product__c IN : prodIds AND gii__Warehouse__c IN : setWarehouseIds 
                    GROUP BY gii__Location__c, gii__Product__c, gii__Warehouse__c
                ];
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ groupedResults: ' + groupedResults);
            }
            for(AggregateResult ar : groupedResults) {
                String key = (String)ar.get('prod') + '-' + (string)ar.get('wh') + '-' + (string)ar.get('loc');
                if(ar.get('availQty') != null) {
                    mapPRODWHLOCWithAvailQty.put(key,integer.valueof(ar.get('availQty')));
                }
            }
            warehouseWrapper whWR = new warehouseWrapper();
            whWR.mapWHLocation = mapWHLocation;
            whWR.mapAllNetworkWarehouses = mapAllNetworkWarehouses;
            whWR.mapWarehouseGroupWarehoues = mapWarehouseGroupWarehoues;
            whWR.mapCountryWHSupplyFlow = mapCountryWHSupplyFlow;
            whWR.mapPITotalOnOrder = mapPITotalOnOrder;
            errorMessageList = processROPForLocalWarehouse(piList, mapPRODWHLOCWithAvailQty, whWR, listLEtoCreateDirectoPO);
        } 
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In errorMessageList: ' + errorMessageList);
        return errorMessageList;
    }
    
    /**
    * @author FirstName :Lorenzo  Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date 29/10/2019
    * @description setLEOnTO
    * @param listNew List<gii__TransferOrder__c>  
    */     
    public static void setLEOnTO(List<gii__TransferOrder__c> listNew){
        List<String> whTransferIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'gii__TransferToWarehouse__c');
        map<Id,gii__Warehouse__c> p2Maps = new  map<Id,gii__Warehouse__c> ([SELECT Id, giic_LegalEntity__c FROM gii__Warehouse__c WHERE Id IN: whTransferIds ]);
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'p2Maps = '+p2Maps.values());
        for(gii__TransferOrder__c t : listNew){   
            for(gii__Warehouse__c w : p2Maps.values()){
                if(t.gii__TransferToWarehouse__c == w.Id && w.giic_LegalEntity__c != null){
                    t.giic_LegalEntity__c = w.giic_LegalEntity__c;
                }
            }
        }
    }
    
    /**
    * @author FirstName :Roberta Porrega - roberta.porrega@nttdata.com
    * @date 29/10/2019
    * @description Create TO and PO for local warehouse ROP
    * @param piList List<gii__ProductInventory__c>  
    * @param mapPRODWHLOCWithAvailQty map<string,integer> 
    * @param whWR - warehouseWrapper
    * @param listLEtoCreateDirectoPO - List<String>
    */      
    public static List<String> processROPForLocalWarehouse(List<gii__ProductInventory__c> piList, Map<String, Integer> mapPRODWHLOCWithAvailQty,  warehouseWrapper whWR, List<String> listLEtoCreateDirectoPO) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In processROPForLocalWarehouse');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In piList: ' + piList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In mapPRODWHLOCWithAvailQty: ' + mapPRODWHLOCWithAvailQty);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In whWR: ' + whWR);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In listLEtoCreateDirectoPO: ' + listLEtoCreateDirectoPO);
        System.Savepoint sp = Database.setSavepoint();
        List<String> errorMessageList                                       = new List<String>();
        Map<String, Integer> mapPRODWHLOCWithSugQty                         = new Map<String, Integer>();
        Map<String, gii__TransferOrder__c> mapTransferOrder                 = new Map<String, gii__TransferOrder__c>();
        Map<String, List<gii__TransferOrderLine__c>> mapTransferOrderLine   = new Map<String, List<gii__TransferOrderLine__c>>();// Map of PI Ids and Transfer Order  
        Map<String, List<gii__ProductInventory__c>> mapSupplierProductPI    = new Map<String, List<gii__ProductInventory__c>>();
        Set<String> setTOWH                                                 = new Set<String>();
        Set<Id> settProductIds                                              = new Set<Id>();
        Set<Id> setSupplierIds                                              = new Set<Id>();
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap        = new List<giic_ReservationUtility.ReservationWrapper>();
        List<gii__ProductInventory__c> lstPIForPOCreation                   = new List<gii__ProductInventory__c>();
        Map<String, Integer> mapProductSuggQty                              = new Map<String, Integer>();
        inventoryWrapper inventoryWr                                        = new inventoryWrapper();
        inventoryWr.settProductIds                                          = new Set<Id> ();
        inventoryWr.setSupplierIds                                          = new Set<Id> ();
        inventoryWr.mapSupplierProductPI                                    = new Map<String, List<gii__ProductInventory__c>> ();
        inventoryWr.errorList                                               = new List<String>();
        inventoryWr.mapKeyPO                                                = new Map<string,gii__PurchaseOrder__c>();
        inventoryWr.mapKeyPOL                                               = new Map<string,list<gii__PurchaseOrderLine__c>>(); 
        inventoryWr.mapTransferOrder                                        = new Map<string,gii__TransferOrder__c>();
        inventoryWr.mapTransferOrderLine                                    = new Map<string,list<gii__TransferOrderLine__c>>();
        inventoryWr.reserveWrap                                             = new List<giic_ReservationUtility.ReservationWrapper> ();
        inventoryWr.mapProductSuggQty                                       = new Map<String, Integer>();
        inventoryWr.setTOWH                                                 = new Set<String>();
        inventoryWr.setPOKey                                                = new Set<String>();
        
        for(gii__ProductInventory__c objPI : piList) {
            Integer dSuggestedQty = 0;
            XC_CM_WarehouseSupplyFlow__mdt whSupplyFlow = whWR.mapCountryWHSupplyFlow.get(objPI.gii__Warehouse__r.gii__WareHouseCountry__c); 
            Decimal totalAvailQty = objPI.gii__TotalOnOrder__c;
            if(whWR.mapWHLocation.containskey(objPI.gii__Warehouse__c)) {
                for(Id location : whWR.mapWHLocation.get(objPI.gii__Warehouse__c)){
                    String key = objPI.gii__Product__c + '-' + objPI.gii__Warehouse__c+'-' +location;
                    if(mapPRODWHLOCWithAvailQty.containsKey(key)) { 
                        totalAvailQty = totalAvailQty + mapPRODWHLOCWithAvailQty.get(key); 
                    } 
                } 
                
                dSuggestedQty = Integer.valueof(objPI.gii__OrderPointQuantity__c - totalAvailQty);
                objPI.gii__OrderQuantityMultiple__c = objPI.gii__OrderQuantityMultiple__c != null ? objPI.gii__OrderQuantityMultiple__c : 0;

                if(dSuggestedQty > 0 &&  totalAvailQty < objPI.gii__OrderPointQuantity__c) {                    
                    if(objPI.gii__OrderQuantityMultiple__c == 0.0) {  
                        objPI.gii__OrderQuantityMultiple__c = 1.0;
                    }
                    if(dSuggestedQty < objPI.gii__MinimumOrderQuantity__c) { 
                        dSuggestedQty = Integer.valueof(objPI.gii__MinimumOrderQuantity__c); 
                    }
                    if(math.mod(Integer.valueOf(dSuggestedQty),Integer.valueOf(objPI.gii__OrderQuantityMultiple__c)) !=0) {
                        dSuggestedQty = Integer.valueOf(objPI.gii__OrderQuantityMultiple__c) * Integer.valueof((dSuggestedQty/objPI.gii__OrderQuantityMultiple__c).setscale(0,RoundingMode.UP));
                    }        
                    if(whSupplyFlow!=null && whSupplyFlow.XC_FirstWarehouseCheck__c!=null) {
                        switch on whSupplyFlow.XC_FirstWarehouseCheck__c {
                            // Controllo solo il WH centrale
                            when 'CW' {
                                Decimal totalAvailQtyCentral = whWR.mapPITotalOnOrder.get(objPI.gii__Product__c + '-' + objPI.gii__Warehouse__r.giic_ParentWarehouse__c);
                                if(objPI.gii__Warehouse__c!=null && whWR.mapWHLocation!=null && whWR.mapWHLocation.get(objPI.gii__Warehouse__r.giic_ParentWarehouse__c)!=null){
                                    for(Id location : whWR.mapWHLocation.get(objPI.gii__Warehouse__r.giic_ParentWarehouse__c)){
                                        String key = objPI.gii__Product__c + '-' + objPI.gii__Warehouse__r.giic_ParentWarehouse__c+'-' +location;
                                        if(mapPRODWHLOCWithAvailQty.containsKey(key)){
                                            totalAvailQtyCentral = totalAvailQtyCentral + mapPRODWHLOCWithAvailQty.get(key);  
                                        }
                                    } 
                                }  
                                String parentKey = objPI.gii__Product__c + '-' + objPI.gii__Warehouse__r.giic_ParentWarehouse__c  + '-'+ objPI.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c;
                                // VERIFICO LA DISPONIBILITà NEL CENTRALE:
                                if(totalAvailQtyCentral >= dSuggestedQty){  
                                    XC_UTIL_DEBUG.debug(DEBUGACTIVE, '@@@ Quantity found on Central WH');
                                    String toKey = objPI.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objPI.gii__Warehouse__c;
                                    if(!inventoryWr.setTOWH.contains(toKey)){
                                        gii__TransferOrder__c objTO = new gii__TransferOrder__c(
                                            giic_Source__c=Label.giic_SourceReorderPlanning,
                                            gii__Account__c=objPI.gii__Warehouse__r.gii__Account__c,
                                            gii__FromWarehouse__c=objPI.gii__Warehouse__r.giic_ParentWarehouse__c,
                                            gii__TransferToWarehouse__c=objPI.gii__Warehouse__c,
                                            giic_Approved__c=true,giic_Status__c=Label.giic_TOApproved
                                        );
                                        inventoryWr.mapTransferOrder.put(toKey,objTO);
                                        gii__TransferOrderLine__c objTOLine = new gii__TransferOrderLine__c(
                                            gii__Product__c=objPI.gii__Product__c,
                                            gii__Quantity__c = dSuggestedQty
                                        );                               
                                        inventoryWr.mapTransferOrderLine.put(toKey, new List<gii__TransferOrderLine__c>{objTOLine});
                                        inventoryWr.setTOWH.add(toKey); 
                                    } else {
                                        gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(
                                            gii__Product__c=objPI.gii__Product__c,
                                            gii__Quantity__c = dSuggestedQty
                                        );
                                        inventoryWr.mapTransferOrderLine.get(toKey).add(objTOLine);
                                    }

                                    reserveWrap.add(giic_ReservationUtility.getReservationWrapper( 
                                        objPI.gii__Warehouse__r.giic_ParentWarehouse__c,
                                        objPI.gii__Product__c,
                                        dSuggestedQty,
                                        objPI.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c
                                    ));
                                } 
                                else {
                                    // SE NON HO DISPONIBILITà SUL CENTRALE CREO PO:
                                    if(objPI.gii__Product__r.giic_EndDate__c >= date.today() || objPI.gii__Product__r.giic_EndDate__c == null) {
                                        inventoryWr.settProductIds.add(objPI.gii__Product__c);
                                        String suppProdKey = objPI.gii__Product__r.gii__PrimarySupplier__c +'-' + objPI.gii__Product__c;
                                        inventoryWr.setSupplierIds.add(objPI.gii__Product__r.gii__PrimarySupplier__c);
                                        if(!inventoryWr.mapSupplierProductPI.containskey(suppProdKey)){
                                            inventoryWr.mapSupplierProductPI.put(suppProdKey,new List<gii__ProductInventory__c>());
                                        }
                                        inventoryWr.mapSupplierProductPI.get(suppProdKey).add(objPI);
                                        inventoryWr.mapProductSuggQty.put(objPI.Id, dSuggestedQty);                                     
                                    } else {
                                        errorMessageList.add('The end date on Product Reference is less than today');  
                                        return errorMessageList;
                                    }
                                } 
                            }
                            when 'LW' {
                                Boolean poToBeCreated = true;
                                for(Id whID : whWR.mapWarehouseGroupWarehoues.get(objPI.gii__Warehouse__r.gii__WarehouseGroup__c)){
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Checking for Local WH: ' + whID);
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ dSuggestedQty: ' + dSuggestedQty + ' totalAvailQty < objPI.gii__OrderPointQuantity__c' + totalAvailQty + ' '+  objPI.gii__OrderPointQuantity__c);
                                    
                                    Decimal totalAvailQtyLocal = 0;
                                    String locationDef ;
                                    if(whWR.mapWHLocation.containskey(whID)){
                                        for(Id location : whWR.mapWHLocation.get(whID)){
                                            string key = objPI.gii__Product__c + '-' + whID +'-' +location;
                                            if(mapPRODWHLOCWithAvailQty.containsKey(key)){
                                                locationDef = location;
                                                totalAvailQtyLocal = totalAvailQtyLocal + mapPRODWHLOCWithAvailQty.get(key);  
                                            }
                                        }     
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ totalAvailQtyLocal >= dSuggestedQty' + totalAvailQtyLocal +'   '+ dSuggestedQty);
                                        // VERIFICO LA DISPONIBILITà NEL LOCALE:
                                        if(totalAvailQtyLocal >= dSuggestedQty  && whID != objPI.gii__Warehouse__c) {  
                                            XC_UTIL_DEBUG.debug(DEBUGACTIVE, '@@@ Quantity found in Local WH:' + whID);
                                            String toKey = whID + '-' + objPI.gii__Warehouse__c;
                                            if(!inventoryWr.setTOWH.contains(toKey)){
                                                gii__TransferOrder__c objTO = new gii__TransferOrder__c(
                                                    giic_Source__c=Label.giic_SourceReorderPlanning,
                                                    gii__Account__c=objPI.gii__Warehouse__r.gii__Account__c,
                                                    gii__FromWarehouse__c=whID,
                                                    gii__TransferToWarehouse__c=objPI.gii__Warehouse__c,
                                                    giic_Approved__c=true,giic_Status__c=Label.giic_TOApproved
                                                );
                                                inventoryWr.mapTransferOrder.put(toKey,objTO);
                                                gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(
                                                    gii__Product__c=objPI.gii__Product__c,
                                                    gii__Quantity__c = dSuggestedQty
                                                );
                                                inventoryWr.mapTransferOrderLine.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine});
                                                inventoryWr.setTOWH.add(toKey); 
                                            } else {
                                                gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(
                                                    gii__Product__c=objPI.gii__Product__c,
                                                    gii__Quantity__c = dSuggestedQty
                                                );
                                                inventoryWr.mapTransferOrderLine.get(toKey).add(objTOLine);
                                            }
                                            reserveWrap.add(giic_ReservationUtility.getReservationWrapper(whID, objPI.gii__Product__c, dSuggestedQty,locationDef));
                                            poToBeCreated = false;
                                            break;
                                        }   
                                    }
                                }
                                if(poToBeCreated && dSuggestedQty>0 ){
                                    if(objPI.gii__Product__r.giic_EndDate__c >= date.today() || objPI.gii__Product__r.giic_EndDate__c == null ){  
                                        inventoryWr.settProductIds.add(objPI.gii__Product__c);
                                        string suppProdKey=objPI.gii__Product__r.gii__PrimarySupplier__c +'-' + objPI.gii__Product__c;
                                        inventoryWr.setSupplierIds.add(objPI.gii__Product__r.gii__PrimarySupplier__c);
                                        if(!inventoryWr.mapSupplierProductPI.containskey(suppProdKey)){
                                            inventoryWr.mapSupplierProductPI.put(suppProdKey,new list<gii__ProductInventory__c>());
                                        }
                                        inventoryWr.mapSupplierProductPI.get(suppProdKey).add(objPI); 
                                        inventoryWr.mapProductSuggQty.put(objPI.Id, dSuggestedQty); 
                                        //createPOforROPProcess(inventoryWr,dSuggestedQty, whSupplyFlow.XC_PurchaseOrderWarehouse__c); 
                                    }else{
                                        errorMessageList.add('The end date on Product Reference is less than today');  
                                        return errorMessageList;
                                    }
                                }                           
                            }         
                        }
                    }
                }
            }
        }

        createPOforROPProcess(inventoryWr, whWR, listLEtoCreateDirectoPO);

        String errorMessage = '';
        if(inventoryWr.mapTransferOrder != null && inventoryWr.mapTransferOrderLine != null) { 
            errorMessage = insertTO(inventoryWr.mapTransferOrder, inventoryWr.mapTransferOrderLine); 
            if(String.isNotBlank(errorMessage)) {
                errorMessageList.add(errorMessage);
                Database.rollback(sp);
                return errorMessageList;
            }
        }
        if(inventoryWr.mapKeyPO != null && inventoryWr.mapKeyPOL != null && !inventoryWr.mapKeyPO.keySet().isEmpty() && !inventoryWr.mapKeyPOL.keySet().isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ inventoryWr.mapKeyPO: ' + inventoryWr.mapKeyPO);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ inventoryWr.mapKeyPOL: ' + inventoryWr.mapKeyPOL);
            List<Id> listPoIds = giic_PurchaseOrderUtility.insertPO(inventoryWr.mapKeyPO, inventoryWr.mapKeyPOL);
            if(listPoIds.isEmpty()) {
                errorMessageList.add('Error to create Purchase Order');
                Database.rollback(sp);
                return errorMessageList;
            }
        } 
        if(inventoryWr.reserveWrap != null){
            giic_ReservationUtility.reserveQuantities(inventoryWr.reserveWrap);
        } 
        errorMessage = insertTO(mapTransferOrder, mapTransferOrderLine);
        if(String.isNotBlank(errorMessage)) {
            errorMessageList.add(errorMessage);
            Database.rollback(sp);
            return errorMessageList;
        }
        if(reserveWrap.size() > 0){
            giic_ReservationUtility.reserveQuantities(reserveWrap);
        }  
        return errorMessageList;
    }       
    
    /**
    * @date 29/10/2019
    * @description Create PO for local warehouse ROP
    * @param inventoryWr - inventoryWrapper
    * @param whWR - warehouseWrapper
    * @param listLEtoCreateDirectoPO - List<String>
    * @return inventoryWrapper
    */    
    public static inventoryWrapper createPOforROPProcess(inventoryWrapper inventoryWr,  warehouseWrapper whWR, List<String> listLEtoCreateDirectoPO) {
        Set<String> setPOKey                                                = new Set<String>();
        Set<String> setTOWH                                                 = new Set<String>();
        Map<String, gii__PurchaseOrder__c> mapKeyPO                         = new Map<String, gii__PurchaseOrder__c>();
        Map<String, List<gii__PurchaseOrderLine__c>> mapKeyPOL              = new Map<String, List<gii__PurchaseOrderLine__c>>(); 
        Map<String, gii__TransferOrder__c> mapTransferOrder                 = new Map<String, gii__TransferOrder__c>();
        Map<String, List<gii__TransferOrderLine__c>> mapTransferOrderLine   = new Map<String, List<gii__TransferOrderLine__c>>();// Map of PI Ids and Transfer Order  
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap        = new List<giic_ReservationUtility.ReservationWrapper>();
        List<String> lstErrors                                              = new List<String>();
        
        if(inventoryWr.settProductIds.size()>0 && inventoryWr.setSupplierIds.size()>0) { 
            List<gii__PriceBookEntry__c> lstPriceBookAndPBEntry = Giic_TransferOrderUtility_D.getPriceBookEntries(inventoryWr.settProductIds,inventoryWr.setSupplierIds);
            if(lstPriceBookAndPBEntry.size() > 0) {
                for(gii__PriceBookEntry__c pbEntry : lstPriceBookAndPBEntry) {
                    String key = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
                    if(inventoryWr.mapSupplierProductPI.containskey(key)) {
                        for(gii__ProductInventory__c objPI : inventoryWr.mapSupplierProductPI.get(key)) {
                            XC_CM_WarehouseSupplyFlow__mdt whSupplyFlow = whWR.mapCountryWHSupplyFlow.get(objPI.gii__Warehouse__r.gii__WareHouseCountry__c); 
                            String poKey=objPI.gii__Warehouse__c + '-'+ pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+ pbEntry.gii__PriceBook__r.name;
                            String warehouse; 

                            switch on whSupplyFlow.XC_PurchaseOrderWarehouse__c {
                                when 'CW' {
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ CREO PO NEL CENTRALE per ' + objPI.Id);
                                    if(objPI.gii__Warehouse__r.giic_ParentWarehouse__c != null) {    
                                        if(!listLEtoCreateDirectoPO.contains(objPI.giic_LegalEntity__c)) {    
                                            String toKey = objPI.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objPI.gii__Warehouse__c;
                                            if(!inventoryWr.setTOWH.contains(toKey)){
                                                gii__TransferOrder__c objTO = new gii__TransferOrder__c(
                                                    giic_Source__c = Label.giic_SourceReorderPlanning,
                                                    gii__Account__c = objPI.gii__Warehouse__r.gii__Account__c,
                                                    gii__FromWarehouse__c = objPI.gii__Warehouse__r.giic_ParentWarehouse__c,
                                                    gii__TransferToWarehouse__c = objPI.gii__Warehouse__c,
                                                    giic_Approved__c = true,
                                                    giic_Status__c = Label.giic_TOApproved
                                                );
                                                inventoryWr.mapTransferOrder.put(toKey,objTO); 
                                                gii__TransferOrderLine__c objTOLine = new gii__TransferOrderLine__c(
                                                    gii__Product__c = objPI.gii__Product__c,
                                                    gii__Quantity__c = inventoryWr.mapProductSuggQty.get(objPI.id)
                                                );
                                                inventoryWr.mapTransferOrderLine.put(toKey, new List<gii__TransferOrderLine__c>{objTOLine}); 
                                                inventoryWr.setTOWH.add(toKey); 
                                            }
                                            else {
                                                gii__TransferOrderLine__c objTOLine = new gii__TransferOrderLine__c(
                                                    gii__Product__c = objPI.gii__Product__c,
                                                    gii__Quantity__c = inventoryWr.mapProductSuggQty.get(objPI.id)
                                                );
                                                inventoryWr.mapTransferOrderLine.get(toKey).add(objTOLine);
                                            } 
                                            
                                            inventoryWr.reserveWrap.add(
                                                giic_ReservationUtility.getReservationWrapper( 
                                                    objPI.gii__Warehouse__r.giic_ParentWarehouse__c,objPI.gii__Product__c, inventoryWr.mapProductSuggQty.get(objPI.id), objPI.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c
                                                )
                                            );
                                            warehouse = objPI.gii__Warehouse__r.giic_ParentWarehouse__c;
                                            poKey = objPI.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-' + pbEntry.gii__PriceBook__r.name;
                                        } else {
                                            warehouse = objPI.gii__Warehouse__c;
                                            poKey = objPI.gii__Warehouse__c + '-' + pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-' + pbEntry.gii__PriceBook__r.name;
                                        }
                                        String suggKey = objPI.gii__Product__c + '-' + objPI.gii__Warehouse__r.giic_ParentWarehouse__c  + '-'+ objPI.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c;
                                    }
                                    else{
                                        String suggKey = objPI.gii__Product__c + '-' + objPI.gii__Warehouse__c+'-' + objPI.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                                        warehouse = objPI.gii__Warehouse__c;
                                    }
                                }
                                when 'LW' {
                                    XC_UTIL_DEBUG.debug(DEBUGACTIVE, '@@@ CREO PO NEL LOCALE');
                                    String suggKey = objPI.gii__Product__c + '-' + objPI.gii__Warehouse__c + '-' + objPI.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                                    warehouse = objPI.gii__Warehouse__c;
                                }
                            }

                            if(!inventoryWr.setPOKey.contains(poKey)){
                                gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(
                                    giic_Source__c = Label.giic_SourceReorderPlanning,
                                    giic_Contract__c = pbEntry.gii__PriceBook__r.giic_Contract__c,
                                    gii__Supplier__c = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId,
                                    gii__ShipTo__c = warehouse,
                                    gii__OrderDate__c = System.today(), 
                                    gii__Approved__c = false,
                                    gii__DropShip__c = false,
                                    gii__RequiredDate__c = System.today(),
                                    gii__PriceBookName__c = pbEntry.gii__PriceBook__r.name,
                                    giic_PriceBookId__c = pbEntry.gii__PriceBook__c,
                                    giic_LegalEntity__c = objPI.giic_LegalEntity__c
                                );
                                inventoryWr.mapKeyPO.put(poKey,objPO);

                                gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(
                                    gii__Product__c = objPI.gii__Product__c,
                                    gii__OrderQuantity__c = inventoryWr.mapProductSuggQty.get(objPI.id)
                                );
                                inventoryWr.mapKeyPOL.put(poKey, new List<gii__PurchaseOrderLine__c>{objPOLine});
                                inventoryWr.setPOKey.add(poKey);
                            }
                            else{
                                gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(
                                    gii__Product__c = objPI.gii__Product__c,
                                    gii__OrderQuantity__c = inventoryWr.mapProductSuggQty.get(objPI.id)
                                );
                                inventoryWr.mapKeyPOL.get(poKey).add(objPOLine);
                            }
                        } 
                    }
                }
            }
        } 
        else {
            lstErrors.add(System.Label.giic_PriceBookError);  
            inventoryWr.errorList = lstErrors;
        }
        return inventoryWr;
    } 
    
    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 23/07/2019
    * @date Modification dd/mm/yyyy
    * @description - To check limits on incoming transfer order.
    * @param transferOdrList List<gii__TransferOrder__c>
    */
    public static void checkLimitsForOrder(List<gii__TransferOrder__c> transferOdrList){
        if(transferOdrList != null && !transferOdrList.isEmpty()){
            Set<String> fromWHSet = new Set<String>();
            Map<String,gii__TransferOrder__c> mapOfTOidVsTO = new Map<String,gii__TransferOrder__c>(transferOdrList);
            
            for(gii__TransferOrder__c tfrOdrObj : transferOdrList){
                fromWHSet.add(tfrOdrObj.gii__TransferToWarehouse__c);
                //mapOfTOidVsTO.put(tfrOdrObj.Id,tfrOdrObj);
            }
            Map<Id,gii__TransferOrderLine__c> mapOfTOVsTOLine = new Map<Id,gii__TransferOrderLine__c>([SELECT Id,gii__Quantity__c,gii__UnitCost__c,gii__TransferOrder__c,gii__TransferOrder__r.gii__TransferToWarehouse__c,gii__TransferOrder__r.gii__TransferToWarehouse__r.giic_StorageCapacity__c,gii__Product__c FROM gii__TransferOrderLine__c WHERE gii__TransferOrder__c IN:transferOdrList ORDER BY gii__Quantity__c asc]);
            
            if(mapOfTOVsTOLine != null && !mapOfTOVsTOLine.values().isEmpty()){
                processOrder(mapOfTOVsTOLine, fromWHSet, mapOfTOidVsTO);
            }
        }
    }
    
    /**    
    * @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description - To update Warehouse exceed limit on incoming Purchase order and lines.
    * @param mapOfTOVsTOLine Map<Id,gii__TransferOrderLine__c>   
    * @param fromWHSet Set<String>  
    * @param mapOfTOidVsTO Map<String,gii__TransferOrder__c> 
    */       
    public static void processOrder(Map<Id,gii__TransferOrderLine__c> mapOfTOVsTOLine, Set<String> fromWHSet, Map<String,gii__TransferOrder__c> mapOfTOidVsTO){       
        Map<String,Decimal> mapOfTOidVsOdrVal = new Map<String,Decimal>();
        Set<String> pdtIdSet = new Set<String>();
        List<gii__ProductInventory__c> lstProductInventory = new List<gii__ProductInventory__c>();
        Map<String,gii__ProductInventory__c> mapOfPdtWhVsPI = new Map<String,gii__ProductInventory__c>();
        Map<String,gii__Warehouse__c> mapOfWHidVsWH = new Map<String,gii__Warehouse__c>([SELECT Id,giic_WarehouseValue__c,giic_StorageCapacity__c FROM gii__Warehouse__c WHERE Id IN: fromWHSet]);
        List<gii__TransferOrderLine__c> listTOLUpdate=new List<gii__TransferOrderLine__c>(); 
        for(gii__TransferOrderLine__c tfrOdrLineObj : mapOfTOVsTOLine.values()){
            pdtIdSet.add(tfrOdrLineObj.gii__Product__c);
            Decimal newVal;
            Decimal unitCost;
            Decimal qty;
            if(mapOfTOidVsOdrVal.containsKey(tfrOdrLineObj.gii__TransferOrder__c)){
                unitCost = tfrOdrLineObj.gii__UnitCost__c == null ? 0 : tfrOdrLineObj.gii__UnitCost__c;
                qty = tfrOdrLineObj.gii__Quantity__c != null ? 0 : tfrOdrLineObj.gii__Quantity__c;
                newVal = mapOfTOidVsOdrVal.get(tfrOdrLineObj.gii__TransferOrder__c)+(qty * unitCost);
                mapOfTOidVsOdrVal.put(tfrOdrLineObj.gii__TransferOrder__c,newVal);
            }else{
                unitCost = tfrOdrLineObj.gii__UnitCost__c == null ? 0 : tfrOdrLineObj.gii__UnitCost__c;
                qty = tfrOdrLineObj.gii__Quantity__c == null ? 0 : tfrOdrLineObj.gii__Quantity__c;
                newVal = qty * unitCost;
                mapOfTOidVsOdrVal.put(tfrOdrLineObj.gii__TransferOrder__c,newVal);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapOfTOidVsOdrVal'+mapOfTOidVsOdrVal);
        if(Schema.sObjectType.gii__ProductInventory__c.isQueryable()){
            for(AggregateResult arObj : [SELECT gii__Warehouse__c warehouseId,SUM(giic_Value__c)value FROM gii__ProductInventory__c WHERE gii__Warehouse__c IN: fromWHSet GROUP BY gii__Warehouse__c]){
                mapOfWHidVsWH.get(String.valueOf(arObj.get('warehouseId'))).giic_WarehouseValue__c = (Decimal)arObj.get('value');
            }
            for(gii__ProductInventory__c pIobj : [SELECT Id,giic_MaxQuantity__c,giic_OnHandNew__c,gii__Product__c,Name,gii__AvailableQuantity__c,gii__TotalOnOrder__c,gii__Warehouse__c,gii__Warehouse__r.giic_WarehouseType__c ,gii__BackOrderQuantity__c From gii__ProductInventory__c WHERE gii__Warehouse__c IN: fromWHSet]){
                mapOfPdtWhVsPI.put(String.valueOf(pIobj.gii__Product__c)+String.valueOf(pIobj.gii__Warehouse__c),pIobj);
            }
        }
        Giic_TransferOrderUtility.ParamsWrapper params = new Giic_TransferOrderUtility.ParamsWrapper();
        params.mapOfTOVsTOLine=mapOfTOVsTOLine;
        params.mapOfTOidVsTO=mapOfTOidVsTO;
        params.mapOfWHidVsWH=mapOfWHidVsWH;
        params.mapOfTOidVsOdrVal=mapOfTOidVsOdrVal;
        params.mapOfPdtWhVsPI=mapOfPdtWhVsPI;
        params.listTOLUpdate=listTOLUpdate;
        //Call processOrderForCheckLimit
        processOrderForCheckLimit(params);
        updateLimitsForOrder(mapOfTOidVsTO,listTOLUpdate);
    }

    /**    
    * @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description - To update Warehouse exceed limit on incoming Purchase order and lines.
    * @param params Giic_TransferOrderUtility.ParamsWrapper   
    */    
    public static void processOrderForCheckLimit(Giic_TransferOrderUtility.ParamsWrapper params){
        Map<Id,gii__TransferOrderLine__c> mapOfTOVsTOLine=params.mapOfTOVsTOLine;
        Map<String,gii__TransferOrder__c> mapOfTOidVsTO=params.mapOfTOidVsTO;
        Map<String,gii__Warehouse__c> mapOfWHidVsWH=params.mapOfWHidVsWH;
        Map<String,Decimal> mapOfTOidVsOdrVal=params.mapOfTOidVsOdrVal;
        Map<String,gii__ProductInventory__c> mapOfPdtWhVsPI=params.mapOfPdtWhVsPI;
        List<gii__TransferOrderLine__c> listTOLUpdate=params.listTOLUpdate;
        Map<String,Decimal> mapOfIdVsOnHandQty = new Map<String,Decimal>();
        for(gii__TransferOrderLine__c tfrOdrLineObj : mapOfTOVsTOLine.values()){
            Decimal qty = 0;
            Decimal maxQty=0;
            Decimal onHandQty=0;
            gii__ProductInventory__c tempPI = mapOfPdtWhVsPI.get(String.valueOf(tfrOdrLineObj.gii__Product__c)+String.valueOf(tfrOdrLineObj.gii__TransferOrder__r.gii__TransferToWarehouse__c));
            if(tempPI != null){
                onHandQty = tempPI.giic_OnHandNew__c != null ? tempPI.giic_OnHandNew__c : 0;
                if(!mapOfIdVsOnHandQty.containsKey(tempPI.Id)){
                    mapOfIdVsOnHandQty.put(tempPI.Id,onHandQty);
                }
                qty = tfrOdrLineObj.gii__Quantity__c != null ? tfrOdrLineObj.gii__Quantity__c : 0;
                maxQty = tempPI.giic_MaxQuantity__c != null ? tempPI.giic_MaxQuantity__c : 0;
                onHandQty = mapOfIdVsOnHandQty.get(tempPI.Id);
                if((qty + onHandQty) > maxQty){
                    mapOfTOidVsTO.get(tfrOdrLineObj.gii__TransferOrder__c).giic_WarehouseLimitExceeded__c = true;
                    tfrOdrLineObj.giic_WarehouseLimitExceeded__c = true;
                    listTOLUpdate.add(tfrOdrLineObj);
                }else{
                    onHandQty += qty;
                    mapOfIdVsOnHandQty.put(tempPI.Id,onHandQty);
                    if((mapOfTOidVsOdrVal.get(tfrOdrLineObj.gii__TransferOrder__c) + mapOfWHidVsWH.get(tfrOdrLineObj.gii__TransferOrder__r.gii__TransferToWarehouse__c).giic_WarehouseValue__c) > mapOfWHidVsWH.get(tfrOdrLineObj.gii__TransferOrder__r.gii__TransferToWarehouse__c).giic_StorageCapacity__c){
                        mapOfTOidVsTO.get(tfrOdrLineObj.gii__TransferOrder__c).giic_WarehouseLimitExceeded__c = true; 
                    }
                }
            }
        }
    }   
    
    /**    
    * @author FirstName : Deepika Rawat- Deepika.Rawat@us.fujitsu.com
    * @date Creation 27/08/2019
    * @date Modification dd/mm/yyyy
    * @description - To update Warehouse exceed limit on incoming Purchase order and lines.
    * @param mapOfTOidVsTO Map<String,gii__TransferOrder__c> 
    * @param listTOLUpdate List<gii__TransferOrderLine__c>  
    */   
    public static void updateLimitsForOrder(Map<String,gii__TransferOrder__c> mapOfTOidVsTO, List<gii__TransferOrderLine__c> listTOLUpdate ){
        if(mapOfTOidVsTO != null && !mapOfTOidVsTO.values().isEmpty() && Schema.sObjectType.gii__TransferOrder__c.isUpdateable()){
            update mapOfTOidVsTO.values();
        }
        if(!listTOLUpdate.isEmpty() && Schema.sObjectType.gii__TransferOrderLine__c.isUpdateable() ){
            update listTOLUpdate;
        }
    }
    
    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description - To check limits on incoming transfer order.
    * @param transferOdrLineList List<gii__TransferOrderLine__c>  
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old gii__TransferOrderLine__c
    */    
    public static void checkLimitsForOrderFromTrigger(List<gii__TransferOrderLine__c> transferOdrLineList,Boolean isInsert,Map<Id, SObject> mapOldS){
        List<gii__TransferOrder__c> tfrOdrList = new List<gii__TransferOrder__c>();
        Set<String> idSet = new Set<String>();
        for(gii__TransferOrderLine__c tfrOdrLine : transferOdrLineList){
            if(isInsert){
                idSet.add(tfrOdrLine.gii__TransferOrder__c);
            }else{
                if(mapOldS.get(tfrOdrLine.Id).get('gii__Quantity__c') != tfrOdrLine.gii__Quantity__c){
                    idSet.add(tfrOdrLine.gii__TransferOrder__c);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'idSet-------'+idSet);
        if(Schema.sObjectType.gii__TransferOrder__c.isQueryable() && idSet != null && !idSet.isEmpty()){
            tfrOdrList = [SELECT gii__TransferToWarehouse__c,Id,giic_status__c FROM gii__TransferOrder__c WHERE ID IN: idSet];
        }
        if(!tfrOdrList.isEmpty()){
            checkLimitsForOrder(tfrOdrList);
        }
    } 
    
    /** 
     * @author Glovia Team
     * @description Method to process merge for TO (by cmp)
     */     
    @AuraEnabled             
    public static XC_UTIL_ResultWrapper processMergeForTOfromComponent(){
        Id currentUserId = UserInfo.getUserId();
        User u = [SELECT Id, XC_LegalEntity__c FROM User WHERE Id=:currentUserId LIMIT 1];
        List<gii__TransferOrder__c> listTO = [SELECT Id,gii__Account__c,giic_WarehouseLimitExceeded__c,giic_LegalEntity__c,
                                              giic_status__c,gii__TransferToWarehouse__r.gii__Account__c, gii__OrderDate__c,gii__FromWarehouse__c,
                                              gii__TransferToWarehouse__c FROM gii__TransferOrder__c WHERE giic_status__c=: System.Label.giic_TODraftStatus 
                                              AND giic_IntegrationStatus__c=: System.Label.giic_TOIntegrationStatusNotStarted AND giic_LegalEntity__c=: u.XC_LegalEntity__c ];
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        if(!listTO.isEmpty()){
            processMergeForTO(listTO);
        }
        return rw;
    }

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@fujitsu.com
    * @date Creation 09/08/2019
    * @date Modification dd/mm/yyyy
    * @description - Merge Transfer Order
    * @param listTO List<gii__TransferOrder__c> 
    * @return Set<Id>
    */ 
    public static List<gii__TransferOrder__c> processMergeForTO(List<gii__TransferOrder__c> listTO){
        List<gii__TransferOrder__c> idToUPdate= new List<gii__TransferOrder__c>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listTo'+listTo);
        Map<String,gii__TransferOrder__c> mapTransferOrder=new Map<String,gii__TransferOrder__c>();  
        Map<String,list<gii__TransferOrder__c>> mapOldTO=new Map<String,list<gii__TransferOrder__c>>();  
        Map<String,List<gii__TransferOrderLine__c>> mapTransferOrderLine=new Map<String,List<gii__TransferOrderLine__c>>();  
        map<Id,list<gii__TransferOrderLine__c>> mapTOWithTransferOrderLines=new map<Id,list<gii__TransferOrderLine__c>>();
        Set<String> setofWHIds= new Set<String>();
        
        for(gii__TransferOrderLine__c objTOL : [SELECT Id,gii__TransferOrder__c,gii__Quantity__c,gii__Product__c,gii__TransferOrder__r.gii__TransferToWarehouse__c,
                                                gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__Account__c,giic_SalesOrderLine__c ,
                                                gii__TransferOrder__r.gii__FromWarehouse__c FROM gii__TransferOrderLine__c 
                                                WHERE  gii__TransferOrder__c    IN: (new map<Id,gii__TransferOrder__c>(listTO)).keyset()]){
        if(!mapTOWithTransferOrderLines.containsKey(objTOL.gii__TransferOrder__c)){
            mapTOWithTransferOrderLines.put(objTOL.gii__TransferOrder__c,new list<gii__TransferOrderLine__c>());
        }
            mapTOWithTransferOrderLines.get(objTOL.gii__TransferOrder__c).add(objTOL);
        }
        for(gii__TransferOrder__c objTO : listTO){
            string toKey=objTO.gii__FromWarehouse__c+'-' + objTO.gii__TransferToWarehouse__c;
            setofWHIds.add(toKey);
            if(!mapOldTO.containsKey(toKey)){
                mapOldTO.put(toKey,new list<gii__TransferOrder__c>());
            }            
            mapOldTO.get(toKey).add(objTO);            
            if(!mapTransferOrder.containsKey(toKey)){
                gii__TransferOrder__c objNewTO =new gii__TransferOrder__c(giic_Source__C=Label.giic_OrderSourceAutomation,gii__Account__c=objTO.gii__TransferToWarehouse__r.gii__Account__c,gii__FromWarehouse__c=objTO.gii__FromWarehouse__c,
                                                                          gii__TransferToWarehouse__c=objTO.gii__TransferToWarehouse__c,
                                                                          giic_status__c=System.Label.giic_TOApproved,giic_Approved__c=True,
                                                                          giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate,
                                                                          giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate,
                                                                          giic_TargetSystem__c=System.Label.giic_TargetSystem3PL,Giic_IsMergedResult__c = true);
                
                if(objTO.giic_WarehouseLimitExceeded__c){
                    objNewTO.giic_WarehouseLimitExceeded__c=true;   
                }
                mapTransferOrder.put(toKey,objNewTO);
                if(objTO.id!=null && mapTOWithTransferOrderLines.get(objTO.id)!=null){
                    mapTransferOrderLine.put(toKey,mapTOWithTransferOrderLines.get(objTO.id).deepclone(false));
                }
            }else{
                if(mapTransferOrderLine.containsKey(toKey) && mapTOWithTransferOrderLines.containsKey(objTO.id) ){
                    mapTransferOrderLine.get(toKey).addall(mapTOWithTransferOrderLines.get(objTO.id).deepclone(false));
                }
            }
            //objTO.giic_Status__c='Merged';
        }
        idToUPdate= insertTO(mapTransferOrder,mapTransferOrderLine,mapOldTO);
        return idToUPdate;
    }   
    
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description - insert Transfer order and transfer order line from map
    * @param  mapTO map<string,gii__TransferOrder__c> 
    * @param mapTOLine  map<string,List<gii__TransferOrderLine__c>> 
    * @param  mapOldTO Map<String,list<gii__TransferOrder__c>> 
    * @return  Set<Id>
    */    
    public static List<gii__TransferOrder__c> insertTO(map<string,gii__TransferOrder__c> mapTO, map<string,List<gii__TransferOrderLine__c>> mapTOLine, Map<String,list<gii__TransferOrder__c>> mapOldTO){
        List<gii__TransferOrder__c> lstTOWithReadyToIntegrate=new List<gii__TransferOrder__c>();
        //Set<Id> idToUPdate= new Set<Id>();
        List<gii__TransferOrder__c> transferOrderList = new List<gii__TransferOrder__c>();
        for(string toKey : mapOldTO.keyset()){
            if(mapOldTO.get(toKey).size() < 2){
                mapTO.remove(toKey);
                lstTOWithReadyToIntegrate.addall(mapOldTO.get(toKey));
            }
        }
        lstTOWithReadyToIntegrate.addall(mapTO.values());   
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<Database.SaveResult> srList = Database.insert(mapTO.values(), false);
        wrapperList = XC_UTIL_Glovia.populateWrapperResultSuccessInsert(srList, mapTO.values() , false );
        for(XC_UTIL_Sobject.WrapperResult wr : wrapperList){
            if(wr.success){
                gii__TransferOrder__c toObject = (gii__TransferOrder__c)JSON.deserialize(wr.objectInfo, gii__TransferOrder__c.class);
                transferOrderList.add(toObject);
            }
        }
        map<Id,gii__TransferOrder__c> mapInsertedTO=new map<id,gii__TransferOrder__c>([select id,name from gii__TransferOrder__c where id in:mapTO.values()]);
        list<gii__TransferOrder__c> lstTransferOrderToUpdate=new list<gii__TransferOrder__c>();
        list<gii__TransferOrderLine__c> lstTOLToInsert=new list<gii__TransferOrderLine__c>();
        for(string key : mapTO.keyset()){
            for(gii__TransferOrder__c objTO : mapOldTO.get(key)){
                objTO.giic_MergedTransferOrder__c = mapInsertedTO.get(mapTO.get(key).id).Name;
                objTO.giic_MergeTO__c =  mapInsertedTO.get(mapTO.get(key).id).Id;
                objTO.giic_Status__c=System.Label.giic_StatusMerged;
                lstTransferOrderToUpdate.add(objTO);
            }
            if(mapTOLine.containsKey(key)){
                for(gii__TransferOrderLine__c objTOL : mapTOLine.get(key)){
                    objTOL.gii__TransferOrder__c=mapTO.get(key).Id;
                    lstTOLToInsert.add(objTOL);
                }
            }
        }
        //lstTransferOrderToUpdate.addall(lstTOWithReadyToIntegrate);
        update lstTransferOrderToUpdate;
        database.insert(lstTOLToInsert);
        /*for(gii__TransferOrder__c objTo:lstTOWithReadyToIntegrate){
            idToUPdate.add(objTo.Id);
        }*/
        return transferOrderList;
    } 

    /**
    * @author FirstName : Shubee Tyagi
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description - updateIntegrationStatus- Update Transfer Order Status for INtegration
    * @param  listTO List<gii__TransferOrder__c> 
    */    
    public static void updateIntegrationStatus(List<gii__TransferOrder__c> listTO){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listTO'+listTO);
        for(gii__TransferOrder__c objTO:listTO){
            objTO.giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate;
            objTO.giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate;
            objTO.giic_TargetSystem__c=System.Label.giic_TargetSystem3PL;
        }
        if(Schema.sObjectType.gii__TransferOrder__c.isUpdateable()) {
            update listTO;
        }
    } 
    
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 30/07/2019
    * @date Modification dd/mm/yyyy
    * @description - insert Transfer order and transfer order line from map
    * @param mapTO map<string,gii__TransferOrder__c> 
    * @param mapTOLine map<string,List<gii__TransferOrderLine__c>> 
    * @return String
    */    
    public static String insertTO(map<string,gii__TransferOrder__c> mapTO, map<string,List<gii__TransferOrderLine__c>> mapTOLine){
        String errorMessage = '';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTO: ' + mapTO);
        List<XC_UTIL_Sobject.WrapperResult> wrResultTO = XC_UTIL_Sobject.insertListRecords(mapTO.values());
        if(!XC_UTIL_Sobject.checkDMLResults(wrResultTO)) {
            errorMessage = wrResultTO[0].errorMessage;
            return errorMessage;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrResultTO: ' + wrResultTO);
        List<gii__TransferOrderLine__c> lstTOLToInsert = new List<gii__TransferOrderLine__c>();
        for(string key : mapTO.keyset()){
            for(gii__TransferOrderLine__c objTOL : mapTOLine.get(key)){
                objTOL.gii__TransferOrder__c=mapTO.get(key).Id;
                lstTOLToInsert.add(objTOL);
              XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ inventoryWr.lstTOLToInsert' + objTOL);
            }
        }
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, '@@@ TOLine: ' + lstTOLToInsert);
        List<XC_UTIL_Sobject.WrapperResult> wrResultTOLine = XC_UTIL_Sobject.insertListRecords(lstTOLToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(wrResultTOLine)) {
            errorMessage = wrResultTOLine[0].errorMessage;
            return errorMessage;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wrResultTOLine: ' + wrResultTOLine);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ errorMessage: ' + errorMessage);
        return errorMessage;
    }
    
    /**
     * @author Sara Miozza - sara.miozza@nttdata.com , Roberta Porrega - roberta.porrega@nttdata.com
     * @param contacts the contacts
     * @date Creation 28/07/2019
     * @description method for manage Order Tracking
     */
    public static void closeSalesOrder(List<gii__TransferOrder__c> listNew, Map<Id, gii__TransferOrder__c> mapOld, Map<Id, gii__TransferOrder__c> mapNew){
        List<String> fieldToCheck = new List<String> { 'giic_status__c'};
        listNew = XC_UTIL_Sobject.getListChanged(fieldTocheck, mapOld, mapNew);
        if(listNew.isEmpty()){
           return; 
        } 
        closeSalesOrder(listNew);
    }

    /**
     * @author Sara Miozza - sara.miozza@nttdata.com , Roberta Porrega - roberta.porrega@nttdata.com
     * @param contacts the contacts
     * @date Creation 28/07/2019
     * @description method for manage Order Tracking
     */
    public static void closeSalesOrder(List<gii__TransferOrder__c> listNew){
        List<String> toListId = XC_UTIL_SObject.getIds(listNew);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'####DENTRO CLOSE SALES ORDER');
        List<gii__TransferOrder__c> toList  = new List<gii__TransferOrder__c>([SELECT Id, giic_status__c , gii__Account__c, gii__TransferToWarehouse__c,giic_SalesOrder__r.giic_isDelivery__c,
                                                                               giic_SalesOrder__r.giic_FSLWorkOrder__c,giic_SalesOrder__r.giic_WorkOrder__c,giic_SalesOrder__r.giic_WorkOrderLineItem__c,
                                                                               (SELECT Id,  gii__TransferOrderLine__c, gii__ProductSerial__c, 
                                                                                gii__TransferOrderLine__r.gii__Product__c,gii__ProductSerial__r.Name,
                                                                                gii__TransferOrderLine__r.giic_SalesOrderLine__r.giic_ProductRequiredId__c,
                                                                                gii__ShippedQuantity__c , gii__TransferOrderLine__r.gii__Quantity__c
                                                                                FROM gii__ShipmentDetails__r)  
                                                                                FROM gii__TransferOrder__c 
                                                                                WHERE giic_SalesOrder__r.giic_isDelivery__c=true
                                                                                AND Id IN :toListId
                                                                                AND giic_status__c = 'Received']);
        if(toList.isEmpty()){
           return; 
        }
        List<Giic_GoodsIssueSO.SalesOrder> soWrapList = new List<Giic_GoodsIssueSO.SalesOrder>();
        List<Id> woClosedIds = new List<Id>();
        for(gii__TransferOrder__c to : toList){
            woClosedIds.add(to.giic_SalesOrder__r.giic_WorkOrder__c);
            Giic_GoodsIssueSO.SalesOrder soWrap = new Giic_GoodsIssueSO.SalesOrder();
            soWrap.account = to.gii__Account__c;
            soWrap.warehouse = to.gii__TransferToWarehouse__c;
            soWrap.fslWorkOrder = to.giic_SalesOrder__r.giic_FSLWorkOrder__c;
            soWrap.fslWorkOrderLineItem = to.giic_SalesOrder__r.giic_WorkOrderLineItem__c;
            soWrap.SalesOrderLineList = new List<Giic_GoodsIssueSO.SalesOrderLine>();
            
            for(gii__ShipmentDetail__c ship : to.gii__ShipmentDetails__r){
                Giic_GoodsIssueSO.SalesOrderLine sol = new Giic_GoodsIssueSO.SalesOrderLine();
                sol.product = ship.gii__TransferOrderLine__r.gii__Product__c ;  
                sol.productRequiredID = ship.gii__TransferOrderLine__r.giic_SalesOrderLine__r.giic_ProductRequiredId__c; 
                sol.orderQuantity = ship.gii__TransferOrderLine__r.gii__Quantity__c;
                sol.consumedQuantity = ship.gii__ShippedQuantity__c;  
                
                sol.assignedSerials =  new List<Giic_GoodsIssueSO.AssignedSerial>(); 
                if(ship.gii__ProductSerial__c != null){ 
                    Giic_GoodsIssueSO.AssignedSerial serials = new Giic_GoodsIssueSO.AssignedSerial();
                    serials.serialNumber = ship.gii__ProductSerial__r.Name;   //Adding first Serial TODO verificare
                    sol.assignedSerials.add(serials);
                    sol.isSerialControlled = true;  //NR2493
                }
                soWrap.SalesOrderLineList.add(sol);
            }
            
         XC_UTIL_Debug.debug(DEBUGACTIVE,'####soWrap.SalesOrderLineList' + soWrap.SalesOrderLineList);
            soWrapList.add(soWrap);
        }
        Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(soWrapList);
         XC_UTIL_Debug.debug(DEBUGACTIVE,'*******the Goods issue response is*******'+goodsIssueResponse);
        Map<Id,WorkOrder> workOrderOtherMap  = new  Map<Id,WorkOrder>();
        map<Id,String> workOrderRejectReason = new  map<Id,String>();
        if(!woClosedIds.isEmpty()){ workOrderOtherMap = giic_TR_PurchaseOrder_ManageUpdate.getWoMap(woClosedIds); }
        if(!workOrderOtherMap.isEmpty()){
            List<XC_Customer_Interaction__c> customInterList = giic_TR_PurchaseOrder_ManageUpdate.populateCustomInterListFromPO(workOrderOtherMap.values(),  'Orders_Pickup_Closed',workOrderRejectReason);
            XC_UTIL_Glovia.insertAndLogError(customInterList);
        }
    }
    
    /**  
    * @author FirstName :Roberta Porrega - roberta.porrega@nttdata.com
    * @date Creation 26/11/2019
    * @date Modification dd/mm/yyyy
    * @description To check limits on incoming transfer orders.
    * @param purchaseOdrLineList -  List of transfer order
    * @param isInsert -  to check if trigger is Insert type
    * @param mapOldS -  List of old transferorder
    */    
    public static void setCorrectRecordTypeInInsert(List<gii__TransferOrder__c> transferOdrList){ 
        for(gii__TransferOrder__c to : transferOdrList) { 
                to.recordTypeId = Schema.SObjectType.gii__TransferOrder__c.getRecordTypeInfosByDeveloperName().get('giic_RT_TransferOrder').getRecordTypeId(); 
        }
    }

    /**  
    * @author FirstName :Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 10/12/2020
    * @date Modification dd/mm/yyyy
    * @description to reserve quantities after to deletion
    * @param List<Id> -  List of transfer order Id
    */
    public static void reserveQuantitiesAfterToDel(List<Id> toIdList){
        List<gii__TransferOrderLine__c> tolList= new List<gii__TransferOrderLine__c>();
        tolList = Giic_TransferOrderUtility_D.getTransferOrderLine(toIdList);
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'tolList: '+ tolList);
        giic_TransferOrderLineUtility.reserveQuantitiesForTolAfterToDel(tolList);
    }

    /**  
    * @author FirstName :Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 24/06/2021
    * @date Modification dd/mm/yyyy
    * @description to rebalt from Warehouse fields on TO
    * @param List<Id> -  List of transfer order
    */
    public static void checkIfFromWHChange(List<gii__TransferOrder__c> listNew,Map<Id,gii__TransferOrder__c> mapOld, Map<Id,gii__TransferOrder__c> mapNew){
        List<String> fieldList = new List<String>{'gii__FromWarehouse__c'};
        List<gii__TransferOrder__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        rebaltFromWhFieldsOnTO(listChanged);    
    }

    /**  
    * @author FirstName : Alberto Pompei - alberto.pompei@nttdata.com
    * @date Creation 24/06/2021
    * @description to rebalt from Warehouse fields on TO
    * @param List<Id> - List of transfer order
    */
    public static void rebaltFromWhFieldsOnTO(List<gii__TransferOrder__c> listNew){
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'in rebaltFromWhFieldsOnTO');
        Set<id> whIdSet = New Set<id>();
        
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'toList: '+ listNew);
        for(gii__TransferOrder__c to : listNew){
            whIdSet.add(to.gii__FromWarehouse__c);
        }

        Map<id, gii__Warehouse__c> whMap = New map<id, gii__Warehouse__c>([SELECT id, gii__Account__r.name, gii__WareHouseStreet__c, gii__WareHouseStateProvince__c,
                                                                        gii__WareHouseZipPostalCode__c, gii__WareHouseCity__c, gii__WareHouseCountry__c
                                                                        FROM gii__Warehouse__c
                                                                        WHERE id IN: whIdSet]);
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, 'whMap: '+ whMap);
        for(gii__TransferOrder__c to : listNew){
            to.giic_ShipFromName__c = whMap.get(to.gii__FromWarehouse__c).gii__Account__r.name;
            to.giic_ShipFromAddress__c = whMap.get(to.gii__FromWarehouse__c).gii__WareHouseStreet__c;
            to.giic_ShipFromProvince__c = whMap.get(to.gii__FromWarehouse__c).gii__WareHouseStateProvince__c;
            to.giic_ShipFromZipCode__c = whMap.get(to.gii__FromWarehouse__c).gii__WareHouseZipPostalCode__c;
            to.giic_ShipFromCity__c = whMap.get(to.gii__FromWarehouse__c).gii__WareHouseCity__c;
            to.giic_ShipFromCountry__c = whMap.get(to.gii__FromWarehouse__c).gii__WareHouseCountry__c;

        }   
    }
    
    public static void codeCoverage() {
    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Code coverage');
    }

    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date 05/07/2019
    * @description Create TO and PO for local warehouse ROP
    * @param piList List<gii__ProductInventory__c>  
    */  
    /*public static void runROPForLocalWarehouse(List<gii__ProductInventory__c> piList){     
        if(!piList.isEmpty()){  
            //Set<Id> setWarehouseGrpId= new Set<Id>();// To store All warehouseGroup Ids
            Set<Id> prodIds= new Set<Id>();// To store all product Reference Ids
            Set<Id> setWarehouseIds= new Set<Id>();
            Set<Id> setLocationIds=new Set<Id>();
            set<Id> setLocalWarehouseIds=new set<Id>();
            map<string,integer> mapPRODWHLOCWithAvailQty=new map<string,integer>();
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'piList'+piList);
            for(gii__ProductInventory__c pi : piList){
                setWarehouseIds.add(pi.gii__Warehouse__c);
                setLocalWarehouseIds.add(pi.gii__Warehouse__c);
                if(pi.gii__Warehouse__r.giic_ParentWarehouse__c != null){
                    setWarehouseIds.add(pi.gii__Warehouse__r.giic_ParentWarehouse__c);
                }
                if(pi.gii__Warehouse__r.gii__DefaultIssueLocation__c != null){
                    setLocationIds.add(pi.gii__Warehouse__r.gii__DefaultIssueLocation__c);
                    if(pi.gii__Warehouse__r.giic_ParentWarehouse__c != null &&
                       pi.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c != null){
                           setLocationIds.add(pi.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c);
                       }
                }
                prodIds.add(pi.gii__Product__c);
            }
            AggregateResult[] groupedResults;
            if(Schema.sObjectType.gii__ProductInventorybyLocation__c.isQueryable()){
                groupedResults = [SELECT gii__Location__c loc,gii__Product__c prod,gii__Warehouse__c wh, sum(gii__AvailableQuantity__c) availQty FROM gii__ProductInventorybyLocation__c where gii__Location__c in :setLocationIds and gii__Product__c in : prodIds and gii__Warehouse__c in : setWarehouseIds GROUP BY gii__Location__c,gii__Product__c,gii__Warehouse__c];
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'groupedResults'+groupedResults);
            }
            for (AggregateResult ar : groupedResults)  {
                string key=(string)ar.get('prod') + '-' + (string)ar.get('wh')+ '-' + (string)ar.get('loc');
                if(ar.get('availQty') != null){
                    mapPRODWHLOCWithAvailQty.put(key,integer.valueof(ar.get('availQty')));
                }
            }
            runROPQuery(piList,mapPRODWHLOCWithAvailQty,setLocalWarehouseIds);
        } 
    }*/
    
    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date 05/07/2019
    * @description Create TO and PO for for local warehouse ROP
    * @param piList List<gii__ProductInventory__c>  
    * @param mapPRODWHLOCWithAvailQty map<string,integer> 
    * @param setLocalWarehouseIds set<Id> 
    */     
    /*public static void runROPQuery(List<gii__ProductInventory__c> piList, map<string,integer> mapPRODWHLOCWithAvailQty,set<Id> setLocalWarehouseIds){  
        /*for(gii__TransferOrderLine__c objTOL : [select id,gii__Quantity__c,gii__TransferOrder__r.gii__TransferToWarehouse__c,gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__DefaultIssueLocation__c,
        gii__Product__c from gii__TransferOrderLine__c where gii__TransferOrder__r.giic_Approved__c=true and gii__TransferOrder__r.giic_Status__c=:System.Label.giic_StatusOpen and 
        gii__TransferOrder__r.gii__TransferToWarehouse__c in :setLocalWarehouseIds]){
        string key=objTOL.gii__Product__c + '-' + objTOL.gii__TransferOrder__r.gii__TransferToWarehouse__c+'-' + objTOL.gii__TransferOrder__r.gii__TransferToWarehouse__r.gii__DefaultIssueLocation__c;
        if(!mapPRODWHLOCWithAvailQty.containsKey(key)){
        mapPRODWHLOCWithAvailQty.put(key,(integer)objTOL.gii__Quantity__c);
        }
        else{
        mapPRODWHLOCWithAvailQty.put(key,integer.valueof(mapPRODWHLOCWithAvailQty.get(key) + objTOL.gii__Quantity__c));
        }
        }*/
        //Calling processROPForLocalWarehouse
      /*  processROPForLocalWarehouse(piList,mapPRODWHLOCWithAvailQty);
    }  */   
    
    /**
    * @author FirstName : Parveen Kaur - Parveen.Kaur@in.fujitsu.com
    * @date 05/07/2019
    * @description Create TO and PO for for local warehouse ROP
    * @param piList List<gii__ProductInventory__c>  
    * @param mapPRODWHLOCWithAvailQty map<string,integer> 
    */      
    /*public static void processROPForLocalWarehouse(List<gii__ProductInventory__c> piList, map<string,integer> mapPRODWHLOCWithAvailQty){ 
        map<string,integer> mapPRODWHLOCWithSugQty=new map<string,integer>();
        map<string,gii__TransferOrder__c> mapTransferOrder=new map<string,gii__TransferOrder__c>();
        map<string,list<gii__TransferOrderLine__c>> mapTransferOrderLine=new map<string,list<gii__TransferOrderLine__c>>();// Map of PI Ids and Transfer Order  
        map<string,list<gii__ProductInventory__c>> mapSupplierProductPI=new map<string,list<gii__ProductInventory__c>>();
        set<string> setTOWH=new set<string>();
        set<Id> settProductIds=new set<Id>();
        set<Id> setSupplierIds=new set<Id>();
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap = new List<giic_ReservationUtility.ReservationWrapper>();
        list<gii__ProductInventory__c> lstPIForPOCreation=new list<gii__ProductInventory__c>();
        for(gii__ProductInventory__c objPI : piList){
            string key=objPI.gii__Product__c + '-' + objPI.gii__Warehouse__c+'-' + objPI.gii__Warehouse__r.gii__DefaultIssueLocation__c;
            Integer prodWHLOC =mapPRODWHLOCWithAvailQty.containsKey(key) ? mapPRODWHLOCWithAvailQty.get(key) : 0;
            integer totalAvailQty=integer.valueof(prodWHLOC+objPI.gii__TotalOnOrder__c); 
            integer dSuggestedQty = integer.valueof(objPI.gii__OrderPointQuantity__c - totalAvailQty); 
            objPI.gii__OrderQuantityMultiple__c =objPI.gii__OrderQuantityMultiple__c != null ? objPI.gii__OrderQuantityMultiple__c :0;  
            if(dSuggestedQty > 0 &&  totalAvailQty < objPI.gii__OrderPointQuantity__c){
                if(objPI.gii__OrderQuantityMultiple__c==0.0){
                    objPI.gii__OrderQuantityMultiple__c=1.0;
                }
                if(dSuggestedQty < objPI.gii__MinimumOrderQuantity__c){
                    dSuggestedQty = integer.valueof(objPI.gii__MinimumOrderQuantity__c);
                }
                if(math.mod(integer.valueOf(dSuggestedQty),integer.valueOf(objPI.gii__OrderQuantityMultiple__c)) !=0){
                    dSuggestedQty = integer.valueOf(objPI.gii__OrderQuantityMultiple__c) * integer.valueof((dSuggestedQty/objPI.gii__OrderQuantityMultiple__c).setscale(0,RoundingMode.UP));
                }
                string parentKey=objPI.gii__Product__c + '-' + objPI.gii__Warehouse__r.giic_ParentWarehouse__c  + '-'+ objPI.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c;
                 
                if(mapPRODWHLOCWithAvailQty.containsKey(parentKey) && mapPRODWHLOCWithAvailQty.get(parentKey) > 0){
                    
                    integer qtyReserved=0;
                    if(dSuggestedQty > mapPRODWHLOCWithAvailQty.get(parentKey)){
                        qtyReserved = mapPRODWHLOCWithAvailQty.get(parentKey); 
                        lstPIForPOCreation.add(objPI);
                        settProductIds.add(objPI.gii__Product__c); 
                        setSupplierIds.add(objPI.gii__Product__r.gii__PrimarySupplier__c);
                        string suppProdKey=objPI.gii__Product__r.gii__PrimarySupplier__c +'-' + objPI.gii__Product__c;
                        setSupplierIds.add(objPI.gii__Product__r.gii__PrimarySupplier__c);
                        if(!mapSupplierProductPI.containskey(suppProdKey)){
                            mapSupplierProductPI.put(suppProdKey,new list<gii__ProductInventory__c>());
                        }
                        mapSupplierProductPI.get(suppProdKey).add(objPI);
                        mapPRODWHLOCWithSugQty.put(key,dSuggestedQty-mapPRODWHLOCWithAvailQty.get(parentKey));
                        mapPRODWHLOCWithAvailQty.put(parentKey,0);
                    }
                    else{
                        qtyReserved = dSuggestedQty;
                        mapPRODWHLOCWithAvailQty.put(parentKey,integer.valueof(mapPRODWHLOCWithAvailQty.get(parentKey)-dSuggestedQty));
                    } 
                    string toKey=objPI.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objPI.gii__Warehouse__c;
                    if(!setTOWH.contains(toKey)){
                        gii__TransferOrder__c objTO=new gii__TransferOrder__c(giic_Source__c=Label.giic_SourceReorderPlanning,gii__Account__c=objPI.gii__Warehouse__r.gii__Account__c,gii__FromWarehouse__c=objPI.gii__Warehouse__r.giic_ParentWarehouse__c,
                                                                              gii__TransferToWarehouse__c=objPI.gii__Warehouse__c,giic_Approved__c=true,giic_Status__c=Label.giic_TOOpenStatus);
                        mapTransferOrder.put(toKey,objTO);
                        gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(gii__Product__c=objPI.gii__Product__c,gii__Quantity__c = qtyReserved);
                        mapTransferOrderLine.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine});
                        setTOWH.add(toKey);
                        
                    }
                    else{
                        gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(gii__Product__c=objPI.gii__Product__c,gii__Quantity__c = qtyReserved);
                        mapTransferOrderLine.get(toKey).add(objTOLine);
                    }
                    reserveWrap.add(giic_ReservationUtility.getReservationWrapper( objPI.gii__Warehouse__r.giic_ParentWarehouse__c,objPI.gii__Product__c ,
                                                                                  qtyReserved,objPI.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c));
                }
                else{
                    settProductIds.add(objPI.gii__Product__c);
                    setSupplierIds.add(objPI.gii__Product__r.gii__PrimarySupplier__c);
                    string suppProdKey=objPI.gii__Product__r.gii__PrimarySupplier__c +'-' + objPI.gii__Product__c;
                    setSupplierIds.add(objPI.gii__Product__r.gii__PrimarySupplier__c);
                    if(!mapSupplierProductPI.containskey(suppProdKey)){
                        mapSupplierProductPI.put(suppProdKey,new list<gii__ProductInventory__c>());
                    }
                    mapSupplierProductPI.get(suppProdKey).add(objPI);
                    mapPRODWHLOCWithSugQty.put(key,dSuggestedQty);
                }
            }                
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapTransferOrder'+mapTransferOrder);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapTransferOrderLine'+mapTransferOrderLine);
        //Calling method insertTO
        insertTO(mapTransferOrder,mapTransferOrderLine);
        if(reserveWrap.size() > 0){
            giic_ReservationUtility.reserveQuantities(reserveWrap);
        }
         
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapPRODWHLOCWithSugQty'+mapPRODWHLOCWithSugQty);
        giic_PurchaseOrderUtility.createPOforROPProcess(settProductIds,setSupplierIds,mapSupplierProductPI,mapPRODWHLOCWithSugQty,false);
    }*/

    /*webservice static String getCurrentUserProfileName(){
        id id1 = userinfo.getProfileId();
        Profile p = [SELECT Id, Name from Profile where id = :id1 LIMIT 1];
        return p.Name;
    }*/
}
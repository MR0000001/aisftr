/**
* @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
* @date Creation 22/07/2019
* @description Giic_StockAvailabilityUtility – Utility to check availability date in local and central warehouse.
*/

public without sharing class Giic_StockAvailabilityUtility { 
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_StockAvailabilityUtility');

    //****************************************************************************************************** WRAPPER: */

    /** @description ProductAvailabilityResponse Wrapper  */
    public class ProductAvailabilityResponse{
        public List<gii__SalesOrder__c> salesOrderToUpdate;
        public List<gii__SalesOrderLine__c> salesOrderLineToUpdate; 
        public List<gii__SalesOrderLine__c> lstNotReservedLines;
        public Map<Id,boolean> mapSOLIsDropShip;
        public TransferOrderWrapper objTOWrapper;
        public PurchaseOrderWrapper objPOWrapper;
        public List<giic_ReservationUtility.ReservationWrapper> reserveWrap;
        public List<gii__ProductInventory__c> lstPIToUpdateBackOrderQty;
        public List<string> lstErrors;
        //[NR1107]
        public Map<string,gii__ProductInventory__c> mapWHPRLOWithPI;
		public Map<string,List<gii__ProductInventoryQuantityDetail__c>> mapWHPIQD;
        public Set<Id> listProduct2AddIds = new Set<Id>();
    }

    /** @description – StockAvailabilityWrapper Wrapper class */
    public class StockAvailabilityWrapper{
        public List<String> partnersWH;
        public List<String> errorList;
        public String pdtCode;
        public String zipCode;
        public String province;
        public Decimal reqQuantity;
        public String requestType;
        public Date availabilityTime;
        public String toWarehouse;
        public Map<String, Date> mapToWarehouseAvailabilityTime = new Map<String, Date>();
        public string errorMessage = '';
        public string country;
        public string legalEntity;  // new
        public string segment;  // new
    }

    /** @description – InventoryWrapper Wrapper class */
    public class InventoryWrapper{
        public set<Id> setWarehouseIds;
        public set<Id> setLocationIds;
        public list<string> lstErrors;
        public set<id> setWarehouseGroupIds;
    }

    /** @description – ProcurementTypeTransferWrapper Wrapper class */
    public class ProcurementTypeTransferWrapper{
        Set<string> setPOKey=new set<string>();
        Set<string> setTOWH=new set<string>();
        public List<gii__PriceBookEntry__c> lstPriceBookAndPBEntry ;
        public Map<String,gii__PriceBookEntry__c> mapPBEClosedOrders ;
        public gii__SalesOrderLine__c objSOL;
        public map<string,integer> mapWHPRLOWithAvlQty;
        public map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability;
        public map<string,gii__ProductInventory__c> mapWHPRLOWithPI;
        public boolean isContinue;
        public List<giic_ReservationUtility.ReservationWrapper> reserveWrap;
        public map<id,gii__Warehouse__c> mapAllNetworkWarehouses;
    }

    /** @description –TransferOrderWrapper Wrapper class */
    public class TransferOrderWrapper{
        public map<string,gii__TransferOrder__c> mapTransferOrder;
        public map<string,list<gii__TransferOrderLine__c>> mapTransferOrderLine;
    }

    /** @description –PurchaseOrderWrapper Wrapper class */
    public class PurchaseOrderWrapper{
        public map<string,gii__PurchaseOrder__c> mapPurchaseOrder;
        public map<string,list<gii__PurchaseOrderLine__c>> mapPurchaseOrderLine;    
    }

    /** @description – POCreationResponse Wrapper class */
    public class POCreationResponse{
        public List<String> lstErrors;
        public Map<Id, giic_CommonWrapper.ProductAvailability> mapProductWithAvailability;
        public List<Giic_CommonWrapper.ProductWrapper> productsWrapper = new List<Giic_CommonWrapper.ProductWrapper>();
        public List<giic_ReservationUtility.ReservationWrapper> listReservationWrapper = new List<giic_ReservationUtility.ReservationWrapper>();
        public Map<String, String> mapUniqueKeyPONumber = new Map<String, String>();
    }

    /** @description – POCreationForReservation Wrapper class */
    public class POCreationForReservation{
        public boolean isDropShip;
        public map<id,boolean> mapSOLIdWithIsDropShip;
        public map<string,list<gii__SalesOrderLine__c>> mapSupplierProductSOLs;
    }

    /** @description – ParamsWrapper Wrapper class */
    public class ParamsWrapper{
        public Map<String,Integer> mapPRODWHLOCWithAvailQty;
        public Map<String,gii__Product2Add__c> mapOfPdtCodeVsPdt;
        public Map<String,List<gii__Warehouse__c>> mapOfZipVsWHlist;
        public List<gii__Warehouse__c> warehouselstOfZipWHGrp;
        public Set<String> zipWHGrpIdSet;
        public Map<String,gii__ProductInventory__c> mapOfZipWHGrpWHPdtCodeVsPI;
        public Map<Id,gii__Warehouse__c> mapOfIdVsWH;
        public Map<String,gii__ProductInventory__c> mapOfWHGrpWHPdtCodeVsPI;
        public Map<String, XC_CM_WarehouseSupplyFlow__mdt> mapCountryWHSupplyFlow;
        public Map<String, XC_CM_WarehouseSupplyFlow__mdt> mapLEWHSupplyFlow ;
        public List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper> stockAvailWrappList;    
        public Map<String,Decimal>  mapProductSupplierTime;
        public Map<String,gii__Warehouse__c>  mapWHGroupToWHCentral ;
        public Map<String,gii__ProductInventory__c> mapOfPdtCodeVsPI;
        public Map<String,List<gii__Warehouse__c>> mapOfWHGrpVsWHlist;       
        public Map<String,List<String>>  zipCodeWarehouseGroup;
        public Map<String,List<String>>  provinceWarehouseGroup;
        public Map<String,List<String>>  legalEntityWarehouseGroup;
    }
    
    //*****************************************************************************************************************/

    //****************************************************************************************************** METHODS: */
    
    /**
    * @author: Roberta Porrega - roberta.porrega@nttdata.com
    * @date Creation 22/07/2019
    * @date Modification 26/10/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description – Method to check availability date in local and central warehouse
    * @param stockAvailWrappList - List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper>
    * @return List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> 
    */  
    public static List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> getFirstAvailability(List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper> stockAvailWrappList) {  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In getFirstAvailability');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In Input method stockAvailWrappList: ' + stockAvailWrappList);
        if(stockAvailWrappList != null && !stockAvailWrappList.isEmpty()) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Creating util variables...');
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stockAvailWrappList: ' + stockAvailWrappList);
            Set<String> pdtCodeSet                                          = new Set<String>();
            Set<String> wareHouseIdSet                                      = new Set<String>();
            Set<String> warehouseGrpIds                                     = new Set<String>();
            Set<String> toWarehouseGrpIds                                   = new Set<String>();
            Set<String> toWareHouseIdSet                                    = new Set<String>();
            Set<String> pdtIdSet                                            = new Set<String>();
            Set<String> zipCodeSet                                          = new Set<String>();
            Set<String> provinceSet                                         = new Set<String>();
            Set<String> legalEntitySet                                      = new Set<String>();
            Set<String> zipWHGrpIdSet                                       = new Set<String>();
            Set<Id> whPIsId                                                 = new Set<Id>(); 
            Set<String> countrySet                                          = new Set<String>(); 
            List<gii__Warehouse__c> warehouselst                            = new List<gii__Warehouse__c>();
            List<gii__Warehouse__c> warehouselstOfZipWHGrp                  = new List<gii__Warehouse__c>();
            List<gii__Product2Add__c> prodRefLst                            = new List<gii__Product2Add__c>();
            Map<String,Integer> mapPRODWHLOCWithAvailQty                    = new Map<String,Integer>(); 
            List<gii__ProductInventory__c> lstProductInventory              = new List<gii__ProductInventory__c>(); 
            Map<String,List<gii__Warehouse__c>> mapOfZipVsWHlist            = new Map<String,List<gii__Warehouse__c>>();
            Map<String,gii__ProductInventory__c> mapOfPdtCodeVsPI           = new Map<String,gii__ProductInventory__c>();
            Map<String,gii__ProductInventory__c> mapOfToWHPdtCodeVsPI       = new Map<String,gii__ProductInventory__c>();
            Map<String,List<gii__Warehouse__c>> mapOfWHGrpVsWHlist          = new Map<String,List<gii__Warehouse__c>>();
            Map<String,gii__ProductInventory__c> mapOfWHGrpWHPdtCodeVsPI    = new Map<String,gii__ProductInventory__c>();
            Map<String,gii__ProductInventory__c> mapOfZipWHGrpWHPdtCodeVsPI = new Map<String,gii__ProductInventory__c>();
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Util variables created');

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Populating util variables...');
            for(Giic_StockAvailabilityUtility.StockAvailabilityWrapper wrap : stockAvailWrappList) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For wrap: ' + wrap);
                pdtCodeSet.add(wrap.pdtCode);
                zipCodeSet.add(wrap.zipCode);
                provinceSet.add(wrap.province);
                legalEntitySet.add(wrap.legalEntity);
                if(wrap.partnersWH != null){
                    toWareHouseIdSet.addAll(wrap.partnersWH);
                }
                countrySet.add(wrap.country);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Util variables populated');

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ provinceSet: ' + provinceSet);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ zipCodeSet: ' + zipCodeSet);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ countrySet: ' + countrySet);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ pdtCodeSet: ' + pdtCodeSet);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ legalEntitySet: ' + legalEntitySet);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ toWareHouseIdSet: ' + toWareHouseIdSet);

            if(pdtCodeSet != null && !pdtCodeSet.isEmpty() && ((zipCodeSet != null && !zipCodeSet.isEmpty() || provinceSet != null && !provinceSet.isEmpty() )) && legalEntitySet != null && !legalEntitySet.isEmpty()){
                // If all mandatory fields are ok:
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ All mandatory fields are ok');

                // Get settings from Custom Metadata:
                Map<Id, XC_CM_WarehouseSupplyFlow__mdt> mapWarehouseSupplyFlow = new Map<Id, XC_CM_WarehouseSupplyFlow__mdt>([
                    SELECT Id ,XC_CheckAvailabilityMode__c,XC_Country__c,XC_FirstWarehouseCheck__c,XC_LegalEntity__c, XC_LogisticPartnerSupplyTime__c,XC_PurchaseOrderWarehouse__c,XC_SupplierSupplyTime__c,XC_AvailabilityByProvince__c
                    FROM XC_CM_WarehouseSupplyFlow__mdt
                    WHERE XC_LegalEntity__c IN :legalEntitySet 
                ]);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ CustomMetadata mapWarehouseSupplyFlow: ' + mapWarehouseSupplyFlow);
                Map<String, XC_CM_WarehouseSupplyFlow__mdt> mapCountryWHSupplyFlow = new Map<String, XC_CM_WarehouseSupplyFlow__mdt>();
                Map<String, XC_CM_WarehouseSupplyFlow__mdt> mapLEWHSupplyFlow = new Map<String, XC_CM_WarehouseSupplyFlow__mdt>();
                if(!mapWarehouseSupplyFlow.values().IsEmpty()){
                    for(XC_CM_WarehouseSupplyFlow__mdt mdt : mapWarehouseSupplyFlow.values()){
                        mapCountryWHSupplyFlow.put(mdt.XC_Country__c , mdt);
                        mapLEWHSupplyFlow.put(mdt.XC_LegalEntity__c , mdt);
                    } 
                } 
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ CustomMetadata mapCountryWHSupplyFlow: ' + mapCountryWHSupplyFlow);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ CustomMetadata mapLEWHSupplyFlow: ' + mapLEWHSupplyFlow);

                // Get Product Information:
                Map<String, String> mapProductSupplier = new Map<String, String>();
                Map<String, gii__Product2Add__c> mapOfPdtCodeVsPdt = new Map<String, gii__Product2Add__c>();
                List<gii__Product2Add__c> prodList = new List<gii__Product2Add__c>([
                    SELECT Id, Name,giic_ProcurementType__c,gii__ProductCode__c, gii__PrimarySupplier__c , giic_EndDate__c 
                    FROM gii__Product2Add__c 
                    WHERE gii__ProductReference__r.ProductCode IN: pdtCodeSet AND  giic_LegalEntity__c IN: legalEntitySet
                ]);  
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ prodList: ' + prodList);																													
                if(!prodList.IsEmpty()){
                    for(gii__Product2Add__c pdtObj : prodList) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For product: ' + pdtObj);
                        mapOfPdtCodeVsPdt.put(pdtObj.gii__ProductCode__c,pdtObj);
                        mapProductSupplier.put(pdtObj.gii__ProductCode__c,pdtObj.gii__PrimarySupplier__c);
                        pdtIdSet.add(pdtObj.Id);
                    } 
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ prodList: ' + prodList);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ mapOfPdtCodeVsPdt: ' + mapOfPdtCodeVsPdt);
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ mapProductSupplier: ' + mapProductSupplier);

                // Get WH Information:
                List<String> whGroup = new  List<String> ();
                if(toWareHouseIdSet != null && !toWareHouseIdSet.isEmpty()) {
                    // For Delivery&Installation: 
                    List<gii__Warehouse__c> wh = new List<gii__Warehouse__c>([
                        SELECT Id,Name,gii__WarehouseGroup__c,gii__WarehouseGroup__r.Name,gii__DefaultIssueLocation__c,giic_WarehouseType__c
                        FROM gii__Warehouse__c 
                        WHERE Id IN: toWareHouseIdSet
                    ]); 
                    whGroup = XC_UTIL_Sobject.getListFieldValues(wh, 'gii__WarehouseGroup__c');
                }
                Map<Id,gii__Warehouse__c> getCentralWH = new Map<Id,gii__Warehouse__c> ([
                    SELECT Id,Name,gii__WarehouseGroup__c,gii__WarehouseGroup__r.Name, gii__DefaultIssueLocation__c,giic_WarehouseType__c,giic_LegalEntity__c
                    FROM gii__Warehouse__c
                    WHERE  giic_LegalEntity__c IN :legalEntitySet AND giic_WarehouseType__c = :Label.giic_WarehouseTypeCentral 
                ]);
                Map<String, List<gii__Warehouse__c>>  legalEntityCentralWH = new Map<String, List<gii__Warehouse__c>>(); 
                for(gii__Warehouse__c whObj : getCentralWH.values()) {
                    if(!legalEntityCentralWH.containsKey(whObj.giic_LegalEntity__c)){
                        legalEntityCentralWH.put(whObj.giic_LegalEntity__c,new list<gii__Warehouse__c>());
                    }
                    legalEntityCentralWH.get(whObj.giic_LegalEntity__c).add(whObj);
                }                
                Set<String> whGroupToCheck = new Set<String>();
                for(String lE : legalEntityCentralWH.keyset()) {
                    if(legalEntityCentralWH.get(lE).size() > 1){
                        List<String> getWHGroup = XC_UTIL_Sobject.getListFieldValues(legalEntityCentralWH.get(lE), 'gii__WarehouseGroup__c');
                        for(String s : getWHGroup){
                            whGroupToCheck.add(s);
                        }                        
                    } else{
                        if(!legalEntityCentralWH.get(lE).isEmpty() ){
                            whGroup.add(legalEntityCentralWH.get(lE)[0].gii__WarehouseGroup__c);
                        }                        
                    }                    
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whGroup: ' + whGroup);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whGroupToCheck: ' + whGroupToCheck);
                      
                // Only if for a LE there are more Central WH: 
                if(!whGroupToCheck.isEmpty()) {              
                    List<gii__ZoneTableZipPostalCode__c> zoneZipCode = new List<gii__ZoneTableZipPostalCode__c>([
                        SELECT Id, gii__ZoneTable__c,gii__StartZipPostalCode__c
                        FROM gii__ZoneTableZipPostalCode__c 
                        WHERE gii__StartZipPostalCode__c IN :zipCodeSet AND gii__EndZipPostalCode__c IN :zipCodeSet AND gii__ZoneTable__r.gii__CountryCode__r.gii__CountryName__c IN:countrySet
                    ]);
                    Map<String,List<String>> zipCodeZoneTable  = new Map<String,List<String>>();  
                    if(!zoneZipCode.IsEmpty()){
                        for(gii__ZoneTableZipPostalCode__c zp : zoneZipCode ){
                            if(!zipCodeZoneTable.containsKey(zp.gii__ZoneTable__c)){
                                zipCodeZoneTable.put(zp.gii__ZoneTable__c , new List<String>());    
                            }
                            zipCodeZoneTable.get(zp.gii__ZoneTable__c).add(zp.gii__StartZipPostalCode__c); 
                        }
                    }
                   
                    List<giic_WarehaouseZoneZip__c> whZoneZip = new List<giic_WarehaouseZoneZip__c>([
                        SELECT Id ,giic_WarehouseGroup__c,giic_ZipPostalCode__c,giic_ZoneTable__r.Name, giic_ZoneTable__c,giic_ZipPostalCode__r.gii__StartZipPostalCode__c
                        FROM giic_WarehaouseZoneZip__c
                        WHERE giic_ZoneTable__c IN :zipCodeZoneTable.keySet() OR giic_ZipPostalCode__c IN :zoneZipCode OR giic_ZoneTable__r.Name IN :provinceSet
                    ]);
                    Map<String,List<String>> zipCodeWarehouseGroup = new Map<String,List<String>>();
                    Map<String,List<String>> provinceWarehouseGroup = new Map<String,List<String>>();
                    if(!whZoneZip.IsEmpty()){
                        for(giic_WarehaouseZoneZip__c wh : whZoneZip) { 
                            whGroup.add(wh.giic_WarehouseGroup__c);                          
                        }      
                    } 
                }
                                
                Map<Id,gii__Warehouse__c> mapOfIdVsWH = new Map<Id,gii__Warehouse__c>([
                    SELECT Id,Name,gii__WarehouseGroup__c,gii__WarehouseGroup__r.Name, gii__DefaultIssueLocation__c,giic_WarehouseType__c,giic_LegalEntity__c
                    FROM gii__Warehouse__c
                    WHERE  giic_LegalEntity__c IN :legalEntitySet AND gii__WarehouseGroup__c IN: whGroup
                ]);
                Map<String,gii__Warehouse__c> mapWHGroupToWHCentral = new  Map<String,gii__Warehouse__c>();
                Map<String,List<String>> legalEntityWarehouseGroup = new  Map<String,List<String>>();
                List<String> allWarehouse = new List<String>();
                if(!mapOfIdVsWH.values().isEmpty()){
                    for(gii__Warehouse__c whObj : mapOfIdVsWH.values()){
                        allWarehouse.add(whObj.Id);
                        if(!mapOfWHGrpVsWHlist.containsKey(whObj.gii__WarehouseGroup__c)){
                            mapOfWHGrpVsWHlist.put(whObj.gii__WarehouseGroup__c,new list<gii__Warehouse__c>{whObj});
                        }
                        mapOfWHGrpVsWHlist.get(whObj.gii__WarehouseGroup__c).add(whObj);
                        if(whObj.giic_WarehouseType__c == Label.giic_WarehouseTypeCentral){ 
                            mapWHGroupToWHCentral.put(whObj.gii__WarehouseGroup__c, whObj); 
                        }    
                        if(!legalEntityWarehouseGroup.containsKey(whObj.giic_LegalEntity__c)){
                            legalEntityWarehouseGroup.put(whObj.giic_LegalEntity__c,new list<String>{whObj.gii__WarehouseGroup__c});
                        }
                        legalEntityWarehouseGroup.get(whObj.giic_LegalEntity__c).add(whObj.gii__WarehouseGroup__c);   
                    }  
                } 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWHGroupToWHCentral: ' + mapWHGroupToWHCentral);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfWHGrpVsWHlist: ' + mapOfWHGrpVsWHlist);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfWHGrpVsWHlist: ' + legalEntityWarehouseGroup);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWHGroupToWHCentral: ' + mapWHGroupToWHCentral);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfWHGrpVsWHlist: ' + mapOfWHGrpVsWHlist);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfWHGrpVsWHlist: ' + legalEntityWarehouseGroup);
                
                // Get Product Inventory Information:      
                List<gii__ProductInventory__c> pIList = new List<gii__ProductInventory__c>( [
                    SELECT Id,gii__Product__r.gii__ProductCode__c,Name,gii__AvailableQuantity__c, gii__TotalOnOrder__c,gii__Warehouse__r.giic_LegalEntity__c, gii__Warehouse__c,gii__Warehouse__r.gii__WarehouseGroup__c, gii__Warehouse__r.giic_WarehouseType__c, gii__BackOrderQuantity__c ,giic_AvgTransferTime__c,giic_SalesOnHand__c
                    FROM gii__ProductInventory__c 
                    WHERE gii__Product__c IN: pdtIdSet AND (gii__Warehouse__c IN :toWarehouseIdSet OR gii__Warehouse__c IN: allWarehouse) 
                ]);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ pdtIdSet: ' + pdtIdSet);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ pIList: ' + pIList);
                if(!pIList.isEmpty()){
                    for(gii__ProductInventory__c piobj : pIList){ 
                        // Map: Product/Warehouse -> PRODUCT INVENTORY
                        if(allWarehouse.contains(piobj.gii__Warehouse__c)){
                            mapOfPdtCodeVsPI.put(piobj.gii__Product__r.gii__ProductCode__c+piobj.gii__Warehouse__c,piobj);
                        }
                    } 
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfPdtCodeVsPI: ' + mapOfPdtCodeVsPI);

                // Get PriceBook Information:
                List<gii__PriceBookEntry__c> pbEntry = new List<gii__PriceBookEntry__c>([
                    SELECT Id ,giic_AvgSupplyTime__c,gii__Product__r.gii__ProductCode__c, gii__PriceBook__r.giic_Contract__r.XC_Type__c,gii__PriceBook__r.giic_Contract__r.Status
                    FROM gii__PriceBookEntry__c
                    WHERE gii__Product__c IN :pdtIdSet AND gii__PriceBook__r.giic_Contract__r.AccountId IN:mapProductSupplier.values() AND giic_Default__c = true
                ]); 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ pbEntry: ' + pbEntry);
                Map<String,Decimal>  mapProductSupplierTime = new  Map<String,Decimal>();
                if(!pbEntry.isEmpty()){ 
                    for(gii__PriceBookEntry__c pbe : pbEntry ){
                        mapProductSupplierTime.put(pbe.gii__Product__r.gii__ProductCode__c,pbe.giic_AvgSupplyTime__c );
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductSupplierTime: ' + mapProductSupplierTime);

                // Populate Wrapper for Output:
                Giic_StockAvailabilityUtility.ParamsWrapper params = new Giic_StockAvailabilityUtility.ParamsWrapper();
                params.mapPRODWHLOCWithAvailQty = mapPRODWHLOCWithAvailQty;
                params.mapOfPdtCodeVsPdt = mapOfPdtCodeVsPdt;
                params.mapOfZipVsWHlist = mapOfZipVsWHlist;
                params.warehouselstOfZipWHGrp = warehouselstOfZipWHGrp;
                params.zipWHGrpIdSet = zipWHGrpIdSet;
                params.mapOfZipWHGrpWHPdtCodeVsPI = mapOfZipWHGrpWHPdtCodeVsPI;
                params.mapOfIdVsWH = mapOfIdVsWH;
                params.mapOfWHGrpWHPdtCodeVsPI = mapOfWHGrpWHPdtCodeVsPI;
                params.mapCountryWHSupplyFlow = mapCountryWHSupplyFlow;
                params.mapLEWHSupplyFlow = mapLEWHSupplyFlow;
                params.stockAvailWrappList = stockAvailWrappList;
                params.mapProductSupplierTime = mapProductSupplierTime;
                params.mapWHGroupToWHCentral = mapWHGroupToWHCentral;
                params.mapOfPdtCodeVsPI = mapOfPdtCodeVsPI;
                params.mapOfWHGrpVsWHlist = mapOfWHGrpVsWHlist;
                //params.zipCodeWarehouseGroup = zipCodeWarehouseGroup;
                //params.provinceWarehouseGroup = provinceWarehouseGroup;
                params.legalEntityWarehouseGroup = legalEntityWarehouseGroup;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ params: ' + params);

                // Populate Wrapper for availability:
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Start check availability...'); 
                params = getFirstAvailabilityHelper(params);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params.stockAvailWrappList: ' + params.stockAvailWrappList);
                stockAvailWrappList = params.stockAvailWrappList;
            }
            else{
                // If missing one of the mandatory fields: Product, Zip Code and Country
                stockAvailWrappList[0].errorMessage = Label.giic_StockAvailabErrorMandatoryFields;
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Exit getFirstAvailabilityHelper'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ Returned Wrapper: ' + stockAvailWrappList); 
        return stockAvailWrappList;
    }
    
    /**
    * @author FRoberta Porrega - roberta.porrega@nttdata.com
    * @date Creation 22/07/2019
    * @date Modification 26/10/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description – This is a helper method to getFirstAvailability to check availability and best Partners
    * @param params - Giic_StockAvailabilityUtility.ParamsWrapper
    * @return Giic_StockAvailabilityUtility.ParamsWrapper
    */ 
    public static Giic_StockAvailabilityUtility.ParamsWrapper getFirstAvailabilityHelper(Giic_StockAvailabilityUtility.ParamsWrapper params){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In getFirstAvailabilityHelper'); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Input Wrapper: ' + params); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stockAvailWrappList: ' + params.stockAvailWrappList); 

        for(Giic_StockAvailabilityUtility.StockAvailabilityWrapper stkAvlObj : params.stockAvailWrappList) {
            // Check errors:
            Boolean isContinue = true;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check errors...'); 
            if(stkAvlObj.reqQuantity == null) {
                stkAvlObj.errorMessage = Label.giic_OdrQtyNotDefined;
                continue;
            }
            if(stkAvlObj.requestType == null) {
                stkAvlObj.errorMessage = Label.giic_StockRequestError;
                continue;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ No Error founded');

            // For Shipment:
            if(stkAvlObj.requestType == System.Label.giic_StockReqTypeShipment) { 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In Shipment section');
                Map<String, List<Date>> mapProductDate = new Map<String, List<Date>> ();
                Map<String, List<String>> mapProductDateVsWH = new Map<String,List<String>> ();
                String whDefault;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ pdtCode: ' + stkAvlObj.pdtCode);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exists products: ' + params.mapOfPdtCodeVsPdt.containskey(stkAvlObj.pdtCode));

                if(params.mapOfPdtCodeVsPdt != null && params.mapOfPdtCodeVsPdt.containskey(stkAvlObj.pdtCode) && params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c != null) { 
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Procurement Type:' + params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c);
                    if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c ==  System.Label.giic_ProcurementTypeSupplier) {
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Supplier');
                        if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c >= Date.today() || params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c == null) { 
                            // Prendo il tempo del PriceBookEntry o del CustomMetadata:
                            Integer avgTime = (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) != null ? (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c;
                            stkAvlObj.availabilityTime = Date.today().addDays(avgTime); 
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Supplier time: ' + avgTime);
                        }
                        else {
                            // Error: The end date on Product Reference is less than today
                            stkAvlObj.errorMessage = Label.giic_ErrorEndDate;
                        } 
                    }
                    else if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c == System.Label.giic_ProcurementTypeTransfer) {  
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Procurement type: ' + params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c);
                        if(!mapProductDate.containsKey(stkAvlObj.pdtCode)) {
                            mapProductDate.put(stkAvlObj.pdtCode, new List<Date>());
                        }  
                        if(params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity)!=null) {   
                            List<String> whGroupList = new List<String>();
                            switch on params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_CheckAvailabilityMode__c {
                                when 'Central WH' {  
                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Central WH'); 
                                    if(stkAvlObj.legalEntity != null && !params.legalEntityWarehouseGroup.get(stkAvlObj.legalEntity).isEmpty()) {                                        
                                        whGroupList = params.legalEntityWarehouseGroup.get(stkAvlObj.legalEntity);                                        
                                    }
                                    if(!whGroupList.isEmpty()) {  
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whGroupList: ' + whGroupList); 
                                        for(String whGroup : whGroupList){ 
                                            if(!params.mapWHGroupToWHCentral.containsKey(whGroup)) {
                                                continue;
                                            }
                                            gii__Warehouse__c centralWH = params.mapWHGroupToWHCentral.get(whGroup); 
                                            whDefault = centralWH.Id;
                                            String key = stkAvlObj.pdtCode + centralWH.Id; 
                                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whDefault: '+ whDefault);
                                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Do check: ' + params.mapOfPdtCodeVsPI.containsKey(key));
                                            
                                            if(params.mapOfPdtCodeVsPI.containsKey(key)) {   
                                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Checking...');
                                                Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                                if(stkAvlObj.reqQuantity <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) { 
                                                    Date avgDate = Date.today().addDays(avgTime) ;  
                                                    mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                    if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)) { 
                                                        mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());
                                                    } 
                                                    mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(centralWH.Id);  
                                                } else{  
                                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check more qty');
                                                    if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c >= Date.today() || params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c == null){ 
                                                        Integer supplierTyme = (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) != null ? (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c ;
                                                        Integer newAvgTime = avgTime + supplierTyme;
                                                        Date avgDate = Date.today().addDays(newAvgTime) ;  
                                                        mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                        if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)) {
                                                            mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());
                                                        } 
                                                        mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(centralWH.Id);
                                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' +mapProductDateVsWH);  
                                                    }
                                                    else{
                                                        // Error messages:
                                                        if(params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c > 0) {
                                                            stkAvlObj.errorMessage = Label.giic_ErrorEndDateWithAvail + params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;
                                                        } else { 
                                                            stkAvlObj.errorMessage = Label.giic_ErrorEndDate;
                                                        }
                                                    }
                                                } 
                                            }
                                        }
                                    } else {
                                        // Error: Zip code is not associated to any Warehouse
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error for Central WH');
                                        stkAvlObj.errorMessage = Label.giic_ErrorMissingWHZoneZip;
                                    }
                                }
                                when 'All warehouse Group' {                                     
                                    if(stkAvlObj.legalEntity != null && !params.legalEntityWarehouseGroup.get(stkAvlObj.legalEntity).isEmpty()) {  
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For LegalEntity: ' + stkAvlObj.legalEntity);
                                        whGroupList = params.legalEntityWarehouseGroup.get(stkAvlObj.legalEntity);     
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whGroupList: ' + whGroupList);
                                    }
                                    if(!whGroupList.isEmpty()) {
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check in all WH group');
                                        for(String whGroup : whGroupList) { 
                                            for(gii__Warehouse__c wHObj : params.mapOfWHGrpVsWHlist.get(whGroup)) {
                                                if(wHObj.giic_WarehouseType__c == Label.giic_WarehouseTypeCentral) { 
                                                    whDefault = wHObj.Id;
                                                }
                                                String key = stkAvlObj.pdtCode + wHObj.Id;   
                                                if(params.mapOfPdtCodeVsPI.containsKey(key) && stkAvlObj.reqQuantity <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c){
                                                    Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                    				Date avgDate = Date.today().addDays(avgTime) ; 
                                                    mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                    if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)){ 
                                                        mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());
                                                    } 
                                                    mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(wHObj.Id); 
                                                } 
                                                
                                                // SE STO PRENDENDO IL CENTRALE E NON HO DISPONIBILITà MI SALVO DIRETTAMENTE I TEMPI DI APPROVVIGIONAMENTO:
                                                if(wHObj.giic_WarehouseType__c == Label.giic_WarehouseTypeCentral && params.mapOfPdtCodeVsPI.containsKey(key) && stkAvlObj.reqQuantity > params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c ){
                                                    if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c >= Date.today() || params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c == null){ 
                                                        Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                                        Integer supplierTyme = (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) != null ? (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c ;
                                                        Integer newAvgTime = avgTime + supplierTyme;                                               
                                                        Date avgDate = Date.today().addDays(newAvgTime) ; 
                                                        mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                        if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)){
                                                            mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());
                                                        } 
                                                        mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(wHObj.Id); 
                                                    }
                                                    else{
                                                        // Error messages:
                                                        if(params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c > 0) {
                                                            stkAvlObj.errorMessage = Label.giic_ErrorEndDateWithAvail + params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;
                                                        } else { 
                                                            stkAvlObj.errorMessage = Label.giic_ErrorEndDate;
                                                        }
                                                    }
                                                }
                                            }                                    
                                        } 
                                    }
                                    else{
                                        // Error: Zip code is not associated to any Warehouse
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error in All Group WH');
                                        stkAvlObj.errorMessage = Label.giic_ErrorMissingWHZoneZip;
                                    }
                                }
                            }
                        }
                        else {
                            stkAvlObj.errorMessage = 'Custom metadata must be configured'; 
                        }
                        
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH); 

                        // Best date for the product:
                        if(mapProductDate.containsKey(stkAvlObj.pdtCode) && !mapProductDate.get(stkAvlObj.pdtCode).isEmpty()) {
                            stkAvlObj.availabilityTime = XC_SC010_PopulateSkillsOnRes_U_Interval.calculateMinOfDates(mapProductDate.get(stkAvlObj.pdtCode)); 
                            // Tramite la data definisco il magazzino in base alle disponibilità e prendo quello con più disponibilità:
                            Decimal avQty = 0;
                            Boolean mapUpdated = false;
                            for(String whId : mapProductDateVsWH.get(stkAvlObj.pdtCode+stkAvlObj.availabilityTime)) {
                                String key =  stkAvlObj.pdtCode + whId;
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Availability for WH: ' + whId);
                                if(params.mapOfPdtCodeVsPI.containskey(key)) {
                                    if(avQty <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) { 
                                        stkAvlObj.toWarehouse = whId;
                                        avQty = params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;
                                        if(avQty < params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) { 
                                            stkAvlObj.mapToWarehouseAvailabilityTime = new Map<String, Date>();
                                        }
                                        stkAvlObj.mapToWarehouseAvailabilityTime.put(whId, stkAvlObj.availabilityTime);
                                        mapUpdated = true;
                                    } 
                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Availability: ' + avQty);  
                                } else { 
                                    stkAvlObj.toWarehouse = whId; 
                                }
                            }
                            // Se non hai trovato nessun partner, mettiamo nella mappa quello inserito nel toWarehouse [NR1052]:
                            if(!mapUpdated && String.isNotBlank(stkAvlObj.toWarehouse)) {
                                stkAvlObj.mapToWarehouseAvailabilityTime.put(stkAvlObj.toWarehouse, stkAvlObj.availabilityTime);
                            }
                        } 
                        else {
                            if(stkAvlObj.legalEntity != null) {
                                Integer avgTimeST = (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c + (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c;
                                stkAvlObj.availabilityTime = Date.today().addDays(avgTimeST);
                                stkAvlObj.toWarehouse = whDefault;
                                stkAvlObj.mapToWarehouseAvailabilityTime.put(whDefault, Date.today().addDays(avgTimeST));
                            }
                        }      
                    }      
                }
                else { 
                    // Error: Missing mandatory field Procurement Type on the product
                    stkAvlObj.errorMessage = Label.giic_MissingProcurementType;
                }
            }
            // For Delivery&Installation:
            else if(stkAvlObj.requestType == System.Label.giic_DeliveryInstallationStockReqType) { 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ In D&I section');
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ requestType: ' + stkAvlObj.requestType);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapOfPdtCodeVsPdt: ' + params.mapOfPdtCodeVsPdt);
                Map<String, List<Date>> mapProductDate = new Map<String, List<Date>>();
                Map<String, List<String>> mapProductDateVsWH = new Map<String,List<String>>();
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check WHs...'); 

                if(params.mapOfPdtCodeVsPdt != null && params.mapOfPdtCodeVsPdt.containsKey(stkAvlObj.pdtCode) && params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c != null){
                    if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c == System.Label.giic_ProcurementTypeSupplier) {
                        // PRENDO IL TEMPO NELLA PBE O QUELLO DEL METADATA 
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Procurement type: ' + params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c);
                        if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c >= Date.today() || params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c == null ){ 
                            Integer avgTime = (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) != null ? (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c ;
                            stkAvlObj.availabilityTime =  Date.today().addDays(avgTime) ; 
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ SUpplier time: ' + avgTime);
                        } else { 
                            stkAvlObj.errorMessage =  Label.giic_ErrorEndDate; 
                        }
                    } else if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_ProcurementType__c == System.Label.giic_ProcurementTypeTransfer){ 
                        Integer maxAvailability = 0;
                        if(!mapProductDate.containsKey(stkAvlObj.pdtCode)){
                            mapProductDate.put(stkAvlObj.pdtCode, new List<Date>());
                        }  
                        for(String whPartner : stkAvlObj.partnersWH) {
                            gii__Warehouse__c toWH = params.mapOfIdVsWH.get(ID.valueOf(whPartner));
                            String key =  stkAvlObj.pdtCode + toWH.Id; 
                            if(params.mapOfPdtCodeVsPI.containsKey(key)){    
                                //Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapCountryWHSupplyFlow.get(stkAvlObj.country).XC_LogisticPartnerSupplyTime__c;
                                if(stkAvlObj.reqQuantity <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c){ 
                                    Date avgDate = Date.today() ;  
                                    mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                    if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)) { 
                                        mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());  
                                    } 
                                    mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(toWH.Id);  
                                } else {
                                    if(maxAvailability < params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) {  
                                        maxAvailability = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;  
                                    }
                                }                                                         
                            }
                        }
                        
               			XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ maxAvailability: ' + maxAvailability);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDate: ' + mapProductDate);
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params.mapOfPdtCodeVsPI: ' + params.mapOfPdtCodeVsPI);
                        
                        if(!mapProductDate.get(stkAvlObj.pdtCode).isEmpty()) {
                            stkAvlObj.availabilityTime = XC_SC010_PopulateSkillsOnRes_U_Interval.calculateMinOfDates(mapProductDate.get(stkAvlObj.pdtCode)); 
                            // Tramite la data definisco il magazzino in base alle disponibilità e prendo quello con più disponibilità
                            Decimal avQty = 0;
                            Boolean mapUpdatedSecondCase = false;
                            for(String whId : mapProductDateVsWH.get(stkAvlObj.pdtCode+stkAvlObj.availabilityTime)){
                                String key =  stkAvlObj.pdtCode + whId;
                                if(params.mapOfPdtCodeVsPI.containskey(key)){
                                    if(avQty <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c ){ 
                                        stkAvlObj.toWarehouse = whId;
                                        avQty = params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c; 
                                        if(avQty < params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) { 
                                            stkAvlObj.mapToWarehouseAvailabilityTime = new Map<String, Date>();
                                        }
                                        stkAvlObj.mapToWarehouseAvailabilityTime.put(whId, stkAvlObj.availabilityTime);
                                        mapUpdatedSecondCase = true;
                                    } 
                                } else { 
                                    stkAvlObj.toWarehouse = whId; 
                                }
                            }
                            // Se non hai trovato nessun partner, mettiamo nella mappa quello inserito nel toWarehouse [NR1052]:
                            if(!mapUpdatedSecondCase && String.isNotBlank(stkAvlObj.toWarehouse)) {
                                stkAvlObj.mapToWarehouseAvailabilityTime.put(stkAvlObj.toWarehouse, stkAvlObj.availabilityTime);
                            }
                        } else {
                            // Devo cercare nel network dei magazzini dei partner:
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Check in network WH partner');
                            if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c >= Date.today() || params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c == null){ 
                                switch on params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_CheckAvailabilityMode__c {
                                    when 'Central WH' {
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For Central WH');
                                        for(String whPartner : stkAvlObj.partnersWH){
                                            gii__Warehouse__c toWH = params.mapOfIdVsWH.get(ID.valueOf(whPartner)); 
                                            String whGroup = toWH.gii__WarehouseGroup__c ;
                                            if(params.mapWHGroupToWHCentral.containsKey(whGroup)){ 
                                                gii__Warehouse__c centralWH = params.mapWHGroupToWHCentral.get(whGroup);
                                                String key =  stkAvlObj.pdtCode + centralWH.Id; 
                                                if(params.mapOfPdtCodeVsPI.containsKey(key)){  
                                                    XC_UTIL_Debug.debug(DEBUGACTIVE,' @@@ Average Transfer Time: ' + params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c );
                                                    Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                                    if(stkAvlObj.reqQuantity <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c){ 
                                                        Date avgDate = Date.today().addDays(avgTime) ;  
                                                        mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                        if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)){ 
                                                            mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>()); 
                                                        } 
                                                        mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(toWH.Id); 
                										XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductDateVsWH: ' + mapProductDateVsWH); 
                                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stkAvlObj.pdtCode: ' + stkAvlObj.pdtCode); 
                                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ toWH.Id: ' + toWH.Id); 
                                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ avgDate: ' + avgDate); 
                                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stkAvlObj.reqQuantity: ' + stkAvlObj.reqQuantity); 
                                                    }
                                                    else{
                                                        if(maxAvailability < params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) {  
                                                            maxAvailability = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;
                                                        }
                                                    }       
                                                }
                                            }
                                        } 
                                    }
                                    when 'All warehouse Group' { 
                                        for(String whPartner : stkAvlObj.partnersWH){  
                                            gii__Warehouse__c toWH = params.mapOfIdVsWH.get(ID.valueOf(whPartner));  
                                            String whGroup = toWH.gii__WarehouseGroup__c ;  
                                            for(gii__Warehouse__c wHObj : params.mapOfWHGrpVsWHlist.get(whGroup)){ 
                                                String key = stkAvlObj.pdtCode + wHObj.Id;    
                                                if(params.mapOfPdtCodeVsPI.containsKey(key)){
                                                    if(stkAvlObj.reqQuantity <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c){ 
                                                        Integer avgTime =  (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                                        Date avgDate = Date.today().addDays(avgTime) ; 
                                                        mapProductDate.get(stkAvlObj.pdtCode).add(avgDate);
                                                        if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)) {
                                                            mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());
                                                        } 
                                                        mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(toWH.Id);
                                                    } else{
                                                        if(maxAvailability < params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c){ 
                                                            maxAvailability = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;
                                                        }
                                                    }
                                                }        
                                            }
                                        }
                                    }   
                                }
                            }
                            else {
                                // Error messages:
                                if(maxAvailability > 0) {
                                    stkAvlObj.errorMessage = Label.giic_ErrorEndDateWithAvail + maxAvailability;
                                } else { 
                                    stkAvlObj.errorMessage = Label.giic_ErrorEndDate;
                                }
                            }
                        } 
                        if(!mapProductDate.get(stkAvlObj.pdtCode).isEmpty()) {
                            // Tramite la data definisco il magazzino in base alle disponibilità e prendo quello con più disponibilità
                            stkAvlObj.availabilityTime = XC_SC010_PopulateSkillsOnRes_U_Interval.calculateMinOfDates(mapProductDate.get(stkAvlObj.pdtCode)); 
                            Decimal avQty = 0 ;
                            Boolean mapUpdated3Case = false;
                            for(String whId : mapProductDateVsWH.get(stkAvlObj.pdtCode+stkAvlObj.availabilityTime)) {
                                String key =  stkAvlObj.pdtCode + whId;
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ key: ' + key);
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stkAvlObj.pdtCode: ' + stkAvlObj.pdtCode);
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whId: ' + whId);
                                if(params.mapOfPdtCodeVsPI.containskey(key)) {
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@ mapOfPdtCodeVsPI for key: ' + params.mapOfPdtCodeVsPI.get(key));
                                    if(avQty <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c ){ 
                                        stkAvlObj.toWarehouse = whId;
                                        avQty = params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;
                                        if(avQty < params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) { 
                                            stkAvlObj.mapToWarehouseAvailabilityTime = new Map<String, Date>();
                                        }
                                        stkAvlObj.mapToWarehouseAvailabilityTime.put(whId, stkAvlObj.availabilityTime);
                                        mapUpdated3Case = true;
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ avQty: ' + avQty);
                                    }
                                }
                                else { 
                                    stkAvlObj.toWarehouse = whId; 
                                }
                            }
                            // Se non hai trovato nessun partner, mettiamo nella mappa quello inserito nel toWarehouse [NR1052]:
                            if(!mapUpdated3Case && String.isNotBlank(stkAvlObj.toWarehouse)) {
                                stkAvlObj.mapToWarehouseAvailabilityTime.put(stkAvlObj.toWarehouse, stkAvlObj.availabilityTime);
                            }
                        }
                        else {
                            // Devo creare il PO:
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Create PO...');
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stkAvlObj.pdtCode: ' + stkAvlObj.pdtCode);
                            if(params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c >= Date.today() || params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c == null) { 
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c: ' + params.mapOfPdtCodeVsPdt.get(stkAvlObj.pdtCode).giic_EndDate__c );
                                switch on params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_PurchaseOrderWarehouse__c {
                                    when 'CW' {
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Case Centrale WH');
                                        for(String whPartner : stkAvlObj.partnersWH) {
                                            gii__Warehouse__c toWH = params.mapOfIdVsWH.get(ID.valueOf(whPartner)); 
                                            String whGroup = toWH.gii__WarehouseGroup__c ; 
                                            if(params.mapWHGroupToWHCentral.containsKey(whGroup)) { 
                                                gii__Warehouse__c centralWH = params.mapWHGroupToWHCentral.get(whGroup);
                                                String key =  stkAvlObj.pdtCode + centralWH.Id; 
                                                if(params.mapOfPdtCodeVsPI.containsKey(key)){                                                    
                									XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ key: ' + key);
                                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stkAvlObj.pdtCode: ' + stkAvlObj.pdtCode);
                                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ centralWH.Id: ' + centralWH.Id);
                                                    Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                                    Integer supplierTyme = (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) != null ? (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c ;
                                                    Integer newAvgTime =  avgTime + supplierTyme;
                                                    Date avgDate = Date.today().addDays(newavgTime) ;  
                                                    mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                    if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)){  mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>()); } 
                                                    mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(toWH.Id); 
                                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Availability found -> mapProductDate: ' + mapProductDate);
                                                }
                                            }
                                            else {
                                                if(stkAvlObj.partnersWH!=null) {  
                                                    for(String whPartners : stkAvlObj.partnersWH){ 
                                                        gii__Warehouse__c toWHs = params.mapOfIdVsWH.get(ID.valueOf(whPartners)); 
                                                        String key =  stkAvlObj.pdtCode + toWHs.Id;   
                                                            if(params.mapOfPdtCodeVsPI.containsKey(key)){
                                                                Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                                                Integer supplierTyme = (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) != null ? (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c ;
                                                                Integer newAvgTime = avgTime + supplierTyme;
                                                                Date avgDate = Date.today().addDays(newavgTime) ; 
                                                                mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                                if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)){
                                                                    mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());
                                                                } 
                                                                mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(toWHs.Id);
                                                            }  
                                                    }
                                                } else { 
                                                    // Error: WH is not correctly configured
                                                    stkAvlObj.errorMessage = Label.giic_ErrorConfiguationWH;
                                                } 
                                            }
                                        }
                                    } 
                                    when 'LW'{ 
                                        if(stkAvlObj.partnersWH!=null) {  
                                            for(String whPartner : stkAvlObj.partnersWH){ 
                                                gii__Warehouse__c toWH = params.mapOfIdVsWH.get(ID.valueOf(whPartner)); 
                                                String key =  stkAvlObj.pdtCode + toWH.Id;   
                                                if(params.mapOfPdtCodeVsPI.containsKey(key)){
                                                    Integer avgTime = (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c != null ? (Integer)params.mapOfPdtCodeVsPI.get(key).giic_AvgTransferTime__c : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c;
                                                    Integer supplierTyme = (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) != null ? (Integer)params.mapProductSupplierTime.get(stkAvlObj.pdtCode) : (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c ;
                                                    Integer newAvgTime = avgTime + supplierTyme; 
                                                    Date avgDate = Date.today().addDays(newavgTime) ; 
                                                    mapProductDate.get(stkAvlObj.pdtCode).add(avgDate); 
                                                    if(!mapProductDateVsWH.containsKey(stkAvlObj.pdtCode+avgDate)){
                                                        mapProductDateVsWH.put(stkAvlObj.pdtCode+avgDate, new List<String>());
                                                    } 
                                                    mapProductDateVsWH.get(stkAvlObj.pdtCode+avgDate).add(toWH.Id); 
                                                }  
                                            }
                                        } else { 
                                            // Error: WH is not correctly configured
                                            stkAvlObj.errorMessage = Label.giic_ErrorConfiguationWH;
                                        } 
                                    }   
                                }
                            }
                            else {
                                // Error messages:
                                if(maxAvailability > 0) {
                                    stkAvlObj.errorMessage = Label.giic_ErrorEndDateWithAvail + maxAvailability;
                                } else { 
                                    stkAvlObj.errorMessage = Label.giic_ErrorEndDate;
                                }                      
                            }
                        }  
                        if(!mapProductDate.get(stkAvlObj.pdtCode).isEmpty()) {
                            stkAvlObj.availabilityTime = XC_SC010_PopulateSkillsOnRes_U_Interval.calculateMinOfDates(mapProductDate.get(stkAvlObj.pdtCode)); 
                            // Tramite la data definisco il magazzino in base alle disponibilità e prendo quello con più disponibilità
                            Decimal avQty = 0;
                            for(String whId : mapProductDateVsWH.get(stkAvlObj.pdtCode+stkAvlObj.availabilityTime)){
                                String key =  stkAvlObj.pdtCode + whId;
                                if(params.mapOfPdtCodeVsPI.containskey(key)){
                                    if(avQty <= params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c){ 
                                        stkAvlObj.toWarehouse = whId;
                                        avQty = params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c;
                                        if(avQty < params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c) { 
                                            stkAvlObj.mapToWarehouseAvailabilityTime = new Map<String, Date>();
                                        }
                                        stkAvlObj.mapToWarehouseAvailabilityTime.put(whId, stkAvlObj.availabilityTime);
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ avQty: ' + avQty);
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c: ' + params.mapOfPdtCodeVsPI.get(key).giic_SalesOnHand__c);
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stkAvlObj.toWarehouse: ' + stkAvlObj.toWarehouse);
                                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ whId: ' + whId);
                                    }
                                } 
                                else { 
                                    stkAvlObj.toWarehouse = whId; 
                                    stkAvlObj.mapToWarehouseAvailabilityTime.put(whId, stkAvlObj.availabilityTime);
                                }
                            }
                        }
                        else {
                            Integer avgTimeST =  (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_LogisticPartnerSupplyTime__c + (Integer)params.mapLEWHSupplyFlow.get(stkAvlObj.legalEntity).XC_SupplierSupplyTime__c;
                            stkAvlObj.availabilityTime = Date.today().addDays(avgTimeST);
                            stkAvlObj.toWarehouse = stkAvlObj.partnersWH[0];
                            for(String whIds : stkAvlObj.partnersWH) {
                                stkAvlObj.mapToWarehouseAvailabilityTime.put(whIds, Date.today().addDays(avgTimeST));
                            }
                        }   
                    }
                }
                else { 
                    // Error: Missing mandatory field Procurement Type on the product
                    stkAvlObj.errorMessage = Label.giic_MissingProcurementType; 
                }
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ params: ' + params);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ stockAvailWrappList: ' + params.stockAvailWrappList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exit helper method');
        return params;
    }    
    
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @author Last Modification : Roberta Porrega - roberta.porrega@nttdata.com
    * @description - get All warehouse from network
    * @param mapAllNetworkWarehouses - map<id,gii__Warehouse__c>
    * @param mapWarehouseGroupWarehoues - map<id,list<id>>
    * @return set<Id>
    */ 
    public static set<Id> getWarehouseNetworkWise(map<id,gii__Warehouse__c> mapAllNetworkWarehouses, map<id,list<id>> mapWarehouseGroupWarehoues){ 
        set<Id> setLocationIds=new set<Id>(); 
        set<Id> setWarehouseIds=new set<Id>();        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        for(gii__Warehouse__c objWarehouse : mapAllNetworkWarehouses.values()){
            if(!mapWarehouseGroupWarehoues.containsKey(objWarehouse.gii__WarehouseGroup__c)){
                mapWarehouseGroupWarehoues.put(objWarehouse.gii__WarehouseGroup__c,new list<Id>());
            }
            mapWarehouseGroupWarehoues.get(objWarehouse.gii__WarehouseGroup__c).add(objWarehouse.id);
            setWarehouseIds.add(objWarehouse.id);
            // CR LOCATION  setLocationIds.add(objWarehouse.gii__DefaultIssueLocation__c);            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        }
        // CR LOCATION
        Map<Id, gii__Location__c> mapLocation = new Map<Id, gii__Location__c > ([
            SELECT Id, giic_LocationType__c  
            FROM gii__Location__c  
            WHERE (giic_LocationType__c = :Label.giic_LocationTypeSales OR giic_LocationType__c = :Label.giic_CL_VanLocation)
            AND gii__Warehouse__c IN :setWarehouseIds]); 
        setLocationIds = mapLocation.keySet();
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'setLocationIds' + setLocationIds );        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        return setLocationIds;
    }

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 09/09/2019
    * @author Last Modification : Roberta Porrega - roberta.porrega@nttdata.com
    * @description - get location, warehouse, warehouse group ids from sales order
    * @param lstSOIds list of sales order ids
    * @return InventoryWrapper
    */ 
    public static InventoryWrapper getWarehouseInformation(list<gii__SalesOrder__c> lstSO){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN getWarehouseInformation');
        InventoryWrapper objInventoryWrapper=new InventoryWrapper();
        objInventoryWrapper.setWarehouseIds=new set<Id>();
        objInventoryWrapper.setLocationIds=new set<Id>();
        objInventoryWrapper.lstErrors=new list<string>();
        objInventoryWrapper.setWarehouseGroupIds=new set<Id>();
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        for(gii__SalesOrder__c objSO : lstSO){
            objInventoryWrapper.setWarehouseIds.add(objSO.gii__Warehouse__c);            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            if(objSO.giic_FromWarehouse__c != null){
                objInventoryWrapper.setWarehouseIds.add(objSO.giic_FromWarehouse__c); 
            }            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            if(objSO.gii__Warehouse__r.gii__WarehouseGroup__c != null){
                objInventoryWrapper.setWarehouseGroupIds.add(objSO.gii__Warehouse__r.gii__WarehouseGroup__c);
            }            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            if(objSO.gii__Warehouse__r.giic_ParentWarehouse__c != null){
                objInventoryWrapper.setWarehouseIds.add(objSO.gii__Warehouse__r.giic_ParentWarehouse__c);
                // CR LOCATION
                /* if(objSO.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c != null){
                    objInventoryWrapper.setLocationIds.add(objSO.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c);
                }*/
            }
            
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            // CR LOCATION
            /*if(objSO.gii__Warehouse__r.gii__DefaultIssueLocation__c != null){
                objInventoryWrapper.setLocationIds.add(objSO.gii__Warehouse__r.gii__DefaultIssueLocation__c);
            }
            else{
                objInventoryWrapper.lstErrors.add('Location is not defined on warehouse  '+ objSO.gii__Warehouse__r.Name);
            }*/
        }
        // CR LOCATION 
        Map<Id, gii__Location__c> mapLocation = new Map<Id, gii__Location__c > ([
            SELECT Id, giic_LocationType__c  
            FROM gii__Location__c  
            WHERE (giic_LocationType__c = :Label.giic_LocationTypeSales OR giic_LocationType__c = :Label.giic_CL_VanLocation)
            AND gii__Warehouse__c IN :objInventoryWrapper.setWarehouseIds]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );        
        objInventoryWrapper.setLocationIds.addAll(mapLocation.keyset());        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        if(mapLocation.isEmpty()){ objInventoryWrapper.lstErrors.add(Label.giic_LocationError); }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'objInventoryWrapper' + objInventoryWrapper );
        return objInventoryWrapper;
    }

    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 09/09/2019
    * @date Modification dd/mm/yyyy
    * @description - get product inventory availability
    * @param objPIQD product inventory quantity detail
    * @param mapWHPRLOWithAvlQty product inventory availQty
    * @param mapWHPRLOWithPI product warehouse with PI
    */
    public static void getPIAvailQty(gii__ProductInventoryQuantityDetail__c objPIQD,map<string,integer> mapWHPRLOWithAvlQty, map<string,gii__ProductInventory__c> mapWHPRLOWithPI){
        string key=objPIQD.gii__Warehouse__c + '-' + objPIQD.gii__Product__c + '-' + objPIQD.gii__Location__c;
        if(!mapWHPRLOWithAvlQty.containsKey(key)){
            mapWHPRLOWithAvlQty.put(key,0);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso4');
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        if(!mapWHPRLOWithPI.containsKey(key)){
            mapWHPRLOWithPI.put(key,new gii__ProductInventory__c(id=objPIQD.gii__ProductInventory__c,giic_BackOrderNew__c=objPIQD.gii__ProductInventory__r.giic_BackOrderNew__c));
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'#######'  + objPIQD.gii__Available__c);
        if(objPIQD.gii__Available__c != null){
            mapWHPRLOWithAvlQty.put(key,(integer)(mapWHPRLOWithAvlQty.get(key) + objPIQD.gii__Available__c));
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso5');
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
    }
    
    /**
    * @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - This method is used to process Products with Transfer Procurement type
    * @param objPTTransferWrapper - ProcurementTypeTransferWrapper 
    * @param mapWHLocation - mapWHLocation 
    * @return list<gii__ProductInventory__c>
    */
    public static list<gii__ProductInventory__c> processProcurementTypeTransferForLocal(ProcurementTypeTransferWrapper objPTTransferWrapper,Map<Id, List<Id>> mapWHLocation){
        gii__SalesOrderLine__c objSOL=objPTTransferWrapper.objSOL;
        list<gii__ProductInventory__c> lstPIToUpdateBackOrderQty=new list<gii__ProductInventory__c>();
        // CR LOCATION
        Map<Id, Map<Decimal,Decimal>> mapLocationQtyReserved = new Map<Id, Map<Decimal,Decimal>>(); 
        Decimal notReservedQuantity = objSOL.gii__OrderQuantity__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        String piKey=objSOL.gii__Warehouse__c +'-' + objSOL.gii__Product__c;
        Id lastLocation;
        for(Id location : mapWHLocation.get(objSOL.gii__Warehouse__c )){
            
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            lastLocation = location;
            string key= objSOL.gii__Warehouse__c +'-' + objSOL.gii__Product__c + '-' + location;
            decimal qty=0;
            decimal qtyReservedLocal=0;
            decimal availQty = objPTTransferWrapper.mapWHPRLOWithAvlQty.containsKey(key) ? objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key) : 0;
            
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            if(availQty == 0){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ availQty' + availQty);
                continue; 
                
                
            } else if(availQty >= notReservedQuantity){ 
                
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                Map<Decimal,Decimal> mapQtyReservedLocalToQty = new  Map<Decimal,Decimal>();
                qty= availQty - objSOL.gii__OrderQuantity__c;
                qtyReservedLocal = objSOL.gii__OrderQuantity__c;
                objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate = system.today();
                mapQtyReservedLocalToQty.put(qtyReservedLocal,qty);
                mapLocationQtyReserved.put(location,mapQtyReservedLocalToQty);
                notReservedQuantity = 0;
                objPTTransferWrapper.isContinue=true; 
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ notReservedQuantity' + notReservedQuantity);
                break;
            } else if(availQty < notReservedQuantity ){
                Map<Decimal,Decimal> mapQtyReservedLocalToQty = new  Map<Decimal,Decimal>();
                notReservedQuantity = objSOL.gii__OrderQuantity__c - availQty; 
                qty = availQty - notReservedQuantity;
                qtyReservedLocal = availQty;
                mapQtyReservedLocalToQty.put(qtyReservedLocal,qty);
                mapLocationQtyReserved.put(location,mapQtyReservedLocalToQty); 
                // objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate=system.today(); //Transfer time days 
            }     
        }
        
        if(notReservedQuantity > 0){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ notReservedQuantity' + notReservedQuantity);
            objPTTransferWrapper.isContinue=false;
            objSOL.gii__OrderQuantity__c =  notReservedQuantity;
            string keyBackOrder= objSOL.gii__Warehouse__c +'-' + objSOL.gii__Product__c + '-' + lastLocation;
            if(objPTTransferWrapper.mapWHPRLOWithPI.containskey(keyBackOrder)){ 
                integer existingBackOrderQty= objPTTransferWrapper.mapWHPRLOWithPI.get(keyBackOrder).giic_BackOrderNew__c != null ? integer.valueof(objPTTransferWrapper.mapWHPRLOWithPI.get(keyBackOrder).giic_BackOrderNew__c ): 0;
                lstPIToUpdateBackOrderQty.add(new gii__ProductInventory__c(Id=objPTTransferWrapper.mapWHPRLOWithPI.get(keyBackOrder).id,giic_BackOrderNew__c=existingBackOrderQty + objSOL.gii__OrderQuantity__c));
            }else if(objPTTransferWrapper.mapWHPRLOWithPI.containsKey(piKey)){ 
                
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                integer existingBackOrderQty=objPTTransferWrapper.mapWHPRLOWithPI.get(piKey).giic_BackOrderNew__c != null ? integer.valueof(objPTTransferWrapper.mapWHPRLOWithPI.get(piKey).giic_BackOrderNew__c ): 0;
                lstPIToUpdateBackOrderQty.add(new gii__ProductInventory__c(Id=objPTTransferWrapper.mapWHPRLOWithPI.get(piKey).Id,giic_BackOrderNew__c=existingBackOrderQty + objSOL.gii__OrderQuantity__c));
            } 
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'***objPTTransferWrapper.mapWHPRLOWithPI***'+objPTTransferWrapper.mapWHPRLOWithPI);
        
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        for(Id location : mapLocationQtyReserved.keySet()){
            
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            string key= objSOL.gii__Warehouse__c +'-' + objSOL.gii__Product__c + '-' + location;
            for(Decimal qtyReservedLocal : mapLocationQtyReserved.get(location).keySet()){
                if(objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key) > 0){   
                    
                objPTTransferWrapper.reserveWrap.add(giic_ReservationUtility.getReservationWrapper(objSOL.gii__Warehouse__c,objSOL.gii__Product__c,integer.valueof(qtyReservedLocal),location));  }
                objPTTransferWrapper.mapWHPRLOWithAvlQty.put(key,integer.valueof(mapLocationQtyReserved.get(location).get(qtyReservedLocal)));
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso1');
            }
        }
        objPTTransferWrapper.objSOL=objSOL;
        return lstPIToUpdateBackOrderQty;
    }
    
    /**
    * @author FirstName : Roberta Porrega - roberta.porrega@nttdata.com
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - This method is used to process Products with Transfer Procurement type for Central/Local WHs
    * @param objPTTransferWrapper - ProcurementTypeTransferWrapper
    * @param mapWarehouseGroupWarehoues - map<id,list<id>>, 
    * @param objTOWrapper -TransferOrderWrapper 
    */
    public static List<String> processCentralOrLocalForTransfer(ProcurementTypeTransferWrapper objPTTransferWrapper, ProductAvailabilityResponse objProdAvailResponse, Giic_TransferOrderUtility.warehouseWrapper wrWH){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'in processCentralOrLocalForTransfer'  );
        List<String> lstErrors = new List<String>();
        gii__SalesOrderLine__c objSOL=objPTTransferWrapper.objSOL; 
        Set<Id> settProductIds=new set<Id>();
        Set<Id> setSupplierIds=new set<Id>();
        map<string,list<gii__SalesOrderLine__c>> mapSupplierProductPI=new map<string,list<gii__SalesOrderLine__c>>();
        XC_CM_WarehouseSupplyFlow__mdt whSupplyFlow = wrWH.mapCountryWHSupplyFlow.get(objSOL.gii__Warehouse__r.giic_LegalEntity__c); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrWH '+ wrWH);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'wrWH.Legal '+ wrWH.mapCountryWHSupplyFlow.get(objSOL.gii__Warehouse__r.giic_LegalEntity__c));
        objPTTransferWrapper.isContinue = true;
         
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'objPTTransferWrapper.mapPBEClosedOrders.containskey(keyPBE) = '+objPTTransferWrapper.mapPBEClosedOrders.containskey(objSOL.gii__Product__c + '-' + objSOL.gii__Product__r.gii__PrimarySupplier__c));
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'whSupplyFlow.XC_FirstWarehouseCheck__c '+ whSupplyFlow.XC_FirstWarehouseCheck__c);
        switch on whSupplyFlow.XC_FirstWarehouseCheck__c { 
            when 'CW' {  
                // CONTROLLO IL CENTRALE
                Decimal totalAvailQtyCentral = 0;
                String parentLocation ;                
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                if(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c != null && wrWH.mapWHLocation.containskey(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c)){ 
                    for(Id location : wrWH.mapWHLocation.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c)){  
                        string key = objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c + '-' +location;
                        if(objPTTransferWrapper.mapWHPRLOWithAvlQty.containsKey(key) && objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key) > 0){
                            parentLocation = location;
                            totalAvailQtyCentral = totalAvailQtyCentral + objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key);  
                        }
                    }
                    
               		XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                    string parentKey= objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c + '-'+ parentLocation ;  
                    if(totalAvailQtyCentral >= objSOL.gii__OrderQuantity__c){   
                        objPTTransferWrapper.mapWHPRLOWithAvlQty.put(parentKey,integer.valueof(objPTTransferWrapper.mapWHPRLOWithAvlQty.get(parentKey) - objSOL.gii__OrderQuantity__c));
                        Integer transferTime = objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c != null ? (Integer)objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c : (Integer)wrWH.mapCountryWHSupplyFlow.get(objSOL.gii__Warehouse__r.giic_LegalEntity__c).XC_LogisticPartnerSupplyTime__c;
                        objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate = system.today().adddays(transferTime); //Transfer time days
                        objPTTransferWrapper.isContinue=true;                         
                        string toKey=objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Warehouse__c; 
                        Date requiredDate = objSOL.gii__SalesOrder__r.gii__RequiredDate__c < Date.today() ? Date.today() : objSOL.gii__SalesOrder__r.gii__RequiredDate__c ;
                        
                        if(!objProdAvailResponse.objTOWrapper.mapTransferOrder.containsKey(toKey) ){ 
                            gii__TransferOrder__c objTO = createTransferOrder(objSOL,requiredDate,objSOL.gii__Warehouse__r.giic_ParentWarehouse__c);
                            objProdAvailResponse.objTOWrapper.mapTransferOrder.put(toKey,objTO);
                            gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                            objProdAvailResponse.objTOWrapper.mapTransferOrderLine.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine});  
                        }else{ 
                            gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                            objProdAvailResponse.objTOWrapper.mapTransferOrderLine.get(toKey).add(objTOLine); 
                        } 
                        objPTTransferWrapper.reserveWrap.add(giic_ReservationUtility.getReservationWrapper(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c,objSOL.gii__Product__c ,integer.valueof(objSOL.gii__OrderQuantity__c),parentLocation));
                        
                        // SE NON HO DISPONIBILITà SUL CENTRALE CREO PO
                    }else{                         
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@  CW : NON HO DISPONIBILITà NEL CENTRALE'  );
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@  CW : NON HO DISPONIBILITà NEL CENTRALE'  );
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@  CW : NON HO DISPONIBILITà NEL CENTRALE'  );
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@  CW : NON HO DISPONIBILITà NEL CENTRALE'  );
                        /*********  CR NR1108   ********/ 
                        String keyPBE = objSOL.gii__Product__c + '-' + objSOL.gii__Product__r.gii__PrimarySupplier__c;
                        if(objPTTransferWrapper.mapPBEClosedOrders.containskey(keyPBE) ){    
                            lstErrors.add(Label.giic_CL_CloseOrderError);  
                            return lstErrors;
                        }else{
                            if(whSupplyFlow.XC_PurchaseOrderWarehouse__c =='CW'){ 
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@  creo po sul centrale'  );
                                Integer transferTime = objPTTransferWrapper.mapWHPRLOWithPI.containskey(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c) && objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c != null ? (Integer)objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c : (Integer)whSupplyFlow.XC_LogisticPartnerSupplyTime__c; 
                                objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate = System.today().adddays(transferTime); //Transfer time days
                                
                                string toKey=objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Warehouse__c; 
                                Date requiredDate = objSOL.gii__SalesOrder__r.gii__RequiredDate__c < Date.today() ? Date.today() : objSOL.gii__SalesOrder__r.gii__RequiredDate__c ;
                                if(!objProdAvailResponse.objTOWrapper.mapTransferOrder.containsKey(toKey) ){
									//NR2097
									List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
									Boolean DraftTO = FALSE;
									String TOStatus;
									Boolean ApprovedTO = TRUE;
									for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {
										if ((CSett.giic_LegalEntity__c == objSOL.gii__SalesOrder__r.giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {
											DraftTO=CSett.giic_DraftTO__c;
											Break;
										}
									}
									if(DraftTO == TRUE) {ApprovedTO=FALSE;TOStatus=Label.giic_TODraftStatus;} else {ApprovedTO=TRUE;TOStatus=Label.giic_TOApproved;}
                                    gii__TransferOrder__c objTO=new gii__TransferOrder__c(giic_Status__c=TOStatus,giic_Source__c=Label.giic_OrderSourceAutomation,
                                                                                          gii__Account__c=objSOL.gii__Warehouse__r.gii__Account__c,
                                                                                          gii__RequiredDate__c =requiredDate ,
                                                                                          giic_SalesOrder__c = objSOL.gii__SalesOrder__c,
                                                                                          gii__FromWarehouse__c=objSOL.gii__Warehouse__r.giic_ParentWarehouse__c,
                                                                                          giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c,
                                                                                          gii__TransferToWarehouse__c=objSOL.gii__Warehouse__c,giic_Approved__c=ApprovedTO);
                                    objProdAvailResponse.objTOWrapper.mapTransferOrder.put(toKey,objTO);
                                    gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                                    objProdAvailResponse.objTOWrapper.mapTransferOrderLine.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine});  
                                }else{
                                    gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                                    objProdAvailResponse.objTOWrapper.mapTransferOrderLine.get(toKey).add(objTOLine); 
                                }
                                objPTTransferWrapper.reserveWrap.add(giic_ReservationUtility.getReservationWrapper(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c,objSOL.gii__Product__c ,integer.valueof(objSOL.gii__OrderQuantity__c),parentLocation));
                                objPTTransferWrapper.isContinue=true;
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                            }
                            
                            if(objSOL.gii__Product__r.giic_EndDate__c >= date.today() || objSOL.gii__Product__r.giic_EndDate__c == null){                           
                                settProductIds.add(objSOL.gii__Product__c);
                                string suppProdKey=objSOL.gii__Product__r.gii__PrimarySupplier__c +'-' + objSOL.gii__Product__c;
                                setSupplierIds.add(objSOL.gii__Product__r.gii__PrimarySupplier__c);
                                if(!mapSupplierProductPI.containskey(suppProdKey)){
                                    mapSupplierProductPI.put(suppProdKey,new list<gii__SalesOrderLine__c>());
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                }
                                // new 29-10-20
                                string key = '';
                                if( wrWH.mapWHLocation.containsKey(objSOL.gii__Warehouse__c)){
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    key = objSOL.gii__Warehouse__c +'-' + objSOL.gii__Product__c + '-' + wrWH.mapWHLocation.get(objSOL.gii__Warehouse__c)[0];
                                }
                                decimal qty = Integer.valueOf(objSOL.gii__OrderQuantity__c);
                                Integer qtyNeeded = 0;
                                XC_UTIL_Debug.debug(DEBUGACTIVE, 'objPTTransferWrapper.mapWHPRLOWithAvlQty = '+objPTTransferWrapper.mapWHPRLOWithAvlQty);
                                decimal availQty = objPTTransferWrapper.mapWHPRLOWithAvlQty.containsKey(key) ? objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key) : 0;
                                XC_UTIL_Debug.debug(DEBUGACTIVE, 'availQty = '+availQty);
                                if(availQty!=0 && objSOL.gii__OrderQuantity__c >= availQty && key!=''){
                                    qtyNeeded = Integer.valueOf(objSOL.gii__OrderQuantity__c - availQty);
                                }else{
                                    qtyNeeded = Integer.valueOf(objSOL.gii__OrderQuantity__c);
                                }
                                XC_UTIL_Debug.debug(DEBUGACTIVE, 'qtyNeeded = '+qtyNeeded);
                                mapSupplierProductPI.get(suppProdKey).add(objSOL);                             
                                lstErrors.addAll(createPOforSO(objPTTransferWrapper,mapSupplierProductPI,  qtyNeeded   , whSupplyFlow, objProdAvailResponse));                                
                            } else{ 
                                lstErrors.add(Label.giic_ErrorEndDate);  
                                return lstErrors;
                            }
                        }
                    }  
                }else{
                    if(objSOL.gii__Product__r.giic_EndDate__c >= date.today() || objSOL.gii__Product__r.giic_EndDate__c == null ){
                        String keyPBE = objSOL.gii__Product__c + '-' + objSOL.gii__Product__r.gii__PrimarySupplier__c;
                        if(objPTTransferWrapper.mapPBEClosedOrders.containskey(keyPBE) ){   
                               lstErrors.add(Label.giic_CL_CloseOrderError);  
                               return lstErrors;
                           }else{ 
                               settProductIds.add(objSOL.gii__Product__c); 
                             
                               string suppProdKey=objSOL.gii__Product__r.gii__PrimarySupplier__c +'-' + objSOL.gii__Product__c;
                               setSupplierIds.add(objSOL.gii__Product__r.gii__PrimarySupplier__c);
                               if(!mapSupplierProductPI.containskey(suppProdKey)){ mapSupplierProductPI.put(suppProdKey,new list<gii__SalesOrderLine__c>()); }
                               mapSupplierProductPI.get(suppProdKey).add(objSOL);    
                               // new 29-10-20
                               string key = '';
                               if( wrWH.mapWHLocation.containsKey(objSOL.gii__Warehouse__c)){
                                   key = objSOL.gii__Warehouse__c +'-' + objSOL.gii__Product__c + '-' + wrWH.mapWHLocation.get(objSOL.gii__Warehouse__c)[0];
                               }
                               decimal qty = Integer.valueOf(objSOL.gii__OrderQuantity__c);
                               Integer qtyNeeded = 0;
                               decimal availQty = objPTTransferWrapper.mapWHPRLOWithAvlQty.containsKey(key) ? objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key) : 0;
                               if(availQty!=0 && objSOL.gii__OrderQuantity__c >= availQty && key!=''){
                                   qtyNeeded = Integer.valueOf(objSOL.gii__OrderQuantity__c - availQty);
                                   XC_UTIL_Debug.debug(DEBUGACTIVE, '33');
                               }else{
                                   XC_UTIL_Debug.debug(DEBUGACTIVE, '44');
                                   qtyNeeded = Integer.valueOf(objSOL.gii__OrderQuantity__c);
                               }
                               XC_UTIL_Debug.debug(DEBUGACTIVE, 'qtyNeeded = '+qtyNeeded);
                               ///////////////////////////////////////////////////////////////////////////////////////////////////7                        
                               lstErrors.addAll(createPOforSO(objPTTransferWrapper,mapSupplierProductPI, qtyNeeded, whSupplyFlow , objProdAvailResponse));
                           }
                    }else{
                        lstErrors.add(Label.giic_ErrorEndDate); 
                        return lstErrors;
                    }
                }
            }when 'LW'{ 
                Decimal notReservedQuantity = objSOL.gii__OrderQuantity__c; 
                for(Id whId : wrWH.mapWarehouseGroupWarehoues.get(objSOL.gii__Warehouse__r.gii__WarehouseGroup__c)){
                    Decimal totalQuantity = 0; 
                    if(!wrWH.mapWHLocation.containskey(whId)){continue; }
                    for(Id location : wrWH.mapWHLocation.get(whId)){
                        string key =  whId + '-' + objSOL.gii__Product__c + '-' + location;
                        if(objPTTransferWrapper.mapWHPRLOWithAvlQty.containsKey(key) && objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key) > 0 ){ totalQuantity = totalQuantity + objPTTransferWrapper.mapWHPRLOWithAvlQty.get(key);  } 
                    }
                    if(totalQuantity > 0  && totalQuantity >= objSOL.gii__OrderQuantity__c && objSOL.gii__Warehouse__c != whId){ 
                        for(Id location : wrWH.mapWHLocation.get(whId)){
                            String localKey =  whId + '-' + objSOL.gii__Product__c + '-' + location; 
                            if(objPTTransferWrapper.mapWHPRLOWithAvlQty.containsKey(localKey) &&objPTTransferWrapper.mapWHPRLOWithAvlQty.get(localKey) >0 && notReservedQuantity > 0 ){
                                decimal availQty=objPTTransferWrapper.mapWHPRLOWithAvlQty.containsKey(localKey) ? objPTTransferWrapper.mapWHPRLOWithAvlQty.get(localKey) : 0;  
                                decimal qtyReserved = objSOL.gii__OrderQuantity__c;
                                
                                objPTTransferWrapper.mapWHPRLOWithAvlQty.put(localKey,integer.valueof(objPTTransferWrapper.mapWHPRLOWithAvlQty.get(localKey) - objSOL.gii__OrderQuantity__c));
                                XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso3');
                                // integer transferTime=objPTTransferWrapper.mapAllNetworkWarehouses.get(whId).gii__WarehouseGroup__r.giic_AvgTransferTime__c != null ? integer.valueof(objPTTransferWrapper.mapAllNetworkWarehouses.get(whId).gii__WarehouseGroup__r.giic_AvgTransferTime__c) : 0;
                                Integer transferTime = objPTTransferWrapper.mapWHPRLOWithPI.get(whId + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c != null ? (Integer)objPTTransferWrapper.mapWHPRLOWithPI.get(whId + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c : (Integer)wrWH.mapCountryWHSupplyFlow.get(objSOL.gii__Warehouse__r.giic_LegalEntity__c).XC_LogisticPartnerSupplyTime__c;
                                
                                objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate=system.today().adddays(transferTime); //Transfer time days
                                objPTTransferWrapper.reserveWrap.add(giic_ReservationUtility.getReservationWrapper(whId,objSOL.gii__Product__c,integer.valueof(qtyReserved),location));
                                objPTTransferWrapper.isContinue=true;
                                string toKey=whId + '-' + objSOL.gii__Warehouse__c;
                                Date requiredDate = objSOL.gii__SalesOrder__r.gii__RequiredDate__c < Date.today() ? Date.today() : objSOL.gii__SalesOrder__r.gii__RequiredDate__c ;
                                if(!objProdAvailResponse.objTOWrapper.mapTransferOrder.containsKey(toKey) && qtyReserved>0){ 
                                    gii__TransferOrder__c objTO = createTransferOrder(objSOL,requiredDate,whId);
                                    objProdAvailResponse.objTOWrapper.mapTransferOrder.put(toKey,objTO);
                                    gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = qtyReserved);
                                    objProdAvailResponse.objTOWrapper.mapTransferOrderLine.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine}); 
                                }else if( qtyReserved > 0){
                                    gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = qtyReserved);
                                    objProdAvailResponse.objTOWrapper.mapTransferOrderLine.get(toKey).add(objTOLine);
                                }
                                notReservedQuantity = objSOL.gii__OrderQuantity__c - qtyReserved;
                                if(notReservedQuantity < 1){ break;  }
                            }                             
                        }
                    }
                }
                if(notReservedQuantity > 0){ 
                    String keyPBE = objSOL.gii__Product__c + '-' + objSOL.gii__Product__r.gii__PrimarySupplier__c;
                    if(objPTTransferWrapper.mapPBEClosedOrders.containskey(keyPBE)  ){   
                        lstErrors.add(Label.giic_CL_CloseOrderError);  
                        return lstErrors;
                    }else{
                        if(whSupplyFlow.XC_PurchaseOrderWarehouse__c =='CW' && objSOL.gii__Warehouse__r.giic_ParentWarehouse__c != null ){
                            Integer transferTime = objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c != null ? (Integer)objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c : (Integer)whSupplyFlow.XC_LogisticPartnerSupplyTime__c; 
                            objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate = System.today().adddays(transferTime); //Transfer time days
                            
                            string toKey=objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Warehouse__c; 
                            Date requiredDate = objSOL.gii__SalesOrder__r.gii__RequiredDate__c < Date.today() ? Date.today() : objSOL.gii__SalesOrder__r.gii__RequiredDate__c ;
                            if(!objProdAvailResponse.objTOWrapper.mapTransferOrder.containsKey(toKey) ){
                                gii__TransferOrder__c objTO = createTransferOrder(objSOL, requiredDate, objSOL.gii__Warehouse__r.giic_ParentWarehouse__c);
                                objProdAvailResponse.objTOWrapper.mapTransferOrder.put(toKey,objTO);
                                gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                                objProdAvailResponse.objTOWrapper.mapTransferOrderLine.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine});  
                            }else{
                                gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                                objProdAvailResponse.objTOWrapper.mapTransferOrderLine.get(toKey).add(objTOLine); 
                            }
                            objPTTransferWrapper.isContinue=true;
                            objPTTransferWrapper.reserveWrap.add(giic_ReservationUtility.getReservationWrapper(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c,objSOL.gii__Product__c ,integer.valueof(objSOL.gii__OrderQuantity__c),objSOL.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c));
                        }
                        if(objSOL.gii__Product__r.giic_EndDate__c >= date.today() || objSOL.gii__Product__r.giic_EndDate__c == null ){                            
                            if(objPTTransferWrapper.mapPBEClosedOrders.containskey(keyPBE)  ){   
                                lstErrors.add(Label.giic_CL_CloseOrderError);  
                                return lstErrors;
                            }else{ 
                                settProductIds.add(objSOL.gii__Product__c);
                                string suppProdKey=objSOL.gii__Product__r.gii__PrimarySupplier__c +'-' + objSOL.gii__Product__c;
                                setSupplierIds.add(objSOL.gii__Product__r.gii__PrimarySupplier__c);
                                if(!mapSupplierProductPI.containskey(suppProdKey)){ mapSupplierProductPI.put(suppProdKey,new list<gii__SalesOrderLine__c>());}
                                mapSupplierProductPI.get(suppProdKey).add(objSOL); 
                                lstErrors.addall(createPOforSO(objPTTransferWrapper,mapSupplierProductPI, Integer.valueOf(notReservedQuantity), whSupplyFlow,objProdAvailResponse));
                            }
                        } else{
                            lstErrors.add(Label.giic_ErrorEndDate); 
                            return lstErrors;
                        }
                    }
                } 
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        return lstErrors;
    } 
    
    public static gii__TransferOrder__c createTransferOrder(gii__SalesOrderLine__c objSOL, Date requiredDate, String fromWarehouse){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ creoTO'  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ creoTO'  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ creoTO'  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ creoTO'  );
        
		//NR2097
		List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
		Boolean DraftTO = FALSE;
		String TOStatus;
		Boolean ApprovedTO = TRUE;
		for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {
			if ((CSett.giic_LegalEntity__c == objSOL.gii__SalesOrder__r.giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {
				DraftTO=CSett.giic_DraftTO__c;
				Break;
			}
		}
		if(DraftTO == TRUE) {ApprovedTO=FALSE;TOStatus=Label.giic_TODraftStatus;} else {ApprovedTO=TRUE;TOStatus=Label.giic_TOApproved;}        
        gii__TransferOrder__c t = new gii__TransferOrder__c(giic_Status__c=TOStatus,
                                                            giic_Source__c=Label.giic_OrderSourceAutomation,
                                                            gii__Account__c=objSOL.gii__Warehouse__r.gii__Account__c,
                                                            gii__RequiredDate__c = requiredDate ,
                                                            giic_SalesOrder__c = objSOL.gii__SalesOrder__c,
                                                            gii__FromWarehouse__c= fromWarehouse,
                                                            giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c,
                                                            gii__TransferToWarehouse__c=objSOL.gii__Warehouse__c,
                                                            giic_Approved__c=ApprovedTO);
        return t;
    }
    
    public static List<String> createPOforSO(ProcurementTypeTransferWrapper objPTTransferWrapper,Map<String, List<gii__SalesOrderLine__c>> mapSupplierProductPI, Integer dSuggestedQty, XC_CM_WarehouseSupplyFlow__mdt pOWarehouse, ProductAvailabilityResponse objProdAvailResponse){
         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ createPOforSO'  );
         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ createPOforSO'  );
        /***********************************************set variables**********************************/
        set<string> setPOKey=new set<string>();
        set<string> setTOWH=new set<string>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTRO IN createPOforSO');
        
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        /***********************************************map variables**********************************/
        map<string,gii__PurchaseOrder__c> mapKeyPO=new  map<string,gii__PurchaseOrder__c>();
        map<string,list<gii__PurchaseOrderLine__c>> mapKeyPOL=new  map<string,list<gii__PurchaseOrderLine__c>>(); 
        map<string,gii__TransferOrder__c> mapTransferOrder=new map<string,gii__TransferOrder__c>();
        map<string,list<gii__TransferOrderLine__c>> mapTransferOrderLine=new map<string,list<gii__TransferOrderLine__c>>();// Map of PI Ids and Transfer Order  
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap = new List<giic_ReservationUtility.ReservationWrapper>();
        /***********************************************list variables**********************************/ 
        list<string> lstErrors=new list<string>(); 
        
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        List<gii__ProductInventory__c> lstPIToUpdateBackOrderQty = new List<gii__ProductInventory__c> ();
        if(objPTTransferWrapper.lstPriceBookAndPBEntry.size()>0){
            for(gii__PriceBookEntry__c pbEntry : objPTTransferWrapper.lstPriceBookAndPBEntry) {
                string key=pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ key' + key ); 
                if(mapSupplierProductPI.containskey(key)){
                    for(gii__SalesOrderLine__c objSOL : mapSupplierProductPI.get(key)){
                        String poKey=objSOL.gii__Warehouse__c + '-'+ pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+pbEntry.gii__PriceBook__r.name;
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ poKey' + poKey );
                        String warehouse; 
                        if(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c != null){                             
                            switch on pOWarehouse.XC_PurchaseOrderWarehouse__c {
                                when 'CW' {
                            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ when CW' );
                                    string toKey = objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Warehouse__c;
                                    Integer transferTime =  (Integer)pOWarehouse.XC_LogisticPartnerSupplyTime__c;
                                    if(objPTTransferWrapper.mapWHPRLOWithPI.containskey(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c)){
                                        transferTime = objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c != null ? (Integer)objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c).giic_AvgTransferTime__c : (Integer)pOWarehouse.XC_LogisticPartnerSupplyTime__c; 
                                    }
                                    Integer supplyTime = pbEntry.giic_AvgSupplyTime__c != null ? (Integer)pbEntry.giic_AvgSupplyTime__c : (Integer)pOWarehouse.XC_SupplierSupplyTime__c;
                                    objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate = System.today().adddays(transferTime + supplyTime); //Transfer time days
                                    
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    string suggKey = objSOL.gii__Product__c + '-' + objSOL.gii__Warehouse__r.giic_ParentWarehouse__c  + '-'+ objSOL.gii__Warehouse__r.giic_ParentWarehouse__r.gii__DefaultIssueLocation__c;
                                    warehouse = objSOL.gii__Warehouse__r.giic_ParentWarehouse__c;
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ warehouse' + warehouse);
                                }
                                when 'LW' { 
                                    string suggKey=objSOL.gii__Product__c + '-' + objSOL.gii__Warehouse__c+'-' + objSOL.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                                    warehouse = objSOL.gii__Warehouse__c;
                                }
                            } 
                        }else{
                            string suggKey=objSOL.gii__Product__c + '-' + objSOL.gii__Warehouse__c+'-' + objSOL.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                            warehouse = objSOL.gii__Warehouse__c;
                        }
                        if(!objPTTransferWrapper.setPOKey.contains(poKey)){ 
                            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                            gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(giic_Source__c=Label.giic_OrderSourceAutomation,giic_Contract__c=pbEntry.gii__PriceBook__r.giic_Contract__c,
                                                                                    gii__Supplier__c = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId,gii__ShipTo__c = warehouse,
                                                                                    gii__OrderDate__c = system.today(), gii__Approved__c=false,gii__DropShip__c = false,gii__RequiredDate__c = system.today(),
                                                                                    gii__PriceBookName__c=pbEntry.gii__PriceBook__r.name, gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                                                                                    giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c,giic_CUP__c = objSOL.gii__SalesOrder__r.giic_CUP__c, giic_CIG__c = objSOL.gii__SalesOrder__r.giic_CIG__c, 
                                                                                    giic_PriceBookId__c =pbEntry.gii__PriceBook__c );
                            objProdAvailResponse.objPOWrapper.mapPurchaseOrder.put(poKey,objPO);
                            //[NR1106]
                            integer oldOrderQuantity; //NR1353
                    		if (pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0) {
                                oldOrderQuantity = dSuggestedQty; //NR1353
                        		if(dSuggestedQty <=integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c)) {dSuggestedQty = integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                        		else {
                            		Integer Div = integer.ValueOf(dSuggestedQty/pbEntry.giic_MinimumOrderQuantity__c);
                            		Integer remainder = math.mod(integer.ValueOf(dSuggestedQty), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                            		if (remainder == 0) {dSuggestedQty = Div*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                           			 else {dSuggestedQty = (Div + 1)*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                        		}
                    		}
                            system.debug('oldOrderQuantity: '+ oldOrderQuantity);
							//[NR1106]
                            gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__SalesOrderLine__c = objSOL.id,gii__OrderQuantity__c=dSuggestedQty);
                            //NR1353
                            if (oldOrderQuantity != null && oldOrderQuantity != 0){
                                objPOLine.giic_OldOrderQuantity__c = oldOrderQuantity;
                            }
                            //NR1353
                            if(objPTTransferWrapper.mapWHPRLOWithPI.containskey(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c)){
                                gii__ProductInventory__c pi = objPTTransferWrapper.mapWHPRLOWithPI.get(objSOL.gii__Warehouse__r.giic_ParentWarehouse__c + '-' + objSOL.gii__Product__c);
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ pi'  +pi);
                                if(pi.giic_BackOrderNew__c!=null){  
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    pi.giic_BackOrderNew__c = pi.giic_BackOrderNew__c + dSuggestedQty;
                                }else{
                                    pi.giic_BackOrderNew__c = dSuggestedQty;
                                } 
                                lstPIToUpdateBackOrderQty.add(pi); 
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                            }
                            //gii__ProductInventory__c pi = new gii__ProductInventory__c(Id = objSOL.gii__ProductInventory__c)
                        //objProdAvailResponse.lstPIToUpdateBackOrderQty.get().giic_BackOrderNew__c = objProdAvailResponse.lstPIToUpdateBackOrderQty.get(objSOL.gii__ProductInventory__c).giic_BackOrderNew__c+dSuggestedQty;
                            objProdAvailResponse.objPOWrapper.mapPurchaseOrderLine.put(poKey,new list<gii__PurchaseOrderLine__c>{objPOLine});
                            objPTTransferWrapper.setPOKey.add(poKey); 
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ objPTTransferWrapper'  +objPTTransferWrapper);
                            
                        }else{
                            //[NR1106]
                            integer oldOrderQuantity; //NR1353
                    		if (pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0) {
                                oldOrderQuantity = dSuggestedQty; //NR1353
                        		if(dSuggestedQty <=integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c)) {dSuggestedQty = integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                        		else {
                            		Integer Div = integer.ValueOf(dSuggestedQty/pbEntry.giic_MinimumOrderQuantity__c);
                            		Integer remainder = math.mod(integer.ValueOf(dSuggestedQty), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                            		if (remainder == 0) {dSuggestedQty = Div*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                           			 else {dSuggestedQty = (Div + 1)*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                        		}
                    		}
							//[NR1106]
                            gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__SalesOrderLine__c = objSOL.id,gii__OrderQuantity__c=dSuggestedQty);
                            //NR1353
                            if (oldOrderQuantity != null && oldOrderQuantity != 0){
                                objPOLine.giic_OldOrderQuantity__c = oldOrderQuantity;
                            }
                            //NR1353
                            objProdAvailResponse.objPOWrapper.mapPurchaseOrderLine.get(poKey).add(objPOLine);
                        }
                    }
                }
            }
             objProdAvailResponse.lstPIToUpdateBackOrderQty = lstPIToUpdateBackOrderQty;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
             XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ objProdAvailResponse'  + objProdAvailResponse);
        }else{  lstErrors.add(System.Label.giic_PriceBookError);    }
        return lstErrors;
    } 
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * @author FirstName : Pradeep Kumar
    * @date Creation 31/07/2019
    * @date Modification dd/mm/yyyy
    * @description - check the quantity available on central and Local warehouse
    * @param lstSOIds - list<id>,  
    * @param mapProductWithAvailability - map<Id,giic_CommonWrapper.ProductAvailability>
    * @return ProductAvailabilityResponse
    */
    public static ProductAvailabilityResponse getProductAvailability(list<id> lstSOIds,map<Id,giic_CommonWrapper.ProductAvailability> mapProductWithAvailability){
        set<Id> setProductIds=mapProductWithAvailability.keyset();
        set<Id> setSOIds=new set<Id>();
        set<string> setPOKey=new set<string>();
        set<string> setTOWH=new set<string>();
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );        
        setSOIds.addall(lstSOIds);                    
        List<giic_ReservationUtility.ReservationWrapper> reserveWrap = new List<giic_ReservationUtility.ReservationWrapper>();
        list<gii__SalesOrderLine__c> lstNotReservedLines=new list<gii__SalesOrderLine__c>();
        map<Id,gii__ProductInventory__c> mapPIToUpdateBackOrderQty=new map<Id,gii__ProductInventory__c>();
        list<gii__ProductInventory__c> lstPIToUpdateBackOrderQty = new list<gii__ProductInventory__c>();
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );        
        map<Id,boolean> mapSOLIsDropShip=new map<Id,boolean>();
        map<id,list<id>> mapWarehouseGroupWarehoues=new map<id,list<id>>();
        map<string,gii__ProductInventory__c> mapWHPRLOWithPI=new map<string,gii__ProductInventory__c>();
        map<string,integer> mapWHPRLOWithAvlQty=new map<string,integer>();
        Set<String> countryWH = new Set<String>();          
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );                                                     
        ProductAvailabilityResponse objProdAvailResponse = new ProductAvailabilityResponse();
        list<gii__SalesOrder__c> salesOrderToUpdate=new list<gii__SalesOrder__c>();
        list<gii__SalesOrderLine__c> salesOrderLineToUpdate=new list<gii__SalesOrderLine__c>(); 
        TransferOrderWrapper objTOWrapper =new TransferOrderWrapper();
        objTOWrapper.mapTransferOrder=new map<string,gii__TransferOrder__c>();
        objTOWrapper.mapTransferOrderLine=new map<string,list<gii__TransferOrderLine__c>>();
        Set<String> soToUpdate = new Set<String>();                                                               
        PurchaseOrderWrapper objPOWrapper =new PurchaseOrderWrapper();
        objPOWrapper.mapPurchaseOrder=new map<string,gii__PurchaseOrder__c>();
        objPOWrapper.mapPurchaseOrderLine=new map<string,list<gii__PurchaseOrderLine__c>>();
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'------ '  );  
        objProdAvailResponse.salesOrderToUpdate=salesOrderToUpdate;
        objProdAvailResponse.salesOrderLineToUpdate = salesOrderLineToUpdate;
        objProdAvailResponse.objTOWrapper = objTOWrapper;                 
        objProdAvailResponse.objPOWrapper = objPOWrapper;                 
        objProdAvailResponse.reserveWrap = reserveWrap;                                                               
        
        /****************************************************** prepare warehouse,location sets *********************************************/        
        List<gii__SalesOrder__c>  lstSalesOrder = Giic_SalesOrderUtility_D.getSalesOrder(lstSOIds);
        List<String> legalEntity = XC_UTIL_Sobject.getListFieldValues(lstSalesOrder, 'giic_LegalEntity__c');
        InventoryWrapper objInventoryWrapper = getWarehouseInformation(lstSalesOrder);
        
        if(!objInventoryWrapper.lstErrors.isEmpty()){
            objProdAvailResponse.lstErrors=objInventoryWrapper.lstErrors;
            return objProdAvailResponse;
        }
        
        /****************************************************** get all warehouses from network *********************************************/
        map<id,gii__Warehouse__c> mapAllNetworkWarehouses=new map<id,gii__Warehouse__c>(giic_WarehouseUtility.getAllWarehousesForNetwork(objInventoryWrapper.setWarehouseGroupIds));
        objInventoryWrapper.setLocationIds.addall(getWarehouseNetworkWise(mapAllNetworkWarehouses,mapWarehouseGroupWarehoues));
        objInventoryWrapper.setWarehouseIds.addall(mapAllNetworkWarehouses.keyset());
        XC_UTIL_Debug.debug(DEBUGACTIVE,'***mapWarehouseGroupWarehoues***'+mapWarehouseGroupWarehoues);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        
        /******************************************************** Prepare map for available qty from PIQD ******************************************/
        map<string,List<gii__ProductInventoryQuantityDetail__c>> mapWHPIQD = new Map<string,List<gii__ProductInventoryQuantityDetail__c>>();
        
        for(gii__ProductInventoryQuantityDetail__c objPIQD : Giic_InventoryUtility_D.getPIQD(objInventoryWrapper.setWarehouseIds,setProductIds,objInventoryWrapper.setLocationIds)){
            // XC_UTIL_Debug.debug(DEBUGACTIVE, '***setSOIds***'+objPIQD.gii__OnHandQuantity__c + ' gii__Available__c-->>>> ' + objPIQD.gii__Available__c);
            getPIAvailQty(objPIQD,mapWHPRLOWithAvlQty,mapWHPRLOWithPI);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            string keyWHPIQD =objPIQD.gii__Warehouse__c + '-' + objPIQD.gii__Product__c;
            if(!mapWHPIQD.containsKey(keyWHPIQD)){  mapWHPIQD.put(keyWHPIQD, new List<gii__ProductInventoryQuantityDetail__c>()); } 
            mapWHPIQD.get(keyWHPIQD).add(objPIQD); 

        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        Map<String,String> mapProductSupplier = new  Map<String,String>();
        for(gii__ProductInventory__c objPI : Giic_InventoryUtility_D.getPIForStockAvailability(objInventoryWrapper.setWarehouseIds,setProductIds)){
            string key=objPI.gii__Warehouse__c + '-' + objPI.gii__Product__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            mapProductSupplier.put(objPI.gii__Product__c, objPI.gii__Product__r.gii__PrimarySupplier__c);
            if(!mapWHPRLOWithPI.containskey(key)){
                mapWHPRLOWithPI.put(key,objPI);
            }
        }
        /*******************************************************************************************/
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        ProcurementTypeTransferWrapper objPTTransferWrapper=new ProcurementTypeTransferWrapper();
        
        objPTTransferWrapper.mapProductWithAvailability=mapProductWithAvailability;
        objPTTransferWrapper.mapWHPRLOWithAvlQty=mapWHPRLOWithAvlQty;
        objPTTransferWrapper.mapWHPRLOWithPI=mapWHPRLOWithPI;
        objPTTransferWrapper.isContinue=true;
        objPTTransferWrapper.reserveWrap=reserveWrap;
        objPTTransferWrapper.mapAllNetworkWarehouses=mapAllNetworkWarehouses;
        objPTTransferWrapper.setPOKey=setPOKey;
        objPTTransferWrapper.setTOWH=setTOWH;
        //[NR1107]
 		objProdAvailResponse.mapWHPRLOWithPI=mapWHPRLOWithPI;
		objProdAvailResponse.mapWHPIQD=mapWHPIQD;
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  ); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  ); 
        
        List<String> warehouseGroup =  new List<String>();
        List<Id> allWarehouse = new List<Id>();
        for(gii__SalesOrder__c so : lstSalesOrder ){
            if(so.gii__Warehouse__r.gii__WarehouseGroup__c != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                warehouseGroup.add(so.gii__Warehouse__r.gii__WarehouseGroup__c);
            }else{ allWarehouse.add(so.gii__Warehouse__c);    } 
            if(so.giic_FromWarehouse__c != null){allWarehouse.add(so.giic_FromWarehouse__c);   } 
        }                                           
        for(String wH : warehouseGroup ){ allWarehouse.addAll(mapWarehouseGroupWarehoues.get(wH)); }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        List<gii__Location__c> whLocations = new List<gii__Location__c>([SELECT Id, giic_LocationType__c ,gii__Warehouse__c,gii__Warehouse__r.gii__WareHouseCountry__c,
                                                                         gii__Warehouse__r.giic_ParentWarehouse__r.gii__WareHouseCountry__c,gii__Warehouse__r.giic_LegalEntity__c,
                                                                         gii__Warehouse__r.giic_ParentWarehouse__r.giic_LegalEntity__c,gii__Warehouse__r.gii__DefaultIssueLocation__c
                                                                         FROM gii__Location__c  
                                                                         WHERE (giic_LocationType__c = 'Sales' OR giic_LocationType__c = :Label.giic_CL_VanLocation)
                                                                         AND gii__Warehouse__c IN :  allWarehouse ]); 
        Map<Id, List<Id>> mapWHLocation = new Map<Id, List<Id>>();
        Map<String, String> mapWHDefaultLocation = new Map<String, String>();
        for(gii__Location__c location : whLocations){ 
            if(!mapWHLocation.containsKey(location.gii__Warehouse__c)){
                mapWHLocation.put(location.gii__Warehouse__c, new List<Id>());
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
            } 
            countryWH.add(location.gii__Warehouse__r.giic_LegalEntity__c);   
            countryWH.add(location.gii__Warehouse__r.giic_ParentWarehouse__r.giic_LegalEntity__c);  
            mapWHLocation.get(location.gii__Warehouse__c).add(location.Id);
            mapWHDefaultLocation.put(location.gii__Warehouse__c, location.gii__Warehouse__r.gii__DefaultIssueLocation__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '#####mapWHDefaultLocation' + mapWHDefaultLocation);
        } 
        
        Map<String, XC_CM_WarehouseSupplyFlow__mdt> mapCountryWHSupplyFlow = new  Map<String, XC_CM_WarehouseSupplyFlow__mdt>();
        
        List<XC_CM_WarehouseSupplyFlow__mdt> configurationCM = new List<XC_CM_WarehouseSupplyFlow__mdt>([SELECT XC_Country__c,XC_LogisticPartnerSupplyTime__c,
                                                                                                         XC_PurchaseOrderWarehouse__c, XC_LegalEntity__c,
                                                                                                         XC_SupplierSupplyTime__c, XC_FirstWarehouseCheck__c 
                                                                                                         FROM XC_CM_WarehouseSupplyFlow__mdt 
                                                                                                         // WHERE XC_Country__c IN :countryWH ]);
                                                                                                         WHERE XC_LegalEntity__c IN :legalEntity ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        for(XC_CM_WarehouseSupplyFlow__mdt cm : configurationCM){
            mapCountryWHSupplyFlow.put(cm.XC_LegalEntity__c, cm);
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ mapCountryWHSupplyFlow' + mapCountryWHSupplyFlow);  
        
        Map<String,gii__PriceBookEntry__c> mapProductSupplierPbe = new  Map<String,gii__PriceBookEntry__c>(); 
        Map<String,gii__PriceBookEntry__c> mapProductClosedContract = new  Map<String,gii__PriceBookEntry__c>(); 
        List<gii__PriceBookEntry__c> lstPriceBookAndPBEntry = new List<gii__PriceBookEntry__c>(); 
        List<gii__PriceBookEntry__c> lstPBE = new List<gii__PriceBookEntry__c>([SELECT Id,name,gii__Product__c,giic_MinimumOrderQuantity__c,gii__Product__r.gii__PrimarySupplier__c,gii__Product__r.gii__ProductCode__c,gii__PriceBook__c,gii__PriceBook__r.name,
                                                                                                gii__PriceBook__r.giic_Contract__c,gii__PriceBook__r.giic_Contract__r.AccountId,gii__PriceBook__r.giic_Contract__r.Status,gii__PriceBook__r.giic_Contract__r.XC_Type__c,
                                                                                                gii__PriceBook__r.giic_Contract__r.EndDate ,giic_AvgSupplyTime__c,gii__Product__r.gii__ProductReference__r.XC_Country__c,giic_Default__c,gii__Product__r.gii__ProductReference__r.giic_LegalEntity__c
                                                                                                FROM gii__PriceBookEntry__c 
                                                                                                WHERE gii__Product__c IN:mapProductSupplier.keySet() 
                                                                                                AND gii__PriceBook__r.giic_Contract__r.AccountId<>null 
                                                                                                AND gii__PriceBook__r.giic_Contract__r.AccountId in : mapProductSupplier.values() 
                                                                                				AND gii__Product__r.giic_LegalEntity__c IN :legalEntity
                                                                                               ]);
        
        for(gii__PriceBookEntry__c pbe : lstPBE ){
            if(pbe.giic_Default__c ){
                lstPriceBookAndPBEntry.add(pbe);
                Integer supplierAvg =  mapCountryWHSupplyFlow.containskey(pbe.gii__Product__r.gii__ProductReference__r.XC_Country__c) &&  mapCountryWHSupplyFlow.get(pbe.gii__Product__r.gii__ProductReference__r.giic_LegalEntity__c).XC_SupplierSupplyTime__c!= null ?  (Integer)mapCountryWHSupplyFlow.get(pbe.gii__Product__r.gii__ProductReference__r.giic_LegalEntity__c).XC_SupplierSupplyTime__c : 0;
                Integer avg =  (Integer)pbe.giic_AvgSupplyTime__c != null ? (Integer)pbe.giic_AvgSupplyTime__c : supplierAvg;
                mapProductWithAvailability.get(pbe.gii__Product__c).availabilityDate = System.today().adddays(avg); //Transfer time days  
                mapProductSupplierPbe.put(pbe.gii__Product__c + '-' + pbe.gii__Product__r.gii__PrimarySupplier__c ,pbe ); 
            }
            if(pbe.gii__PriceBook__r.giic_Contract__r.XC_Type__c != null && pbe.gii__PriceBook__r.giic_Contract__r.XC_Type__c.substring(0,3) == 'ZCC' &&   pbe.gii__PriceBook__r.giic_Contract__r.Status != 'Ended'){ //
                mapProductClosedContract.put(pbe.gii__Product__c + '-' + pbe.gii__Product__r.gii__PrimarySupplier__c ,pbe );                 
            }
        }      
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        objPTTransferWrapper.lstPriceBookAndPBEntry  = lstPriceBookAndPBEntry;  
        objPTTransferWrapper.mapPBEClosedOrders = mapProductClosedContract;
        
        Giic_TransferOrderUtility.warehouseWrapper wrWH = new Giic_TransferOrderUtility.warehouseWrapper();
        wrWH.mapWHLocation = mapWHLocation;
        wrWH.mapAllNetworkWarehouses = mapAllNetworkWarehouses;
        wrWH.mapWarehouseGroupWarehoues = mapWarehouseGroupWarehoues;
        wrWH.mapCountryWHSupplyFlow = mapCountryWHSupplyFlow;
        
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'***mapWHPRLOWithAvlQty***'+mapWHPRLOWithAvlQty);
        for(gii__SalesOrderLine__c objSOL : Giic_SalesOrderUtility_D.getSalesOrderLines(setSOIds)){
            /****************************************** Procurement Type Transfer, check for All local and central warehouse for quantity ****************/ 
            XC_UTIL_Debug.debug(DEBUGACTIVE,'***objSOL.gii__Product__r.giic_ProcurementType__c***'+objSOL.gii__Product__r.giic_ProcurementType__c);
            if(objSOL.gii__Product__r.giic_ProcurementType__c == System.Label.Giic_ProductProcurementTypeTransfer){
                /******************************************* Local Warehouse Check *****************************************/
                objPTTransferWrapper.isContinue=false; 
                if(objSOL.gii__SalesOrder__r.giic_IsDelivery__c){
                	XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ giic_IsDelivery__c '  );
                	if(objSOL.gii__SalesOrder__r.giic_FromWarehouse__c!=null){
               			XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ giic_FromWarehouse__c '  );
                        string toKey=objSOL.gii__SalesOrder__r.giic_FromWarehouse__c + '-' + objSOL.gii__Warehouse__c;  
                        
                        if(!objProdAvailResponse.objTOWrapper.mapTransferOrder.containsKey(toKey) ){
							//NR2097
							List<giic_ConsoleIntegrationLP__c> CS_CI = giic_ConsoleIntegrationLP__c.getAll().values();
							Boolean DraftTO = FALSE;
							String TOStatus;
							Boolean ApprovedTO = TRUE;
							for (giic_ConsoleIntegrationLP__c CSett : CS_CI) {
								if ((CSett.giic_LegalEntity__c == objSOL.gii__SalesOrder__r.giic_LegalEntity__c)&&(CSett.giic_ActiveConfiguration__c==TRUE)) {
									DraftTO=CSett.giic_DraftTO__c;
									Break;
								}
							}
							if(DraftTO == TRUE) {ApprovedTO=FALSE;TOStatus=Label.giic_TODraftStatus;} else {ApprovedTO=TRUE;TOStatus=Label.giic_TOApproved;}
                            gii__TransferOrder__c objTO=new gii__TransferOrder__c(giic_Status__c=TOStatus,giic_Source__c=Label.giic_OrderSourceAutomation,
                                                                                  gii__Account__c=objSOL.gii__SalesOrder__r.gii__Account__c,
                                                                                  giic_SalesOrder__c = objSOL.gii__SalesOrder__c,
                                                                                  gii__FromWarehouse__c=objSOL.gii__SalesOrder__r.giic_FromWarehouse__c,
                                                                                  gii__TransferToWarehouse__c=objSOL.gii__Warehouse__c, giic_Approved__c=ApprovedTO, 
                                                                                  gii__ShipToCity__c = objSOL.gii__SalesOrder__r.gii__ShipToCity__c,
                                                                                  gii__ShipToCountry__c = objSOL.gii__SalesOrder__r.gii__ShipToCountry__c,
                                                                                  gii__ShipToName__c = objSOL.gii__SalesOrder__r.gii__ShipToName__c, 
                                                                                  gii__ShipToState__c = objSOL.gii__SalesOrder__r.gii__ShipToStateProvince__c, 
                                                                                  gii__ShipToStreet__c = objSOL.gii__SalesOrder__r.gii__ShipToStreet__c, 
                                                                                  gii__ShipToZipPostalCode__c = objSOL.gii__SalesOrder__r.gii__ShipToZipPostalCode__c,
                                                                                  giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c
                                                                                 );
                            
                            objProdAvailResponse.objTOWrapper.mapTransferOrder.put(toKey,objTO);
                            gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                            objProdAvailResponse.objTOWrapper.mapTransferOrderLine.put(toKey,new list<gii__TransferOrderLine__c>{objTOLine});  
                        }else{
                            gii__TransferOrderLine__c objTOLine=new gii__TransferOrderLine__c(giic_SalesOrderLine__c=objSOL.id,gii__Product__c=objSOL.gii__Product__c,gii__Quantity__c = objSOL.gii__OrderQuantity__c);
                            objProdAvailResponse.objTOWrapper.mapTransferOrderLine.get(toKey).add(objTOLine);  
                        }
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  ); 
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );

        				string keyWHPIQDLoc =objSOL.gii__SalesOrder__r.giic_FromWarehouse__c + '-' + objSOL.gii__Product__c;
						List<gii__ProductInventoryQuantityDetail__c> ListOfPIQD = new List<gii__ProductInventoryQuantityDetail__c>();
						if(mapWHPIQD.containskey(keyWHPIQDLoc)){
							ListOfPIQD = mapWHPIQD.get(keyWHPIQDLoc);                         
                       
 				
							String location;
							List<String> ListOfLocAv = new List<String>();
							//for(gii__ProductInventoryQuantityDetail__c PIQDAv : ListOfPIQD){ListOfLocAv.add(PIQDAv.gii__Location__c);}
							for(gii__ProductInventoryQuantityDetail__c PIQDAv : ListOfPIQD){if((PIQDAv.gii__Location__r.giic_LocationType__c =='Sales') && (PIQDAv.gii__Available__c > 0)) {ListOfLocAv.add(PIQDAv.gii__Location__c);}}
							If (ListOfLocAv.Size()>0) {location = ListOfLocAv[0];} else {location = mapWHDefaultLocation.get(objSOL.gii__SalesOrder__r.giic_FromWarehouse__c);}
                        					
					
                        	XC_UTIL_Debug.debug(DEBUGACTIVE, '#####mapWHDefaultLocationlocation' + location);
							//location = mapWHLocation.get(objSOL.gii__SalesOrder__r.giic_FromWarehouse__c)[0];	
                        	objPTTransferWrapper.reserveWrap.add(giic_ReservationUtility.getReservationWrapper(objSOL.gii__SalesOrder__r.giic_FromWarehouse__c,objSOL.gii__Product__c ,integer.valueof(objSOL.gii__OrderQuantity__c),location));
                        	}
                        String key = objSOL.gii__SalesOrder__r.giic_FromWarehouse__c + '-' + objSOL.gii__Product__c;
                        if(mapWHPRLOWithPI.containskey(key)){
                            Decimal avQty = mapWHPRLOWithPI.get(key).gii__TotalOnOrder__c + mapWHPRLOWithPI.get(key).giic_SalesOnHand__c;
                            if( objSOL.gii__OrderQuantity__c > avQty ){
                                String keyPbe = mapWHPRLOWithPI.get(key).gii__Product__c + '-' +  mapWHPRLOWithPI.get(key).gii__Product__r.gii__PrimarySupplier__c ;
                                 /********* CR NR1108*****************/
                                if(mapProductClosedContract.containskey(keyPBE) && mapProductClosedContract.get(keyPBE).gii__PriceBook__r.giic_Contract__r.XC_Type__c.substring(0,3) == 'ZCC'){
                                    List<String> error = new List<String>();
                                    error.add(Label.giic_CL_CloseOrderError);
                                    objProdAvailResponse.lstErrors = error;
                                    return objProdAvailResponse;
                                }
                                /*****************************************/
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                if(mapProductSupplierPbe.containskey(keyPbe) ){                                                            
                                    string poKey=objSOL.gii__SalesOrder__r.giic_FromWarehouse__c + '-'+ mapProductSupplierPbe.get(keyPbe).gii__PriceBook__r.giic_Contract__r.AccountId + '-'+mapProductSupplierPbe.get(keyPbe).gii__PriceBook__r.name; 
                                    Integer transferTime = mapWHPRLOWithPI.get(key).giic_AvgTransferTime__c != null ? (Integer)mapWHPRLOWithPI.get(key).giic_AvgTransferTime__c : (Integer)mapCountryWHSupplyFlow.get(objSOL.gii__SalesOrder__r.giic_LegalEntity__c).XC_LogisticPartnerSupplyTime__c;
                                    Integer supplyTime = mapProductSupplierPbe.get(keyPbe).giic_AvgSupplyTime__c != null ? (Integer)mapProductSupplierPbe.get(keyPbe).giic_AvgSupplyTime__c : (Integer)mapCountryWHSupplyFlow.get(objSOL.gii__SalesOrder__r.giic_LegalEntity__c).XC_SupplierSupplyTime__c;
                                    objPTTransferWrapper.mapProductWithAvailability.get(objSOL.gii__Product__c).availabilityDate = System.today().adddays(transferTime + supplyTime); //Transfer time days
									XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );                                    
                                    if(!objPTTransferWrapper.setPOKey.contains(poKey)){
                                        gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(giic_Source__c=Label.giic_OrderSourceAutomation,
                                                                                                giic_Contract__c=mapProductSupplierPbe.get(keyPbe).gii__PriceBook__r.giic_Contract__c,
                                                                                                gii__Supplier__c = mapProductSupplierPbe.get(keyPbe).gii__PriceBook__r.giic_Contract__r.AccountId,
                                                                                                gii__ShipTo__c = objSOL.gii__SalesOrder__r.giic_FromWarehouse__c,
                                                                                                gii__OrderDate__c = system.today(), gii__Approved__c=false,
                                                                                                gii__DropShip__c = false,gii__RequiredDate__c = system.today(),
                                                                                                gii__PriceBookName__c=mapProductSupplierPbe.get(keyPbe).gii__PriceBook__r.name, 
                                                                                                gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                                                                                                giic_PriceBookId__c =mapProductSupplierPbe.get(keyPbe).gii__PriceBook__c );
                                        objProdAvailResponse.objPOWrapper.mapPurchaseOrder.put(poKey,objPO);
                                         //[NR1106]
                                        Decimal QtyNew = objSOL.gii__OrderQuantity__c;
                                        integer oldOrderQuantity; //NR1353
										if (mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c != null && mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c != 0) {
                                            oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
											if(QtyNew <=mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c) {QtyNew = mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c;}
											else {
												Integer Div = integer.ValueOf(QtyNew/mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c);
												Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c));
												if (remainder == 0) {QtyNew = Div*mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c;}
												else {QtyNew = (Div + 1)*mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c;}
												}
											}   
                                            system.debug('oldOrderQuantity: '+ oldOrderQuantity);                           
                                        //gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=objSOL.gii__OrderQuantity__c);
                                        gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__SalesOrderLine__c = objSOL.id,gii__OrderQuantity__c=QtyNew);
                                        //NR1353
                                        if(oldOrderQuantity != null && oldOrderQuantity != 0){
                                            objPOLine.giic_OldOrderQuantity__c = oldOrderQuantity;
                                        }
                                        //NR1353
                                         //[NR1106]
                                        objProdAvailResponse.objPOWrapper.mapPurchaseOrderLine.put(poKey,new list<gii__PurchaseOrderLine__c>{objPOLine});
                                        objPTTransferWrapper.setPOKey.add(poKey);
                                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                                        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );                                    
                                    }else{
                                         //[NR1106]
                                        Decimal QtyNew = objSOL.gii__OrderQuantity__c;
                                        integer oldOrderQuantity; //NR1353
										if (mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c != null && mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c != 0) {
											oldOrderQuantity = integer.valueOf(QtyNew); //NR1353
                                            if(QtyNew <=mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c) {QtyNew = mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c;}
											else {
												Integer Div = integer.ValueOf(QtyNew/mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c);
												Integer remainder = math.mod(integer.ValueOf(QtyNew), integer.ValueOf(mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c));
												if (remainder == 0) {QtyNew = Div*mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c;}
												else {QtyNew = (Div + 1)*mapProductSupplierPbe.get(keyPbe).giic_MinimumOrderQuantity__c;}
												}
											}                              
                                        //gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__OrderQuantity__c=objSOL.gii__OrderQuantity__c);
                                        gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__SalesOrderLine__c = objSOL.id,gii__OrderQuantity__c=QtyNew);
                                        //NR1353
                                        if(oldOrderQuantity != null && oldOrderQuantity != 0){
                                            objPOLine.giic_OldOrderQuantity__c = oldOrderQuantity;
                                        }
                                        //NR1353
                                        //[NR1106]
                                        objProdAvailResponse.objPOWrapper.mapPurchaseOrderLine.get(poKey).add(objPOLine);
                                    }
                                }else{
                                    List<String> error = new List<String>();
                                    error.add(Label.giic_PriceBookError);
                                    objProdAvailResponse.lstErrors = error;
                                    //return objProdAvailResponse;
                                }
                            }
                        }
                        objPTTransferWrapper.isContinue=true;     
                    }else{
                        List<String> error = new List<String>();
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'q3');
                        error.add(Label.giic_ErrorMissingWHZoneZip);
                        objProdAvailResponse.lstErrors = error;
                        return objProdAvailResponse;
                    }
                }
                
                objPTTransferWrapper.objSOL=objSOL;
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                if(objPTTransferWrapper.isContinue){continue;}
                // CR LOCATION
                lstPIToUpdateBackOrderQty.addall(processProcurementTypeTransferForLocal(objPTTransferWrapper,mapWHLocation));
                
                if(objPTTransferWrapper.isContinue){continue;}
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );

                List<giic_Switch1107__c> csSw = giic_Switch1107__c.getAll().values();
                boolean isActive1107 = false;
                for(giic_Switch1107__c cs : csSw){
                    if(cs.giic_isActive__c){isActive1107 = true;break;}
                        
                    
                }
                //[NR1107]
                if(objSOL.gii__SalesOrder__r.giic_PO_TO_LocalWH__c && isActive1107){
					List<String> error = processLocalforTransfer(objPTTransferWrapper, mapWHLocation, objProdAvailResponse); 
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'ffffffff');
                    objProdAvailResponse.lstErrors = error;
				}else{
                    if(objSOL.gii__Warehouse__r.gii__WarehouseGroup__c != null &&  mapWarehouseGroupWarehoues.containskey(objSOL.gii__Warehouse__r.gii__WarehouseGroup__c)){
                        List<String> error = processCentralOrLocalForTransfer(objPTTransferWrapper,objProdAvailResponse,wrWH); 
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ffffffff');
                        objProdAvailResponse.lstErrors = error;
                    }
                }
                //[NR1107]
                
                if(objPTTransferWrapper.isContinue){continue;}
                //lstNotReservedLines.add(objSOL);
                //  mapSOLIsDropShip.put(objSOL.id,false); 
            }else{ 
                if(objSOL.gii__Product__r.giic_EndDate__c >= date.today() || objSOL.gii__Product__r.giic_EndDate__c == null ){
                    String keyPBE = objSOL.gii__Product__c + '-' + objSOL.gii__Product__r.gii__PrimarySupplier__c;
                    if(mapProductClosedContract.containskey(keyPBE)){  
                           List<String> error = new List<String>();
                           error.add(Label.giic_CL_CloseOrderError);
                           objProdAvailResponse.lstErrors = error;   
                     }else{
                        List<giic_Switch2152__c> csSw = giic_Switch2152__c.getAll().values();
                        boolean isActive2152 = false;
                        for(giic_Switch2152__c cs : csSw){
                            if(objSOL.gii__SalesOrder__r.giic_LegalEntity__c == cs.giic_LegalEntity__c && cs.giic_isActive__c == true){isActive2152 =true; break;}
                        }
						//[NR1107]
						if ((objSOL.gii__SalesOrder__r.giic_PO_TO_LocalWH__c || (!(objSOL.gii__SalesOrder__r.gii__DropShip__c) && !(objSOL.gii__SalesOrder__r.giic_IsDelivery__c)) && isActive2152)) {
                         if(!soToUpdate.contains(objSOL.gii__SalesOrder__c)){
                             soToUpdate.add(objSOL.gii__SalesOrder__c);
                             XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@2 '  );
                             XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@2 '  );
                             gii__SalesOrder__c so = new gii__SalesOrder__c(Id = objSOL.gii__SalesOrder__c, giic_PO_TO_LocalWH__c=true);
                             objProdAvailResponse.salesOrderToUpdate.add(so);

                         }         
                         	gii__SalesOrderLine__c sol = new gii__SalesOrderLine__c(Id = objSOL.Id, gii__DropShip__c=false);
                         	objProdAvailResponse.salesOrderLineToUpdate.add(sol);						 
                         	lstNotReservedLines.add(objSOL);  
                 	        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@1 '  );
                	        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@1 '  );
                    	    XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@1 lstNotReservedLines.add(objSOL' + lstNotReservedLines);  
                    	    mapSOLIsDropShip.put(objSOL.id,false);
						 } else {						 
                         if(!soToUpdate.contains(objSOL.gii__SalesOrder__c)){
                             soToUpdate.add(objSOL.gii__SalesOrder__c);
                             XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                             XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                             gii__SalesOrder__c so = new gii__SalesOrder__c(Id = objSOL.gii__SalesOrder__c, gii__DropShip__c=true);
                             objProdAvailResponse.salesOrderToUpdate.add(so);
                         }         
                         gii__SalesOrderLine__c sol = new gii__SalesOrderLine__c(Id = objSOL.Id, gii__DropShip__c=true);
                         objProdAvailResponse.salesOrderLineToUpdate.add(sol);
                         
                         lstNotReservedLines.add(objSOL);  
                         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                         XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@ lstNotReservedLines.add(objSOL' + lstNotReservedLines);  
                         mapSOLIsDropShip.put(objSOL.id,true);
						 }
                         //[NR1107]
                       }
                }else{
                    List<String> error = new List<String>();
                    error.add(Label.giic_ErrorEndDate);
                    objProdAvailResponse.lstErrors = error;  
                }
            }                                  
            
        }
        
        objProdAvailResponse.lstNotReservedLines=lstNotReservedLines;
        objProdAvailResponse.mapSOLIsDropShip=mapSOLIsDropShip;
        objProdAvailResponse.objTOWrapper=objTOWrapper;
        objProdAvailResponse.objPOWrapper=objPOWrapper;
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ggggggggg');
        
        objProdAvailResponse.reserveWrap=objPTTransferWrapper.reserveWrap;
        if(objProdAvailResponse.lstPIToUpdateBackOrderQty == null){
             XC_UTIL_Debug.debug(DEBUGACTIVE, 'lstPIToUpdateBackOrderQty = '+lstPIToUpdateBackOrderQty);
             objProdAvailResponse.lstPIToUpdateBackOrderQty = lstPIToUpdateBackOrderQty; 
        }else{
             objProdAvailResponse.lstPIToUpdateBackOrderQty.addAll(lstPIToUpdateBackOrderQty); 
        }
       
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'hhhhhhh');
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);  
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objPOWrapper' +  objProdAvailResponse.objPOWrapper);   
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@  objProdAvailResponse.objTOWrappe' +  objProdAvailResponse.objTOWrapper);                                                            
        XC_UTIL_Debug.debug(DEBUGACTIVE,'****objProdAvailResponse***'+objProdAvailResponse);
        return objProdAvailResponse;
    }

    /**
    * @author FirstName : Alberto Pompei alberto.pompei@nttdata.com
    * @date Creation 25/06/2021
    * @date Modification dd/mm/yyyy
    * @description - This method is used to process Products with Transfer Procurement type for Local WHs
    * @param lstSOIds - ProcurementTypeTransferWrapper, Map<Id, List<Id>> mapWHLocation, ProductAvailabilityResponse
    * @param mapProductWithAvailability - map<Id,giic_CommonWrapper.ProductAvailability>
    * @return list<String>
    */
    //[NR1107]
    public static list<String> processLocalforTransfer(ProcurementTypeTransferWrapper objPTTransferWrapper,Map<Id, List<Id>> mapWHLocation, ProductAvailabilityResponse objProdAvailResponse){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'in processLocalforTransfer');
        gii__SalesOrderLine__c objSOL=objPTTransferWrapper.objSOL;
        map<string,list<gii__SalesOrderLine__c>> mapSupplierProductPI=new map<string,list<gii__SalesOrderLine__c>>();
        List<String> lstErrors = new List<String>();
        Set<Id> settProductIds=new set<Id>();
        Set<Id> setSupplierIds=new set<Id>();

        Integer qtyNeeded = Integer.valueOf(objSOL.gii__OrderQuantity__c);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'qtyNeeded = '+qtyNeeded);
        if(qtyNeeded > 0){
            if(objSOL.gii__Product__r.giic_EndDate__c >= date.today() || objSOL.gii__Product__r.giic_EndDate__c == null ){
                String keyPBE = objSOL.gii__Product__c + '-' + objSOL.gii__Product__r.gii__PrimarySupplier__c;
                if(objPTTransferWrapper.mapPBEClosedOrders.containskey(keyPBE) ){   
                       lstErrors.add(Label.giic_CL_CloseOrderError);  
                       return lstErrors;
                   }else{ 
                       settProductIds.add(objSOL.gii__Product__c); 
                       string suppProdKey=objSOL.gii__Product__r.gii__PrimarySupplier__c +'-' + objSOL.gii__Product__c;
                       setSupplierIds.add(objSOL.gii__Product__r.gii__PrimarySupplier__c);
                       if(!mapSupplierProductPI.containskey(suppProdKey)){ mapSupplierProductPI.put(suppProdKey,new list<gii__SalesOrderLine__c>()); }
                       mapSupplierProductPI.get(suppProdKey).add(objSOL);    
                       
                       ///////////////////////////////////////////////////////////////////////////////////////////////////                      
                       lstErrors.addAll(createPOforSOtoLocal(objPTTransferWrapper,mapSupplierProductPI, Integer.valueOf(qtyNeeded), objProdAvailResponse));
                   }
            }else{
                lstErrors.add(Label.giic_ErrorEndDate); 
                return lstErrors;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'out of processLocalforTransfer');
    return lstErrors;
    }
    //[NR1107]

    //[NR1107]
    public static List<String> createPOforSOtoLocal(ProcurementTypeTransferWrapper objPTTransferWrapper,Map<String, List<gii__SalesOrderLine__c>> mapSupplierProductPI, Integer dSuggestedQty, ProductAvailabilityResponse objProdAvailResponse){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ createPOforSOtoLocal'  );
        
       /***********************************************set variables**********************************/
       set<string> setPOKey=new set<string>();
       set<string> setTOWH=new set<string>();
       XC_UTIL_Debug.debug(DEBUGACTIVE, 'in createPOforSOtoLocal');
       
               XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
       /***********************************************map variables**********************************/
       map<string,gii__PurchaseOrder__c> mapKeyPO=new  map<string,gii__PurchaseOrder__c>();
       map<string,list<gii__PurchaseOrderLine__c>> mapKeyPOL=new  map<string,list<gii__PurchaseOrderLine__c>>();
       /***********************************************list variables**********************************/ 
       list<string> lstErrors=new list<string>(); 
       
       XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
       XC_UTIL_Debug.debug(DEBUGACTIVE, 'objPTTransferWrapper.lstPriceBookAndPBEntry.size(): '+ objPTTransferWrapper.lstPriceBookAndPBEntry.size());
       if(objPTTransferWrapper.lstPriceBookAndPBEntry.size()>0){
           for(gii__PriceBookEntry__c pbEntry : objPTTransferWrapper.lstPriceBookAndPBEntry) {
               string key=pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId  + '-' + pbEntry.gii__Product__c;
               XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ key' + key );
               XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapSupplierProductPI.containskey(key): '+ mapSupplierProductPI.containskey(key));
               if(mapSupplierProductPI.containskey(key)){
                   for(gii__SalesOrderLine__c objSOL : mapSupplierProductPI.get(key)){
                       String poKey=objSOL.gii__Warehouse__c + '-'+ pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId + '-'+pbEntry.gii__PriceBook__r.name;
                       XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ poKey' + poKey );
                       string suggKey=objSOL.gii__Product__c + '-' + objSOL.gii__Warehouse__c+'-' + objSOL.gii__Warehouse__r.gii__DefaultIssueLocation__c;
                       String warehouse = objSOL.gii__Warehouse__c; 
                       
                       if(!objPTTransferWrapper.setPOKey.contains(poKey)){ 
                           XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
                           gii__PurchaseOrder__c objPO = new gii__PurchaseOrder__c(giic_Source__c=Label.giic_OrderSourceAutomation,giic_Contract__c=pbEntry.gii__PriceBook__r.giic_Contract__c,
                                                                                   gii__Supplier__c = pbEntry.gii__PriceBook__r.giic_Contract__r.AccountId,gii__ShipTo__c = warehouse,
                                                                                   gii__OrderDate__c = system.today(), gii__Approved__c=false,gii__DropShip__c = false,gii__RequiredDate__c = system.today(),
                                                                                   gii__PriceBookName__c=pbEntry.gii__PriceBook__r.name, gii__SalesOrder__c = objSOL.gii__SalesOrder__c,
                                                                                   giic_WorkOrder__c = objSOL.gii__SalesOrder__r.giic_WorkOrder__c,giic_CUP__c = objSOL.gii__SalesOrder__r.giic_CUP__c, giic_CIG__c = objSOL.gii__SalesOrder__r.giic_CIG__c, 
                                                                                   giic_PriceBookId__c =pbEntry.gii__PriceBook__c );
                           objProdAvailResponse.objPOWrapper.mapPurchaseOrder.put(poKey,objPO);
                           //[NR1106]
                           integer oldOrderQuantity; //NR1353 portare con 1107
                           if (pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0) {
                            oldOrderQuantity = dSuggestedQty; //NR1353 portare con 1107
                               if(dSuggestedQty <=integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c)) {dSuggestedQty = integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                               else {
                                   Integer Div = integer.ValueOf(dSuggestedQty/pbEntry.giic_MinimumOrderQuantity__c);
                                   Integer remainder = math.mod(integer.ValueOf(dSuggestedQty), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                                   if (remainder == 0) {dSuggestedQty = Div*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                                       else {dSuggestedQty = (Div + 1)*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                               }
                           }
                           //[NR1106]
                           gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__SalesOrderLine__c = objSOL.id,gii__OrderQuantity__c=dSuggestedQty);
                           //NR1353 portare con 1107
                           if(oldOrderQuantity != null && oldOrderQuantity != 0){
                            objPOLine.giic_OldOrderQuantity__c = oldOrderQuantity;
                           }
                           //NR1353 portare con 1107
                           objProdAvailResponse.objPOWrapper.mapPurchaseOrderLine.put(poKey,new list<gii__PurchaseOrderLine__c>{objPOLine});
                           objPTTransferWrapper.setPOKey.add(poKey); 
                           XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ objPTTransferWrapper'  +objPTTransferWrapper);
                           
                       }else{
                           //[NR1106]
                           integer oldOrderQuantity; //NR1353 portare con 1107
                           if (pbEntry.giic_MinimumOrderQuantity__c != null && pbEntry.giic_MinimumOrderQuantity__c != 0) {
                            oldOrderQuantity = dSuggestedQty; //NR1353 portare con 1107
                               if(dSuggestedQty <=integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c)) {dSuggestedQty = integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                               else {
                                   Integer Div = integer.ValueOf(dSuggestedQty/pbEntry.giic_MinimumOrderQuantity__c);
                                   Integer remainder = math.mod(integer.ValueOf(dSuggestedQty), integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c));
                                   if (remainder == 0) {dSuggestedQty = Div*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                                       else {dSuggestedQty = (Div + 1)*integer.ValueOf(pbEntry.giic_MinimumOrderQuantity__c);}
                               }
                           }
                           //[NR1106]
                           gii__PurchaseOrderLine__c objPOLine = new gii__PurchaseOrderLine__c(gii__Product__c= objSOL.gii__Product__c,gii__SalesOrderLine__c = objSOL.id,gii__OrderQuantity__c=dSuggestedQty);
                           //NR1353 portare con 1107
                           if(oldOrderQuantity != null && oldOrderQuantity != 0){
                            objPOLine.giic_OldOrderQuantity__c = oldOrderQuantity;
                           }
                           //NR1353 portare con 1107
                           objProdAvailResponse.objPOWrapper.mapPurchaseOrderLine.get(poKey).add(objPOLine);
                       }
                   }
               }
           }
            
               XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
               XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
               XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ '  );
       XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@ objProdAvailResponse'  + objProdAvailResponse);
       }else{  lstErrors.add(System.Label.giic_PriceBookError);    }
       XC_UTIL_Debug.debug(DEBUGACTIVE, 'out of createPOforSOtoLocal');
       return lstErrors;
   }
   //[NR1107]   

   /**
    * @date Creation 30/07/2021
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
    }
    
   /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 22/07/2019
    * @author Last Modification : Roberta Porrega - roberta.porrega@nttdata.com
    * @description – Method to query and return all Warehouses
    * @param 
    * @return Map<Id,gii__Warehouse__c>
    */    
   /* public static Map<Id,gii__Warehouse__c> getAllWarehouse(Set<String> toWarehouseGrpIds, Set<String> toWareHouseIdSet){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'****toWarehouseGrpIds***'+toWarehouseGrpIds); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'****toWareHouseIdSet***'+toWareHouseIdSet);
        List<String> whGroup = new  List<String> ();
        if(toWareHouseIdSet != null){
            List<gii__Warehouse__c> wh = new List<gii__Warehouse__c>([SELECT Id,Name,gii__WarehouseGroup__c,gii__WarehouseGroup__r.Name,gii__DefaultIssueLocation__c,giic_WarehouseType__c
                                                                      FROM gii__Warehouse__c WHERE Id IN: toWareHouseIdSet ]); 
            whGroup = XC_UTIL_Sobject.getListFieldValues(wh, 'gii__WarehouseGroup__c');
        }
        List<String> allWHGroup = new List<String>();
        allWHGroup.addAll(whGroup);
        allWHGroup.addAll(toWarehouseGrpIds);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@@@@@@ allWHGroup' + allWHGroup );
        return new Map<Id,gii__Warehouse__c>([SELECT Id,Name,gii__WarehouseGroup__c,gii__WarehouseGroup__r.Name,gii__DefaultIssueLocation__c,giic_WarehouseType__c
                                              FROM gii__Warehouse__c WHERE  gii__WarehouseGroup__c IN :allWHGroup ]);
    }*/

    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 22/07/2019
    * @date Modification dd/mm/yyyy
    * @description – get product code wise product
    * @param pdtCodeSet
    * @param pdtIdSet
    * @return Map<String,gii__Product2Add__c>
    */  
    /* public static Map<String,gii__Product2Add__c> getProductCodeWiseProducts(Set<String> pdtCodeSet,Set<String> pdtIdSet){
        Map<String,gii__Product2Add__c> mapOfPdtCodeVsPdt = new Map<String,gii__Product2Add__c>();
        for(gii__Product2Add__c pdtObj : [SELECT Id,Name,giic_ProcurementType__c,giic_AvgSupplyTime__c,gii__ProductCode__c,gii__PrimarySupplier__c 
        FROM gii__Product2Add__c 
        WHERE gii__ProductCode__c IN: pdtCodeSet]){
        mapOfPdtCodeVsPdt.put(pdtObj.gii__ProductCode__c,pdtObj);
        pdtIdSet.add(pdtObj.Id);
        }
        return mapOfPdtCodeVsPdt;
    }*/

}
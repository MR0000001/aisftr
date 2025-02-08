/** 
* @Author Roberta Porrega - roberta.porrega@nttdata.com 
* @Date Creation 02/09/2019
* @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 03/06/2020
* @Description XC_UTIL_Glovia - Class for integration with GLOVIA   
*/

public without sharing class XC_UTIL_Glovia {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Glovia');  

    /** @description AvailabilityResponseWrapper */
    public class AvailabilityResponseWrapper {                      
        public Boolean success = false;
        public String errorMessage = '';
        public Map<Date, List<String>> availabilityDate = new Map<Date, List<String>>();
        public Boolean isGenericTechProduct = false;
        public Boolean applyCoverageFilterInBooking = true;
    }

    /** @description AvailabilityWrapper */
    public class AvailabilityWrapper {
        public String zipCode;
        public String requestType;
        public String country;
        public List<String> partnerList;
        public Map<String, Decimal> mapProductCodeQuantity;
        public String engineCode;
        public WorkOrder wo;
        public String legalEntity;
        public String segment;
        public String fslKey;
    }

    //*************************************************************************************** CHECK AVAILABILITY FOR TECHNICAL PRODUCT:        
    
    /** 
    * @description Method calculate AvailabilityWrapper
    * @param recordId - Id
    * @param partnerList - List<String>
    * @return AvailabilityResponseWrapper
    */ 
    public static AvailabilityResponseWrapper getAvailabilityWrapper(Id recordId , List<String> partnerList) {
       List<WorkOrder> listOfWo = new List<WorkOrder>([
            SELECT Id, XC_ApplyCoverageFilterInBooking__c, XC_NumberWorkOrdersDI__c, XC_Conga_AssetProductName__c, XC_FSLAssignmentKey__c, XC_LegalEntity__c, XC_Segment__c, PostalCode, State, XC_AssignedPartner__c, XC_Configuration_Item__r.NE__ProdId__r.NE__Engine_Code__c,XC_Configuration_Item__r.NE__Qty__c,XC_Country__c,XC_Address__r.XC_AddressCountry__c ,
                (SELECT Id, Product2Id,Product2.ProductCode, ProductRequiredNumber,XC_Asset__r.SerialNumber, XC_Asset__c, XC_ProcurementType__c, QuantityRequired , XC_Mode__c, XC_OwnedByEnelX__c 
                FROM ProductsRequired 
                WHERE XC_Mode__c = 'Add'),
                (SELECT Id, XC_Conga_AssetProductName__c 
                FROM ChildWorkOrders
                WHERE XC_Conga_AssetProductName__c = 'Generic Technical Product')
            FROM WorkOrder
            WHERE Id = :recordId
        ]);
        WorkOrder wo = listOfWo[0];

        // Check for Generic Tech Product:
        if(wo.XC_Conga_AssetProductName__c == 'Generic Technical Product' || wo.ChildWorkOrders.size() == wo.XC_NumberWorkOrdersDI__c) {
            AvailabilityResponseWrapper availabilityWrapper = new AvailabilityResponseWrapper();
            availabilityWrapper.isGenericTechProduct = true;
            availabilityWrapper.success = true;
            availabilityWrapper.applyCoverageFilterInBooking = wo.XC_ApplyCoverageFilterInBooking__c;
            return availabilityWrapper;
        }

        Map<String, Decimal> mapProductRequiredQuantity = new Map<String, Decimal>();
        for(ProductRequired pr : wo.ProductsRequired){
            mapProductRequiredQuantity.put(pr.Product2.ProductCode, pr.QuantityRequired);   
        }   
        AvailabilityWrapper avWr = new AvailabilityWrapper();
        avWr.zipCode = wo.PostalCode; 
        avWr.fslKey = wo.XC_FSLAssignmentKey__c;
        avWr.requestType = 'Delivery Installation';
        avWr.mapProductCodeQuantity = mapProductRequiredQuantity ;
        avWr.partnerList =  partnerList; 
        avWr.country = wo.XC_Address__r.XC_AddressCountry__c ;
        avWr.wo = wo;
        avWr.legalEntity = wo.XC_LegalEntity__c;
        avWr.segment = wo.XC_Segment__c;
        AvailabilityResponseWrapper availabilityWrapper = checkAvailabilityDeliveryInstallation(avWr) ;
        return availabilityWrapper;
    }
    

    //**************************************************** CHECK AVAILABILITY FOR TECHNICAL PRODUCT REQUEST TYPE DELIVERY INSTALLATION:
    
    /** 
    * @description Method check availability for D&I
    * @param wrAvailab - AvailabilityWrapper
    * @return AvailabilityResponseWrapper
    */ 
    public static AvailabilityResponseWrapper checkAvailabilityDeliveryInstallation(AvailabilityWrapper wrAvailab){
        AvailabilityResponseWrapper responseWrapper = new AvailabilityResponseWrapper();
        List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper>();
        /* ## REWORK Glovia
        Map<Id, gii__Warehouse__c> warehouseMap = new  Map<Id, gii__Warehouse__c>([
            SELECT Id, gii__Account__c 
            FROM gii__Warehouse__c  
            WHERE gii__Account__c  IN :wrAvailab.partnerList
        ]);*/
        List<Id> whIds = getMapWarehouseCheckAvailability(wrAvailab.wo, wrAvailab.partnerList); 
        if(whIds.isEmpty()) {
            responseWrapper.success = false;
            responseWrapper.errorMessage = Label.XC_CL_ErrorBookWarehouse;
            return responseWrapper;
        }
        /* ## REWORK Glovia
        Map<Id, Id> mapPartnerIdWarehouseId = new Map<Id, Id>(); 
        if(!warehouseMap.isEmpty() && wrAvailab.partnerList != null){
            for(Id warehouseId : warehouseMap.keySet()){
                mapPartnerIdWarehouseId.put(warehouseMap.get(warehouseId).gii__Account__c, warehouseId);
            }
        }      
        List<String> whIds = new List<String>();
        for(String partner : wrAvailab.partnerList){
             if(mapPartnerIdWarehouseId.get(partner) != null){
                 whIds.add(mapPartnerIdWarehouseId.get(partner));
            }
        }
        List<String> whIds = new List<String>();
        for(Id warehouseId : mapWorkOrderIdWarehouseId.values()){
            whIds.add(warehouseId);
        }*/
        for(String prod : wrAvailab.mapProductCodeQuantity.keySet()){
            Giic_StockAvailabilityUtility.stockAvailabilityWrapper stoclAvailobjwrapper = new Giic_StockAvailabilityUtility.stockAvailabilityWrapper();
            stoclAvailobjwrapper.pdtCode = prod;
            stoclAvailobjwrapper.province = String.isBlank(wrAvailab.fslKey) ? '' : wrAvailab.fslKey.toUpperCase();
            stoclAvailobjwrapper.zipCode = wrAvailab.zipCode;
            stoclAvailobjwrapper.legalEntity = wrAvailab.legalEntity;
            stoclAvailobjwrapper.segment = wrAvailab.segment;
            stoclAvailobjwrapper.reqQuantity = wrAvailab.mapProductCodeQuantity.get(prod) ;
            stoclAvailobjwrapper.requestType = wrAvailab.requestType;
            stoclAvailobjwrapper.partnersWH = whIds ;
            stoclAvailobjwrapper.country = wrAvailab.country;
            stockAvailWrappList.add(stoclAvailobjwrapper);
        }
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> availabilityResult = Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        Map<Id, List<Date>> mapPartnerProductAvailability = new Map<Id,List<Date>>();
        Map<Id, gii__Warehouse__c> warehouseMap = new  Map<Id, gii__Warehouse__c>([
            SELECT Id, gii__Account__c 
            FROM gii__Warehouse__c  
            WHERE Id  IN :whIds
        ]);
        for(Giic_StockAvailabilityUtility.StockAvailabilityWrapper result : availabilityResult) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Availability Result: ' + result);
            if(!String.isBlank(result.errorMessage)){
                responseWrapper.errorMessage = result.errorMessage; 
                return responseWrapper;
            }
            /*if(result.toWarehouse == null || !warehouseMap.containsKey(result.toWarehouse) || String.isEmpty(warehouseMap.get(result.toWarehouse).gii__Account__c)){
                continue;
            }*/
            if(result.mapToWarehouseAvailabilityTime.keySet().isEmpty()){
                continue;
            }
            //mapToWarehouseAvailabilityTime: id(warehouseId) value(Date availability)
            //mi scorro i keyValue che sono tutti IdWarehouse
            // mi prendo l'account: warehouseMap.get(idWarehouse).gii__Account__c
            // e all'interno di mapPartnerProductAvailability metterò come key: l'accountId e come value metterò l'availability date
            //uscirò con una mappa che contiene nWarehouse con relativa availableDate
            for(String idWarehouse : result.mapToWarehouseAvailabilityTime.keySet() ){
                Id accPartnerId = warehouseMap.get(idWarehouse).gii__Account__c;
                Date availabilityDate = result.availabilityTime;
                List<Date> availabilityDateList = new List<Date>();
                availabilityDateList.add(availabilityDate);
                if(mapPartnerProductAvailability.containsKey(warehouseMap.get(idWarehouse).gii__Account__c)) {
                    availabilityDateList.addAll(mapPartnerProductAvailability.get(warehouseMap.get(idWarehouse).gii__Account__c));
                }
                mapPartnerProductAvailability.put(accPartnerId,availabilityDateList);
                
            }

            //a questo punto ci ritroviamo nelle ResourcePreference gli account glovia-compatibili

            /*if(!mapPartnerProductAvailability.containsKey(warehouseMap.get(result.toWarehouse).gii__Account__c)){
                mapPartnerProductAvailability.put(warehouseMap.get(result.toWarehouse).gii__Account__c, new List<Date>());
            }*/
            //mapPartnerProductAvailability.get(warehouseMap.get(result.toWarehouse).gii__Account__c).add(result.availabilityTime);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapPartnerProductAvailability: ' + mapPartnerProductAvailability);
        Map<Id, Date> mapPartnerBestProductAvailability = new Map<Id,Date>();
        for(String partnerID : mapPartnerProductAvailability.keySet()){
            for(Date bestDate : mapPartnerProductAvailability.get(partnerID)){
                Date avDate = mapPartnerBestProductAvailability.get(partnerID);
                if(bestDate > avDate){
                    mapPartnerBestProductAvailability.put(partnerID, avDate);
                }else {
                    mapPartnerBestProductAvailability.put(partnerID, bestDate);
                }
            }
        }   
        if(mapPartnerBestProductAvailability.isEmpty()){
            responseWrapper.errorMessage = Label.XC_CL_BookCustom_ErrorProductConf; 
            return responseWrapper;
        }
        responseWrapper.availabilityDate = getBestPartner(mapPartnerBestProductAvailability);
        responseWrapper.success = true;
        return  responseWrapper;
    }
    
    /** 
    * @description Method to get Available Plartner
    * @param mapPartnerBestProductAvailability - Map<Id, Date>
    * @return Map<Date, List<String>>
    */ 
    @testVisible
    private static Map<Date, List<String>> getBestPartner(Map<Id, Date> mapPartnerBestProductAvailability){
        Map<Date, List<String>> mapBestPartner = new Map<Date, List<String>>();
        Map<Date, List<String>> mapBestDatePartner = new Map<Date, List<String>>();
        for(String partnerID : mapPartnerBestProductAvailability.keySet()){
            Date dateAvailable = mapPartnerBestProductAvailability.get(partnerID);
            if( !mapBestPartner.containsKey(dateAvailable)  ){
                mapBestPartner.put(dateAvailable, new List<String>());
            }
            mapBestPartner.get(dateAvailable).add(partnerID);
        }  
        List<Date> dateList = new List<Date>();
        for(Date avDate : mapBestPartner.keySet()){
            dateList.add(avDate);
        }
        Date bestDate = XC_SC010_PopulateSkillsOnRes_U_Interval.calculateMinOfDates(dateList);
        mapBestDatePartner.put(bestDate, mapBestPartner.get(bestDate));
        
        return mapBestPartner;
    } 
    

    //****************************************************************************************** FROM ENGINE CODE TO TECHNICAL PRODUCT:

    /** 
    * @description Method to get Tech Product from Engine Code
    * @param engineCode - Map<String,Decimal>
    * @return Map<String, Map<String, Decimal>>
    */ 
    public static Map<String, Map<String, Decimal>> getTechnicalProductFromEngineCode(Map<String,Decimal> engineCode){
        Map<Id, NE__Product__c> mapCommercialProd = new Map<Id,NE__Product__c>([
            SELECT Id, Name, NE__Engine_Code__c  
            FROM NE__Product__c 
            WHERE NE__Engine_Code__c IN :engineCode.keySet()
        ]);
        Map<String, String> mapEngineCodeToCommercialProd = new Map<String, String> ();             
        for(NE__Product__c prod : mapCommercialProd.values()){
            String prodCommId = prod.Id;
            if(!mapEngineCodeToCommercialProd.containsKey(prodCommId)){
                mapEngineCodeToCommercialProd.put(prodCommId, prod.NE__Engine_Code__c);
            }
        }                        
        Map<Id, B2WExtCat__External_Catalog_Association__c>  mapProdExternalCatalog = new Map<Id, B2WExtCat__External_Catalog_Association__c>([
            SELECT Id,  Name, XC_TechnicalProduct__c,XC_TechnicalProduct__r.ProductCode,XC_Quantity__c, B2WExtCat__Commercial_Product__r.XC_LIC_Product_Name__c, B2WExtCat__Commercial_Product__c , B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c 
            FROM B2WExtCat__External_Catalog_Association__c  
            WHERE B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c IN :mapCommercialProd.keySet() OR B2WExtCat__Commercial_Product__c IN :mapCommercialProd.keySet() 
        ]);
        List<String> techProd = new List<String>();
        Map<String, Map<String, Decimal>> mapEngineCodeToTechnical = new Map<String, Map<String, Decimal>>();
        for(B2WExtCat__External_Catalog_Association__c extCat : mapProdExternalCatalog.values()){
            String prodId = (extCat.B2WExtCat__Commercial_Product__c !=null) ? extCat.B2WExtCat__Commercial_Product__c : extCat.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c;
            if(!mapEngineCodeToTechnical.containsKey(mapEngineCodeToCommercialProd.get(prodId))){
                mapEngineCodeToTechnical.put(mapEngineCodeToCommercialProd.get(prodId), new Map<String, Decimal>());
            } 
            mapEngineCodeToTechnical.get(mapEngineCodeToCommercialProd.get(prodId)).put(extCat.XC_TechnicalProduct__r.ProductCode, extCat.XC_Quantity__c); 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapEngineCodeToTechnical: ' + mapEngineCodeToTechnical);        
        return mapEngineCodeToTechnical;
    }
    
     
    //*********************************************************************************************** CHECK AVAILABILITY FROM API REST:
    
    /** 
    * @description Method to check Availability for Shipment
    * @param wrAvailab - RequestWrapper
    * @return Map<String, Date>
    */ 
    public static Map<String, Date> checkAvailabilityShipment(XC_REST_Product_U.RequestWrapper wrAvailab){
        List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper>();
        Map<Id, gii__Warehouse__c> warehouseMap  = new  Map<Id, gii__Warehouse__c>([
            SELECT Id, gii__Account__c 
            FROM gii__Warehouse__c  
            WHERE gii__Account__c = :wrAvailab.check_availability.partner_id 
        ]);
        Map<Id, Id> mapPartnerIdWarehouseId = new Map<Id, Id>(); 
        if(!warehouseMap.isEmpty() && wrAvailab.check_availability.partner_id != null){
            for(Id warehouseId : warehouseMap.keySet()){
                mapPartnerIdWarehouseId.put(warehouseMap.get(warehouseId).gii__Account__c, warehouseId);
            }
        }       
        Map<String,String > engineCodesRequestType = new Map<String,String>();
        Map<String,Decimal > engineCodes = new Map<String,Decimal>();
        for(XC_REST_Product_U.ProductWrapper productWr : wrAvailab.product){
             engineCodes.put(productWr.product_id, productWr.quantity);
             engineCodesRequestType.put(productWr.product_id, productWr.request_type);
        }
        Map<String, Map<String, Decimal>> mapEngineCodeTechnicalProduct =  getTechnicalProductFromEngineCode(engineCodes);
        List<availabilityWrapper> avWrList = new List<availabilityWrapper>();
         
        for(String engineCode : mapEngineCodeTechnicalProduct.keySet()){
            availabilityWrapper avWr = new availabilityWrapper();
            avWr.zipCode = wrAvailab.check_availability.customer_zip_code; // CHECKPROVINCE
            avWr.country = wrAvailab.check_availability.country;
            avWr.mapProductCodeQuantity = mapEngineCodeTechnicalProduct.get(engineCode);
            avWr.requestType = engineCodesRequestType.get(engineCode);
            avWr.engineCode = engineCode;
            avWrList.add(avWr);
        }
        for(availabilityWrapper av : avWrList){ 
            List<String> whID = new List<String>();
            if(!mapPartnerIdWarehouseId.isEmpty()){
                whID.add(mapPartnerIdWarehouseId.get(wrAvailab.check_availability.partner_id));
            }
            for(String prod : av.mapProductCodeQuantity.keySet()){
                Giic_StockAvailabilityUtility.stockAvailabilityWrapper stoclAvailobjwrapper = new Giic_StockAvailabilityUtility.stockAvailabilityWrapper();
                stoclAvailobjwrapper.pdtCode = prod;
                stoclAvailobjwrapper.zipCode = av.zipCode; // CHECKPROVINCE
                stoclAvailobjwrapper.reqQuantity = av.mapProductCodeQuantity.get(prod) ; 
                stoclAvailobjwrapper.requestType = av.requestType;
                stoclAvailobjwrapper.country = av.country; 
                stoclAvailobjwrapper.partnersWH = whID  ;
            
                stockAvailWrappList.add(stoclAvailobjwrapper);
            } 
        }
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> availabilityResult = Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        Map<String, Date> mapProductAvailability = new Map<String,Date>();
        Map<String, Date> mapEngineCodeAvailability = new Map<String,Date>();
        for(Giic_StockAvailabilityUtility.StockAvailabilityWrapper result : availabilityResult){
            if(!mapProductAvailability.containsKey(result.pdtCode)){
                mapProductAvailability.put(result.pdtCode, result.availabilityTime);
            }
        } 
        for(availabilityWrapper av : avWrList){
            List<Date> dateList = new List<Date>();
            for(String prod : av.mapProductCodeQuantity.keySet()){
            dateList.add(mapProductAvailability.get(prod));
            }
            Date bestDate = XC_SC010_PopulateSkillsOnRes_U_Interval.calculateMinOfDates(dateList);
            mapEngineCodeAvailability.put(av.engineCode, bestDate);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProductAvailability: ' + mapEngineCodeAvailability);
        return  mapEngineCodeAvailability;
    }
  
    //******************************************************************************************************************* UTIL METHODS:   

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 03/06/2020
     * @description Method to calculate a map for Multiple Warehouse
     * @param mapAccountProvinces - Map<String, List<String>>
     * @return Map<String, gii__Warehouse__c>
    */  
    public static Map<String, gii__Warehouse__c> getMapWarehouses(Map<String, List<String>> mapAccountProvinces) { 
        Map<String, gii__Warehouse__c> mapKeyWarehouseId = new Map<String, gii__Warehouse__c>();
        // Get Warehouses for input Accounts
        Map<Id, Account> listAccount = new Map<Id, Account>([
            SELECT Id,
                (SELECT Id, giic_ProvinceCoverage__c, gii__Account__c, gii__Account__r.Name, gii__WareHouseStreet__c, gii__WareHouseCity__c, gii__WareHouseStateProvince__c,
                gii__WareHouseZipPostalCode__c,giic_WareHouseCountryPick__c
                FROM gii__Warehouses__r)
            FROM Account
            WHERE Id IN :mapAccountProvinces.keySet()
        ]);

        // Populate map for provinces:
        for(String accountId : mapAccountProvinces.keySet()) {
            List<String> listInputProvince = mapAccountProvinces.get(accountId);
            List<gii__Warehouse__c> listWarehouse = listAccount.get(accountId).gii__Warehouses__r;
            for(gii__Warehouse__c wh : listWarehouse) {
                if(String.isBlank(wh.giic_ProvinceCoverage__c)) {
                    for(String inputProvince : listInputProvince) {
                        mapKeyWarehouseId.put(inputProvince+'_'+accountId, wh);
                    }
                }
                else {
                    List<String> listProvincesForWarehouse = wh.giic_ProvinceCoverage__c.split(';');
                    for(String inputProvince : listInputProvince) {
                        if(listProvincesForWarehouse.contains(inputProvince)) {
                            mapKeyWarehouseId.put(inputProvince+'_'+accountId, wh);
                            break;
                        }
                    }
                }
            }
        }
        return mapKeyWarehouseId;
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 03/06/2020
     * @description Method to calculate a map WorkOrder->Warehouse for check availability
     * @param wo - WorkOrder
     * @param listPartnerIds - List<String>
     * @return List<Id>
    */  
    @TestVisible
    private static List<Id> getMapWarehouseCheckAvailability(WorkOrder wo, List<String> listPartnerIds) { 
        List<Id> listWarehouse = new List<Id>();
        Map<String, List<String>> mapAccountProvinces = new Map<String, List<String>>();
        for(String partnerId : listPartnerIds) {
            if(!mapAccountProvinces.containsKey(partnerId)) {
                mapAccountProvinces.put(partnerId, new List<String>());
            }
            mapAccountProvinces.get(partnerId).add(wo.State);
        }
        if(mapAccountProvinces.isEmpty()) {
            return listWarehouse;
        }

        Map<String, gii__Warehouse__c> mapKeyWarehouse = getMapWarehousesByLegalEntity(mapAccountProvinces);
        for(gii__Warehouse__c wh : mapKeyWarehouse.values()) {
            if(wo.XC_LegalEntity__c == wh.giic_LegalEntity__c){
                listWarehouse.add(wh.Id);
            }
        }
        return listWarehouse;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 03/06/2020
     * @description Method to calculate a map WorkOrder->Warehouse
     * @param listWorkOrder - List<WorkOrder>
     * @return Map<Id, Id>
    */  
    public static Map<Id, Id> getMapWorkOrderWarehouse(List<WorkOrder> listWorkOrder) { 
        Map<Id, Id> mapWorkOrderIdWarehouseId = new Map<Id, Id>();
        Map<String, List<String>> mapAccountProvinces = new Map<String, List<String>>();
        for(WorkOrder wo : listWorkOrder) {
            if(!mapAccountProvinces.containsKey(wo.XC_AssignedPartner__c)) {
                mapAccountProvinces.put(wo.XC_AssignedPartner__c, new List<String>());
            }
            mapAccountProvinces.get(wo.XC_AssignedPartner__c).add(wo.State);
        }
        if(mapAccountProvinces.isEmpty()) {
            return mapWorkOrderIdWarehouseId;
        }

        Map<String, gii__Warehouse__c> mapKeyWarehouse = getMapWarehousesByLegalEntity(mapAccountProvinces);
        for(WorkOrder wo : listWorkOrder) {
            String key = wo.State + '_' + wo.XC_LegalEntity__c + '_' + wo.XC_AssignedPartner__c;
            if(mapKeyWarehouse.containsKey(key)) {
                Id warehouseId = mapKeyWarehouse.get(key).Id;
                mapWorkOrderIdWarehouseId.put(wo.Id, warehouseId);
            }
        }
        return mapWorkOrderIdWarehouseId;
    }

         
    /** 
    * @description Method to manage Contract information
    * @param contractList - List<Contract>
    * @param mapOld - Map<Id, Contract>
    * @param mapNew - Map<Id, Contract>
    */  
    public static void getCompanyNameByCompanyCode( List<Contract> contractList){
        List<String> companyCodeList = XC_UTIL_SObject.getListFieldValues( contractList, 'XC_CompanyCode__c');
        if(companyCodeList.isEmpty()){
            return;
        }
        List<XC_CM_LegalEntity_Configuration__mdt> mdtList = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id,XC_LegalEntity__c,XC_CompanyCode__c
            FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_CompanyCode__c IN :companyCodeList AND XC_isUsedByGlovia__c = true ]);
        
        if(mdtList.isEmpty()){
            return;
        }
        Map<String,String> mapCompanyCodeCompanyName = new Map<String,String>();
        for(XC_CM_LegalEntity_Configuration__mdt mdt : mdtList ){
            mapCompanyCodeCompanyName.put(mdt.XC_CompanyCode__c, mdt.XC_LegalEntity__c);
        }
        for(Contract c : contractList){
            if(c.recordTypeId == Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_ContractPartner').getRecordTypeId()){
                c.XC_CompanyCode__c = c.XC_CompanyCode__c == 'ES21' ? 'ES5R' : c.XC_CompanyCode__c;                
                c.XC_CompanyName__c = mapCompanyCodeCompanyName.get(c.XC_CompanyCode__c);
                c.XC_LegalEntity__c = mapCompanyCodeCompanyName.get(c.XC_CompanyCode__c);
                c.CurrencyIsoCode = c.XC_CurrencyKey__c != null ? c.XC_CurrencyKey__c : c.CurrencyIsoCode;      
            }
        }
    }
    
    /**
    * @description Method to update generic record
    * @param o - sObject
    * @return XC_UTIL_ResultWrapper
    */  
    public static XC_UTIL_ResultWrapper updateRecord(sObject o) { 
        List<sObject> recordsToUpdate = new List<sObject>();
        recordsToUpdate.add(o);
        return updateRecords(recordsToUpdate)[0];
    }
    
    /**
    * @description Method to update a list of generic record
    * @param updateRecords - List<sObject>
    * @return List<XC_UTIL_ResultWrapper>
    */  
    public static List<XC_UTIL_ResultWrapper> updateRecords(List<sObject> updateRecords) { 
        List<XC_UTIL_ResultWrapper> finalWrapperList = new List<XC_UTIL_ResultWrapper>();
        List<XC_UTIL_Sobject.WrapperResult> oldWrapperList = XC_UTIL_DML.updateRecords(updateRecords);
        for(XC_UTIL_Sobject.WrapperResult o : oldWrapperList){
            XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
            wr = new XC_UTIL_ResultWrapper(o);
            finalWrapperList.add(wr);
        }
        return finalWrapperList;
    }
    
    /**
    * @description Method to insert a list of generic record
    * @param updateRecords - List<sObject>
    * @return List<XC_UTIL_ResultWrapper>
    */  
    public static List<XC_UTIL_ResultWrapper> insertRecords(List<sObject> updateRecords) { 
        List<XC_UTIL_ResultWrapper> finalWrapperList = new List<XC_UTIL_ResultWrapper>();
        List<XC_UTIL_Sobject.WrapperResult> oldWrapperList = XC_UTIL_DML.insertRecords(updateRecords);
        for(XC_UTIL_Sobject.WrapperResult o : oldWrapperList){
            XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
            wr = new XC_UTIL_ResultWrapper(o);
            finalWrapperList.add(wr);
        }
        return finalWrapperList;
    }
    
    /**
    * @description Method to insert a list of generic record (with log error)
    * @param listToInsert - List<sObject>
    * @return List<XC_UTIL_ResultWrapper>
    */  
    public static List<XC_UTIL_Sobject.WrapperResult> insertAndLogError(List<sObject> listToInsert){
        List<Database.SaveResult> srList = Database.insert(listToInsert, false);
        return populateWrapperResultSuccessInsert(srList,listToInsert,true);
    }
     /**
    * @description Method to insert a list of generic record (without log error)
    * @param listToInsert - List<sObject>
    * @return List<XC_UTIL_ResultWrapper>
    */  
    public static List<XC_UTIL_Sobject.WrapperResult> insertAndDontLogError(List<sObject> listToInsert){
        List<Database.SaveResult> srList = Database.insert(listToInsert, false);
        return populateWrapperResultSuccessInsert(srList,listToInsert,false);
    }
    /**
    * @description Method to ipopulate Wrapper for Log Error
    * @param srList - List<Database.SaveResult>
    * @param listToUpdate - List<sObject>
    * @param logError - Boolean
    * @return List<XC_UTIL_ResultWrapper>
    */  
      public static List<XC_UTIL_Sobject.WrapperResult> populateWrapperResultSuccessInsert(List<Database.SaveResult> srList, List<sObject> listToUpdate, Boolean logError){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ populateWrapperResultSuccessInsert ENTER: ');
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<giic_ErrorLog__c> logToEventuallyInsert = new List<giic_ErrorLog__c>();
        for(Integer i=0;i<srList.size();i++){
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            if(!srList.get(i).isSuccess() || Test.isRunningTest() ) {
                List<String> listErrors = new List<String>();
                // Operation failed, so get all errors                
                for(Database.Error err : srList.get(i).getErrors()) {
                    listErrors.add(err.getMessage());     
                }
                wr.errorObjectId = listToUpdate.get(i).Id;
                wr.success = false;
                wr.errorMessage = String.join(listErrors, '; ');
                String objectName = '';
                String objectType = '';
                Map<String, Object> queriedFieldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(listToUpdate.get(i)));
               
                if(queriedFieldValues.containsKey('Name') && listToUpdate.get(i).get('Name')!= null){
                    objectName = String.valueOf(listToUpdate.get(i).get('Name'));
                }
                if(queriedFieldValues.containsKey('attributes')){
                     Map<String, Object> objectTypeMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(queriedFieldValues.get('attributes')));
                     objectType = JSON.serialize(objectTypeMap.get('type'));
                     XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ objectType: ' + objectType);
                }
                if(logError){
                        giic_ErrorLog__c objErr = new giic_ErrorLog__c(
                        Name = 'Error in insert ('+objectType+') :'+objectName,
                        giic_ClassMessage__c = 'XC_UTIL_Glovia',
                        giic_Process__c   = 'Insert',
                        giic_IntegrationWrapper__c = JSON.serialize(listToUpdate.get(i)),
                        giic_ErrorDescription__c = wr.errorMessage
                        );
                    logToEventuallyInsert.add(objErr);
                }
            }
            else { 
                wr.success = true;
                wr.recordId = srList.get(i).getId();
                wr.objectInfo = JSON.serialize(listToUpdate.get(i));
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully inserted or updated record-> ' + wr);
            }
            wrapperList.add(wr);
        }
        if(logError){
            insert logToEventuallyInsert;
        }
        return wrapperList;
    }


    /**
     * @author dpalamides
     * @date 03/06/2020
     * @description Method to calculate a map for Multiple Warehouse
     * @param mapAccountProvinces - Map<String, List<String>>
     * @return Map<String, gii__Warehouse__c>
    */
    public static Map<String, gii__Warehouse__c> getMapWarehousesB2B(Map<String, List<String>> mapAccountProvinces) {
        Map<String, gii__Warehouse__c> mapKeyWarehouseId = new Map<String, gii__Warehouse__c>();
        // Get Warehouses for input Accounts
        Map<Id, Account> listAccount = new Map<Id, Account>([
                SELECT Id,
                (SELECT Id, giic_ProvinceCoverage__c, gii__Account__c, gii__Account__r.Name, gii__WareHouseStreet__c, gii__WareHouseCity__c, gii__WareHouseStateProvince__c,
                        gii__WareHouseZipPostalCode__c,giic_WareHouseCountryPick__c,giic_WarehouseType__c
                FROM gii__Warehouses__r)
                FROM Account
                WHERE Id IN :mapAccountProvinces.keySet()
        ]);

        // Populate map for provinces:
        for(String accountId : mapAccountProvinces.keySet()) {
            List<String> listInputProvince = mapAccountProvinces.get(accountId);
            List<gii__Warehouse__c> listWarehouse = listAccount.get(accountId).gii__Warehouses__r;
            
            for(gii__Warehouse__c wh : listWarehouse) {
                if(wh.giic_WarehouseType__c != 'Local' && wh.giic_WarehouseType__c != 'Central'){
                    continue;
                }
                if(String.isBlank(wh.giic_ProvinceCoverage__c)) {
                    for(String inputProvince : listInputProvince) {
                        mapKeyWarehouseId.put(inputProvince+'_'+accountId, wh);
                    }
                }
                else {
                    List<String> listProvincesForWarehouse = wh.giic_ProvinceCoverage__c.split(';');
                    for(String inputProvince : listInputProvince) {
                        if(listProvincesForWarehouse.contains(inputProvince)) {
                            mapKeyWarehouseId.put(inputProvince+'_'+accountId, wh);
                            break;
                        }
                    }
                }
            }
        }
        return mapKeyWarehouseId;
    }
  
    
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @date 29/01/2021
     * @description Method to calculate a map for Multiple Warehouse using the legal entity to create the key
     * @param mapAccountProvinces - Map<String, List<String>>
     * @return Map<String, gii__Warehouse__c>
    */  
    public static Map<String, gii__Warehouse__c> getMapWarehousesByLegalEntity(Map<String, List<String>> mapAccountProvinces) { 
        Map<String, gii__Warehouse__c> mapKeyWarehouseId = new Map<String, gii__Warehouse__c>();
        // Get Warehouses for input Accounts
        Map<Id, Account> listAccount = new Map<Id, Account>([
            SELECT Id,
                (SELECT Id, giic_ProvinceCoverage__c, gii__Account__c, gii__Account__r.Name, gii__WareHouseStreet__c, gii__WareHouseCity__c, gii__WareHouseStateProvince__c,
                gii__WareHouseZipPostalCode__c,giic_WareHouseCountryPick__c, giic_LegalEntity__c
                FROM gii__Warehouses__r)
            FROM Account
            WHERE Id IN :mapAccountProvinces.keySet()
        ]);

        // Populate map for provinces:
        for(String accountId : mapAccountProvinces.keySet()) {
            List<String> listInputProvince = mapAccountProvinces.get(accountId);
            List<gii__Warehouse__c> listWarehouse = listAccount.get(accountId).gii__Warehouses__r;
            for(gii__Warehouse__c wh : listWarehouse) { 
                if(String.isBlank(wh.giic_ProvinceCoverage__c)) { 
                    for(String inputProvince : listInputProvince) {
                        mapKeyWarehouseId.put(inputProvince+'_' + wh.giic_LegalEntity__c + '_' +accountId, wh);
                    }
                }
                else {
                    List<String> listProvincesForWarehouse = wh.giic_ProvinceCoverage__c.split(';');
                    for(String inputProvince : listInputProvince) {
                        if(listProvincesForWarehouse.contains(inputProvince)) {
                            mapKeyWarehouseId.put(inputProvince+'_'+ wh.giic_LegalEntity__c + '_' + accountId, wh);
                            break;
                        }
                    }
                }
            }
        }
        return mapKeyWarehouseId;
    }
}
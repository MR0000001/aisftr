/**
* @author dpalamides
* @date 07/08/2020
* @description classes.XC_UTIL_WOLICreateRMA
*/


public without sharing class XC_UTIL_WOLICreateRMA {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WOCreateRMA');

    public static XC_UTIL_ResultWrapper createRMAGlovia (List<WorkOrderLineItem> woliList){

        XC_UTIL_ResultWrapper resWrapper = new  XC_UTIL_ResultWrapper();
        try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
            wrapper.listWOLI = woliList;
            wrapper.operation = 'createRMAGloviaB2B';
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);

            /*List<XC_UTIL_TechnicalCart.paramToGloviaSoli> wrapperToGloviaSoli= new List<XC_UTIL_TechnicalCart.paramToGloviaSoli>();
            wrapperToGloviaSoli = XC_UTIL_TechnicalCart.setSendGlovia(wrapperToGloviaSoli,inputWrapper.listProductRequired,inputWrapper.pRGlovia);
            system.debug('@@@@ getAllProductRequired - wrapperToGlovia:' + wrapperToGloviaSoli);
            system.debug('@@@@ getAllProductRequired - inputWrapper.wrapperToGloviaSO:' + inputWrapper.wrapperToGloviaSO);
            resWrapper = XC_UTIL_TechnicalCart.CreateSOSOLIGlovia(wrapperToGloviaSoli,inputWrapper.wrapperToGloviaSO, inputWrapper.listProductRequired);
            */

            resWrapper.success = response.success;
            resWrapper.resultMessage = response.message;
        }
        catch(Exception e){
            System.debug( '@@@@ XC_UTIL_TehcnicalCart - generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        return resWrapper;
    }
    /**
    * @description create RMA
    * @param listNew the list new
    */
    public static List<XC_UTIL_Sobject.WrapperResult> createRMA(List<WorkOrderLineItem> listNew){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = new List<XC_UTIL_Sobject.WrapperResult>();

        XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
        List<String> listPartnerIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_AccountId__c');
        if(listPartnerIds.isEmpty()){
            wrapperResult.success = false;
            wrapperResult.errorMessage = 'XC_UTIL_WOLICreateRMA - No Assigned Partner related to WOLI.';
            wrapperResultList.add(wrapperResult);
            return wrapperResultList;
        }
        List<Id> listWOLIIds = XC_UTIL_Sobject.getIds(listNew);
        Map<Id, WorkOrderLineItem> mapWOLI = getWorkOrderLineItem(listWOLIIds);

        Map<Id, Id> mapWorkOrderIdWarehouseId = new Map<Id, Id>();
        Map<String, List<String>> mapAccountProvinces = new Map<String, List<String>>();
        for(WorkOrderLineItem woli : mapWOLI.values()) {
            if(!mapAccountProvinces.containsKey(woli.XC_AccountId__c)) {
                mapAccountProvinces.put(woli.XC_AccountId__c, new List<String>());
            }
            mapAccountProvinces.get(woli.XC_AccountId__c).add(woli.workOrder.State);
        }

        Map<String, gii__Warehouse__c> mapPartnerIdWarehouseId = XC_UTIL_Glovia.getMapWarehousesB2B(mapAccountProvinces);


        Map<Id, List<XC_ProductConsumed__c>> mapWOLIConsumedToReturn = new Map<Id, List<XC_ProductConsumed__c>>();
        List<String> product2 = new List<String>();
        if(!mapWOLI.values().isEmpty()){
            for(Id woliId : mapWOLI.keySet()){
                for (XC_ProductConsumed__c pr : mapWOLI.get(woliId).Products_Consumed__r){
                    product2.add(pr.XC_Product2Id__C);
                }
            }
            if(product2.isEmpty()){
                wrapperResult.success = false;
                wrapperResult.errorMessage = 'XC_UTIL_WOLICreateRMA - No Required Product to precess.';
                wrapperResultList.add(wrapperResult);
                return wrapperResultList;
            }
            Map<Id,gii__Product2Add__c> prGloviaMap =  getGloviaProduct(product2);
            if(prGloviaMap.values().isEmpty()){
                wrapperResult.success = false;
                wrapperResult.errorMessage = 'XC_UTIL_WOLICreateRMA - No Product Reference to precess.';
                wrapperResultList.add(wrapperResult);
                return wrapperResultList;
            }
            Map<Id,gii__Product2Add__c> product2ToGlovia = getProduct2ToGlovia(prGloviaMap.values());
            List<WorkOrderLineItem> woliNewList = new List<WorkOrderLineItem>();
            List<Giic_CommonWrapper.RMAHeader> rmaList = new List<Giic_CommonWrapper.RMAHeader>();

            Map<String, Id> mapSerialNumberID =  getSerialProductID(mapWOLI.values());
            for(WorkOrderLineItem woli : mapWOLI.values()){
                Giic_CommonWrapper.RMAHeader objRMA = new Giic_CommonWrapper.RMAHeader();
                String key = woli.workOrder.State+'_'+woli.XC_AccountId__c;
                if(!mapPartnerIdWarehouseId.containsKey(key)){
                    continue;
                }
                objRMA.accountId = woli.XC_AccountId__c; 
                
                if(woli.XC_WarehouseId__c == null && woli.WorkOrder.XC_Country__c == 'Italy'){
                    wrapperResult.success = false;
                    wrapperResult.errorMessage = Label.XC_CL_SelectWarehouseError;
                    wrapperResultList.add(wrapperResult);
                    return wrapperResultList;
                }
                
                objRMA.warehouseId = woli.XC_WarehouseId__c != null ? woli.XC_WarehouseId__c : mapPartnerIdWarehouseId.get(key).Id;
                objRMA.workOrderId = null;//woli.WorkOrderId;
                objRMA.workOrderLineItemId = woli.Id;
                objRMA.CurrencyIsoCode = woli.CurrencyIsoCode;
                objRMA.reason ='Other'; // TODO possibili valori:  Damaged, Incorrect Shipment, Bad Quality, Other
                objRMA.rMADate = Date.today();
                objRMA.accountName  = mapPartnerIdWarehouseId.get(key).gii__Account__r.Name ;
                objRMA.street = mapPartnerIdWarehouseId.get(key).gii__WareHouseStreet__c;
                objRMA.city = mapPartnerIdWarehouseId.get(key).gii__WareHouseCity__c;
                objRMA.stateProvince = mapPartnerIdWarehouseId.get(key).gii__WareHouseStateProvince__c;
                objRMA.zipPostalCode = mapPartnerIdWarehouseId.get(key).gii__WareHouseZipPostalCode__c;
                objRMA.country = mapPartnerIdWarehouseId.get(key).giic_WareHouseCountryPick__c;
                objRMA.RMALines = new  List<Giic_CommonWrapper.RmaLine> ();
                objRMA.RMALines.addAll(getRMALines( woli, mapSerialNumberID ,  product2ToGlovia ));
                rmaList.add(objRMA);
                WorkOrderLineItem woNew = new WorkOrderLineItem();
                woNew.Id = woli.Id;
                woNew.Status = 'Completed';
                // woNew.XC_SentGoodIssue__c = true; // SS 17/06/2020
                woliNewList.add(woNew);
            }
            System.debug('rmaList§§ '+rmaList);
            Giic_CommonWrapper.RMAResponse responseRMA = Giic_RMAUtility.createRMAs(rmaList);
            System.debug('responseRMA§§ '+responseRMA);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WOLICreateRMA-responseRMA:' + responseRMA);
            if(responseRMA.isSuccess != null && responseRMA.isSuccess){
                wrapperResultList = XC_UTIL_Sobject.updateListRecords(woliNewList);
                //[Begin - NR2357 - 07/04/2022 - DK - ET - if wrapperResult is success continue with updating the form cases
                if(wrapperResultList[0].success){
                    List<XC_FormCase__c> formCases = [SELECT Id, XC_Product_Consumed__r.XC_Product2Id__c FROM XC_FormCase__c WHERE XC_Return_Material__c=: wrapperResultList[0].recordId];
                    List<gii__RMADetail__c> rmaLines = [SELECT Id, gii__Product__r.gii__ProductReference__c FROM gii__RMADetail__c WHERE gii__RMA__c =: responseRMA.RMAId];
                    Map<String, String> productRMAmap = new Map<String,String>();
                    
                    for(gii__RMADetail__c rmal : rmaLines){
                        productRMAmap.put(rmal.gii__Product__r.gii__ProductReference__c, rmal.Id);
                    }

                    for(XC_FormCase__c form : formCases){
                        form.XC_Glovia_RMA__c = responseRMA.RMAId;
                        form.XC_RMA_Line__c = productRMAmap.get(form.XC_Product_Consumed__r.XC_Product2Id__c);
                    }
                    update formCases;
                }
                //[End - NR2357 - 04/04/2022 - DK - ET - if wrapperResult is success continue with updating the form cases
            } else {
                wrapperResult.success = false;
                if(!responseRMA.errorList.isEmpty() &&  responseRMA.errorList[0].containsKey('ErrorMsg')){
                    wrapperResult.errorMessage = responseRMA.errorList[0].get('ErrorMsg');
                }
                wrapperResultList.add(wrapperResult);
            }
        }else{
            wrapperResult.success = false;
            wrapperResult.errorMessage = 'XC_UTIL_WOLICreateRMA - No Work Order to precess.';
            wrapperResultList.add(wrapperResult);
            return wrapperResultList;
        }
        return wrapperResultList;
    }


    /**
    * @description getWorkOrderLineItem
    * @param listWorkOrderIds the list new
    * @return Map<Id,WorkOrder>
    */
    private static Map<Id, WorkOrderLineItem> getWorkOrderLineItem(List<Id> listWOLIIds){
        Map<Id, WorkOrderLineItem> mapWOLI = new Map<Id, WorkOrderLineItem>(
        [SELECT Id,XC_AccountId__c,workOrderId, CurrencyIsoCode,WorkOrder.XC_AssignedPartner__c,WorkOrder.XC_PreferredPartner__c,workOrder.AccountId,workOrder.WorkOrderNumber,Asset.XC_Warranty_End_Date__c, WorkOrder.State,XC_WarehouseId__c,WorkOrder.XC_Country__c,
        (SELECT Id, Product2Id,ProductRequiredNumber, XC_ProcurementType__c, XC_Asset__r.SerialNumber,QuantityRequired , XC_Mode__c, XC_OwnedByEnelX__c
        FROM ProductsRequired
        WHERE XC_Mode__c = 'Remove' ),
        (select id,XC_QuantityConsumed__c, XC_Product2Id__c, XC_SerialNumber__c, TAM_Asset__c, TAM_Asset__r.SerialNumber, TAM_Asset__r.Product2Id, TAM_Asset__r.TAM_IsTechnical__c, XC_ProductRequired__c
        from Products_Consumed__r)
        FROM WorkOrderLineItem
        WHERE Id IN: listWOLIIds]
        );
        return mapWOLI;
    }

    /**
    * @description getGloviaProduct
    * @param product2 the list new
    * @return Map<Id,gii__Product2Add__c>
    */
    private static  Map<Id,gii__Product2Add__c> getGloviaProduct(List<String> product2){
        Map<Id,gii__Product2Add__c> prGloviaMap = new Map<Id,gii__Product2Add__c>([
                SELECT Id, gii__ProductReference__c,gii__SerialControlled__c
                FROM gii__Product2Add__c
                WHERE gii__ProductReference__c IN : product2]
        );
        return prGloviaMap;
    }

    /**
    * @description getProduct2ToGlovia
    * @param prGloviaMap the list new
    * @return Map<Id,gii__Product2Add__c>
    */
    private static  Map<Id,gii__Product2Add__c> getProduct2ToGlovia(List<gii__Product2Add__c> prGloviaMap){
        Map<Id,gii__Product2Add__c> product2ToGlovia =  new  Map<Id,gii__Product2Add__c>();
        if(!prGloviaMap.isEmpty()){
            for(gii__Product2Add__c pr : prGloviaMap){
                product2ToGlovia.put(pr.gii__ProductReference__c, pr);
            }
        }
        return product2ToGlovia;
    }

    /**
    * @description getProduct2ToGlovia
    * @param wo the list new
    * @return Map<String,Id>
    */
    private static Map<String, Id> getSerialProductID(List<WorkOrderLineItem> woliList){
        List<String> serialNumbers = new List<String>();
        Map<String, Id> mapSerialNumberIds = new  Map<String, Id>();
        List<String> parterAssigned = new List<String>();
        for(WorkOrderLineItem woli : woliList){
            parterAssigned.add(woli.XC_AccountId__c);
            for(XC_ProductConsumed__c pc : woli.Products_Consumed__r ){
                /*
                if(pc.TAM_Asset__r != null){
                    serialNumbers.add(pc.TAM_Asset__r.SerialNumber);
                }*/
                string serialpc = pc.TAM_Asset__r != null ? pc.TAM_Asset__r.SerialNumber : pc.XC_SerialNumber__c;
                serialNumbers.add(serialpc);
            }
        }
        List<gii__ProductSerial__c> prodSerial = new List<gii__ProductSerial__c>([
                SELECT Id, Name FROM gii__ProductSerial__c
                WHERE  Name IN :serialNumbers]);

        for(gii__ProductSerial__c ps : prodSerial){
            mapSerialNumberIds.put(ps.Name , ps.Id);
        }
        return mapSerialNumberIds;
    }
    /**
    * @description getRMALines
    * @param wo the list new
    * @param product2ToGlovia
    * @return List<Giic_CommonWrapper.RmaLine>
    */
    private static List<Giic_CommonWrapper.RmaLine> getRMALines( WorkOrderLineItem woli,  Map<String, Id> mapSerialNumberID , Map<Id,gii__Product2Add__c> product2ToGlovia ){
        List<Giic_CommonWrapper.RmaLine> rmaLines = new List<Giic_CommonWrapper.RmaLine>();
        for(XC_ProductConsumed__c pc :  woli.Products_Consumed__r){
            Giic_CommonWrapper.RmaLine objRMALine = new Giic_CommonWrapper.RmaLine();
            objRMALine.rmaQuantity = pc.XC_QuantityConsumed__c;
            objRMALine.productId = product2ToGlovia.get(pc.XC_Product2Id__C).Id;
            if(product2ToGlovia.get(pc.XC_Product2Id__C).gii__SerialControlled__c ) {
                //objRMALine.productSerialId = mapSerialNumberID.get(pc.TAM_Asset__r.SerialNumber) ;
                string serialpc = pc.TAM_Asset__r != null ? pc.TAM_Asset__r.SerialNumber : pc.XC_SerialNumber__c;
                objRMALine.productSerialId = mapSerialNumberID.get(serialpc) ;
            }else{
                objRMALine.productSerialId = null;
            }
            if(System.today() < woli.Asset.XC_Warranty_End_Date__c ) {
                objRMALine.underWarranty = true;
            }else{
                objRMALine.underWarranty = false;
            }
            rmaLines.add(objRMALine);
        }
        return rmaLines;
    }
}
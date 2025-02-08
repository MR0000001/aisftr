/** 
* @Author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @Date Creation 04/06/2020
* @Description XC_REST_FSLLogistic - Class REST for Field Service
*/

@RestResource(urlMapping='/v1/FSLLogistic/*')
global with sharing class XC_REST_FSLLogistic {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_REST_FSLLogistic');
 
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 04/06/2020
    * @description POST method for Field Service objects
    */
    @HttpPost
    global static void doPost() {
        try {
            Map<String, String> mapHeader = RestContext.request.headers;
            String jsonWrapper;
            if(Test.isRunningTest()) {
                jsonWrapper = EncodingUtil.base64Decode(RestContext.request.params.toString().replace('{','').replace('}','').replace('InputSelfCallout=','')).toString();

            } else {
                jsonWrapper = EncodingUtil.base64Decode(RestContext.request.params.toString().replace('{','').replace('}','')).toString();
            }
            XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper = (XC_UTIL_FSLLogistic.InputSelfCallout) JSON.deserialize(jsonWrapper, XC_UTIL_FSLLogistic.InputSelfCallout.class);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Input Wrapper ->' + inputWrapper);
            XC_UTIL_Sobject.WrapperResult responseWrapper = new XC_UTIL_Sobject.WrapperResult();
            XC_UTIL_FSLLogistic.OutputSelfCallout outputWrapper = new XC_UTIL_FSLLogistic.OutputSelfCallout();

            switch on inputWrapper.operation {
                when 'createSalesOrderFromConfig' {
                    giic_CommonWrapper.OrderResponse responseWrapperOrder = new giic_CommonWrapper.OrderResponse();
                    if(!Test.isRunningTest()) {
                        responseWrapperOrder = XC_UTIL_WOCreateSalesOrder.createSalesOrderFromConfig(inputWrapper.recordID);
                    }
                    outputWrapper.errorMessageList = responseWrapperOrder.errorMessages;
                    outputWrapper.lstProductAvailability = responseWrapperOrder.lstProductAvailability;
                }
                when 'createSalesOrder'{
                    if(!Test.isRunningTest()) {
                        responseWrapper = XC_UTIL_WOCreateSalesOrder.createSalesOrder(inputWrapper.listWorkOrder);
                    }
                    outputWrapper.wrapperResult = responseWrapper;
                }
                when 'createSalesOrderDelivery'{
                    if(!Test.isRunningTest()) {
                        responseWrapper = XC_UTIL_WOCreateSalesOrder.createSalesOrderDelivery(inputWrapper.recordID);
                    }
                    outputWrapper.wrapperResult = responseWrapper;
                }
                when 'checkAvailability'{
                    XC_UTIL_EligibleServiceResource.EligibleWrapper eligibleWrapper = new XC_UTIL_EligibleServiceResource.EligibleWrapper();
                    if(!Test.isRunningTest()) {
                        eligibleWrapper = XC_UTIL_EligibleServiceResource.checkAvailability(inputWrapper.workOrderId, inputWrapper.zipCode, inputWrapper.workTypeId, inputWrapper.currentUserPartnerId, inputWrapper.applyCoverageFilterInBooking);
                    }
                    outputWrapper.eligibleWrapper = eligibleWrapper;
                }
                when 'getGloviaProductMapping'{
                    Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> resultData = new Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>>();
                    if(!Test.isRunningTest()) {
                        resultData = XC_UTIL_TechnicalCart.retrieveProductFromGlovia(inputWrapper);
                    }
                    if(resultData != null && !resultData.isEmpty()){
                        if(resultData.get('materialProducts') != null && !resultData.get('materialProducts').isEmpty()){
                            outputWrapper.gloviaMaterialProduct = resultData.get('materialProducts');
                        }
                        if(resultData.get('serviceProducts') != null && !resultData.get('serviceProducts').isEmpty()){
                            outputWrapper.gloviaServiceProduct = resultData.get('serviceProducts');
                        }
                    }
                }
                when 'getProductReferenceMapping'{
                    Map<id,gii__Product2Add__c> prGlovia = new  Map<id,gii__Product2Add__c>([SELECT id,gii__ProductReference__c FROM gii__Product2Add__c where gii__ProductReference__c in :inputWrapper.productReferenceId]);
                    List<XC_UTIL_FSLLogistic.GloviaProduct> gloviaProdWR = new List<XC_UTIL_FSLLogistic.GloviaProduct>();
                    if(!prGlovia.isEmpty()){
                        for(gii__Product2Add__c p : prGlovia.values()){
                            XC_UTIL_FSLLogistic.GloviaProduct pWR = new XC_UTIL_FSLLogistic.GloviaProduct();
                            pWR.productReference = p.gii__ProductReference__c;
                            pWR.id = p.id;
                            gloviaProdWR.add(pWR);
                        }
                        outputWrapper.gloviaProductReference = gloviaProdWR;

                    }
                }
                when 'createSalesOrdersB2B'{
                    List<XC_UTIL_TechnicalCart.paramToGloviaSoli> wrapperToGloviaSoli= new List<XC_UTIL_TechnicalCart.paramToGloviaSoli>();
                    wrapperToGloviaSoli = XC_UTIL_TechnicalCart.setSendGlovia(wrapperToGloviaSoli,inputWrapper.listProductRequired,inputWrapper.pRGlovia);
                    system.debug('@@@@ getAllProductRequired - wrapperToGlovia:' + wrapperToGloviaSoli);
                    system.debug('@@@@ getAllProductRequired - inputWrapper.wrapperToGloviaSO:' + inputWrapper.wrapperToGloviaSO);
                    XC_UTIL_ResultWrapper rAndM = XC_UTIL_TechnicalCart.CreateSOSOLIGlovia(wrapperToGloviaSoli,inputWrapper.wrapperToGloviaSO, inputWrapper.listProductRequired);
                    outputWrapper.resultWrapperUtil =rAndM;
                    System.debug('Donato' +rAndM);
                }
                when 'createGoodsIssueGlovia'{
                    System.debug('** entra');
                    Giic_GoodsIssueSO.OrderGoodsIssuedResponse goodsIssueResponse = Giic_GoodsIssueSO.createGoodsIssue(inputWrapper.wrapperToGloviaGoodIssueSO);
                    System.debug('createGoodsIssueGlovia'+ goodsIssueResponse);
                    outputWrapper.success = goodsIssueResponse.isSuccess;
                    if(goodsIssueResponse.errorList!=null && !goodsIssueResponse.errorList.isEmpty()){
                        outputWrapper.message = String.valueOf(goodsIssueResponse.errorList[0].errorMsg);
                        outputWrapper.errorMessageList.add(String.valueOf(goodsIssueResponse.listProductErrors));
                        System.debug('**' + String.valueOf(goodsIssueResponse.listProductErrors));
                        System.debug('**' + outputWrapper.errorMessageList);
                    }

                }
                when 'createRMAGloviaB2B'{
                    List<XC_UTIL_Sobject.WrapperResult> retValues = XC_UTIL_WOLICreateRMA.createRMA(inputWrapper.listWOLI);
                    outputWrapper.success = true;
                    for(XC_UTIL_Sobject.WrapperResult res : retValues){
                        if(!res.success){
                            outputWrapper.success = false;
                            outputWrapper.message = res.errorMessage;

                        }
                    }

                }
                when 'getMapWorkOrderLineItemWarehouse'{
                    Map<Id, Id> mapWorkOrderIdWarehouseId = new Map<Id, Id>();
                    Map<String, List<String>> mapAccountProvinces = new Map<String, List<String>>();
                    List<WorkOrderLineItem> woliList = [select id, XC_AccountId__c, workOrder.XC_Address__r.XC_Region__c, workOrder.XC_LegalEntity__c,XC_WOLIType__c, workOrder.state
                                                        from WorkOrderLineItem
                                                        where id in :XC_UTIL_Sobject.getIds(inputWrapper.listWOLI)];
                    List<String> leList = new List<String>();
                    for(WorkOrderLineItem w : woliList){
                        leList.add(w.workOrder.XC_LegalEntity__c);
                    }
                    Map<String,String> virtualWH = XC_UTIL_TechnicalCart.getVirtualWarehousesMap(leList);
                    for(WorkOrderLineItem woli : woliList) {
                        if(woli.XC_AccountId__c!=null && woli.workOrder.state!=null) {
                            if (!mapAccountProvinces.containsKey(woli.XC_AccountId__c)) {
                                mapAccountProvinces.put(woli.XC_AccountId__c, new List<String>());
                            }
                            mapAccountProvinces.get(woli.XC_AccountId__c).add(woli.workOrder.state);
                        }
                    }
                    if(mapAccountProvinces.isEmpty()) {
                        outputWrapper.mapWorkOrderIdWarehouseId=mapWorkOrderIdWarehouseId ;
                    }

                    Map<String, gii__Warehouse__c> mapKeyWarehouse = XC_UTIL_Glovia.getMapWarehousesB2B(mapAccountProvinces);
                    for(WorkOrderLineItem woli : woliList) {
                        if(woli.XC_WOLIType__c == 'Delivery'){
                            mapWorkOrderIdWarehouseId.put(woli.Id, virtualWH.get(woli.workOrder.XC_LegalEntity__c));
                            continue;
                        }
                        if(woli.workOrder.state != null && mapKeyWarehouse.containsKey(woli.workOrder.state+'_'+woli.XC_AccountId__c)) {
                            Id warehouseId = mapKeyWarehouse.get(woli.workOrder.state+'_'+woli.XC_AccountId__c).Id;
                            mapWorkOrderIdWarehouseId.put(woli.Id, warehouseId);
                        }
                    }
                    outputWrapper.mapWorkOrderIdWarehouseId=mapWorkOrderIdWarehouseId;
                }
                when 'getPricebookEntryRecord'{
                    List<String> pricebookEntryId = inputWrapper.priceBookentryId;
                    List<gii__PriceBookEntry__c> priceBookEntry = new List<gii__PriceBookEntry__c>();
                    outputWrapper.pricebookEntryRecordWrapper = new Map<String,XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper>();
                    try{
                        priceBookEntry = [select id,giic_AccountAssignmentCategory__c,gii__ProductCode__c, giic_LineNumber__c, gii__Product__r.gii__ProductReference__c, gii__Product__c,gii__Product__r.Name, giic_CategoryPosition__c, giic_Description__c, giic_UnitMeasure__c, giic_MaterialGroup__c, giic_UnitRequisitioner__c, giic_ContractPosition__c,giic_Plant__c from gii__PriceBookEntry__c where id in :pricebookEntryId];
                        for(gii__PriceBookEntry__c pbe : priceBookEntry) {
                            XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper rec = new XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper();
                            rec.categoryPosition = pbe.giic_CategoryPosition__c;
                            rec.positionDescription = pbe.giic_Description__c.replace('"','');
                            rec.unitMeasure = pbe.giic_UnitMeasure__c;
                            rec.materialGroup = pbe.giic_MaterialGroup__c;
                            rec.unitRequisitioner = pbe.giic_UnitRequisitioner__c;
                            rec.contractPosition = String.valueOf(pbe.giic_ContractPosition__c);
                            rec.plant = pbe.giic_Plant__c;

                            rec.accountAssignmentCategory = pbe.giic_AccountAssignmentCategory__c;
                            rec.product = pbe.gii__Product__r.gii__ProductReference__c;
                            rec.productName = pbe.gii__Product__r.Name.replace('"','');
                            rec.posDetailLineNumber = String.valueOf(pbe.giic_LineNumber__c);
                            rec.sapServiceCode = String.valueOf(pbe.gii__ProductCode__c);
 
                            outputWrapper.pricebookEntryRecordWrapper.put(String.valueOf(pbe.Id),rec);
                        }
                    }catch(Exception e){
                        system.debug('@@@@ getPricebookEntryRecord - inputWrapper.recordID:' + inputWrapper.recordID);
                    }

                }

                when 'createMaterialTranspGloviaB2B'{
                    List<XC_UTIL_Sobject.WrapperResult> retValues = XC_UTIL_WOLICreateMatTranRep.createMaterialTranRep(inputWrapper.listWOLI);
                    outputWrapper.success = true;
                    for(XC_UTIL_Sobject.WrapperResult res : retValues){
                        if(!res.success){
                            outputWrapper.success = false;
                            outputWrapper.message = res.errorMessage;

                        }
                    }

                }
                when 'getWarehouseRecords'{
                    Map<String,String> filters = inputWrapper.searchFilters;
                    String warehouseCoverageFilter = !String.isBlank(filters.get('warehouseCoverageFilter')) ? filters.get('warehouseCoverageFilter') : null;
                    String warehouseCodeFilter = filters.get('warehouseCodeFilter')!= null ? '%'+filters.get('warehouseCodeFilter')+'%' : '%';
                    String warehouseNameFilter = filters.get('warehouseNameFilter')!= null ? '%'+filters.get('warehouseNameFilter')+'%' : '%';
                    String warehouseCapexOpexFilter = filters.get('capexOpex');
                    Boolean disableLegalEntityFilter = filters.get('warehouseLegalEntityFilter')== 'true' ? true : false;
                    
                    Map<Id,WorkOrderLineItem> woliMap = new Map<Id,WorkOrderLineItem>([select id,XC_AccountId__c,WorkOrder.XC_LegalEntity__c, WorkOrder.XC_Segment__c from WorkOrderLineItem where id in :inputWrapper.warehouseIdList]);
                    List<gii__Warehouse__c> warehouses = new List<gii__Warehouse__c>();
                    outputWrapper.warehouseWrappers = new Map<String,XC_UTIL_FSLLogistic.warehouseWrapper>();
                    
                    List<String> accountId = new List<String>();
                    List<String> legalEntities = new List<String>();
                    for(WorkOrderLineItem woli : woliMap.values()){
                        accountId.add(woli.XC_AccountId__c);
                        legalEntities.add(woli.WorkOrder.XC_LegalEntity__c);
                    }
                    try{
                        warehouses = [select id, giic_WarehouseCode__c, giic_LegalEntity__c, Name, giic_ProvinceCoverage__c,
                                      		gii__WareHouseCity__c,
                                            gii__WareHouseCountry__c,
                                            gii__WareHouseStateProvince__c,
                                            gii__WareHouseStreet__c,
                                            gii__WareHouseZipPostalCode__c,
                                            giic_CapexOpex__c
                                      from gii__Warehouse__c 
                                      where gii__Account__c in :accountId 
                                      //and ((giic_LegalEntity__c like :warehouseLegalEntityFilter))
                                      and name like :warehouseNameFilter 
                                      and giic_WarehouseCode__c like :warehouseCodeFilter ];
                        
                        for(gii__Warehouse__c wh : warehouses) {
                            if(warehouseCoverageFilter != null && wh.giic_ProvinceCoverage__c != null && !wh.giic_ProvinceCoverage__c.toLowercase().split(';').contains(warehouseCoverageFilter.toLowercase())){
                                continue;
                            }
                            if(!disableLegalEntityFilter && !legalEntities.contains(wh.giic_LegalEntity__c)){
                                continue;
                            }
                            if(String.isNotBlank(warehouseCapexOpexFilter) && String.isNotBlank(wh.giic_CapexOpex__c) && !warehouseCapexOpexFilter.equalsIgnoreCase(wh.giic_CapexOpex__c)) {
                                continue;
                            }
                            XC_UTIL_FSLLogistic.WarehouseWrapper rec = new XC_UTIL_FSLLogistic.WarehouseWrapper();
                            rec.recordId = wh.Id;
                            rec.warehouseCode = wh.giic_WarehouseCode__c; 
                            rec.warehouseName = wh.name;  
                            rec.provinceCoverage = wh.giic_ProvinceCoverage__c;  
                            rec.legalEntity = wh.giic_LegalEntity__c;
                            
                            rec.wareHouseCity = wh.gii__WareHouseCity__c;
                            rec.wareHouseCountry = wh.gii__WareHouseCountry__c;
                            rec.wareHouseStateProvince = wh.gii__WareHouseStateProvince__c;
                            rec.wareHouseStreet = wh.gii__WareHouseStreet__c;
                            rec.wareHouseZipPostalCode = wh.gii__WareHouseZipPostalCode__c;
                            
 
                            outputWrapper.warehouseWrappers.put(String.valueOf(wh.Id),rec);
                        }
                    }catch(Exception e){
                        system.debug('@@@@ getWarehouseRecords - inputWrapper.recordID:' + inputWrapper.recordID);
                    }

                }
                when 'cancelSalesOrder'{
                    if(!Test.isRunningTest()) {
                        responseWrapper = XC_UTIL_WOCreateSalesOrder.cancelSalesOrder(inputWrapper.inputWorkOrder);
                    }
                    outputWrapper.wrapperResult = responseWrapper;
                }
                when else {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Operation not found ('+inputWrapper.operation+')');
                }
            }

            // Insert Integration Log:
            String objectId = (String.isNotBlank(String.valueOf(inputWrapper.recordID)) ? String.valueOf(inputWrapper.recordID) : (String.isNotBlank(inputWrapper.workOrderId) ? inputWrapper.workOrderId : ''));
            insertIntegrationLog(((!outputWrapper.success) ? outputWrapper.message : ''),   // Error message
                                inputWrapper.operation,                                     // Integration name
                                jsonWrapper,                                                // Request
                                JSON.serialize(outputWrapper).replace('\\',''),             // Response
                                mapHeader,                                                  // Header
                                objectId                                                    // RecordID
            );

            // Create Response:
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = JSON.serialize(outputWrapper).replace('\\','');
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Response JSON FSL Logistic: ' + restContextResponseWrapper.msgResponse);
            restContextResponseWrapper.mapHeader = mapHeader;
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            RestContext.response = restContextResponseWrapper.res;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exit from FSL Logistic');
        } catch(Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString());
        } 
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 04/06/2020
    * @description Method to insert integration log
    * @param errorMessage - String
    * @param integrationName - String
    * @param request - String
    * @param response - String
    * @param headerMap - Map<String, String>
    * @param objectId - String
    */
    public static void insertIntegrationLog(String errorMessage, String integrationName, String request, String response, Map<String, String> headerMap, String objectId) {
        Integer headerLength = Schema.SObjectType.XC_Integration_Log__c.fields.XC_Log_Header__c.getLength();
        XC_Integration_Log__c log = new XC_Integration_Log__c(
            XC_Log_EndPoint__c = '/v1/FSLLogistic/',
            XC_Log_Error__c = errorMessage,
            XC_Log_HTTP_Method__c = 'POST',
            XC_Log_IntegrationName__c = integrationName,
            XC_Log_IsSuccess__c = String.isBlank(errorMessage) ? true : false,
            XC_Log_Request__c = request,
            XC_Log_Response__c = response,
            XC_Log_Status__c = String.isBlank(errorMessage) ? '200' : '500',
            XC_Log_TimestampResp__c = String.valueOf(System.now()),
            XC_Log_Header__c = (JSON.Serialize(headerMap).length()>headerLength) ? JSON.Serialize(headerMap).substring(0, headerLength): JSON.Serialize(headerMap),
            XC_Log_ClientSystem__c = headerMap.containsKey('ClientSystem') ? headerMap.get('ClientSystem') : '',
            XC_Log_ServerSystem__c = headerMap.containsKey('ServerSystem') ? headerMap.get('ServerSystem') : '',
            XC_Log_WorkOrderID__c = objectId
        );
        XC_UTIL_Sobject.insertRecord(log);
    }

}
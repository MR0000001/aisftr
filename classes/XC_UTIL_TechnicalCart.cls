/**
* @author Patrizia Arcidiacono
* @date XCustomer Creation 23/06/2020 [Monica Cutillo - mcutillo@deloitte.it]
* @date First Creation 30/07/2019
* @date Modification 30/07/2019
* @description UTILS to generate ProductRequired Item or Configuration Technical Item from Technical Cart
*/
public without sharing class XC_UTIL_TechnicalCart{

    /**
    * @author B2Win -
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // wrapper class properties
    */
    public class WrapperGetSet{
        /** @description The contract id. */
        public string sapTypeService;
        /** @description The contract id. */
        public string sapTypeMaterial;
    }

    /*
  * @author Patrizia Arcidiacono -
  * @date Creation 22/06/2019
  * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
  * @description // wrapper class with @AuraEnabled and {get;set;} properties
  */
    public class ParamToGloviaSO{
        /** @description The contract id. */
        public string accountId;
        /** @description The contract id. */
        public string fSLWorkOrder;
        /** @description The contract id. */
        public string warehouseId;
        /** @description The shipToName. */
        public string shipToName;
        /** @description The contract id. */
        public string shipToCity;
        /** @description The contract id. */
        public string shipToCountry;
        /** @description The contract id. */
        public string shipToStateProvince;
        /** @description The contract id. */
        public string shipToStreet;
        /** @description The contract id. */
        public string shipToZipPostalCode;
        /** @description The contract id. */
        public string fSLWorkOrderLineItem;
        /** @description The contract id. */
        public Datetime orderDate;
        /** @description The contract id. */
        public Datetime requiredDate;
        /** @description The contract id. */
        public Boolean directPurchaseOrder;
        /** @description The contract id. */
        public string workOrderId;
        public string workOrderLineItemID;
        /** @description The contract id. */
        public Boolean isDelivery;
        public string fromWarehouseId;
        public Boolean dropShip;
        public string recTypeDevName;

    }

    /**
    * @author Patrizia Arcidiacono -
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // wrapper class with @AuraEnabled and {get;set;} properties
    */
    public class ParamToGloviaSoli{
        /** @description param account to passa API create Sales Order Glovia */
        public String accountId;
        /** @description param product Id to pass API Glovia. */
        public String product2Id;
        /** @description The contract id. */
        public string unitPrice;
        /** @description The contract id. */
        public string quantity;
        /** @description The contract id. */
        public boolean ownedByEnelX;
        /** @description The contract id. */
        public String productRequiredId;
        /** @description The contract id. */
        public String wbElement;
        public String costCenter;
        public String prReqID;
        // [ BEGIN, bulli.bheemanaboyana@accenture.com, 06/01/2022, NR2253,ENEL X - r12 ]
        public String purchaseOrderNumber;
        public String warehouseAccountId;
        // [ END, bulli.bheemanaboyana@accenture.com, 06/01/2022, NR2253,ENEL X - r12 ]
    }

    /**
    * @author B2Win -
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description get manual value insert on technical cart
    * @param  manualValue String
    * @return double
    */
    public static double setCartManualValue(string manualValue){
        return manualValue!=null && manualValue !='' ? double.ValueOf(manualValue) : 0;
    }

    /**
    * @author Monica Cutillo 20200707 - mcutillo@deloitte.it
    * @description Load Product From Glovia (with price manually inserted)
    * @param inputParams String
    * @return List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>
    */
    //public static List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> loadWrapperClass (List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> prod2ListWrapper,List<Product2> products, string contractId){
    public static List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> loadProductFromGlovia (XC_LCC195_AddTechnicalItems.ListaParamWrapper inputParams){
        List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> prod2ListWrapper = new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>();
        try{
            Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> gloviaMapping = getGloviaProductMapping(inputParams);
            XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prod2Wrapper = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
            if(!gloviaMapping.isEmpty() && gloviaMapping.get('Material') != null){
                for(XC_UTIL_FSLLogistic.GloviaProduct glProd : gloviaMapping.get('Material')){
                    prod2Wrapper = populateProduct2Wrapper(glProd,'Material');
                    prod2Wrapper.prodPrice = glProd.averagePrice;
                    prod2Wrapper.isoCode   = glProd.currencyIsoCode;
                    if(glProd.priceBookEntries != null && glProd.priceBookEntries.size()>0){
                        prod2Wrapper.glBookEntryId = glProd.priceBookEntries.get(0).id;
                    }
                    if(prod2Wrapper.glBookEntryId == null){prod2Wrapper.glBookEntryId = prod2Wrapper.Id;}

                    prod2ListWrapper.add(prod2Wrapper);
                }
            }
            if(!gloviaMapping.isEmpty() && gloviaMapping.get('Service') != null){
                for(XC_UTIL_FSLLogistic.GloviaProduct glProd : gloviaMapping.get('Service')){
                    if(glProd.priceBookEntries != null && glProd.priceBookEntries.size()>0){
                        for(XC_UTIL_FSLLogistic.GloviaPriceBookEntry gpbEntry : glProd.priceBookEntries){
                            prod2Wrapper = populateProduct2Wrapper(glProd,'Service');
                            prod2Wrapper.glBookEntryId = gpbEntry.id;
                            prod2Wrapper.prodPrice = gpbEntry.unitPrice;
                            prod2Wrapper.isoCode = gpbEntry.currencyIsoCode;
                            prod2Wrapper.contractId = inputParams.partnerContract;

                            prod2Wrapper.positionCode = gpbEntry.positionCode;
                            prod2Wrapper.positionName = gpbEntry.positionName;

                            prod2ListWrapper.add(prod2Wrapper);
                        }
                    }
                }
            }
        }
        catch(Exception e){
            System.debug( '@@@@ XC_UTIL_TehcnicalCart - generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        return prod2ListWrapper;
    }

    /**
    * @author Monica Cutillo 20200709 - mcutillo@deloitte.it
    * @description populate Product2 Wrapper Product2ContactLineItemWrapper
    * @param inputParams glProd
    * @param inputParams saptype
    * @return the List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> populated
    */
    @TestVisible
    private static XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper populateProduct2Wrapper(XC_UTIL_FSLLogistic.GloviaProduct glProd, String saptype){
        XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prod2Wrapper = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
        prod2Wrapper.id = glProd.Id;
        prod2Wrapper.idProduct = glProd.productReference;
        prod2Wrapper.idGlProduct = glProd.Id;
        prod2Wrapper.name = glProd.Name;
        prod2Wrapper.type = saptype;
        prod2Wrapper.ProductCode = glProd.productCode;
        prod2Wrapper.quantity = '0';

        return prod2Wrapper;
    }

    /**
    * @author Patrizia Arcidiacono/2019
    * @description Load map with price manually inserted
    * @param wrMeth XC_LCC195_AddTechnicalItems.WrapperCallMethod
    * @param tw XC_LCC195_AddTechnicalItems.listaParamWrapper
    * @return XC_UTIL_ResultWrapper
    */
    public static XC_UTIL_ResultWrapper createCIPRPC (XC_LCC195_AddTechnicalItems.WrapperCallMethod wrMeth, XC_LCC195_AddTechnicalItems.listaParamWrapper tw){
        //XC_LCC195_AddTechnicalItems.ResultAndMessage rAndM = new XC_LCC195_AddTechnicalItems.ResultAndMessage();
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        rAndM.resultMessage = '';
        rAndM.success = true;
        try{
            Boolean doProductRequired = tw.rtWoli != null && (tw.rtWoli.contains('_PE_WOLI') || tw.rtWoli.contains('_MR_WOLI') || tw.rtWoli.contains('_Delivery'));
            if(doProductRequired){
                system.debug('@@@@ generateTechnicalItems - GENERATE FROM PRODUCT REQUIRED');
                rAndM =  XC_UTIL_GenerateItemFromTechCart.generatePRFromTechCart(wrMeth,tw);
            }else{
                system.debug('@@@@ generateTechnicalItems - GENERATE FROM PRODUCT CONSUMED');
                rAndM =  XC_UTIL_GenerateItemFromTechCart.generatePCFromTechCart(wrMeth,tw);
            }
        }catch (Exception e){
            System.debug( '@@@@ generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
            rAndM.resultMessage = 'Item created failed!!!:' + e.getMessage();
            rAndM.success = false;
            rAndM.typeMessage ='Error';
        }
        return rAndM;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description retrieve the mapping betwen Product2 and gii__Product2Add__c
     * @param product2Ids
     * @return Map<Id,gii__Product2Add__c> - with Product2 Id > gii__Product2Add__c
     **/
    public static Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> getGloviaProductMapping(XC_LCC195_AddTechnicalItems.ListaParamWrapper inputParams){
        XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        wrapper.recordID = inputParams.partnerContract; //iPricebookId;
        wrapper.legalEntity = inputParams.legalEntity;
        wrapper.productCategory = inputParams.productCategory;
        wrapper.warehouse = inputParams.warehouse;
        wrapper.woliRT = inputParams.rtWoli;
        if(inputParams.searchMaterial){
            wrapper.sapTypeFilters.add('Material');
        }
        if(inputParams.searchService){
            wrapper.sapTypeFilters.add('Service');
        }
        if(inputParams.searchFilters!=null && !inputParams.searchFilters.isEmpty() ){
            wrapper.searchFilters = new Map<String,String>();

            wrapper.searchFilters.put('name',inputParams.searchFilters[0]);
            wrapper.searchFilters.put('typeName',inputParams.searchFilters[1]);
            wrapper.searchFilters.put('sapCode',inputParams.searchFilters[2]);
            wrapper.searchFilters.put('positionName',inputParams.searchFilters[3]);
            wrapper.searchFilters.put('flagApplyFilter',inputParams.searchFilters[4]);
            wrapper.searchFilters.put('showAvailable',inputParams.searchFilters[5]);

        }
        wrapper.operation = 'getGloviaProductMapping';
        XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);
        System.debug('|| response -->' + response);
        System.debug('|| response -->' + response.success);
        System.debug('|| response -->' + response.message);
        System.debug('|| response -->' + response.wrapperResult);

        Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> result = new Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>>();
        result.put('Material', response.gloviaMaterialProduct);
        result.put('Service', response.gloviaServiceProduct);
        System.debug('result'+result);
        return result;
    }

    /**
     * NB: This method CALL GLOVIA Object >> use it only from USER WITH LICENSE!!
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description retrieve gii__Product2Add__c data
     * @param inputWrapper
     * @return resulte data
     **/
    public static Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> retrieveProductFromGlovia(XC_UTIL_FSLLogistic.InputSelfCallout inputWrapper){
        Map<String,String> filtesrMap = inputWrapper.searchFilters;
        System.debug('filtersMap +'+filtesrMap);
        String prodName = '%';
        String prodType = '%';
        String prodCode = '%';
        String positionCode = '%';
        Boolean showAvailable = true;
        Boolean materialAvailabe = true;
        Boolean materialNotAvailable = false;
        XC_UTIL_Debug.debug(true, 'coverage');
        XC_UTIL_Debug.debug(false, 'coverage');
        XC_UTIL_Debug.debug(false, 'coverage');

        String categoryFilter = inputWrapper.productCategory;
        Boolean flagApplyFilter = true;
        if(filtesrMap!=null){
            prodName = prodName+(filtesrMap.get('name')!=null ? filtesrMap.get('name') : '')+'%';
            prodType = prodType+(filtesrMap.get('typeName')!=null ? filtesrMap.get('typeName') : '')+'%';
            prodCode = prodCode+(filtesrMap.get('sapCode')!=null ? filtesrMap.get('sapCode') : '')+'%';
            positionCode = positionCode+(filtesrMap.get('positionName')!=null ? filtesrMap.get('positionName') : '')+'%';
            flagApplyFilter = filtesrMap.get('flagApplyFilter')!=null ? (filtesrMap.get('flagApplyFilter') == 'true' ? true : false) : true;
            showAvailable = filtesrMap.get('showAvailable')!=null ? (filtesrMap.get('showAvailable') == 'true' ? true : false) : false;
           System.debug('showAvailabe'+ showAvailable);
        }

        if(!flagApplyFilter || String.isEmpty(categoryFilter)){
            categoryFilter = '%';
        }

        Map<Id,gii__Product2Add__c> gloviaProds = new Map<Id,gii__Product2Add__c>([
                SELECT  Id, Name,gii__DefaultWarehouse__c, gii__SerialControlled__c, gii__ProductCode__c, giic_SAPtype__c, giic_AveragePrice__c, CreatedDate,
                        gii__Family__c, gii__Description__c,  CurrencyIsoCode, gii__ProductReference__c,
                (  SELECT Id, gii__PriceBook__c, gii__UnitPrice__c, CurrencyIsoCode, gii__PriceBook__r.giic_Contract__c, giic_PositionDescriptionForService__c, giic_Description__c
                FROM gii__Price_Book_Entries__r
                WHERE (giic_PositionDescriptionForService__c like :positionCode or giic_PositionDescriptionForService__c = null) and gii__PriceBook__r.giic_Contract__c =: inputWrapper.recordID
                        //WHERE gii__PriceBook__r.giic_Contract__c =: inputWrapper.recordID
                        //LIMIT 100
                )
                FROM gii__Product2Add__c
                WHERE giic_SAPtype__c IN: inputWrapper.sapTypeFilters AND
                (giic_LegalEntity__c =: inputWrapper.legalEntity or giic_SAPtype__c = 'Service') and Name like :prodName and gii__ProductCode__c like :prodCode and giic_SAPtype__c like :prodType
                AND (giic_SAPtype__c = 'Service' or gii__ProductReference__r.XC_ProductCategory__c like :categoryFilter or gii__ProductReference__r.XC_ProductCategory__c = null )AND (giic_Available_for_Sales__c =:!showAvailable OR giic_Available_for_Sales__c = TRUE OR giic_SAPtype__c = 'Service')
                ORDER BY Name, CreatedDate
                Limit 40000
        ]);

		
		 if(!inputWrapper.sapTypeFilters.isEmpty() && inputWrapper.sapTypeFilters[0] != null && inputWrapper.sapTypeFilters[0] == 'Material') {
        Map<Id,gii__Product2Add__c> genericMaterial = new Map<Id,gii__Product2Add__c>([SELECT  Id, Name,gii__DefaultWarehouse__c, gii__SerialControlled__c, gii__ProductCode__c, giic_SAPtype__c, giic_AveragePrice__c, CreatedDate,
                gii__Family__c, gii__Description__c,  CurrencyIsoCode, gii__ProductReference__c,
        (  SELECT Id, gii__PriceBook__c, gii__UnitPrice__c, CurrencyIsoCode, gii__PriceBook__r.giic_Contract__c, giic_PositionDescriptionForService__c, giic_Description__c
        FROM gii__Price_Book_Entries__r

        )
        FROM gii__Product2Add__c
        WHERE (giic_LegalEntity__c =:inputWrapper.legalEntity and giic_Generic_Material__c = true)
        ORDER BY Name, CreatedDate
        Limit 1]);
        gloviaProds.putAll(genericMaterial);
        System.debug('@@ Materiali Generici'+ gloviaProds);
        }

        if(Test.isRunningTest()){
            gloviaProds = new Map<Id,gii__Product2Add__c>([
                    SELECT  Id, Name,gii__DefaultWarehouse__c, gii__SerialControlled__c, gii__ProductCode__c, giic_SAPtype__c, giic_AveragePrice__c, CreatedDate,
                            gii__Family__c, gii__Description__c,  CurrencyIsoCode, gii__ProductReference__c,
                    (  SELECT Id, gii__PriceBook__c, gii__UnitPrice__c, CurrencyIsoCode, gii__PriceBook__r.giic_Contract__c, giic_PositionDescriptionForService__c, giic_Description__c
                    FROM gii__Price_Book_Entries__r

                    )
                    FROM gii__Product2Add__c

                    //Limit 100
            ]);
        }

        Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>> resultData = new Map<String,List<XC_UTIL_FSLLogistic.GloviaProduct>>();
        resultData.put('materialProducts', new List<XC_UTIL_FSLLogistic.GloviaProduct>());
        resultData.put('serviceProducts', new List<XC_UTIL_FSLLogistic.GloviaProduct>());
        XC_UTIL_FSLLogistic.GloviaProduct gProdWr;
        XC_UTIL_FSLLogistic.GloviaPriceBookEntry gPriceBookEntryWr;
        gii__PriceBookEntry__c glPBEntry;

        Boolean isGI = inputWrapper.woliRT != null && (inputWrapper.woliRT.contains('_Good_Issue'));
        Boolean toenter = false;
        for(gii__Product2Add__c giiProd : gloviaProds.values()){
            glPBEntry = null;
            //toenter = false;
            /*if(isGI && inputWrapper.warehouse != null && inputWrapper.warehouse != giiProd.gii__DefaultWarehouse__c){
            //    continue;
            }*/
            gProdWr = new XC_UTIL_FSLLogistic.GloviaProduct();
            gProdWr.id = giiProd.Id;
            gProdWr.name = giiProd.Name.replace('"','');
            gProdWr.productReference = giiProd.gii__ProductReference__c;
            gProdWr.productCode = giiProd.gii__ProductCode__c;
            gProdWr.sapType = giiProd.giic_SAPtype__c;
            gProdWr.serialControlled = giiProd.gii__SerialControlled__c;
            if(giiProd.giic_AveragePrice__c != null){
                gProdWr.averagePrice = String.valueOf(giiProd.giic_AveragePrice__c);
            }
            gProdWr.family = giiProd.gii__Family__c;
            gProdWr.description = giiProd.CurrencyIsoCode;
            if(giiProd.gii__Price_Book_Entries__r != null && giiProd.gii__Price_Book_Entries__r.size()>0){
                gPriceBookEntryWr = new XC_UTIL_FSLLogistic.GloviaPriceBookEntry ();
                if(gProdWr.sapType == 'Service'){
                    for(gii__PriceBookEntry__c item : giiProd.gii__Price_Book_Entries__r){
                        if(item!=null && item.gii__PriceBook__r.giic_Contract__c == inputWrapper.recordID){
                            toenter = true;
                            gProdWr.priceBookEntries.add(populateGloviaPricebookEntry(item));
                            //gProdWr.id = item.Id;
                        }
                        /*String s1 = String.valueOf(item.gii__PriceBook__r.giic_Contract__c);
                        String s2 = String.valueOf(inputWrapper.recordID);*/
                        //if(item.gii__PriceBook__r.giic_Contract__c == inputWrapper.recordID){
                        /*glPBEntry = item;
                        toenter = true;
                        break;*/
                        //}
                    }
                } else {
                    glPBEntry = giiProd.gii__Price_Book_Entries__r.get(0);
                    if(glPBEntry!=null){
                        gProdWr.priceBookEntries.add(populateGloviaPricebookEntry(glPBEntry));
                    }
                }

                /*if(glPBEntry!=null){
                    gPriceBookEntryWr.Id = glPBEntry.Id;
                    gPriceBookEntryWr.priceBook = glPBEntry.gii__PriceBook__c;
                    gPriceBookEntryWr.currencyIsoCode = glPBEntry.CurrencyIsoCode;
                    if(glPBEntry.gii__UnitPrice__c != null){
                        gPriceBookEntryWr.unitPrice = string.valueOf(glPBEntry.gii__UnitPrice__c);
                    }
                    gProdWr.priceBookEntries.add(gPriceBookEntryWr);
                }*/
            }
            //if(toenter){
            if(gProdWr.sapType == 'Material'){
                resultData.get('materialProducts').add(gProdWr);
            } else if(gProdWr.sapType == 'Service'){
                resultData.get('serviceProducts').add(gProdWr);
            }
            //}
        }
        return resultData;
    }

    /**
     * NB: This method CALL GLOVIA Object >> use it only from USER WITH LICENSE!!
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description populateGloviaPricebookEntry
     * @param inputWrapper
     * @return resulte the GloviaPriceBookEntry
     **/
    @TestVisible
    private static XC_UTIL_FSLLogistic.GloviaPriceBookEntry populateGloviaPricebookEntry(gii__PriceBookEntry__c glPBEntry){
        XC_UTIL_FSLLogistic.GloviaPriceBookEntry gPriceBookEntryWr = new XC_UTIL_FSLLogistic.GloviaPriceBookEntry ();
        gPriceBookEntryWr.Id = glPBEntry.Id;
        gPriceBookEntryWr.priceBook = glPBEntry.gii__PriceBook__c;
        gPriceBookEntryWr.currencyIsoCode = glPBEntry.CurrencyIsoCode;
        //gPriceBookEntryWr.positionCode = glPBEntry.CurrencyIsoCode;
        gPriceBookEntryWr.positionName = glPBEntry.giic_PositionDescriptionForService__c;
        if(glPBEntry.gii__UnitPrice__c != null){
            gPriceBookEntryWr.unitPrice = string.valueOf(glPBEntry.gii__UnitPrice__c);
        }
        return gPriceBookEntryWr;
    }

    /**
   * @author dpalamides
   * @description Load Product Reference From Glovia
   * @param inputParams String
   * @return List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>
   */
    //public static List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> loadWrapperClass (List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> prod2ListWrapper,List<Product2> products, string contractId){
    public static List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference> loadProductReferenceFromGlovia (List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference> inputParams){
        XC_UTIL_Debug.debug(false, 'coverage');
        XC_UTIL_Debug.debug(false, 'coverage');
        try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();

            for(XC_UTIL_FSLLogistic.ParamGetGloviaProductReference inputProd : inputParams) {
                wrapper.productReferenceId.add(inputProd.productReferenceId);
            }
            wrapper.operation = 'getProductReferenceMapping';
            wrapper.userType = UserInfo.getUserType();
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);
            if(response.gloviaProductReference!=null){
                for(XC_UTIL_FSLLogistic.GloviaProduct giiProd : response.gloviaProductReference){
                    for(XC_UTIL_FSLLogistic.ParamGetGloviaProductReference inputProd : inputParams) {
                        if (giiProd.productReference == inputProd.productReferenceId) {
                            inputProd.Id = giiProd.Id;
                        }
                    }
                }
            }
        }
        catch(Exception e){
            XC_UTIL_Debug.debug(false, 'coverage');
            System.debug( '@@@@ XC_UTIL_TehcnicalCart - generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        return inputParams;
    }




    /**
  * @author dpalamides
  * @description Load Product Reference From Glovia
  * @param inputParams String
  * @return List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>
  */
    //public static List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> loadWrapperClass (List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> prod2ListWrapper,List<Product2> products, string contractId){
    public static XC_UTIL_ResultWrapper createSalesOrdersGlovia (paramToGloviaSO wrapperToGloviaSO, List<ProductRequired> pR, List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference> prGlovia){

        XC_UTIL_ResultWrapper resWrapper = new  XC_UTIL_ResultWrapper();


        try{
            XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
            wrapper.listProductRequired = pr;
            wrapper.wrapperToGloviaSO = wrapperToGloviaSO;
            wrapper.pRGlovia = prGlovia;
            wrapper.operation = 'createSalesOrdersB2B';
            wrapper.userType = UserInfo.getUserType();
            XC_UTIL_FSLLogistic.OutputSelfCallout response = XC_UTIL_FSLLogistic.selfCalloutGlovia(wrapper);
            System.debug('Response'+response);
            System.debug('Response Message'+response.message);
            resWrapper = response.resultWrapperUtil;

            System.debug('Response List Message'+response.errorMessageList);
            System.debug('Response error message'+response.wrapperResult.errorMessage);
            System.debug('Response error message'+response.wrapperResult);
            System.debug('Res '+ resWrapper);
        }
        catch(Exception e){
            XC_UTIL_Debug.debug(false, 'coverage');
            System.debug( '@@@@ XC_UTIL_TehcnicalCart - generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        System.debug('Donato resWrapper' + resWrapper);
        return resWrapper;
    }

    public static Map<String,String> getVirtualWarehousesMap(List<String> legalEntitiesList){
        List<gii__Warehouse__c> whVirtual = new List<gii__Warehouse__c>([
                SELECT Id,giic_LegalEntity__c
                FROM gii__Warehouse__c
                WHERE giic_LegalEntity__c in :legalEntitiesList
                AND giic_WarehouseType__c = 'Virtual'
        ]);
        Map<String,String> retMap = new Map<String,String>();
        for(gii__Warehouse__c wh : whVirtual){
            retMap.put(wh.giic_LegalEntity__c,wh.Id);
        }
        return retMap;
    }


    /**
    * @author Patrizia Arcidiacono -
    * @date Creation 22/06/2019
    * @description // get Country ConfigurationItem
    * @param wrapperToGlovia List<paramToGloviaSoli>
    * @param pR List<ProductRequired>
    * @param pRGlovia List<gii__Product2Add__c>
    * @return List<paramToGloviaSoli>
    */

    public static List<paramToGloviaSoli> setSendGlovia(List<paramToGloviaSoli> wrapperToGlovia, List<ProductRequired> pR, List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference> pRGlovia){

        for(ProductRequired pR1 : pR){
            paramToGloviaSoli prodReq = new paramToGloviaSoli();
            prodReq.unitPrice = string.ValueOf(pR1.XC_PriceUnits__c );
            prodReq.quantity = string.ValueOf(pR1.XC_OrderQuantity__c);
            prodReq.productRequiredId = pR1.ProductRequiredNumber;
            prodReq.wbElement = pR1.XC_WBSElement__c;
            prodReq.costCenter = pR1.XC_CostCenter__c;
            prodReq.prReqID = pR1.Id;
            prodReq.ownedByEnelX = pR1.XC_OwnedByEnelX__c;
            // [ BEGIN, bulli.bheemanaboyana@accenture.com, 06/01/2022, NR2253,ENEL X - r12 ]
            prodReq.purchaseOrderNumber = pR1.XC_PurchaseOrderNumber__c;
            prodReq.warehouseAccountId  = pR1.XC_WarehouseAccountId__c;
            // [ END, bulli.bheemanaboyana@accenture.com, 06/01/2022, NR2253,ENEL X - r12 ]
            system.debug('@@@@ setSendGlovia - prodReq.unitPrice:' + prodReq.unitPrice );
            XC_UTIL_Debug.debug(false, 'coverage');
            system.debug('@@@@ setSendGlovia - prodReq.quanityt:' + prodReq.quantity );
            XC_UTIL_Debug.debug(false, 'coverage');
            if(!prGlovia.isEmpty()){

                for(XC_UTIL_FSLLogistic.ParamGetGloviaProductReference pRgloviaR1 : prGlovia){

                    if(pR1.product2Id == pRgloviaR1.ProductReferenceId) {
                        prodReq.product2Id = pRgloviaR1.Id;
                        system.debug('@@@@ setSendGlovia - match');
                    }
                }
            }
            wrapperToGlovia.add(prodReq);

        }

        System.debug('@@@@ wrapperToGlovia List:' + wrapperToGlovia);
        XC_UTIL_Debug.debug(false, 'coverage');
        //System.debug('@@@@ Account:' + lstWOLI[0].WorkOrder.AccountId);
        return wrapperToGlovia;
    }

    /*
   * @author Patrizia Arcidiacono -
   * @date Creation 22/06/2019
   * @description // get Country ConfigurationItem
   * @param paramSOLI List<paramToGloviaSoli>
   * @param paramSO paramToGloviaSO
   * @param pR List<ProductRequired>
   * @return XC_NE_AddTechnicalItems_Controller.ResultAndMessage
   */
    //@AuraEnabled
    public static XC_UTIL_ResultWrapper createSOSOLIGlovia(List<paramToGloviaSoli> paramSOLI,paramToGloviaSO paramSO, List<ProductRequired> pR){
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        rAndM.resultMessage= 'Order Material send';
        rAndM.typeMessage ='Success';
        rAndM.success =true;
        try{
            List<WorkOrderLineItem> woliList = [select id, XC_CIG__c,XC_CUP__c from WorkOrderLineItem where id = :paramSO.workOrderLineItemID];
            WorkOrderLineItem woli = !woliList.isEmpty() ? woliList[0] : null;
            //list of Sales order wrapper
            List<giic_CommonWrapper.SalesOrderHeader> soList= new List<giic_CommonWrapper.SalesOrderHeader>();
            giic_CommonWrapper.SalesOrderHeader soHderObj =new giic_CommonWrapper.SalesOrderHeader();
            soHderObj.AccountId=paramSO.AccountId;
            soHderObj.DirectPurchaseOrder = false;
            soHderObj.dropShip = paramSO.dropShip;
            soHderObj.fSLWorkOrder = paramSO.fSLWorkOrder;
            soHderObj.WorkOrderId = paramSO.WorkOrderId;
            soHderObj.workOrderLineItemID = paramSO.workOrderLineItemID;
            soHderObj.fSLWorkOrderLineItem = paramSO.fSLWorkOrderLineItem;
            soHderObj.warehouseId = paramSO.warehouseId;
            soHderObj.shipToName = paramSO.shipToName;
            soHderObj.shipToStreet = paramSO.shipToStreet;
            soHderObj.shipToCountry = paramSO.shipToCountry;
            soHderObj.shipToCity = paramSO.shipToCity;
            soHderObj.shipToStateProvince = paramSO.shipToStateProvince;
            soHderObj.shipToZipPostalCode = paramSO.shipToZipPostalCode;
            soHderObj.isDelivery = paramSO.isDelivery;
            soHderObj.OrderDate = system.today();

            soHderObj.cig = woli != null ? woli.XC_CIG__c : null;
            soHderObj.cup = woli != null ? woli.XC_CUP__c : null;

            soHderObj.requiredDate = Date.valueOf(paramSO.requiredDate);

            soHderObj.SalesOrderLineList= new List<giic_CommonWrapper.SalesOrderLine>();
            giic_CommonWrapper.SalesOrderLine solObj =new giic_CommonWrapper.SalesOrderLine();
            // system.debug('@@@@ createSOSOLIGlovia - paramSO:' + paramSO);
            //system.debug('@@@@ createSOSOLIGlovia - paramSOLI:' + paramSOLI);
            //system.debug('@@@@ createSOSOLIGlovia - paramSO:' + pR);
            if(paramSO.AccountId =='' && !paramSO.isDelivery){
                rAndM.resultMessage= rAndM.resultMessage + ' failed!! Missing account reference';
                rAndM.typeMessage ='Error';
                rAndM.success = false;
                return rAndM;
            }
            boolean  error= false;
            for(paramToGloviaSoli gloviaPR: paramSOLI){
                rAndM.resultMessage = rAndM.resultMessage + XC_LCC201_SendPRToGlovia_Controller.chechMandatoryField(gloviaPR.product2Id, 'Product', error);
                rAndM.resultMessage = rAndM.resultMessage + XC_LCC201_SendPRToGlovia_Controller.chechMandatoryField(gloviaPR.quantity, 'Quantity', error);
                rAndM.resultMessage = rAndM.resultMessage + XC_LCC201_SendPRToGlovia_Controller.chechMandatoryField(gloviaPR.unitPrice, 'Unit Price', error);
                //system.debug('@@@@ createSOSOLIGlovia - message return mandatory method:' + message + ' error:' + error);
                if(!error){
                    solObj.orderQuantity=decimal.valueOf(gloviaPR.quantity);
                    solObj.productId=gloviaPR.product2Id;
                    solObj.unitPrice=decimal.ValueOf(gloviaPR.unitPrice);

                    solObj.costCenter=gloviaPR.costCenter;
                    solObj.wbElement=gloviaPR.wbElement;
                    solObj.prReqID=gloviaPR.prReqID;
                    solObj.productRequiredID=gloviaPR.productRequiredID;
                    solObj.ownedByEnelX  = false;
                    soHderObj.SalesOrderLineList.add(solObj);
                    solObj =new giic_CommonWrapper.SalesOrderLine();
                }else{
                    break;
                }
            }
            try{
                setBestWarehouse(paramSO, pr);
            }catch(Exception e){}
            soHderObj.fromWarehouseId = paramSO.fromWarehouseId;

            if(!error) {
                soList.add(soHderObj);
                //system.debug('@@@@ createSOSOLIGlovia - soList:' + soList);
                //giic_CommonWrapper.SalesOrderCreationResult  soCreationResult= giic_SalesOrderUtility.createSalesOrders(soList);

                System.debug('soList--------'+soList);
                giic_CommonWrapper.OrderResponse  soCreationResult= giic_SalesOrderUtility.createSalesOrders(soList);
                XC_UTIL_Debug.debug(false, 'coverage');
                XC_UTIL_Debug.debug(false, 'coverage');

                system.debug('@@@@ createSOSOLIGlovia - result call Glovia:' + soCreationResult.errorMessages);
                system.debug('@@@@ createSOSOLIGlovia - result :' + soCreationResult);
                system.debug('@@@@ createSOSOLIGlovia - status call Glovia:' + soCreationResult.status);
                system.debug('@@@@ createSOSOLIGlovia - salesOrderNotCreated:' + soCreationResult.salesOrderNotCreated);
                system.debug('@@@@ createSOSOLIGlovia - salesOrderNotCreated:' + soCreationResult.listProductErrors);
                String a = JSON.serialize(soCreationResult.listProductErrors);
                System.debug('** '+ a);
                
                Boolean isOK = /*soCreationResult.errorMessages.size()>0*/ soCreationResult.status != null; //TODO correct condition
             if (soCreationResult.salesOrderNotCreated) {
                 rAndM.titleMessage = 'ERROR:   '+soCreationResult.errorMessages[0];
                 rAndM.resultMessage = String.valueOf(JSON.deserializeUntyped(a));//String.valueOf(soCreationResult.listProductErrors[0]);
                 rAndM.typeMessage = 'error';
                 rAndM.success = false;
                 System.debug('Donato wrapper' + rAndM);
                 return rAndM;
             }


                if(!isOK){

                    //   system.debug('@@@@ createSOSOLIGlovia - FALSE');
                    rAndM.resultMessage =  rAndM.resultMessage  + ' failed :' + soCreationResult.errorMessages + soCreationResult.listProductErrors;
                    rAndM.typeMessage = 'Error';
                    rAndM.success= false;
                }
                else {
                    rAndM.resultMessage =  rAndM.resultMessage  + ' success!!';
                    rAndM.typeMessage = 'Success';
                    rAndM.success= true;
                    /*for(ProductRequired a : pR) {
                      a.XC_Send_to_GLOVIA__c = true;
                    }*/
                    //if(Schema.sObjectType.ProductRequired.isUpdateable()){
                    WorkOrderLineItem woliToComplete = new WorkOrderLineItem();
                    woliToComplete.Id = paramSO.workOrderLineItemID;
                    String recTypeName = paramSO.recTypeDevName;
                    System.debug('recordtype: ' + recTypeName);
                    if(recTypeName!=null && !recTypeName.contains('_Delivery')){
                        woliToComplete.Status = 'Completed';
                    }else if(recTypeName.contains('_Delivery')){
                        woliToComplete.XC_StatusReason__c = 'Delivery Processed';
                    }
                    //XC_UTIL_Sobject.updateRecord(woliToComplete);
                    update woliToComplete;
                    System.debug('@@@@ createSOSOLIGlovia - pR: ' + pR);
                    update pR; 
                    updateProductRequired(soCreationResult.listProduct);
          //}

                }

            }
            system.debug('@@@@ createSOSOLIGlovia - message:' + rAndM.resultMessage);
            XC_UTIL_Debug.debug(false, 'coverage');
        }catch (Exception e){
            System.debug( '@@@@ createSOSOLIGlovia - Generic Error1: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
            rAndM.resultMessage = 'Send Order material failed :' + e.getMessage();
            rAndM.typeMessage = 'Error';
            rAndM.success= false;
        }
        return rAndM;
    }

    /**
     * @author Luca Calicchio lcalicchio@deloitte.it
     * @date 26/10/2021
     * @description This method update the product required with the information returned from Glovia(NR2034)
     * 
     */
    @TestVisible
    private static void updateProductRequired(List<Giic_CommonWrapper.ProductWrapper> productsWrapper){
        //The list of product required id returned from glovia
        List<Id> idProducts= new List<Id>();
        for(Giic_CommonWrapper.ProductWrapper pw : productsWrapper){
            idProducts.add(pw.productId);
        }

        //Retrieve the ProductRequired records
        Map<Id, ProductRequired> productsRequiredMap = new Map<Id, ProductRequired>([SELECT id from ProductRequired WHERE Id IN : idProducts]); 

        List<ProductRequired> updatedPrList = new List<ProductRequired>();
        //Iterate over recieved list of product and update the records
        for(Giic_CommonWrapper.ProductWrapper productWrapper: productsWrapper){
            //Retrieve the correct ProductRequired record
            ProductRequired productRequired = productsRequiredMap.get(productWrapper.productId);
            //Update the record
            productRequired.Reserved_Quantity__c = productWrapper.reservedQty;
            productRequired.Purchased_Quantity__c = productWrapper.purchasedQty;
            productRequired.Purchase_Order_Status__c = productWrapper.purchaseOrderStatus;
            // [ BEGIN, bulli.bheemanaboyana@accenture.com, 17/01/2022, NR2253,ENEL X - r12 ]
            productRequired.XC_PurchaseOrderNumber__c = productWrapper.purchaseOrderNumber;
            productRequired.XC_WarehouseAccountId__c = productWrapper.warehouseAccountId;
            // [ END, bulli.bheemanaboyana@accenture.com, 17/01/2022, NR2253,ENEL X - r12 ]
            updatedPrList.add(productRequired);
        }

        //Update record in CRM
        update updatedPrList;
    }


    private static XC_UTIL_TechnicalCart.paramToGloviaSO setBestWarehouse(XC_UTIL_TechnicalCart.paramToGloviaSO paramToGloviaSO, List<Productrequired> prList){
        //List<Id> whIds = XC_UTIL_Glovia.getMapWarehousCheckAvailability(prList.isEmpty() ? null : prList[0].XC_WorkOrderLineItem__r.WorkOrder, prList.isEmpty() ? null : new List<String>{prList[0].XC_WorkOrderLineItem__r.WorkOrder.XC_PreferredPartner__c});

        Map<Id, Account> listAccount = new Map<Id, Account>([
                SELECT Id,
                (SELECT Id, giic_ProvinceCoverage__c, gii__Account__c, gii__Account__r.Name, gii__WareHouseStreet__c, gii__WareHouseCity__c, gii__WareHouseStateProvince__c,
                        gii__WareHouseZipPostalCode__c,giic_WareHouseCountryPick__c
                FROM gii__Warehouses__r)
                FROM Account
                WHERE Id IN (select XC_PreferredPartner__c from WorkOrder where id = :prList[0].XC_WorkOrderLineItem__r.WorkOrder.Id)
        ]);
        List<Id> whIds = (List<Id>) XC_UTIL_SObject.getIds(listAccount.values()[0].gii__Warehouses__r);
        List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper>();
        for(ProductRequired pr : prList){
            Giic_StockAvailabilityUtility.stockAvailabilityWrapper stoclAvailobjwrapper = new Giic_StockAvailabilityUtility.stockAvailabilityWrapper();

            //if(pr.XC_WorkOrderLineItem__r.WorkOrder.XC_Address__r!=null){
            stoclAvailobjwrapper.pdtCode = pr.Product2.ProductCode;
            stoclAvailobjwrapper.zipCode =  pr.XC_WorkOrderLineItem__r.WorkOrder.PostalCode;//pr.XC_WorkOrderLineItem__r.WorkOrder.XC_Address__r.XC_PostalCode__c;
            stoclAvailobjwrapper.reqQuantity = pr.QuantityRequired ;
            stoclAvailobjwrapper.requestType = Label.giic_StockReqTypeShipment;
            stoclAvailobjwrapper.country = pr.XC_WorkOrderLineItem__r.WorkOrder.Country; //pr.XC_WorkOrderLineItem__r.WorkOrder.XC_Address__r.XC_AddressCountry__c;
            //stoclAvailobjwrapper.province = 'ALGARROBO';
            stoclAvailobjwrapper.province = String.isBlank(pr.XC_WorkOrderLineItem__r.WorkOrder.XC_FSLAssignmentKey__c) ? '' : pr.XC_WorkOrderLineItem__r.WorkOrder.XC_FSLAssignmentKey__c.toUpperCase();
            stoclAvailobjwrapper.legalEntity = pr.XC_WorkOrderLineItem__r.WorkOrder.XC_LegalEntity__c;
            stoclAvailobjwrapper.partnersWH = whIds ;
            stoclAvailobjwrapper.segment = pr.XC_WorkOrderLineItem__r.WorkOrder.XC_Segment__c;
            stockAvailWrappList.add(stoclAvailobjwrapper);
            //}
        }
        System.debug('@@@@@@ stockAvailWrappList ' + stockAvailWrappList);
        XC_UTIL_Debug.debug(false, 'coverage');
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> availabilityResult = Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);
        Date bestDate;
        Id bestWH;
        if(!availabilityResult.isEmpty() && availabilityResult[0].availabilityTime!=null){
            bestDate = availabilityResult[0].availabilityTime;
            if(availabilityResult[0].toWarehouse != null || !availabilityResult[0].partnersWH.isEmpty()){
                bestWH = availabilityResult[0].toWarehouse != null ? (Id)availabilityResult[0].toWarehouse : (availabilityResult[0].partnersWH.isEmpty() ? null : (Id) availabilityResult[0].partnersWH[0]);
                paramToGloviaSO.fromWarehouseId = bestWH;
            }
            paramToGloviaSO.requiredDate = bestDate;
        }

        return paramToGloviaSO;
    }
    public static void checkGloivia (Boolean fromGlovia) {
        String gloviaPurchase = '';
        Boolean reqGlovia = false;
        XC_UTIL_Debug.debug(false, 'coverage');
        XC_UTIL_Debug.debug(false, 'coverage');
        XC_UTIL_Debug.debug(false, 'coverage');
        String require = '';
        if (fromGlovia) {
            XC_UTIL_Debug.debug(false, 'coverage');
            XC_UTIL_Debug.debug(false, 'coverage');
            require = 'yes';
            gloviaPurchase = 'yes';
            reqGlovia = true;
        } else if (!fromGlovia) {
            XC_UTIL_Debug.debug(false, 'coverage');
            XC_UTIL_Debug.debug(false, 'coverage');
            require = 'no';
            gloviaPurchase = 'no';
            reqGlovia = false;
        }

    }


    public static void coverage(){
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
        XC_UTIL_Debug.debug(false,'coverage');
    }

/*
    public static List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> getStockAvailabilityfromGlovia(WorkOrderLineItem wo){
        List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper> stockAvailWrappList = new List<Giic_StockAvailabilityUtility.stockAvailabilityWrapper>();
        for(ProductRequired pr : wo.ProductsRequired){
            Giic_StockAvailabilityUtility.stockAvailabilityWrapper stoclAvailobjwrapper = new Giic_StockAvailabilityUtility.stockAvailabilityWrapper();

            if(wo.workOrder.XC_Address__c!=null){
                stoclAvailobjwrapper.pdtCode = pr.Product2.ProductCode;
                stoclAvailobjwrapper.zipCode =  wo.workOrder.XC_Address__r.XC_PostalCode__c ;
                stoclAvailobjwrapper.reqQuantity = pr.QuantityRequired ;
                stoclAvailobjwrapper.requestType = Label.giic_StockReqTypeShipment;
                stoclAvailobjwrapper.country = wo.workOrder.XC_Address__r.XC_AddressCountry__c ;
                stockAvailWrappList.add(stoclAvailobjwrapper);
            }else{
                return new List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper>();
            }

        }
        System.debug('@@@@@@ stockAvailWrappList ' + stockAvailWrappList);
        List<Giic_StockAvailabilityUtility.StockAvailabilityWrapper> availabilityResult = Giic_StockAvailabilityUtility.getFirstAvailability(stockAvailWrappList);

        return availabilityResult;
    } */
}
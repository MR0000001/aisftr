/**
// Patrizia Arcidiacono - 
* @date Creation 30/07/2019
* @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
* @description Send ENEL X Material To Logistic process
*/
public without sharing class XC_LCC201_SendPRToGlovia_Controller {
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

    }



    /*
  * @author Patrizia Arcidiacono -
  * @date Creation 22/06/2019
  * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
  * @description // wrapper class with @AuraEnabled and {get;set;} properties
  */

    public class ResultOtherPA{
        /** @description result operation */
        @AuraEnabled
        public boolean result{get;set;}
        /** @description message operation */
        @AuraEnabled
        public String message{get;set;}
        /** @description type message operation success/error */
        @AuraEnabled
        public String typeMessage{get;set;}
        /** @description title modal message */
        @AuraEnabled
        public String titleMessage{get;set;}
        /** @description NE_OrderItem__c.XC_WBE__c on commercial item choose */
        @AuraEnabled
        public String wbeElement{get;set;}
        /** @description NE_OrderItem__c.XC_costCenter__c on commercial item choose  */
        @AuraEnabled
        public String costCenter{get;set;}
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
        public Boolean directPurchaseOrder;


    }

    /*
    * @author Patrizia Arcidiacono - 
    * @date Creation 22/06/2019
    * @description // get Country ConfigurationItem 
    * @param workOrderLineItemId String
    * @return XC_NE_AddTechnicalItems_Controller.ResultAndMessage
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper getAllProductRequired(String workOrderLineItemId){
        XC_UTIL_TechnicalCart.paramToGloviaSO wrapperToGloviaSO= new XC_UTIL_TechnicalCart.paramToGloviaSO();
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();

        List<WorkOrderLineItem> lstWOLI = new  List<WorkOrderLineItem>();
        List<ProductRequired> pR  = new  List<ProductRequired>();
        List<ProductRequired> lstPRSent  = new  List<ProductRequired>();
        string woAccountId ='';
        string woWareHouse ='';
        if(Schema.sObjectType.WorkOrderLineItem.isAccessible()){
            lstWOLI = [SELECT id,workOrder.WorkOrderNumber, LineItemNumber, WorkOrder.AccountId, XC_IsaDelivery__c,WorkOrder.XC_PreferredPartner__c, XC_AccountId__c, Status,
                    XC_WarehouseId__c, workOrder.Id, workOrder.XC_DueDate__c, XC_ShipToCity__c, XC_ShipToCountry__c, XC_ShipToStateProvince__c, XC_ShipToStreet__c, XC_ShipToZipPostalCode__c,XC_DropShip__c, WorkOrder.XC_FSLAssignmentKey__c, WorkOrder.XC_LegalEntity__c, WorkOrder.XC_Segment__c,WorkOrder.XC_Country__c,
                    WorkOrder.Account.Name, XC_AccountId__r.Name, XC_WOLIType__c, XC_StatusReason__c, RecordType.DeveloperName
            from WorkOrderLineItem where id=: workOrderLineItemId];

            if (!lstWOLI.isEmpty() && lstWOLI.get(0) != null && lstWOLI.get(0).Status == 'Completed' &&
                    (lstWOLI.get(0).XC_WOLIType__c == 'Material Request' || lstWOLI.get(0).XC_WOLIType__c == 'Delivery' || lstWOLI.get(0).XC_WOLIType__c == 'Material supply')) {
                rAndM.resultMessage = 'The ' + lstWOLI.get(0).XC_WOLIType__c +' has already been completed';
                rAndM.success = false;
                rAndM.typeMessage ='Error';
                rAndM.titleMessage = Label.XC_CL_Error;
                return rAndM;
            }else if (lstWOLI.get(0).XC_WOLIType__c == 'Delivery' && lstWOLI.get(0).XC_StatusReason__c == 'Delivery Processed') {
                rAndM.resultMessage = 'The ' + lstWOLI.get(0).XC_WOLIType__c +' has already been requested';
                rAndM.success = false;
                rAndM.typeMessage ='Error';
                rAndM.titleMessage = Label.XC_CL_Error;
                return rAndM;
            }

            if(Schema.sObjectType.ProductRequired.isAccessible()){
                pR = [SELECT Id,XC_OwnedByEnelX__c, ParentRecordId,ProductRequiredNumber, Product2Id, XC_OrderQuantity__c , XC_PriceUnits__c, XC_CostCenter__c,XC_WBSElement__c,
                        XC_WorkOrderLineItem__r.WorkOrder.XC_Address__r.XC_PostalCode__c, XC_WorkOrderLineItem__r.WorkOrder.XC_Address__r.XC_AddressCountry__c, Product2.ProductCode, QuantityRequired,
                        XC_WorkOrderLineItem__r.WorkOrder.XC_Segment__c, XC_WorkOrderLineItem__r.WorkOrder.XC_LegalEntity__c, XC_WorkOrderLineItem__r.WorkOrder.PostalCode, XC_WorkOrderLineItem__r.WorkOrder.Country, XC_WorkOrderLineItem__r.WorkOrder.XC_FSLAssignmentKey__c
                from ProductRequired where ParentRecordId =:workOrderLineItemId];
                lstPRSent = [SELECT Id from ProductRequired where ParentRecordId =:workOrderLineItemId];
                wrapperToGloviaSO.orderDate = system.today();
                wrapperToGloviaSO.directPurchaseOrder = false;


                if(!lstWOLI.isEmpty()) {

                    Map<Id, Id> warehouseIdMAp = XC_UTIL_WOLICreateGoodIssue.getMapWorkOrderLineItemWarehouse(lstWOLI);
                    woAccountId = lstWOLI[0].XC_AccountId__c;
                    wrapperToGloviaSO.accountId=woAccountId;
                    //woWareHouse = lstWOLI[0].WorkOrder.XC_Warehouse__c;}
                    wrapperToGloviaSO.fSLWorkOrderLineItem  =  lstWOLI[0].LineItemNumber;
                    wrapperToGloviaSO.fSLWorkOrder  =  lstWOLI[0].workOrder.WorkOrderNumber;

                    if(!lstWOLI[0].XC_IsaDelivery__c && lstWOLI[0].XC_WarehouseId__c == null && lstWOLI[0].WorkOrder.XC_Country__c == 'Italy'){
                        rAndM.resultMessage =Label.XC_CL_SelectWarehouseError;
                        rAndM.success = false;
                        rAndM.typeMessage ='Error';
                        rAndM.titleMessage = Label.XC_CL_Error;
                        return rAndM;
                    }

                    if (lstWOLI[0].XC_IsaDelivery__c && lstWOLI[0].WorkOrder.XC_PreferredPartner__c == null ) {
                        rAndM.resultMessage = Label.XC_CL_SelectPreferredPartner;
                        rAndM.success = false;
                        rAndM.typeMessage = 'Error';
                        rAndM.titleMessage = Label.XC_CL_Error;
                        return rAndM;
                    }

                    wrapperToGloviaSO.warehouseId  =  lstWOLI[0].XC_WarehouseId__c != null ? lstWOLI[0].XC_WarehouseId__c : warehouseIdMAp.get(lstWOLI[0].Id);
                    wrapperToGloviaSO.workOrderId  =  lstWOLI[0].workOrder.Id;
                    wrapperToGloviaSO.workOrderLineItemID  =  lstWOLI[0].Id;
                    wrapperToGloviaSO.recTypeDevName  =  lstWOLI[0].RecordType.DeveloperName;
                    wrapperToGloviaSO.requiredDate  =  lstWOLI[0].workOrder.XC_DueDate__c;

                    if(lstWOLI[0].XC_IsaDelivery__c){
                        wrapperToGloviaSO.shipToName = lstWOLI[0].WorkOrder.Account.Name;
                    }
                    else{
                        wrapperToGloviaSO.shipToName = lstWOLI[0].XC_AccountId__r.Name;
                    }

                    wrapperToGloviaSO.shipToCity  =  lstWOLI[0].XC_ShipToCity__c;
                    wrapperToGloviaSO.shipToCountry  =  lstWOLI[0].XC_ShipToCountry__c;
                    wrapperToGloviaSO.shipToStateProvince  =  lstWOLI[0].XC_ShipToStateProvince__c;
                    wrapperToGloviaSO.shipToStreet  =  lstWOLI[0].XC_ShipToStreet__c;
                    wrapperToGloviaSO.shipToZipPostalCode  =  lstWOLI[0].XC_ShipToZipPostalCode__c;
                    wrapperToGloviaSO.isDelivery  =  lstWOLI[0].XC_IsaDelivery__c;
                    wrapperToGloviaSO.dropShip  = lstWOLI[0].XC_DropShip__c;

                }

                //wrapperToGloviaSO.warehouseId='aD36E000000ChyXSAS'; 
                //wrapperToGloviaSO.shipToCity = '' ;
                //wrapperToGloviaSO.shipToCountry = '' ;
                //wrapperToGloviaSO.shipToStateProvince = '' ;
                //wrapperToGloviaSO.shipToStreet = '' ;
                //wrapperToGloviaSO.shipToZipPostalCode = '' ;


            }
            if (lstPRSent.size() != pR.size()) {
                rAndM.resultMessage = 'Order material is already sent!';
                rAndM.success = false;
                rAndM.typeMessage = 'Error';
                rAndM.titleMessage = 'Send order material';
                return rAndM;
            }

            List<ProductRequired> relatedrequired = [SELECT Id, XC_WBSElement__c from ProductRequired where XC_WorkOrderLineItem__c = :lstWOLI[0].id and XC_WBSElement__c = null];
            if (relatedrequired.size() > 0) {
                rAndM.resultMessage = 'Please fill in the WBE on the product required';
                rAndM.success = false;
                rAndM.typeMessage = 'Error';
                rAndM.titleMessage = Label.XC_CL_Error;
                return rAndM;
            }


            if (lstWOLI != null && !lstWOLI.isEmpty() && lstWOLI[0].Status != 'Approved') {
                rAndM.resultMessage = Label.XC_CL_WoliNotApproved;
                rAndM.success = false;
                rAndM.typeMessage = 'Error';
                rAndM.titleMessage = '';
                return rAndM;
            }


            List<ProductRequired> listProductRequiredsM = new List<ProductRequired>();
            listProductRequiredsM = [select id, Product2Id from ProductRequired where ParentRecordId = :lstWOLI[0].id];
            Set<Id> setProd2Id = new Set<Id>();
            for (ProductRequired p : listProductRequiredsM) {
                setProd2Id.add(p.Product2Id);
            }
            List<gii__Product2Add__c> listProd2Generic = new List<gii__Product2Add__c>();
            listProd2Generic = [select Id, Name, gii__ProductCode__c, gii__Description__c, gii__SerialControlled__c, giic_PricePerUnit__c, giic_Generic_Material__c from gii__Product2Add__c where gii__ProductReference__c IN:setProd2Id AND giic_Generic_Material__c = true];
            if (!listProd2Generic.isEmpty()) {
                rAndM.resultMessage = 'Before proceeding, remove all generic products';
                rAndM.success = false;
                rAndM.typeMessage = 'Error';
                rAndM.titleMessage = '';
                return rAndM;

            }

            //************** List<XC_UTIL_TechnicalCart.paramToGloviaSoli> wrapperToGloviaSoli= new List<XC_UTIL_TechnicalCart.paramToGloviaSoli>();

            //List<gii__Product2Add__c> prGlovia = new  List<gii__Product2Add__c>();
            List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference> prGlovia = new List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference>();
            for(ProductRequired p : pR){
                XC_UTIL_FSLLogistic.ParamGetGloviaProductReference gloPr = new XC_UTIL_FSLLogistic.ParamGetGloviaProductReference();
                gloPr.productReferenceId = p.Product2Id;
                prGlovia.add(gloPr);
            }
            //if(Schema.sObjectType.gii__Product2Add__c.isAccessible()){
            prGlovia = XC_UTIL_TechnicalCart.loadProductReferenceFromGlovia(prGlovia);
            //    prGlovia = [SELECT gii__ProductReference__c FROM gii__Product2Add__c];
            System.debug('@@@@ getAllProductRequired - prGlovia:' + prGlovia);
            //}
            system.debug('@@@@ getAllProductRequired - lstWOLI:' + lstWOLI);
            System.debug('@@@@ getAllProductRequired - Product Required List:' + pR);

            List<ProductRequired> listToUpdate = new List<ProductRequired>();
            if (!pR.isEmpty()) {
                rAndM = XC_UTIL_TechnicalCart.createSalesOrdersGlovia (wrapperToGloviaSO, pR, prGlovia);
                System.debug('??' + rAndM);

                if (rAndM.success == false && rAndM.titleMessage == 'ERROR:   Check list product errors') {

                    String errorMessage = rAndM.resultMessage;
                    List<Map<String,String>> listMap = new List<Map<String,String>>();
                    listMap = convertMessage(errorMessage);
                    Set<String> setProductCode = new Set<String>();
                    Map<String,String> mapTest = new Map<String,String>();
                    /*
                    System.debug('donato k0'+ listMap[0].keySet());
                    System.debug('donato v0'+ listMap[0].values());
                    System.debug('donato k1'+ listMap[1].keySet());
                    System.debug('donato v1'+ listMap[1].values());
                    */
                    Map<String, String> mapCodeValue = new Map<String,String>();

                    for(Map<String,String> mapo :listMap) {
                        System.debug('mapo' + mapo);
                            if(mapo.get('{prodCode')!=null){
                                setProductCode.add(mapo.get('{prodCode'));
                            }
                    }


                    System.debug('*donato' + setProductCode);
                    System.debug('*donato' + mapCodeValue);

                    /*System.debug('Donato'+ errorMessage);

                    String peppe = errorMessage.remove('(').remove(')');
                    System.debug('Donato ' + peppe);
                    List<String> sre = peppe.split('},');
                    System.debug('Donato' + sre);


                    Map<String, String> mapErroreMessage = new Map<String, String>();
                   // mapErroreMessage = (Map<String,String>) JSON.deserializeUntyped(peppe);
                   // System.debug('Donato' + mapErroreMessage);
                    if (errorMessage.contains('ProductErrorWrapper:[')) {
                        String don = errorMessage.remove('ProductErrorWrapper:[').removeEnd('])');
                        List<String> s = don.split(',');
                        System.debug('Donato Split 1' + s);
                        for (String a : s) {
                            List<String> b = a.split('=');
                            mapErroreMessage.put(b[0], b[1]);
                            System.debug('Donato for a' + b[0]);
                            System.debug('Donato for b' + b[1]);

                        }
                        System.debug('Donato Key' + mapErroreMessage.keySet());
                        System.debug('Donato Value' + mapErroreMessage.values());*/
                    List<ProductRequired> listPrc = new List<ProductRequired>();
                    listPrc = [select id, XC_ErrorMessage__c, XC_ProductCode__c from ProductRequired where XC_ProductCode__c = :setProductCode AND XC_ProductCode__c != null]  ;
                    for (ProductRequired prd : listPrc) {
                        for(Map<String, String> mapo : listMap){
                            //System.debug('*donato'+ prd.XC_ProductCode__c);
                            //System.debug('*donato'+  mapo.get('prodCode'));
                            if(prd.XC_ProductCode__c == mapo.get('{prodCode')){
                                prd.XC_ErrorMessage__c = Label.ProdWarehouseQuantity + ' :' + mapo.get('warehouseQuantity').remove('}');
                            }
                        }

                    }
                    update listPrc;


                    rAndM.resultMessage = Label.Prod_Req_Error_Msg;
                    rAndM.titleMessage = '';
                    rAndM.typeMessage = 'Error';
                }


                //      pR[0].XC_ErrorMessage__c = Label.XC_Label_ErrorMateriaRequest;
                //      		update pR;

                for (ProductRequired pr0 : pR) {
                    //  pr0.XC_ErrorMessage__c =Label.XC_Label_ErrorMateriaRequest;
                    listToUpdate.add(pr0);
                    /*wrapperToGloviaSoli = XC_LCC201_SendPRToGlovia_Controller.SetSendGlovia(wrapperToGloviaSoli,pR,pRGlovia);
                system.debug('@@@@ getAllProductRequired - wrapperToGlovia:' + wrapperToGloviaSoli);
                rAndM = CreateSOSOLIGlovia(wrapperToGloviaSoli,wrapperToGloviaSO, pR);*/


                }
                //update listToUpdate;
            }
        }
        system.debug('@@@@ getAllProductRequired - resultMessage:' + rAndM);
        system.debug('@@@@ getAllProductRequired - resultMessage:' + rAndM.resultMessage);
        system.debug('@@@@ getAllProductRequired - resultMessage:' + rAndM.success);
        system.debug('@@@@ getAllProductRequired - resultMessage:' + rAndM.titleMessage);
        //rAndM.titleMessage = 'ERROR TEST';



      return rAndM;

    }

    public static List<Map<String,String>> convertMessage(String errorMessage){
        String remove = errorMessage.remove('(').remove(')');
        List<String> listRemove = remove.split('},');
        for(String s : listRemove){
            s = s.remove('{').remove('}');
        }
        List<List<String>> listAll = new List<List<String>>();
        for(String s :listRemove){
            List<String> listF = new List<String>();
            listF = s.split(',');
            listAll.add(listF);
        }

        List<Map<String,String>> listMap = new List<Map<String,String>>();
        for(List<String> ls : listAll){
            Map<String,String> mapTes= new Map<String,String>();
            for(String s :ls){
                if(s!=null) {
                    mapTes.put(s.substringBefore('=').remove(' '), s.substringAfter('=').remove(' '));

                }

            }
            listMap.add(mapTes);
        }
        System.debug('Donato C'+ listMap);
        return listMap;


    }



    /*
   * @author Patrizia Arcidiacono -
   * @date Creation 22/06/2019
   * @description // get Country ConfigurationItem
   * @param fieldValue string
   * @param fieldName String
   * @param errorCheck boolean
   * @return string
   */

    public static string chechMandatoryField(string fieldValue, string fieldName, boolean errorCheck){
        system.debug('@@@@ chechMandatoryField - fieldValue:' + fieldValue);
        system.debug('@@@@ chechMandatoryField - fieldName:' + fieldName);
        system.debug('@@@@ chechMandatoryField - errorChecj:' + errorCheck);
        string message='';
        if(fieldValue =='' || fieldvalue == null){
            message = message + 'failed, missing ' + fieldName + ' Reference!';
            errorCheck = true;
        }
        system.debug('@@@@ chechMandatoryField - message:' + message);
        return message;
    }

    /*
    * @author Patrizia Arcidiacono/2019
    * @date Creation 01/08/2019 
    * @description mapListConfItemTechnicalMaterial
    * @param woliId string 
    * @return XC_NE_AddTechnicalItems_Controller.ResultAndMessage
    
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkAddPr(string woliId){
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        system.debug('@@@@ checkAddPr:' + woliId);
        rAndM.titleMessage = 'Add new Order material';
        rAndM.resultMessage = 'Order material added success!!';
        rAndM.typeMessage ='Success';
        rAndM.success = true;
        List<ProductRequired> prodRes = new List<ProductRequired>();
        prodRes = [select id from ProductRequired where parentRecordId =:woliId];
        system.debug('@@@@ checkAddPr - prodRes' + prodRes);
        if(prodRes.size()>0){
            rAndM.resultMessage = 'Order material is freeze, already sent!!';
            rAndM.typeMessage ='Error';
            rAndM.success = false;
            system.debug('@@@@ checkAddPr:' + rAndM.resultMessage);
            return rAndM;
        }else{
            return rAndM; }
    }




    /*
     * @author Patrizia Arcidiacono -
     * @date Creation 22/06/2019
     * @description // get Country ConfigurationItem
     * @param woliId string
     * @return List<NE__OrderItem__c>
     */

    @AuraEnabled
    public static List<NE__OrderItem__c> getCommercialItemList(Id woliId){
        Id workOrderDec = [select WorkOrder.RootWorkOrderId from workOrderLineItem WHERE Id = :woliId].workorder.RootWorkOrderId;
        system.debug('@@@@ getCommercialItemList - workOrderDec:' + workOrderDec);
        List<WorkOrder> woChildDEC = new List<WorkOrder>();
        if(Schema.sObjectType.WorkOrder.isAccessible()){
            woChildDEC = [select id, XC_Configuration_Item__c from WorkOrder where RootWorkOrderId =:workOrderDec];
        }

        system.debug('@@@@ getCommercialItemList - woChildDEC:' + woChildDEC);
        List<String> idCommCIIds = new List<String>();
        if(woChildDEC.size()>0){
            for(WorkOrder wo: woChildDEC){
                system.debug('@@@@ getCommercialItemList - wo.XC_Configuration_Item__c:' + wo.XC_Configuration_Item__c);
                idCommCIIds.add(wo.XC_Configuration_Item__c);

            }
        }
        system.debug('@@@@ getCommercialItemList - idCommCIIds:' + idCommCIIds);
        List<NE__OrderItem__c> commercialCI = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            commercialCI=  [select Id, name from NE__OrderItem__c where id in:idCommCIIds];
        }
        system.debug('@@@@ getCommercialItemList - commercialCI:' + commercialCI);
        return commercialCI;

    }

    /*
      * @author Patrizia Arcidiacono -
      * @date Creation 22/06/2019
      * @description // get Country ConfigurationItem
      * @param confItemComm id
      * @return LParamToGloviaSoli
      */

    @AuraEnabled
    public static ResultOtherPA getParamToGlovia(Id confItemComm){

        ResultOtherPA  param = new ResultOtherPA();
        param.result = false;
        system.debug('@@@@ getParamToGlovia - confItemComm:' + confItemComm);
        List<NE__OrderItem__c> confComm = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            confComm=[SELECT XC_WBE__c, XC_CMCostCenter__c from NE__OrderItem__c where id=:confItemComm];
            system.debug('@@@@ getParamToGlovia - conComm:' + confComm);

            for(NE__OrderItem__c ci : confComm){
                param.costCenter = ci.XC_CMCostCenter__c;
                param.wbeElement = ci.XC_WBE__c;
                system.debug('@@@@ getParamToGlovia - param.costCenter:' + param.costCenter);
                system.debug('@@@@ getParamToGlovia - param.wbeElement:' + param.wbeElement);

                if(ci.XC_WBE__c =='' && ci.XC_CMCostCenter__c ==''){

                    param.result = false;
                    param.message ='Operation failed!!! WBE element or costCenter missing';
                    param.titleMessage = 'Order Material';
                    param.typeMessage = 'Error';

                }else

                        param.result = true;


            }
            system.debug('@@@@ getParamToGlovia - param.result:' + param.result);
        }

        return param;
    }




}
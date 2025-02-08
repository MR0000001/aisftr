/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 20/05/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_Configuration_U_StartCongaWorkflow  - Class that recover the info from the created Quote and pass the info to the Conga call
*                                                             that start with a workflow XC_CongaTriggerQuoteContracts
*/ 

public without sharing class XC_TR_Configuration_U_StartCongaWorkflow {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_StartCongaWorkflow');

    /** 
     * @description populate Conga Field
     * @param listNew 
     * @param mapOldS
     * @param mapNewS 
     */
    public static void populateCongaField(List<NE__Order__c> listNew, Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS) {
        List<NE__Order__c> listOrderChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_Status__c','RecordTypeId'}, mapOldS, mapNewS);
        if(listOrderChanged.isEmpty()){
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<---- @205 ENTER IN populateCongaField - list order changed--> ' + listOrderChanged); 
        List<NE__Order__c> listItalySpain = new List<NE__Order__c>();
        List<NE__Order__c> listOthers = new List<NE__Order__c>();
        for(NE__Order__c o : listOrderChanged){
            if( ((o.XC_LegalEntity__c == Label.XC_CL_EndesaX || o.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy) && o.XC_Segment__c == 'B2C') || FeatureManagement.checkPermission('XC_Brazil_MVP') ){ //DCR 07/03/2022 - MVP Brazil
                listItalySpain.add(o);
            }else{
                listOthers.add(o);
            }
        }
        if(!listItalySpain.isEmpty()){
            List<NE__Order__c> orderList = checkRecordType(listItalySpain, mapOldS, mapNewS);
            if(!orderList.isEmpty()){
                startingConga(orderList);
            }
        } else if(!listOthers.isEmpty()){
            //XC_TR_Configuration_U_CongaWFCustomObj.checkRecordTypeForQuote(listOthers);
        }
    }
    
    /**
    * @date Creation 20/05/2019
    * @description Method to check record type for Configuration
    * @param listOrderChanged - List<NE__Order__c> 
    * @param mapOldS - Map<Id, SObject>
    * @param mapNewS - Map<Id, SObject>
    * @return WrapperByRecordType
    */ 
    private static List<NE__Order__c> checkRecordType(List<NE__Order__c> listOrderChanged, Map<Id, SObject> mapOldS,  Map<Id, SObject> mapNewS){
        List<NE__Order__c> orderList = new List<NE__Order__c>();
        Map<Id, NE__Order__c> mapOld = (Map<Id, NE__Order__c>) mapOldS; 
        Map<Id, NE__Order__c> mapNew = (Map<Id, NE__Order__c>) mapNews; 
        Id recTypeOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        for(NE__Order__c order : listOrderChanged){
            if(mapOld.get(order.Id).RecordTypeId != mapNew.get(order.Id).RecordTypeId && order.RecordTypeId == recTypeOrderId && order.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder){
                orderList.add(order);
            }
        }
        return orderList;
    }

    /**
    * @date Creation 20/05/2019
    * @description Method to manage Configuration for Record Type Quote
    * @param listQuoteId - List<String>
    */ 
    private static void startingConga(List<NE__Order__c> orderList) {
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = recoverInfoFromOrder(orderList);
        if(!wrapperList.isEmpty()){
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'PRECONTRACTUAL_CONDITIONS');
            List<NE__OrderItem__c> orderItemList = updateToStartConga(wrapperList);
            if(!orderItemList.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(orderItemList);
            }
        } else {
            return;
        }
    }
    
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/5/2020 
    * @param wrapperList 
    * @return void 
    **/
    public static List<NE__OrderItem__c> updateToStartConga(List<XC_UTIL_Conga.UtilWrapper> wrapperList){
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();

        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            NE__OrderItem__c orderItemStartingConga = wrapper.orderItemToBeUpdated;
            if(!String.isBlank(wrapper.templateId) && !String.isBlank(wrapper.congaQuery) && orderItemStartingConga != null && String.isEmpty(orderItemStartingConga.XC_CongaDynamicAPI__c)){ 
                String name = 'Precontractual';
                if(orderItemStartingConga.Name.contains('-')){
                    name = orderItemStartingConga.Name.substringAfter('-');
                } else {
                    name = orderItemStartingConga.Name;
                }
                String dynamicApi = '&Id=' + orderItemStartingConga.NE__OrderId__c + '&QueryId=' +  wrapper.congaQuery + '&TemplateId=' +  wrapper.templateId // ON ORDERITEM: '&Id=' + quoteItemId + '&AttachmentParentID=' + orderId +
                            + '&OFN=' +  name + ' - PRECONTRACTUAL_CONDITIONS'
                            + '&DefaultPDF=1&qmode=SalesforceFile';
                orderItemStartingConga.XC_CongaDynamicAPI__c = orderItemStartingConga.XC_CongaStaticAPI__c + dynamicApi;
                //orderItemStartingConga.XC_StartCongaProcess__c = true;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 templateId --->' + wrapper.templateId);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 congaQuery --->' + wrapper.congaQuery); 
                orderItemList.add(orderItemStartingConga);   
            } else if(wrapper.orderItemWithNoPaymentRequired != null) {
                orderItemList.add(wrapper.orderItemWithNoPaymentRequired);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 orderItemList --->' + orderItemList);
        return orderItemList;
    }
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 25/5/2020 
    * @param orderItemMap 
    * @return List<XC_UTIL_Conga.UtilWrapper> 
    **/
    public static List<XC_UTIL_Conga.UtilWrapper> populateWrapper(Map<Id, NE__OrderItem__c> orderItemMap){
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 orderItemList ---> '+ orderItemMap.values());
        Map<String,NE__OrderItem__c> mapSupportOrderItemRootId = populateUtilMap(orderItemMap);
        for(NE__OrderItem__c orderItem: orderItemMap.values()){
            NE__OrderItem__c supportOI = orderItemMap.get(orderItem.Id);
            XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
            if( (orderItem.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_NoPaymentRequired || orderItem.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_CommodityOffer) && !orderItem.XC_IsAProduct__c  && !orderItem.NE__Catalog__r.XC_LIC_Name__c.containsIgnoreCase('emobility')){
                orderItem.XC_StartCongaProcess__c = true;
                wrapper.orderItemWithNoPaymentRequired = orderItem;
                wrapperList.add(wrapper);
            }
            if(orderItem.XC_IsAProduct__c && !orderItem.NE__Catalog__r.XC_LIC_Name__c.containsIgnoreCase('emobility')){
                if(orderItem.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_NoPaymentRequired || orderItem.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_CommodityOffer){
                    orderItem.XC_StartCongaProcess__c = true;
                    wrapper.orderItemWithNoPaymentRequired = orderItem;   
                }
                String catalogName = orderItemMap.get(orderItem.Id).NE__Catalog__r.XC_LIC_Name__c;
                String categoryName = orderItemMap.get(orderItem.Id).XC_Product_Subtype__c;
                String billingModel = orderItemMap.get(orderItem.Id).XC_BillingModel__c;
                String country =  orderItemMap.get(orderItem.Id).NE__OrderId__r.XC_Country__c;
                String legalEntity = orderItemMap.get(orderItem.Id).NE__OrderId__r.XC_LegalEntity__c;
                String optyId = orderItemMap.get(orderItem.Id).NE__OrderId__r.NE__OptyId__c;
                if(billingModel.contains(Label.XC_CL_ConfigurationItem_Renting)){
                    billingModel = Label.XC_CL_ConfigurationItem_Renting;
                }
                wrapper.billingModel = billingModel;
                wrapper.catalogName = catalogName;
                wrapper.categoryName = categoryName;
                wrapper.country = country;
                wrapper.legalEntity = legalEntity;
                wrapper.optyId = optyId;
                wrapper.orderItemToBeUpdated = orderItem;  
                if( verifyScenario(orderItem, wrapper) ){
                    wrapper.orderItemToBeUpdated = orderItem; 
                    wrapperList.add(wrapper); 
                }  else if(!mapSupportOrderItemRootId.isEmpty() && mapSupportOrderItemRootId.containsKey(orderItem.Id)){
                    wrapper.orderItemToBeUpdated = mapSupportOrderItemRootId.get(orderItem.Id);
                    wrapperList.add(wrapper);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@205 wrapperList ---> '+ wrapperList);
        return wrapperList;
    }
    /**
    * @date Creation 20/05/2019
    * @description Method to recover info from order
    * @param listIds - List<String>
    * @param productNameList - Set<String>
    * @return Map<String, String>
    */ 
    private static List<XC_UTIL_Conga.UtilWrapper> recoverInfoFromOrder(List<NE__Order__c> orderList) {
        
        Map<Id, NE__OrderItem__c> orderItemMap = getOrderItemInfo(orderList);
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = populateWrapper(orderItemMap);
        return wrapperList;
    }

    /**
    * @description 
    * @author salvatore.scarpato@nttdata.com | 16/3/2020 
    * @param orderItemMap 
    * @return Map<String, NE__OrderItem__c> 
    **/
    private static Map<String, NE__OrderItem__c> populateUtilMap(Map<Id, NE__OrderItem__c> orderItemMap){
        Map<String,NE__OrderItem__c> mapSupportOrderItemRootId = new Map<String,NE__OrderItem__c>();
        for(NE__OrderItem__c orderItem: orderItemMap.values()){
            if(!String.isEmpty(orderItem.NE__Root_Order_Item__c)){
                if(!mapSupportOrderItemRootId.containsKey(orderItem.NE__Root_Order_Item__c)){
                    mapSupportOrderItemRootId.put(orderItem.NE__Root_Order_Item__c, orderItem);
                }
            }
        }
        return mapSupportOrderItemRootId;
    }
    /**
    * @description this method is needed to manage the precontractual doc creation on OK* services.
    * @author salvatore.scarpato@nttdata.com | 16/3/2020 
    * @param wrapper 
    * @return Boolean  
    **/
    private static Boolean checkIfService(XC_UTIL_Conga.UtilWrapper wrapper){
        return ( (wrapper.categoryName == Label.XC_CL_ProductSubTypeGas || wrapper.categoryName == Label.XC_CL_ProductSubTypeElectric) );
    }

    /**
    * @description check if is a bundle or it is an Ok service without the billing profile line item. This method is needed to manage the precontractual doc creation on OK* services.
    * @author salvatore.scarpato@nttdata.com | 16/3/2020 
    * @param orderItem 
    * @param wrapper 
    * @return Boolean 
    **/
    private static Boolean verifyScenario(NE__OrderItem__c orderItem, XC_UTIL_Conga.UtilWrapper wrapper){
        return ( orderItem.XC_IsAProduct__c && !checkIfService(wrapper) || (orderItem.XC_IsAProduct__c && checkIfService(wrapper) && String.isEmpty(orderItem.XC_BillingProfileLineItem__c)) );
    }
    /**
    * @date Creation 20/05/2019
    * @description Method to get quote item info
    * @param listQuoteId - List<String>
    * @return Map<Id,NE__OrderItem__c>
    */ 
    private static Map<Id, NE__OrderItem__c> getOrderItemInfo(List<NE__Order__c> orderList){
        List<String> orderItemToBeProcessedIds = XC_UTIL_Sobject.getIds(orderList);
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, Name, NE__ProdName__c, NE__OrderId__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, XC_BillingProfileLineItem__c,
                                                                       XC_CongaStaticAPI__c,XC_CongaDynamicAPI__c, XC_BillingModel__c,NE__OrderId__r.Name, NE__OrderId__r.NE__OptyId__c,
                                                                       NE__OrderId__r.NE__AccountId__r.XC_SohoType__c, XC_Product_Subtype__c,NE__OrderId__r.XC_Country__c, 
                                                                       NE__OrderId__r.XC_LegalEntity__c, XC_IsAProduct__c, NE__Root_Order_Item__c, NE__Catalog__r.XC_LIC_Name__c, 
                                                                       NE__Bundle_Configuration__c, NE__OrderId__r.RecordTypeId, NE__OrderId__r.XC_SignedByExternal__c,
                                                                       NE__OrderId__r.NE__OptyId__r.XC_Contact__r.IndividualId, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__Bundle__r.LIC_Name__c,
                                                                       NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c, XC_PaymentMethod__c, XC_StartCongaProcess__c, NE__OrderId__r.XC_SkipContractGeneration__c, NE__ProdId__c
                                                                       FROM NE__OrderItem__c  
                                                                       WHERE NE__OrderId__c  IN: orderItemToBeProcessedIds 
                                                                       AND (NE__OrderId__r.NE__AccountId__r.XC_SohoType__c = null OR NE__OrderId__r.NE__AccountId__r.XC_SohoType__c =: Label.XC_CL_Soho)
                                                                       ]);
        /*if(!quoteItemMap.isEmpty() && !String.isEmpty(quoteItemMap.values()[0].NE__OrderId__r.NE__AccountId__r.XC_SohoType__c) && quoteItemMap.values()[0].NE__OrderId__r.NE__AccountId__r.XC_SohoType__c != Label.XC_CL_Soho){
            return null;
        }*/
        return orderItemMap;
    }

        /**
    * @description Method for create contract when Signed by External is populate 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 04/11/2020 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void onAfterUpdate(Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
        startCongaWFSignedByExternal(mapOld, mapNew);
    }

    /**
    * @description Method for create contract when Signed by External is populate 
    * @author Del Prete Domenico | 4/6/2020 
    * @param mapOld 
    * @param mapNew 
    **/
    private static void startCongaWFSignedByExternal(Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
        List<NE__Order__c> listOrderChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_SignedByExternal__c'}, mapOld, mapNew);
        List<NE__Order__c> listOrderChangedFiltered = new  List<NE__Order__c>();
        Id recTypeOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        for(NE__Order__c ord : listOrderChanged){
            if(String.isBlank(mapOld.get(ord.Id).XC_SignedByExternal__c) && ord.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy 
                && ord.RecordTypeId == recTypeOrderId){
                listOrderChangedFiltered.add(ord);
            }
        }
        if(listOrderChanged.isEmpty() && listOrderChangedFiltered.isEmpty()){
            return;
        }
        Map<Id, NE__OrderItem__c> mapIdOrderItem = getOrderItemInfo(listOrderChangedFiltered);
        Map<Id, NE__OrderItem__c> mapIdOrderItemFiltered = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c ordItem : mapIdOrderItem.values()){
            if(!String.isBlank(ordItem.XC_BillingProfileLineItem__c) && String.isBlank(ordItem.NE__Bundle_Configuration__c)){
                mapIdOrderItemFiltered.put(ordItem.Id, ordItem);
            }
        }
        if(mapIdOrderItem.isEmpty() || mapIdOrderItemFiltered.isEmpty()){
            return;
        }
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = XC_TR_ConfigurationItem_U_StartCongaWF.getOrderInfo(mapIdOrderItemFiltered, mapIdOrderItemFiltered.values(), false);
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            if(XC_TR_ConfigurationItem_U_StartCongaWF.checkEmobilityScenarioAndRecordType(wrapper)) {
                return;
            }
        }
        XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CONTRACT_TO_SIGN');
        List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
        if(!wrapperList.isEmpty()){
            orderItemToUpdateList = XC_TR_ConfigurationItem_U_StartCongaWF.startingCongaWorkflowOnBundle(wrapperList, 'isInsert');
        }
        if(!orderItemToUpdateList.isEmpty()){
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            XC_UTIL_SObject.updateListRecords(orderItemToUpdateList);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }
    }
}
/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 08/05/2020
* @date Modification dd/mm/yyyy
* @description  – XC_TR_ConfItem_U_StartCongaWF_PenalCheck  - Util class for XC_TR_ConfigurationItem_U_StartCongaWF used for manage the penalty value
*/ 
public class XC_TR_ConfItem_U_StartCongaWF_PenalCheck {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_StartCongaWF'); 
    
    public static void forPenalty(List<NE__OrderItem__c> orderItemPenaltiesList){
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = getOrderInfoForPenalty(orderItemPenaltiesList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapperList--> ' + wrapperList);
        if(wrapperList.isEmpty()){
            return;
        }
        //XC_TR_ConfigurationItem_U_StartCongaWF.getPenaltyValue(wrapperList);
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            if(XC_TR_ConfigurationItem_U_StartCongaWF.checkEmobilityScenario(wrapper)) { 
                return;
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ orderItemPenaltiesList--> ' + orderItemPenaltiesList);
        if(!orderItemPenaltiesList.isEmpty()){
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CONTRACT_TO_SIGN');
        }
        if(!wrapperList.isEmpty()){
            List<NE__OrderItem__c> orderItemList = startingCongaWorkflowOnBundle(wrapperList);
            System.enqueueJob(new XC_TR_ConfigurationItem_U_StartCongaWF.ManageDMLQueuable(orderItemList));
        }
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/6/2020 
    * @param orderItemPenaltiesList 
    * @return void 
    **/
    public static void forItalianPV(List<NE__OrderItem__c> orderItemList){
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        Map<Id, NE__OrderItem__c> orderItemMap = XC_TR_ConfigurationItem_U_StartCongaWF.queryOnOrderItem(orderItemList);
        wrapperList = XC_TR_ConfigurationItem_U_StartCongaWF.getOrderInfo(orderItemMap, orderItemList, true);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapperList--> ' + wrapperList);
        if(wrapperList.isEmpty()){
            return;
        }
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            if(XC_TR_ConfigurationItem_U_StartCongaWF.checkEmobilityScenario(wrapper)) { 
                return;
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ orderItemItalyPVList--> ' + orderItemList);
        
        XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CONTRACT_TO_SIGN');
        List<NE__OrderItem__c> orderItemListToUpdate = startingCongaWorkflowOnBundle(wrapperList);
        if(!orderItemListToUpdate.isEmpty()){
            System.enqueueJob(new XC_TR_ConfigurationItem_U_StartCongaWF.ManageDMLQueuable(orderItemListToUpdate));
        }
        
    }

        /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 21/5/2021 
    * @param orderItemPenaltiesList 
    * @return void 
    **/
    public static void forChile(List<NE__OrderItem__c> orderItemList){
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        Map<Id, NE__OrderItem__c> orderItemMap = XC_TR_ConfigurationItem_U_StartCongaWF.queryOnOrderItem(orderItemList);
        wrapperList = XC_TR_ConfigurationItem_U_StartCongaWF.getOrderInfo(orderItemMap, orderItemList, true);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapperList--> ' + wrapperList);
        if(wrapperList.isEmpty()){
            return;
        }
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
            if(XC_TR_ConfigurationItem_U_StartCongaWF.checkEmobilityScenario(wrapper)) { 
                return;
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ orderItemItalyPVList--> ' + orderItemList);
        
        XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CONTRACT_TO_SIGN'); 
        List<NE__OrderItem__c> orderItemListToUpdate = startingCongaWorkflowOnBundle(wrapperList); 
        if(!orderItemListToUpdate.isEmpty()){ 
            System.enqueueJob(new XC_TR_ConfigurationItem_U_StartCongaWF.ManageDMLQueuable(orderItemListToUpdate)); 
        } 
    } 

    private static Boolean checkHomix(NE__OrderItem__c orderItem){
        return orderItem.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && orderItem.XC_Product_Subtype__c == label.XC_CL_ProductSubtypeSmart;
    }

    /**
    * @description 
    * @author Del Prete Domenico && Salvatore Scarpato | 8/5/2020 
    * @param orderItemToBeProcessedList 
    * @return List<XC_UTIL_Conga.UtilWrapper> 
    **/
    private static List<XC_UTIL_Conga.UtilWrapper> getOrderInfoForPenalty(List<NE__OrderItem__c> orderItemToBeProcessedList){
        Map<String, NE__OrderItem__c> mapBundleIdProductItem = new Map<String, NE__OrderItem__c>();
        List<String> orderItemToBeProcessedIds = XC_UTIL_Sobject.getIds(orderItemToBeProcessedList);
        List<String> bundleIdChecked = new List<String>();
        List<String> serviceIdChecked = new List<String>();
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        Id configOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__OrderId__r.RecordTypeId,NE__OrderId__r.NE__AccountId__r.XC_SohoType__c,NE__Bundle_Configuration__c,NE__Catalog__r.XC_LIC_Name__c,
                                                                        NE__Bundle_Configuration__r.NE__Catalog__r.XC_LIC_Name__c, XC_Product_Subtype__c,XC_CongaStaticAPI__c,XC_Product_Type__c,
                                                                        NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.XC_LegalEntity__c,NE__OrderId__r.XC_Country__c,NE__ProdId__r.XC_LIC_Product_Name__c,
                                                                        NE__ProdName__c, NE__Bundle_Configuration__r.NE__ProdName__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__r.IndividualId,
                                                                        NE__Bundle__r.LIC_Name__c,NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c,NE__Bundle_Configuration__r.NE__Bundle__r.LIC_Name__c,
                                                                        NE__OrderId__r.XC_SignedByExternal__c, XC_BillingModel__c,
                                                                        NE__OrderId__r.NE__OptyId__r.XC_PrincingRegion__c,
                                                                        NE__Root_Order_Item__c,NE__Root_Order_Item__r.NE__Catalog__r.XC_LIC_Name__c,NE__Root_Order_Item__r.NE__ProdName__c,
                                                                        NE__OrderId__r.XC_SkipContractGeneration__c, NE__ProdId__c, NE__Root_Order_Item__r.NE__ProdId__c
                                                                        FROM NE__OrderItem__c 
                                                                        WHERE (NE__Bundle_Configuration__c IN: orderItemToBeProcessedIds OR Id IN: orderItemToBeProcessedIds) 
                                                                        AND XC_Product_Type__c =: Label.XC_CL_ProductTypeEquipment
                                                                        AND XC_Segment__c = 'B2C' AND NE__OrderId__r.NE__Type__c = 'InOrder']);
        
         
        for(NE__OrderItem__c orderitemprod : orderItemMap.values()){
            Boolean checkHomix = checkHomix(orderitemprod);
            if(!String.isEmpty(orderitemprod.NE__Bundle_Configuration__c)){
                mapBundleIdProductItem.put(orderitemprod.NE__Bundle_Configuration__c, orderitemprod);
            } else { 
                if(checkHomix){
                    mapBundleIdProductItem.put(orderitemprod.Id, orderitemprod);
                } else {
                    mapBundleIdProductItem.put(orderitemprod.NE__Root_Order_Item__c, orderitemprod);
                }
            }
        }
        String recordTypeId = '';
        String sohoType = '';
        String fileName = '';
        String categoryName = '';
        String optyId = '';
        String legalEntity ='';
        String country = '';
        String contactId = '';
        String individualId = '';
        String region = '';
        String signedBy = '';
        String billingModel = '';
        String catalogName  = '';
        String productServiceName  = '';
        String productId = '';

        for(NE__OrderItem__c oi : orderItemToBeProcessedList){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ Specific order Item--> ' + oi);
            if(!bundleIdChecked.contains(oi.Id) && !bundleIdChecked.contains(oi.NE__Root_Order_Item__c)){               
                XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
                if(mapBundleIdProductItem.containsKey(oi.Id) && !bundleIdChecked.contains(oi.Id)){
                    bundleIdChecked.add(oi.Id);
                    Boolean checkHomix = checkHomix(oi);
                    if(mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.XC_SkipContractGeneration__c){
                        continue;
                    }
                    recordTypeId = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.RecordTypeId;
                    sohoType = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.NE__AccountId__r.XC_SohoType__c;
                    categoryName = oi.XC_Product_Subtype__c;
                    optyId =  mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.NE__OptyId__c;   
                    legalEntity = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.XC_LegalEntity__c;
                    country = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.XC_Country__c;
                    contactId = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                    individualId = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.NE__OptyId__r.XC_Contact__r.IndividualId;
                    region = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.NE__OptyId__r.XC_PrincingRegion__c;
                    signedBy = mapBundleIdProductItem.get(oi.Id).NE__OrderId__r.XC_SignedByExternal__c;
                    billingModel = oi.XC_BillingModel__c;
                    catalogName = checkHomix ? mapBundleIdProductItem.get(oi.Id).NE__Catalog__r.XC_LIC_Name__c : mapBundleIdProductItem.get(oi.Id).NE__Bundle_Configuration__r.NE__Catalog__r.XC_LIC_Name__c;
                    fileName = checkHomix ? mapBundleIdProductItem.get(oi.Id).NE__ProdName__c : mapBundleIdProductItem.get(oi.Id).NE__Bundle_Configuration__r.NE__ProdName__c;
                    productServiceName = mapBundleIdProductItem.get(oi.Id).NE__ProdId__r.XC_LIC_Product_Name__c;
                    productId = mapBundleIdProductItem.get(oi.Id).NE__ProdId__c;
                    wrapper.bundleName = mapBundleIdProductItem.get(oi.Id).NE__Bundle_Configuration__r.NE__Bundle__r.LIC_Name__c;
                    wrapper.orderItemToBeUpdated = oi;
                } else if(mapBundleIdProductItem.containsKey(oi.NE__Root_Order_Item__c) && !serviceIdChecked.contains(oi.NE__Root_Order_Item__c)){
                    if(mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.XC_SkipContractGeneration__c){
                        continue;
                    }
                    serviceIdChecked.add(oi.NE__Root_Order_Item__c);
                    recordTypeId = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.RecordTypeId;
                    sohoType = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.NE__AccountId__r.XC_SohoType__c;
                    categoryName = oi.XC_Product_Subtype__c;
                    optyId =  mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.NE__OptyId__c;   
                    legalEntity = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.XC_LegalEntity__c;
                    country = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.XC_Country__c;
                    contactId = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                    individualId = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.NE__OptyId__r.XC_Contact__r.IndividualId;
                    region = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.NE__OptyId__r.XC_PrincingRegion__c;
                    signedBy = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__OrderId__r.XC_SignedByExternal__c;
                    billingModel = oi.XC_BillingModel__c;
                    catalogName = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__Root_Order_Item__r.NE__Catalog__r.XC_LIC_Name__c;
                    fileName = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__Root_Order_Item__r.NE__ProdName__c;
                    productServiceName = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__Root_Order_Item__r.NE__ProdName__c;
                    productId = mapBundleIdProductItem.get(oi.NE__Root_Order_Item__c).NE__Root_Order_Item__r.NE__ProdId__c;
                    wrapper.photovoltaicId = oi.NE__Root_Order_Item__c;
                    wrapper.bundleName = '';
                    wrapper.orderItemToBeUpdated = oi;  
                } else {
                    continue;
                }
                
                if(!String.isEmpty(sohoType) && sohoType != Label.XC_CL_Soho){
                    wrapper.checkSohoType = false;
                }
                wrapper.catalogName = catalogName;
                wrapper.equipmentName = productServiceName;
                wrapper.productServiceName = productServiceName;
                wrapper.legalEntity = legalEntity; 
                wrapper.categoryName = categoryName;
                wrapper.country = country;
                if(recordTypeId == configOrderId ){ 
                    wrapper.checkOnRecordType = true;
                }
                wrapper.optyId = optyId;
                wrapper.contactId = contactId;
                wrapper.individualId = individualId;
                
                wrapper.region = region;
                
                wrapper.billingModel = billingModel;
                String nameOi = '';
                if(!String.isBlank(oi.Name)){
                    nameOi = oi.Name.remove('OI-');
                }
                if(fileName.contains('-')){
                    fileName = fileName.remove('-');
                }
                if(String.isBlank(signedBy)){
                    wrapper.fileName = fileName + ' ' +  nameOi + ' - CONTRACT_TO_SIGN';
                } else {
                    wrapper.fileName = fileName + ' ' +  nameOi + ' - CONTRACT_SIGNED';
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ wrapper--> ' + wrapper);
                wrapperList.add(wrapper); 
            }  
        }
        return wrapperList;
    }

      /**
    * @description Create the conga field that is passed to the workflow in order to generate the document
                   using the conga trigger add-on. It generates 3 types of doc categories: CREDIT_ASSIGNMENT_TO_SIGN, CONTRACT_TO_SIGN and CONTRACT_SIGNED
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 08/05/2020
    * @param wrapperList List<XC_UTIL_Conga.UtilWrapper>
    * @param triggerEvent String
    * @return List<NE__OrderItem__c> orderItemsToBeUpdated
    */
    @TestVisible
    private static List<NE__OrderItem__c> startingCongaWorkflowOnBundle(List<XC_UTIL_Conga.UtilWrapper> wrapperList){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ final wrapperList--> ' + wrapperList);
        List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
        List<Asset> listOfAssetToUpdate = new List<Asset>();
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){     
            Boolean contractGenerated = false;
            if(!String.isBlank(wrapper.templateId) && !String.isBlank(wrapper.congaQuery) ){
                String dynamicApi = '&Id=' + wrapper.orderItemToBeUpdated.NE__OrderId__c + '&QueryId=' + wrapper.congaQuery + '&TemplateId=' +  wrapper.templateId + '&OFN='+ wrapper.fileName
                + '&DefaultPDF=1&qmode=SalesforceFile';
                if(wrapper.fileName.contains(Label.XC_CL_ContractValueForConga)){
                    contractGenerated = true;
                }
                NE__OrderItem__c orItem = new NE__OrderItem__c(
                        Id = wrapper.orderItemToBeUpdated.Id,
                        //XC_PenaltyValue__c = wrapper.penaltyValue,
                        XC_CongaDynamicAPI__c = wrapper.orderItemToBeUpdated.XC_CongaStaticAPI__c + dynamicApi,
                        XC_ContractGenerated__c = contractGenerated);
                orderItemToUpdateList.add(orItem);
            }
        }
        return  orderItemToUpdateList;
    }
}
/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 12/08/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_ConfigurationItem_U_StartCongaWF  - Class that recover the info from Configuration Item and related objectwhen the billingProfileLineItem is populated and pass 
*                                                           the info to the Conga call that start with a workflow  
*/ 

public without sharing class XC_TR_ConfigurationItem_U_StartCongaWF {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_StartCongaWF');  

    private class MapUtilWrapper{
        Map<String,NE__OrderItem__c> productNameMap = new Map<String,NE__OrderItem__c>();
        Map<String, Boolean> mapProductBundle = new Map<String, Boolean>(); 
    } 
    /**
    * @description  method called by the configuration item trigger in insert. Due to the B2W logic that blanks the
    *               billing model field, the insert method works only for usage billing model, for the others 
    *               it's needed the onUpdate method, that is triggered by the change of billing model field itself.
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param orderItemList List<NE__OrderItem__c> 
    */
    public static void onInsert(List<NE__OrderItem__c> orderItemList) { 
        String triggerEvent = 'isInsert';
        List<NE__OrderItem__c> orderItemToUpdate = startCongaOnInsert(orderItemList, triggerEvent);
        if(orderItemToUpdate!= null && !orderItemToUpdate.isEmpty()){
            if(System.isQueueable()){
                manageDMLfuture(JSON.serialize(orderItemToUpdate));
            } else {
                //XC_UTIL_RESTCallout.sleep(4000);
                System.enqueueJob(new ManageDMLQueuable(orderItemToUpdate));
            }
        }
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 9/5/2020  
    * @param mapOld 
    * @param mapNew 
    **/
    public static void onAfterUpdate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'XC_BillingModel__c'};
        List<NE__OrderItem__c> orderItemUpdatedList = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(orderItemUpdatedList.isEmpty()){
            return;
        }
        List<NE__OrderItem__c>  orderItemForPenalitiesList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c>  orderItemPVItalyList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c>  orderItemChile = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c>  orderItemToUpdateList = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c orderItemToCheck : orderItemUpdatedList){
            if(XC_TR_ConfigurationItem_U_StartCongaWF_U.checkOnBMUpdate(orderItemToCheck,mapOld, mapNew)){
                if(orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_EndesaX || 
                   orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain){
                    orderItemForPenalitiesList.add(orderItemToCheck);
                    
                } else if(orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy ||
                          orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia){
                    orderItemPVItalyList.add(orderItemToCheck);
                } else if(orderItemToCheck.XC_LegalEntityFormula__c == 'EnelX' ||
                          orderItemToCheck.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilityChile){
                    orderItemChile.add(orderItemToCheck);
                }
            }
        } 
        if(!orderItemForPenalitiesList.isEmpty()){
            XC_TR_ConfItem_U_StartCongaWF_PenalCheck.forPenalty(orderItemForPenalitiesList);
        }
        if(!orderItemPVItalyList.isEmpty()){
            XC_TR_ConfItem_U_StartCongaWF_PenalCheck.forItalianPV(orderItemPVItalyList);
        }   
        if(!orderItemChile.isEmpty()){
            XC_TR_ConfItem_U_StartCongaWF_PenalCheck.forChile(orderItemChile);
        }
    }
    /** 
    * @description method called by the configuration item trigger in update. Because the billing model, when different
    *              from Usage, is changed in update and not in insert, it's needed that the change of both XC_BillingProfileLineItem__c
    *              and XC_BillingModel__c are tracked.
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param mapOld Map<Id, NE__OrderItem__c> 
    * @param mapNew Map<Id, NE__OrderItem__c> 
    */
    public static void onUpdate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) { 
        Boolean isFromBillingModel = false;
        String triggerEvent = 'isUpdate';
        List<String> fieldList = new List<String>{'XC_BillingProfileLineItem__c', 'XC_CreditAssignmentAvailable__c','XC_CityCode__c','XC_StartCongaProcess__c',
                                                    'XC_Subordinate__c','XC_HouseType__c','XC_Sheet__c','XC_Particle__c'};
        
        List<NE__OrderItem__c> orderItemUpdatedList = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(orderItemUpdatedList.isEmpty()){
            return;
        }
        List<NE__OrderItem__c>  orderItemList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c>  orderItemListCredit = new List<NE__OrderItem__c>();
        Boolean creditAssignment = false;
        for(NE__OrderItem__c orderItemToCheck : orderItemUpdatedList){
            if(XC_TR_ConfigurationItem_U_StartCongaWF_U.checkBillingProfileLineItemChange(orderItemToCheck,mapOld, mapNew) ){
                orderItemList.add(orderItemToCheck);
            } else if (XC_TR_ConfigurationItem_U_StartCongaWF_U.checkCreditAssignmentAvailable(orderItemToCheck,mapOld, mapNew)){
                creditAssignment = true;
                orderItemListCredit.add(orderItemToCheck);
            } 
        }
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        List<XC_UTIL_Conga.UtilWrapper> wrapperListCreditAssignment = new List<XC_UTIL_Conga.UtilWrapper>();
        List<XC_UTIL_Conga.UtilWrapper> finalWrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        if(creditAssignment){
            wrapperListCreditAssignment = getOrderInfoByCreditAssignment(orderItemListCredit);
            finalWrapperList.addAll(wrapperListCreditAssignment);
        }
        if(!orderItemList.isEmpty()){
            Map<Id, NE__OrderItem__c> orderItemMap = queryOnOrderItem(orderItemList);
            wrapperList = getOrderInfo(orderItemMap, orderItemList, isFromBillingModel);
            //getPenaltyValue(wrapperList);
            finalWrapperList.addAll(wrapperList);
        }
        /*if(!orderItemForPenalitiesList.isEmpty()){
            XC_TR_ConfItem_U_StartCongaWF_PenalCheck.forPenalty(orderItemForPenalitiesList);
            return;
        }*/
        for(XC_UTIL_Conga.UtilWrapper wrapper : finalWrapperList){
            if(checkEmobilityScenarioAndRecordType(wrapper) && !wrapper.noPaymentMethodRequired) {
                return;
            }
        } 
        // queryOnCongaTemplates(wrapperList);
        // In the class XC_UTIL_Conga it's retrieved the correct conga template id
        if(creditAssignment){
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperListCreditAssignment, 'CREDIT_ASSIGNMENT_TO_SIGN');
        }
        if(!orderItemList.isEmpty()){
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CONTRACT_TO_SIGN');
        }
        if(!wrapperList.isEmpty()){
            startingCongaWorkflowOnBundle(wrapperList, triggerEvent);

            //generate XC_DocumentTypeRecords for External Signature Case
            List<XC_DocumentType__c> docTypesToInsert = new List<XC_DocumentType__c>();
            List<String> orderIdList = new List<String>();
            Set<String> orderIdSet = new Set<String>();
            Map<String, List<String>> mapOderProductCategory = new Map<String, List<String>>();
            for(XC_UTIL_Conga.UtilWrapper wr : wrapperList){
                if(wr.isExternallySigned){
                    orderIdList.add(wr.orderItemToBeUpdated.NE__OrderId__c);
                    orderIdSet.add(wr.orderItemToBeUpdated.NE__OrderId__c);
                    if(mapOderProductCategory.get(wr.orderItemToBeUpdated.NE__OrderId__c) != null){
                        mapOderProductCategory.get(wr.orderItemToBeUpdated.NE__OrderId__c).add(wr.orderItemToBeUpdated.XC_Product_Subtype__c);
                    }else{
                        List<String> listProdCategory = new List<String>();
                        listProdCategory.add(wr.orderItemToBeUpdated.XC_Product_Subtype__c);
                        mapOderProductCategory.put(wr.orderItemToBeUpdated.NE__OrderId__c, listProdCategory);
                    }
                }
            }
            Map<Id, Ne__Order__c> orderMap = new Map<Id, Ne__Order__c>([SELECT Id, (SELECT Id FROM Document_Types__r WHERE Category__c = 'SF_CONTRACT_TO_SIGN') FROM Ne__Order__c WHERE Id IN: orderIdSet]);
            for(String idSet : orderIdSet){
                if(orderMap.containsKey(idSet) && !orderMap.get(idSet).Document_Types__r.isEmpty()){
                    continue;
                }
                Integer numbOfFiles = 0;
                for(String idList: orderIdList ){
                    if(idSet == idList){
                        numbOfFiles++;
                    }
                }
				String prodCategoryList = String.join(mapOderProductCategory.get(idSet),',');
                XC_DocumentType__c docTypeToSign = new XC_DocumentType__c(
                    Category__c = 'SF_CONTRACT_TO_SIGN',
                    XC_Configuration__c = idSet,
                    numberOfFiles__c = numbOfFiles,
                	XC_ContractProductCategory__c = prodCategoryList);

                docTypesToInsert.add(docTypeToSign);
            }
            if(!docTypesToInsert.isEmpty()){
                XC_UTIL_SObject.insertListRecords(docTypesToInsert);
            }
        }
        if(!wrapperListCreditAssignment.isEmpty()){
            startingCongaWorkflowOnBundle(wrapperListCreditAssignment, triggerEvent);
        }
    }

    /**
    * @description call the util conga class in order to retrieve the template id related to the order.
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param orderItemList List<NE__OrderItem__c>  
    * @param triggerEvent String
    * @return List<NE__OrderItem__c> orderItemsToBeUpdated
    */
    public static List<NE__OrderItem__c> startCongaOnInsert(List<NE__OrderItem__c> orderItemList, String triggerEvent){
        Boolean isFromBillingModel = false;
        List<NE__OrderItem__c> orderItemToBeProcessedList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemToBeProcessedForCreditAssignmentList = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ordIt : orderItemList){
            if(XC_TR_ConfigurationItem_U_StartCongaWF_U.firstCheckOnInsert(ordIt)) {
                orderItemToBeProcessedList.add(ordIt);
            }
            if(XC_TR_ConfigurationItem_U_StartCongaWF_U.secondCheckOnInsert(ordIt)){
                orderItemToBeProcessedForCreditAssignmentList.add(ordIt);
            }
        }
        if(orderItemToBeProcessedList.isEmpty() && orderItemToBeProcessedForCreditAssignmentList.isEmpty()){
            return new List<NE__OrderItem__c>();
        } 
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        if(!orderItemToBeProcessedList.isEmpty()){
            Map<Id, NE__OrderItem__c> orderItemMap = queryOnOrderItem(orderItemToBeProcessedList);
            wrapperList = getOrderInfo(orderItemMap,orderItemToBeProcessedList,isFromBillingModel);
            //getPenaltyValue(wrapperList);
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                if(checkEmobilityScenario(wrapper)) {
                    return new List<NE__OrderItem__c>();
                }
            }
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CONTRACT_TO_SIGN'); 
        }

        if(!orderItemToBeProcessedForCreditAssignmentList.isEmpty()){
            wrapperList = getOrderInfoByCreditAssignment(orderItemToBeProcessedForCreditAssignmentList);
            for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){
                if(checkEmobilityScenario(wrapper)) {
                    return new List<NE__OrderItem__c>();
                }
            }
            XC_UTIL_Conga.queryOnCongaTemplates(wrapperList, 'CREDIT_ASSIGNMENT_TO_SIGN'); 
        }

        List<NE__OrderItem__c> orderItemsToBeUpdated = new List<NE__OrderItem__c>();
        if(!wrapperList.isEmpty()){
            List<NE__OrderItem__c> orderItemListToUpdate = startingCongaWorkflowOnBundle(wrapperList, triggerEvent);
            if(orderItemListToUpdate != null && !orderItemListToUpdate.isEmpty()){
                orderItemsToBeUpdated.addAll(orderItemListToUpdate);
            }

            //generate XC_DocumentTypeRecords for External Signature Case
            List<XC_DocumentType__c> docTypesToInsert = new List<XC_DocumentType__c>();
            List<String> orderIdList = new List<String>();
            Set<String> orderIdSet = new Set<String>();
            Map<String, List<String>> mapOderProductCategory = new Map<String, List<String>>();
            for(XC_UTIL_Conga.UtilWrapper wr : wrapperList){
                if(wr.isExternallySigned){
                    orderIdList.add(wr.orderItemToBeUpdated.NE__OrderId__c);
                    orderIdSet.add(wr.orderItemToBeUpdated.NE__OrderId__c);
                    if(mapOderProductCategory.get(wr.orderItemToBeUpdated.NE__OrderId__c) != null){
                        mapOderProductCategory.get(wr.orderItemToBeUpdated.NE__OrderId__c).add(wr.orderItemToBeUpdated.XC_Product_Subtype__c);
                    }else{
                        List<String> listProdCategory = new List<String>();
                        listProdCategory.add(wr.orderItemToBeUpdated.XC_Product_Subtype__c);
                        mapOderProductCategory.put(wr.orderItemToBeUpdated.NE__OrderId__c, listProdCategory);
                    }
                }
            }
            Map<Id, Ne__Order__c> orderMap = new Map<Id, Ne__Order__c>([SELECT Id, (SELECT Id FROM Document_Types__r WHERE Category__c = 'SF_CONTRACT_TO_SIGN') FROM Ne__Order__c WHERE Id IN: orderIdSet]);
            for(String idSet : orderIdSet){
                if(orderMap.containsKey(idSet) && !orderMap.get(idSet).Document_Types__r.isEmpty()){
                    continue;
                }
                Integer numbOfFiles = 0;
                for(String idList: orderIdList ){
                    if(idSet == idList){
                        numbOfFiles++;
                    }
                }
                String prodCategoryList = String.join(mapOderProductCategory.get(idSet),',');
                XC_DocumentType__c docTypeToSign = new XC_DocumentType__c(
                    Category__c = 'SF_CONTRACT_TO_SIGN',
                    XC_Configuration__c = idSet,
                    numberOfFiles__c = numbOfFiles,
                    XC_ContractProductCategory__c = prodCategoryList);

                docTypesToInsert.add(docTypeToSign);
            }
            if(!docTypesToInsert.isEmpty()){
                XC_UTIL_SObject.insertListRecords(docTypesToInsert);
            }
        }
        return orderItemsToBeUpdated;   
    }

    /**
    * @description Create the conga field that is passed to the workflow in order to generate the document
                   using the conga trigger add-on. It generates 3 types of doc categories: CREDIT_ASSIGNMENT_TO_SIGN, CONTRACT_TO_SIGN and CONTRACT_SIGNED
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param wrapperList List<XC_UTIL_Conga.UtilWrapper>
    * @param triggerEvent String
    * @return List<NE__OrderItem__c> orderItemsToBeUpdated
    */
    public static List<NE__OrderItem__c> startingCongaWorkflowOnBundle(List<XC_UTIL_Conga.UtilWrapper> wrapperList, String triggerEvent){
        List<NE__OrderItem__c> orderItemToUpdateList = new List<NE__OrderItem__c>();
        List<Asset> listOfAssetToUpdate = new List<Asset>();
        for(XC_UTIL_Conga.UtilWrapper wrapper : wrapperList){       
            Boolean contractGenerated = false;     
            if(!String.isBlank(wrapper.templateId) && !String.isBlank(wrapper.congaQuery) ){
                String dynamicApi = '&Id=' + wrapper.orderItemToBeUpdated.NE__OrderId__c + '&QueryId=' + wrapper.congaQuery + '&TemplateId=' +  wrapper.templateId + '&OFN='+ wrapper.fileName
                + '&DefaultPDF=1&qmode=SalesforceFile';
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@ START CONGA ON ORDER ITEM dynamicApi--> ' + dynamicApi);
                if(wrapper.fileName.contains(Label.XC_CL_ContractValueForConga)){
                    contractGenerated = true;
                }
                if(triggerEvent == 'isInsert'){
                    NE__OrderItem__c orItem = new NE__OrderItem__c(
                        Id = wrapper.orderItemToBeUpdated.Id,
                        //XC_PenaltyValue__c = wrapper.penaltyValue,
                        XC_CongaDynamicAPI__c = wrapper.orderItemToBeUpdated.XC_CongaStaticAPI__c + dynamicApi,
                        XC_ContractGenerated__c = contractGenerated);
                        orderItemToUpdateList.add(orItem);
                } else if(triggerEvent == 'isUpdate'){
                    wrapper.orderItemToBeUpdated.XC_ContractGenerated__c = contractGenerated;
                    wrapper.orderItemToBeUpdated.XC_CongaDynamicAPI__c = wrapper.orderItemToBeUpdated.XC_CongaStaticAPI__c + dynamicApi;
                    //wrapper.orderItemToBeUpdated.XC_PenaltyValue__c = wrapper.penaltyValue;
                }
            }
        }
        return  orderItemToUpdateList;
    }
    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 4/6/2020 
    * @param orderItemToBeProcessedList 
    * @return Map<Id, NE__OrderItem__c> 
    **/
    public static Map<Id, NE__OrderItem__c> queryOnOrderItem(List<NE__OrderItem__c> orderItemToBeProcessedList){
        List<String> orderItemToBeProcessedIds = XC_UTIL_Sobject.getIds(orderItemToBeProcessedList);
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, Name,NE__OrderId__c,XC_BillingModel__c, XC_CongaDynamicAPI__c,XC_CongaStaticAPI__c,NE__OrderId__r.XC_SignedByExternal__c,
                                                                        XC_BillingProfileLineItem__c,NE__ProdName__c, XC_Product_Type__c, XC_Product_Subtype__c, 
                                                                        NE__OrderId__r.RecordTypeId, NE__Bundle_Configuration__c,NE__OrderId__r.XC_LegalEntity__c,
                                                                        NE__Catalog__r.XC_LIC_Name__c,NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.XC_Country__c,
                                                                        NE__OrderId__r.NE__AccountId__r.XC_SohoType__c, NE__OrderId__r.NE__OptyId__r.XC_PrincingRegion__c,
                                                                        NE__OrderId__r.NE__OptyId__r.XC_Contact__r.IndividualId,NE__OrderId__r.NE__Type__c,
                                                                        NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__Bundle__r.LIC_Name__c, NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c,
                                                                        NE__OrderId__r.XC_SkipContractGeneration__c,  NE__ProdId__c,
                                                                        NE__OrderId__r.XC_ManualLogisticActivities__c, NE__OrderId__r.XC_DelegatedSignature__c
                                                                        FROM NE__OrderItem__c 
                                                                        WHERE Id IN: orderItemToBeProcessedIds AND NE__Root_Order_Item__c = '' AND XC_Segment__c = 'B2C' AND NE__OrderId__r.NE__Type__c = 'InOrder']);
        return orderItemMap;
    }

    /**
    * @description
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @param orderItemToBeProcessedList List<NE__OrderItem__c>
    * @param isFromBillingModel String
    * @return List<XC_UTIL_Conga.UtilWrapper>  wrapperList
    */
    public static List<XC_UTIL_Conga.UtilWrapper> getOrderInfo(Map<Id, NE__OrderItem__c> orderItemMap,List<NE__OrderItem__c> orderItemToBeProcessedList,Boolean isFromBillingModel){
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();

        List<String> orderItemToBeProcessedIds = XC_UTIL_Sobject.getIds(orderItemToBeProcessedList);
        List<String> subTypeList = new List<String>();
        List<String> oppListId = new List<String>();
        Id configOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        for(NE__OrderItem__c orderItem : orderItemToBeProcessedList){
            subTypeList.add(orderItem.XC_Product_Subtype__c);
            if(orderItem.XC_Product_Subtype__c == Label.XC_CL_Subtype_Photovoltaic){
                subTypeList.add('PhotovoltaicPP');
                subTypeList.add('Photovoltaic PP');
            } else if(orderItem.XC_Product_Subtype__c == 'Boiler 110'){
                subTypeList.add(Label.XC_CL_ProductSubtypeBoiler);
            }
        }
        for(NE__OrderItem__c orderItem : orderItemMap.values()){
            oppListId.add(orderItem.NE__OrderId__r.NE__OptyId__c);
        }
        MapUtilWrapper mapWrapper = getProductName(orderItemToBeProcessedIds, subTypeList, oppListId);
        Map<String,NE__OrderItem__c> productNameMap = mapWrapper.productNameMap;                                            
        Map<String, Boolean> booleanProductMap = mapWrapper.mapProductBundle;    
        for(NE__OrderItem__c orItem : orderItemToBeProcessedList){
            // Check if the contract generation has to be skipped
            if(orderItemMap.containsKey(orItem.Id) && orderItemMap.get(orItem.Id).NE__OrderId__r.XC_SkipContractGeneration__c){
                continue;
            }
            // Check InOrder Type
            if(orItem.XC_CongaDynamicAPI__c == Label.XC_CL_Yes){
                continue;
            }
            if(!booleanProductMap.isEmpty() && booleanProductMap.containsKey(orItem.NE__ProdName__c) && booleanProductMap.get(orItem.NE__ProdName__c)){
                continue;
            } 
            if(!orderItemMap.containsKey(orItem.Id)){
                continue;
            }
            XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
            String recordTypeId = orderItemMap.get(orItem.Id).NE__OrderId__r.RecordTypeId;
            String sohoType = orderItemMap.get(orItem.Id).NE__OrderId__r.NE__AccountId__r.XC_SohoType__c;
            String catalogName = orderItemMap.get(orItem.Id).NE__Catalog__r.XC_LIC_Name__c;
            String categoryName = orderItemMap.get(orItem.Id).XC_Product_Subtype__c;
            if(!String.isEmpty(categoryName) && categoryName == Label.XC_CL_Subtype_Photovoltaic && !productNameMap.isEmpty() && productNameMap.containsKey(orItem.Id) ){
                categoryName = productNameMap.get(orItem.Id).XC_Product_Subtype__c;
            }
            String billingModel = orItem.XC_BillingModel__c;
            String optyId =  orderItemMap.get(orItem.Id).NE__OrderId__r.NE__OptyId__c;
            String productServiceName = orItem.NE__ProdName__c;
            String legalEntity = orderItemMap.get(orItem.Id).NE__OrderId__r.XC_LegalEntity__c;
            String country = orderItemMap.get(orItem.Id).NE__OrderId__r.XC_Country__c;
            String signedBy = orderItemMap.get(orItem.Id).NE__OrderId__r.XC_SignedByExternal__c;
            String fileName = orderItemMap.get(orItem.Id).NE__ProdName__c;
            String individualId = orderItemMap.get(orItem.Id).NE__OrderId__r.NE__OptyId__r.XC_Contact__r.IndividualId;
            String contactId = orderItemMap.get(orItem.Id).NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
            String bundleName = orderItemMap.get(orItem.Id).NE__Bundle__r.LIC_Name__c;
            String region = orderItemMap.get(orItem.Id).NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c;

            String productId =  orderItemMap.get(orItem.Id).NE__ProdId__c;

            if(!String.isBlank(billingModel) && billingModel.contains(Label.XC_CL_ConfigurationItem_Renting)){
                billingModel = 'Renting';
            }
            Boolean noPaymentMethodRequired = ( orItem.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_NoPaymentRequired || orItem.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_CommodityOffer );
            // The check on the order record type is useful only in the update process, that because for the b2w order creation logic, a new order is created
            // always with record type opty both for opty, quote and order creation. So the check on record type  it's needed only in the update process (when a 
            // blpi it's populated on the order). 
            if(recordTypeId == configOrderId || isFromBillingModel){ 
                wrapper.checkOnRecordType = true;
            }
            if(!String.isEmpty(sohoType) && sohoType != Label.XC_CL_Soho){
                wrapper.checkSohoType = false;
            }
            wrapper.billingModel = billingModel;
            wrapper.catalogName = catalogName;
            wrapper.legalEntity = legalEntity; 
            wrapper.categoryName = categoryName;
            wrapper.country = country;
            String nameOi = '';
            if(!String.isBlank(orItem.Name)){
                nameOi = orItem.Name.remove('OI-');
            }
            if(fileName.contains('-')){
                fileName = fileName.remove('-');
            }
            if(String.isBlank(signedBy)){
                wrapper.fileName = fileName + ' ' +  nameOi +' - CONTRACT_TO_SIGN';
            } else {
                wrapper.fileName = fileName + ' ' +  nameOi +' - CONTRACT_SIGNED';
                wrapper.isExternallySigned = true;
            }
            wrapper.orderItemToBeUpdated = orItem; 
            wrapper.optyId = optyId;
            wrapper.individualId = individualId;
            wrapper.contactId = contactId;
            wrapper.bundleName = bundleName;
            wrapper.region = region;
            if(productNameMap != null && !productNameMap.isEmpty() && productNameMap.containsKey(orItem.Id)){
                wrapper.equipmentName = productNameMap.get(orItem.Id).NE__ProdId__r.XC_LIC_Product_Name__c;
                wrapper.productId = productNameMap.get(orItem.Id).NE__ProdId__c;
            } else {
                wrapper.equipmentName = productServiceName;
                wrapper.productId = productId;
            }
            if(checkServiceOrPhotovoltaic(wrapper)){
                wrapper.productServiceName = wrapper.equipmentName;
            }
            if(wrapper.productServiceName != null && wrapper.productServiceName != '' && wrapper.productServiceName.contains('/')){
                wrapper.productServiceName = wrapper.productServiceName.remove('/');
            }
            if(wrapper.categoryName == Label.XC_CL_Subtype_Photovoltaic){
                wrapper.photovoltaicId = orItem.Id;
            }
            wrapper.noPaymentMethodRequired = noPaymentMethodRequired;
            wrapper.customerRepresentative = orderItemMap.get(orItem.Id).NE__OrderId__r.XC_DelegatedSignature__c;
            wrapperList.add(wrapper);           
        }
        return wrapperList;
    }

    /**
    * @description 
    * @author Del Prete Domenico && Salvatore Scarpato | 2/4/2020 
    * @param orderItemToBeProcessedList 
    * @return List<XC_UTIL_Conga.UtilWrapper> 
    **/
    public static List<XC_UTIL_Conga.UtilWrapper> getOrderInfoByCreditAssignment(List<NE__OrderItem__c> orderItemToBeProcessedList){
        List<String> listOfBundleId = new List<String>();
        List<String> listOfOrderId = new List<String>();
        for(NE__OrderItem__c oi : orderItemToBeProcessedList){
            listOfBundleId.add(oi.NE__Bundle_Configuration__c);
            listOfOrderId.add(oi.NE__OrderId__c);
        }
        List<XC_UTIL_Conga.UtilWrapper> wrapperList = new List<XC_UTIL_Conga.UtilWrapper>();
        Id configOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, Name,NE__OrderId__c,XC_BillingModel__c, XC_CongaDynamicAPI__c,XC_CongaStaticAPI__c,NE__OrderId__r.XC_SignedByExternal__c,
                                                                        XC_BillingProfileLineItem__c,NE__ProdName__c, XC_Product_Type__c, XC_Product_Subtype__c, 
                                                                        NE__OrderId__r.RecordTypeId, NE__Bundle_Configuration__c,NE__OrderId__r.XC_LegalEntity__c,
                                                                        NE__Catalog__r.XC_LIC_Name__c,NE__OrderId__r.NE__OptyId__c, NE__OrderId__r.XC_Country__c,
                                                                        NE__OrderId__r.NE__AccountId__r.XC_SohoType__c, NE__OrderId__r.NE__OptyId__r.XC_PrincingRegion__c, NE__OrderId__r.NE__Type__c,
                                                                        NE__OrderId__r.NE__OptyId__r.XC_Contact__c
                                                                        FROM NE__OrderItem__c 
                                                                        WHERE Id IN: listOfBundleId AND NE__OrderId__c IN:listOfOrderId AND XC_Segment__c = 'B2C' AND NE__OrderId__r.NE__Type__c = 'InOrder']);
        for(NE__OrderItem__c oi : orderItemToBeProcessedList){
            if(orderItemMap.get(oi.NE__Bundle_Configuration__c) != null){
                // Check InOrder Type
                /*if(orderItemMap.get(oi.Id).NE__OrderId__r.NE__Type__c != Label.XC_CL_Configuration_TypeInOrder){
                    continue;
                }*/
                XC_UTIL_Conga.UtilWrapper wrapper = new XC_UTIL_Conga.UtilWrapper();
                String recordTypeId = orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__OrderId__r.RecordTypeId;
                String sohoType = orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__OrderId__r.NE__AccountId__r.XC_SohoType__c;
                String catalogName = orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__Catalog__r.XC_LIC_Name__c;
                String categoryName = orderItemMap.get(oi.NE__Bundle_Configuration__c).XC_Product_Subtype__c;
                String optyId =  orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__OrderId__r.NE__OptyId__c;
                //String productServiceName = orItem.NE__ProdName__c;
                String legalEntity = orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__OrderId__r.XC_LegalEntity__c;
                String country = orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__OrderId__r.XC_Country__c;
                String fileName = orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__ProdName__c;
                String contactId = orderItemMap.get(oi.NE__Bundle_Configuration__c).NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
                if(!String.isEmpty(sohoType) && sohoType != Label.XC_CL_Soho){
                    wrapper.checkSohoType = false;
                }
                wrapper.catalogName = catalogName;
                wrapper.legalEntity = legalEntity; 
                wrapper.categoryName = categoryName;
                wrapper.country = country;
                String nameOi = '';
                if(!String.isBlank(oi.Name)){
                    nameOi = oi.Name.remove('OI-');
                }
                if(fileName.contains('-')){
                    fileName = fileName.remove('-');
                }
                wrapper.fileName =  fileName + ' '+ nameOi +' - CREDIT_ASSIGNMENT_TO_SIGN';
                if(recordTypeId == configOrderId ){ 
                    wrapper.checkOnRecordType = true;
                }
                wrapper.orderItemToBeUpdated = oi; 
                wrapper.optyId = optyId;
                wrapper.contactId = contactId;
                wrapperList.add(wrapper); 
            }  
        }
        return wrapperList;
    }
 
    /**
    * @description method used to populate the serviceName value in the wrapper if needed 
    * @author salvatore.scarpato@nttdata.com | 27/2/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper  
    * @return Boolean 
    **/
    private static Boolean checkServiceOrPhotovoltaic(XC_UTIL_Conga.UtilWrapper wrapper){
        return ( (wrapper.country == 'Italy' || wrapper.country == 'Spain' || wrapper.country == 'Romania' || wrapper.country == 'Brazil')  && (wrapper.categoryName == 'Gas' || wrapper.categoryName == 'Electric' || wrapper.categoryName == 'Maintenance' ||  wrapper.categoryName == 'Gas and Electricity' || wrapper.categoryName == 'Certification' || wrapper.categoryName == Label.XC_CL_Subtype_Photovoltaic || wrapper.categoryName == Label.XC_CL_ProductSubtypeSmart || wrapper.categoryName == 'Wallbox' || wrapper.categoryName == 'JuiceAbility' || wrapper.categoryName == 'Home Check' || wrapper.categoryName == 'Photovoltaic PP'));
    }

    /**
    * @description check if eMobility scenario is verified. If yes all following steps have to be skipped, moreover check if
                   the record type is order.
    * @author salvatore.scarpato@nttdata.com | 20/2/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper  
    * @return Boolean 
    **/
    public static Boolean checkEmobilityScenarioAndRecordType(XC_UTIL_Conga.UtilWrapper wrapper){
        return ((wrapper.catalogName != null && wrapper.catalogName.containsIgnoreCase('emobility')) || !wrapper.checkOnRecordType);
    }

    /**
    * @description check if eMobility scenario is verified. If yes all following steps have to be skipped, moreover check if
                   the record type is order.
    * @author salvatore.scarpato@nttdata.com | 20/2/2020 
    * @param wrapper XC_UTIL_Conga.UtilWrapper  
    * @return Boolean 
    **/
    public static Boolean checkEmobilityScenario(XC_UTIL_Conga.UtilWrapper wrapper){
        return (wrapper.catalogName != null && wrapper.catalogName.containsIgnoreCase('emobility'));
    }


    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 7/5/2020 
    * @param orderItemToBeProcessedIds 
    * @return Map<String, String> 
    **/
    private static MapUtilWrapper getProductName(List<String> orderItemToBeProcessedIds, List<String> subTypeList, List<String> oppListId){
        MapUtilWrapper mapWrapper = new MapUtilWrapper();
        Id optyRecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        Map<String, Boolean> mapProductBundle = new Map<String, Boolean>();
        Boolean isInBundle ;
        Map<String,NE__OrderItem__c> productNameMap = new Map<String,NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>([SELECT Id,NE__Bundle_Configuration__c, NE__ProdName__c,NE__ProdId__r.XC_LIC_Product_Name__c, NE__ProdId__c, XC_Product_Subtype__c,NE__OrderId__r.RecordTypeId
                                                                            FROM NE__OrderItem__c
                                                                            WHERE (NE__Bundle_Configuration__c IN:  orderItemToBeProcessedIds
                                                                            AND XC_Product_Type__c =: Label.XC_CL_ProductTypeEquipment 
                                                                            AND XC_Product_Subtype__c !=: Label.XC_CL_ProductSubtypeSmart
                                                                            AND XC_Product_Subtype__c IN: subTypeList)
                                                                            OR ( NE__OrderId__r.NE__OptyId__c IN: oppListId 
                                                                            AND NE__OrderId__r.RecordTypeId =: optyRecordTypeId 
                                                                            AND XC_Product_Subtype__c =: Label.XC_CL_ProductSubtypeSmart
                                                                            AND NE__Bundle_Configuration__c != '')]);
        for(NE__OrderItem__c orderItem : orderItemList){
            if(orderItem.XC_Product_Subtype__c == Label.XC_CL_ProductSubtypeSmart){
                isInBundle = true;
                mapProductBundle.put(orderItem.NE__ProdName__c,isInBundle);
            } else {
                productNameMap.put(orderItem.NE__Bundle_Configuration__c, orderItem);
            }
        }
        mapWrapper.mapProductBundle = mapProductBundle;
        mapWrapper.productNameMap = productNameMap;
        return mapWrapper;
    }

    /**
    * @description retrieve the penalty value from the NE__Matrix_Parameter_Row__c object
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 8/5/2020 
    * @param wrapperList 
    **/
    public static Set<NE__OrderItem__c> getPenaltyValue(Map<String, List<NE__OrderItem__c>> oiFatherIdoiChildrenMap){
        Set<NE__OrderItem__c> orderItemToUpdateSet = new Set<NE__OrderItem__c>();
        Set<String> setIdToCheck = new Set<String>();
        List<String> equipmentNameList = new List<String>();
        List<String> bundleNameList = new List<String>();
        List<String> billingModelList = new List<String>();
        List<String> regionList = new List<String>();
        for(String bundleId : oiFatherIdoiChildrenMap.keySet()){
            for(NE__OrderItem__c oi : oiFatherIdoiChildrenMap.get(bundleId)){
                equipmentNameList.add(oi.NE__ProdId__r.XC_LIC_Product_Name__c);
                bundleNameList.add(oi.NE__Bundle__r.LIC_Name__c);
                billingModelList.add(oi.XC_BillingModel__c);
                regionList.add(oi.NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c);
            }    
        }
        List<NE__Matrix_Parameter_Row__c> matrixList = new List<NE__Matrix_Parameter_Row__c>([SELECT Id, XC_Value1__c, XC_BundleLicName__c, Product_LIC_Name__c, XC_Payment_Model__c, 
                                                                                                XC_Region__c, NE__Start_Date__c, NE__End_Date__c, 
                                                                                                XC_Offline_Name_01__c, XC_Offline_Value_01__c, XC_Offline_Name_02__c, XC_Offline_Value_02__c,
                                                                                                XC_Offline_Name_03__c, XC_Offline_Value_03__c, XC_Offline_Name_04__c, XC_Offline_Value_04__c,
                                                                                                XC_Offline_Name_05__c, XC_Offline_Value_05__c, XC_Offline_Name_06__c, XC_Offline_Value_06__c,
                                                                                                XC_Offline_Name_07__c, XC_Offline_Value_07__c, XC_Offline_Name_08__c, XC_Offline_Value_08__c,
                                                                                                XC_Offline_Name_09__c, XC_Offline_Value_09__c, XC_Offline_Name_10__c, XC_Offline_Value_10__c,
                                                                                                XC_Offline_Name_11__c, XC_Offline_Value_11__c, XC_Offline_Name_12__c, XC_Offline_Value_12__c,
                                                                                                XC_Offline_Name_13__c, XC_Offline_Value_13__c, XC_Offline_Name_14__c, XC_Offline_Value_14__c,  
                                                                                                XC_Offline_Name_15__c, XC_Offline_Value_15__c, XC_Offline_Name_16__c, XC_Offline_Value_16__c, 
                                                                                                XC_Offline_Name_17__c, XC_Offline_Value_17__c, XC_Offline_Name_18__c, XC_Offline_Value_18__c, 
                                                                                                XC_Offline_Name_19__c, XC_Offline_Value_19__c, XC_Offline_Name_20__c, XC_Offline_Value_20__c, 
                                                                                                XC_Offline_Name_21__c, XC_Offline_Value_21__c, XC_Offline_Name_22__c, XC_Offline_Value_22__c, 
                                                                                                XC_Offline_Name_23__c, XC_Offline_Value_23__c, XC_Offline_Name_24__c, XC_Offline_Value_24__c, 
                                                                                                XC_Offline_Name_25__c, XC_Offline_Value_25__c, XC_Offline_Name_26__c, XC_Offline_Value_26__c, 
                                                                                                XC_Offline_Name_27__c, XC_Offline_Value_27__c, XC_Offline_Name_28__c, XC_Offline_Value_28__c, 
                                                                                                XC_Offline_Name_29__c, XC_Offline_Value_29__c, XC_Offline_Name_30__c, XC_Offline_Value_30__c
                                                                                                FROM NE__Matrix_Parameter_Row__c 
                                                                                                WHERE XC_BundleLicName__c IN: bundleNameList AND
                                                                                                Product_LIC_Name__c IN :equipmentNameList AND
                                                                                                XC_Payment_Model__c IN :billingModelList AND
                                                                                                XC_Region__c IN: regionList AND
                                                                                                NE__Start_Date__c <=: Date.Today() AND
                                                                                                (NE__End_Date__c >=:  Date.Today() OR NE__End_Date__c = null)
                                                                                                ORDER BY NE__Start_Date__c DESC]);
        System.debug('@@@@0706 oiFatherIdoiChildrenMap--> ' + oiFatherIdoiChildrenMap);
        for(String bundleId : oiFatherIdoiChildrenMap.keySet()){
            Decimal penalty = 0;
            for(NE__OrderItem__c oi : oiFatherIdoiChildrenMap.get(bundleId)){ // NE__Matrix_Parameter_Row__c matrix : matrixList
                for(NE__Matrix_Parameter_Row__c matrix : matrixList){ // NE__OrderItem__c oi : oiFatherIdoiChildrenMap.get(bundleId)
                    System.debug('@@@@0706 oi--> ' + oi);
                    if( (matrix.XC_BundleLicName__c == oi.NE__Bundle__r.LIC_Name__c || (String.isBlank(oi.NE__Bundle__r.LIC_Name__c) && matrix.XC_BundleLicName__c == null) )
                    && matrix.Product_LIC_Name__c == oi.NE__ProdId__r.XC_LIC_Product_Name__c
                    && matrix.XC_Payment_Model__c == oi.XC_BillingModel__c
                    && matrix.XC_Region__c == oi.NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c){
                        Map<String,String> penaltyMap = XC_LCC095_ShowPenalty.createMapPenalties(matrix);
                        for(String key : penaltyMap.keySet()){
                            if(key.containsIgnoreCase('Pen_Unistall')){
                                System.debug('@@@@0706 oi 2--> ' + oi);
                                System.debug('@@@@0706 oi.NE__ProdId__r.XC_LIC_Product_Name__c 2--> ' + oi.NE__ProdId__r.XC_LIC_Product_Name__c);
                                System.debug('@@@@0706 oi.NE__Bundle__r.LIC_Name__c 2--> ' + oi.NE__Bundle__r.LIC_Name__c);
                                System.debug('@@@@0706 penalty--> ' + penalty);
                                penalty += Decimal.valueOf(penaltyMap.get(key));
                            }
                        }
                    } 
                }
                /*if(!setIdToCheck.contains(bundleId)){
                    setIdToCheck.add(bundleId);
                    
                }*/
            }
            String penaltyValue = String.valueOf(penalty);
            orderItemToUpdateSet.add(new NE__OrderItem__c(Id = bundleId, XC_PenaltyValue__c = penaltyValue));
        }
        return orderItemToUpdateSet;
    }


    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 06-07-2021 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void populatePenalty(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) { 
        List<String> fieldList = new List<String>{'NE__Bundle_Configuration__c'};
        List<NE__OrderItem__c> orderItemUpdatedList = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(orderItemUpdatedList.isEmpty()){
            return;
        }   
        populatePenaltyValue(orderItemUpdatedList, false);
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 06-08-2021 
    * @param orderItemUpdatedList 
    **/
    public static void populatePenaltyValue(List<NE__OrderItem__c> orderItemUpdatedList, Boolean forDataRemediation){
        Set<String> orderItemsBundlesId = new Set<String>();
        for(NE__OrderItem__c oi : orderItemUpdatedList){
            if((oi.XC_LegalEntityFormula__c == Label.XC_CL_EndesaX || oi.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) && !String.isBlank(oi.NE__Bundle_Configuration__c) && oi.XC_BillingModel__c != 'Usage'){
                orderItemsBundlesId.add(oi.NE__Bundle_Configuration__c);
            }
        }
        if(orderItemsBundlesId.isEmpty()){
            return;
        }
        Map<String, List<NE__OrderItem__c>> oiFatherIdoiChildrenMap = getBrothersOIs(orderItemsBundlesId, forDataRemediation);
        if(oiFatherIdoiChildrenMap.isEmpty()){
            return;
        }
        Set<NE__OrderItem__c> oiListToUpdate = getPenaltyValue(oiFatherIdoiChildrenMap);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> dMLResult = XC_UTIL_SObject.updateListRecords(new List<NE__OrderItem__c>(oiListToUpdate));
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    } 

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 06-07-2021 
    * @param orderItemsBundlesId 
    * @return Map<String, List<NE__OrderItem__c>> 
    **/
    private static Map<String, List<NE__OrderItem__c>> getBrothersOIs(Set<String> orderItemsBundlesId, Boolean forDataRemediation){
        Id optyRecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        Map<String, List<NE__OrderItem__c>> oiFatherIdoiChildrenMap = new Map<String, List<NE__OrderItem__c>>();
        List<NE__OrderItem__c> oiBrothersList = new List<NE__OrderItem__c>();
        if(!forDataRemediation){
            oiBrothersList = new List<NE__OrderItem__c>([SELECT Id, NE__Bundle_Configuration__c,  NE__ProdId__r.XC_LIC_Product_Name__c, NE__Bundle__r.LIC_Name__c, XC_BillingModel__c,
                                                                                NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c, NE__Bundle_Configuration__r.XC_PenaltyValue__c
                                                                            FROM NE__OrderItem__c
                                                                            WHERE NE__Bundle_Configuration__c IN: orderItemsBundlesId AND NE__OrderId__r.recordTypeId =: optyRecordTypeId]);
        
        } else {
            oiBrothersList = new List<NE__OrderItem__c>([SELECT Id, NE__Bundle_Configuration__c,  NE__ProdId__r.XC_LIC_Product_Name__c, NE__Bundle__r.LIC_Name__c, XC_BillingModel__c,
                                                                            NE__OrderId__r.XC_InstallationAddress__r.XC_PricinRegion__c, NE__Bundle_Configuration__r.XC_PenaltyValue__c
                                                                        FROM NE__OrderItem__c
                                                                        WHERE NE__Bundle_Configuration__c IN: orderItemsBundlesId]);    
        }
        for(NE__OrderItem__c oi : oiBrothersList){
            if(!String.isBlank(oi.NE__Bundle_Configuration__r.XC_PenaltyValue__c)){
                continue;
            }
            if(!oiFatherIdoiChildrenMap.containsKey(oi.NE__Bundle_Configuration__c)){
                oiFatherIdoiChildrenMap.put(oi.NE__Bundle_Configuration__c, new List<NE__OrderItem__c>());
            }
            oiFatherIdoiChildrenMap.get(oi.NE__Bundle_Configuration__c).add(oi);
        }
        return oiFatherIdoiChildrenMap;
    }

    /**
    * @description INNER QUEABLE CLASS
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
    * @return Boolean
    */
    public class ManageDMLQueuable implements Queueable{
        List<NE__OrderItem__c> orderItemList;
        /**
        * @description INNER QUEABLE CLASS
        * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
        * @param orderItemList List<NE__OrderItem__c>
        */
        public ManageDMLQueuable(List<NE__OrderItem__c> orderItemList){
            this.orderItemList = orderItemList;
        }
        /**
        * @description execute queuble class
        * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
        * @param context QueueableContext
        */        
        public void execute(QueueableContext context) {
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            List<XC_UTIL_Sobject.WrapperResult> dMLResult = XC_UTIL_SObject.updateListRecords(orderItemList);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }
    }
    /**
     * @description manageDMLfuture
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 12/8/2019
     * @param orderItemsString the order items list
     */
    @future(callout=true)
    public static void manageDMLfuture(String orderItemsString) {

        List<NE__OrderItem__c> orderItemList = (List<NE__OrderItem__c>) JSON.deserialize(orderItemsString, List<NE__OrderItem__c>.class);

        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> dMLResult = XC_UTIL_SObject.updateListRecords(orderItemList);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ConfigurationItem_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }
}
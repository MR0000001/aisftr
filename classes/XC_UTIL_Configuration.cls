/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 10/10/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Configuration – Util class for Cart Configuration methods
*/

public without sharing class XC_UTIL_Configuration {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Configuration');
    
    

    /**
    * @author Monica Cutillo - monica.cutillo@nttdata.com
    * @description check Configuration Opportunity Stage
    * @param confId the configuration id
    * @return the XC_UTIL_ResultWrapper
    */
    public static XC_UTIL_ResultWrapper checkOpportunityStage(String confId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'START checkConfigurationOpportunityStage');
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        //START-CR725-elisa.caldini@accenture.com-08.03.2022
        List<String> legalEntities= new  List<String>{'EnelSole','EnelXItalia'};
        List<String> requestForApprovals=new List<String>{'Pre-approval','Approval Needed','Approval Refused'}; 
        List<String> commercialContracts=new List<String>{'Capex Intensive Projects with energy ESCO','Capex Intensive Projects without energy','Spot Sales Works_OM','OM Projects without energy'};//CR725-elisa.caldini@accenture-07.06.2022
        //END-CR725-elisa.caldini@accenture.com-08.03.2022
        //Block quote/order creation if the parent opportunity is Closed Lost or Closed Won /*MC ESCEP-2094*/
        Map<Id,NE__Order__C> confData = new Map<Id,NE__Order__C>(
            [SELECT Id, NE__OptyId__r.StageName, NE__OptyId__c, NE__OptyId__r.XC_Segment__c, NE__OptyId__r.XC_Commercial_Contract_Type__c, XC_RequestForApproval__c,NE__OptyId__r.XC_BusinessLine__c,NE__OptyId__r.XC_LegalEntity__c,RecordType.DeveloperName
               FROM NE__Order__C
              WHERE id =: confId] //CR725-elisa.caldini@accenture.com-08.03.2022-add fields
        );
        NE__Order__C conf = confData.values()[0];
        if(Label.XC_CL_Opportunity_ClosedLost == conf.NE__OptyId__r.StageName || Label.XC_CL_Opportunity_ClosedWon == conf.NE__OptyId__r.StageName){
            wr.success = false;
            wr.resultMessage = Label.XC_CL_OppStageClosedLostOrWonMess;
        }
        //START-CR725-elisa.caldini@accenture.com-08.03.2022
        if('Opty'.equalsIgnoreCase(conf.RecordType.DeveloperName) && 'In Progress'.equalsIgnoreCase(conf.NE__OptyId__r.StageName) && !'B2C'.equalsIgnoreCase(conf.NE__OptyId__r.XC_Segment__c) && legalEntities.contains(conf.NE__OptyId__r.XC_LegalEntity__c) && 'eCity'.equalsIgnoreCase(conf.NE__OptyId__r.XC_BusinessLine__c) && !commercialContracts.contains(conf.NE__OptyId__r.XC_Commercial_Contract_Type__c)){
            if(requestForApprovals.contains(conf.XC_RequestForApproval__c) ){
                wr.success=false;
                wr.resultMessage='Please approve the opty to proceed with the next step';
            }
        }
        //END-CR725-elisa.caldini@accenture.com-08.03.2022
        //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022 - start fix
        if(conf.NE__OptyId__r.StageName == 'In Progress' && conf.NE__OptyId__r.XC_Segment__c != 'B2C'){
            List<NE__OrderItem__c> rootOI = 
                [SELECT id, NE__StartDate__c, NE__EndDate__c, XC_BillingModel__c 
                 FROM NE__OrderItem__c 
                 WHERE NE__OrderId__c =: confId 
                 AND NE__Root_Order_Item__c = null 
                 AND XC_ParentCommercialItem__c = null];
            for(NE__OrderItem__c root : rootOI){
                if(root.NE__StartDate__c == null || root.NE__EndDate__c == null){
                    wr.success = false;
                    wr.resultMessage = 'For In Progress Opportunity, start date and end date on root order item must be set.';
                }
            }
        }
        //CR2249 - Gestione date contrattuali - federico.manni@accenture.com R1 2022 - end
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkConfigurationOpportunityStage result ='+wr);
        return wr;
    }

    /** 
    * @description Filter configurations by NE__Configuration_Type__c field
    * @param listConfiguration - List<NE__Order__c>
    * @return listOrder - List<NE__Order__c>
    */
    public static List<NE__Order__c> getConfigurationNew(List<NE__Order__c> listConfiguration) {
        List<NE__Order__c> listOrder = new List<NE__Order__c>();
        for(NE__Order__c order: listConfiguration) {
            if(order.NE__Configuration_Type__c == Label.XC_CL_Configuration_TypeNew) {
                listOrder.add(order);
            }
        }
        return listOrder;
    }

    /** 
    * @author Monica Cutillo - monica.cutillo@nttdata.com
    * @description getAdditionalAmountFromAcceptedQuote
    * @param configIds
    * @return Map<Id,NE__Order__c> result
    */
    public static Map<Id,NE__Order__c> getAdditionalAmountFromAcceptedQuoteOrder(Set<Id> configIds){
        return new Map<Id,NE__Order__c>(
            [SELECT Id, NE__One_Time_Fee_Total__c 
               FROM NE__Order__c 
              WHERE Id IN: new Set<Id>(configIds)
                AND RecordType.DeveloperName IN: new List<String> {Label.XC_CL_Configuration_RtQuote, Label.XC_CL_Configuration_RtOrder}
                AND XC_Status__c =: Label.XC_CL_Configuration_QuoteAccepted
        ]);
    }

    /*****************************************************************************************************************
    * @description check if exist record in object NE__Order__c
    * @param listOrder - List<NE__Order__c>
    * @return Set<Id>
    *****************************************************************************************************************/
    public static Set<Id> getAllConfItemIds(List<NE__Order__c> listOrder) {
        Set<Id> setIds = new Set<Id>();
        List<NE__OrderItem__c> listOrderItem;
        for(NE__Order__c order : listOrder) {

            listOrderItem = order.NE__Order_Items__r;
            for(NE__OrderItem__c item : listOrderItem){
                 setIds.add(item.Id);
            }
        }
        return setIds;
    }

    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @description  Method to get the map of Order Ids to List<NE__Order_Item_Attribute__c> using the list of Ids
    *               of NE__Order_Item__c
    * @param listConfigurationItemId - Set<Id>
    * @return Map<Id, List<NE__Order_Item_Attribute__c>>
    **/
    public static Map<Id, List<NE__Order_Item_Attribute__c>> getOrderItemAttributesByListCIId(Set<Id> listConfigurationItemId) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return new Map<Id, List<NE__Order_Item_Attribute__c>>();
        }
        Map<Id, NE__OrderItem__c> mapOrderItems = new Map<Id, NE__OrderItem__c>(
                                                [SELECT Id, NE__OrderId__c, 
                                                    (SELECT Id, Name, NE__Value__c, XC_DeveloperName__c FROM NE__Order_Item_Attributes__r)
                                                 FROM NE__OrderItem__c WHERE Id IN :listConfigurationItemId]);
        List<NE__OrderItem__c> listOrderItems = mapOrderItems.values();
        Map<Id, List<NE__Order_Item_Attribute__c>> mapOrderIdToOrderItemAttrs = new Map<Id, List<NE__Order_Item_Attribute__c>>();
        List<NE__Order_Item_Attribute__c> listOrderItemAttrs;

        for(NE__OrderItem__c item : listOrderItems) {

            listOrderItemAttrs = item.NE__Order_Item_Attributes__r;
            if(mapOrderIdToOrderItemAttrs.get(item.NE__OrderId__c) != null) {
                listOrderItemAttrs = mapOrderIdToOrderItemAttrs.get(item.NE__OrderId__c);
            } else {
                listOrderItemAttrs = new List<NE__Order_Item_Attribute__c>();
            }
            listOrderItemAttrs.addAll(item.NE__Order_Item_Attributes__r);
            mapOrderIdToOrderItemAttrs.put(item.NE__OrderId__c, listOrderItemAttrs);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in for attr ' + mapOrderIdToOrderItemAttrs);
        }

        return mapOrderIdToOrderItemAttrs;

    }


    /*****************************************************************************************************************
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @data 27/11/2018
    * @modification dd/mm/yyyy
    * @description Method to get the map of Order Ids to List<NE__OrderItem__c> using the list of Ids of NE__Order__c
    * @param orderIdList - List<Id>
    * @return Map<Id, List<NE__OrderItem__c>>
    *****************************************************************************************************************/
    public static Map<Id, List<NE__OrderItem__c>> getOrderItemFromConfiguration(List<Id> orderIdList) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return new Map<Id, List<NE__OrderItem__c>>();
        }
        List<NE__OrderItem__c> orderItemList = [SELECT id, NE__OrderId__c, NE__Catalog__c, NE__CatalogItem__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Phone_Required__c
                                                FROM NE__OrderItem__c
                                                WHERE NE__OrderId__c IN: orderIdList];
        
        Map<Id, List<NE__OrderItem__c> > mapIdToOrderItem = new Map<Id, List<NE__OrderItem__c> >();
        List<NE__OrderItem__c> orderItemToConf;

        for(NE__OrderItem__c orItem : orderItemList) {
            if(mapIdToOrderItem.get(orItem.NE__OrderId__c) != null) {
                orderItemToConf = mapIdToOrderItem.get(orItem.NE__OrderId__c);
            } else {
                orderItemToConf = new List<NE__OrderItem__c>();
            }
            orderItemToConf.add(orItem);
            mapIdToOrderItem.put(orItem.NE__OrderId__c, orderItemToConf);
        }

        return mapIdToOrderItem;
    }

    /*****************************************************************************************************************
    * @author Federico Amici federico.amici@nttdata.com
    * @data 10/01/2019
    * @modification dd/mm/yyyy
    * @description Method to get the map of Order Ids to List<NE__OrderItem__c> using the list of Ids of NE__Order__c and List of NE__OrderItem__c Ids
    * @param orderIdList
    * @param listItemIds
    * @return Map<Id, List<NE__OrderItem__c>>
    *****************************************************************************************************************/
    public static Map<Id, List<NE__OrderItem__c>> getOrderItemFromConfiguration(List<ID> orderIdList, List<Id> listItemIds) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return new Map<Id, List<NE__OrderItem__c>>();
        }
        List<NE__OrderItem__c> orderItemList = [SELECT id, NE__OrderId__c, NE__Catalog__c, NE__CatalogItem__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Phone_Required__c
                                                FROM NE__OrderItem__c
                                                WHERE NE__OrderId__c IN: orderIdList AND
                                                    ID IN :listItemIds];
        
        Map<Id, List<NE__OrderItem__c> > mapIdToOrderItem = new Map<Id, List<NE__OrderItem__c> >();
        List<NE__OrderItem__c> orderItemToConf;

        for(NE__OrderItem__c orItem : orderItemList) {
            if(mapIdToOrderItem.get(orItem.NE__OrderId__c) != null) {
                orderItemToConf = mapIdToOrderItem.get(orItem.NE__OrderId__c);
            } else {
                orderItemToConf = new List<NE__OrderItem__c>();
            }
            orderItemToConf.add(orItem);
            mapIdToOrderItem.put(orItem.NE__OrderId__c, orderItemToConf);
        }

        return mapIdToOrderItem;
    }


    /**
    * @author lorenzo.orlanducci@nttdata.com - monica.cutillo@nttdata.com
    * @date Modification 13/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description  The method changs the status order in Sent. If there are some 
    *               Validation Exception during the update, it catch and block its and return 
    *               the exception message on the XC_UTIL_ResultWrapper result, with success field false.
    * @param recordId - String
    * @param assetCreated - Boolean
    * @return XC_UTIL_ResultWrapper
    **/
    public static XC_UTIL_ResultWrapper changeOrderStatusSent(String recordId, Boolean assetCreated){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'USED QUERIES->' + Limits.getQueries() + '/' + Limits.getLimitQueries());       
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        //wr.success = true; 
        if(recordId != null){
            NE__Order__c order = new NE__Order__c(); 
            order.Id = recordId;
            order.NE__FulfilmentStatus__c = Label.XC_CL_Order_StatusSent;
            order.NE__OrderStatus__c = Label.XC_CL_Order_StatusSent;
            order.XC_AssetsCreated__c = true;
            //wr.resultMessage = Label.XC_CL_Configuration_OrderUpdated;
            //order.B2WZC__ZPaymentMethodType__c = Label.XC_CL_Configuration_PaymentCash;
            XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.updateRecord(order);
            wr.success = result.success;
            if(result.success && !assetCreated){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Create Assets');
                wr.resultMessage = Label.XC_CL_Configuration_OrderUpdated; 
                NE.JS_RemoteMethods.order2asset(order.ID);    
            } else {
                wr.resultMessage = result.errorMessage;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@# order->' + order);
            /*try{
                update order;
            } catch(DmlException e){
                wr.success = false;
                wr.resultMessage = e.getDmlMessage(0);
            }*/
        } else {
            wr.success = false;
            wr.resultMessage = Label.XC_CL_Configuration_OrderNotExist;
        }
        return wr;
    }
    
    /**@author Federico Amici
     * @description The method return the list of NE__OrderId__c lookup from List<NE__OrderItem__c>
     * @param listItems - List<NE__OrderItem__c>
     * @return listOrderIds - List<String>
     **/
    public static List<String> getOrderIdsFromOrderItems(List<NE__OrderItem__c> listItems) {
        List<String> listOrderIds = new List<String>();

        for(NE__OrderItem__c item : listItems) {
            listOrderIds.add(item.NE__OrderId__c);
        }

        return listOrderIds;
    }

    /**@author Federico Amici
     * @description The method return the list of rateplan associated to the items of the order
     * @param orderId - String
     * @return List<B2WExtCat__Work_Order_Item__c>
     **/
    public static List<B2WExtCat__Work_Order_Item__c> getRatePlanByOrderId(String orderId) {
        if(!Schema.sObjectType.B2WExtCat__Work_Order_Item__c.isAccessible()){
            return new List<B2WExtCat__Work_Order_Item__c>();
        }
        List<B2WExtCat__Work_Order_Item__c> listB2WWo = 
                                    [SELECT B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__c,
                                            Name, RecordType.Name 
                                     FROM   B2WExtCat__Work_Order_Item__c
                                     WHERE  B2WExtCat__Configuration_Item__c IN (SELECT Id 
                                                                                FROM NE__OrderItem__c
                                                                                WHERE NE__OrderId__c =:orderId) AND
                                            (RecordType.Name = 'ZuoraOne-Time' OR 
                                            RecordType.Name = 'ZuoraRecurring' OR
                                            RecordType.Name = 'ZuoraUsage') AND
                                            B2WExtCat__Action__c = 'Provide'];

        return listB2WWo;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @date Creation 29/03/2019
     * @description Checks for the Order in input if its OrderItem with XC_IsAProduct__c flag true
     *              all have XC_PaymentMethod__c filled. Return true if this check is ok, false otherwise.
     * @param orderId - String
     * @return Boolean
     **/
    public static Boolean areOrderItemsPaymentMethodsOk(String orderId){
        Boolean checkResult = true;
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return false;
        }
        List<NE__OrderItem__c> items = [SELECT Id, XC_IsAProduct__c,XC_Product_Type__c, XC_Segment__c, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, XC_PaymentMethod__c, XC_ProvisioningSpareParts__c, XC_BillingModel__c  FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderId AND NE__OrderId__r.NE__Type__c =: Label.XC_CL_Configuration_TypeInOrder];
        for(NE__OrderItem__c item : items){
            if((item.NE__Parent_Order_Item__c == null && item.NE__Bundle_Configuration__c == null && item.XC_PaymentMethod__c== null && item.XC_Product_Type__c != 'Billing' && item.XC_Product_Type__c != 'Technical' && item.XC_BillingModel__c!= 'Capex')
            || (item.XC_ProvisioningSpareParts__c && item.XC_PaymentMethod__c== null  && item.XC_Segment__c =='B2C')){
                checkResult = false;
                break;
            }
        }

        return checkResult;
    }


    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @date Creation 21/09/2021
     * @description generate Workorders
     * @param orderId - String
     * @param stepId - String
     * @param className - String
     * @return Boolean
     **/
    public static Boolean generateWorkorders(String orderId, String stepId, String className) {

        Boolean manageLogs = (XC_CS_UtilityGlobalValues__c.getInstance('GenerateWOB2Win_Log') != null && XC_CS_UtilityGlobalValues__c.getInstance('GenerateWOB2Win_Log').Value__c != null) ? Boolean.valueOf(XC_CS_UtilityGlobalValues__c.getInstance('GenerateWOB2Win_Log').Value__c) : false;
        String generateWorkorderResult = (manageLogs) ? B2WExtCat.WS_WorkOrders.generateWorkOrdersLogs(orderId, true) : B2WExtCat.WS_WorkOrders.generateWorkOrders(orderId);
        XC_UTIL_IntegrationLog.insertGenerateWorkOrderLog(generateWorkorderResult, orderId, 'GenerateWorkOrder-' + className);
        
        if(generateWorkorderResult.startsWithIgnoreCase('Generic Error') && !generateWorkorderResult.containsIgnoreCase('DUPLICATE_VALUE')) {

            if(String.isNotBlank(stepId)) {

                String errorMessage = 'Generate Workorders Error';
                errorMessage += (generateWorkorderResult.containsIgnoreCase('UNABLE_TO_LOCK_ROW')) ? ': Unable To Lock Row during workorder upsert' : '';

                String errorMessageDetails = generateWorkorderResult;
                if(generateWorkorderResult.length() > 131000) {
                    String subStr = generateWorkorderResult.subString(0, 131000);
                    errorMessageDetails = subStr.subString(0, subStr.lastIndexOf(' ')) + '...';
                }
                
                XC_UTIL_SObject.updateRecord(new XC_Provisioning_Step__c(Id = stepId, XC_Status__c = Label.XC_CL_Step_CompletedKO, XC_ErrorMessage__c = errorMessage, XC_ErrorMessageDetails__c = errorMessageDetails));
            }

            return false;
        }
        
        return true;
    }


    /** @description Filter configurations by NE__Configuration_Type__c field */
    /*public static List<NE__Order__c> getConfigurationNewAndItems(List<Id> listConfigurationIds) {
        
        List < NE__Order__c > listOrder = [SELECT Id, NE__Configuration_Type__c, (SELECT ID FROM NE__Order_Items__r) 
                                            FROM NE__Order__c
                                            WHERE NE__Configuration_Type__c = 'New' ];

        return listOrder;
    }*/

    /** @description Filter configurations by type and fields passed as parameters */
    /*public static List <NE__Order__c> getConfigurationNewAndFields(List < NE__Order__c > listConfiguration, List<String> fieldsToCheck, Map<Id, NE__Order__c> oldMap, Map<Id, NE__Order__c> newMap) {
        
        List<NE__Order__c> listOrder = XC_UTIL_SObject.getListChanged(listConfiguration, fieldsToCheck, oldMap, newMap);
        List<NE__Order__C> listOrderFiltered = new List<NE__Order__c>();

        for (NE__Order__c order: listOrder) {
            if (order.NE__Configuration_Type__c == Label.XC_CL_Configuration_TypeNew) {
                listOrderFiltered.add(order);
            }
        }
        return listOrderFiltered;
    }*/
}
/**
 * @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 08/10/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Configuration_U_FillFields – Class to fill Configuration Fields
 */

public without sharing class XC_TR_Configuration_U_FillFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_FillFields');

    /**
     * @description Change status update. 
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void changeStatusUpdate(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        //List<NE__Order__c> listConfigurationNew = XC_UTIL_Configuration.getConfigurationNew(listNew);
        List<String> fieldList = new List<String> {'XC_Status__c', 'NE__OrderStatus__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        
        if(!listChanged.isEmpty()){  
            changeStatus(listChanged, mapOld, mapNew);
        }
    }

    private static void changeStatus(List<NE__Order__c> listChanged, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){ 
        List<NE__Order__c> listOrders = new List<NE__Order__c>();
        for(NE__Order__c ord : listChanged) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### listchanged id and status ### ' + ord.Id + ' ' + ord.XC_Status__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### mapold XC_Status__c ### ' + mapOld.get(ord.Id).XC_Status__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### mapnew XC_Status__c ### ' + mapNew.get(ord.Id).XC_Status__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'### RT ### ' + ord.RecordTypeId); 
            if(ord.RecordTypeId == Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId()){
                listOrders.add(ord);
            }
        }
        if(!listOrders.isEmpty()){
        	changeStatusOrders(listOrders, mapOld, mapNew);   
        }
    }

    /**
     * @description Change status 
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    private static void changeStatusOrders(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){ 
        List<Id> listOrderId = XC_UTIL_SObject.getIds(listNew); 
        Map<Id, NE__Order__c> mapOrderAndOpty = getOrderAndOpty(listOrderId);
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        Opportunity opty; 

        /******* Creation of administrative case **********/
        /*Group queueBOAdministrative;
        Boolean retrievedQueueId = false;
        List<Case> listCaseToCreate = new List<Case>();
        Case c;
        List<String> splittedTasks = new List<String>();
        /**** ************************************* *********/

        Set<Id> listConfigurationItemIds = XC_UTIL_Configuration.getAllConfItemIds(listNew);
        //Map<Id, List<NE__Order_Item_Attribute__c>> mapOrderIdToOrderItemAttrs = XC_UTIL_Configuration.getOrderItemAttributesByListCIId(listConfigurationItemIds);

        //PERFORMANCE IMPROVEMENT - JUNE 2022 - GDB\FA
        //Map<Id, List<NE__OrderItem__c> > mapOrderIdToOrderItem = XC_UTIL_Configuration.getOrderItemFromConfiguration(listOrderId); // NM LR - 27/11/2018 - ESCEP-780
        Map<Id, List<NE__OrderItem__c> > mapOrderIdToOrderItem = new Map<Id, List<NE__OrderItem__c> >();
        for(NE__Order__c ord : mapOrderAndOpty.values()){
            mapOrderIdToOrderItem.put(ord.Id, ord.NE__Order_Items__r);
        }

        for(NE__Order__c conf : listNew) {

            XC_UTIL_Debug.debug(DEBUGACTIVE, 'status->' + conf.XC_Status__c);  

            XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN IF, status->' + conf.XC_Status__c);
            /*if(String.isBlank(conf.Id)) {
                continue;   
            }*/
            opty = new Opportunity();
            opty.Id = mapOrderAndOpty.get(conf.Id).NE__OptyId__r.Id;

            if((conf.XC_Status__c == Label.XC_CL_Configuration_QuoteDraft) &&
            (conf.NE__OrderStatus__c != 'Cancelled')) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN IF, status->' + conf.XC_Status__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderTrigger->' + conf.RecordTypeId);
                mapNew.get(conf.Id).XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
                opty.XC_Substatus__c = Label.XC_CL_Opportunity_OrderInProgress;

            } else if ((mapOld.get(conf.Id).NE__OrderStatus__c != Label.XC_CL_Order_StatusSent) &&
                    (mapNew.get(conf.Id).NE__OrderStatus__c == Label.XC_CL_Order_StatusSent) &&
                    (conf.XC_Status__c != Label.XC_CL_Configuration_OrderCancelled)) {

                mapNew.get(conf.Id).XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
                mapNew.get(conf.Id).XC_In_Provisioning__c = true;

                XC_UTIL_Debug.debug(DEBUGACTIVE, 'pick compliance ' + conf.XC_Compliance_Approval__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'pick financial ' + conf.XC_FinancialApproval__c);
                //Boolean checkInProvisioning = (((conf.XC_Compliance_Approval__c == Label.XC_CL_Configuration_NotNeeded) || (conf.XC_Compliance_Approval__c == Label.XC_CL_Configuration_Approved)) &&
                //                       ((conf.XC_FinancialApproval__c == Label.XC_CL_Configuration_NotNeeded) || (conf.XC_FinancialApproval__c == Label.XC_CL_Configuration_Approved)));

                /**
                *   03/01/2019 
                *   @Federico Amici commented the manage of the provisioning */
                if(mapNew.get(conf.Id).XC_In_Provisioning__c) {                                   
                    /*XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN ELIF status->' + conf.XC_Status__c);
                    mapNew.get(conf.Id).XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
                    mapNew.get(conf.Id).XC_In_Provisioning__c = true;*/

                    
                    opty.XC_Substatus__c = Label.XC_CL_Opportunity_OrderInProvisioning;
                    //opty.StageName = Label.XC_CL_Opportunity_ClosedWon; GS 28/12/2018

                    /*if(!String.isBlank(conf.XC_AdministrativeTasks__c)) {

                        if(!retrievedQueueId) {
                            queueBOAdministrative = [SELECT Id FROM Group WHERE Name = 'BO Administrative Queue'];
                            retrievedQueueId = true;
                        }

                        splittedTasks = conf.XC_AdministrativeTasks__c.split(';');

                        c = XC_UTIL_Case.createAdministrativeCase(conf.Id, queueBOAdministrative.Id, conf.XC_AdministrativeTasks__c);
                        listCaseToCreate.add(c);

                    }*/

                    checkInstallationAddress(mapOrderAndOpty.get(conf.Id), conf);

                    // NM LR - 27/11/2018 - ESCEP-780 ___________
                    checkPhoneRequired(mapOrderAndOpty.get(conf.Id), mapOrderIdToOrderItem.get(conf.Id), mapNew.get(conf.Id));
                    //___________________________________________
                }
            } 
            if(String.isNotBlank(opty.XC_Substatus__c)) {
                opportunityToUpdate.add(opty);
            }
        }

        XC_UTIL_SObject.updateListRecords(opportunityToUpdate);
    }

    /**
     * @description Gets the order and opty 
     * @param listOrderId the list order id
     * @return the order and opty
     */
    public static Map<Id, NE__Order__c> getOrderAndOpty(List<Id> listOrderId) {

        Map<Id, NE__Order__c> mapOrderAndOpty = new Map<Id, NE__Order__c>([SELECT Id, XC_Status__c, NE__OptyId__r.StageName,
                                                                        NE__Configuration_Type__c, XC_AdministrativeTasks__c,
                                                                        XC_Compliance_Approval__c, XC_FinancialApproval__C,
                                                                        XC_InstallationAddress__c,
                                                                        (SELECT Id, NE__ProdName__c, NE__OrderId__c, NE__Catalog__c, 
                                                                         NE__CatalogItem__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, 
                                                                         NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Phone_Required__c		 // GDB - JUNE 2022
                                                                         FROM NE__Order_Items__r),                        							 // FA - 05/12/2018
                                                                        NE__AccountId__c, NE__AccountId__r.MainPhone__c, NE__AccountId__r.Phone      // NM LR - 26/11/2018 - Bit2Win
                                                                        FROM NE__Order__c
                                                                        WHERE Id IN: listOrderId]);
        return mapOrderAndOpty;
    }

    /**
     * Creates the asset from order.
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    /*public static void createAssetFromOrder(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {

        //List<NE__Order__c> listConfigurationNew = XC_UTIL_Configuration.getConfigurationNew(listNew);
        List<String> fieldList = new List<String> {'NE__OrderStatus__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        //if(avoidRecursion()) {return;}

        for(NE__Order__c order : listChanged) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ' + order.NE__OrderStatus__c + ' xc_status ' + order.XC_Status__c);
            if(order.NE__OrderStatus__c == Label.XC_CL_Order_StatusSent) {
                NE.JS_RemoteMethods.order2asset(order.ID);
            }
        }

    }*/

    /**
     * @param newOrder the new order
     * @param trOrder the tr order
     * @author: Federico Amici - federico.amici@nttdata.com
     * @data: 05/12/2018
     * @modification : dd/mm/yyyy
     * @description : Method to check if one of the Configuration Item requires installation and the XC_InstallationAddress__c
     *                   field on Configuration is not filled. If so, an error is thrown
     */
    public static void checkInstallationAddress(NE__Order__c newOrder, NE__Order__c trOrder) {

        if(newOrder == null) {
            return;
        }

        List<NE__OrderItem__c> listOrderItems = newOrder.NE__Order_Items__r;

        if(listOrderItems == null || listOrderItems.isEmpty()) {
            return;
        }
        
        for(NE__OrderItem__c item : listOrderItems) {

            if((item.NE__ProdName__c == Label.XC_CL_Configuration_InstallationRequired) && (String.isBlank(newOrder.XC_InstallationAddress__c))) {
                trOrder.addError(Label.XC_CL_Configuration_FillInstallationAddress);
            }
        }
    }

    /**
     * @param order the order
     * @param orderItemList the order item list
     * @param orderForError the order for error
     * @author: Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
     * @data: 27/11/2018
     * @modification : dd/mm/yyyy
     * @description : Method to check if one of the Phone fields on Account is filled when XC_Phone_Required is true
     */
    public static void checkPhoneRequired(NE__Order__c order, List<NE__OrderItem__c> orderItemList, NE__Order__c orderForError) {
        if(orderItemList!=null){
            for(NE__OrderItem__c orItem : orderItemList) {
                if(orItem.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Phone_Required__c == true
                && order.NE__AccountId__r.MainPhone__c == null && order.NE__AccountId__r.Phone == null) {
                    orderForError.addError(Label.XC_CL_Configuration_PhoneRequired);
                }
            }
        }
    }

    /**
     * @param listNew - List<NE__Order__c>
     * @data 23/4/2019 
     * @description Method to populatre fields from Opportunity for e-mobility
     */
    /*public static void checkEmobilityFields(List<NE__Order__c> listNew){
        List<Id> listIdOpp = XC_UTIL_Sobject.getListFieldValues(listNew, 'NE__OptyId__c');
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT Id, XC_CompanyCode__c, XC_CostCenter__c
                                                                 FROM Opportunity
                                                                 WHERE Id IN :listIdOpp]);
        for(NE__Order__c conf : listNew){
            if(conf.RecordTypeAUX__c == 'Order' && mapOpp.containsKey(conf.NE__OptyId__c)){ 
                if(String.isBlank(conf.XC_Cost_Center__c)){
                	conf.XC_Cost_Center__c = mapOpp.get(conf.NE__OptyId__c).XC_CostCenter__c;
                }
                if(String.isBlank(conf.XC_Company_Code__c)){
                    conf.XC_Company_Code__c = mapOpp.get(conf.NE__OptyId__c).XC_CompanyCode__c;
                }
            }
        }
    }*/
    

    /**
     * @author Domenico Del Prete - domenico.delprete@nttdata.com
     * @date 02/05/2020
     * @description Method to reopen Cart 
     * @param confList - List<NE__Order__c> 
     * @param mapOld - Map<Id,NE__Order__c>
     * @param mapNew - Map<Id,NE__Order__c>
     */
    public static void openCartForTechnicalProduct(List<NE__Order__c> confList, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'RecordTypeId', 'NE__Type__c'}, mapOld, mapNew);
        List<NE__Order__c> listChangedRtOrder = new List<NE__Order__c>();
        String rtOrder = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        for(NE__Order__c ord : listChanged){
            if(ord.RecordTypeId.equals(rtOrder) && (ord.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder || ord.NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder)){
                listChangedRtOrder.add(ord);
            }
        }
        if(listChangedRtOrder.isEmpty()){
            return;
        }
        //List<String> oppId = new List<String>();
        Opportunity oppToUpdate;
        List<Opportunity> listOfOpp = new List<Opportunity>();
        for(NE__Order__c ord : confList){
            if(!String.isBlank(ord.NE__OptyId__c)){
                oppToUpdate = new Opportunity(Id = ord.NE__OptyId__c);
                oppToUpdate.XC_TechnicalProductOnly__c = (ord.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder);
                listOfOpp.add(oppToUpdate);
                //oppId.add(ord.NE__OptyId__c);
            }
        }
        /*List<Opportunity> listOfOpp = new List<Opportunity>();
        for(String idopp : oppId){
            Opportunity oppToUpdate = new Opportunity(Id = idopp);
            oppToUpdate.XC_TechnicalProductOnly__c = true;
            listOfOpp.add(oppToUpdate);
        }*/
        List<Id> listOrderId = XC_UTIL_Sobject.getIds(listChangedRtOrder); 
        List<NE__OrderItem__c> listOfOI = new List<NE__OrderItem__c>([
            SELECT Id, XC_Product_Type__c, NE__Root_Order_Item__c, NE__Bundle_Configuration__c, NE__OrderId__r.NE__Type__c 
            FROM NE__OrderItem__c WHERE NE__OrderId__c IN: listOrderId]);
        List<NE__OrderItem__c> listOfOiToUpdate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : listOfOI){
            if( Label.XC_CL_Technical.equals(oi.XC_Product_Type__c) && 
                String.isBlank(oi.NE__Root_Order_Item__c) && String.isBlank(oi.NE__Bundle_Configuration__c) && 
                oi.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder ){
                continue;
            }
            else{
                oi.NE__Hidden_in_Cart__c = (oi.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder); //true;
                listOfOiToUpdate.add(oi);
            }
        }
        XC_UTIL_Sobject.updateListRecords(listOfOiToUpdate);
        XC_UTIL_Sobject.updateListRecords(listOfOpp);
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 2/5/2020 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    **/
    public static void setTechnicalProductOnly (List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<String> fieldList = new List<String> {'RecordTypeId'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        
        if(!listChanged.isEmpty()){  
            List<NE__Order__c> ordersToUpdateList = checkRecordType(listChanged, mapOld, mapNew);
            for(NE__Order__c order : ordersToUpdateList){
                order.XC_TechnicalProductOnly__c = true;
            }
        }
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 2/5/2020 
    * @param listOrderChanged 
    * @param mapOldS 
    * @param mapNewS 
    * @return orderList
    **/
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
     * @param listOrder the new Orders
     * @author: Dario Tramontin dtramontin@deloitte.it - Marina Ciavarra mciavarra@deloitte.it
     * @data: 09/11/2020
     * @modification : 06/07/2022 added NE__BillAccId__c population 
     * @description : Method to populate Addresss and CallType from Opportunity
     */
    public static void populateFieldsFromOpportunity(List<NE__Order__c> listOrder){
        List<String> listOpportunityId = XC_UTIL_Sobject.getListFieldValues(listOrder, 'NE__OptyId__c');
        Map<Id,Opportunity> oppMap = new Map<Id, Opportunity> ([
            SELECT Id, XC_Address__c, XC_LegalEntity__c, XC_Country__c, AccountId, XC_Segment__c, XC_ResidentialAddress__c,XC_Billing_Account__c,
                    XC_CampaignPlatform__c, XC_CampaignProduct__c, XC_CampaignCode__c, XC_ConventionCode__c, XC_ECID__c,XC_CTI_Interaction__c,XC_CTI_Interaction__r.XC_Communication_Type__c
            FROM Opportunity 
            WHERE Id IN: listOpportunityId
        ]);

        XC_TR_Configuration_U_FillAddress.populateAddressFromOpportunity(listOrder, oppMap);

        for(NE__Order__c configuration : listOrder){
            if(oppMap.containsKey(configuration.NE__OptyId__c)){
                Opportunity opp = oppMap.get(configuration.NE__OptyId__c);
                if(!String.isBlank(opp.XC_CTI_Interaction__c)){
                    configuration.XC_CallType__c = opp.XC_CTI_Interaction__r.XC_Communication_Type__c;
                }
                if (!String.isBlank(opp.XC_Billing_Account__c)) {
                    configuration.NE__BillAccId__c = opp.XC_Billing_Account__c;
                }
            }
        }
    }

    public static void checkStepCustomerAcceptance(List<NE__Order__c> listOrder, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<String> fieldList = new List<String> {'XC_EnhancedAcceptanaceResponse__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<String> confIdAccepted = new List<String>();
        System.debug('CheckStep on ' + listChanged);
        if(!listChanged.isEmpty()){
            for(NE__Order__c configuration : listChanged){
                if(configuration.XC_EnhancedAcceptanaceResponse__c == Label.XC_CL_CTIAcceptedResponse){
                    confIdAccepted.add(configuration.Id);
                    System.debug('Configuration' + configuration.Id);

                }
            }
            
            List<XC_Provisioning_Step__c> getSteps = new List<XC_Provisioning_Step__c>([SELECT Id, XC_Status__c
            FROM XC_Provisioning_Step__c 
            WHERE XC_Configuration_Item__r.NE__OrderId__c IN : confIdAccepted
            AND XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress
            AND XC_StepLabel__c =: Label.XC_CL_ProvStep_CheckCustomerAcceptance]);

            for(XC_Provisioning_Step__c step: getSteps){
                System.debug('Step to update: ' + step.Id);
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
            }

            XC_UTIL_Sobject.updateListRecords(getSteps);
        }
    }
}
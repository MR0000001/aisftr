/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com, Riccardo Cossu - riccardo.cossu@nttdata.com
* @date 26/11/2018
* @date Modification 05/03/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_WorkOrder_U_FillFieldByConfItem - The class populates a work order record according to the linked configuration item
*/

public without sharing class XC_TR_WorkOrder_U_FillFieldByConfItem {
      
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_FillFieldByConfItem');
    
    /**   
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listNew - List<WorkOrder>
     * @description Method to populate a work order record according to the linked configuration item
     */ 
    public static void fillFieldsFromConfigurationItem(List<WorkOrder> listNew){

        List<WorkOrder> woWithOrder = new List<WorkOrder>();
        List<WorkOrder> woWithOrderItem = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(!String.isBlank(wo.XC_Configuration_Item__c)){
                woWithOrderItem.add(wo);
            } 
            if(!String.isBlank(wo.XC_Configuration__c)){
                woWithOrder.add(wo);
            }
        }

        if(!woWithOrder.isEmpty()){
            Map<Id, NE__Order__c> mapOrder = new Map<ID, NE__Order__c>([
                SELECT  Id, NE__OptyId__r.XC_BusinessLine__c
                FROM NE__Order__c 
                WHERE Id IN :XC_UTIL_SObject.getListFieldValues(woWithOrder, 'XC_Configuration__c')
            ]);
            
            for(WorkOrder wo : woWithOrder){ 
                if((wo.XC_WorkTypeCategory__c == 'Sales Site Inspection' || wo.XC_WorkTypeCategory__c == 'Site Inspection' ) && wo.XC_Configuration__c!=null && mapOrder.get(wo.XC_Configuration__c)!=null) {
                    wo.BusinessLine__c = mapOrder.get(wo.XC_Configuration__c).NE__OptyId__r.XC_BusinessLine__c;
                }
            }
        }

        if(woWithOrderItem.isEmpty()){
            return;
        }

        List<Id> listOrderItemIds = XC_UTIL_SObject.getListFieldValues(woWithOrderItem, 'XC_Configuration_Item__c'); 

        Map<Id, NE__OrderItem__c> mapOrderItem = new Map<ID, NE__OrderItem__c>([
            SELECT  Id, NE__Account__c, NE__OrderId__c, XC_Effective_Product_Availability_Date__c, XC_EffectiveDeliveryDate__c,  XC_DeliveryType__c,XC_CountryFormula__c,
                    XC_DurationInMinutes__c,NE__SerialNum__c,XC_Product_Reservation__c,XC_DeliveryId__c,NE__Qty__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, XC_Delivery_Tracking_URL__c, 
                    XC_Courier_Partner__c, XC_PaymentMethod__c, NE__CatalogItem__r.NE__Product_Name__c, NE__OrderId__r.XC_InstallationAddress__c, NE__OrderId__r.XC_InstallationAddress__r.XC_Address__c, 
                    NE__OrderId__r.XC_InstallationAddress__r.XC_PostalCode__c,NE__OrderId__r.XC_InstallationAddress__r.XC_City__c, NE__OrderId__r.XC_InstallationAddress__r.XC_AddressCountry__c,  
                    NE__OrderId__r.NE__OptyId__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__CatalogItem__c, NE__OrderId__r.XC_InstallationAddress__r.XC_StreetTypeText__c, NE__OrderId__r.XC_InstallationAddress__r.XC_StreetNumber__c,
            		NE__OrderId__r.OwnerId, NE__OrderId__r.XC_UserId__c,
                    (SELECT Id, XC_ConfigurationItemIncentive__c FROM Cases__r WHERE XC_ConfigurationItemIncentive__c != null),
                    (SELECT Id FROM Assets__r),
                    (SELECT id, XC_DeveloperName__c, NE__Value__c FROM NE__Order_Item_Attributes__r) // SS  NR1757 - 04/05/2021
            FROM NE__OrderItem__c 
            WHERE Id IN :listOrderItemIds
        ]);
        if(mapOrderItem.isEmpty()) return;
        
        Map<Id, Boolean> woIdWasteDisposalBlockMap = getInfoByCountryLegalEntityAssociation(woWithOrderItem);
        for(WorkOrder wo : woWithOrderItem){  
            if(!mapOrderItem.containsKey(wo.XC_Configuration_Item__c)){
                continue;
            }
            NE__OrderItem__c confItem =  mapOrderItem.get(wo.XC_Configuration_Item__c);
            system.debug('confItem Test'+' '+confItem);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ -> ' + confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_Address__c);
            system.debug('Test'+' '+confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_Address__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ -> ' + confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_PostalCode__c);
            system.debug('Test 2'+' '+confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_PostalCode__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ -> ' + confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_City__c);
            populateFields(wo, confItem, woIdWasteDisposalBlockMap);      
        } 
    }

    /** 
    * @description Method to populate fields from Configuration Item related
    * @param wo - WorkOrder
    * @param confItem - NE__OrderItem__c
    */ 
    private static void populateFields(WorkOrder wo, NE__OrderItem__c confItem, Map<Id, Boolean> woIdWasteDisposalBlockMap) {
        wo.AccountId = confItem.NE__Account__c;
        wo.ContactId = confItem.NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
        populateOrder(confItem,wo);
        wo.XC_CatalogCategory__c = confItem.NE__CatalogItem__r.NE__Catalog_Category_Name__c;
        wo.XC_Product_Name__c = confItem.NE__CatalogItem__r.NE__Product_Name__c;
        wo.XC_Payment_Type__c = confItem.XC_PaymentMethod__c;

        if(String.isBlank(wo.XC_CatalogItemId__c)){
            wo.XC_CatalogItemId__c = confItem.NE__CatalogItem__c;
        }

        if(confItem.NE__OrderId__r.XC_InstallationAddress__c != null ){ 
            wo.Street = confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_StreetTypeText__c + ' ' +
                        confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_Address__c + ' ' +
                        confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_StreetNumber__c; 
            wo.PostalCode = confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_PostalCode__c;
            String tmpCity = confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_City__c;
            if(String.isNotBlank(tmpCity) && tmpCity.length() > 40){
                wo.City = tmpCity.substring(0, 40);
            } else {
                wo.City = tmpCity;
            }
            wo.Country = confItem.NE__OrderId__r.XC_InstallationAddress__r.XC_AddressCountry__c;
            wo.XC_Address__c = confItem.NE__OrderId__r.XC_InstallationAddress__c;
        }
      
        if(!confItem.Assets__r.isEmpty() && wo.XC_WorkTypeCategory__c != Label.XC_CL_WorkType_Substitution && String.isBlank(wo.AssetId)){
            wo.AssetId = confItem.Assets__r[0].Id;
        }

        if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && String.isBlank(wo.XC_Opportunity__c) && confItem.NE__OrderId__r.NE__OptyId__c != null ){ 
            wo.XC_Opportunity__c = confItem.NE__OrderId__r.NE__OptyId__c;
        }  
        if((wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && !String.isBlank(confItem.NE__OrderId__r.OwnerId) &&
            wo.XC_Segment__c=='B2C'){ //na add the segment check
            wo.OwnerId = confItem.NE__OrderId__r.OwnerId;
        }if((wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia) && !String.isBlank(confItem.NE__OrderId__r.OwnerId) &&
            (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G')&&
            !wo.XC_ToProject__c){ //na add the segment check
               wo.OwnerId = confItem.NE__OrderId__r.OwnerId;
            }
        if((wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') && wo.XC_ToProject__c && String.isNotBlank(confItem.NE__OrderId__r.XC_UserId__c)){
            wo.OwnerId = confItem.NE__OrderId__r.XC_UserId__c;

        }

        if(wo.XC_WorkTypeCategory__c == 'Delivery & Installation' && !confItem.Cases__r.isEmpty()) {
            wo.XC_ConfigurationItemIncentive__c = confItem.Cases__r[0].XC_ConfigurationItemIncentive__c;
        }
        // SS  NR1757 - 04/05/2021
        for(NE__Order_Item_Attribute__c orderItemAttr : confItem.NE__Order_Item_Attributes__r){
            if(orderItemAttr.XC_DeveloperName__c == Label.XC_CL_Attribute_RAEE && orderItemAttr.NE__Value__c == 'Si'){ 
                wo.XC_WasteDisposal__c = true;
            }
        }
        if(!woIdWasteDisposalBlockMap.isEmpty() && woIdWasteDisposalBlockMap.containsKey(wo.Id) && woIdWasteDisposalBlockMap.get(wo.Id)){
            wo.XC_WasteDisposalBlock__c = true;
        }
        // wo.XC_EffectiveProductAvailabilityDate__c = confItem.XC_Effective_Product_Availability_Date__c;
        // wo.XC_DeliveryDate__c = confItem.XC_EffectiveDeliveryDate__c;       
        // wo.XC_DeliveryType__c = confItem.XC_DeliveryType__c;
        // wo.XC_ProductReservationResult__c = confItem.XC_Product_Reservation__c;
        // wo.XC_DeliveryId__c = confItem.XC_DeliveryId__c;
        // wo.XC_Delivery_Tracking_URL__c = confItem.XC_Delivery_Tracking_URL__c;
        // wo.XC_Courier_Partner__c = confItem.XC_Courier_Partner__c;
        // if(confItem.NE__SerialNum__c != null){
        //      wo.XC_SerialNumber__c                 = confItem.NE__SerialNum__c;
        //}
        //populateDuration(confItem, wo);
    }

    /** 
    * @description Method to populate fields from Order
    * @param confItem - NE__OrderItem__c
    * @param wo - WorkOrder
    */ 
    private static void populateOrder(NE__OrderItem__c confItem, WorkOrder wo){
        if(wo.XC_NumberWorkOrdersDI__c == 1){
            wo.XC_Configuration__c = confItem.NE__OrderId__c;  
        }
    }

    /*private static void populateDuration(NE__OrderItem__c confItem, WorkOrder wo){
        if(confItem.XC_DurationInMinutes__c != null && (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) ){
            if(confItem.NE__Qty__c > 0){
                wo.Duration = confItem.XC_DurationInMinutes__c * confItem.NE__Qty__c;
                wo.DurationType = 'Minutes';
            }
            else if (confItem.XC_DurationInMinutes__c != null) {
                wo.Duration = confItem.XC_DurationInMinutes__c;
                wo.DurationType = 'Minutes';
            }
        }
    }*/

    private static Map<Id, Boolean> getInfoByCountryLegalEntityAssociation(List<WorkOrder> woList){
        Map<Id, Boolean> woIdDocumentNeededMap = new Map<Id, Boolean>();
        List<String> legalEntityList = new List<String>();
        List<String> segmentList = new List<String>();
        for(WorkOrder wo : woList){
            legalEntityList.add(wo.XC_LegalEntity__c);
            segmentList.add(wo.XC_Segment__c);
        }
        if(legalEntityList.isEmpty()){
            return woIdDocumentNeededMap;
        }
        List<XC_CM_CountryLegalEntityAssociation__mdt> countryLegalEntityAssociationList = new List<XC_CM_CountryLegalEntityAssociation__mdt>([SELECT Id,  XC_WorkOrderWasteDisposalBlock__c, XC_LegalEntity__c, XC_Stream__c
                                                                                                                                        FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                                                                                        WHERE XC_LegalEntity__c IN: legalEntityList
                                                                                                                                        AND XC_Stream__c IN: segmentList]);
        for(WorkOrder wo : woList){
            for(XC_CM_CountryLegalEntityAssociation__mdt clea : countryLegalEntityAssociationList){
                if(wo.XC_LegalEntity__c == clea.XC_LegalEntity__c && wo.XC_Segment__c == clea.XC_Stream__c && clea.XC_WorkOrderWasteDisposalBlock__c){
                    woIdDocumentNeededMap.put(wo.Id, true);
                } else {
                    woIdDocumentNeededMap.put(wo.Id, false);
                }
            }
        }
        return woIdDocumentNeededMap;
    }
}
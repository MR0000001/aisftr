/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_LCC_056_CalculateWBS_U {
    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBE
* @param recordId Id
* @return errorMsg String
*/
    public static List<NE__OrderItem__c> retriveConfItem(Id recordId) {
        List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>();
        // @ Mod CV CR.NR1652 @date 28/10/2021 add XC_Zone__c to quey
        if (Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            listItems = [select Id, NE__Item_Code__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.XC_ProductServiceType__c,
                    NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__ProdName__c,NE__OrderId__r.Name, RecordType.DeveloperName,NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c, NE__OrderId__r.NE__OptyId__r.XC_ProductCategoryOfInterest__c,
                    NE__OrderId__r.XC_Subtype__c, RecordType.name,XC_Product_Subtype__c,NE__Parent_Order_Item__c, XC_BillingModel__c, NE__OrderId__r.XC_Segment__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ContractStartDate__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ContractEndDate__c,
                    NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c,
                    NE__OrderId__r.NE__OptyId__r.XC_GrossMarginFullLife__c,
                    NE__OrderId__r.NE__OptyId__r.Contract.XC_ContractType__c,
                    NE__OrderId__r.NE__AccountId__r.IdentityType__c,
                    NE__OrderId__r.NE__AccountId__r.IdentityNumber__c,
                    NE__OrderId__r.NE__AccountId__r.Name,
                    XC_Installation_Address__r.XC_PostalCode__c,
                    NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c,
                    NE__OrderId__r.NE__OptyId__r.XC_LOT__c,
                    NE__OrderId__r.NE__OptyId__r.XC_Zone__c ,
                    XC_Segment__c,
                    XC_LegalEntity__c,
                    XC_BlockWBE_User__c,
                    NE__OrderId__r.XC_PlantOwnership__c,
                    NE__OrderId__r.XC_UpdateWBE_FromButton__c,
                    XC_WBE_Status__c,
                    XC_RecurringDuration__c,
                    NE__OrderId__r.NE__OptyId__r.XC_Segment__c, NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, XC_EstimatedRevenue__c, XC_RevenueFullLife__c, XC_CostFullLife__c, NE__CatalogItem__r.NE__Item_Header__c, XC_CapexFullLife__c,
                    NE__OrderId__r.XC_Calculation_Channel_WBE_EC__c,XC_Country__c, NE__OrderId__c //[ jayaprasath.tj@accenture.com, 05/05/2022, ID-1 Update Calcola WBE, NR2453, R2-2022 ]     
            from NE__OrderItem__c
            //  where NE__OrderId__c = :recordId
            where NE__OrderId__c = :recordId  AND XC_Wbe__c ='' AND RecordType.DeveloperName != 'Technical_Item'/* AND NE__ProdName__c != :Constants.B2B_PROJECT AND NE__ProdName__c != :Constants.B2G_PROJECT AND RecordType.DeveloperName != :Constants.B2W_RECORDTYPE_TECHNICALITEM*/
            ];
        }
        return listItems;
    }

    public static List<NE__OrderItem__c> retriveConfItemforPenlty(Id recordId) {
        List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>();
        if (Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            listItems = [
                    select id, NE__Parent_Order_Item__r.XC_Wbe__c, XC_TotalPrice__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_ProductLine__c, NE__CatalogItem__r.XC_ProductServiceType__c,XC_Wbe__c,
                            NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c, NE__ProdName__c,NE__OrderId__r.Name, RecordType.DeveloperName,NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c,
                            NE__OrderId__r.XC_Subtype__c, RecordType.name,XC_Product_Subtype__c,NE__Parent_Order_Item__c
                    from NE__OrderItem__c
                    //  where NE__OrderId__c = :recordId
                    where NE__OrderId__c = :recordId /* AND NE__ProdName__c != :Constants.B2B_PROJECT AND NE__ProdName__c != :Constants.B2G_PROJECT AND RecordType.DeveloperName != :Constants.B2W_RECORDTYPE_TECHNICALITEM*/
            ];
        }
        return listItems;
    }





    /**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 02/05/2019
* @param listOrderItem - List<NE__OrderItem__c>
* @description Method to retrieve a map where key->CompanyName and value->CompanyCode
* @return Map<String, String>
*/
    /*
    public static Map<String, String> getMapCompanyCode(List<NE__OrderItem__c> listOrderItem) {

        Map<String, String> mapCompanyCode = new Map<String, String>();

        if(!Schema.sObjectType.XC_CM_LegalEntity_Configuration__mdt.isAccessible()){
            mapCompanyCode.put('', '0000');
            return mapCompanyCode;
        }
        List<XC_CM_LegalEntity_Configuration__mdt> listCompanyCM = [
            SELECT XC_LegalEntity__c , XC_CompanyCode__c
            FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: UserInfo.getOrganizationId() LIMIT 50000
        ];
        Map<String, String> mapCompanyCM = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt companyCM : listCompanyCM) {
            mapCompanyCM.put(companyCM.XC_LegalEntity__c , companyCM.XC_CompanyCode__c);
        }
        for(NE__OrderItem__c orderItem : listOrderItem) {
            String checkCompanyName = orderItem.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            if(mapCompanyCM.containsKey(checkCompanyName)) {
                mapCompanyCode.put(checkCompanyName, mapCompanyCM.get(checkCompanyName));
            } else {
                mapCompanyCode.put(checkCompanyName, '0000');
            }
        }

        //If null, it returns '0'
        if(mapCompanyCode.isEmpty()) {
            mapCompanyCode.put('', '0000');
        }
        return mapCompanyCode;
    }
    */


    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @date Modification 17/09/2019 - last modified by Nicola Arrigo
* @description method calculate WBS
* @param mapCostCenter Map<Id, String>
* @param mapProfitCenter Map<Id, String>
* @param listItems List<NE__OrderItem__c>
* @return Map<Id,XC_WBERegistry__c>
*/
    /*
    public static Map<Id,XC_WbeTracking__c> updateConfItem(Map<Id, String> mapCostCenter, Map<Id, String> mapProfitCenter, List<NE__OrderItem__c> listItems) {
        Map<Id,XC_WbeTracking__c> confIdWbeUpdate = new Map<Id,XC_WbeTracking__c>();
        List<NE__OrderItem__c> listToUpdate = new List<NE__OrderItem__c>();
        List<XC_WbeTracking__c > listWBE = new List<XC_WbeTracking__c >();
        for (NE__OrderItem__c ne : listItems) {
            for (Id i : mapCostCenter.keySet()) {

                if (ne.id == i) {
                    XC_WbeTracking__c wbeObjcet = new XC_WbeTracking__c();
                    ne.XC_CMProfitCenter__c = mapProfitCenter.get(i);
                    ne.XC_CMCostCenter__c = mapCostCenter.get(i);
                    wbeObjcet.XC_ConfigurationItemId__c = ne.id;
                    wbeObjcet.XC_ConfigurationId__c = ne.NE__OrderId__c;
                    wbeObjcet.XC_OrderNumber__c = ne.NE__OrderId__r.Name;
                    wbeObjcet.XC_TypeofSending__c = 'Order Submit';//Constants.WBE_TYPEOFSENDING_ORDER_SUBMIT;
                    wbeObjcet.XC_ClientIdentifier__c =''; //ne.NE__Account__r.XC_CIF__c;
                    wbeObjcet.XC_ProfitCenter__c = mapProfitCenter.get(i);
                    wbeObjcet.XC_CostCenter__c = mapCostCenter.get(i);
                    wbeObjcet.XC_Scope__c = 'B2B/G';//Constants.WBE_STATUS_NEW;
                    wbeObjcet.XC_SapPillar__c = 'S4P';//Constants.WBE_STATUS_NEW;
                    wbeObjcet.WBS__c = 'WBS';//Constants.WBE_STATUS_NEW;
                    wbeObjcet.XC_ProductService__c = 'test';//Constants.WBE_STATUS_NEW;
                    wbeObjcet.XC_Status__c = 'New';//Constants.WBE_STATUS_NEW;
                    listWBE.add(wbeObjcet);

                    System.debug('Mappa confidwbePut'+ne.id + '-->'+wbeObjcet);
                    confIdWbeUpdate.put(ne.id,wbeObjcet);



                    listToUpdate.add(ne);
                }
            }
        }
        If (Schema.sObjectType.NE__OrderItem__c.isUpdateable() && !listToUpdate.isEmpty()) {
            update(listToUpdate);
        }
        //Database.insert(listWBE,true);
        return confIdWbeUpdate;
    }
    */


    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBS
* @param mapDim7 Map<Id, String>
* @param listItems List<NE__OrderItem__c>
* @return mapDim8 Map<Id,String>
*/
    /*
   public static Map<Id,String> retriveCodeAutoNumber(Map<Id, String> mapDim7, List<NE__OrderItem__c>  listItems ){
       String orderNumber = listItems[0].NE__OrderId__r.Name;
       Map<String,String> mapNameCodeAutoNumbe = new Map<String,String>();
       mapNameCodeAutoNumbe = querToGetAutoNumber(orderNumber);
       Map<Id,String> mapDim8 = new Map<Id,String>();
       String autoNumber = '';
       Integer numAutoInt = 0;
       String encodeValue= '';
       String dim8 ='';
       String old ='';
       for(Id i : mapDim7.keySet()){
           for(NE__OrderItem__c ne : listItems){
               if(i==ne.id){
                   old = mapDim7.get(i);
                   System.debug('old'+old);
                   numAutoInt =  Integer.valueOf(mapNameCodeAutoNumbe.get(ne.NE__OrderId__r.Name)) != null ? Integer.valueOf(mapNameCodeAutoNumbe.get(ne.NE__OrderId__r.Name)) : Integer.valueOf('99999999') ;
                   System.debug('numAutoInt'+numAutoInt);
                   encodeValue= XC_Encode_Base62.generateBase62(numAutoInt, 4);
                   System.debug('encodeValue'+encodeValue);

                   //Aggiungere metodo per la decodifica
                   dim8 = old + encodeValue+'00';
                   XC_WbeTracking__c wberegb= new XC_WbeTracking__c();// XC_LCC_056_CalculateWBS.confIdWbe.get(i);
                   wberegb.XC_WBE__c = dim8;
                   System.debug('wberegb.XC_WBE__c'+wberegb.XC_WBE__c);
                   System.debug('dim8'+dim8);
                   mapDim8.put(i,dim8);
               }
           }
       }

       return mapDim8;

   }

     */
    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBS
* @lastmodifieddate 17/09/2019 - lastmodifiedby Nicola Arrigo
* @param wbsFinal Map<Id, String>
* @param listItems List<NE__OrderItem__c>
* @return error String
*/
    /*
   public static String updateConfItemWBS(Map<Id, String> wbsFinal, List<NE__OrderItem__c> listItems) {
       String error ='ERROR';
       List<XC_WbeTracking__c> listToInsertWBE = new List<XC_WbeTracking__c>();

       List<NE__OrderItem__c> listToUpdate = new List<NE__OrderItem__c>();
       for (NE__OrderItem__c ne : listItems) {
           for (Id i : wbsFinal.keySet()) {
               if(ne.id==i){
                   ne.XC_WBE__c = wbsFinal.get(i);
                   XC_LCC_056_CalculateWBS.confIdWbe.get(i).XC_WBE__c = wbsFinal.get(i);
                   listToInsertWBE.add(XC_LCC_056_CalculateWBS.confIdWbe.get(i));
                   listToUpdate.add(ne);
               }
           }
       }
       return checkAccesibleandUpdate(listToUpdate,listToInsertWBE);

      /* if (Schema.sObjectType.NE__OrderItem__c.isUpdateable() && !listToUpdate.isEmpty()) {
           try{
               update(listToUpdate);
               Database.insert(XC_LCC_056_CalculateWBS.confIdWbe.values());
               error = 'OK';

           }
           catch (exception e){
               error = 'ERROR'+e;
           }

       }
       return error;
   }

     */



    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBS
* @lastmodifieddate 17/09/2019 - lastmodifiedby Nicola Arrigo
* @param wbsFinal Map<Id, String>
* @param listItems List<NE__OrderItem__c>
* @return error String
*/
    /*
   private static String checkAccesibleandUpdate(List<NE__OrderItem__c>listToUpdate, list<XC_WbeTracking__c> listToInsertWBE){
       String error = 'OK';
       If (Schema.sObjectType.NE__OrderItem__c.isUpdateable() && !listToUpdate.isEmpty()) {
           try{
               Database.update(listToUpdate);
               List<XC_WbeTracking__c> listToInsert = XC_LCC_056_CalculateWBS.confIdWbe.values();
               //insert listToInsert;
               System.debug('List to upsert ' + XC_LCC_056_CalculateWBS.confIdWbe.values());
               //Database.Upsert(XC_LCC_056_CalculateWBS.confIdWbe.values());
               Database.Upsert(listToInsertWBE);
               error = 'OK';


           }
           catch (exception e){
               error = 'ERROR'+e;
           }

       }
       return error;

   }

     */


    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBS
* @lastmodifieddate 17/09/2019 - lastmodifiedby Nicola Arrigo
* @param wbsFinal Map<Id, String>
* @param listItems List<NE__OrderItem__c>
* @return error String
*/

    /*
   private static Map<String,String> querToGetAutoNumber(String orderNumber){
       Map<String,String> mapStringCode = new Map<String,String>();
       List<XC_WBE_Order_Number__c> listAutoNumber = new List<XC_WBE_Order_Number__c>();
       if(Schema.sObjectType.XC_WBE_Order_Number__c.isAccessible()){
           listAutoNumber = [select id, XC_AutonumberWBS__c, Name from XC_WBE_Order_Number__c where name = :orderNumber];
       }
       for(XC_WBE_Order_Number__c an : listAutoNumber){
           if(an.XC_AutonumberWBS__c!=null){
           mapStringCode.put(an.name, an.XC_AutonumberWBS__c);
           }
       }
       if(mapStringCode.isEmpty()){
           mapStringCode.put(orderNumber,'00990263');
       }

       return mapStringCode;


   }

     */
    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBS
* @lastmodifieddate 17/09/2019 - lastmodifiedby Nicola Arrigo
* @param wbsFinal Map<Id, String>
* @param listItems List<NE__OrderItem__c>
* @return error String
*/
/*
public static List<NE__OrderItem__c> checkSkipWBE(List<NE__OrderItem__c> listItems){
    List<NE__OrderItem__c> orderItemsToUpdate = new List<NE__OrderItem__c>();
    List<XC_CM_WBE_Status__mdt> listWbeOfLE = [select id, XC_Status_WBE__c, XC_Legal_Entity__c, XC_Cost_Center__c, XC_Profit_Center__c, XC_WBE__c from XC_CM_WBE_Status__mdt where XC_Legal_Entity__c =:XC_UTIL_User.getLegalEntityFromUser()];
    for(XC_CM_WBE_Status__mdt cm :listWbeOfLE){
        if(cm.XC_Status_WBE__c =='Disable'){
            for(NE__OrderItem__c oi:listItems){
                oi.XC_WBE__c = cm.XC_WBE__c;
                oi.XC_CMProfitCenter__c= cm.XC_Profit_Center__c;
                oi.XC_CMCostCenter__c = cm.XC_Cost_Center__c;
                orderItemsToUpdate.add(oi);
            }
        }
    }
    if(!orderItemsToUpdate.isEmpty() && Schema.sObjectType.NE__OrderItem__c.isUpdateable()){
        update orderItemsToUpdate;
    }
    return orderItemsToUpdate;

}
*/
    /**
* @author: Donato Lombardi
* @date Creation Date 09/09/2019
* @description method calculate WBS
* @lastmodifieddate 17/09/2019 - lastmodifiedby Nicola Arrigo
* @param wbsFinal Map<Id, String>
* @param listItems List<NE__OrderItem__c>
* @return error String
*/
    public static List<NE__OrderItem__c> wbsToPenalty( List<NE__OrderItem__c> listItems){
        List<NE__OrderItem__c> orderItemsToPenalty = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemsChild = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ne : listItems){
            if(ne.XC_Product_Subtype__c == 'Penalty' && ne.NE__Parent_Order_Item__c != null){
                orderItemsChild.add(ne);
            }
            if(!orderItemsChild.isEmpty()){
                for(NE__OrderItem__c nep : listItems){
                    for(NE__OrderItem__c ch : orderItemsChild){

                        if(ch.NE__Parent_Order_Item__c == nep.id){

                            ch.XC_Wbe__c= changeCharacter(nep.XC_Wbe__c);
                            orderItemsToPenalty.add(ch);

                        }
                    }
                }
            }
        }
        if(!orderItemsToPenalty.isEmpty()){
            Database.update(orderItemsToPenalty);
            List<XC_WbeTracking__c> wbetrToInsert = new List<XC_WbeTracking__c>();
            wbetrToInsert = createWBETrakingforPenality(orderItemsToPenalty);
            System.debug('DL--> wbetrToInsert' + wbetrToInsert);
            insert wbetrToInsert;
        }

        return orderItemsToPenalty;

    }

    private static String changeCharacter(String source){
        return  source.mid(0,16) + 'A' +  source.mid(17,source.length());
        //return  source.mid(0,16) + 'A' + source.mid(17,24);
    }

    private static List<XC_WbeTracking__c> createWBETrakingforPenality(List<NE__OrderItem__c> orderItemsToPenalty){
        List<XC_WbeTracking__c> wbeTrackRetrived = retrieveWbeTrackingforPenality(orderItemsToPenalty);
        System.debug('DL--> wbeTrackRetrived' + wbeTrackRetrived);
        System.debug('DL--> orderItemsToPenalty' + orderItemsToPenalty);
        List<XC_WbeTracking__c> wbeTrackToIsert = new List<XC_WbeTracking__c>();
        for(NE__OrderItem__c ne : orderItemsToPenalty){
            for(XC_WbeTracking__c wt : wbeTrackRetrived){
                if(ne.NE__Parent_Order_Item__r.XC_Wbe__c == wt.XC_Wbe__c){
                    XC_WbeTracking__c wtInsert = new XC_WbeTracking__c();
                    wtInsert.XC_ConfigurationItemId__c = ne.id;
                    wtInsert.XC_ConfigurationId__c = wt.XC_ConfigurationId__c;
                    wtInsert.XC_OrderNumber__c = wt.XC_OrderNumber__c;
                    wtInsert.XC_SalesOrder__c = wt.XC_SalesOrder__c;
                    wtInsert.XC_Wbe__c = ne.XC_Wbe__c;
                    wtInsert.XC_CompanyCode__c = wt.XC_CompanyCode__c;
                    wtInsert.XC_ProductLine__c = wt.XC_ProductLine__c;
                    wtInsert.XC_ProductService__c = wt.XC_ProductService__c;
                    wtInsert.XC_WBS__c = wt.XC_WBS__c;
                    wtInsert.XC_WbeI__c = wt.XC_WbeI__c;
                    wtInsert.XC_WbeII__c = wt.XC_WbeII__c;
                    wtInsert.XC_BusinessModelCode__c = wt.XC_BusinessModelCode__c;
                    wtInsert.XC_Market__c = wt.XC_Market__c;
                    wtInsert.XC_Channel__c = wt.XC_Channel__c;
                    wtInsert.XC_CostCenterResponsible__c = wt.XC_CostCenterResponsible__c;
                    wtInsert.XC_CostCenter__c =wt.XC_CostCenter__c;
                    wtInsert.XC_ProfitCenter__c = wt.XC_ProfitCenter__c;
                    wtInsert.XC_SapPillar__c = wt.XC_SapPillar__c;
                    wtInsert.XC_Scope__c = wt.XC_Scope__c;
                    wtInsert.XC_TypeOfSending__c =  wt.XC_TypeOfSending__c;
                    wtInsert.XC_Status__c =  wt.XC_Status__c;
                    wbeTrackToIsert.add(wtInsert);

                }
            }
        }
        return wbeTrackToIsert;
    }

    private static List<XC_WbeTracking__c> retrieveWbeTrackingforPenality(List<NE__OrderItem__c> orderItemsToPenalty){
        Set<String> setOrderItemParent = new Set<String>();
        for(NE__OrderItem__c ne :orderItemsToPenalty){
            System.debug('DL--> setOrderItemParent' + ne);
            setOrderItemParent.add(ne.NE__Parent_Order_Item__r.XC_Wbe__c);
        }
        System.debug('DL--> setOrderItemParent' + setOrderItemParent);
        List<XC_WbeTracking__c> listWbeTrackingsRetrived = new List<XC_WbeTracking__c>();
        if(Schema.sObjectType.XC_WbeTracking__c.isAccessible()){
            listWbeTrackingsRetrived = [select Id, XC_CostCenter__c, XC_Counter__c, XC_ProfitCenter__c, XC_Result__c, XC_Status__c, XC_Wbe__c, XC_WBS__c, XC_BusinessModelCode__c, XC_ClientIdentifier__c, XC_ConfigurationId__c, XC_ConfigurationItemId__c, XC_ExecutionProjectId__c, XC_InvestmentReason__c, XC_OrderNumber__c, XC_ProductService__c, XC_ProjectType__c, XC_ReturnDate__c, XC_ReturnErrorDescription__c, XC_SapPillar__c, XC_Scope__c, XC_SentDate__c, XC_TypeOfSending__c, XC_WbsDescription__c, XC_CompanyCode__c, XC_ProductLine__c, XC_WbeI__c, XC_WbeIDescription__c, XC_Activity__c, XC_LegalEntityGeography__c, XC_WbeII__c, XC_WbeIIDescription__c, XC_Market__c, XC_TypeOfLocation__c, XC_Channel__c, XC_CustomerSegment__c, XC_CustomerRelevance__c, XC_CustomerSize__c, XC_TypeOfCustomer__c, XC_CustomerGeography__c, XC_WbeIII__c, XC_WbeIIIDescription__c, XC_SalesOrder__c, XC_KitLogistic__c, XC_Contract__c, XC_ReturnErrorcode__c, XC_Responsible__c, XC_Applicant__c, XC_OdvIntercompany__c, XC_CostCenterResponsible__c, XC_CostCenterApplicant__c   from XC_WbeTracking__c where XC_Wbe__c IN :setOrderItemParent];
            System.debug('DL--> listWbeTrackingsRetrived' + listWbeTrackingsRetrived);

        }
        return listWbeTrackingsRetrived;




    }

    public static Boolean checkWBEForPenality(String configurationId){
        Boolean checkNeedPenality = False;
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            orderItemList= [select id, NE__ProdName__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Country__c,
                    XC_Wbe__c, XC_Product_Subtype__c, XC_TotalPrice__c, NE__Parent_Order_Item__c, NE__Parent_Order_Item__r.NE__ProdName__c, NE__OrderId__r.NE__Type__c
            from NE__OrderItem__c
            where NE__OrderId__c = :configurationId];
        }
        /*if(!orderItemList.isEmpty() && !checkOrderIsB2B(orderItemList)){
            return false;
        }*/
        for(NE__OrderItem__c ne :orderItemList){
            System.debug('DL--> ne' + ne);
            System.debug('DL--> ne' + ne.NE__Parent_Order_Item__r.NE__ProdName__c);
            if(ne.NE__OrderId__r.XC_Segment__c == 'B2B' && ne.NE__ProdName__c != 'UBM' && ne.NE__OrderId__r.NE__Type__c != 'ChangeOrder' ){
                if(ne.XC_Product_Subtype__c == 'Penalty' && ne.NE__Parent_Order_Item__c != null && ne.XC_Wbe__c == Null){
                    checkNeedPenality = True;
                    break;
                }
            }

        }

        return checkNeedPenality;
    }

    /*private static Boolean checkOrderIsB2B(List<NE__OrderItem__c> orderItemList){
        Boolean checkB2B = False;
        List<XC_CM_CountryLegalEntityAssociation__mdt> listLegalEntityAss = new List<XC_CM_CountryLegalEntityAssociation__mdt>();
        listLegalEntityAss = [
                SELECT Id, XC_LegalEntity__c, XC_Country__c, XC_Category__c
                FROM XC_CM_CountryLegalEntityAssociation__mdt
                WHERE XC_LegalEntity__c = :orderItemList[0].NE__OrderId__r.XC_LegalEntity__c AND XC_Country__c  = :orderItemList[0].NE__OrderId__r.XC_Country__c];

        if(!listLegalEntityAss.isEmpty() && listLegalEntityAss[0].XC_Category__c == 'B2B'){
            checkB2B = True;
        }
        return checkB2B;
    }*/
}
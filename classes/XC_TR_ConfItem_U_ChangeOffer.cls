/**
 * @File Name          : XC_TR_ConfItem_U_ChangeOffer.cls
 * @Description        : check if a commercial offer change is in progress and update order fields
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 30/6/2020, 09:55:20
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/6/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_ConfItem_U_ChangeOffer {

    public static final Id orderRtId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
    public static final Set<String> admittedProductTypes = new Set<String>{'Bundle','Equipment','Service','Coverage'};

    /**
    * @description invoke the mark method in after insert
    * @author Francesco Imperioli - fimperioli@deloitte.it | 16/6/2020 
    * @param listNew 
    * @return void 
    **/
    public static void onAfterInsert(List<NE__OrderItem__c> listNew){
        markChangeOffer(listNew, true);
    }

    /**
    * @description invoked on after delete from the handler
    * @author Francesco Imperioli - fimperioli@deloitte.it | 16/6/2020 
    * @param mapOld 
    * @return void 
    **/
    public static void onAfterDelete(Map<Id,NE__OrderItem__c> mapOld){
        markChangeOffer(mapOld.values(),false);
    }

    /**
    * @description perform on before update operations in case of change offering during the order
    * @author Francesco Imperioli - fimperioli@deloitte.it | 17/6/2020 
    * @param mapOld 
    * @param mapNew 
    * @return void 
    **/
    public static void onBeforeUpdate(Map<Id,NE__OrderItem__c> mapOld,Map<Id,NE__OrderItem__c> mapNew){
        // BUNDLE ITEM ADDITION OPS
        // addBPLIOnBundleElemAddition(mapNew.values(),mapOld,mapNew);
    }


    /**
    * @description perform on after update operations in case of change offering during the order
    * @author Francesco Imperioli - fimperioli@deloitte.it | 17/6/2020 
    * @param mapOld 
    * @param mapNew 
    * @return void 
    **/
    public static void onAfterUpdate(Map<Id,NE__OrderItem__c> mapOld,Map<Id,NE__OrderItem__c> mapNew){
        recalculateCreditAssignmentAmounts(mapNew.values(), mapOld, mapNew);
    }


    /**
    * @description updates a configuration object flag in case of change of the commercial offer 
    in the final order phase before provisioning
    * @author Francesco Imperioli - fimperioli@deloitte.it | 16/6/2020 
    * @param listNew 
    * @return void 
    **/
    private static void markChangeOffer(List<NE__OrderItem__c> listNew,Boolean checkHuman){

        Set<String> orderIds = new Set<String>();
        Set<String> oisIds = new Set<String>();
        for(NE__OrderItem__c oi : listNew){
            orderIds.add(oi.NE__OrderId__c);
            oisIds.add(oi.Id);
        }

        if(!listNew.isEmpty()){
            
            Map<Id,NE__Order__c> orderMap = new Map<Id,NE__Order__c>([
                SELECT Id,NE__Type__c,XC_CommercialChange__c,RecordTypeId,XC_TechnicalProductOnly__c,
                    (SELECT Id,XC_BillingProfileLineItem__c,XC_PaymentMethod__c,XC_CreditAssignmentAvailable__c,XC_CongaDynamicAPI__c 
                    FROM NE__Order_Items__r 
                    WHERE ID NOT IN :oisIds)
                FROM NE__Order__c WHERE Id IN :orderIds]);
        
                System.Debug('OTHER OIS::: ' + orderMap.values()[0].NE__Order_Items__r);
        
                List<NE__Order__c> ordersToUpdate = new List<NE__Order__c>();
                List<NE__OrderItem__c> oisToUpdate = new List<NE__OrderItem__c>();
        
                for(NE__OrderItem__c oi : listNew){
                    NE__Order__c relatedOrder = orderMap.get(oi.NE__OrderId__c);
                    if(admittedProductTypes.contains(oi.XC_Product_Type__c) 
                    && relatedOrder.RecordTypeId == orderRtId 
                    && relatedOrder.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder 
                    && !relatedOrder.XC_CommercialChange__c
                    && !relatedOrder.XC_TechnicalProductOnly__c
                    ){
        
                        if((checkHuman && oi.NE__Picked_By__c == 'Human') || !checkHuman){
                            relatedOrder.XC_CommercialChange__c = true;
                            ordersToUpdate.add(relatedOrder);
        
                            //BLANK TECHNICAL FIELDS OVER ALL OTHER ITEMS
                            System.Debug('RELATED OTHER OIS::: ' + relatedOrder.NE__Order_Items__r);
        
                            for(NE__OrderItem__c otherOi : relatedOrder.NE__Order_Items__r){
                                if(String.isNotBlank(otherOi.XC_BillingProfileLineItem__c) || String.isNotBlank(otherOi.XC_PaymentMethod__c)){
                                    otherOi.XC_BillingProfileLineItem__c = null;
                                    otherOi.XC_PaymentMethod__c = null;
                                    otherOi.XC_CreditAssignmentAvailable__c = false;
                                    otherOi.XC_CongaDynamicAPI__c = null;
                                    oisToUpdate.add(otherOi);
                                }
                            }
                        }
                    }
                }
        
                if(!ordersToUpdate.isEmpty()){
                    XC_UTIL_Sobject.updateListRecords(ordersToUpdate);
                }
        
                if(!oisToUpdate.isEmpty()){
                    XC_UTIL_Sobject.updateListRecords(oisToUpdate);
                }
        }
    }


    /**
    * @description check if an orderItem NE__Bundle_Configuration__c field is updated during order phase, then gets the BPLI from bundle parent, called on before update
    * @author Francesco Imperioli - fimperioli@deloitte.it | 17/6/2020 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    * @return void 
    **/
    // private static void addBPLIOnBundleElemAddition(List<NE__OrderItem__c> listNew,Map<Id,NE__OrderItem__c> mapOld,Map<Id,NE__OrderItem__c> mapNew){

    //     List<NE__OrderItem__c> changedOis = XC_UTIL_Sobject.getListChanged(new List<String>{'NE__Bundle_Configuration__c'},mapOld,mapNew);
    //     Set<String> bundleIds = new Set<String>();

    //     System.Debug('CHANGED OIS BUNDLE CHANGE OFFER ' + changedOis);

    //     for(NE__OrderItem__c oi : changedOis){
    //         if((String.isBlank(oi.XC_PaymentMethod__c) || String.isBlank(oi.XC_BillingProfileLineItem__c)) && String.isNotBlank(oi.NE__Bundle_Configuration__c)){
    //             bundleIds.add(oi.NE__Bundle_Configuration__c);
    //         }
    //     }

    //     if(!bundleIds.isEmpty()){
    //         Map<Id,NE__OrderItem__c> bundleOiMap = new Map<Id,NE__OrderItem__c>([SELECT Id,NE__OrderId__r.RecordTypeId,NE__OrderId__r.NE__Type__c,
    //         XC_PaymentMethod__c,XC_BillingProfileLineItem__c
    //         FROM NE__OrderItem__c WHERE ID IN :bundleIds]);

    //         System.Debug('FULL QUERIED OIS CHANGE OFFER ' + bundleOiMap);

    //         for(NE__OrderItem__c oi : changedOis){

    //             if(String.isNotBlank(oi.NE__Bundle_Configuration__c)){     
    //                 NE__OrderItem__c bundleOi = bundleOiMap.get(oi.NE__Bundle_Configuration__c);
    //                 for(NE__OrderItem__c origOi : listNew){
    //                     if(bundleOi.NE__OrderId__r.RecordTypeId == orderRtId && bundleOi.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder && oi.Id==origOi.Id){
    //                         origOi.XC_PaymentMethod__c = bundleOi.XC_PaymentMethod__c;
    //                         origOi.XC_BillingProfileLineItem__c = bundleOi.XC_BillingProfileLineItem__c;
    //                     }
    //                 }
    //             }
    //         }
    //     }

    // }


    /**
    * @description if bundle total amount is changed, then incentive amounts have to change
    * @author Francesco Imperioli - fimperioli@deloitte.it | 17/6/2020 
    * @param listNew 
    * @param mapOld 
    * @param mapNew 
    * @return void 
    **/
    private static void recalculateCreditAssignmentAmounts (List<NE__OrderItem__c> listNew,Map<Id,NE__OrderItem__c> mapOld,Map<Id,NE__OrderItem__c> mapNew){

        List<NE__OrderItem__c> changedOis = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_BundleTotalOTAmount__c'},mapOld,mapNew);
        System.Debug('CHANGED OIS BUNDLE CHANGE OFFER ' + changedOis);
        Set<Id> bundleIds = XC_UTIL_Sobject.getSetIdsOnField(changedOis, 'Id');
        Set<String> bundlesToCheckIds = new Set<String>();

        if(!bundleIds.isEmpty()){
            List<NE__OrderItem__c> fullQueriedBundles = [SELECT Id,NE__OrderId__r.RecordTypeId,NE__OrderId__r.NE__Type__c FROM NE__OrderItem__c WHERE ID IN :bundleIds];
            for(NE__OrderItem__c bundleOi : fullQueriedBundles){
                if(bundleOi.NE__OrderId__r.RecordTypeId == orderRtId && bundleOi.NE__OrderId__r.NE__Type__c == Label.XC_CL_Configuration_TypeInOrder){
                    bundlesToCheckIds.add(bundleOi.Id);
                }
            }


            if(!bundlesToCheckIds.isEmpty()){
                //getting incentive items
                List<NE__OrderItem__c> incentiveItems = [SELECT Id,NE__Bundle_Configuration__c,
                NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c,
                NE__Bundle_Configuration__r.XC_CreditAssignmentAmount__c,
                    (SELECT Id,XC_DeveloperName__c,NE__Value__c FROM NE__Order_Item_Attributes__r) 
                FROM NE__OrderItem__c 
                WHERE NE__Bundle_Configuration__c IN : bundlesToCheckIds AND XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive];

                //if we have incentives, amounts have to be updated
                if(!incentiveItems.isEmpty()){
                    List<NE__OrderItem__c> oiToUpdate = new List<NE__OrderItem__c>();

                    for(NE__OrderItem__c incentiveOi : incentiveItems){
                        Map<String,String> attributeMap = getAttributeNameValueMap(incentiveOi.NE__Order_Item_Attributes__r);
                        Integer incentiveAmount = Integer.valueOf(attributeMap.get(Label.XC_CL_Incentive_Amount));
                        Decimal totalBundleAmount =  incentiveOi.NE__Bundle_Configuration__r.XC_BundleTotalOTAmount__c;
                        NE__OrderItem__c bundleOi = new NE__OrderItem__c (Id = incentiveOi.NE__Bundle_Configuration__c);

                        if(totalBundleAmount!=null){
                            Decimal CAAmount = ((totalBundleAmount / 100) * incentiveAmount).round();
                            incentiveOi.XC_CreditAssignmentAmount__c = CAAmount;
                            bundleOi.XC_CreditAssignmentAmount__c = CAAmount;
                            oiToUpdate.add(incentiveOi);
                            oiToUpdate.add(bundleOi);
                        }
                    }

                    if(!oiToUpdate.isEmpty()){
                        XC_UTIL_Sobject.updateListRecords(oiToUpdate);
                    }
                }
            }
        }
    }

    /**
    * @description returns b2w attributes as a name value map
    * @author Francesco Imperioli - fimperioli@deloitte.it | 17/6/2020 
    * @param oias 
    * @return Map<String, String> 
    **/
    private static Map<String,String> getAttributeNameValueMap (List<NE__Order_Item_Attribute__c> oias){
        Map<String,String> attrNameValueMap = new Map<String,String>();
        for(NE__Order_Item_Attribute__c attr : oias){
            attrNameValueMap.put(attr.XC_DeveloperName__c,attr.NE__Value__c);
        }
        return attrNameValueMap;
    }



}
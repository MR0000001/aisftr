/**
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       22/11/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         util class for  XC_IN038_ApplyCoupon
*/

public without sharing class XC_IN038_ApplyCoupon_U {

    /**
     * @description UtilWrapper
    */ 
    public class UtilWrapper {
        public Map<String, List<String>> mapItemAddRP = new Map<String, List<String>>();
        public Map<String, List<String>> mapItemRemoveRP = new Map<String, List<String>>();
        public Map<String, List<String>> mapItemChangeRP = new Map<String, List<String>>();
    }


    /**
     * @description RatePlanWrapper
    */ 
    public class RatePlanWrapper{
        public Map<String, List<String>> mapZquoteIdAddRP = new Map<String, List<String>>();
        public Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();
    }


    /**
     * @description cycleOnAsset
     * @param mapUtil
     */ 
    public static RatePlanWrapper cycleOnAsset(Map<String,Object> mapUtil){
        
        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = (XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems) mapUtil.get('wr');
        Map<String, List<String>> mapItemAddRP = (Map<String, List<String>>)  mapUtil.get('mapItemAddRP');
        Map<String, List<String>> mapItemRemoveRP = (Map<String, List<String>>)  mapUtil.get('mapItemRemoveRP');

        
        Map<String, List<String>> mapZquoteIdAddRP = new Map<String, List<String>>();
        Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();
        RatePlanWrapper rpWrapper= new RatePlanWrapper();
        String newItemId;
        String oldItemId;
        NE__OrderItem__c oldItem;
        NE__OrderItem__c newItem;
        List<String> listRatePlanAddTmp;
        List<String> listRatePlanRemoveTmp;
        List<String> listRatePlanAdd = new List<String>();
        List<String> listRatePlanRemove = new List<String>();



        for(Asset a : wr.listAsset) {
            
            newItemId = a.XC_Configuration_Item__c;
            newItem = newItem(newItemId, wr);
    
            oldItemId = a.XC_Original_Configuration_Item__c;
            oldItem = oldItem(oldItemId, wr);

            listRatePlanRemoveTmp = mapItemRemoveRP.get(newItemId);
            listRatePlanAddTmp = mapItemAddRP.get(newItemId);

            Map<String,Object> utilMap = new Map<String,Object>{
                                                                'listRatePlanAdd' => listRatePlanAdd,
                                                                'listRatePlanRemove' => listRatePlanRemove,
                                                                'listRatePlanAddTmp' => listRatePlanAddTmp,
                                                                'listRatePlanRemoveTmp' => listRatePlanRemoveTmp,
                                                                'wr' => wr,
                                                                'mapZquoteIdAddRP' => mapZquoteIdAddRP,
                                                                'mapZquoteIdRemoveRP' => mapZquoteIdRemoveRP
                                                                };
            
            if(checkItem(newItem, oldItem)){
                continue;
            }

            if(newItem.NE__Action__c == 'Add') {
                if(String.isBlank(wr.zQuoteId)) {
                    continue;
                }
                nestedIfAdd(utilMap);
            } else if(newItem.NE__Action__c == 'Remove') {
                if(oldItem.XC_ZQuoteId__c != null) {
                    nestedIf(utilMap);
                }
            }else if(newItem.NE__Action__c == 'Change'){
                if(String.isBlank(wr.zQuoteId)) {
                    continue;
                }
                nestedIfAdd(utilMap);
                nestedIf(utilMap);
            }
        }    

        rpWrapper.mapZquoteIdAddRP = mapZquoteIdAddRP;
        rpWrapper.mapZquoteIdRemoveRP = mapZquoteIdRemoveRP;

        return rpWrapper;
    }


    /**
     * @description newItem
     * @param newItemId
     * @param wr
     * @return new orderItem
     */ 
    private static NE__OrderItem__c newItem(String newItemId, XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr){
        NE__OrderItem__c newItem = new NE__OrderItem__c();
        if(newItemId != null) {
            newItem = wr.mapNewItems.get(newItemId);
        }
        return newItem;
    }


    /**
     * @description newItem
     * @param newItemId
     * @param wr
     * @return old orderItem
     */ 
    private static NE__OrderItem__c oldItem(String oldItemId, XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr){
        NE__OrderItem__c oldItem = new NE__OrderItem__c();
        if(oldItemId != null) {
            oldItem = wr.mapOldItems.get(oldItemId);
        }
        return oldItem;
    }


    /**
     * @description method for avoid nested if
     * @param listRatePlanRemove
     * @param listRatePlanRemoveTmp
     */
    private static void nestedIf(Map<String,Object> utilMap){

        List<String> listRatePlanRemove = (List<String>) utilMap.get('listRatePlanRemove');
        List<String> listRatePlanRemoveTmp = (List<String>) utilMap.get('listRatePlanRemoveTmp');
        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = (XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems) utilMap.get('wr');
        Map<String, List<String>> mapZquoteIdRemoveRP = (Map<String, List<String>>) utilMap.get('mapZquoteIdRemoveRP');                                     

        if(listRatePlanRemoveTmp != null) {
            listRatePlanRemove.addAll(listRatePlanRemoveTmp);
            mapZquoteIdRemoveRP.put(wr.zQuoteId, listRatePlanRemove);
        }
    }
    

    /**
     * @description method for avoid nested if
     * @param listRatePlanAdd
     * @param listRatePlanAddTmp
     * @return Map<String, List<String>>
     */
    public static void nestedIfAdd(Map<String,Object> utilMap){

        List<String> listRatePlanAdd = (List<String>) utilMap.get('listRatePlanAdd');
        List<String> listRatePlanAddTmp = (List<String>) utilMap.get('listRatePlanAddTmp');
        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = (XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems) utilMap.get('wr');
        Map<String, List<String>> mapZquoteIdAddRP = (Map<String, List<String>>) utilMap.get('mapZquoteIdAddRP');           
        
        if(listRatePlanAddTmp != null) {
            listRatePlanAdd.addAll(listRatePlanAddTmp);
            mapZquoteIdAddRP.put(wr.zQuoteId, listRatePlanAdd);
        }
    }


    /**
     * @description method for avoid nested if
     * @return Map<String, List<String>>
     * @param newItem
     * @param oldItem
     */
    private static Boolean checkItem(NE__OrderItem__c newItem, NE__OrderItem__c oldItem){
        Boolean check = false;
        if(newItem == null || oldItem == null){
            check = true;
        }
        return check;
    }


     /** 
     * @description generate Error For No Rate Plan.
     * @param zQuoteId the id of zQuote
     */
    @TestVisible
    public static void generateError(List<String> ratePlanConfItem, String errorMessage){
        Map<Id, NE__OrderItem__c> orderItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id,
                                                                                (SELECT Id, XC_Status__c FROM Provisioning_Steps__r WHERE XC_Flow_API_Name__c =: Label.XC_CL_ChangeProvisioningApplyCoupon_Flow OR XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningBillingProcess_Flow) // CUSTOM LABEL
                                                                                FROM NE__OrderItem__c WHERE Id IN :ratePlanConfItem]);
        
        Map<Id, XC_Provisioning_Step__c> mapStepToUpdate = new Map<Id, XC_Provisioning_Step__c>();
        for(NE__OrderItem__c oi : orderItemMap.values()) {
            XC_TR_ZQuote_U_ManageErrors.manageStepsForErrorZquote(oi.Provisioning_Steps__r, errorMessage , mapStepToUpdate); 
        }
        XC_UTIL_Sobject.updateListRecords(mapStepToUpdate.values());
    }

}
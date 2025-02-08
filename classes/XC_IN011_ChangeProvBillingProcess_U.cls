/**
* @description  – UTIL Class for XC_IN011_ChangeProvBillingProcess
*/ 
public without sharing class XC_IN011_ChangeProvBillingProcess_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN011_ChangeProvBillingProcess_U');

    /**
     * @description RatePlanWrapper
     */ 
    public class RatePlanWrapper{
        public Map<String, List<String>> mapZquoteIdAddRP = new Map<String, List<String>>();
        public Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();
    }
    /**
     * @description UtilWrapper
     */ 
    public class UtilWrapper {
        public Map<String, List<String>> mapItemAddRP = new Map<String, List<String>>();
        public Map<String, List<String>> mapItemRemoveRP = new Map<String, List<String>>();
    }

    /**
     * @description InputWrapper
     */ 
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;       
    }    

    /**
     * @description QuoteWrapper
     */ 
    public class QuoteWrapper{
        public Set<String> setZquoteIds = new Set<String>();
        public Map<String, List<String>> mapZquoteIdAddRP = new Map<String, List<String>>();
        public Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();
        public String orderId;
        public String stepId;
        public String confItemId;
        public NE__OrderItem__c item;
        public NE__OrderItem__c confItemMalfunction;
        public Map<String, List<String>> prpcConfItemsMap;
        public Boolean mixedVat; 
    }

    /**
     * @description cycleOnAsset
     * @param wr
     * @param mapItemAddRP
     * @param mapItemRemoveRP
     * @return RatePlanWrapper
     */ 
    public static RatePlanWrapper cycleOnAsset(XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr, Map<String, List<String>> mapItemAddRP, Map<String, List<String>> mapItemRemoveRP){
        Map<String, List<String>> mapZquoteIdAddRP = new Map<String, List<String>>();
        Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();
        RatePlanWrapper rpWrapper= new RatePlanWrapper();
        String newItemId;
        String oldItemId;
        NE__OrderItem__c oldItem;
        NE__OrderItem__c newItem;
        List<String> listRatePlanAddTmp;
        List<String> listRatePlanRemoveTmp;
        List<String> listRatePlanAdd;
        List<String> listRatePlanRemove;

        for(Asset a : wr.listAsset) {
            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### asset da wr.ListAsset ' + a);
            newItemId = a.XC_Configuration_Item__c;
            newItem = newItem(newItemId, wr);
    
            oldItemId = a.XC_Original_Configuration_Item__c;
            oldItem = oldItem(oldItemId, wr);

            listRatePlanRemoveTmp = mapItemRemoveRP.get(newItemId);
            listRatePlanAddTmp = mapItemAddRP.get(newItemId);
            
            if(checkItem(newItem, oldItem)){
                continue;
            }

            if(newItem.NE__Action__c == 'Add') {
                XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@--FUORI-zquoteNONULL@'+oldItem.XC_ZQuoteId__c);
                //if(oldItem.XC_ZQuoteId__c != null) {
                if(String.isBlank(wr.zQuoteId)) {
                    continue;
                }
                if(listRatePlanAdd == null) {
                    listRatePlanAdd = new List<String>();
                }
                if(listRatePlanAddTmp != null) {
                    listRatePlanAdd.addAll(listRatePlanAddTmp);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@--DENTRO-zquoteNONULL@'+oldItem.XC_ZQuoteId__c);
                    mapZquoteIdAddRP.put(wr.zQuoteId, listRatePlanAdd);
                    //mapZquoteIdAddRP.put(oldItem.XC_ZQuoteId__c, mapItemAddRP.get(newItemId));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@mapZquoteIdAddRP@'+mapZquoteIdAddRP);
                }
            } else if(newItem.NE__Action__c == 'Remove') {
                if(oldItem.XC_ZQuoteId__c != null) {
                    
                    if(listRatePlanRemove == null) {
                        listRatePlanRemove = new List<String>();
                    }
                    if(listRatePlanRemoveTmp != null) {
                        listRatePlanRemove.addAll(listRatePlanRemoveTmp);
                        mapZquoteIdRemoveRP.put(wr.zQuoteId, listRatePlanRemove);
                    }
                    //mapZquoteIdRemoveRP = nestedIf(listRatePlanRemove, listRatePlanRemoveTmp, wr);
                }
            }
        }    

        rpWrapper.mapZquoteIdAddRP = mapZquoteIdAddRP;
        rpWrapper.mapZquoteIdRemoveRP = mapZquoteIdRemoveRP;

        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@mapZquoteIdAddRP@'+mapZquoteIdAddRP);
        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@mapZquoteIdRemoveRP@'+mapZquoteIdRemoveRP);

        return rpWrapper;
    }

      /**
   * @description cycleOnAsset
   * @param wr
   * @param mapItemAddRP
   * @param mapItemRemoveRP
   * @return RatePlanWrapper
   */
    /*
    public static RatePlanWrapper cycleOnAssetB2B(XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr, Map<String, List<String>> mapItemAddRP, Map<String, List<String>> mapItemRemoveRP){
        Map<String, List<String>> mapZquoteIdAddRP = new Map<String, List<String>>();
        Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();
        RatePlanWrapper rpWrapper= new RatePlanWrapper();
        String newItemId;
        String oldItemId;
        NE__OrderItem__c oldItem;
        NE__OrderItem__c newItem;
        List<String> listRatePlanAddTmp;
        List<String> listRatePlanRemoveTmp;
        List<String> listRatePlanAdd;
        List<String> listRatePlanRemove;

        for(Asset a : wr.listAsset) {

            XC_UTIL_Debug.debug(DEBUGACTIVE, '### asset da wr.ListAsset ' + a);
            newItemId = a.XC_Configuration_Item__c;
            newItem = newItem(newItemId, wr);

            oldItemId = a.XC_Original_Configuration_Item__c;
            oldItem = oldItem(oldItemId, wr);

            listRatePlanRemoveTmp = mapItemRemoveRP.get(newItemId);
            listRatePlanAddTmp = mapItemAddRP.get(newItemId);

            if (checkItem(newItem, oldItem)) {
                continue;
            }

            if (newItem.NE__Action__c == 'Add') {
                XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST, '@--FUORI-zquoteNONULL@' + oldItem.XC_ZQuoteId__c);
                //if(oldItem.XC_ZQuoteId__c != null) {
                if (String.isBlank(wr.zQuoteId)) {
                    continue;
                }
                if (listRatePlanAdd == null) {
                    listRatePlanAdd = new List<String>();
                }
                if (listRatePlanAddTmp != null) {
                    listRatePlanAdd.addAll(listRatePlanAddTmp);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST, '@--DENTRO-zquoteNONULL@' + oldItem.XC_ZQuoteId__c);
                    mapZquoteIdAddRP.put(wr.zQuoteId, listRatePlanAdd);
                    //mapZquoteIdAddRP.put(oldItem.XC_ZQuoteId__c, mapItemAddRP.get(newItemId));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST, '@mapZquoteIdAddRP@' + mapZquoteIdAddRP);
                }
            } else if (newItem.NE__Action__c == 'Remove') {
                if (oldItem.XC_ZQuoteId__c != null) {

                    if (listRatePlanRemove == null) {
                        listRatePlanRemove = new List<String>();
                    }
                    if (listRatePlanRemoveTmp != null) {
                        listRatePlanRemove.addAll(listRatePlanRemoveTmp);
                        mapZquoteIdRemoveRP.put(wr.zQuoteId, listRatePlanRemove);
                    }
                    //mapZquoteIdRemoveRP = nestedIf(listRatePlanRemove, listRatePlanRemoveTmp, wr);
                }
            } else if (newItem.NE__Action__c == 'Change') {
                if (String.isBlank(wr.zQuoteId)) {
                    continue;
                }
                if (listRatePlanAdd == null) {
                    listRatePlanAdd = new List<String>();
                }
                if (listRatePlanAddTmp != null) {
                    listRatePlanAdd.addAll(listRatePlanAddTmp);
                    mapZquoteIdAddRP.put(wr.zQuoteId, listRatePlanAdd);
                    if (oldItem.XC_ZQuoteId__c != null) {
                        if (listRatePlanRemove == null) {
                            listRatePlanRemove = new List<String>();
                        }
                        if (listRatePlanRemoveTmp != null) {
                            listRatePlanRemove.addAll(listRatePlanRemoveTmp);
                            mapZquoteIdRemoveRP.put(wr.zQuoteId, listRatePlanRemove);
                        }
                    }
                }
            }
        }

        rpWrapper.mapZquoteIdAddRP = mapZquoteIdAddRP;
        rpWrapper.mapZquoteIdRemoveRP = mapZquoteIdRemoveRP;

        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@mapZquoteIdAddRP@'+mapZquoteIdAddRP);
        XC_UTIL_Debug.debug(DEBUGACTIVE, LoggingLevel.FINEST,'@mapZquoteIdRemoveRP@'+mapZquoteIdRemoveRP);

        return rpWrapper;
    }
*/



    /**
     * @description addRemoveProductsAmendmentQuote
     * @param quoteWr
     * @return the zquoteid
     */ 
    public static String addRemoveProductsAmendmentQuote(QuoteWrapper quoteWr){
        
        Set<String> setZquoteIds = quoteWr.setZquoteIds;
        Map<String, List<String>> mapZquoteIdAddRP = quoteWr.mapZquoteIdAddRP;
        Map<String, List<String>> mapZquoteIdRemoveRP = quoteWr.mapZquoteIdRemoveRP;
        String orderId = quoteWr.orderId;
        String newZquoteId;
        for(String z : setZquoteIds) {  
            
            XC_TR_Configuration_U_ChangeOrder.UtilWrapper wrapper = new XC_TR_Configuration_U_ChangeOrder.UtilWrapper();
            
            wrapper.orderId = orderId;
            wrapper.originalZQuoteId = z;
            wrapper.stepId = quoteWr.stepId;
            wrapper.confItem = quoteWr.item;
            wrapper.mixedVat = quoteWr.mixedVat;
            wrapper.confItemId = quoteWr.confItemId;
            wrapper.prpcConfItemsMap = quoteWr.prpcConfItemsMap;
            wrapper.confItemMalfunction = quoteWr.confItemMalfunction;
            

            if(mapZquoteIdAddRP.containsKey(z) && mapZquoteIdRemoveRP.containsKey(z)) {

                wrapper.ratePlanAddList = mapZquoteIdAddRP.get(z);
                wrapper.ratePlanRemoveList = mapZquoteIdRemoveRP.get(z);

            } else if(mapZquoteIdAddRP.containsKey(z) && !mapZquoteIdRemoveRP.containsKey(z)){

                wrapper.ratePlanAddList = mapZquoteIdAddRP.get(z);
                wrapper.ratePlanRemoveList = null;

            } else if(!mapZquoteIdAddRP.containsKey(z) && mapZquoteIdRemoveRP.containsKey(z)){

                wrapper.ratePlanAddList =null;
                wrapper.ratePlanRemoveList = mapZquoteIdRemoveRP.get(z);
            } 

            newZquoteId = XC_TR_Configuration_U_ChangeOrder.createAddRemoveProductsAmendmentQuote(wrapper);
        }

        return newZquoteId;
    }

    /**
     * @description newItem
     * @param newItemId
     * @param wr
     * @return RatePlanWrapper
     */ 
    public static NE__OrderItem__c newItem(String newItemId, XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr){
        NE__OrderItem__c newItem = new NE__OrderItem__c();
        if(newItemId != null) {
            newItem = wr.mapNewItems.get(newItemId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### newItem da wr.ListAsset ' + newItem + ' zquote ' + newItem.XC_ZQuoteId__c);
        }
        return newItem;
    }

    public static NE__OrderItem__c oldItem(String oldItemId, XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr){
        NE__OrderItem__c oldItem = new NE__OrderItem__c();
        if(oldItemId != null) {
            oldItem = wr.mapOldItems.get(oldItemId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### oldItem da wr.ListAsset ' + oldItem + ' zquote ' + oldItem.XC_ZQuoteId__c);
        }
        return oldItem;
    }

    /**
     * @description method for avoid nested if
     * @param listRatePlanRemove
     * @param listRatePlanRemoveTmp
     * @param wr
     * @return Map<String, List<String>>
     */
    /*private static Map<String, List<String>> nestedIf(List<String> listRatePlanRemove, List<String> listRatePlanRemoveTmp, 
                                                        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr){
        Map<String, List<String>> mapZquoteIdRemoveRP = new Map<String, List<String>>();
        if(listRatePlanRemove == null) {
            listRatePlanRemove = new List<String>();
        }
        if(listRatePlanRemoveTmp != null) {
            listRatePlanRemove.addAll(listRatePlanRemoveTmp);
            mapZquoteIdRemoveRP.put(wr.zQuoteId, listRatePlanRemove);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### mapZquoteIdRemoveRP ### ' + mapZquoteIdRemoveRP);
        return mapZquoteIdRemoveRP;
    }*/

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

}
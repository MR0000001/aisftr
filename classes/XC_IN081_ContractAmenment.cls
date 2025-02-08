/**
 * @author Danilo Lombardi - dolombardi@deloitte.it
 * @date Creation 13/10/2021
 * @date Modification 28/10/2021 by Nicola Mariniello nmariniello@deloitte.it
 * @description XC_IN081_ContractAmenment – Invocable class for XC_FL_ContractAmendmentB2B
 */


public without sharing class XC_IN081_ContractAmenment {


    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN081_ContractAmenment');


    /**
     * @description InputWrapper
     */
    public class InputWrapper {
        @Invocablevariable
        public String contractAmendmentId;
    }

    
    /**
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of Apply Coupon
     */
    @InvocableMethod
    public static void applyAmendment(List<InputWrapper> inputWrapperList) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN081_ContractAmenment');

        if(inputWrapperList.isEmpty()) {
            return;
        }

        List<Id> listContractAmendment = new List<String>();
        for(InputWrapper inputWr : inputWrapperList){
            listContractAmendment.add(inputWr.contractAmendmentId);
        }

        Map<Id, Asset> mapCA = XC_IN081_ContractAmenment_D.getMapContrAmend(listContractAmendment);
        String confItemId = '';
        String orderId = '';
        Asset asset = new Asset();
        for(Asset inputWr : mapCA.values()) {
            asset = mapCA.get(inputWr.id);
            orderId = mapCA.get(inputWr.id).XC_Configuration_Item__r.NE__OrderId__c;
            confItemId = mapCA.get(inputWr.id).XC_Configuration_Item__r.Id;
        }

        /************** Get item **************/
        List<NE__OrderItem__c> configItemList = XC_IN038_ApplyCoupon_D.getItemsByOrderId(orderId);
        List<Id> confItemsIds = XC_UTIL_Sobject.getIds(configItemList);

        /************* Retrieve rate plans *******************************/
        Map<String, List<String>> prpcConfItemsMap = new Map<String, List<String>>();
        List<B2WExtCat__Work_Order_Item__c> b2wList = XC_IN038_ApplyCoupon_D.getJunctionRatePlanToItem(confItemsIds, prpcConfItemsMap);
        if(b2wList.isEmpty()) {
            setStatusOnContractAmendment(listContractAmendment[0], Label.XC_CL_ErrorMessage_NoRatePlanFound, Label.XC_CL_ErrorMessage_NoRatePlanFound);
            return;
        }

        /***************************************************************/
        XC_IN038_ApplyCoupon_U.UtilWrapper wrapper = applyCouponUtil(b2wList);
        Map<String, List<String>> mapItemAddRP = wrapper.mapItemAddRP;
        Map<String, List<String>> mapItemRemoveRP = wrapper.mapItemRemoveRP;
        /***************************************************************/

        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = XC_IN011_ChangeProvBillingProcess_D.getItemsByOldIds(confItemsIds);

        // [NM] CONTROLLARE QUESTO PEZZO PER MIGRAZIONE
        if(String.isBlank(wr.zQuoteId)) {   // FOR Migration
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN038 zquote is Blank');

            String subNumber = '';
            for(Asset a : wr.listAsset) {
                if(String.isNotBlank(a.XC_SubscriptionName__c)) {
                    subNumber = a.XC_SubscriptionName__c;
                    break;
                }
            }
            if(String.isNotBlank(subNumber)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN038 subName is Not Blank');
                // call new method for amendment
                Map<String, Object> inputMap = new Map<String, Object>{'wr' => wr,
                'mapItemAddRP' => mapItemAddRP,
                'mapItemRemoveRP' => mapItemRemoveRP,
                'subNumber' => subNumber,
                'orderId' => orderId,
                'confItemId' => confItemId,
                //'stepId' => step.Id,
                'prpcConfItemsMap' => prpcConfItemsMap};
                XC_UTIL_ChangeOrderMigration.migrationPayAndBill(inputMap);
            }
            return;
        }

        Map<String,Object> mapUtilAsset = new  Map<String,Object>{  'mapItemAddRP' => mapItemAddRP,
                                                                    'mapItemRemoveRP' => mapItemRemoveRP,
                                                                    'wr' => wr};
        XC_IN038_ApplyCoupon_U.RatePlanWrapper rpWrapper = XC_IN038_ApplyCoupon_U.cycleOnAsset(mapUtilAsset);
        Map<String, List<String>> mapZquoteIdAddRP = rpWrapper.mapZquoteIdAddRP;
        Map<String, List<String>> mapZquoteIdRemoveRP = rpWrapper.mapZquoteIdRemoveRP;

        Set<String> setZquoteIds = new Set<String>();
        setZquoteIds.addAll(mapZquoteIdAddRP.keySet());
        setZquoteIds.addAll(mapZquoteIdRemoveRP.keySet());

        if(setZquoteIds.isEmpty()) {
            setStatusOnContractAmendment(listContractAmendment[0], Label.XC_CL_NoRatePlanAddRemove, Label.XC_CL_NoRatePlanAddRemove);
            return;
        }

        XC_IN011_ChangeProvBillingProcess_U.QuoteWrapper quoteWr = new XC_IN011_ChangeProvBillingProcess_U.QuoteWrapper();
        quoteWr.setZquoteIds = setZquoteIds;
        quoteWr.mapZquoteIdAddRP = mapZquoteIdAddRP;
        quoteWr.mapZquoteIdRemoveRP = mapZquoteIdRemoveRP;
        quoteWr.orderId = orderId;
        quoteWr.confItemId = confItemId;
        // quoteWr.stepId = step.Id;
        quoteWr.prpcConfItemsMap = prpcConfItemsMap;
        quoteWr.mixedVat = wr.mixedVat;
        String newZquoteID = XC_IN011_ChangeProvBillingProcess_U.addRemoveProductsAmendmentQuote(quoteWr);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### setZquoteIds ### ' + setZquoteIds);

        Map<Id, NE__OrderItem__c> confItemToUpdateList = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c oi : wr.mapNewItems.values()) {
            oi.XC_ZQuoteId__c = newZquoteID;
            confItemToUpdateList.put(oi.Id, oi);
        }
        XC_UTIL_Sobject.updateListRecords(confItemToUpdateList.values());

        // Update the XC_Original_Configuration_Item__c field (LABEL Previous Order Item) with the actual Order Item that have the new zquote
        Map<Id, Asset> assetToUpdateList = new Map<Id, Asset>();
        for(Asset a : wr.listAsset) {
            if(confItemToUpdateList.keySet().contains(a.XC_Configuration_Item__c)) {
                Asset aTemp = a;
                aTemp.XC_Original_Configuration_Item__c = a.XC_Configuration_Item__c;
                assetToUpdateList.put(aTemp.Id, aTemp);
            }
        }

        XC_UTIL_Sobject.updateListRecords(assetToUpdateList.values());
    }


    /**
     * Populate items list.
     * @description method applyCouponUtil to populate rateplan list
     * @param B2WExtCat__Work_Order_Item__c
     */
    private static XC_IN038_ApplyCoupon_U.UtilWrapper applyCouponUtil(List<B2WExtCat__Work_Order_Item__c> b2wList) {

        XC_IN038_ApplyCoupon_U.UtilWrapper wrapper = new XC_IN038_ApplyCoupon_U.UtilWrapper();
        Map<String, List<String>> mapItemAddRP = new Map<String, List<String>>();
        Map<String, List<String>> mapItemRemoveRP = new Map<String, List<String>>();
        List<String> listRP = new List<String>();

        for(B2WExtCat__Work_Order_Item__c woItem : b2wList) {
            if(woItem.B2WExtCat__Action__c == 'Provide') {
                if(mapItemAddRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemAddRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemAddRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);

            } else if(woItem.B2WExtCat__Action__c == 'Consume') {
                if(mapItemRemoveRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemRemoveRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemRemoveRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);
            }
        }

        wrapper.mapItemAddRP = mapItemAddRP;
        wrapper.mapItemRemoveRP = mapItemRemoveRP;

        return wrapper;
    }


    /**
     * Set Status On Contract Amendment.
     * @description method setStatusOnContractAmendment to set sthe status on the contract amendment
     * @param contractAmendmentId
     * @param errorMessage
     * @param errorMessageDetails
     */
    public static void setStatusOnContractAmendment(String contractAmendmentId, String errorMessage, String errorMessageDetails) {

        Map<Id, XC_ContractAmendment__c> mapContractAmend = new Map<Id, XC_ContractAmendment__c>([SELECT Id, Contract_Amendment_Parent__c, XC_Status__c, XC_Error__c, XC_ErrorDetail__c
                                                                                                    FROM XC_ContractAmendment__c
                                                                                                    WHERE (Id = :contractAmendmentId OR Contract_Amendment_Parent__c = :contractAmendmentId) AND XC_Status__c = 'In Progress']);
        
        for(XC_ContractAmendment__c ca : mapContractAmend.values()) {
            ca.XC_Status__c = (String.isBlank(errorMessage)) ? 'Completed' : 'Error';
            ca.XC_Error__c = errorMessage;
            ca.XC_ErrorDetail__c = errorMessageDetails;
        }

        XC_UTIL_SObject.updateListRecords(mapContractAmend.values());
    }

}
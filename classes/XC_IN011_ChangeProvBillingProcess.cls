/**
* @author : Riccardo Cossu - riccardo.cossu@nttdata.com - Sara Miozza - sara.miozza@nttdata.com
* @date Creation 28/02/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. - Change Provisioning Billing Process 
*/ 
public without sharing class XC_IN011_ChangeProvBillingProcess {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN011_ChangeProvBillingProcess');

    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description InputWrapper
     */
    public class InputWrapper{ 
        @Invocablevariable 
        public String stepId;  
        @Invocablevariable 
        public Boolean isAddRemove = false;    
    }


    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @param inputWrapperList the list coming from flow
     * @description class to the the logic of Change Provisioning Billing Process
     */
    @InvocableMethod 
    public static void payAndBill(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN011_ChangeProvBillingProcess');
        
        if(!inputWrapperList.isEmpty()){
            List<Id> listStepIds = new List<String>();
            List<XC_Provisioning_Step__c> provisioningStepsToComplete = new List<XC_Provisioning_Step__c>();
            String orderId = ''; 
            XC_Provisioning_Step__c step;
            for(InputWrapper inputWr : inputWrapperList){
                listStepIds.add(inputWr.stepId);
            }
            Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);
            String confItemId;
			String segment;

            Boolean checkAddRemove = false;
            for(InputWrapper inputWr : inputWrapperList) {
                checkAddRemove = inputWr.isAddRemove;
                step = mapSteps.get(inputWr.stepId);
                orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
                confItemId = step.XC_Configuration_Item__c;
				segment = mapSteps.get(inputWr.stepId).XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
            } 


             List<NE__OrderItem__c> configItemList = new List<NE__OrderItem__c>();
            Boolean resultGenerateWorkorders = XC_UTIL_Configuration.generateWorkorders(orderId, step.Id, 'XC_IN011_ChangeProvBillingProcess');
            if(!resultGenerateWorkorders && !Test.isRunningTest()) {
                return;
            }

           if(segment != 'B2C'){
               configItemList = XC_IN011_ChangeProvBillingProcess_D.getItemsByOrderIdB2B(orderId);
           }else{
                configItemList =  XC_IN011_ChangeProvBillingProcess_D.getItemsByOrderId(orderId);
          }
          //  List<NE__OrderItem__c> configItemList =  XC_IN011_ChangeProvBillingProcess_D.getItemsByOrderId(orderId);             
            List<Id> listIds = XC_UTIL_Sobject.getIds(configItemList);

            /************* Retrieve rate plans *******************************/
            Map<String, List<String>> prpcConfItemsMap = new Map<String, List<String>>();
            List<B2WExtCat__Work_Order_Item__c> b2wList = XC_IN011_ChangeProvBillingProcess_D.getJunctionRatePlanToItem(listIds, prpcConfItemsMap);
            if(b2wList.isEmpty()){
                XC_IN018_CreateZquote.generateErrorForNoRatePlan(listIds);
                return;
            }

            /*****************************************************************/

            XC_IN011_ChangeProvBillingProcess_U.UtilWrapper wrapper = payAndBillUtil(b2wList);
            Map<String, List<String>> mapItemAddRP = wrapper.mapItemAddRP;
            Map<String, List<String>> mapItemRemoveRP = wrapper.mapItemRemoveRP;

            if(!listIds.contains(confItemId)) {
                listIds.add(confItemId);
            }
            XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = XC_IN011_ChangeProvBillingProcess_D.getItemsByOldIds(listIds);
            
            if(String.isBlank(wr.zQuoteId)) {   // FOR Migration
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN011 zquote is Blank');

                String subNumber = '';
                for(Asset a : wr.listAsset) {
                    if(String.isNotBlank(a.XC_SubscriptionName__c)) {
                        subNumber = a.XC_SubscriptionName__c;
                        break;
                    }
                }
                if(String.isNotBlank(subNumber)) {
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN011 subName is Not Blank');
                    // call new method for amendment
                    Map<String, Object> inputMap = new Map<String, Object>{'wr' => wr,
                                                                            'mapItemAddRP' => mapItemAddRP,
                                                                            'mapItemRemoveRP' => mapItemRemoveRP,
                                                                            'subNumber' => subNumber,
                                                                            'orderId' => orderId,
                                                                            'confItemId' => confItemId,
                                                                            'stepId' => step.Id,
                                                                            'prpcConfItemsMap' => prpcConfItemsMap};
                    XC_UTIL_ChangeOrderMigration.migrationPayAndBill(inputMap);

                } else {
                    step.XC_ErrorMessage__c = 'Subscription not found - No remove items with info for change (zquote/subNumber)';
                    step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                    XC_UTIL_Sobject.updateRecord(step);
                }
                return;
            }


            List<String> listZquoteIds = new List<String>();

            XC_IN011_ChangeProvBillingProcess_U.RatePlanWrapper rpWrapper = XC_IN011_ChangeProvBillingProcess_U.cycleOnAsset(wr, mapItemAddRP, mapItemRemoveRP);
            Map<String, List<String>> mapZquoteIdAddRP = rpWrapper.mapZquoteIdAddRP;
            Map<String, List<String>> mapZquoteIdRemoveRP = rpWrapper.mapZquoteIdRemoveRP;

            Set<String> setZquoteIds = new Set<String>();
            setZquoteIds.addAll(mapZquoteIdAddRP.keySet());
            setZquoteIds.addAll(mapZquoteIdRemoveRP.keySet());
            
            XC_IN011_ChangeProvBillingProcess_U.QuoteWrapper quoteWr = new XC_IN011_ChangeProvBillingProcess_U.QuoteWrapper();
            quoteWr.setZquoteIds = setZquoteIds;
            quoteWr.mapZquoteIdAddRP = mapZquoteIdAddRP;
            quoteWr.mapZquoteIdRemoveRP = mapZquoteIdRemoveRP;
            quoteWr.orderId = orderId;
            quoteWr.confItemId = confItemId;
            quoteWr.stepId = step.Id;
            quoteWr.prpcConfItemsMap = prpcConfItemsMap;
            String newZquoteID = XC_IN011_ChangeProvBillingProcess_U.addRemoveProductsAmendmentQuote(quoteWr);    
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### setZquoteIds ### ' + setZquoteIds);

            /************* Update Order Items *******************************/
            NE__OrderItem__c confItemToUpdate = new NE__OrderItem__c();
            if(checkAddRemove) {
                confItemToUpdate.Id = confItemId;
            }
            else {
                confItemToUpdate = wr.mapNewItems.get(confItemId);
            }
            confItemToUpdate.XC_ZQuoteId__c = newZquoteID;

            Map<Id, NE__OrderItem__c> confItemToUpdateList = new Map<Id, NE__OrderItem__c>();
            for(NE__OrderItem__c oi : wr.mapNewItems.values()) {
                oi.XC_ZQuoteId__c = newZquoteID;
                confItemToUpdateList.put(oi.Id, oi);
            }
            confItemToUpdateList.put(confItemToUpdate.Id, confItemToUpdate);
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

            //UPDATE STEP AND ORDERITEM
            //updateProvisioningStepsAndConfigurationItem(provisioningStepsToComplete, confItemToUpdate);
        }
    }
    

    /**
     * @description payAndBillUtil
     * @param b2wList the b2w workorder list
     * @return the XC_IN011_ChangeProvBillingProcess_U.UtilWrapper
     */ 
    public static XC_IN011_ChangeProvBillingProcess_U.UtilWrapper payAndBillUtil(List<B2WExtCat__Work_Order_Item__c> b2wList){
        XC_IN011_ChangeProvBillingProcess_U.UtilWrapper wrapper = new XC_IN011_ChangeProvBillingProcess_U.UtilWrapper();
        Map<String, List<String>> mapItemAddRP = new Map<String, List<String>>();
        Map<String, List<String>> mapItemRemoveRP = new Map<String, List<String>>();
        List<String> listRP = new List<String>();
        List<String> ratePlanAdd = new List<String>();
        List<String> ratePlanRemove = new List<String>();

        
        for(B2WExtCat__Work_Order_Item__c woItem : b2wList) {
            if(woItem.B2WExtCat__Configuration_Item__r.NE__Action__c == 'Add') {
                ratePlanAdd.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                if(mapItemAddRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemAddRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemAddRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);

            } else if(woItem.B2WExtCat__Configuration_Item__r.NE__Action__c == 'Remove') {
                ratePlanRemove.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                if(mapItemRemoveRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemRemoveRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
            listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
            mapItemRemoveRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);
            } 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### mapItemAddRP ### ' + mapItemAddRP);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### mapItemRemoveRP ### ' + mapItemRemoveRP);
        wrapper.mapItemAddRP = mapItemAddRP;
        wrapper.mapItemRemoveRP = mapItemRemoveRP;

        return wrapper;
    }

    
       /**
   * @description payAndBillUtil
   * @param b2wList the b2w workorder list
   * @return the XC_IN011_ChangeProvBillingProcess_U.UtilWrapper
   */
  /*
    public static XC_IN011_ChangeProvBillingProcess_U.UtilWrapper payAndBillUtilB2B(List<B2WExtCat__Work_Order_Item__c> b2wList){
        XC_IN011_ChangeProvBillingProcess_U.UtilWrapper wrapper = new XC_IN011_ChangeProvBillingProcess_U.UtilWrapper();
        Map<String, List<String>> mapItemAddRP = new Map<String, List<String>>();
        Map<String, List<String>> mapItemRemoveRP = new Map<String, List<String>>();
        List<String> listRP = new List<String>();
        List<String> ratePlanAdd = new List<String>();
        List<String> ratePlanRemove = new List<String>();


        for(B2WExtCat__Work_Order_Item__c woItem : b2wList) {
            if(woItem.B2WExtCat__Configuration_Item__r.NE__Action__c == 'Add') {
                ratePlanAdd.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                if(mapItemAddRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemAddRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemAddRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);

            } else if(woItem.B2WExtCat__Configuration_Item__r.NE__Action__c == 'Remove') {
                ratePlanRemove.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                if(mapItemRemoveRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemRemoveRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemRemoveRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);
            }else if (woItem.B2WExtCat__Configuration_Item__r.NE__Action__c == 'Change'){
                ratePlanAdd.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                if(mapItemAddRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemAddRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemAddRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);
                ratePlanRemove.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                if(mapItemRemoveRP.containsKey(woItem.B2WExtCat__Configuration_Item__c)) {
                    listRP = mapItemRemoveRP.get(woItem.B2WExtCat__Configuration_Item__c);
                } else {
                    listRP = new List<String>();
                }
                listRP.add(woItem.B2WExtCat__Work_Order_Item_Code__c);
                mapItemRemoveRP.put(woItem.B2WExtCat__Configuration_Item__c, listRP);

            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### mapItemAddRP ### ' + mapItemAddRP);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### mapItemRemoveRP ### ' + mapItemRemoveRP);
        wrapper.mapItemAddRP = mapItemAddRP;
        wrapper.mapItemRemoveRP = mapItemRemoveRP;

        return wrapper;
    }

*/


    /**
     * Populate items list.
     * @description method populateItemsList to populate configItemRemoveList and  configItemAddList
     * @param configItemRemoveList the config item remove list
     * @param configItemAddList the config item add list
     * @param configItemList the config item list
     */
    /*private static void populateItemsList(List<NE__OrderItem__c> configItemRemoveList, List<NE__OrderItem__c> configItemAddList, List<NE__OrderItem__c> configItemList) {
        for(NE__OrderItem__c item : configItemList) {
            if(item.NE__Action__c == 'Remove') {
                configItemRemoveList.add(item);
            } else if(item.NE__Action__c == 'Add') {
                configItemAddList.add(item);
            }
        }
    }*/

    /**
     * Update provisioning steps and configuration item.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param provisioningStepsToUpdate the provisioning steps to update
     * @param orderItemsToUpdate the order items to update
     * @description Method to update the configuration item and the provisioning step.
     */ 
    /*private static void updateProvisioningStepsAndConfigurationItem(List<XC_Provisioning_Step__c> provisioningStepsToUpdate, NE__OrderItem__c orderItemsToUpdate){
        // XC_UTIL_Sobject.updateListRecords(provisioningStepsToUpdate); 
        //if(listDMLResultOnStep[0].success){
            XC_UTIL_Sobject.WrapperResult dmlResultOnItems = XC_UTIL_Sobject.updateRecord(orderItemsToUpdate);
        //}
    }*/
}
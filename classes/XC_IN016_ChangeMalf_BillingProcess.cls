/**
* @author Federico Amici - federico.amici@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 19/03/2019  
* @date Modification : 2/01/2020 by  Luisana Rocco lrocco@deloitte.it - Nicola Mariniello nmariniello@deloitte.it
* @description XC_IN016_ChangeMalf_BillingProcess – 
*/
public without sharing class XC_IN016_ChangeMalf_BillingProcess {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN016_ChangeMalf_BillingProcess');

   
    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Checks if and how much is worth the penalty
     * @param inputWrapperList the input wrapper list
    */
    @InvocableMethod
    public static void billingPenalty(List<XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper> inputWrapperList) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering XC_IN016_ChangeMalf_BillingProcess.billingPenalty');
        
        if(inputWrapperList.isEmpty()){
            return;
        }

        List<String> listStepIds = XC_IN016_ChangeMalf_BillingProcess_U.addStepsIds(inputWrapperList);
        Map<Id, XC_Provisioning_Step__c> mapSteps = XC_IN011_ChangeProvBillingProcess_D.getMapSteps(listStepIds);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapSteps-->' +mapSteps);

        String orderId = ''; 
        String confItemId = '';
        String legalEntity = '';
        List<XC_Provisioning_Step__c> provisioningStepsToComplete = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c step;
        
        for(XC_IN016_ChangeMalf_BillingProcess_U.InputWrapper inputWr : inputWrapperList) {
            step = mapSteps.get(inputWr.stepId);
            //NE__OrderItem__c confItem = configurationMap.get(step.XC_Configuration_Item__c);
            orderId = step.XC_Configuration_Item__r.NE__OrderId__c; 
            confItemId = step.XC_Configuration_Item__c;
            legalEntity = step.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;

            //COMPLETE STEP - Salvatore Scarpato 14/3/2019
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
            provisioningStepsToComplete.add(step); 
        }
        
        Boolean resultGenerateWorkorders = XC_UTIL_Configuration.generateWorkorders(orderId, step.Id, 'XC_IN016_ChangeMalf_BillingProcess');
        if(!resultGenerateWorkorders && !Test.isRunningTest()) {
            return;
        }
        
        Map<Id, NE__OrderItem__c> configItemMap = XC_IN016_ChangeMalf_BillingProcess_D.getItemsByOrderId(orderID, confItemId);    /* Get both Product and Penalty confitem */

        Map<String, List<String>> prpcConfItemsMap = new Map<String, List<String>>();
        List<Id> listIds =  new List<Id>();
        listIds.addAll(configItemMap.keyset());
        List<B2WExtCat__Work_Order_Item__c> b2wList = XC_IN011_ChangeProvBillingProcess_D.getJunctionRatePlanToItem(listIds, prpcConfItemsMap);
        if(b2wList.isEmpty()){
            XC_IN018_CreateZquote.generateErrorForNoRatePlan(listIds);
            return;
        }

        XC_IN011_ChangeProvBillingProcess_U.UtilWrapper wrapper = XC_IN011_ChangeProvBillingProcess.payAndBillUtil(b2wList);
        Map<String, List<String>> mapItemAddRP = wrapper.mapItemAddRP;
        Map<String, List<String>> mapItemRemoveRP = wrapper.mapItemRemoveRP;

        XC_IN015_UpdateRenting_D.WrapperAssetItems wr = XC_IN016_ChangeMalf_BillingProcess_D.getItemsByIds(listIds, orderId);

        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wrAsset = new XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems();
        wrAsset.listAsset = wr.listAsset;
        wrAsset.mapNewItems = wr.mapNewItems;
        wrAsset.mapOldItems = wr.mapOldItems;
        wrAsset.zQuoteId = wr.zQuoteId;
        wrAsset.mixedvat = wr.mixedvat;


        Map<String,Object> confItemMalfMap = new Map<String,Object>{ 'wrAsset' => wrAsset,
                                                                     'confItemId' => confItemId
                                                                    };

        if(String.isBlank(wr.zQuoteId)) {   // FOR Migration
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN016 zquote is Blank');

            String subNumber = '';
            for(Asset a : wr.listAsset) {
                if(String.isNotBlank(a.XC_SubscriptionName__c)) {
                    subNumber = a.XC_SubscriptionName__c;
                    break;
                }
            }
            if(String.isNotBlank(subNumber)) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ in IN016 subName is Not Blank');
                // call new method for amendment
                Map<String, Object> inputMap = new Map<String, Object>{'wr' => wrAsset,
                                                                        'mapItemAddRP' => mapItemAddRP,
                                                                        'mapItemRemoveRP' => mapItemRemoveRP,
                                                                        'subNumber' => subNumber,
                                                                        'orderId' => orderId,
                                                                        'confItemId' => confItemId,
                                                                        'stepId' => step.Id,
                                                                        'prpcConfItemsMap' => prpcConfItemsMap};

                Boolean sameProductMigration = XC_IN016_ChangeMalf_BillingProcess_U.checkIfSameProduct(confItemMalfMap);

                if(!sameProductMigration){
                    inputMap.put('confItemMalfunction', confItemMalfMap.get('confItemMalfunction'));
                    XC_UTIL_ChangeOrderMigration.migrationPayAndBill(inputMap);
                }
                
            }
            return;
        }

        Boolean sameProduct = XC_IN016_ChangeMalf_BillingProcess_U.checkIfSameProduct(confItemMalfMap);

        if(!sameProduct){
             
            XC_IN011_ChangeProvBillingProcess_U.RatePlanWrapper rpWrapper = XC_IN011_ChangeProvBillingProcess_U.cycleOnAsset(wrAsset,mapItemAddRP,mapItemRemoveRP);
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
            quoteWr.mixedvat = wrAsset.mixedvat;
            quoteWr.item = configItemMap.get(confItemId);
            quoteWr.confItemMalfunction = (NE__OrderItem__c)confItemMalfMap.get('confItemMalfunction');

            String newZquoteID = XC_IN011_ChangeProvBillingProcess_U.addRemoveProductsAmendmentQuote(quoteWr);     

            XC_UTIL_Debug.debug(DEBUGACTIVE, '### setZquoteIds ### ' + setZquoteIds);
            NE__OrderItem__c confItemToUpdate = wr.mapNewItems.get(confItemId);
            confItemToUpdate.XC_ZQuoteId__c = newZquoteID;

            //UPDATE ORDERITEM
            XC_UTIL_Sobject.updateRecord(confItemToUpdate);

            // Update the XC_Original_Configuration_Item__c field (LABEL Previous Order Item) with the actual Order Item that have the new zquote
            Asset assetToUpdate;
            for(Asset a : wrAsset.listAsset) {
                if(a.XC_Configuration_Item__c == confItemToUpdate.Id) {
                    assetToUpdate = a;
                    assetToUpdate.XC_Original_Configuration_Item__c = a.XC_Configuration_Item__c;
                }
            }
            XC_UTIL_Sobject.updateRecord(assetToUpdate);

        }else{

            for(XC_Provisioning_Step__c stepToUpdate : provisioningStepsToComplete){
                if(stepToUpdate.XC_Configuration_Item__c == confItemId){
                    stepToUpdate.XC_Status__c = Label.XC_CL_Step_Skipped;
                }
            }

            XC_UTIL_Sobject.updateListRecords(provisioningStepsToComplete);
        }

    }

}
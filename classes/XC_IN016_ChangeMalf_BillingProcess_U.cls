/**
 * @author              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation       08/01/2020
 * @date Modification   dd/mm/yyyy
 * @description         XC_IN016_ChangeMalf_BillingProcess_D – util class for XC_IN016_ChangeMalf_BillingProcess
 */



public without sharing class XC_IN016_ChangeMalf_BillingProcess_U{

    /**
    * @description Util Wrapper
    */
    public class UtilWrapper {
        public NE.DataMap.DataMapResponse dResp;
        public Id newZQuoteId;
        public List<zqu__Quote__c> subscriptionZuoraList = new List<zqu__Quote__c>();
        public String currentSubscription;
        public String subscriptionZuoraId;
        public String legalEntity;
        public List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        public NE__OrderItem__c confItem; 
        public String stepId;

    }


    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date Creation 19/03/2019  
    * @description Wrapper used by the flow
    */
    public class InputWrapper{ 
        @Invocablevariable 
        public String stepId;       
    }    


    /**
     * @description Checks if it was substituted the same product
     * @param wr the confItemMalfMap
     * @return the boolean
    */
    public static Boolean checkIfSameProduct(Map<String,Object> confItemMalfMap) {

        Boolean res = false;
        XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems wr = (XC_IN011_ChangeProvBillingProcess_D.WrapperAssetItems) confItemMalfMap.get('wrAsset');
        String confItemId = (String) confItemMalfMap.get('confItemId');

        System.debug('###wrMap### ' + wr.mapNewItems);
        NE__OrderItem__c itemTmp = wr.mapNewItems.get(confItemId);
        String prodName = itemTmp.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c;
        

        for(NE__OrderItem__c item : wr.mapNewItems.values()) {

            if(item.NE__Action__c == 'Remove'){
                if(item.NE__OrderId__r.NE__Type__c == 'ChangeOrder' &&  item.NE__OrderId__r.XC_Subtype__c == Label.XC_CL_ChangeOrder_SubstitutionMalfunction){
                    confItemMalfMap.put('confItemMalfunction', item);
                }
                if((item.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c == prodName)){
                    res = true;
                    break;
                }

            }
        }

        return res;
    }

   
      
    /* @description addStepsIds
     * @param inputWrapperList the List<InputWrapper>
     * @return the list of step ids
    */
    public static List<String> addStepsIds(List<InputWrapper> inputWrapperList) {
        List<String> listStepIds = new List<String>();
        for(InputWrapper inputWr : inputWrapperList){
            listStepIds.add(inputWr.stepId);
        }
        return listStepIds;
    }


}
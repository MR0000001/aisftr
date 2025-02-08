/**
 * @author: Francesco Imperioli - fimperioli@deloitte.it
 * @description: manage unique bank transfer code calculation for Italy Adoption Bank Transfer
 * paid order items
 * 
 */

public without sharing class XC_IN048_ManageInvoiceAfterPayment {

    public class InputWrapper {
        @InvocableVariable
        public String stepId;
    }

        /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description: main invocable method, bulkified, check payment method and then eventually skip steps
     * paid order items
     * 
     */
    @InvocableMethod
    public static void manageInvoiceAfterPayment(List<InputWrapper> inputs){

        if(!inputs.isEmpty()){

            List<String> stepIds = new List<String>();
            for(InputWrapper iw : inputs){
                stepIds.add(iw.stepId);
            }
            Map<Id, XC_Provisioning_Step__c> mapSteps = getMapSteps(stepIds);
            List<XC_Provisioning_Step__c> stepsToSkip = new List<XC_Provisioning_Step__c>();
            List<XC_Provisioning_Step__c> stepsToProcess = new List<XC_Provisioning_Step__c>();

            for(XC_Provisioning_Step__c step : mapSteps.values()){
                if(step.XC_Configuration_Item__r.XC_PaymentMethod__c == 'Bank Transfer'){
                    stepsToProcess.add(step);
                }else{
                    step.XC_Status__c = Label.XC_CL_Step_Skipped;
                    stepsToSkip.add(step);
                }
            }

            if(!stepsToSkip.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(stepsToSkip);
            }

            if(!stepsToProcess.isEmpty()){
                manageUniqueBankTransferCode(stepsToProcess);
            }

        }

    }

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description: return a rich map of provisioning step and orderItem fields
     * paid order items
     * 
     */
    public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return new Map<Id, XC_Provisioning_Step__c>();
        }
		Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID,XC_Status__c, XC_Configuration_Item__c,XC_Configuration_Item__r.Name,
                XC_Configuration_Item__r.XC_PaymentMethod__c,XC_Configuration_Item__r.NE__OrderId__c, 
                XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c,
                XC_Configuration_item__r.NE__Bundle_Configuration__r.Name
                 FROM XC_Provisioning_Step__c 
                 WHERE Id IN: listStepIds]);
		return mapSteps;
    }
    

    /**
     * @author: Francesco Imperioli - fimperioli@deloitte.it
     * @description: manage unique bank transfer code calculation for Italy Adoption Bank Transfer
     * paid order items
     * 
     */
    private static void manageUniqueBankTransferCode(List<XC_Provisioning_Step__c> stepsToProcess){
        
        List<String> confItemIds = new List<String>();
        List<String> bundleConfItemIds = new List<String>();
        Map<String,XC_Provisioning_Step__c> confItemStepMap = new Map<String,XC_Provisioning_Step__c>();

        for(XC_Provisioning_Step__c step : stepsToProcess){
            confItemIds.add(step.XC_Configuration_Item__c);
            confItemStepMap.put(step.XC_Configuration_Item__c,step);
            
            if(String.isNotBlank(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c)){
                bundleConfItemIds.add(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c);
            }
        }


        // Map<Id,Asset> confItemAssetMapBundle = getConfItemAssetMap(bundleConfItemIds);
        // Map<Id,Asset> confItemAssetMap = getConfItemAssetMap(confItemIds);
        List<NE__OrderItem__c> oiToUpdate = new List<NE__OrderItem__c>();


        for(XC_Provisioning_Step__c step : stepsToProcess){
            String code; 
            String itemNameStep1;
            String itemNameStep2;
            if(String.isNotBlank(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c)){
                itemNameStep1 = step.XC_Configuration_Item__r.NE__Bundle_Configuration__r.Name.right(6);
                itemNameStep2 = itemNameStep1.right(3);
                code = 'CZ'+ itemNameStep1.left(3) + manageAlphabetCode(itemNameStep2);
                NE__OrderItem__c bundleOi = new NE__OrderItem__c(Id = step.XC_Configuration_Item__r.NE__Bundle_Configuration__c,XC_BankTransferCode__c=code);
                oiToUpdate.add(bundleOi);
            }else{
                itemNameStep1 = step.XC_Configuration_Item__r.Name.right(6);
                itemNameStep2 = itemNameStep1.right(3);
                code = 'CZ'+ itemNameStep1.left(3) + manageAlphabetCode(itemNameStep2);
            }
            NE__OrderItem__c currentOi = new NE__OrderItem__c(Id = step.XC_Configuration_Item__c,XC_BankTransferCode__c=code);
            oiToUpdate.add(currentOi);
        }


        if(!oiToUpdate.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> updateResultsOi = XC_UTIL_Sobject.updateListRecords(oiToUpdate);
            List<XC_Provisioning_Step__c> stepsToCompleteOK = new List<XC_Provisioning_Step__c>();
            List<XC_Provisioning_Step__c> stepsToCompleteKO = new List<XC_Provisioning_Step__c>();

            for(XC_UTIL_Sobject.WrapperResult result : updateResultsOi){
                if(result.success && confItemStepMap.containsKey(result.recordId)){
                    XC_Provisioning_Step__c okStep = confItemStepMap.get(result.recordId);
                    okStep.XC_Status__c = 'Completed OK';
                    stepsToCompleteOK.add(okStep);
                }else if(!result.success && confItemStepMap.containsKey(result.recordId)){
                    XC_Provisioning_Step__c koStep = confItemStepMap.get(result.recordId);
                    koStep.XC_Status__c = 'Completed KO';
                    koStep.XC_ErrorMessage__c = result.errorMessage;
                    stepsToCompleteOK.add(koStep);
                }
            }

            if(!stepsToCompleteOK.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(stepsToCompleteOK);
            }

            if(!stepsToCompleteKO.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(stepsToCompleteKO);
            }
        }
   }

//     /**
//      * @author: Francesco Imperioli - fimperioli@deloitte.it
//      * @description: returns a rich map of configuration items and asset with contract fields.
//      * paid order items
//      * 
//      */
//    private static Map<Id,Asset> getConfItemAssetMap(List<String> confItemIds){

//         Map<Id,Asset> result = new Map<Id,Asset>();
//         if(!confItemIds.isEmpty()){
//             List<Asset> assetList = [SELECT ID,XC_Contract__r.ContractNumber,XC_Configuration_Item__c FROM Asset WHERE XC_Configuration_Item__c IN :confItemIds];
//             for(Asset a : assetList){
//                 result.put(a.XC_Configuration_Item__c,a);
//             }
//         }
//         return result;
//    }

   /**
   * @description manage alphabet code for italy
   * @author Francesco Imperioli - fimperioli@deloitte.it | 20/4/2020 
   * @param lastTwoDigits 
   * @return String 
   **/
   private static String manageAlphabetCode(String lastTwoDigits){
        String result = '';
        Map<String,String> alphabetMap = new Map<String,String>{
            '0'=>'A',
            '1'=>'B',
            '2'=>'C',
            '3'=>'D',
            '4'=>'E',
            '5'=>'F',
            '6'=>'G',
            '7'=>'H',
            '8'=>'I',
            '9'=>'L',
            '10'=>'M',
            '11'=>'N',
            '12'=>'O',
            '13'=>'P',
            '14'=>'Q',
            '15'=>'R',
            '16'=>'S',
            '17'=>'T',
            '18'=>'U',
            '19'=>'V',
            '20'=>'Z'
        };

        for(Integer i =0; i<lastTwoDigits.length();i++){
            result= result + alphabetMap.get(lastTwoDigits.substring(i,i+1));
        }
        return result;
   }


   

    // public static Map<String,Boolean> checkItemStepHasIncentive(Map<Id,XC_Provisioning_Step__c> stepsMap){

    //     Map<String,Boolean> mapResult = new Map<String,String>();
    //     List<String> orderIds = getOrderIds(stepsMap);
    //     List<String> bundleItemsIds = getBundleItemsIds(stepsMap);
    //     //TODO: add incentive where clauses
    //     List<NE__OrderItem__c> incentiveItems = [SELECT ID,NE__Bundle_Configuration__c FROM NE__OrderItem__c WHERE NE__Bundle_Configuration__c IN :bundleItemsIds AND NE__OrderId__c IN :orderIds];
        
    //     Map<String,NE__OrderItem__c> incentiveConfMap = new Map<String,NE__OrderItem__c>();
    //     for(NE__OrderItem__c oi : incentiveItems){
    //         incentiveConfMap.put(oi.NE__Bundle_Configuration__c,oi);
    //     }

    //     for(XC_Provisioning_Step__c step : stepsMap.values()){
    //         if(incentiveConfMap.containsKey(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c) 
    //         && step.XC_Configuration_Item__r.XC_PaymentMethod__c == 'Bank Transfer'){
    //             mapResult.put(step.Id,true);
    //         }else{
    //             mapResult.put(step.Id,false);
    //         }
    //     }
    //     return mapResult;
    // }

    // private static List<String> getOrderIds(Map<Id, XC_Provisioning_Step__c> stepsMap){
    //     List<String> result = new List<String>();
    //     for(XC_Provisioning_Step__c step : stepsMap.values()){
    //         result.add(step.XC_Configuration_Item__r.NE__OrderId__c);
    //     } 
    //     return result;
    // }

    // private static List<String> getBundleItemsIds (Map<Id, XC_Provisioning_Step__c> stepsMap){
    //     List<String> result = new List<String>();
    //     for(XC_Provisioning_Step__c step : stepsMap.values()){
    //         result.add(step.XC_Configuration_Item__r.NE__Bundle_Configuration__c);
    //     }
    //     return result;
    // }

}
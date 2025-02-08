/** 
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date Creation 15/06/2021
  * @description XC_LCC254_SelectDeliveryPreference - Apex Controller for component LCP254
*/

public without sharing class XC_LCC254_SelectDeliveryPreference {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC254_SelectDeliveryPreference');  

    /** @description Output Wrapper */
    public class ResultWrapper {
        @AuraEnabled public Boolean success = false;
        @AuraEnabled public String message = '';
        @AuraEnabled public List<String> listPreferences = new List<String>();
    }

    /** 
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/06/2021
     * @description Method to load preferences options
     * @param orderId - String
     * @return ResultWrapper
     */
    @AuraEnabled
    public static ResultWrapper loadPreferences(String orderId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Load Options Invoice Delivery Preference for order ' + orderId);
        ResultWrapper resWrapper = new ResultWrapper();
        try {
            Schema.DescribeFieldResult fieldResult = NE__Order__c.XC_InvoiceDeliveryPreference__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                resWrapper.listPreferences.add(f.getValue());
            }     
            List<NE__Order__c> listOrder = new List<NE__Order__c>([
                SELECT Id, XC_InvoiceDeliveryPreference__c
                FROM NE__Order__c
                WHERE Id = :orderId
            ]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Options: ' + resWrapper.listPreferences);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Current Preferred Delivery Invoice: ' + listOrder);

            if(String.isNotBlank(listOrder[0].XC_InvoiceDeliveryPreference__c)) {
                for(Integer i=0; i<resWrapper.listPreferences.size(); i++) {
                    if(resWrapper.listPreferences[i] == listOrder[0].XC_InvoiceDeliveryPreference__c && i!=0) {
                        String temp = resWrapper.listPreferences[i];
                        resWrapper.listPreferences[i] = resWrapper.listPreferences[0];
                        resWrapper.listPreferences[0] = temp;
                        break;
                    }
                }
            }
            resWrapper.success = true;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Wrapper: ' + resWrapper);
            return resWrapper;
        } catch (Exception e) {
            resWrapper.success = false;
            resWrapper.message = e.getMessage();
            return resWrapper;
        }
    }

    /** 
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 15/06/2021
     * @description Method to save preferences option
     * @param orderId - String
     * @param preferenceSelected - String
     * @return ResultWrapper
     */
    @AuraEnabled
    public static ResultWrapper savePreference(String orderId, String preferenceSelected) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Save option ' + preferenceSelected + ' for order ' + orderId);
        ResultWrapper resWrapper = new ResultWrapper();
        try {
            NE__Order__c orderToUpdate = new NE__Order__c(
                Id = orderId,
                XC_InvoiceDeliveryPreference__c = preferenceSelected
            );
            XC_UTIL_Sobject.WrapperResult wrDML = XC_UTIL_Sobject.updateRecord(orderToUpdate);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result DML order: ' + wrDML);
            if(!wrDML.success) {
                resWrapper.success = false;
                resWrapper.message = wrDML.errorMessage;
            } else {
                resWrapper.success = true;
                resWrapper.message = Label.XC_CL_Configuration_OrderUpdated;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Result Wrapper: ' + resWrapper);
            return resWrapper;
        } catch (Exception e) {
            resWrapper.success = false;
            resWrapper.message = e.getMessage();
            return resWrapper;
        }
    }

}
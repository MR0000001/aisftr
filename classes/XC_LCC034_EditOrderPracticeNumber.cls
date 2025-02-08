/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 06/11/2018
* @date Modification 23/11/2018
* @description XC_LCC034_EditOrderPracticeNumber - Update the Order with Practice Number and process a new Email CustomerInteraction 
*/
public without sharing class XC_LCC034_EditOrderPracticeNumber {

    /**
     * @description Update order practice number.
     *
     * @param orderId the order id
     * @param practiceNumber the practice number
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateOrderPracticeNumber(String orderId, String practiceNumber){
        XC_UTIL_SObject_CheckVisibility.updateLockedRecordFieldById(orderId, 'XC_PracticeNumber__c', practiceNumber);
        System.debug('@@@@ update Order PracticeNumber >> DONE');

        Map<String, Object> interactionMap = initCustomerInteractionMap(orderId);
        XC_UTIL_ResultWrapper rWr = XC_LCC039_CustomerInteraction.newEmailForCustomer(JSON.serialize(interactionMap));
        System.debug('@@@@ new Email Customer >> DONE');
        if(rWr.success){
            rWr.resultMessage  = Label.XC_CL_Order_PracticeNumberUpdated;
        }

        System.debug('@@@@ ResultWrapper='+rWr);
        return rWr;
    }

    /**
     * @description Check financial approval value.
     *
     * @param orderId the order id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkFinancialApprovalValue(String orderId){
        XC_UTIL_ResultWrapper rWr = new XC_UTIL_ResultWrapper();

        if(!Schema.SObjectType.NE__Order__c.isAccessible()) {
            return new XC_UTIL_ResultWrapper();
        }
        
        Map<Id,NE__Order__c> ordersMap = new Map<Id,NE__Order__c> ([SELECT Id, XC_FinancialApproval__c
         FROM NE__Order__c WHERE Id =: orderId]);
        List<NE__Order__c> orders = ordersMap.values();

        for(NE__Order__c order : orders){
            System.debug('@@@@ order XC_FinancialApproval__c='+order.XC_FinancialApproval__c);
            if(order.XC_FinancialApproval__c == Label.XC_CL_Configuration_ToDo || order.XC_FinancialApproval__c == Label.XC_CL_Configuration_Pending){
                rWr.isValid = true;
            } else {
                rWr.isValid = false;
                rWr.resultMessage = Label.XC_CL_Order_PracticeNumberNotModifiable;
            }
        }
        return rWr;
    }

    /**
     * @description Inits the customer interaction map.
     *
     * @param orderId the order id
     * @return the map
     */
    private static Map<String, Object> initCustomerInteractionMap(String orderId){
        Map<String, Object> interactionMap = new Map<String, Object>();
        interactionMap.put('orderId',orderId);
        interactionMap.put('customerType','Order_Update_On_Practice_Number_Email');
        interactionMap.put('skipComunication',false);
        interactionMap.put('isAccountRequired',true);

        return interactionMap;
    }

}
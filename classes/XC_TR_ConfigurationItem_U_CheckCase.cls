/**
 * The Class XC_TR_ConfigurationItem_U_CheckCase.
 *
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 04/12/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ConfigurationItem_U_CheckCase – Class to check if there are opened case on the order related to the configuration item
 *                                                     in input.
 */
public class XC_TR_ConfigurationItem_U_CheckCase {

    /** 
     * Check if closeable.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @description Method that take the list of Order Item for which the status changed.
     */
    public static void checkIfCloseable (List<NE__OrderItem__c> listNew, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){    
        List<String> fieldList = new List<String>{'NE__Status__c'};  
        List<NE__OrderItem__c> completedOrderItem = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> orderItemChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        for(NE__OrderItem__c orItem : orderItemChanged){
            if(orItem.NE__Status__c == Label.XC_CL_Configuration_Item_Completed){
                completedOrderItem.add(orItem);
            } 
        }
        if(!completedOrderItem.isEmpty()){
            checkStatusCaseOnOrder(completedOrderItem);
        }
    }

    /**
     * Check status case on order.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listConfItemChanged the list conf item changed
     * @description Method that allow the update of the configuration item to complete only if there are not cases of type
     *                      Administrative Tasks still opened on the order father.
     */
    public static void checkStatusCaseOnOrder(List<NE__OrderItem__c> listConfItemChanged){
        List<NE__OrderItem__c> orderItemsToUpdate = XC_TR_ConfigurationItem_U_CloseConfItem.getOrderItemToClose(listConfItemChanged);
        System.debug('listConfItemChanged -----lista1---->' + listConfItemChanged);
        System.debug('orderItemsToUpdate -----lista2---->' + orderItemsToUpdate);
        for(NE__OrderItem__c orderItem : listConfItemChanged){
            if(!orderItemsToUpdate.contains(orderItem)){
                orderItem.addError(Label.XC_CL_ConfiguratioItem_CannotClose);
            }
        }
    }
}
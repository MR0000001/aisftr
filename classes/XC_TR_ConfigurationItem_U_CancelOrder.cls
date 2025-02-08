/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com / Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 30/10/2018
* @date Modification dd/mm/yyyy 
* @description XC_TR_ConfigurationItem_U_CancelOrder - Util class for XC_TR_ConfigurationItem
*/

public with sharing class XC_TR_ConfigurationItem_U_CancelOrder {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_CancelOrder');

    /** @description PopulateOrderWrapper */
    private class PopulateOrderWrapper {
        List<NE__OrderItem__c> listChildren = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> listChildrenBis = new List<NE__OrderItem__c>();
        NE__Order__c ord;
        Map<Id, NE__OrderItem__c> mapNew = new Map<Id, NE__OrderItem__c>();
    }

    /**
     * @param confItemUpdate the conf item update
     * @param mapOld the map old  
     * @param mapNew the map new
     * @description check the status of ConfigurationItem
     */
    public static void checkConfigurationItemStatus(list<NE__OrderItem__c> confItemUpdate,  Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__Status__c'};
        confItemUpdate = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);     
        if(confItemUpdate.isEmpty()){
            return;
        }
        List<NE__OrderItem__c> listchanged = new List<NE__OrderItem__c>();
        //D.D.D - 27.11 Order in Close if all the CI are completed
        List<NE__OrderItem__c> listConfItemCompleted = new List<NE__OrderItem__c>();

        for(NE__OrderItem__c confi : confItemUpdate){
            if(checkStatusCancelled(confi, mapOld, mapNew)){
                listchanged.add(confi);
            //D.D.D-27.11 Order in Close if all the CI are completed(START)
            } else if(checkStatusCompleted(confi, mapOld, mapNew)){
                listConfItemCompleted.add(confi);   
            }//D.D.D-27.11(STOP)
        }

        //D.D.D-27.11 Order in Close if all the CI are completed
        if(listConfItemCompleted.isEmpty() && Schema.sObjectType.NE__Order__c.isAccessible()){
            Set<Id> idOrderSet = populateOrderId(listchanged); 
            Map<Id, NE__Order__c> mapOrder = new Map<Id, NE__Order__c>([SELECT Id, XC_Status__c,XC_Type_of_cancellation__c,XC_Cancellation_Date__c,XC_Mode_of_cancellation__c,(SELECT Id,NE__Status__c FROM NE__Order_Items__r)
                                                                    FROM NE__Order__c 
                                                                    WHERE Id IN :idOrderSet]); 
            List<NE__Order__c> listOrder = mapOrder.values();
            if(!listOrder.isEmpty()){                                                       
                for(NE__Order__c ord : listOrder){
                    List<NE__OrderItem__c> listChildrenBis = new List<NE__OrderItem__c>();
                    List<NE__OrderItem__c>  listChildren = ord.NE__Order_Items__r;
                    
                    // For cyclomatic complexity:
                    PopulateOrderWrapper populateWrapper = new PopulateOrderWrapper();
                    populateWrapper.listChildren = listChildren;
                    populateWrapper.listChildrenBis = listChildrenBis;
                    populateWrapper.ord = ord;
                    populateWrapper.mapNew = mapNew;
                    populateOrder(populateWrapper);   
                    listChildren = populateWrapper.listChildren;
                    listChildrenBis = populateWrapper.listChildrenBis;
                    ord = populateWrapper.ord;
                }
            }
            XC_UTIL_SObject.updateListRecords(listOrder); 
        }
    }

    /**
     * @description Check for status Completed (FOR CYCLOMATIC COMPLEXITY)
     * @param confi - NE__OrderItem__c
     * @param mapOld - Map<Id,NE__OrderItem__c>
     * @param mapNew - Map<Id,NE__OrderItem__c>
     * @return Boolean
     */
    private static Boolean checkStatusCompleted(NE__OrderItem__c confi, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew) {
        if(mapold.get(confi.Id).NE__Status__c != Label.XC_CL_Configuration_OrderCancelled && mapNew.get(confi.Id).NE__Status__c== Label.XC_CL_Configuration_Item_Completed) {
            return true;
        }
        return false;
    }

    /**
     * @description Check for status Cancelled (FOR CYCLOMATIC COMPLEXITY)
     * @param confi - NE__OrderItem__c
     * @param mapOld - Map<Id,NE__OrderItem__c>
     * @param mapNew - Map<Id,NE__OrderItem__c>
     * @return Boolean
     */
    private static Boolean checkStatusCancelled(NE__OrderItem__c confi, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew) {
        if((mapold.get(confi.Id).NE__Status__c != Label.XC_CL_Configuration_OrderCancelled && mapNew.get(confi.Id).NE__Status__c==Label.XC_CL_Configuration_OrderCancelled)
        || (mapold.get(confi.Id).NE__Status__c != Label.XC_CL_Configuration_Item_Disconnected && mapNew.get(confi.Id).NE__Status__c==Label.XC_CL_Configuration_Item_Disconnected) ) {
            return true;
        }
        return false;
    }

    /**
     * @description Populate order id
     * @param populateWrapper - PopulateOrderWrapper
     */
    private static void populateOrder(PopulateOrderWrapper populateWrapper) {
        NE__OrderItem__c itemTmp;
        for(NE__OrderItem__c orditem : populateWrapper.listChildren){
            if(orditem.NE__Status__c == Label.XC_CL_Configuration_OrderCancelled){ // FIX SS 3001 - Anomalia BSN 136 before was: orditem.NE__Status__c == Label.XC_CL_Configuration_OrderCancelled || orditem.NE__Status__c == Label.XC_CL_Configuration_Item_Disconnected
                populateWrapper.listChildrenBis.add(orditem);
                if(String.isBlank(populateWrapper.ord.XC_Type_of_cancellation__c)){
                    populateWrapper.ord.XC_Type_of_cancellation__c = Label.XC_CL_Configuration_CancellationType_Partial;
                }
                populateWrapper.ord.XC_Mode_of_cancellation__c = Label.XC_CL_Configuration_CancellationMode_Automatic;
            }
            
            //Check the size of children list for view all record cancelled
            if(populateWrapper.listChildrenBis.size() == populateWrapper.listChildren.size()){
                if((populateWrapper.ord.XC_Status__c != Label.XC_CL_Configuration_OrderToBeValidated) &&
                    (populateWrapper.ord.XC_Status__c != Label.XC_CL_Configuration_OrderInProgress) &&
                    (populateWrapper.ord.XC_Status__c != Label.XC_CL_Configuration_OrderInProvisioning) &&
                    (populateWrapper.ord.XC_Status__c != Label.XC_CL_Configuration_Closed)){
                    //orditem.addError(Label.XC_CL_ConfItem_CancelError);
                    itemTmp = populateWrapper.mapNew.get(orditem.Id);
                    itemTmp.addError(Label.XC_CL_ConfItem_CancelError);
                }
                populateWrapper.ord.XC_Type_of_cancellation__c      = Label.XC_CL_Configuration_CancellationType_Total;
                populateWrapper.ord.XC_Reason_of_cancellation__c    = Label.XC_CL_Configuration_CancelledOrderItem;
                populateWrapper.ord.XC_Cancellation_Date__c         = Date.today();
                if(populateWrapper.ord.XC_Status__c != Label.XC_CL_Configuration_Closed){  
                populateWrapper.ord.XC_Status__c = Label.XC_CL_Configuration_OrderCancelled;
                }
            }
        }
    }

    /**
     * @description Populate order id
     * @param confItemUpdate the conf item update
     * @return idOrderSet the sets the
     */
    public static Set<Id> populateOrderId(List<NE__OrderItem__c> confItemUpdate){
        Set<Id> idOrderSet = new Set<Id>();
        for(NE__OrderItem__c ci : confItemUpdate){
            if(ci.NE__OrderId__c != null) {
                idOrderSet.add(ci.NE__OrderId__c);
            }
        }
        return idOrderSet;
    } 
}
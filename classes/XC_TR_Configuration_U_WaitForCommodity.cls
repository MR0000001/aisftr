/**
* @author Salvatore Scarpato
* @date Creation 16/07/2019
* @date Modification
* @description XC_TR_Configuration_U_WaitForCommodity – Class to check the value of two fields related to commodity in order to complete the related 
                                                        step "Wait for commodity"
*/

public without sharing class XC_TR_Configuration_U_WaitForCommodity {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_WaitForCommodity');
    
    private class CommodityWrapper{
        Map<String,XC_Provisioning_Step__c> provisioningMapWait1;
        Map<String,XC_Provisioning_Step__c> provisioningMapWait2;
    } 
    /**
     * @description  check if the field Wait For Commodity changed
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new 
     */
    public static void checkWaitForCommodity(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {
        
        List<String> fieldList = new List<String>{'XC_WaitForCommodity__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            closeProvisioningStep(listChanged);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @#@#@ WAIT FOR COMMODITY  --->');
        }
    } 
  
    private static void waitForCommodity1(NE__Order__c order, Map<String,XC_Provisioning_Step__c> provisioningMapWait1, List<XC_Provisioning_Step__c> stepsToUpdateList){
        if(order.XC_WaitForCommodity__c == 'Ok' && order.XC_WaitforCommodityStep__c == '1'){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @#@#@ WAIT FOR COMMODITY  ---> CASO OK - 1');
            XC_Provisioning_Step__c stepToUpdate = provisioningMapWait1.get(order.Id);
            stepToUpdate.XC_Status__c = Label.XC_CL_Completed_Ok;
            stepsToUpdateList.add(stepToUpdate);
            
        } else if(order.XC_WaitForCommodity__c == 'Ko' && order.XC_WaitforCommodityStep__c == '1'){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @#@#@ WAIT FOR COMMODITY  ---> CASO KO - 1');
            XC_Provisioning_Step__c stepToUpdate = provisioningMapWait1.get(order.Id);
            stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            stepsToUpdateList.add(stepToUpdate);
        }
    }

    private static void waitForCommodity2(NE__Order__c order, Map<String,XC_Provisioning_Step__c> provisioningMapWait2, List<XC_Provisioning_Step__c> stepsToUpdateList){
        if(!provisioningMapWait2.isEmpty()){
            if(order.XC_WaitForCommodity__c == 'Ok' && order.XC_WaitforCommodityStep__c == '2'){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @#@#@ WAIT FOR COMMODITY  ---> CASO OK - 2');
                XC_Provisioning_Step__c stepToUpdate = provisioningMapWait2.get(order.Id);
                stepToUpdate.XC_Status__c = Label.XC_CL_Completed_Ok;
                stepsToUpdateList.add(stepToUpdate);
            } else if(order.XC_WaitForCommodity__c == 'Ko' && order.XC_WaitforCommodityStep__c == '2'){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @#@#@ WAIT FOR COMMODITY  ---> CASO KO - 2');
                XC_Provisioning_Step__c stepToUpdate = provisioningMapWait2.get(order.Id);
                stepToUpdate.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                stepsToUpdateList.add(stepToUpdate);
            }
        }
    }

    private static void closeProvisioningStep(List<NE__Order__c> orderList) {
        List<XC_Provisioning_Step__c> stepsToUpdateList = new List<XC_Provisioning_Step__c>();
        List<String> orderIds = XC_UTIL_Sobject.getIds(orderList);
        CommodityWrapper cWrapper = getProvisioningStep(orderIds);
        Map<String,XC_Provisioning_Step__c> provisioningMapWait1 = cWrapper.provisioningMapWait1;
        Map<String,XC_Provisioning_Step__c> provisioningMapWait2 = cWrapper.provisioningMapWait2;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @#@#@ WAIT FOR COMMODITY  ---> COMMODITY WRAPPER -> '+ cWrapper);
        if(!provisioningMapWait1.isEmpty() || !provisioningMapWait2.isEmpty()){
            for(NE__Order__c order : orderList){
                waitForCommodity1(order, provisioningMapWait1, stepsToUpdateList);
                waitForCommodity2(order, provisioningMapWait2, stepsToUpdateList);
            }
            XC_UTIL_Sobject.updateListRecords(stepsToUpdateList);
        }
    }

    private static CommodityWrapper getProvisioningStep(List<String> orderIds){
        CommodityWrapper comWrapper = new CommodityWrapper();
        Map<String,XC_Provisioning_Step__c> provisioningMapWait1 = new Map<String,XC_Provisioning_Step__c>();
        Map<String,XC_Provisioning_Step__c> provisioningMapWait2 = new Map<String,XC_Provisioning_Step__c>();
        List<XC_Provisioning_Step__c> getSteps = new List<XC_Provisioning_Step__c>([SELECT Id, XC_Flow_API_Name__c,XC_Status__c, XC_Configuration_Item__r.NE__OrderId__c
                                                                                    FROM XC_Provisioning_Step__c 
                                                                                    WHERE XC_Configuration_Item__r.NE__OrderId__c IN : orderIds
                                                                                    AND (XC_Flow_API_Name__c =: Label.XC_CL_Provisioning_WaitForCommodity1
                                                                                    OR XC_Flow_API_Name__c =: Label.XC_CL_Provisioning_WaitForCommodity2)
                                                                                    AND XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress]);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '<--- @#@#@ WAIT FOR COMMODITY  ---> LIST STEPS TO BE MODIFIED : ' + getSteps);
        for(XC_Provisioning_Step__c step : getSteps){
            if(step.XC_Flow_API_Name__c == Label.XC_CL_Provisioning_WaitForCommodity1){
                provisioningMapWait1.put(step.XC_Configuration_Item__r.NE__OrderId__c, step);
            } else if(step.XC_Flow_API_Name__c == Label.XC_CL_Provisioning_WaitForCommodity2){
                provisioningMapWait2.put(step.XC_Configuration_Item__r.NE__OrderId__c, step);
            }
        }
        comWrapper.provisioningMapWait1 = provisioningMapWait1;
        comWrapper.provisioningMapWait2 = provisioningMapWait2;
        return comWrapper;
    }
	

}
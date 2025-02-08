/**
* @author :             Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation :      11/01/2019
* @date Modification :  16/01/2019
* @description :        XC_TR_ConfItem_U_CheckComplianceStatus – Util to check Compliance Status
*/

public without sharing class XC_TR_ConfItem_U_CheckComplianceStatus {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfItem_U_CheckComplianceStatus');

    /**
     * @description Check compliance 1 status
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkCompliance1Status(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_Compliance1_Status__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkComp1StatusOfOrderItems(listChanged);
        }
    }

    /**
     * @description Check compliance 2 status
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkCompliance2Status(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_Compliance2_Status__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkComp23StatusOfOrderItems(Label.XC_CL_Compliance_C2, listChanged);
        }
    }

    /**
     * @description Check compliance 4 status
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkCompliance4Status(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_Compliance4_Status__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkComp23StatusOfOrderItems(Label.XC_CL_Compliance_C4, listChanged);
        }
    }

    /**
     * @description Check compliance 3 status
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkCompliance3Status(List<NE__OrderItem__c> listNew, Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_Compliance3_Status__c'};
        List<NE__OrderItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            checkComp23StatusOfOrderItems(Label.XC_CL_Compliance_C3, listChanged);
        }
    }


    /**
     * @param orderItemList the order item list
     * @description : Method to verify if all Order Items related to a specific Order have the Compliance 1 Status in OK.
     *                In this case, the Compliance 1 Status of the Order is changed in OK.
     */
    private static void checkComp1StatusOfOrderItems(List<NE__OrderItem__c> orderItemList) {
        List<String> configurationIdList = XC_UTIL_Sobject.getListFieldValues(orderItemList, 'NE__OrderId__c');
        if(!Schema.sObjectType.NE__Order__c.isAccessible()){
            return;
        }
        Map<Id, NE__Order__c> mapConfiguration = new Map<Id, NE__Order__c>([SELECT Id, XC_Compliance_Approval__c, 
                                                                                (SELECT Id, XC_Compliance1_Status__c, XC_IsAProduct__c 
                                                                                FROM NE__Order_Items__r WHERE XC_IsAProduct__c = true) 
                                                                            FROM NE__Order__c 
                                                                            WHERE Id IN: configurationIdList]);
        List<NE__Order__c> configurationList = mapConfiguration.values();
        List<NE__Order__c> configurationListToUpdate = new List<NE__Order__c>();

        for(NE__Order__c conf : configurationList) {
            Boolean checkStatusOK = true;
            Boolean checkStatusKOFinal = false;

            for(NE__OrderItem__c orderItem : conf.NE__Order_Items__r) {
                if(orderItem.XC_Compliance1_Status__c != Label.XC_CL_OK && orderItem.XC_Compliance1_Status__c != Label.XC_CL_Configuration_NotNeeded) {
                    checkStatusOK = false;
                }
                if (orderItem.XC_Compliance1_Status__c == Label.XC_CL_KO){
                    checkStatusKOFinal = true;
                }
            }

            if(checkStatusOK) {
                conf.XC_Compliance_Approval__c = Label.XC_CL_OK;
                configurationListToUpdate.add(conf);
            } else if (checkStatusKOFinal){
                conf.XC_Compliance_Approval__c = Label.XC_CL_KO;
                configurationListToUpdate.add(conf);
            }
        }
        XC_UTIL_Sobject.updateListRecords(configurationListToUpdate);
    }

    /**
     * @param complianceType the compliance type
     * @param listNew the list new
     * @description : Method to verify if the Compliance 2 Status or the Compliance 3 Status of an Order Item is in OK.
     *                In this case, the Compliance 2 (or 3) Provisioning Step Status is changed in Completed OK.
     */
    public static void checkComp23StatusOfOrderItems(String complianceType, List<NE__OrderItem__c> listNew) {
        List<Id> orderItemIdsList = XC_UTIL_Sobject.getIds(listNew);
        String flowAPIname;
        if(complianceType == Label.XC_CL_Compliance_C2) {
            flowAPIname = Label.XC_CL_Provisioning_C2Flow;
        } else if(complianceType == Label.XC_CL_Compliance_C3) {
            flowAPIname = Label.XC_CL_Provisioning_C3Flow;
        } else if(complianceType == Label.XC_CL_Compliance_C4) {
            flowAPIname = Label.XC_CL_Provisioning_C4Flow;
        }

        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return;
        }
        Map<Id, NE__OrderItem__c> mapOrderItem = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_Compliance2_Status__c, XC_Compliance3_Status__c, XC_Compliance4_Status__c,
                                                                                    (SELECT Id, XC_Flow_API_Name__c, XC_Status__c 
                                                                                    FROM Provisioning_Steps__r 
                                                                                    WHERE XC_Flow_API_Name__c =: flowAPIname) 
                                                                                FROM NE__OrderItem__c 
                                                                                WHERE Id IN: orderItemIdsList]);
        List<NE__OrderItem__c> orderItemList = mapOrderItem.values();

        List<XC_Provisioning_Step__c> provisioningStepListToUpdate = new List<XC_Provisioning_Step__c>();
        populateProvisiongStep(complianceType, orderItemList, provisioningStepListToUpdate);
        XC_UTIL_Sobject.updateListRecords(provisioningStepListToUpdate);
    }

    /**
     * @param complianceType - the compliance type
     * @param orderItemList - List<NE__OrderItem__c>
     * @param provisioningStepListToUpdate - List<XC_Provisioning_Step__c>
     * @description : Method to populate List Provisiong Step
     */
    private static void populateProvisiongStep(String complianceType, List<NE__OrderItem__c> orderItemList, List<XC_Provisioning_Step__c> provisioningStepListToUpdate) {
        for(NE__OrderItem__c orderItem : orderItemList) {
            if(checkCondition(orderItem, complianceType)) {
                provisioningStepListToUpdate.add(getProvisioningStepToUpdate(orderItem,Label.XC_CL_Completed_Ok));
            } else if(checkConditionKo(orderItem, complianceType)){
                provisioningStepListToUpdate.add(getProvisioningStepToUpdate(orderItem,Label.XC_CL_Step_CompletedKO));
            }
        }
    }

    private static XC_Provisioning_Step__c getProvisioningStepToUpdate(NE__OrderItem__c orderItem, String status){
        XC_Provisioning_Step__c provisioningStepToUpdate = new XC_Provisioning_Step__c();
        provisioningStepToUpdate.Id = orderItem.Provisioning_Steps__r.get(0).Id;
        provisioningStepToUpdate.XC_Status__c = status;
        return provisioningStepToUpdate;
    }

    private static Boolean checkCondition(NE__OrderItem__c orderItem, String complianceType){
        return orderItem.Provisioning_Steps__r.size()>0 && ((complianceType == Label.XC_CL_Compliance_C2 && orderItem.XC_Compliance2_Status__c == Label.XC_CL_OK && orderItem.Provisioning_Steps__r.get(0).XC_Status__c == Label.XC_CL_InProgress) ||
                (complianceType == Label.XC_CL_Compliance_C3 && orderItem.XC_Compliance3_Status__c == Label.XC_CL_OK && orderItem.Provisioning_Steps__r.get(0).XC_Status__c == Label.XC_CL_InProgress) || (complianceType == Label.XC_CL_Compliance_C4 && orderItem.XC_Compliance4_Status__c == Label.XC_CL_OK && orderItem.Provisioning_Steps__r.get(0).XC_Status__c == Label.XC_CL_InProgress));
    }

    private static Boolean checkConditionKo(NE__OrderItem__c orderItem, String complianceType){
        return orderItem.Provisioning_Steps__r.size()>0 && ((complianceType == Label.XC_CL_Compliance_C2 && orderItem.XC_Compliance2_Status__c == Label.XC_CL_KO && orderItem.Provisioning_Steps__r.get(0).XC_Status__c == Label.XC_CL_InProgress) ||
                (complianceType == Label.XC_CL_Compliance_C3 && orderItem.XC_Compliance3_Status__c == Label.XC_CL_KO && orderItem.Provisioning_Steps__r.get(0).XC_Status__c == Label.XC_CL_InProgress) || (complianceType == Label.XC_CL_Compliance_C4 && orderItem.XC_Compliance4_Status__c == Label.XC_CL_KO && orderItem.Provisioning_Steps__r.get(0).XC_Status__c == Label.XC_CL_InProgress));
    }    
}
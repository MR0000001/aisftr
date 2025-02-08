/**
 * @author  Simone Trenta - strenta@deloitte.it Luca Tedeschi - ltedeschi@deloitte.it
 *          Salvatore Agrillo - salvatore.agrillo@nttdata.com (date Modification 03/04/2019)
 * @date Creation 11/01/2019
 * @description XC_TR_ComplVerifStatus_U_ParentToOk--- Change parent status to ok if all other child have status ok
 */

public class XC_TR_ComplVerifStatus_U_ParentToOk {

    private final static Boolean DEBUGACTIVE = true;     //XC_UTIL_Debug.isActive('XC_TR_ComplVerifStatus_U_ParentToOk');

    /** @description ParentToCheckWrapper */
    private class ParentToCheckWrapper {
        Set<Id> parentC1ToCheck = new Set<Id>();
        Set<Id> parentC2ToCheck = new Set<Id>();
        Set<Id> parentC3ToCheck = new Set<Id>();
        Set<Id> parentC4ToCheck = new Set<Id>();
    }

    /**
    * @description Change parent status
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void changeParentStatus(Map<Id, XC_ComplianceVerificationStatus__c> mapOld, Map<Id, XC_ComplianceVerificationStatus__c> mapNew) {
        List<String> fieldToCheck = new List<string> {'XC_ComplianceStatus__c'};
        List<XC_ComplianceVerificationStatus__c> changed = XC_UTIL_SObject.getListChanged(fieldToCheck, mapOld, mapNew);
        if(changed.isEmpty()){
            return;
        }

        /* modifica Salvatore Agrillo 03/04/2019 per risolvere la Cyclomatic Complexity */
        ParentToCheckWrapper parentWrapper = new ParentToCheckWrapper();
        Map<String, List<String>> junctionObject = new Map<String, List<String>>();
        populateParentWrapper(changed, parentWrapper, junctionObject);
        List<String> listOfOrderId = XC_UTIL_Sobject.getListFieldValues(changed, 'XC_Order__c');
        List<XC_OrderItemCompliance__c> allComp = new List<XC_OrderItemCompliance__c>();
        allComp = XC_TR_ComplVerifStatus_U_ParentToOk_D.getComplianceVerificationStatus(listOfOrderId);
        
        removeForOrderItemCompliance(allComp, parentWrapper);

        List<NE__OrderItem__c> con1 = XC_TR_ComplVerifStatus_U_ParentToOk_D.getConfigurationItemById(parentWrapper.parentC1ToCheck);
        List<NE__OrderItem__c> con2 = XC_TR_ComplVerifStatus_U_ParentToOk_D.getConfigurationItemById(parentWrapper.parentC2ToCheck);
        List<NE__OrderItem__c> con3 = XC_TR_ComplVerifStatus_U_ParentToOk_D.getConfigurationItemById(parentWrapper.parentC3ToCheck);
        List<NE__OrderItem__c> con4 = XC_TR_ComplVerifStatus_U_ParentToOk_D.getConfigurationItemById(parentWrapper.parentC4ToCheck);



        populateOrderItemStatusCompl1(con1, Label.XC_CL_ComplianceVerificationStatus_StatusOK);
        populateOrderItemStatusCompl2(con2, Label.XC_CL_ComplianceVerificationStatus_StatusOK);
        populateOrderItemStatusCompl3(con3, Label.XC_CL_ComplianceVerificationStatus_StatusOK);
        populateOrderItemStatusCompl4(con4, Label.XC_CL_ComplianceVerificationStatus_StatusOK);

        con1.addAll(con2);
        con1.addAll(con3);
        con1.addAll(con4);
        XC_UTIL_Sobject.updateListRecords(con1);
    }

    /**
    * @description Populate Parent Wrapper
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param changed - List<XC_ComplianceVerificationStatus__c>
    * @param parentWrapper - ParentToCheckWrapper
    */
    private static void populateParentWrapper(List<XC_ComplianceVerificationStatus__c> changed, ParentToCheckWrapper parentWrapper, Map<String, List<String>> junctionObject) {
        junctionObject = XC_TR_ComplVerifStatus_U_ParentToOk_D.getMapWithJunctionObjectByCVSWithAllOrderItem(changed);
        for(XC_ComplianceVerificationStatus__c c : changed) {
            /*if(c.XC_ComplianceStatus__c == Label.XC_CL_ComplianceVerificationStatus_StatusOK || c.XC_ComplianceStatus__c == Label.XC_CL_ComplianceVerificationStatus_StatusKO) {
                if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C1) parentC1ToCheck.add(c.XC_ParentConfigurationItem__c);
                if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C2) parentC2ToCheck.add(c.XC_ParentConfigurationItem__c);
                if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C3) parentC3ToCheck.add(c.XC_ParentConfigurationItem__c);
            }
            else {
                if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C1) parentC1ToCheck.remove(c.XC_ParentConfigurationItem__c);
                if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C2) parentC2ToCheck.remove(c.XC_ParentConfigurationItem__c);
                if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C3) parentC3ToCheck.remove(c.XC_ParentConfigurationItem__c);
            }*/

            if(c.XC_ComplianceStatus__c == Label.XC_CL_ComplianceVerificationStatus_StatusOK || c.XC_ComplianceStatus__c == Label.XC_CL_ComplianceVerificationStatus_StatusKO) {
                checkForComplianceType(c, parentWrapper, junctionObject);
            }
            else {
                removeForComplianceType(c, parentWrapper, junctionObject);
            }
        }
    }

    /**
    * @description Check in order to Compliance Type (FOR CYCLOMATIC COMPLEXITY)
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param c - XC_ComplianceVerificationStatus__c
    * @param parentWrapper - ParentToCheckWrapper
    * @param junctionObject - Map<String, String>
    */
    private static void checkForComplianceType(XC_ComplianceVerificationStatus__c c, ParentToCheckWrapper parentWrapper, Map<String, List<Id>> junctionObject) {
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C1 || c.XC_ComplianceType__c == Label.XC_CL_Compliance_C5) {
            parentWrapper.parentC1ToCheck.addAll(junctionObject.get(c.Id));
        }
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C2) {
            parentWrapper.parentC2ToCheck.addAll(junctionObject.get(c.Id));
        }
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C3) {
            parentWrapper.parentC3ToCheck.addAll(junctionObject.get(c.Id));
        }
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C4) {
            parentWrapper.parentC4ToCheck.addAll(junctionObject.get(c.Id));
        }
    }

    /**
    * @description Remove in order to Compliance Type (FOR CYCLOMATIC COMPLEXITY)
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param c - XC_ComplianceVerificationStatus__c
    * @param parentWrapper - ParentToCheckWrapper
    * @param junctionObject - Map<String, String>
    */
    private static void removeForComplianceType(XC_ComplianceVerificationStatus__c c, ParentToCheckWrapper parentWrapper, Map<String, List<Id>> junctionObject) {
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C1 || c.XC_ComplianceType__c == Label.XC_CL_Compliance_C5) {
            parentWrapper.parentC1ToCheck.removeAll(junctionObject.get(c.Id));
        }
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C2) {
            parentWrapper.parentC2ToCheck.removeAll(junctionObject.get(c.Id));
        }
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C3) {
            parentWrapper.parentC3ToCheck.removeAll(junctionObject.get(c.Id));
        }
        if(c.XC_ComplianceType__c == Label.XC_CL_Compliance_C4) {
            parentWrapper.parentC4ToCheck.removeAll(junctionObject.get(c.Id));
        }
    }

    /**
    * @description Remove in order to Order Item Compliance
    * @param allComp - List<XC_OrderItemCompliance__c>
    * @param parentWrapper - ParentToCheckWrapper
    */
    private static void removeForOrderItemCompliance(List<XC_OrderItemCompliance__c> allComp, ParentToCheckWrapper parentWrapper) {
        for(XC_OrderItemCompliance__c c : allComp) {

            if(checkForComplianceStatus(c)) {
                if(checkForParentComplianceStatus(parentWrapper.parentC1ToCheck, Label.XC_CL_Compliance_C1, c)) {
                    parentWrapper.parentC1ToCheck.remove(c.XC_OrderItem__c);
                }
                if(checkForParentComplianceStatus(parentWrapper.parentC1ToCheck, Label.XC_CL_Compliance_C5, c)) {
                    parentWrapper.parentC1ToCheck.remove(c.XC_OrderItem__c);
                }
                if(checkForParentComplianceStatus(parentWrapper.parentC2ToCheck, Label.XC_CL_Compliance_C2, c)) {
                    parentWrapper.parentC2ToCheck.remove(c.XC_OrderItem__c);
                }
                if(checkForParentComplianceStatus(parentWrapper.parentC3ToCheck, Label.XC_CL_Compliance_C3, c)) {
                    parentWrapper.parentC3ToCheck.remove(c.XC_OrderItem__c);
                }
                if(checkForParentComplianceStatus(parentWrapper.parentC4ToCheck, Label.XC_CL_Compliance_C4, c)) {
                    parentWrapper.parentC4ToCheck.remove(c.XC_OrderItem__c);
                }
            }

        }
    }

    /**
    * @description Populate Order Item Status
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param listOrderItem - List<NE__OrderItem__c>
    * @param status - String
    */
    private static void populateOrderItemStatusCompl1(List<NE__OrderItem__c> listOrderItem, String status) {
        for(NE__OrderItem__c orderItem : listOrderItem) {
            orderItem.XC_Compliance1_Status__c = status;
        }
    }

    /**
    * @description Populate Order Item Status
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param listOrderItem - List<NE__OrderItem__c>
    * @param status - String
    */
    private static void populateOrderItemStatusCompl2(List<NE__OrderItem__c> listOrderItem, String status) {
        for(NE__OrderItem__c orderItem : listOrderItem) {
            orderItem.XC_Compliance2_Status__c = status;
        }
    }

    /**
    * @description Populate Order Item Status
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param listOrderItem - List<NE__OrderItem__c>
    * @param status - String
    */
    private static void populateOrderItemStatusCompl3(List<NE__OrderItem__c> listOrderItem, String status) {
        for(NE__OrderItem__c orderItem : listOrderItem) {
            orderItem.XC_Compliance3_Status__c = status;
        }
    }

    /**
    * @description Populate Order Item Status
    * @author Anna Maria Rosanova - annamaria.rosanova@nttdata.com
    * @param listOrderItem - List<NE__OrderItem__c>
    * @param status - String
    */
    private static void populateOrderItemStatusCompl4(List<NE__OrderItem__c> listOrderItem, String status) {
        for(NE__OrderItem__c orderItem : listOrderItem) {
            orderItem.XC_Compliance4_Status__c = status;
        }
    }

    /**
    * @description Check for Compliance Status (FOR CYCLOMATIC COMPLEXITY)
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param c - XC_OrderItemCompliance__c
    * @return Boolean
    */
    private static Boolean checkForComplianceStatus(XC_OrderItemCompliance__c c) {
        return c.XC_ComplianceVerificationStatus__r.XC_ComplianceStatus__c != Label.XC_CL_ComplianceVerificationStatus_StatusOK && c.XC_ComplianceVerificationStatus__r.XC_ComplianceStatus__c != Label.XC_CL_ComplianceVerificationStatus_StatusKO;
    }

    /**
    * @description Check for Parent Compliance Status (FOR CYCLOMATIC COMPLEXITY)
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param parentCompl - Set<Id>
    * @param complianceLabel - String
    * @param c - XC_OrderItemCompliance__c
    * @return Boolean
    */
    private static Boolean checkForParentComplianceStatus(Set<Id> parentCompl, String complianceLabel, XC_OrderItemCompliance__c c) {
        return parentCompl.contains(c.XC_OrderItem__c) && c.XC_ComplianceVerificationStatus__r.XC_ComplianceType__c == complianceLabel;
    }
}
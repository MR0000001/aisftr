/**
 * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
 * @date: 16-05-2019
 * @description Util class for XC_TR_WorkOrder_U_PopulateServiceType
*/  

public without sharing class XC_TR_WorkOrder_U_PopulateServiceType_U {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_PopulateServiceType');
    
    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to match workOrder data with custom metadata
    * @param wo - WorkOrder 
    * @param confItem - NE__OrderItem__c 
    * @param mapServiceTypes - Map<Id, XC_CM_WorkOrderServiceType__mdt> 
    */
    public static void manageWorkOrderByConfItem(WorkOrder wo, NE__OrderItem__c confItem, Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### in manageWorkOrderByConfItem con ### ' + wo);
        for(XC_CM_WorkOrderServiceType__mdt cm : mapServiceTypes.values()){
            if(confItem.NE__Bundle_Configuration__c != null){
                if(wo.XC_WorkTypeCategory__c == cm.XC_WorkType__c && confItem.NE__ProdId__r.XC_Product_Subtype__c == cm.XC_SubType__c && cm.XC_Bundle__c){
                    populateServiceType(wo, cm.XC_ServiceType__c);
                    break;
                }
            } else {
                if(wo.XC_WorkTypeCategory__c == cm.XC_WorkType__c && confItem.NE__ProdId__r.XC_LIC_Product_Name__c == cm.XC_ProductName__c && !cm.XC_Bundle__c){
                    populateServiceType(wo, cm.XC_ServiceType__c);
                    break;
                }
            }    
        }
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to match workOrder data with custom metadata
    * @param wo - WorkOrder 
    * @param a - Asset
    * @param mapServiceTypes - Map<Id, XC_CM_WorkOrderServiceType__mdt> 
    */

    /*public static void manageWorkOrderByAsset(WorkOrder wo, Asset a, Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes){
        for(XC_CM_WorkOrderServiceType__mdt cm : mapServiceTypes.values()){
            if(a.NE__Bundle_Configuration__c != null){
                if(wo.XC_WorkTypeLabel__c == cm.XC_WorkType__c && a.NE__ProdId__r.XC_Product_Subtype__c == cm.XC_SubType__c && cm.XC_Bundle__c){
                    populateServiceType(wo, cm.XC_ServiceTypeGP__c);
                    break;
                }
            } else {
                if(wo.XC_WorkTypeLabel__c == cm.XC_WorkType__c && a.NE__ProdId__r.XC_LIC_Product_Name__c == cm.XC_ProductName__c && !cm.XC_Bundle__c){
                    populateServiceType(wo, cm.XC_ServiceTypeGP__c);
                    break;
                }
            }    
        }
    }*/


        /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to match workOrder data with custom metadata
    * @param wo - WorkOrder 
    * @param c - Case
    * @param mapServiceTypes - Map<Id, XC_CM_WorkOrderServiceType__mdt> 
    */

    public static void manageWorkOrderByCase(WorkOrder wo, Case c, Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### manageWorkOrderByCase con ### ' + wo);
        for(XC_CM_WorkOrderServiceType__mdt cm : mapServiceTypes.values()){
            if(c.Asset.NE__Bundle_Configuration__c != null){
                if(wo.XC_WorkTypeCategory__c == cm.XC_WorkType__c && c.Asset.NE__ProdId__r.XC_Product_Subtype__c == cm.XC_SubType__c && cm.XC_Bundle__c){
                    populateServiceType(wo, cm.XC_ServiceType__c);
                    break;
                }
            } else {
                if(wo.XC_WorkTypeCategory__c == cm.XC_WorkType__c && c.Asset.NE__ProdId__r.XC_LIC_Product_Name__c == cm.XC_ProductName__c && !cm.XC_Bundle__c){
                    populateServiceType(wo, cm.XC_ServiceType__c);
                    break;
                }
            }    
        }
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to match workOrder data with custom metadata
    * @param wo - WorkOrder 
    * @param a - Asset
    * @param mapServiceTypes - Map<Id, XC_CM_WorkOrderServiceType__mdt> 
    */

    public static void manageMaintenanceWorkOrderByAsset(WorkOrder wo, Asset a, Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### manageMaintenanceWorkOrderByAsset con ### ' + wo);
        for(XC_CM_WorkOrderServiceType__mdt cm : mapServiceTypes.values()){
            if(a != null) {
                if(checkConditionBundle(wo, a, cm)){
                    populateServiceType(wo, cm.XC_ServiceType__c);
                    break; 
                } else if(checkConditionNotBundle(wo, a, cm)){
                    if(wo.XC_PositionInMaintenancePlan__c == 1 && cm.XC_PositionOfMaintenanceWorkOrder__c == '1'){
                        populateServiceType(wo, cm.XC_ServiceType__c);
                        break;  
                    } else if(wo.XC_PositionInMaintenancePlan__c > 1 && cm.XC_PositionOfMaintenanceWorkOrder__c != '1'){
                        populateServiceType(wo, cm.XC_ServiceType__c);
                        break;  
                    }
                }    
            }
        }
    }

    private static Boolean checkConditionBundle(WorkOrder wo, Asset a, XC_CM_WorkOrderServiceType__mdt cm){
        return a.NE__Bundle_Configuration__c != null && cm.XC_Bundle__c && wo.XC_WorkTypeCategory__c == cm.XC_WorkType__c && a.NE__ProdId__r.XC_Product_Subtype__c == cm.XC_SubType__c;
    }

    private static Boolean checkConditionNotBundle(WorkOrder wo, Asset a, XC_CM_WorkOrderServiceType__mdt cm){
        return a.NE__Bundle_Configuration__c == null && !cm.XC_Bundle__c && wo.XC_WorkTypeCategory__c == cm.XC_WorkType__c && a.NE__ProdId__r.XC_LIC_Product_Name__c == cm.XC_ProductName__c;
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to populate Service Type on WorkOrder
    * @param wo - WorkOrder  
    * @param serviceType 
    */ 

    public static void populateServiceType(WorkOrder wo, String serviceType){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### populateServiceType ### ' + wo);
        wo.XC_ServiceTypeGP__c = serviceType;
    }
    
}
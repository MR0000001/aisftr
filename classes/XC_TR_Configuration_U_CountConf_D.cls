/**
* @author Giulio Serra giserra@deloitte.it
* @date Creation 06/09/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Configuration_U_CountConf_D  – DAO Class for XC_TR_Configuration_U_CountConf
*/
 
public without sharing class XC_TR_Configuration_U_CountConf_D {

    /**
     * @description Retrieve opportunities with children configurations.
     * @param setIdOpportunities the set id opportunities
     * @return the map
     */
    public static Map<Id,Opportunity> retrieveOpportunitiesWithChildrenConfigurations(Set<Id> setIdOpportunities){
        Map<Id,Opportunity> mapMyOpportunity = new Map<Id,Opportunity>([
            SELECT Id, StageName, XC_NumberOfConfiguration__c, XC_EnableChangeStage__c, (
            SELECT Id, RecordTypeId, RecordType.DeveloperName, NE__OrderStatus__c, XC_Status__c, NE__Type__c FROM NE__Orders__r) 
            FROM Opportunity WHERE Id IN :setIdOpportunities AND StageName NOT IN (:Label.XC_CL_Opportunity_ClosedWon, :Label.XC_CL_Opportunity_ClosedLost)
        ]); 

        return mapMyOpportunity;
    }

    /**
     * @description Gets the work order from opportunity.
     * @param opportunity the opportunity
     * @return the work order from opportunity
     */
    public static List<WorkOrder> getWorkOrderFromOpportunity(Set<Id> opportunity){
        List<WorkOrder> woList = new List<WorkOrder>([SELECT XC_Opportunity__c,(SELECT Status,XC_OrderOfActivity__c FROM WorkOrderLineItems) 
                               FROM   WorkOrder
                               WHERE   XC_WorkTypeCategory__c=: Label.XC_CL_CommercialVisit
                               AND    Status =: Label.XC_CL_WorkOrder_InProgress
                               AND    XC_Opportunity__c IN :opportunity]);
        return woList;
    }
     /**
    * @description Gets Work Order and his related Service Opportunity from Order
    * @param listOrderIds - List<String>
    * @return List<WorkOrder> 
    **/
    public static List<WorkOrder> getWorkOrderWithSa(List<String> listOrderIds){   
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([SELECT Id, Status, XC_Configuration_Item__r.NE__OrderId__c, (SELECT Id, Status, XC_StatusReason__c  FROM ServiceAppointments ) FROM WorkOrder WHERE XC_Check_Final_Status__c = false AND XC_WorkTypeCategory__c = :Label.XC_CL_WorkType_DeliveryInstallation AND (XC_Configuration_Item__r.NE__OrderId__c IN :listOrderIds OR XC_Configuration__c IN: listOrderIds)]);
        return listWorkOrder;
    }
}
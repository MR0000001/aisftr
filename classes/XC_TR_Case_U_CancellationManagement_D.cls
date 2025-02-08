/**
 * The Class XC_TR_Case_U_CancellationManagement_D.
 *
 * @author            : Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 20/08/2019
 * @date Modification : dd/mm/yyyy 
 * @description       : Class to manage Case cancellation DAO
 **/ 

public without sharing class XC_TR_Case_U_CancellationManagement_D {


    /**
    * getChildCase.
    * 
    * @param parentCaseIds the parent case ids 
    * @retrun Map<Id,Case> the map with CaseId as key and Case as value
    * @description method to retrieve child case
    */
    public static Map<Id,Case> getChildCase(Set<Id> parentCaseIds){

        List<String> woStatusList = new List<String>{Label.XC_CL_Completed, Label.XC_CL_Cancelled, Label.XC_CL_CannotComplete};
        List<String> caseStatusList = new  List<String>{XC_AT_Constants.TRIGGER_STATUS_ESTA008, XC_AT_Constants.TRIGGER_STATUS_ESTA007};
        List<String> oppStatusList = new List<String>{Label.XC_CL_Opportunity_ClosedLost, Label.XC_CL_Opportunity_ClosedWon};

        Map<id,Case> idToCase = new Map<id,Case>([SELECT Id,
                                                (SELECT Id, Status FROM WorkOrders WHERE status NOT IN: woStatusList),
                                                (SELECT Id, Status FROM Cases WHERE status NOT IN: caseStatusList),
                                                (SELECT Id, XC_Status__c, RecordType.Name FROM Configurations__r 
                                                WHERE RecordType.Name =: Label.XC_CL_Order_RecordTypeOrder OR RecordType.Name =: Label.XC_CL_Configuration_RtQuote),
                                                (SELECT Id, StageName FROM Opportunities__r WHERE StageName NOT IN: oppStatusList)
                                                FROM Case 
                                                WHERE Id IN: parentCaseIds]);

        return idToCase;

    }

    
    /**
    * getChildOpportunity.
    * 
    * @param oppIds the opportunity ids 
    * @retrun Map<Id,Opportunity> the map with OpportunityId as key and Opportunity as value
    * @description method to retrieve child opportunity
    */
    public static Map<Id,Opportunity> getChildOpportunity(List<Id> oppIds){

        Map<Id,Opportunity> idToOpportunity = new  Map<Id,Opportunity>([SELECT Id, StageName,
                                            (SELECT Id, XC_Status__c FROM NE__Orders__r),
                                            (SELECT Id, OwnerId, Status FROM Work_Orders__r)
                                            FROM Opportunity 
                                            WHERE Id IN: oppIds
                                            ]);

        return idToOpportunity;

    }


    /**
    * getChildWorkOrder.
    * 
    * @param woIds the WorkOrder ids 
    * @retrun Map<Id,WorkOrder> the map with WorkOrderId as key and WorkOrder as value
    * @description method to retrieve child WorkOrder
    */
    public static Map<Id,WorkOrder> getChildWorkOrder(List<Id> woIds){

        List<String> statusList = new List<String>{Label.XC_CL_Completed, Label.XC_CL_Cancelled, Label.XC_CL_CannotComplete};
        Map<Id,WorkOrder> idToWorkOrder = new  Map<Id,WorkOrder>([SELECT id, Status, 
                                                (SELECT Id, Status FROM ServiceAppointments WHERE status NOT IN: statusList)
                                                FROM WorkOrder
                                                WHERE Id IN: woIds
                                                ]);

        return idToWorkOrder;

    }

}
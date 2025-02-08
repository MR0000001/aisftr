/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 25/10/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_WorkOrderLineItem – Util class for WorkOrderLineItems methods
*/ 
public without sharing class XC_UTIL_WorkOrderLineItem {
    
    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description wrapper class for workOrderLineItem
    **/
    public class WorkOrderLineItemWrapper{

        public String WorkOrderLineItemNumber;  //LineItemNumber
        public String Status;                   //Status
        public DateTime ActionStart;            //XC_Action_Start__c
        public DateTime ActionEnd;              //XC_Action_End__c
        public String ActivityName;             //XC_ActivityName__c
        public Boolean Required;                //XC_Required__c    
        public String Operation;                //XC_Operation__c
        public String Description;              //Description
        public String CompletionMode;           //XC_CompletionMode__c
        public String TechnicianResponse;       //XC_TechnicianResponse__c
        public String DefectType;               //XC_DefectType__c
        public String DefectRefer;              //XC_DefectRefer__c

        public String ActionDescription;
        public Integer MacroBlocNumber;
        public String MacroBlocName;
        public Integer ActivityNumber;
        public String ObservationsOne;
        public String ObservationsTWO;
        public Decimal MeasurementValueOne;
        public String MeasurementUnitOne;
        public Decimal MeasurementValueTwo;
        public String MeasurementUnitTwo;
        public String RecordTypeID;
        public String AssetID;

        public String AssetName;
		public String AssetBrand;
		public String AssetModel;
		public String AssetCatalogCategory;

        public String Range;

        public String WorkOrderLineItemID;    

    }

    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description Method to create a Work Order Line Item.
     * @param param wrapper of the WOLI
     * @param woId WorkOrder Id
     * @param wlOut return WOLI
     * @return the updated WOLI
    **/
    public static WorkOrderLineItem createWorkOrderLineItemByWrapper(WorkOrderLineItemWrapper param, string woId, WorkOrderLineItem wlOut){

        Map<String, Object> mapField = new Map<String, Object>{ 
            'WorkOrderid' => woId,
            'Status' => param.Status, 
            'XC_Action_Start__c' => param.ActionStart, 
            'XC_Action_End__c' => param.ActionEnd, 
            'XC_ActivityName__c' => param.ActivityName, 
            'XC_Required__c' => param.Required, 
            'XC_Operation__c' => param.Operation, 
            'Description' => param.Description, 
            'XC_CompletionMode__c' => param.CompletionMode, 
            'XC_DefectType__c' => param.DefectType, 
            'XC_DefectRefer__c' => param.DefectRefer,
            'XC_ActionDescription__c' => param.ActionDescription,
            'XC_MacroBlocNumber__c' => param.MacroBlocNumber,
            'XC_MacroBlocName__c' => param.MacroBlocName,
            'XC_ActivityNumber__c' => param.ActivityNumber,
            'XC_ObservationsOne__c' => param.ObservationsOne,
            'XC_ObservationsTWO__c' => param.ObservationsTWO,
            'XC_MeasurementValueOne__c' => param.MeasurementValueOne,
            'XC_MeasurementUnitOne__c' => param.MeasurementUnitOne,
            'XC_MeasurementValueTwo__c' => param.MeasurementValueTwo,
            'XC_MeasurementUnitTwo__c' => param.MeasurementUnitTwo,
            'XC_TechnicianResponse__c' => param.TechnicianResponse,
            'RecordTypeId' => param.RecordTypeID,
            'AssetId' => param.AssetID
        };

        for (String field : mapField.keySet()) {
            if ( mapField.get(field)!=null && mapField.get(field)+'' != '') {
                wlOut.put(field, mapField.get(field));
            }    
        }
        
        return wlout;
    }
   


}
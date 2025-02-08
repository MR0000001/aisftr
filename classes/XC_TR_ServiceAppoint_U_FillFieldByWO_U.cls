/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation: 19/04/2019
* @date Modification:
* @description XC_TR_ServiceAppointment_U_CheckStatus_U Utility Class
*/
public  without sharing class XC_TR_ServiceAppoint_U_FillFieldByWO_U {
	  
    /**
     * Check on status.
     *
     * @author Porrega Roberta - roberta.porrega@nttdata.com, Cossiga Roberta - rcossiga@deloitte.it
     * @param listNew the service appointment 
     * @return List<String>
     * @description  method to update the lead status of the service appointment
     */

    public static List<String> retrieveWorkOrderFromCanceledSA (List<ServiceAppointment> listNew){
        List<String> listOfWorkOrderId = new List<String>();
        if(!listNew.isEmpty()){
        for(ServiceAppointment sa : listNew){
            if(sa.Status == Label.XC_CL_ServiceAppointment_CannotComplete || sa.Status == Label.XC_CL_ServiceAppointment_Canceled){
            listOfWorkOrderId.add(sa.ParentRecordId);
            }
        }  
        } 
        return listOfWorkOrderId;    
    }

    /**
     * Check on status.
     *
     * @author Porrega Roberta - roberta.porrega@nttdata.com, Cossiga Roberta - rcossiga@deloitte.it
     * @param listOfWorkOrderId
     * @return List<Id>
     * @description  method to update the lead status of the service appointment
     */

    public static List<Id> retrieveLeadToUpdate (List<String> listOfWorkOrderId){
        List<Id> leadToUpdate = new List<Id> ();     
        if(!listOfWorkOrderId.isEmpty() && Schema.sObjectType.WorkOrder.isAccessible() && Schema.sObjectType.WorkOrder.fields.Id.isAccessible() && Schema.sObjectType.WorkOrder.fields.XC_Lead__c.isAccessible()){
            List<WorkOrder> workOrder =  [SELECT Id, XC_Lead__c 
                                          FROM WorkOrder
                                          WHERE Id IN: listOfWorkOrderId];
            for(WorkOrder wo : workOrder) {
                if(!String.isBlank(wo.XC_Lead__c)) {
                    leadToUpdate.add(wo.XC_Lead__c);
                }
            }
        }
        return leadToUpdate;
    }


    /**
     * Retrieve Custom Metadata information
     *
     * @author Cossiga Roberta - rcossiga@deloitte.it
     * @param listCountries
     * @return Map<Id, XC_CM_CaseUrgencyManagement__mdt>
     * @description  method to update the lead status of the service appointment
     */

    public static  Map<String, XC_CM_CaseUrgencyManagement__mdt> retrieveRepairDate (List<String> listCountries){
        Map<Id, XC_CM_CaseUrgencyManagement__mdt> mapRepairDatesCM = new Map<Id, XC_CM_CaseUrgencyManagement__mdt>(
                                                                        [SELECT Id, XC_Country__c, XC_HourForEarliestStartTime__c, XC_HourForDueDate__c, XC_TypeOfRepair__c
                                                                         FROM XC_CM_CaseUrgencyManagement__mdt
                                                                         WHERE XC_Country__c IN: listCountries]);
        Map<String, XC_CM_CaseUrgencyManagement__mdt> mapRepairTypeToDates = new Map<String, XC_CM_CaseUrgencyManagement__mdt>();
        for(XC_CM_CaseUrgencyManagement__mdt mdt : mapRepairDatesCM.values()){
            mapRepairTypeToDates.put(mdt.XC_TypeOfRepair__c, mdt);
        }
        return mapRepairTypeToDates;    
    }

}
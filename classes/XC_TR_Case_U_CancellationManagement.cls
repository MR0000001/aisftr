/**
 * The Class XC_TR_Case_U_CancellationManagement.
 *
 * @author            : Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 20/08/2019
 * @date Modification : dd/mm/yyyy 
 * @description       : Class to manage Case cancellation
 **/ 


public without sharing class XC_TR_Case_U_CancellationManagement {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_CancellationManagement');

    /**
    * manageChildrenCaseStatusOnUpdate.
    * 
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    * @description cancel the children case when a parent case is cancelled
    */
    public static void manageChildrenCaseStatusOnUpdate(List<Case> listNew, Map<Id, Case> mapOld, Map<Id, Case> mapNew) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_CancellationManagement.manageChildrenCaseStatusOnUpdate');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + listNew);
        List<String> fieldList = new List<String>{'Status'}; 
        List<Case> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);

        Map<Id,Case> parentCases = new Map<Id,Case>();

        if(!listChanged.isEmpty()){
            Set<Id> parentCaseIds = new Set<Id>();
            for(Case c : listChanged){
                if(String.isBlank(c.ParentId) && c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA008){
                    parentCases.put(c.Id, c);
                }
            }
            if(!parentCases.isEmpty()){
                manageChildrenCaseStatus(parentCases);
            }
        }
    }


    /**
    * manageChildrenCaseStatus.
    * 
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    * @description cancel the case children when a parent case is cancelled
    */
    public static void manageChildrenCaseStatus(Map<Id,Case> parentCases){

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'enter in manageChildrenCaseStatus with parent case ids = '+ parentCases.keySet());

        Map<id,Case> idToCase = XC_TR_Case_U_CancellationManagement_D.getChildCase(parentCases.keySet());
        
        Map<List<Id>, Id> childrenIdsToCase = new Map<List<Id>, Id>();

        List<ServiceAppointment> serAppListToUpdate = new List<ServiceAppointment>();
        List<Sobject> sObjectToupdate = new List<Sobject>();
    
        for(Case parentCase : parentCases.values()){
            Boolean foundError = false;
            sObjectToupdate.addAll(updateChildernCase(idToCase.get(parentCase.Id).Cases,  parentCase));
            sObjectToupdate.addAll(updateWorkOrders(idToCase.get(parentCase.Id).WorkOrders, serAppListToUpdate));
            sObjectToupdate.addAll(serAppListToUpdate);
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            foundError = updateOpportunities(idToCase.get(parentCase.Id).Opportunities__r, oppListToUpdate);
            if(foundError){
                parentCase.addError(Label.XC_CL_OpportunityWithChildRecord);
                continue;
            }else{
                sObjectToupdate.addAll(oppListToUpdate);
            }
            List<NE__Order__c> confListToUpdate = new List<NE__Order__c>();
            foundError = updateConfigurations(idToCase.get(parentCase.Id).Configurations__r, confListToUpdate);
            if(foundError){
                parentCase.addError(Label.XC_CL_OrderInProvisioning);
                continue;
            }else{
                sObjectToupdate.addAll(confListToUpdate);
            }
            List<Id> ids = XC_UTIL_Sobject.getIds(sObjectToupdate);
            childrenIdsToCase.put(ids,parentCase.Id);
        }

        if(!sObjectToupdate.isEmpty()){
            manageError(sObjectToupdate, childrenIdsToCase, parentCases);
        }
    }

    
    /**
    * manageError.
    * 
    * @param sObjectToupdate the sobject to update
    * @param childrenIdsToCase map with list of children ids as key and parent case id as key
    * @param parentCases the parent case
    * @description manage update errror
    */
    public static void manageError(List<Sobject> sObjectToupdate, Map<List<Id>, Id> childrenIdsToCase, Map<Id,Case> parentCases){
        
        List<Database.SaveResult> results = Database.update(sObjectToupdate, false);

        for(Integer i=0;i<results.size();i++){
            if(!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String errorMessage = error.getMessage();
                Id objectFailedId = sObjectToupdate.get(i).Id;
                for(List<Id> ids : childrenIdsToCase.keySet()){ // to be modified 
                    if(ids.contains(objectFailedId)){
                        Case parentCase = parentCases.get(childrenIdsToCase.get(ids));
                        parentCase.addError(errorMessage);
                    }
                }
            }
        }
    }

    /**
    * updateChildernCase.
    * 
    * @param childrenCaseList the children case list
    * @param parentCase the parent case
    * @return List<Case> the case list to update
    * @description update chil case fields - Case
    */
    public static List<Case> updateChildernCase(List<Case> childrenCaseList, Case parentCase){

        List<Case> caseListToUpdate = new List<Case>();
        for(Case childCase : childrenCaseList){
            childCase.Status = XC_AT_Constants.TRIGGER_STATUS_ESTA008; 
            childCase.XC_Resolution__c = parentCase.XC_Resolution__c;
            childCase.XC_Result__c = parentCase.XC_Result__c;
            childCase.CaseRemarks__c = Label.XC_CL_ChildCaseCancellation; 
            caseListToUpdate.add(childCase);
        }
        return caseListToUpdate; 
    }


    /**
    * updateOpportunities.
    * 
    * @param oppList the opportunity list of the case
    * @param foundError the boolean to chek if there is an error
    * @return List<Opportunity> the opportnity list to update
    * @description update chil case fields  - Opportunity
    */
    public static Boolean updateOpportunities(List<Opportunity> oppList, List<Opportunity> oppListToUpdate){

        Boolean foundError = false; 

        List<Id> oppIds = XC_UTIL_Sobject.getIds(oppList);
        Map<Id,Opportunity> idToOpportunity = XC_TR_Case_U_CancellationManagement_D.getChildOpportunity(oppIds);

        for(Id opportunityId : idToOpportunity.keySet()){
            //if(idToOpportunity.get(opportunityId).StageName != Label.XC_CL_Opportunity_ClosedLost && idToOpportunity.get(opportunityId).StageName != Label.XC_CL_Opportunity_ClosedWon){
                if(idToOpportunity.get(opportunityId).NE__Orders__r.size() > 0 || idToOpportunity.get(opportunityId).Work_Orders__r.size() > 0){
                    foundError = true;
                    oppListToUpdate = new List<Opportunity>();
                    break;
                }else{
                    idToOpportunity.get(opportunityId).XC_LossReason__c = Label.XC_CL_Other; 
                    idToOpportunity.get(opportunityId).StageName = Label.XC_CL_Opportunity_ClosedLost;
                    oppListToUpdate.add(idToOpportunity.get(opportunityId));
                }
            //}
        }
        return foundError; 
    }


    /**
    * updateConfigurations.
    * 
    * @param confList the configuration list of the case
    * @return List<NE__order__c> the configuration list to update
    * @description update chil case fields - Configuration
    */
    public static Boolean updateConfigurations(List<NE__Order__c> confList, List<NE__Order__c> confListToUpdate){

        Boolean foundError = false;

        for(NE__Order__c conf : confList){
            if(conf.RecordType.Name == Label.XC_CL_Order_RecordTypeOrder){
                if(conf.XC_Status__c != Label.XC_CL_Order_StatusCancelled && conf.XC_Status__c != Label.XC_CL_Configuration_Closed){
                    if(conf.XC_Status__c == 'In provisioning'){
                        foundError = true;
                        confListToUpdate = new List<NE__Order__c>();
                        break;
                    }else{
                        conf.XC_Status__c = Label.XC_CL_Order_StatusCancelled;
                        conf.XC_Reason_of_cancellation__c = Label.XC_CL_Configuration_CancelledCase; 
                        confListToUpdate.add(conf);
                    }
                }
            }else if(conf.RecordType.Name == Label.XC_CL_Configuration_RtQuote){
                if(conf.XC_Status__c != Label.XC_CL_Configuration_QuoteAccepted && conf.XC_Status__c != Label.XC_CL_Configuration_QuoteRejected){
                    conf.XC_Status__c = Label.XC_CL_Configuration_QuoteRejected;
                    conf.XC_Reason_of_cancellation__c = Label.XC_CL_Configuration_CancelledCase; 
                    confListToUpdate.add(conf);
                }
            } 
        }
        return foundError; 
    }


    /**
    * updateWorkOrders.
    * 
    * @param woList the work order list of the case
    * @return List<WorkOrder> the WorkOrder list to update
    * @description update chil case fields -  WorkOrder 
    */
    public static List<WorkOrder> updateWorkOrders(List<WorkOrder> woList, List<ServiceAppointment> serAppList){

        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        List<Id> woIds = XC_UTIL_Sobject.getIds(woList);
        
        Map<Id,WorkOrder> idToWorkOrder = XC_TR_Case_U_CancellationManagement_D.getChildWorkOrder(woIds);
        List<WorkOrder> listToUpdateDigit = new List<WorkOrder>();
        
        for(Id workOrderId : idToWorkOrder.keySet()){
            WorkOrder woFiltered = idToWorkOrder.get(workOrderId);
            if(woFiltered.ServiceAppointments.size() > 0){
                for(ServiceAppointment serApp : woFiltered.ServiceAppointments){
                    if(serApp.status == Label.XC_CL_ServiceAppointment_None || serApp.status == Label.XC_CL_ServiceAppointment_Scheduled){
                        serApp.status = Label.XC_CL_Cancelled;
                        serApp.XC_ForceWOCancellation__c = true;
                        serAppList.add(serApp);
                    }else{
                        serApp.status = Label.XC_CL_CannotComplete;
                        serApp.XC_Reason_Cannot_Complete__c = Label.XC_CL_CancelledByParentCase; 
                        serAppList.add(serApp);
                    }
                }
                woFiltered.XC_ToBeManuallyDigitalized__c = true;
                woFiltered.XC_Digitized__c = true;
                listToUpdateDigit.add(woFiltered);
            }else if(woFiltered.Status == Label.XC_CL_WorkOrder_New || woFiltered.Status == Label.XC_CL_WorkOrder_Assigned){
                woFiltered.Status = Label.XC_CL_Cancelled;
                woFiltered.XC_ToBeManuallyDigitalized__c = true;
                woFiltered.XC_Digitized__c = true;
                woListToUpdate.add(woFiltered);
            }else{
                woFiltered.Status = Label.XC_CL_CannotComplete;
                woFiltered.XC_Reason_Cannot_Complete__c = Label.XC_CL_CancelledByParentCase;
                woFiltered.XC_ToBeManuallyDigitalized__c = true;
                woFiltered.XC_Digitized__c = true;
                woListToUpdate.add(woFiltered);
            }
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(listToUpdateDigit);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        return woListToUpdate; 
    }


}
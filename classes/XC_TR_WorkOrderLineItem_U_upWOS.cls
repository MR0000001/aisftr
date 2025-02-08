/**
* @author Giulio Serra
* @date Creation 26/09/2018
* @date Modification 15/02/2019 
* @description XC_TR_WorkOrderLineItem_U_upWOS – utility class for the handler
*/

public without sharing class XC_TR_WorkOrderLineItem_U_upWOS {
     
    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrderLineItem_U_upWOS'); 

    /**
    * @description UtilWrapper
    */
    public class UtilWrapper {
        public List<WorkOrder> woToUpdate = new List<WorkOrder>();
        public List<Opportunity> oppToUpdate = new List<Opportunity>();
        public List<ServiceAppointment> serAppToUpdate = new List<ServiceAppointment>();
        public List<WorkOrder> woToNotify = new List<Workorder>();
    }
    
    /**
     * On before insert WOLI.  
     *
     * @author Giulio Serra giserra@deloitte.it   
     * @param listNew the list new
     * @param oldMap the old map
     * @param newMap the new map
     * @description check if the changed WorkOrderLineItem respect the state model
     */
    public static void onBeforeInsertWOLI(List<WorkOrderLineItem> listNew,Map<Id,WorkOrderLineItem> oldMap,Map<Id,WorkOrderLineItem> newMap ){ 

        List<String> fieldList = new List<String>{'Status'};// field list that I'm listening for updates
        List<WorkOrderLineItem> changed = XC_UTIL_SObject.getListChanged(fieldList, oldMap, newMap); 
        XC_UTIL_Debug.debug(DEBUGACTIVE,'WOLI CHANGED='+changed); 

        if(!changed.isEmpty()){ 
            Set<Id> workOrderID = getWorkOrderSet(changed);
            Map<Id,WorkOrder> workOrderMap = XC_TR_WorkOrderLineItem_U_upWOS_D.getWorkOrderFromChildren(workOrderID);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'woqua='+workOrderMap.values()); 
            
            UtilWrapper wrapper = XC_TR_WorkOrderLineItem_U_upWOSUtil.cycleOnWoli(changed, workOrderMap, oldMap);
            List<WorkOrder> woToUpdate = wrapper.woToUpdate;
            List<ServiceAppointment> serAppToUpdate = wrapper.serAppToUpdate;
            List<Opportunity> oppToUpdate = wrapper.oppToUpdate;
            List<WorkOrder> woToNotify = wrapper.woToNotify;

            XC_UTIL_Debug.debug(DEBUGACTIVE,'#woToUPDATE' + woToUpdate); 
            XC_UTIL_Sobject.updateListRecords(woTOUpdate);

            XC_UTIL_Debug.debug(DEBUGACTIVE,'#Opp to update' + oppToUpdate); 
            XC_UTIL_Sobject.updateListRecords(oppToUpdate);

            XC_UTIL_Debug.debug(DEBUGACTIVE,'#SerApp to update' + serAppToUpdate); 
            if(!serAppToUpdate.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(serAppToUpdate);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE,'#woToNotify' + woToNotify); 
            notifyWorkOrderClient(woToNotify);
        } 
    }



    /**
     * Notify work order client.
     *
     * @author Giulio Serra - giserra@deloitte.it
     * @param workOrders the work orders
     * @date Creation 4/12/2018 ESCEP-106
     * @date Modification dd/mm/yyyy
     * @description send a notification to the owner of the workOrders through marketing cloud
     */
    private static void notifyWorkOrderClient(List<WorkOrder> workOrders){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@@arance' + workOrders); 
        List<Map<String,Object>> woToNotify = new List<Map<String,Object>>();
        List<Id> opportunityId = XC_UTIL_Sobject.getListFieldValues(workOrders, 'XC_Opportunity__c');
        List<Opportunity> opportunities = XC_TR_WorkOrderLineItem_U_upWOS_D.getOpportunityFromIds(opportunityId).values();
        List<Id> contactId = XC_UTIL_Sobject.getListFieldValues(opportunities, 'Contact__c');
        Map<Id,Contact> contacts =  XC_TR_WorkOrderLineItem_U_upWOS_D.getContactsFromOpportunity(contactId);

        for(WorkOrder workOrder : workOrders){
            woToNotify.add(createValueMap(workOrder,contacts.get(workOrder.ContactId)));
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'@@mandarini to notify' + woToNotify); 
        List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(woToNotify);

        manageResults(results);

    }

    /**
     * Creates the value map.
     *
     * @author Giulio Serra - giserra@deloitte.it
     * @param workOrder the work order
     * @param cont the cont
     * @return the map
     * @date Creation 4/12/2018 ESCEP-106
     * @date Modification dd/mm/yyyy
     * @description create a map with the values of a work order
     */
    private static Map<String,Object> createValueMap(Workorder workOrder,Contact cont){
        
        Map<String,Object> data = new Map<String,Object>();

        data.put('customerType', 'WorkOrder_QuoteNotCreated_Email');
        data.put('workorderId', workOrder.id);
        data.put('skipComunication', false);
        data.put('opportunityId', workOrder.XC_Opportunity__c); //Marketing Cloud opportunityID required issue - 05/12/2018 - MCutillo, LOrlanducci

        if(cont != null){
            data.put('email', cont.Email);
            data.put('fullName', cont.Name);
            data.put('contactId', cont.Id);
            data.put('preferredlanguage',cont.XC_Preferredlanguageofcontact__c);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE,'Order Map value' + ' ' + data); 

        return data;
    }



    /**
     * Manage results.
     *
     * @author Giulio Serra giserra@deloitte.it
     * @param results the results
     * @date Creation 21/08/2018
     * @date Modification dd/mm/yyyy
     * @description manage the update of the opportunities
     */
    private static void manageResults(List<XC_UTIL_Sobject.WrapperResult> results){
        for(XC_UTIL_Sobject.WrapperResult result : results) {
            if(!result.success) {
                System.debug('Error creating customer interaction:' + result);
            }
        }
    }
 
    private static void checkOnNumberActivityOne(List<Opportunity> oppToUpdate, Workorder father, WorkOrderLineItem currentWoli ){
        if(currentWoli.XC_OrderOfActivity__c == 1){    
            if(father.ServiceAppointments.size() == 0) {
                currentWoli.addError(Label.XC_CL_WorkOrderLineItem_NOSA);
            } else if(!isRangeOfTimeCorrect(father)){
                currentWoli.addError(Label.XC_CL_WorkOrderLineItem_SAR);
            }else if(father.Status != Label.XC_CL_WorkOrder_Assigned && father.Status != Label.XC_CL_WorkOrder_InProgress){
                currentWoli.addError(Label.XC_CL_WorkOrderLineItem_NOAssigned);// 3/01/19 GS*/ 
            }else{
                Opportunity opp = new Opportunity(id=father.XC_Opportunity__c);
                opp.XC_CommercialVisitStarted__c = true;
                oppToUpdate.add(opp);
            }
        }
    }
    /**
     * Manage woli brothers.
     *
     * @author Giulio Serra - giserra@deloitte.it & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param wrapper
     * @return the work order
     * @date Creation 26/09/2018
     * @date Modification 4/12/2018 ESCEP-106
     * @description check if the changed WorkOrderLineItems respect the state model, return the father of the workorder if changed
     */
    public static WorkOrder manageWoliBrothers(XC_TR_WorkOrderLineItem_U_upWOSUtil.UtilityWrapper wrapper){ 
        WorkOrderLineItem currentWoli = wrapper.currentWoli;
        Workorder father = wrapper.father;
        List<Opportunity> oppToUpdate = wrapper.oppToUpdate;
        List<WorkOrder> woliToNotify = wrapper.woliToNotify;
        Map<Decimal,WorkOrderLineItem> orderedStatus = new Map<Decimal,WorkOrderLineItem>();
        List<WorkOrder> woToUpdate = new List<Workorder>();
        for(WorkOrderLineItem woLineItem : father.WorkOrderLineItems){
            orderedStatus.put(woLineItem.XC_OrderOfActivity__c, woLineItem);
        } 

        checkOnNumberActivityOne(oppToUpdate, father, currentWoli);

        if(currentWoli.XC_OrderOfActivity__c == 3){
            if(!isStatusCompleted(2,orderedStatus)){
                currentWoli.addError(orderedStatus.get(2).XC_ActivityName__c + ' ' + 'must be completed first');
            }           
        }
        if(currentWoli.XC_OrderOfActivity__c == 4){
            Boolean isTwoCompleted = isStatusCompleted(2,orderedStatus);
            Boolean isThreeCompleted = isStatusCompleted(3,orderedStatus);
            Boolean isFatherMissinQuoteBlank = String.isBlank(father.XC_MissingQuoteReason__c);
            Boolean quoteErrorCondition = !isTwoCompleted && isFatherMissinQuoteBlank;
            Boolean notifyCondition = (!isTwoCompleted && !isFatherMissinQuoteBlank);
            
            if(!isStatusCompleted(1,orderedStatus)) {
                currentWoli.addError(orderedStatus.get(1).XC_ActivityName__c + ' ' + 'must be completed first');
            }
            if(quoteErrorCondition) {
                currentWoli.addError('You must complete ' + orderedStatus.get(2).XC_ActivityName__c + ' or ' + Label.XC_CL_WorkOrderLineItem_MissingQuoteReason);
            }
            if(notifyCondition) {
                woliToNotify.add(father);
            }
            currentWoli.Status = Label.XC_CL_WorkOrderLineItem_Closed;
        }
        return father;
    } 

    

    
    /**
     * Checks if is range of time correct.
     *
     * @author Giulio Serra
     * @param father the father
     * @return the boolean 
     * @date Creation 26/09/2018
     * @date Modification dd/mm/yyyy<
     * @description check if a the first work order line item respect the range of time of the related service appointment
     */
    private static Boolean isRangeOfTimeCorrect(WorkOrder father){
        return XC_UTIL_ServiceAppointment.checkRangeTimeOnServiceAppointment(father.ServiceAppointments);
    }        
 
    /**
     * Checks if is status completed.
     *
     * @author Giulio Serra
     * @param statusNumber the status number
     * @param orderedStatus the ordered status
     * @return the boolean
     * @date Creation 26/09/2018
     * @date Modification dd/mm/yyyy<
     * @description check if a stutus of work order line item is 'Completed'
     */
    private static Boolean isStatusCompleted(Decimal statusNumber,Map<Decimal,WorkOrderLineItem> orderedStatus){
        return orderedStatus.get(statusNumber) != null && orderedStatus.get(statusNumber).Status ==  Label.XC_CL_WorkOrderLineItem_Closed;
    }



    /**
     * Gets the work order set.
     *
     * @author Giulio Serra
     * @param itemsList the items list
     * @return the work order set
     * @date Creation 26/09/2018
     * @date Modification dd/mm/yyyy<
     * @description return a set of IDs ot the WorkOrderItems fathers of the collection passed
     */

    public static Set<Id> getWorkOrderSet(List<WorkOrderLineItem> itemsList){
        Set<Id> workOrderID = new Set<Id>();

        for(WorkOrderLineItem wolI : itemsList){
            workOrderID.add(wolI.WorkOrderId);
        }

        return workOrderID;
    }
}
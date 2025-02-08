/**
 * @author Domenico Del Prete - domenico.delprete@nttdata.com
 * @date Creation 03/10/2019
 * @date Modification dd/mm/yyyy
 * @description XC_IN032_ChangeOrder_WOPlanAdaptation_U –  util class for XC_IN032_ChangeOrder_WOPlanAdaptation
 */
public without sharing class XC_IN032_ChangeOrder_WOPlanAdaptation_U {

    private static List<ServiceAppointment> getServiceAppointment(List<String> listWorkOrdersId) {
        if(!Schema.sObjectType.ServiceAppointment.isAccessible()) {
            return null;
        }

        return new List<ServiceAppointment>([SELECT Id, EarliestStartTime, DueDate, (SELECT Id FROM ServiceResources)
                                            FROM ServiceAppointment
                                            WHERE ParentRecordId IN: listWorkOrdersId AND (Status = :Label.XC_CL_Cancelled OR Status = :Label.XC_CL_CannotComplete) ORDER BY LastModifiedDate desc]);
    }

    /**
    * @description 
    * @author Del Prete Domenico - domenico.delprete@nttdata.com | 3/10/2019 
    * @param newWo 
    * @param oldWo 
    * @param listWorkOrderid 
    **/
    public static void createSA(WorkOrder newWo, WorkOrder oldWo, List<String> listWorkOrderid){
        XC_IN032_ChangeOrder_WOPlanAdaptation.WrapperWo wrapp = new XC_IN032_ChangeOrder_WOPlanAdaptation.WrapperWo ();
        List<ServiceAppointment> listServiceAppointment = getServiceAppointment(listWorkOrderid);
        if(listServiceAppointment.isEmpty()) {
            return;
        }
        ServiceAppointment oldSa = listServiceAppointment[0];
        ServiceAppointment newSa = XC_UTIL_ServiceAppointment.populateServiceAppointmentFromWorkOrder(newWo);
        newSa.FSL__Auto_Schedule__c = true;
        wrapp.newWo = newWo;
        wrapp.oldWo = oldWo;
        setDates(wrapp, newSa, oldSa);
        XC_UTIL_Sobject.insertRecord(newSa);
    }

    private static void setDates(XC_IN032_ChangeOrder_WOPlanAdaptation.WrapperWo workOrderWrapper, ServiceAppointment newSa, ServiceAppointment oldSa){
        List<WorkOrder> woList = new List<WorkOrder>([SELECT Id, XC_Country__c, WorkTypeId, XC_Product_Name__c, XC_CatalogCategory_Name__c, XC_Asset_ActivationDate__c, XC_PositionInMaintenancePlan__c, XC_MaintenanceYearFrequency__c, Country, State, City, PostalCode, Street, Latitude, Longitude, ServiceTerritoryId FROM WorkOrder WHERE Id = :workOrderWrapper.newWo.Id]);
        WorkOrder newWo = woList.get(0);
        WorkOrder oldWo = workOrderWrapper.oldWo;
        DateTime newEarliestStartTime;
        DateTime newDueDate;

        if(newWo.XC_MaintenanceYearFrequency__c == oldWo.XC_MaintenanceYearFrequency__c) {
            newEarliestStartTime = oldSa.EarliestStartTime;
            newDueDate = oldSa.DueDate;
        }else if(newWo.XC_MaintenanceYearFrequency__c > oldWo.XC_MaintenanceYearFrequency__c) {
            newEarliestStartTime = oldSa.EarliestStartTime.addYears(1);
            newDueDate = oldSa.DueDate.addYears(1);
        }else {
            if(oldSa.EarliestStartTime.addYears(-1) > Datetime.now()) {
                newEarliestStartTime = oldSa.EarliestStartTime.addYears(-1);
                newDueDate = oldSa.DueDate.addYears(-1);
            }else {
                Map<Id, XC_UTIL_ServiceAppointment.WrapperMaintenanceDates> mapManteinanceDatesForProduct = XC_UTIL_ServiceAppointment.getManteinanceDatesForProduct(new List<WorkOrder> {newWo});
                newEarliestStartTime = Datetime.now().addDays(15);
                newDueDate = mapManteinanceDatesForProduct.containsKey(newWo.Id) ? newWo.XC_Asset_ActivationDate__c.addYears(1).addDays(mapManteinanceDatesForProduct.get(newWo.Id).NumberDaysDueDateMaintenance) : newWo.XC_Asset_ActivationDate__c.addYears(1);
                newDueDate = newDueDate.addHours(12);
            }
        }

        newSa.EarliestStartTime = newEarliestStartTime;
        newSa.DueDate = newDueDate;
    }

    /**
    * @description 
    * @author Del Prete Domenico | 7/10/2019 
    * @param listAsset 
    * @return Boolean 
    **/
    public static Boolean checkWorkOrders(List<Asset> listAsset){
        Boolean found = false;
        for(Asset asset : listAsset){
            for(WorkOrder wo : asset.WorkOrders){
                found = true;
            }
        }
        return found;
    }
}
/**
* @author Federico Amici - federico.amici1@nttdata.com
* @date Creation 17/06/2019
* @date Modification:
* @description XC_TR_ServiceAppointment_U_OptySubSt_D - DAO for XC_TR_ServiceAppointment_U_OptySubSt class
*/
public without sharing class XC_TR_ServiceAppointment_U_OptySubSt_D {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 17/06/2019
    * @param listOpportunityIds list of opportunity Ids to retrieve
    * @description retrieves the opportunity 
    * @return the opportunity list retrieved
    */
    public static Map<Id, Opportunity> getOpportunityByIdList(List<String> listOpportunityIds) {

        Map<Id, Opportunity> mapOpportunity =
            new Map<Id, Opportunity>([SELECT Id, XC_Substatus__c, XC_CommercialVisitRequired__c
                                       FROM Opportunity
                                       WHERE Id IN :listOpportunityIds]);
        return mapOpportunity;

    }

    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 17/06/2019
    * @param listIds list of sa Ids to retrieve
    * @description retrieves the Service Appointments
    * @return the Service Appointment list retrieved
    */
    public static List<ServiceAppointment> getSAWithWO(List<Id> listIds) {
        Map<Id, ServiceAppointment> mapSA =
            new Map<Id, ServiceAppointment>([SELECT Id, ParentRecordId, ParentRecordType
                                            FROM ServiceAppointment
                                            WHERE Id IN :listIds]);
        return mapSA.values();
    }

    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @date 17/06/2019
    * @param listIds list of wo Ids to retrieve
    * @description retrieves the wo
    * @return the wo map
    */
    public static Map<Id, WorkOrder> getOppFromWO(List<String> listIds) {
        Map<Id, WorkOrder> mapWorkOrder =
            new Map<Id, WorkOrder>([SELECT Id, XC_Opportunity__c
                                            FROM WorkOrder
                                            WHERE Id IN :listIds AND
                                                XC_Opportunity__c != '']);
        return mapWorkOrder;
    }
}
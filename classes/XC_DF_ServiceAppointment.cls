/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 06/05/2019
* @description XC_DF_ServiceAppointment – Data Factory for ServiceAppointment
*/
@isTest
public class XC_DF_ServiceAppointment {
    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Opportunity
     * @param  woList List<WorkOrder> 
     * @return List<ServiceAppointment> to insert 
    */ 
    public static List<ServiceAppointment> createServiceAppointment(List<WorkOrder> woList) {
        //Create Service Appointment list
        List<ServiceAppointment> listServiceAppointment = new List<ServiceAppointment>();
        for (Integer i=0; i < woList.size(); i++){
            ServiceAppointment serviceAppointmentToInsert = new ServiceAppointment();
            serviceAppointmentToInsert.Status = 'None';
            serviceAppointmentToInsert.ParentRecordId = woList.get(i).Id;
            serviceAppointmentToInsert.EarliestStartTime = (System.now()).addHours(2);
            serviceAppointmentToInsert.DueDate = (System.now()).addHours(4);  
            listServiceAppointment.add(serviceAppointmentToInsert);
        }
        return listServiceAppointment;
    }

    /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @modify Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to create N Opportunity
     * @param  n Integer
     * @param workTypeName - String
     * @return List<ServiceAppointment> to insert 
    */ 
    public static List<ServiceAppointment> createServiceAppointment(Integer n, String workTypeName) {
        //Create Service Appointment list
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(n, workTypeName);
        insert woList;
        //List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(n, true);
       // insert oppList;
        List<ServiceAppointment> listServiceAppointment = new List<ServiceAppointment>();
        for (Integer i=0; i < n; i++){
            ServiceAppointment serviceAppointmentToInsert = new ServiceAppointment();
          //  serviceAppointmentToInsert.ContactId = oppList[0].XC_Contact__c; 
          //  serviceAppointmentToInsert.Opportunity__c = oppList[0].Id;
            serviceAppointmentToInsert.Status = 'None';
            serviceAppointmentToInsert.ParentRecordId = woList[i].Id;
            serviceAppointmentToInsert.EarliestStartTime = (System.now()).addHours(2);
            serviceAppointmentToInsert.DueDate = (System.now()).addHours(4);  

            serviceAppointmentToInsert.Duration = 1;
            serviceAppointmentToInsert.DurationType = 'Hours';
          
            listServiceAppointment.add(serviceAppointmentToInsert);
        }
        return listServiceAppointment;
    }

     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @modify Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to create N Opportunity
     * @param  n Integer
     * @return List<ServiceAppointment> to insert 
    */ 
    public static List<ServiceAppointment> createServiceAppointment(Integer n) {
        return createServiceAppointment(n, Label.XC_CL_CommercialVisit);
    }

}
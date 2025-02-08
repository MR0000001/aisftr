/**
* @author Valeria Martino - valeria.martino@nttdata.com
* @date Creation 21/06/2019 
* @description XC_TR_ServiceAppointment_U_Opty_TEST – Test class 
*/

@isTest
public class XC_TR_ServiceAppointment_U_Opty_TEST {
    
    @TestSetup
    	static void setup(){
        OneOrg__c org            = new OneOrg__c(); 
        org.Name                 = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org; 
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;    
    } 
    
    @isTest
    static void onServiceAppointmentOpty(){
        
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1);
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        insert opps;
  		listServiceAppointment[0].Opportunity__c=opps[0].id;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        listServiceAppointment[0].ParentRecordId=woList[0].id;
        insert listServiceAppointment;
        List<WorkOrder> oppsT = [SELECT Id, XC_Opportunity__c   FROM WorkOrder   WHERE Id=:listServiceAppointment[0].ParentRecordId];
        oppsT[0].XC_Opportunity__c=opps[0].id;
        System.debug('oppsT:'+ oppsT);
        update oppsT;
        
        Test.startTest();
        listServiceAppointment[0].Status= 'Scheduled';
        update listServiceAppointment;
        listServiceAppointment[0].Status= 'Dispatched';
        update listServiceAppointment;
        listServiceAppointment[0].Status= 'In Progress';
        update listServiceAppointment; 
        Test.stopTest();
        
        System.assert(listServiceAppointment != null);
    }

    @isTest
    static void onServiceAppointmentOptyDAO(){
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1);
        List<Opportunity> opps = XC_DF_Opportunity.createOpportunity(1, false) ;
        insert opps;
        listServiceAppointment[0].Opportunity__c=opps[0].id;
        insert listServiceAppointment;
        List<String> listIds=new List<String>();
        List<Id> listIdsServiceAppointment=new List<String>();
        for(Opportunity i: opps) {        
            listIds.add(i.id);            
        }
        for(ServiceAppointment i: listServiceAppointment) {           
            listIdsServiceAppointment.add(i.id);          
        }
        
        Test.startTest();
        XC_TR_ServiceAppointment_U_OptySubSt.getOpportunityIds(listServiceAppointment);
        XC_TR_ServiceAppointment_U_OptySubSt_D.getOpportunityByIdList(listIds);
        XC_TR_ServiceAppointment_U_OptySubSt_D.getSAWithWO(listIdsServiceAppointment);
        Test.stopTest();
    }
    
    @isTest
    static void createCustIntList(){
        
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1);
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList;
        Map<Id, List<ServiceAppointment>> mapSApp = new Map<Id, List<ServiceAppointment>>();
        Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>();
        mapSApp.put(ord.id, listServiceAppointment);
        mapWO.put(ord.id, woList[0]);
        XC_TR_ServiceApp_U_CreateCustomInter.createCustomInterList(ord.id, mapSApp, mapWO);
       
    }
        
}
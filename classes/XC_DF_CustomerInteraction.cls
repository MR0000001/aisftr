/**
* @author Federica Tavera federica.tavera@nttdata.com 
* @date Creation 16/05/2019
* @description XC_DF_CustomerInteraction – Data Factory for Customer Interaction
*/
@IsTest
public class XC_DF_CustomerInteraction {
    
     /** 
     * @author Federica Tavera federica.tavera@nttdata.com
     * @description Method to create N Customer Interaction
     * @return List<XC_Customer_Interaction__c>
     **/
    
    public static List<XC_Customer_Interaction__c> createCustomerInteraction(integer n){
        
        //Create a Lead
        Lead l = XC_DF_Lead.createCondominiumLead();
        insert l;
        
        //Create a list of Residential Account
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        
        //Create a list of Residential Contact
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        
        //Create a list of Address
        List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
        insert addList;
        
        //Create an Opportunity
        List<Opportunity> oList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oList;
        
        //Create a WorkTYpe
        /*WorkType wt = XC_DF_WorkType.createWorkType('Commercial Visit');
        insert wt;*/
        
        //Create a Work Order
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        insert woList;
        
        //Create a list of Service Appointment
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
     
        //Create n Customer Interaction
        List<XC_Customer_Interaction__c> ciList = new list<XC_Customer_Interaction__c>();
        for(Integer i = 0; i<n; i++){
            XC_Customer_Interaction__c c = new XC_Customer_Interaction__c();
            c.Name = 'Test Ci' + ' ' + i;
            c.XC_OpportunityId__c = oList[0].Id;
            c.XC_ContactId__c = oList[0].XC_Contact__c;
            c.XC_AccountId__c = oList[0].AccountId;
            c.XC_Communication_Type__c = 'Lead_Welcome_Email';
            c.XC_ServiceAppointmentId__c = saList[0].Id;
            c.XC_WorkOrderId__c = woList[0].Id;
            ciList.add(c);
        }
        return ciList;
    }
}
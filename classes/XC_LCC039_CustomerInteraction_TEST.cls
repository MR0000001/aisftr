/**
* @author Federica Tavera federica.tavera@nttdata.com 
* @date Creation 16/05/2019 
* @description XC_LCC039_CustomerInteraction_TEST – Test class for XC_LCC039_CustomerInteraction, XC_LCC039_CustomerInteraction_U
*/

@isTest
private class XC_LCC039_CustomerInteraction_TEST {
    
    static testMethod void retrieveData() {
       
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert woList;
        
      	List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
         Test.startTest();
        List<XC_Customer_Interaction__c> ciList = XC_DF_CustomerInteraction.createCustomerInteraction(10);
        insert ciList;
        
       /*ciList[0].XC_Communication_Type__c = 'ServiceAppointment_NotCompleted';
        ciList[0].XC_SkipCommunication__c = false;
        update ciList[0];
        System.debug('CUST INT ' + ciList[0]);
        */
       
        map<String,Object> mapToTest = new map<String,Object>();
        //mapToTest.put('customerType', ciList[0].XC_Communication_Type__c);
        mapToTest.put('serviceAppointmentId', saList[0].Id);      
        //mapToTest.put('skipComunication',ciList[0].XC_SkipCommunication__c);
        System.debug('MAPPA ' + mapToTest);
        
        String wrapper = JSON.serialize(mapToTest);
        
       
        XC_LCC039_CustomerInteraction.checkPossibilityToReSchedule(saList[0].Id);
        XC_LCC039_CustomerInteraction.newEmailForCustomer(wrapper);
        XC_LCC039_CustomerInteraction_U.validateMobilePhone('6567234');
        Test.stopTest();
    }

    @isTest
    public static void checkLeadProductCategory_Test(){
             
        Lead l =  XC_DF_Lead.createCondominiumLead();
        insert l;
        Test.startTest();
        XC_LCC039_CustomerInteraction.checkLeadProductCategory(l.Id);
        Test.stopTest();
    }
    
    static testMethod void opportunityProductCategoryEmailTest() {
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
       
        map<String,Object> mapToTest = new map<String,Object>();

        mapToTest.put('customerType', 'Opportunity_Product_Category_Email');
        mapToTest.put('opportunityId', oppList[0].Id);

        System.debug('MAPPA ' + mapToTest);
        
        String wrapper = JSON.serialize(mapToTest);
        
        Test.startTest();
        XC_LCC039_CustomerInteraction.newEmailForCustomer(wrapper);
        Test.stopTest();
    }
    
    static testMethod void opportunityQuoteCreatedTest() {
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
       
        map<String,Object> mapToTest = new map<String,Object>();

        mapToTest.put('customerType', 'Opportunity_QuoteCreated');
        mapToTest.put('opportunityId', oppList[0].Id);

        System.debug('MAPPA ' + mapToTest);
        
        String wrapper = JSON.serialize(mapToTest);
        
        Test.startTest();
        XC_LCC039_CustomerInteraction.newEmailForCustomer(wrapper);
        XC_LCC039_CustomerInteraction.checkContactEmailAndNotification(oppList[0].Id, '{}');
        Test.stopTest();
    }
    
    static testMethod void validatePhoneTest() {
        
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        
        Test.startTest();
        XC_LCC039_CustomerInteraction_U.populateCustomerInteractionAccount(new Map<String, Object>{'leadId' => leadList[0].Id, 'accountId' => accList[0].Id}, new XC_Customer_Interaction__c());
        Test.stopTest();
    }
    
    static testMethod void checkForOrderTest() {
        	
        NE__Order__c ord = XC_DF_Order.createOrder('inOrder');
        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        XC_LCC039_CustomerInteraction_U.CheckValuesWrapper checkWrapper = new XC_LCC039_CustomerInteraction_U.CheckValuesWrapper();
        checkWrapper.values = new Map<String, Object>{'orderId' => ord.Id};
        checkWrapper.customerInteraction = new XC_Customer_Interaction__c();
        checkWrapper.rw = new XC_UTIL_ResultWrapper();
            
        Test.startTest();
        XC_LCC039_CustomerInteraction_U.checkForOrder(checkWrapper);
        Test.stopTest();
    }
    
    static testMethod void checkForWorkorderTest() {
        	
       List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        insert woList;

        XC_LCC039_CustomerInteraction_U.CheckValuesWrapper checkWrapper = new XC_LCC039_CustomerInteraction_U.CheckValuesWrapper();
        checkWrapper.values = new Map<String, Object>{'workorderId' => woList[0].Id};
        checkWrapper.customerInteraction = new XC_Customer_Interaction__c();
        checkWrapper.rw = new XC_UTIL_ResultWrapper();
            
        Test.startTest();
        XC_LCC039_CustomerInteraction_U.checkForWorkOrder(checkWrapper);
        Test.stopTest();
    }

    
       /* static testMethod void retrieveData2() {
        
        Lead l =  XC_DF_Lead.createCondominiumLead();
        insert l;
                
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert woList;
        
      	List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        
        List<XC_Customer_Interaction__c> ciList = XC_DF_CustomerInteraction.createCustomerInteraction(10);
        insert ciList;
        
       /*ciList[0].XC_Communication_Type__c = 'ServiceAppointment_NotCompleted';
        ciList[0].XC_SkipCommunication__c = false;
        update ciList[0];
        System.debug('CUST INT ' + ciList[0]);
        
       
        map<String,Object> mapToTest = new map<String,Object>();
        //mapToTest.put('customerType', ciList[0].XC_Communication_Type__c);
        mapToTest.put('workorderId', woList[0].Id);
        //mapToTest.put('skipComunication',ciList[0].XC_SkipCommunication__c);
        System.debug('MAPPA ' + mapToTest);
        
        String wrapper = JSON.serialize(mapToTest);
        
        Test.startTest();
        XC_LCC039_CustomerInteraction.newEmailForCustomer(wrapper);
        Test.stopTest();
    }*/
}
/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceApp_U_CreateCI_TEST – Test Class for XC_TR_ServiceApp_U_CreateCustomInter
*/ 

@isTest
public class XC_TR_ServiceApp_U_CreateCI_TEST {

    @TestSetup
    static void insertCustomSetting (){
        
       // OneOrg__c org = new OneOrg__c();
       // org.Name = 'OneOrg (User)';
       // org.XC_Spain_Triggers__c=true;
        //org.XC_Spain_ValidationRules__c =  true;
       // insert org;
        insert XC_DF_OneOrg.createOneOrg('Spain');
       /*  insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        
        List<Contact> contactList = XC_DF_Contact.createPartnerContacts(accList);
        insert contactList;        
        User user = XC_DF_User.createCommunityUser(contactList.get(0));
        String name = '%' + accList.get(0).Name + '%';
        user.UserRoleId = [Select Id from UserRole where Name like :name LIMIT 1].id;
		insert user;
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = user.Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;*/
        
    }

    static testMethod void onUpdate(){
        
        insert XC_DF_ServiceAppointment.createServiceAppointment(1);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        User portalAccountOwner  = [Select id from User Limit 1];
        Test.startTest();
                for(ServiceAppointment sa : saList){
                    sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
                    saToUpdate.add(sa);
                }
                update saToUpdate;
                List<ServiceAppointment> listSaUpdated = [SELECT Id FROM ServiceAppointment];
                    System.assertEquals(1, listSaUpdated.size());
        
        Test.stopTest();
    }  

    static testMethod void woWithConfIntem(){
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account where RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        orderQueried.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderQueried.RecordType.DeveloperName = Label.XC_CL_Configuration_Order;
        update orderQueried;
        NE__Order__c orderQueriedAfterUpdate = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderQueriedAfterUpdate-->' +orderQueriedAfterUpdate);
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueriedAfterUpdate.Id];
        System.debug('@@orderItems-->'+ orderItemInserted);
        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c();
        provStep.XC_Configuration_Item__c = orderItemInserted[0].Id;
        provStep.XC_Flow_API_Name__c = Label.XC_CL_Provisioning_DeliveryInstallation;
        insert provStep;
        Test.startTest();
        System.debug('@@@provStepInserted' + provStep);
        woList[0].XC_Provisioning_Step__c = provStep.Id;
        woList[0].XC_Configuration__c = orderQueriedAfterUpdate.Id;
        woList[0].AccountId = accList[0].Id;
        insert woList[0];
        System.debug('@@@woList-->' + woList[0]);
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        Map<WorkOrder,List<ServiceAppointment>> mapToUpdate = new Map<WorkOrder,List<ServiceAppointment>>();
        mapToUpdate.put(woList[0], saList);
        
        for(ServiceAppointment sa : mapToUpdate.get(woList[0])){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            saToUpdate.add(sa);
        }
        update saToUpdate;
        List<ServiceAppointment> listSaUpdated = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated.size());
        Test.stopTest();
    }
    
    
    static testMethod void woWithConfIntem2(){
        Id recTypeOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get(Label.XC_CL_Configuration_Order).getRecordTypeId();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> contList =  XC_DF_Contact.createResidentialContacts(accList);
        insert contList;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        orderInserted.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        orderInserted.RecordTypeId = recTypeOrderId;
        update orderInserted;
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        System.debug('@@orderItems-->'+ orderItemInserted);
        XC_Provisioning_Step__c provStep = new XC_Provisioning_Step__c();
        provStep.XC_Configuration_Item__c = orderItemInserted[0].Id;
        provStep.XC_Flow_API_Name__c = Label.XC_CL_Provisioning_DeliveryInstallation;
        insert provStep;
        Test.startTest();
        System.debug('@@@provStepInserted' + provStep);
        woList[0].XC_Provisioning_Step__c = provStep.Id;
        woList[0].XC_Configuration__c = orderInserted.Id;
        woList[0].AccountId = accList[0].Id;
        woList[0].ContactId = contList[0].Id;
        insert woList[0];
        
        System.debug('@@@woList-->' + woList[0]);
        List<ServiceAppointment> saBefore = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToInsert = new List<ServiceAppointment>();
        for (ServiceAppointment sa : saBefore){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.XC_Reason_Cannot_Complete__c = 'Customer not presence';
            saToInsert.add(sa);
        }
        insert saToInsert;
        
        //insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        List<ServiceAppointment> saToUpdate1 = new List<ServiceAppointment>();
        //List<ServiceAppointment> saList1 = [SELECT Id, ParentRecordId FROM ServiceAppointment];
        /*for (ServiceAppointment sa : saToInsert){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.XC_Reason_Cannot_Complete__c = 'Customer not presence';
            //sa.ParentRecordId = woList[0].Id;
            saToUpdate1.add(sa);
        }
        update saToUpdate1;*/
        
        woList[0].Status = 'On Hold';
        woList[0].EndDate = null;
        update woList;
        System.debug('@@@ServiceAppointmet Canceled-->' +saToUpdate1);
        insert XC_DF_ServiceAppointment.createServiceAppointment(woList);
        System.debug('@@@app-->' + woList[0].ServiceAppointments);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();    
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>([
            SELECT Id, 
            (
                SELECT Id, ActualStartTime, ActualEndTime, EarliestStartTime, DueDate
                FROM ServiceAppointments 
                
            ) 
            FROM WorkOrder WHERE Id =: woList[0].Id]);
        System.debug('@@@mapWorkOrder-->' + mapWorkOrder);    
        /*for(ServiceAppointment sa :saToInsert){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            //sa.ParentRecordId = woList[0].Id;
            saToUpdate.add(sa);
        }
        update saToUpdate;*/
        Test.stopTest();
    	}
    
      	static testMethod void serviceAppointmentWithWorkOrder(){
        
        List<WorkOrder> woList= XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        WorkOrder wo = woList[0];
       	insert wo;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        ServiceAppointment sa = saList[0];
        sa.ParentRecordId=wo.Id;
        insert sa;
       
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        Test.startTest();
        for(ServiceAppointment sap : saList){
            sap.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            saToUpdate.add(sap);
        }
        update saToUpdate;
        List<ServiceAppointment> listSaUpdated = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated.size());
        Test.stopTest();
    }  
    
    static testMethod void serviceAppointmentWithWorkOrder2(){
         
        List<WorkOrder> woList= XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        WorkOrder wo = woList[0];
       	insert wo;
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(2);
        ServiceAppointment sa = saList[0];
        sa.ParentRecordId=wo.Id;
        sa.Status ='';
        insert sa;
        Test.startTest();
        sa.Status = 'Cannot Complete';
        sa.XC_Reason_Cannot_Complete__c = 'Customer not presence'; 
        update sa;
       	ServiceAppointment sa1 = saList[1];
        sa1.ParentRecordId=wo.Id;
        insert sa1;
        sa1.Status = 'Scheduled';
        update sa1;       
        List<ServiceAppointment> listSaUpdated = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(2, listSaUpdated.size());
        Test.stopTest();
    }  
    static testMethod void createCustomInterList(){
      Map<Id, WorkOrder> mapOrderIdWorkOrder=new Map<Id, WorkOrder>();
        Map<Id, List<ServiceAppointment> > mapOrderIdListServiceAppointment= new Map<Id, List<ServiceAppointment> >();
        NE__Order__c order=XC_DF_Order.createOrder('Order');
        List<Contact> concContact=[select id, Name,XC_Preferredlanguageofcontact__c,Email 
                                       from contact
                                  where id=:order.NE__OptyId__c];
        List<WorkOrder> woList= XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        WorkOrder wo = woList[0];
        wo.XC_Configuration__c=order.id;
        mapOrderIdWorkOrder.put(order.id,wo);
       	insert wo;
        test.startTest();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        ServiceAppointment sa = saList[0];
        sa.ParentRecordId=wo.Id;
        sa.Status='New';
        insert saList;
        mapOrderIdListServiceAppointment.PUT(order.id,saList); 
        XC_TR_ServiceApp_U_CreateCustomInter.createCustomInterList(order.Id,mapOrderIdListServiceAppointment,mapOrderIdWorkOrder);
        test.stopTest();
    }
        static testMethod void createCustomInterList2(){
      Map<Id, WorkOrder> mapOrderIdWorkOrder=new Map<Id, WorkOrder>();
        Map<Id, List<ServiceAppointment> > mapOrderIdListServiceAppointment= new Map<Id, List<ServiceAppointment> >();
        NE__Order__c order=XC_DF_Order.createOrder('Order');
        List<Contact> concContact=[select id, Name,XC_Preferredlanguageofcontact__c,Email 
                                       from contact
                                  where id=:order.NE__OptyId__c];
        List<WorkOrder> woList= XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        WorkOrder wo = woList[0];
        wo.XC_Configuration__c=order.id;
        mapOrderIdWorkOrder.put(order.id,wo);
       	insert wo;
        test.startTest();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1);
        ServiceAppointment sa = saList[0];
        sa.ParentRecordId=wo.Id;
       // sa.Status='New';
        insert saList;
        mapOrderIdListServiceAppointment.PUT(order.id,saList);
        XC_TR_ServiceApp_U_CreateCustomInter.createCustomInterList(order.Id,mapOrderIdListServiceAppointment,mapOrderIdWorkOrder);
        test.stopTest();
    }
   /* public static testMethod void notificationForInstallation(){
        List<String> orderIdList=new list <string>();
        Map<Id, WorkOrder> mapOrderIdWorkOrder=new Map<Id, WorkOrder>();
        Map<Id, List<ServiceAppointment> > mapOrderIdListServiceAppointment= new Map<Id, List<ServiceAppointment> >();
        NE__Order__c order=XC_DF_Order.createOrder('Order');
        List<Contact> concContact=[select id, Name,XC_Preferredlanguageofcontact__c,Email 
                                       from contact
                                  where id=:order.NE__OptyId__c];
        List<WorkOrder> woList= XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        WorkOrder wo = woList[0];
        wo.XC_Configuration__c=order.id;
        mapOrderIdWorkOrder.put(order.id,wo);
       	insert wo;
        orderIdList.add(wo.id);
        test.startTest();
        XC_TR_ServiceApp_U_CreateCustomInter.notificationForInstallation(orderIdList);
        test.stopTest();
    }*/
    /*static testMethod void createCustomInterList(){
        
        NE__Order__c ord = XC_DF_Order.createOrder('Order');
        //insert ord;
        
        List<ServiceAppointment>  servApp = XC_DF_ServiceAppointment.createServiceAppointment(3);
        insert servApp;
        Map<Id, List<ServiceAppointment>> mapServApp = new Map<Id, List<ServiceAppointment>>();
        mapServApp.put(ord.id, servApp);
        
        Map<Id, WorkOrder> woMap  = new Map<Id, WorkOrder>();
        list<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        woMap.put(ord.id, wo.get(0));
        
        
        Test.startTest();
        	XC_TR_ServiceApp_U_CreateCustomInter.createCustomInterList(ord.id, mapServApp, woMap);
        Test.stopTest();
    }*/
   
}
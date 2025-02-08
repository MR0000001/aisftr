/**
* @author Roberta Porrega - roberta.porrega@nttdata.com
* @date Creation 03/06/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ServiApp_CreateCustomInter_TEST – Test Class 
*/ 

@isTest
public class XC_UTIL_ServiApp_CreateCustomInter_TEST {
    @TestSetup
    static void insertCustomSetting (){
        Test.startTest();
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        //org.XC_Spain_ValidationRules__c =  true;
        insert org;
        /*List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = usersList[1].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;*/
        Test.stopTest();
    }
    
    @isTest
    static void onCreate(){
        Test.startTest();
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        wo[0].XC_Opportunity__c = oppList[0].Id;
        wo[0].ContactId = oppList[0].XC_Contact__c;
        insert wo;
        
        wo[0].Status = 'Assigned';
        wo[0].XC_StatusReason__c = 'Assigned to the technician';
        update wo;
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled; 
            sa.XC_StatusReason__c = 'Assigned to the technician';
            sa.ParentRecordId = wo[0].Id;
        }
        insert saList;

        /*saList[0].Status = 'In progress';
        update saList;

        wo[0].Status = Label.XC_CL_ServiceAppointment_OnHold;
        wo[0].XC_StatusReason__c = Label.XC_CL_StatusReason_Thecustomerrequeststorescheduledthevisit;
        update wo;
        
        
        saList[0].Status = Label.XC_CL_ServiceAppointment_CannotComplete;
        saList[0].XC_Reason_Cannot_Complete__c = 'etc';
        saList[0].XC_StatusReason__c = Label.XC_CL_StatusReason_Customerrefusesthevisit;
        update saList;*/
        /*List<ServiceAppointment> listSaUpdated = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());*/
        Test.stopTest();
    }  

    @IsTest
    static void create1(){
        
        Test.startTest();
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        wo[0].XC_Opportunity__c = oppList[0].Id;
        insert wo;
        
        wo[0].Status = 'Assigned';
        wo[0].XC_StatusReason__c = 'Assigned to the technician';
        update wo;
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled; 
            sa.XC_StatusReason__c = 'Assigned to the technician';
            sa.ParentRecordId = wo[0].Id;
        }
        insert saList;
        Test.stopTest();
        
    }
    
    /*@isTest
    static void onUpdate1(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation);
        wo[0].XC_Opportunity__c = oppList[0].Id;
        wo[0].ContactId = oppList[0].XC_Contact__c;
        insert wo;
        
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
            sa.ParentRecordId = wo[0].Id;
        }
        insert saList;
        
        List<ServiceAppointment> listSaUpdated = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        Test.startTest();
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    }  
    
    @isTest
    static void onUpdate2(){
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        Contact cnt = [SELECT Id FROM Contact WHERE Id =: oppList[0].XC_Contact__c];
        cnt.Email = 'test@testfortest.com';
        update cnt;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation);
        wo[0].XC_Opportunity__c = oppList[0].Id;
        wo[0].ContactId = oppList[0].XC_Contact__c;
        insert wo;
        
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Canceled;
            sa.ParentRecordId = wo[0].Id;
        }
        insert saList;
        
        List<ServiceAppointment> listSaUpdated = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        Test.startTest();
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    }  
    
    @isTest
    static void onUpdate3(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation);
        wo[0].XC_Opportunity__c = oppList[0].Id;
        //wo[0].ContactId = oppList[0].XC_Contact__c;
        insert wo;
        Test.startTest();
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        
        for(ServiceAppointment sa : saList){
            sa.Status = '';
            sa.ParentRecordId = wo[0].Id;
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2);
        }
        insert saList;
        
        List<ServiceAppointment> listSaToUpdate = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        List<ServiceAppointment> listSaUpdated = new List<ServiceAppointment>();
        for(ServiceAppointment sa : listSaToUpdate){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.XC_Reason_Cannot_Complete__c = 'Technical issue';
            listSaUpdated.add(sa);
        }
        update listSaUpdated;
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;
        
        AssignedResource ar = new AssignedResource();
        
        ar.ServiceResourceId = sr[0].Id; 
        ar.ServiceAppointmentId = listSaUpdated[0].id;
        insert ar; 
        
        
        
        List<AssignedResource> assList = new List<AssignedResource>();
        assList.add(ar);        
        Map<Id, List<AssignedResource>> mapAssRes = new Map<Id, List<AssignedResource>>(); 
        mapAssRes.put(listSaUpdated[0].id, assList);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        checkWr.mapAssRes = mapAssRes;
        
        
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    } 
    
    @isTest
    static void onUpdate3_2(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation);
        //wo[0].XC_Opportunity__c = oppList[0].Id;
        wo[0].ContactId = oppList[0].XC_Contact__c;
        insert wo;
        
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        
        for(ServiceAppointment sa : saList){
            sa.Status = '';
            sa.ParentRecordId = wo[0].Id;
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2);
        }
        insert saList;
        
        List<ServiceAppointment> listSaToUpdate = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        List<ServiceAppointment> listSaUpdated = new List<ServiceAppointment>();
        for(ServiceAppointment sa : listSaToUpdate){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.XC_Reason_Cannot_Complete__c = 'Technical issue';
            listSaUpdated.add(sa);
        }
        update listSaUpdated;
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        Test.startTest();
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResource> srInserted = [SELECT Id, RelatedRecordId FROM ServiceResource];
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = srInserted[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        insert srtmemb;
        
        AssignedResource ar = new AssignedResource();
        
        ar.ServiceResourceId = srInserted[0].Id; 
        ar.ServiceAppointmentId = listSaUpdated[0].id;
        insert ar; 
        AssignedResource assResInserted = [SELECT Id, ServiceResourceId, ServiceAppointmentId, ServiceResource.RelatedRecordId, ServiceResource.RelatedRecord.Email FROM AssignedResource];
        User user = [SELECT Id, Email FROM User WHERE Id =: srInserted[0].RelatedRecordId];  
        user.Email = 'test@salessforce.com';
        update user;
        List<AssignedResource> assList = [SELECT Id, ServiceResourceId, ServiceAppointmentId, ServiceResource.RelatedRecordId, ServiceResource.RelatedRecord.Email, ServiceResource.RelatedRecord.ContactId , ServiceResource.RelatedRecord.Contact.Name FROM AssignedResource];     
        Map<Id, List<AssignedResource>> mapAssRes = new Map<Id, List<AssignedResource>>(); 
        mapAssRes.put(listSaUpdated[0].id, assList);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        checkWr.mapAssRes = mapAssRes;
        
        
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    } 
    
    @isTest
    static void onUpdate4(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation);
        wo[0].XC_Opportunity__c = oppList[0].Id;
        wo[0].ContactId = null;
        insert wo;
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.ParentRecordId = wo[0].Id;
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2); 
        }
        insert saList;
        
        List<ServiceAppointment> listSaUpdated = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        //srtmemb.TerritoryType = 'Primary';
        insert srtmemb;
        
        AssignedResource ar = new AssignedResource();
        
        ar.ServiceResourceId = sr[0].Id; 
        ar.ServiceAppointmentId = listSaUpdated[0].id;
        insert ar; 
        
        
        
        List<AssignedResource> assList = new List<AssignedResource>();
        assList.add(ar);        
        Map<Id, List<AssignedResource>> mapAssRes = new Map<Id, List<AssignedResource>>(); 
        mapAssRes.put(listSaUpdated[0].id, assList);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        checkWr.mapAssRes = mapAssRes;
        Test.startTest();
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    }
    @isTest
    static void onUpdate5(){
        List<Account> accList =  XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        System.debug('@@@accList-->' +accList);
        List<Contact> contList = XC_DF_Contact.createCondominiumContacts(accList);
        insert contList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accList);
        insert address;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunityWithVisit(contList,address[0]) ;
        insert oppList;
        System.debug('@@@oppList-->' +oppList[0].XC_Contact__r.Email);
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        wo[0].ContactId = contList[0].Id;
        insert wo;  
     //   wo[0].Contact.Email = contList[0].Email;
        List<Contact> cList = [SELECT ID ,Email FROM CONTACT WHERE ID =: wo[0].ContactId];
        cList[0].Email = 'test@enelx.it';
        update cList[0];  
        System.debug(LoggingLevel.FINEST,'@@@wo-->' +wo); 
        
        
        
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Scheduled; 
            sa.ParentRecordId = wo[0].Id;
        }
        insert saList;
        System.debug('@@@saList-->' +saList);
        List<ServiceAppointment> listSaUpdated = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        System.debug('@@@mapWorkOrder-->' +mapWorkOrder);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        System.debug('@@@checkWr-->' +checkWr);
        Test.startTest();
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    } 
    
    @isTest
    static void onUpdate6(){
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1,true) ;
        insert oppList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation);
        wo[0].XC_Opportunity__c = oppList[0].Id;
        wo[0].ContactId =oppList[0].XC_Contact__c;
        insert wo;
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.ParentRecordId = wo[0].Id;
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2); 
        }
        insert saList;
        
        List<ServiceAppointment> listSaUpdated = [SELECT Id, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, Status, ParentRecordId, ParentRecord.Type, XC_Check_Final_Status__c, WorkType.Name, XC_WorkTypeCategory__c, XC_StatusReason__c FROM ServiceAppointment];
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>(); 
        mapWorkOrder.put(wo[0].Id , wo[0]);
        
        OperatingHours opH = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar'];
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: sr[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = srt[0].Id;
        srtmemb.ServiceResourceId = sr[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now();
        srtmemb.OperatingHoursId = opH.Id;
        //srtmemb.TerritoryType = 'Primary';
        insert srtmemb;
        
        AssignedResource ar = new AssignedResource();
        
        ar.ServiceResourceId = sr[0].Id; 
        ar.ServiceAppointmentId = listSaUpdated[0].id;
        insert ar; 
        
        
        
        List<AssignedResource> assList = new List<AssignedResource>();
        assList.add(ar);        
        Map<Id, List<AssignedResource>> mapAssRes = new Map<Id, List<AssignedResource>>(); 
        mapAssRes.put(listSaUpdated[0].id, assList);
        XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper checkWr = new XC_UTIL_ServiceApp_CreateCustomInter.CheckNotifyWrapper();
        checkWr.serApp = listSaUpdated[0];
        checkWr.mapWorkOrder = mapWorkOrder;
        checkWr.mapAssRes = mapAssRes;
        Test.startTest();
        XC_UTIL_ServiceApp_CreateCustomInter.checkNotify(checkWr, true);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    }
    
    @isTest
    static void onUpdate7(){
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Installation);
        insert wo;
        List<ServiceAppointment> saList =  XC_DF_ServiceAppointment.createServiceAppointment(1); 
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
            sa.ParentRecordId = wo[0].Id;
            sa.SchedStartTime = DateTime.now();
            sa.SchedEndTime = DateTime.now().addHours(2); 
        }
        insert saList;
        Test.startTest();
        XC_UTIL_ServiceApp_CustomInterCondition.checkParent(saList[0]);
        List<ServiceAppointment> listSaUpdated1 = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, listSaUpdated1.size());
        Test.stopTest();
    }*/
    
    
    
    
}
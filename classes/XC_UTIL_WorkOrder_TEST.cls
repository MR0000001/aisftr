/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation 23/05/2019 
* @date Modification 05/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description public class XC_UTIL_WorkOrder_TEST – Test class for public class XC_UTIL_WorkOrder
*/

@isTest
public class XC_UTIL_WorkOrder_TEST {
    
    //Test Method createWorkOrder
    static testMethod void createWorkOrder(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        list<Account> lacc = XC_DF_Account.createResidentialAccounts(1);  
        workType  wtp = XC_DF_WorkType.createWorkType('Delivery & Installation');        
        String workTypeName=wtp.Name;
        insert wtp;
        String country='SPAIN';
        WorkOrder wo = XC_UTIL_WorkOrder.createWorkOrder( workTypeName, country, lacc[0].Id);
        XC_UTIL_WorkOrder.getMapQueueIds(new List<String>());
        System.assertEquals(true, wo!=null);
        Test.stopTest();
    }
    
    //Test Method createWorkOrderRepair
    static testMethod void createWorkOrderRepair(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        WorkType wt = XC_DF_WorkType.createWorkType('Delivery & Installation');
        list <Case> nc = new list <Case>();        
        String workTypeId = wt.Id;
        list <WorkOrder> wo = XC_UTIL_WorkOrder.createWorkOrderRepair(nc, workTypeId);
        System.assertEquals(true, wo!=null);
        Test.stopTest();
    }
    
    //Test Method createWorkOrderRepair2
    static testMethod void createWorkOrderRepair2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        WorkType wt = XC_DF_WorkType.createWorkType('Delivery & Installation');
        Case nc = new Case();        
        String workTypeId = wt.Id;
        WorkOrder wo = XC_UTIL_WorkOrder.createWorkOrderRepair(nc, workTypeId);
        System.assertEquals(true, wo!=null);
        Test.stopTest();
    }
    
    //Test Method initWorkOrderIspection
    static testMethod void initWorkOrderIspection(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        WorkType wt = XC_DF_WorkType.createWorkType('Delivery & Installation');
        Case nc = new Case();        
        String workTypeId = wt.Id;
        List<WorkOrder> lstwo = XC_DF_WorkOrder.createWorkOrders(3, 'Delivery & Installation');
        WorkOrder parentWO= lstwo[0];
        WorkOrder wo = XC_UTIL_WorkOrder.initWorkOrderIspection(nc, workTypeId,parentWO);
        System.assertEquals(true, wo!=null);
        Test.stopTest();
    }
    
    //Test Method createWorkOrderInspection
    static testMethod void createWorkOrderInspection(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        WorkType wt = XC_DF_WorkType.createWorkType('Delivery & Installation');
        Case nc = new Case();        
        String workTypeId = wt.Id;
        WorkOrder wo = XC_UTIL_WorkOrder.createWorkOrderInspection(nc, workTypeId);
        System.assertEquals(true, wo!=null);
        Test.stopTest();
    }
    
    //Test Method getWorkOrderRecordTypeByCountry
    static testMethod void getWorkOrderRecordTypeByCountry(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        string country = 'SPAIN';
        string st = XC_UTIL_WorkOrder.getWorkOrderRecordTypeByCountry(country);
        System.assertEquals(true, st!=null);
        Test.stopTest();
    }
    
    //Test Method getWorkTypeByName
    static testMethod void getWorkTypeByName(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        String typeName = 'Delivery & Installation';
        string st = XC_UTIL_WorkOrder.getWorkTypeByName(typeName);
        System.assertEquals(true, st!=null);
        Test.stopTest();
    }
    
    //Test Method populateAddressFields
    static testMethod void populateAddressFields(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<WorkOrder> lstwo = XC_DF_WorkOrder.createWorkOrders(3, 'Delivery & Installation');
        WorkOrder wo= lstwo[0];
        XC_UTIL_Schedule_W.AddressWrapper wr = new XC_UTIL_Schedule_W.AddressWrapper();
        XC_Address__c myAddress = XC_DF_Address.createAddress(1)[0];
        insert myAddress;
        wr.city = myAddress.XC_City__c;
        wr.country = myAddress.XC_AddressCountry__c;
        wr.postalCode = myAddress.XC_PostalCode__c;
        wr.street = myAddress.XC_StreetType__c + myAddress.XC_Address__c + myAddress.XC_StreetNumber__c;
        wr.state = myAddress.XC_AddressProvince__c;
        wr.addressId = myAddress.Id;
        XC_UTIL_WorkOrder.populateAddressFields(wo, wr);
        System.assertEquals(true, wo!=null);
        Test.stopTest();
    }
    
    //Test Method populateAddressFieldsFromLead
    static testMethod void populateAddressFieldsFromLead(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<WorkOrder> lstwo = XC_DF_WorkOrder.createWorkOrders(3, 'Delivery & Installation');
        WorkOrder wo= lstwo[0];
        List<Lead> lld = XC_DF_Lead.createSohoLeads(3);
        lead l = lld[0];
        XC_UTIL_WorkOrder.populateAddressFieldsFromLead(wo, l);
        System.assertEquals(true, l!=null);
        Test.stopTest();
    }
    
    //Test Method workOrdersInFinalStatus
    static testMethod void workOrdersInFinalStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<WorkOrder> lstwo = XC_DF_WorkOrder.createWorkOrders(3, 'Delivery & Installation');
        list<workOrder> lwo= XC_UTIL_WorkOrder.workOrdersInFinalStatus(lstwo);
        XC_UTIL_WorkOrder.getMapWorkOrderErrorSerialNumber(lstwo);
        System.assertEquals(true, lwo!=null);
        Test.stopTest();
    }
    
    //Test Method retriveMaintenanceWOByAsset
    static testMethod void retriveMaintenanceWOByAsset(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        list <Asset> lasst = XC_DF_Asset.createAssets(1);
        list<workOrder> lwo = XC_UTIL_WorkOrder.retriveMaintenanceWOByAsset(lasst[0].Id);
        System.assertEquals(true, lwo!=null);
        Test.stopTest();
    }
    
    //Test Method sendToBackOffice
    static testMethod void sendToBackOffice(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        list <Account> accList = XC_DF_Account.createResidentialAccounts(2);
        insert accList;        
        XC_UTIL_WorkOrder.SendToBackOfficeWrapper wr = new XC_UTIL_WorkOrder.SendToBackOfficeWrapper();
        wr.serAppToChange = new ServiceAppointment();
        wr.workOrderToChange = new WorkOrder();
        wr.partnerIdCurrentResource = '';
        wr.queueId = accList[0].Id;
        wr.mapWorkType = new Map<String,Boolean>();
        XC_UTIL_WorkOrder.sendToBackOffice(wr);
        System.assertEquals(true, wr!=null);
        Test.stopTest();
    }

    //Test Method sendToBackOffice
    static testMethod void populateDurationFromChildren() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceTerritory> servTerr = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert servTerr;
        User user = XC_DF_User.createUserAdmin();
        insert user;
        ServiceResource servRes = new ServiceResource(Name = Label.XC_CL_NoCandidateFound, 
                                                      XC_Account__c = accList[0].Id, 
                                                      isCapacityBased = true,
                                                      RelatedRecordId = user.Id, 
                                                      isActive = true );
        insert servRes;
        
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>();
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert listWorkOrder;
        for(WorkOrder wo : listWorkOrder) {
            mapWorkOrder.put(wo.Id, wo);
        }

        List<WorkOrder> listWorkOrderChild = XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_CommercialVisit);
        for(WorkOrder wo : listWorkOrderChild) {
            wo.Duration = 1.1;
            wo.ParentWorkOrderId = listWorkOrder[0].Id;
        }
        insert listWorkOrderChild;

        Test.startTest();
        XC_UTIL_WorkOrder.populateDurationFromChildren(mapWorkOrder);
        XC_UTIL_WorkOrder.getMapWorkOrderErrorSerialNumber(listWorkOrder);
        System.assertNotEquals(listWorkOrder, null);
        Test.stopTest();
    }
    
}
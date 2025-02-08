/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC008_LeadCallToCommodity_TEST 
*/  
@isTest
public class XC_LCC014_CreateWorkOrder_TEST {
        
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        XC_ProductCategoryOfInterest__c product = XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        product.XC_CommercialVisit__c=true;
        product.Name = 'Caldera';
        insert product;
        XC_LeadAssignmentMaster__c leadAssignment = new XC_LeadAssignmentMaster__c();
        leadAssignment.XC_OrderOfEvaluation__c = 1;
        leadAssignment.XC_ProductCategoryOfInterest__c = 'Caldera';
        leadAssignment.XC_Status__c = Label.XC_CL_WorkOrder_PendingScheduling;
        leadAssignment.XC_ChannelRequired__c = 'Yes';
        leadAssignment.XC_Channel__c  = 'Email';
        leadAssignment.XC_AssignedToCreator__c = true;
        leadAssignment.XC_Address__c = 'Yes';
        leadAssignment.XC_Email__c = 'Yes';
        leadAssignment.XC_RecordTypePick__c = '';
        insert leadAssignment;                                                
                                                     
    }
    
    @isTest
    static void hasCommercialVisitForLeadTest3(){
        XC_DF_OneOrg.createOneOrg('Spain'); 
        List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
        insert addList;
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeadsWithAddress(1);
        leadlist[0].Email = 'mimmo@gmail.com';
        leadlist[0].XC_ProductCategoryOfInterest__c= 'Caldera';
        leadlist[0].XC_DocumentCountry__c = 'Spain';
        leadlist[0].XC_Segment__c='B2C';
        leadlist[0].XC_LeadAddress__c = addList[0].Id;
        insert leadlist;
        Test.startTest();
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.hasCommercialVisitForLead(leadlist[0].id);
        System.assert(rw!=null);
        Test.stopTest();
    }   
    
    @isTest
    static void hasCommercialVisitForLeadTest3bis(){
        XC_DF_OneOrg.createOneOrg('Spain'); 
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeadsWithAddress(1);
        leadlist[0].Email = 'mimmo@gmail.com';
        leadlist[0].XC_ProductCategoryOfInterest__c= 'Caldera';
        leadlist[0].XC_DocumentCountry__c = 'Spain';
        leadlist[0].XC_Segment__c='B2C';
        insert leadlist;
        Test.startTest();
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.hasCommercialVisitForLead(leadlist[0].id);
        System.assert(rw!=null);
        Test.stopTest();
    }     

    /*
    @isTest
    static void hasCommercialVisitForLeadTest3tris(){
        List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
        insert addList;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeadsWithAddress(1);
        leadlist[0].XC_Segment__c='B2B';
        leadlist[0].XC_DocumentCountry__c='Spain';
        leadlist[0].XC_CommercialVisitRequired__c = true;
        leadlist[0].XC_ProductCategoryOfInterest__c = 'Caldera';
    
        insert leadlist;  
        XC_ProductCategoryOfInterest__c prodCat =  XC_DF_ProductCategoryOfInterest.prodCatWithoutVisitRecord();
        insert prodCat;
        leadlist[0].Status = Label.XC_CL_Lead_PendingScheduling;
        update leadlist;
    Test.startTest();
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.hasCommercialVisitForLead(leadlist[0].id);
        System.assert(rw!=null);
        Test.stopTest();
    }   
    */
    @isTest
    static void hasCommercialVisitForLeadTest2(){
        List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
        insert addList;
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeadsWithAddress(1);
        leadlist[0].XC_Segment__c='B2C';
        leadlist[0].XC_DocumentCountry__c='Spain';
        leadlist[0].XC_CommercialVisitRequired__c = true;
        leadlist[0].XC_ProductCategoryOfInterest__c = 'Caldera';
        leadlist[0].XC_LeadAddress__c = addList[0].Id;
        insert leadlist;  
        XC_ProductCategoryOfInterest__c prodCat =  XC_DF_ProductCategoryOfInterest.prodCatWithoutVisitRecord();
        insert prodCat;
        leadlist[0].Status = Label.XC_CL_Lead_PendingScheduling;
        update leadlist;
    Test.startTest();
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.hasCommercialVisitForLead(leadlist[0].id);
        System.assert(rw!=null);
        Test.stopTest();
    }
    
    @isTest
    static void hasCommercialVisitForLeadTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeads(1);
        leadlist[0].XC_Segment__c='B2C';
        insert leadlist;
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.hasCommercialVisitForLead(leadlist[0].id);
        System.assert(rw!=null); 
        Test.stopTest();
    } 
    
    @isTest
    static void hasCommercialVisitForOpportunityTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Opportunity> opplist = XC_DF_Opportunity.createOpportunity(1,true);
        insert opplist;
        Boolean rw = XC_LCC014_CreateWorkOrder.hasCommercialVisitForOpportunity(opplist[0].id);
        Test.stopTest();
    }
    
    /*
    @isTest
    static void hasCommercialVisitForLeadTest4(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_ProductCategoryOfInterest__c pci = new XC_ProductCategoryOfInterest__c(Name='Caldera', XC_CommercialVisit__c=true); 
        insert pci;
        WorkType wt = new WorkType(Name=Label.XC_CL_CommercialVisit, EstimatedDuration =2);
        insert wt;
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeadsWithAddress(1);
        leadlist[0].Status = Label.XC_CL_WorkOrder_PendingScheduling;
        leadlist[0].Email = 'mimmo@gmail.com';
        leadlist[0].XC_ProductCategoryOfInterest__c= 'Iluminación LED';
        leadlist[0].XC_DocumentCountry__c = 'Spain';
        insert leadlist;
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.hasCommercialVisitForLead(leadlist[0].id);
        System.assert(rw!=null);
        Test.stopTest(); 
    } 
    */
        @isTest
    static void getListAddressReturnNull(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
    String recordId;
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.getListAddress(recordId, true);
        System.assert(rw==null);
        Test.stopTest(); 
    } 
   
         @isTest
    static void getListAddressWithRecordId(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
    String recordId = accList[0].Id;
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.getListAddress(recordId, true);
        System.assert(rw!=null);
        Test.stopTest(); 
    }  
    
     @isTest
    static void getListAddressWithRecordIdAndFalse(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
    String recordId = accList[0].Id;
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper rw = XC_LCC014_CreateWorkOrder.getListAddress(recordId, false);
        System.assert(rw!=null);
        Test.stopTest(); 
    } 
    
    
     @isTest
     static void callZuoraForUpdate(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        //List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        insert contList;
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        Zuora__CustomerAccount__c zCustomerAccount = new Zuora__CustomerAccount__c(Zuora__Account__c = accList[0].Id);
        insert zCustomerAccount;
        
        List<XC_Address__c> addList = XC_DF_Address.createAddress(1);
        insert addList;
        List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1);
        //List<NE__Billing_Profile__c> bpList = XC_DF_BillingProfile.createBillingProfile(1,accList);
        List<XC_BillingProfileLineItem__c> bpliList = [
            SELECT Id, XC_CustomerAccount__c, XC_ZuoraId__c, XC_LegalEntity__c,XC_SoldToContactId__c 
            FROM XC_BillingProfileLineItem__c 
        ];
        XC_BillingProfileLineItem__c bpli = bpliList[0];
        bpli.XC_CustomerAccount__c =zCustomerAccount.Id; 
        bpli.XC_LegalEntity__c = 'EndesaX';

    bpli.XC_SoldToContactId__c=contList[0].Id;
        update bpli;

        updateZuora_Mock mock = new updateZuora_Mock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        String recordId = addList[0].Id;
    String lineItemId = bpliList[0].Id; 
        XC_UTIL_ResultWrapper rw = XC_LCC014_CreateWorkOrder.callZuoraForUpdate(recordId, lineItemId);
        System.assert(rw!=null);
        Test.stopTest(); 
    }  
    
    @isTest
    static void createWorkOrderForLeadTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<XC_Address__c> listOfAdd = XC_DF_Address.createAddress(1);
        insert listOfAdd;
        List<Lead> leadlist = XC_DF_Lead.createResidentialLeads(1);
        leadlist[0].XC_LeadAddress__c = listOfAdd[0].Id;
        insert leadlist;
        WorkType wt = new WorkType(Name=Label.XC_CL_CommercialVisit, EstimatedDuration =2);
        insert wt;
        XC_UTIL_ResultWrapper rw = XC_LCC014_CreateWorkOrder.createWorkOrderForLead(leadlist[0].id);
        XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper wrapper = new XC_LCC014_CreateWorkOrder.CreateWOforLeadWrapper();
    XC_LCC014_CreateWorkOrder_U.CheckLeadStatusWrapper wrapperCheckLead = new XC_LCC014_CreateWorkOrder_U.CheckLeadStatusWrapper();
    wrapperCheckLead.wrapper = wrapper;
    XC_LCC014_CreateWorkOrder_U.CheckLeadPendingSchedulingWrapper wrap = new XC_LCC014_CreateWorkOrder_U.CheckLeadPendingSchedulingWrapper();
    wrap.checkWrapper = wrapperCheckLead; 
      wrap.isPendingScheduling = false;    
    XC_LCC014_CreateWorkOrder_U.checkLeadPendingScheduling(wrap);
        System.assert(rw!=null);
        Test.stopTest();
    }  
    
    @isTest
    static void createWorkOrderTest(){        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Opportunity> opplist = XC_DF_Opportunity.createOpportunity(1,true);
        insert opplist;
        WorkType wt = new WorkType(Name=Label.XC_CL_CommercialVisit,  EstimatedDuration =2);
        insert wt;
        XC_UTIL_ResultWrapper rw = XC_LCC014_CreateWorkOrder.createWorkOrder(opplist[0].id);
        System.assert(rw!=null);
        Test.stopTest();
    }    
    
    public class updateZuora_Mock implements HttpCalloutMock{

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"OK","success":"true","reasons":[]}');
            res.setStatusCode(200);
            return res;
        }
    }
}
/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @Creation 30/01/2020
* @description Test Class for XC_UTIL_CustomerInteractionGeneration
*/

@isTest
private class XC_UTIL_CustomerInteractionGen_TEST {
    
    @isTest
    static void testInsertCustInter(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.Name = 'Test Ci xxxxx';
        ci.XC_ContactId__c = cList[0].Id;
        ci.XC_AccountId__c = aList[0].Id;
        ci.XC_Communication_Type__c = 'Lead_Welcome_Email';
        //List<XC_Customer_Interaction__c> customerIntList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        
        test.startTest();
        	XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_CustomerInteractionGeneration.insertCustomerInteraction(ci); //customerIntList[0]
        test.stopTest();
        //System.assertNotEquals(customerIntList, null);
        System.assertEquals(wr.success, true);
    }   

    @isTest
    static void testProdCateg(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        test.startTest();
        Boolean bool = XC_UTIL_CustomerInteractionGeneration.isLeadProductCategoryBlank(leadList[0].Id);
        test.stopTest();
        System.assertNotEquals(leadList, null);
    }
    
    @isTest
    static void populateLookupBankTransferKO_Test() {
        
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc; 
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont; 
        List<NE__OrderItem__c> oItmlist=XC_DF_OrderItem.createOrderItems(1);
        for(Ne__OrderItem__C oi: oItmlist) {
            oi.XC_BankTransferCode__c ='testBanckTrCode';
        }
        insert oItmlist;
        Test.startTest();
            List<XC_Address__c> address =  XC_DF_Address.createAddress(acc);
            insert address;
            List<XC_Customer_Interaction__c> newListCi = new List<XC_Customer_Interaction__c>();
        
        	
             XC_Customer_Interaction__c cI=  new XC_Customer_Interaction__c();
            cI.Name = 'Test Ci';
            cI.XC_ContactId__c = cont[0].Id;
            cI.XC_AccountId__c = acc[0].Id;
            cI.XC_Communication_Type__c = 'Bank_Transfer_KO_Email';
            cI.XC_Channel__c ='Email';
            cI.XC_LegalEntity__c='EndesaX';
        	ci.XC_AdditionalInfo1__c ='testBanckTrCode';
            cI.XC_Preferredlanguageofcontact__c='English';
        	newListCi.add(ci);
         XC_UTIL_CustomerInteractionGeneration_U.populateLookupBankTransferKO(newListCi);
        Test.stopTest();
    }
    
    @isTest
    static void getPreferredLanguage_test() {
        test.startTest();
        	String retu=XC_UTIL_CustomerInteractionGeneration_U.getPreferredLanguage('English');
        System.assertEquals(retu, 'English');
        Test.stopTest();
    }
    
    /*@isTest
    static void populateCustomerInterFromLead_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        woList[0].XC_Lead__c = leadList[0].Id;
        woList[0].XC_WorkTypeCategory__c = Label.XC_CL_WorkType_CommercialVisit;
        insert woList; 
        test.startTest();
        XC_UTIL_CustomerInteractionGeneration_U.populateCustomerInterFromLead(woList[0], new XC_Customer_Interaction__c());
        test.stopTest();
    }*/

    /*@isTest
    static void testPopulateFromLead(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<XC_Customer_Interaction__c> customerIntList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        insert leadList; 
        Map<String,Object> values = new Map<String,Object>{'leadId' => leadList[0].Id};
        test.startTest();
        XC_UTIL_CustomerInteractionGeneration.populateFromLead(customerIntList[0], values);
        test.stopTest();
        System.assertNotEquals(customerIntList, null);
    }

    @isTest
    static void testPopulateFromLeadWithContact(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<XC_Customer_Interaction__c> customerIntList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        test.startTest();
        insert leadList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        insert contactList;
        Map<String,Object> values = new Map<String,Object>{'leadId' => leadList[0].Id, 'contactId' => contactList[0].Id, 'fullName' => 'TEST', 'email' => 'test@email.com'};
        XC_UTIL_CustomerInteractionGeneration.populateFromLead(customerIntList[0], values);
        test.stopTest();
        System.assertNotEquals(customerIntList, null);
    }*/
    
    @isTest
    static void insertCustomerInteraction_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.insertCustomerInteraction(new XC_Customer_Interaction__c());
        Test.stopTest();
    } 
    
    @isTest
    static void isLeadProductCategoryBlank_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1); 
        insert listLead;      
        XC_UTIL_CustomerInteractionGeneration.isLeadProductCategoryBlank(listLead[0].Id);
        Test.stopTest();
    } 
        
    @isTest
    static void newEmailForCustomerFromLead_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOpportunity(new List<Map<String,Object>>());
        Test.stopTest();
    } 
    
    @isTest
    static void newEmailForCustomerFromCases_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(new List<Map<String,Object>>());
        Test.stopTest();
    } 
    
    @isTest
    static void newEmailForCustomerFromAsset_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromAsset(new List<Map<String,Object>>());
        Test.stopTest();
    }
    
    @isTest
    static void populateFromWorkOrder(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        wo[0].ContactId = cList[0].Id;
        wo[0].XC_Address__c = null;
        wo[0].Street = '';
        insert wo;
        
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_WorkOrderId__c = wo[0].id;
        
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.populateFromWorkOrder(ci);
        Test.stopTest();
    } 
    
    @isTest
    static void newEmailForCustomerFromWorkOrder_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(new List<Map<String,Object>>());
        Test.stopTest();
    } 
    
    @isTest
    static void newEmailForCustomerFromOrders_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(new List<Map<String,Object>>());
        Test.stopTest();
    } 
    
    @isTest
    static void populateFromServiceAppointment_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(1);
        insert conList;
        
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1);
        serApp[0].ContactId = conList[0].Id;
        insert serApp;
        
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.populateFromServiceAppointment(new XC_Customer_Interaction__c(XC_ServiceAppointmentId__c = serApp[0].Id));
        Test.stopTest();
    }
    
    @isTest
    static void populateFromOpportunity_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
        
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.populateFromOpportunity(new XC_Customer_Interaction__c(XC_OpportunityId__c = oppList[0].Id));
        Test.stopTest();
    } 
    
    @isTest
    static void populateFromOrder_TEST(){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
        
        List<NE__Order__c> orderList = XC_DF_Order.createOrders(1, 'inOrder');
        orderList[0].NE__OptyId__c = oppList[0].Id;
        orderList[0].NE__AccountId__c = oppList[0].AccountId;
        insert orderList;

        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.populateFromOrder(new XC_Customer_Interaction__c(XC_OrderId__c = orderList[0].Id));
        Test.stopTest();
    } 
    
    @isTest
    static void populateCoreCustomerInteration_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration_U.populateCoreCustomerInteration(new Map<String,Object>());
        Test.stopTest();
    } 
    
    @isTest
    static void populateCoreCustomerInterationIDs_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration_U.populateCoreCustomerInterationIDs(new Map<String,Object>());
        Test.stopTest();
    } 
    
    @isTest
    static void objectIdEncrypt_TEST(){ 
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1); 
        insert listLead;   
        XC_UTIL_CustomerInteractionGeneration_U.objectIdEncrypt(listLead[0].Id);
        Test.stopTest();
    } 
    
    @isTest
    static void populateCIforStartTravel_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, false);
        insert oppList;
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        woList[0].XC_Opportunity__c = oppList[0].Id;
        insert woList;
        
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c(XC_WorkOrderId__c = woList[0].Id, XC_Communication_Type__c = Label.XC_CL_CustomerInteraction_WorkOrder_StartTravel);
        List<XC_Customer_Interaction__c> ciList = new List<XC_Customer_Interaction__c>();
        ciList.add(ci);
        
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration_U.populateCIforStartTravel(ciList);
        Test.stopTest();
    }
    
    @isTest
    static void populateCIforStartTravel_TEST2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        woList[0].XC_Opportunity__c = null;
        insert woList;
        
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c(XC_WorkOrderId__c = woList[0].Id, XC_Communication_Type__c = Label.XC_CL_CustomerInteraction_WorkOrder_DelayTravel);
        List<XC_Customer_Interaction__c> ciList = new List<XC_Customer_Interaction__c>();
        ciList.add(ci);
        
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration_U.populateCIforStartTravel(ciList);
        Test.stopTest();
    } 
    
    @isTest
    static void isMobilePhone_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone('+34','612345678');
        XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone('+37','612345678');
        XC_UTIL_CustomerInteractionGeneration_U.isMobilePhone('','612345678');
        Test.stopTest();
    } 
    
    @isTest
    static void getCustomerUnreachableCI_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert woList; 
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        WorkOrder wo = woList[0];
        ServiceAppointment sa = saList[0];
        XC_UTIL_CustomerInteractionGeneration_U.getCustomerUnreachableCI(wo,sa);
        Test.stopTest();
    } 
    
    @isTest
    static void getWorkOrderActivityReportCI_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert woList; 
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        WorkOrder wo = woList[0];
        ServiceAppointment sa = saList[0];
        XC_UTIL_CustomerInteractionGeneration_U.getWorkOrderActivityReportCI(wo,sa, new Map<Id, List<NE__Order__c>>());
        Test.stopTest();
    }  

    static void getWorkOrderActivityReportCI1_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        insert woList; 
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        WorkOrder wo = woList[0];
        ServiceAppointment sa = saList[0];
        XC_UTIL_CustomerInteractionGeneration_U.getWorkOrderActivityReportCI(wo,sa, new Map<Id, List<NE__Order__c>>());
        Test.stopTest();
    } 

    static void getWorkOrderActivityReportCI2_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_PlannedMaintenance);
        woList[0].XC_StatusReason__c = 'No anomaly';
        insert woList; 
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        WorkOrder wo = woList[0];
        ServiceAppointment sa = saList[0];
        XC_UTIL_CustomerInteractionGeneration_U.getWorkOrderActivityReportCI(wo,sa, new Map<Id, List<NE__Order__c>>());
        Test.stopTest();
    } 
    
    @isTest
    static void populateCICommercialVisit3_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        insert woList; 
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        insert saList;
        WorkOrder wo = woList[0];
        ServiceAppointment sa = saList[0];
        XC_UTIL_CustomerInteractionGeneration_U.populateCICommercialVisit(wo,sa, new Map<Id, List<NE__Order__c>>());
        Test.stopTest();
    } 
    
    @isTest
    static void setSurveyIdForCaseClosed_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Reason = 'XCMOT001';
        listCase[0].SubCause__c = 'ATCL015';
        listCase[0].XC_LegalEntity__c = 'EndesaX';
        listCase[0].XC_Segment__c = 'B2C';
        insert listCase;
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.XC_Communication_Type__c = 'Case_Closed';
        ci.XC_CaseId__c = listCase[0].id;
        XC_UTIL_CustomerInteractionGeneration_U.setSurveyIdForCaseClosed(new List<XC_Customer_Interaction__c>{ci});
        Test.stopTest();
    } 
    
    @isTest
    static void setSurveyIdForCaseClosed2_TEST(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration_U.setSurveyIdForCaseClosed(new List<XC_Customer_Interaction__c>());
        Test.stopTest();
    }  
    
    @isTest
    static void resendCiTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        insert ci;
        XC_UTIL_ResultWrapper reswrap = XC_LCC164_ResendCI.resend(ci.id, 'enel@gmail.com');
        Map<String, String> emailmap = XC_LCC164_ResendCI.getEmails(ci.id);
        Test.stopTest();
    }  
    
    @isTest
    static void populatefromlead_test(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.cov();
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        List<Lead> lead = XC_DF_Lead.createResidentialLeads(1);
        insert lead;
        Map<String,Object> values = new Map<String,Object>();
        values.put('leadId',lead[0].Id);
        
        XC_UTIL_CustomerInteractionGeneration.populateFromLead(ci, values);
        Test.stopTest();
    }  
    
    @isTest
    static void populatefromlead_withContact(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.cov();
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        Map<String,Object> values = new Map<String,Object>();
        
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        values.put('contactId',cList[0].Id);
        
        XC_UTIL_CustomerInteractionGeneration.populateFromLead(ci, values);
        Test.stopTest();
    }  
    
    @isTest
    static void getCustomerInteractionInfo_test(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        XC_UTIL_CustomerInteractionGeneration.getCustomerInteractionInfo('Welcome_Contract', 'EnelXItalia', 'B2C');
        Test.stopTest();
    }  

    @isTest
    static void setPreferredLanguageOnNewCI_TRCall(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;
        
        Test.startTest();
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.Name = 'Test Ci xxxxx';
        ci.XC_ContactId__c = cList[0].Id;
        ci.XC_AccountId__c = aList[0].Id;
        ci.XC_LegalEntity__c = 'EndesaX';
        ci.XC_Communication_Type__c = 'Case_Created';
        insert ci;
  
        Test.stopTest();
    }
    
    @IsTest
    static void methodTestpopulateAccountBalance(){
        
        List<Account> aList = XC_DF_Account.createResidentialAccounts(1);
        insert aList;
        List<Contact> cList = XC_DF_Contact.createResidentialContacts(aList);
        insert cList;

        Zuora__CustomerAccount__c zu = new Zuora__CustomerAccount__c(); 
        zu.Zuora__Account__c = aList[0].Id;
        zu.Zuora__Zuora_Id__c = '123456';
        insert zu;

        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c (Zuora__Balance__c = 0, Zuora__Status__c = 'Posted', Zuora__TotalAmount__c = 10,Zuora__Account__c = aList[0].Id);
        insert invoice;

        Zuora__Payment__c payment = new Zuora__Payment__c(Zuora__BillingAccount__c = zu.Id,Zuora__Account__c = aList[0].Id,Zuora__AppliedAmount__c = 4);
        insert payment;

        Zuora__CreditMemo__c credit = new Zuora__CreditMemo__c(Zuora__BillingAccount__c = zu.Id,Zuora__AppliedAmount__c = 12,Zuora__Balance__c = 12, Zuora__DiscountAmount__c = 12, Zuora__External_Id__c = '123', Zuora__MemoDate__c = System.Today(), Zuora__RefundAmount__c = 12, Zuora__TaxAmount__c = 0, Zuora__TotalAmountWithoutTax__c = 0, Zuora__TotalAmount__c = 12, Zuora__TotalTaxExemptAmount__c = 0);
        insert credit;
        
        Test.startTest();
        XC_Customer_Interaction__c ci = new XC_Customer_Interaction__c();
        ci.Name = 'Test Ci xxxxx';
        ci.XC_ContactId__c = cList[0].Id;
        ci.XC_AccountId__c = aList[0].Id;
        ci.XC_LegalEntity__c = 'EndesaX';
        ci.XC_Communication_Type__c = 'Case_Created';
        insert ci;
  
        Test.stopTest();

        XC_Customer_Interaction__c insertedCi = [SELECT Id,XC_Account_Balance__c FROM XC_Customer_Interaction__c LIMIT 1];
        System.assertEquals(18, insertedCi.XC_Account_Balance__c, '(10-4)+12');
        
    }
}
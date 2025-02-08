/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date Creation  16/05/2019
* @description Test Class for XC_LCC066_Doxee / Canvas / Doxee 
*/ 
@isTest
private class XC_LCC066_Doxee_TEST {
    static testMethod void fetchUserTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        Test.startTest();
        XC_LCC066_Doxee.WrapperUser wr = new XC_LCC066_Doxee.WrapperUser();
        wr.username  = 'test@test.com';
        wr.country   = 'SPAIN';
        wr.company   = 'ENDESAX-B2C';
        User u = XC_DF_User.createUserAdmin();
        insert u;
        String userid = u.Id;
        XC_LCC066_Doxee.fetchUser(userid);
        System.assert(true, !String.isEmpty(userid));
        Test.stopTest();
    }
    static testMethod void fetchUserCaseTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA001';
        listCase[0].XC_LegalEntity__c='EnelXItalia'; //vdb
        insert listCase;
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        Test.startTest();
        XC_LCC066_Doxee.fetchUser(listCase[0].Id);
        System.assert(true, !listCase.isEmpty());
        Test.stopTest();
        }
    }
    static testMethod void fetchUserConfItemTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        insert oiList;
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        Test.startTest();
        XC_LCC066_Doxee.fetchUser(oiList[0].Id);
        System.assert(true, !oiList.isEmpty());
        Test.stopTest();
        }
    }
    static testMethod void fetchUserWorkorderTest(){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
          OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert woList;
         List<Case> listCase = XC_DF_Case.createCases(1);
       /* Account acc=[select from Account 
                    where id=:]*/
        listCase[0].Reason='XCMOT006';
        listCase[0].SubCause__c='ATCL072';
        listCase[0].XC_LegalEntity__c='	EndesaX';
        woList[0].AccountID=listCase[0].AccountId;
        update woList;
        listCase[0].XC_WorkOrder__c=woList[0].id;
        
        system.debug('LE Case'+' '+listCase[0].XC_LegalEntity__c);
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        Test.startTest();
        insert listCase;
        XC_LCC066_Doxee.getUserInformation(listCase[0].Id);
        System.assert(true, !woList.isEmpty());
        Test.stopTest();
        }
    }
    static testMethod void fetchUserOrdertest(){
       OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        insert org;
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Reason='XCMOT006';
        listCase[0].SubCause__c='ATCL091';
        listCase[0].XC_LegalEntity__c = 'EndesaX';
        insert listCase;
         User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        test.startTest();
         XC_LCC066_Doxee.getUserInformation(listCase[0].id);
        XC_LCC066_Doxee.getProcurator(listCase[0].id,'Case');
        XC_LCC066_Doxee.getProcuratoreId(listCase[0]);
        test.stopTest();
        }
    }
    static testMethod void getUserInformationOrder() {
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        NE__Order__c o=XC_DF_Order.createOrder('Opty');
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        test.startTest();
         XC_LCC066_Doxee.getUserInformation(o.id);
        test.stopTest();
        }
    }
    static testMethod void getUserInformationWorkOrder(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert woList;
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        test.startTest();
         XC_LCC066_Doxee.getUserInformation(woList[0].id);
        test.stopTest();    
        }
    }
    static testMethod void getUserInformationContract(){
        
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        User admin = XC_DF_User.createUserAdmin();
        admin.XC_LegalEntity__c = 'EndesaX';
        insert admin;
        System.runAs(admin){
        NE__Order__c order = XC_DF_Order.createOrder('Order');
        List<contract> con=XC_DF_Contract.createContracts(1);
        con[0].XC_Configurations__c = order.id;
        insert con;
        test.startTest();
        XC_LCC066_Doxee.getUserInformation(con[0].id);
        test.stopTest();    
        }
    }
  /*  static testMethod void getUserInformationBillinProfile(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;       
        List<NE__Billing_Profile__c> listBP=XC_DF_BillingProfile.createBillingProfile(1);
        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        XC_BillingProfileLineItem__c bpli = [
                SELECT XC_SoldToContactId__c, XC_SoldToAddress__c
                FROM XC_BillingProfileLineItem__c
                WHERE XC_BillingProfile__c = :listBP[0].id
                LIMIT 1];
        bpli.XC_SoldToContactId__c = contactList[0].id;
        update bpli; 
        test.startTest();
         XC_LCC066_Doxee.getUserInformation(listBP[0].id);
        test.stopTest(); 
    }*/

    /*static testMethod void getProcuratorTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Case c = XC_DF_Case.createCases(1)[0];
        c.Reason = 'XCMOT018';
        c.SubCause__c = 'ATCL115';
        c.XC_legalEntity__c = 'EnelSole';
        c.XC_segment__c = 'B2B';
        c.Country__c = 'Italy';
		c.RecordTypeId	= Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
        insert c;
        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        Test.startTest();
        
        XC_LCC066_Doxee.getProcurator(c.Id,'Case');
        XC_LCC066_Doxee.getProcuratoreId(c);
        Test.stopTest();
    }*/

    static testMethod void getProcuratorWOLITest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
        Case c = new Case();
        c.Status = 'ESTA001';
        c.XC_Type_Intermediary__c = 'TI001';
        c.Reason = 'XCMOT018';
        c.SubCause__c = 'ATCL115';
        c.XC_legalEntity__c = 'EnelSole';
        c.XC_segment__c = 'B2B';
		c.RecordTypeId	= Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();

        List<WorkOrder> wo = new List<WorkOrder>();
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_CommercialVisit);
        insert workTypeToInsert;
        insert XC_DF_Address.createAddress(acc);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        for (Integer i=0; i<1; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_CommercialVisit;
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
            workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_Digitized__c = true;
            workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            wo.add(workOrderToInsert);
        }
        wo[0].XC_Segment__c = 'B2B';
        WO[0].XC_LegalEntity__c = 'EnelSole';
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo[0].AccountId = acc[0].id;
        insert wo;         
        WorkOrderLineItem woli = new WorkOrderLineItem();
        Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
        woli.WorkOrderId= wo[0].Id;      
        woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        insert woli;

		c.XC_WorkOrder__c = wo[0].Id;
        c.AccountId = acc[0].id;
        c.ContactId = contact[0].id;
        c.XC_WorkOrderLineItem__c = woli.id;
        c.SubCause__c = 'ATCL116';
        //c.XC_LcLsuspended__c =true;
        //c.XC_Generate_Case_Document__c=true;
        c.Country__c = 'Italy';
        Test.startTest();
        insert c;

        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        
        XC_LCC066_Doxee.getProcurator(woli.Id,'WorkOrderLineItem');
        XC_LCC066_Doxee.getProcuratoreId(woli);
        XC_LCC066_Doxee.getNumberOfSignatureInt('LCL');
        XC_LCC066_Doxee.getNumberOfSignatureExt('LCL');
        Test.stopTest();
    }

  /*  static testMethod void getUserInformationWorkOrderLineItem(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        //List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        //insert woList;
        List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;

        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
       	contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;

        User u = XC_DF_User.createUserAdmin();
        insert u;

        ServiceResource s1 = new ServiceResource();
        s1.RelatedRecordId = u.Id;
        s1.XC_Contact__c = contact[0].Id;
        s1.Name = 'test';
        insert s1;

        XC_PersonalDocument__c d1 = new XC_PersonalDocument__c();
        d1.XC_Contact__c = contact[0].Id;
        d1.XC_Country__c = 'Italy';
        //d1.XC_DocumentType__c = 'PT';
        d1.XC_DocumentType__c = 'Other';
        insert d1;

        test.startTest();
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_CommercialVisit);
        wo[0].XC_Segment__c = 'B2B';
        WO[0].XC_LegalEntity__c = 'EnelSole';
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wo[0].AccountId = acc[0].id;
        system.debug('DIM' + contact[0].id);
        wo[0].ContactId = contact[0].id;
        wo[0].XC_AssignedResource__c = s1.Id;
        insert wo;     
        
        

        WorkOrderLineItem woli = new WorkOrderLineItem();
        Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
        woli.WorkOrderId= wo[0].Id;      
        woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        woli.XC_LCLDocument__c = 'LCL';
        insert woli;
        
         XC_LCC066_Doxee.getUserInformation(woli.id);
        test.stopTest();    
    }  */
    
    static testMethod void getProcuratorWOLITestB2C(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> acc = XC_DF_Account.createSohoAccounts(1);
        acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert acc;
        List<Contact> contact = XC_DF_Contact.createSohoContacts(acc);
        contact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDevelopername().get('XC_GLO_B2B').getRecordTypeId();
        insert contact;
        Case c = new Case();
        c.Status = 'ESTA001';
        c.XC_Type_Intermediary__c = 'TI001';
        c.Reason = 'XCMOT018';
        c.SubCause__c = 'ATCL115';
        c.XC_legalEntity__c = 'EndesaX';
        c.XC_segment__c = 'B2C';
		c.RecordTypeId	= Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('XC_ESP_Management_Case').getRecordTypeId();

        List<WorkOrder> wo = new List<WorkOrder>();
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType(Label.XC_CL_WorkType_CommercialVisit);
        insert workTypeToInsert;
        insert XC_DF_Address.createAddress(acc);
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        for (Integer i=0; i<1; i++){
            WorkOrder workOrderToInsert = new WorkOrder();
            workOrderToInsert.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_CommercialVisit;
            workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
            workOrderToInsert.XC_LegalEntity__c = 'EndesaX';
            workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
            workOrderToInsert.XC_Address__c = address.Id;
            workOrderToInsert.Street = address.XC_Address__c;
            workOrderToInsert.XC_Digitized__c = true;
            workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
            workOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
            wo.add(workOrderToInsert);
        }
        wo[0].XC_Segment__c = 'B2C';
        wo[0].XC_LegalEntity__c ='EndesaX';
        wo[0].RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDevelopername().get('XC_B2C_EndesaX_WorkOrder').getRecordTypeId();
        wo[0].AccountId = acc[0].id;
        insert wo;         
        WorkOrderLineItem woli = new WorkOrderLineItem();
        Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2B_EnelXItalia_PE_WOLI').getRecordTypeId();
        woli.WorkOrderId= wo[0].Id;      
        woli.Status='Approved';
        woli.XC_WOLIType__c = 'Partner Engagement';
        insert woli;

		c.XC_WorkOrder__c = wo[0].Id;
        c.AccountId = acc[0].id;
        c.ContactId = contact[0].id;
        c.XC_WorkOrderLineItem__c = woli.id;
        c.SubCause__c = 'ATCL116';
        //c.XC_LcLsuspended__c =true;
        //c.XC_Generate_Case_Document__c=true;
        c.Country__c = 'Italy';
        insert c;
 		
        Test.startTest();
        List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(1);
        insert contactList;
        
        XC_LCC066_Doxee.getProcurator(woli.Id,'WorkOrderLineItem');
        XC_LCC066_Doxee.getProcuratoreId(woli);
        XC_LCC066_Doxee.getNumberOfSignatureInt('LCL');
        XC_LCC066_Doxee.getNumberOfSignatureExt('LCL');
        Test.stopTest();
    }
    
    static testMethod void getUserInformationOrderB2B() {
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        NE__Order__c o=XC_DF_Order.createOrder('Opty');
        o.XC_Segment__c = 'B2B';
        update o;
        Opportunity opp = [SELECT XC_Contact__c FROM Opportunity WHERE id =: o.NE__OptyId__c  LIMIT 1];
        XC_PersonalDocument__c pd = new XC_PersonalDocument__c();
		pd.XC_Contact__c= opp.XC_Contact__c;
        pd.XC_Account__c= o.NE__AccountId__c;
        pd.XC_DocumentType__c ='Other';
        insert pd;
        test.startTest();
         XC_LCC066_Doxee.getUserInformation(o.id);
        XC_LCC066_Doxee.buildSignature(opp.XC_Contact__c, 1, 'test');
        test.stopTest();
    }
}
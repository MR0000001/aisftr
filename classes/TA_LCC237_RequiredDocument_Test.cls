@isTest
private class TA_LCC237_RequiredDocument_Test {
    static testMethod void fetchUserTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        Test.startTest();
        TA_LCC237_RequiredDocument.WrapperUser wr = new TA_LCC237_RequiredDocument.WrapperUser();
        wr.username  = 'test@test.com';
        wr.country   = 'SPAIN';
        wr.company   = 'ENDESAX-B2C';
        User u = XC_DF_User.createUserAdmin();
        insert u;
        String userid = u.Id;
        TA_LCC237_RequiredDocument.fetchUser(userid);
        System.assert(true, !String.isEmpty(userid));
        Test.stopTest();
    }
    static testMethod void fetchUserCaseTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].Status = 'ESTA001';
        insert listCase;
        Test.startTest();
        TA_LCC237_RequiredDocument.fetchUser(listCase[0].Id);
        System.assert(true, !listCase.isEmpty());
        Test.stopTest();
    }
    static testMethod void fetchUserConfItemTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__OrderItem__c> oiList = XC_DF_OrderItem.createOrderItems(1);
        insert oiList;
        Test.startTest();
        TA_LCC237_RequiredDocument.fetchUser(oiList[0].Id);
        System.assert(true, !oiList.isEmpty());
        Test.stopTest();
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
        woList[0].AccountID=listCase[0].AccountId;
        update woList;
        listCase[0].XC_WorkOrder__c=woList[0].id;

        Test.startTest();
        insert listCase;

        insert new XC_PersonalDocument__c(XC_Contact__c = listCase[0].contactId, XC_DocumentType__c = 'CI');

        TA_LCC237_RequiredDocument.getUserInformation(listCase[0].Id);
        System.assert(true, !woList.isEmpty());
        Test.stopTest();
    }
    static testMethod void fetchUserOrdertest(){
       OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        NE__Order__c o=XC_DF_Order.createOrder('Opty');
        List<Case> listCase = XC_DF_Case.createCases(1);
        listCase[0].XC_Order__c=o.id;
        insert listCase;
        test.startTest();
        TA_LCC237_RequiredDocument.getUserInformation(listCase[0].id);
        test.stopTest();
    }
    static testMethod void getUserInformationOrder() {
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        NE__Order__c o=XC_DF_Order.createOrder('Opty');
        test.startTest();
        TA_LCC237_RequiredDocument.getUserInformation(o.id);
        test.stopTest();
    }
    static testMethod void getUserInformationWorkOrder(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrdersForLead(1);
        insert woList;
        test.startTest();
        TA_LCC237_RequiredDocument.getUserInformation(woList[0].id);
        test.stopTest();    
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
            
            Contact cont = new Contact();
            cont.AccountId = order.NE__AccountId__c;
            cont.FirstName = 'Test';
            cont.LastName = 'Test1';
            cont.Email = 'test_soho' + Math.random() + '@email.com'; 
            cont.XC_CountryLegalEntity__c = 'SPAIN';
            cont.XC_SkipTriggerIndividual__c = true; 
            cont.XC_MainLegalEntity__c = 'EndesaX';
            cont.XC_GiveDataToNew__c = 'Yes';
            insert cont;

            insert new XC_PersonalDocument__c(XC_DocumentType__c = 'PT', XC_Contact__c = cont.Id);

            Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =:order.NE__OptyId__c];
            opp.XC_Contact__c = cont.Id;
            update opp;

            List<contract> con=XC_DF_Contract.createContracts(1);
            con[0].XC_Configurations__c = order.id;
            insert con;
        
        Test.startTest();
        TA_LCC237_RequiredDocument.getUserInformation(con[0].id);
        Test.stopTest();    
        }
    }
    static testMethod void getUserInformationBillinProfile(){
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
        TA_LCC237_RequiredDocument.getUserInformation(listBP[0].id);
        test.stopTest(); 
    }
}
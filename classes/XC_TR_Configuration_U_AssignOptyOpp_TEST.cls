/**
* @author Elisa Caldini -elisa.caldini@accenture.com
* @date Creation -22.03.2022
* @description  XC_TR_Configuration_U_AssignOptyOpp_TEST - TEST Class for XC_TR_Configuration_U_AssignOptyAndOpp
*/

@isTest
private  class XC_TR_Configuration_U_AssignOptyOpp_TEST {
    
    @TestSetup 
    static void methodName() {
        Opportunity opp = new Opportunity();
		List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        accountList[0].RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        insert accountList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(accountList);
        contList[0].RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2B').getRecordTypeId();
        insert contList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;
        opp.Name ='Opportunity di Test';
        opp.XC_Contact__c = contList[0].Id;
        opp.AccountId = contList[0].AccountId;
        opp.XC_Address__c = address[0].Id;
        opp.CloseDate = Date.newInstance(2030, 12, 31);
        opp.XC_Segment__c = 'B2C';
        opp.XC_LegalEntity__c = 'EnelXItalia';
        opp.XC_BusinessLine__c='eCity';
        opp.XC_IndustrialKPI__c ='Work Contract';
        opp.XC_ProductCategoryOfInterest__c ='Smart Lighting';
        opp.XC_ProductCategory__c='Optimize';
        opp.XC_BusinessModel__c = 'Spot Sale';
        opp.StageName ='Draft';
        opp.XC_Source__c ='Commodity';
        opp.XC_ReceivingChannel__c='KAM';
        opp.XC_CapexFullLife__c =6000;
        opp.XC_CustomerRequestDate__c =Date.newInstance(2022, 12, 30);
        insert opp;
        NE__Order__c order =new NE__Order__c();
        order.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2B';
        order.XC_LegalEntity__c='EnelSole';
        order.NE__OptyId__c = opp.Id;
		order.NE__Type__c='InOrder';							
        order.XC_DeliveryAddress__c = opp.XC_Address__c;
        order.NE__AccountId__c =opp.AccountId;
        insert order;
        NE__OrderItem__c orderItem=XC_DF_OrderItem.createOrderItem(order);
        insert orderItem;
        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(orderItem, 'Modalidad de Contratacion', '3');
        insert attr;
        List<User> users=XC_DF_User.generateMultipleUser(2);
        users[0].ProfileId=[SELECT Id, UserLicenseId FROM Profile WHERE Name = 'XC_ITA_KAM' LIMIT 1][0].Id;
        users[1].ProfileId=[SELECT Id, UserLicenseId FROM Profile WHERE Name = 'XC_ITA_ProjectManager' LIMIT 1][0].Id;
        insert users;
        AccountTeamMember accountTeamMember=new AccountTeamMember();
        accountTeamMember.AccountId=opp.AccountId;
        accountTeamMember.UserId=users[0].Id;
        accountTeamMember.TeamMemberRole='Tecnico';
        insert accountTeamMember;
        AccountTeamMember accountTeamMember1=new AccountTeamMember();
        accountTeamMember1.AccountId=opp.AccountId;
        accountTeamMember1.UserId=users[1].Id;
        accountTeamMember1.TeamMemberRole='Tecnico Gestionale';
        insert accountTeamMember1;
    }

    static void makeDataIta(){
        Account itaAcc = new Account();
        itaAcc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
        itaAcc.XC_FirstName__c = 'TestAccount';
        itaAcc.XC_LastName__c = 'TestAccount';
        itaAcc.PrimaryEmail__c = 'test_res@email.com';
        itaAcc.XC_DocumentCountry__c = 'Italy';
        itaAcc.IdentityType__c='CF';
        itaAcc.IdentityNumber__c='TSTTTC80A01F591Y';
        itaAcc.XC_CommercialCode__c='AAA123';
        itaAcc.XC_InternalCommercialCode__c='BBB123';
        itaAcc.name = 'Test Account n ';
        insert itaAcc;
        Contact cont = new Contact();
        cont.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();
        cont.FirstName = 'Test contact';
        cont.LastName = 'Test contact';
        cont.Email = 'test_soho@email.com';  
        cont.AccountId = itaAcc.Id;
        cont.XC_CountryLegalEntity__c = 'ITALY';
        cont.XC_SkipTriggerIndividual__c = true; 
        cont.XC_MainLegalEntity__c = 'EnelXItalia';
        cont.XC_GiveDataToNew__c = 'Yes';
        insert cont;
        XC_Address__c address = new XC_Address__c();
        address.XC_Account__c = itaAcc.Id;
        address.XC_Address__c = 'Test';
        address.XC_City__c = 'Roma';
        address.XC_AddressCountry__c = 'Italy';
        address.XC_PostalCode__c = '00042';
        address.XC_AddressProvince__c = 'Roma';
        address.XC_StreetNumber__c = '11';
        address.XC_StreetType__c = 'Street'; 
        address.XC_Municipality__c   = 'Test';
        address.XC_InstallationAddress__c = TRUE;
        address.XC_DeliveryAddress__c = TRUE;
        address.XC_BillingAddress__c = TRUE;
        address.XC_PickUpPoint__c = TRUE;
        address.XC_PointOfSales__c = TRUE;
        address.XC_WareHouse__c = TRUE;
        insert address;
        Opportunity opp = new Opportunity();
        opp.Name ='Opportunity di Test';
        opp.XC_Contact__c = cont.Id;
        opp.AccountId = itaAcc.Id;
        opp.XC_Address__c = address.Id;
        opp.CloseDate = Date.newInstance(2030, 12, 31);
        opp.XC_Segment__c = 'B2C';
        opp.XC_LegalEntity__c = 'EnelXItalia';
        opp.XC_ProductCategoryOfInterest__c ='Photovoltaic';
        opp.XC_BusinessModel__c = 'Spot Sale';
        opp.StageName ='Draft';
        opp.XC_Source__c ='Web';
        opp.XC_ReceivingChannel__c='Email';
        opp.XC_CapexFullLife__c =6000;
        opp.XC_CustomerRequestDate__c =Date.newInstance(2022, 12, 30);
        opp.XC_QuotePresent__c = true;
        insert opp;
        opp.StageName='Qualified Potential Opportunity';
        update opp;
        opp.StageName='In Progress';
        update opp;
        List<User> us = new List<User>([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 2]);
        Id quoteRecId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        Id orderRecId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        NE__Order__c quote =new NE__Order__c();
        quote.RecordTypeId = quoteRecId;
        quote.XC_Country__c = 'Italy';
        quote.XC_Segment__c = 'B2C';
        quote.XC_LegalEntity__c='EnelXItalia';
        quote.NE__OptyId__c = opp.Id;
		quote.NE__Type__c='InOrder';							
        quote.XC_DeliveryAddress__c = opp.XC_Address__c;
        quote.NE__AccountId__c =opp.AccountId;
        System.runAs(us[0]){
            insert quote;
            quote.XC_Status__c = Label.XC_CL_Configuration_QuoteAccepted;
            update quote;
            update opp;
        }
        NE__Order__c order = new NE__Order__c();
        order.RecordTypeId = orderRecId;
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c='EnelXItalia';
        order.NE__OptyId__c = opp.Id;
        order.NE__Type__c='InOrder';							
        order.XC_DeliveryAddress__c = opp.XC_Address__c;
        order.NE__AccountId__c =opp.AccountId;
        System.runAs(us[1]){
            insert order;
        }
    }

    @isTest
    static void AssignOwnerConfigurationAndOpportunityPreApprovalTest() {
        Id orderRecId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        List<NE__Order__c> orders=[SELECT Id,NE__OptyId__c,OwnerId, RecordTypeId,XC_LegalEntity__c, XC_Segment__c,NE__AccountId__c,NE__Type__c  FROM NE__Order__c WHERE RecordTypeId= :orderRecId AND   XC_LegalEntity__c='EnelSole' AND XC_Segment__c = 'B2B' AND NE__Type__c='InOrder'];
        List<Opportunity> opps=[SELECT Id,XC_BusinessLine__c,AccountId,OwnerId,(SELECT Id FROM NE__Orders__r WHERE id= :orders[0].Id) FROM Opportunity WHERE XC_ProductCategoryOfInterest__c = 'Smart Lighting'];
        List<NE__OrderItem__c> orderItems=[SELECT Id,NE__OrderId__c  FROM NE__OrderItem__c WHERE NE__OrderId__c = :orders[0].Id AND NE__OrderId__r.NE__Type__c= :orders[0].NE__Type__c];
        List< NE__Order_Item_Attribute__c> orderItemAttributes=[SELECT Id,NE__Order_Item__c FROM NE__Order_Item_Attribute__c WHERE NE__Order_Item__c= :orderItems[0].Id];
        List<AccountTeamMember> accountTeamMembers=[SELECT UserId,AccountId,TeamMemberRole FROM AccountTeamMember WHERE AccountId = :opps[0].AccountId AND TeamMemberRole='Tecnico' ];
        Test.StartTest();
        XC_TR_Configuration_U_AssignOptyAndOpp.executeAssignOwnerOppConfPreAppr(orderItemAttributes);
        Test.StopTest();
        System.assertEquals(1,accountTeamMembers.size());
        System.assertEquals(1,orders.size());
        System.assertEquals(1,opps.size());
    }

   @isTest
    static void AssignOwnerConfigurationAndOpportunityPostApprovalTest() {
        Id orderRecId=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        Map<Id,NE__Order__c> mapOrder=new Map<Id,NE__Order__c>([SELECT Id,NE__OptyId__c,OwnerId, RecordTypeId,XC_LegalEntity__c, XC_Segment__c,NE__AccountId__c FROM NE__Order__c WHERE RecordTypeId= :orderRecId AND   XC_LegalEntity__c='EnelSole' AND XC_Segment__c = 'B2B' AND NE__Type__c='InOrder']);
        List<NE__Order__c> orderList=mapOrder.values();
        List<Opportunity> opps=[SELECT Id,XC_BusinessLine__c,AccountId,OwnerId,StageName,(SELECT Id FROM NE__Orders__r WHERE Id= :orderList[0].Id ) FROM Opportunity WHERE  XC_BusinessLine__c='eCity' AND XC_Segment__c = 'B2B' AND XC_LegalEntity__c = 'EnelXItalia']; 
        List<Opportunity> oppInts=new  List<Opportunity>();
        List<Opportunity> oppNews=new  List<Opportunity>();
        Set<Id> ids= new Set<Id> ();
        for(Opportunity opp : opps){
           opp.StageName='Qualified Potential Opportunity';
           ids.add(opp.Id);
        }
        update opps;
        for(Opportunity opp : opps){
            opp.StageName='In Progress';
            ids.add(opp.Id);
         }
        update opps;
        Map<Id,NE__Order__c> mapOrderOld=new Map<Id,NE__Order__c>([SELECT Id,NE__OptyId__c,OwnerId, RecordTypeId,XC_LegalEntity__c, XC_Segment__c,NE__AccountId__c,XC_CapexFullLife__c,XC_RequestForApproval__c FROM NE__Order__c WHERE  NE__OptyId__c IN :ids]);
        List<NE__Order__c> orderListOld=mapOrderOld.values();
        List<NE__Order__c> orderListNew=new  List<NE__Order__c>();
        for(NE__Order__c  ord: orderListOld){
            ord.XC_RequestForApproval__c ='Approval Received';
            orderListNew.add(ord);
        }
	    update orderListNew;
        Map<Id,NE__Order__c> mapOrderNew= new Map<Id,NE__Order__c>();
        for (NE__Order__c ordNew :orderListNew){
            mapOrderNew.put(ordNew.Id,ordNew);
        }
        List<AccountTeamMember> accountTeamMembers=[SELECT UserId,AccountId,TeamMemberRole FROM AccountTeamMember WHERE AccountId = :opps[0].AccountId AND TeamMemberRole='Tecnico Gestionale' ];
        Test.StartTest();
		XC_TR_Configuration_U_AssignOptyAndOpp.AssignOwnerConfigurationAndOpportunityAfterApproval(mapOrderOld,mapOrderNew);
        System.assertEquals(1,accountTeamMembers.size());
        System.assertEquals(1,orderListNew.size());
        System.assertEquals(1,opps.size());
		Test.StopTest();				
    }

    @isTest
    static void assignOwnerIfQuoteApprovedTest() {
        makeDataIta();
        Id orderRecordType = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Id quoteRecordType = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        Test.StartTest();
        NE__Order__c order = [SELECT Id, RecordTypeId, NE__OptyId__c, XC_Segment__c, NE__Type__c, XC_QuotePresent__c, OwnerId FROM NE__Order__c WHERE RecordTypeId =: orderRecordType LIMIT 1];
        NE__Order__c quote = [SELECT OwnerId FROM NE__Order__c WHERE RecordTypeId =: quoteRecordType LIMIT 1];
		XC_TR_Configuration_U_AssignOptyAndOpp.assignOwnerIfQuoteApproved(new List<NE__Order__c>{order});
        System.assert(order.OwnerId == quote.OwnerId);
		Test.StopTest();				
    }
}
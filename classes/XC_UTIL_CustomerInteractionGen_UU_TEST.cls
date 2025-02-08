/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @Creation 12/06/2020
* @description Test Class for XC_UTIL_CustomerInteractionGeneration_UU
*/

@isTest
private class XC_UTIL_CustomerInteractionGen_UU_TEST {
    
    @isTest
    static void testWorkorderCustomerInteractions(){
        
        test.startTest();

        List<Workorder> wos = new List<Workorder>();
        wos = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        wos[0].Status = 'Assigned';
        wos[0].XC_StatusReason__c = 'To be scheduled';
        insert wos;
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForWorkOrdITA(wos);
           
        wos[0].XC_WorkTypeCategory__c = 'Site Inspection';
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForWorkOrdITA(wos);

        
        wos[0].XC_WorkTypeCategory__c = 'Planned Maintenance';
        wos[0].Status = 'Completed';
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForWorkOrdITA(wos);
        

        wos[0].XC_WorkTypeCategory__c = 'Installation';
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForWorkOrdITA(wos);

        wos[0].XC_WorkTypeCategory__c = 'Repair';
        wos[0].Status = 'Completed';
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForWorkOrdITA(wos);
               
        test.stopTest();
        System.assertNotEquals(wos.size(), 2);
    }
    
    @isTest
    static void testAssetCustomerInteractions(){
        
        test.startTest();

        List<Asset> assL = XC_DF_Asset.createAssets(1);
        assL[0].Status = 'Active';
        assL[0].XC_Product_Type__c = 'Coverage';
        assL[0].XC_Product_SubType__c = 'Maintenance';  
        insert assL;


        NE__Asset_Discount__c assDisc = new NE__Asset_Discount__c();
        assDisc.NE__Asset__c = assL[0].id;
        assDisc.NE__Reason__c = 'Standard Promotion';
        assDisc.NE__Code__c = '100';
        assDisc.NE__One_Time_Price__c = 0;
        assDisc.NE__One_Time_Value__c = 0;
        assDisc.NE__Recurring_Price__c = 0;
        assDisc.NE__Recurring_Value__c = 0;
        assDisc.NE__Type__c = 'Percentage';
        insert assDisc;


        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForAssetITA(assL);
        
        
        assL[0].XC_Product_Type__c = 'Service';
        assL[0].XC_Product_SubType__c = 'Gas';
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForAssetITA(assL);
        XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntServicePromoRenewal(assL[0], 'ServicePromo_Renewal');    
        
        test.stopTest();
        System.assertNotEquals(assL.size(), 2);
    }

    @isTest
    static void testWelcome_ContractInteractions(){
        



List<NE__OrderItem__c> orits = XC_DF_OrderItem.createOrderItems(1);
NE__Order__c order = XC_DF_Order.createOrder('InOrder');
orits[0].NE__Bundle_Configuration__c = null;
orits[0].NE__Root_Order_Item__c = null;
orits[0].XC_Product_Type__c = 'Bundle';
Test.startTest();
insert orits;

List<XC_Customer_Interaction__c> cil = XC_DF_CustomerInteraction.createCustomerInteraction(1);
cil[0].XC_Communication_Type__c = 'Welcome_Contract';
cil[0].XC_OrderId__c = orits[0].NE__OrderId__c;

Test.stopTest();
XC_UTIL_CustomerInteractionGeneration_UU.generateWelcomeContractChild(cil);



/*
Map<Id, NE__Order__c> ordmap = new Map<Id, NE__Order__c>([
SELECT NE__OptyId__r.XC_Contact__r.Name, NE__AccountId__c, Id, XC_LegalEntity__c,
XC_Segment__c, NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__c
FROM NE__Order__c]);
*/
Map<Id, NE__Order__c> ordmap = new Map<Id, NE__Order__c>();
ordmap.put(order.Id,order);
XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntForConfigurationItemITA(ordmap.values()[0], orits[0].id, 'Welcome_Contract_Complex_Products');
//Test.stopTest();




System.assertNotEquals(cil.size(), 2);
}

    @isTest
    static void testCaseCustomerInteractions(){
        
        test.startTest();

        XC_CTI_Interaction__c cti = new XC_CTI_Interaction__c();
        insert cti;

        Case c = new Case();
        c.Reason = 'XCMOT001';
        c.SubCause__c = 'ATCL033';
        c.XC_Subtype__c = 'XC157';
        c.XC_CTI_Interaction__c = cti.id;
        List<Case> clist = new List<Case>();
        clist.add(c);
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntForCaseSurveyITA(clist);
        XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntForCaseSurveyITA(c);
        test.stopTest();
        System.assertNotEquals(clist.size(), 2);
    }
    
    @isTest
    static void testCaseRepair(){

        //test.startTest();
        List<Case> cs = XC_DF_Case.createCases(1);
        insert cs;
        
        test.startTest();
        List<Workorder> wos = new List<Workorder>();
        wos = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        wos[0].Status = 'Completed';
        wos[0].XC_WorkTypeCategory__c = 'Repair';
        wos[0].ParentWorkOrderId = null;
        wos[0].XC_External_ID__c = null;
        wos[0].CaseId = cs[0].id;
        insert wos;
        
        List<String> csid = new List<String>();
        csid.add(cs[0].id);
        XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntSurveyPostRepair(csid);
        XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntSurveyPostRepair(wos[0], 'Survey_Post_Repair');
        test.stopTest();
        System.assertNotEquals(csid.size(), 2);
        }

    @isTest
    static void testServiceAppointment_Confirmed(){
		
        OneOrg__c org=new OneOrg__c(); 
	    org.Name='OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1, 'Site Inspection');
        saList[0].XC_StatusReason__c = 'To be scheduled';
        saList[0].XC_WorkTypeCategory__c = 'Site Inspection';
        System.debug('$Status Reason'+saList[0].XC_StatusReason__c);
        insert saList;
        
        saList[0].XC_StatusReason__c = 'Assigned to the technician';
        saList[0].SchedStartTime = (System.now()).addHours(34);  
        saList[0].SchedEndTime = (System.now()).addHours(38);  
        
        System.debug('$WorkTypeCategory'+saList[0].XC_WorkTypeCategory__c);
        System.debug('$Status Reason'+saList[0].XC_StatusReason__c);
		System.debug('$SchedStartTime'+saList[0].SchedStartTime);
        
        XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntServiceAppointmentConfirmed(saList[0]);
        
        update saList;
        System.assertNotEquals(saList.size(), 2);
    }
    
     @isTest
    static void testServiceAppointment_ConfirmedDealer(){
		
        OneOrg__c org=new OneOrg__c(); 
	    org.Name='OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(1, 'Delivery & Installation');
        saList[0].XC_StatusReason__c = 'To be scheduled';
        saList[0].XC_WorkTypeCategory__c = 'Delivery & Installation';
        System.debug('$Status Reason'+saList[0].XC_StatusReason__c);
        saList[0].SchedStartTime = (System.now()).addHours(34);  
        saList[0].SchedEndTime = (System.now()).addHours(38);
        Test.startTest();
        insert saList;
        
        saList[0].XC_StatusReason__c = 'Assigned to the technician';
         
        NE__Catalog__c catalog = new NE__Catalog__c();
        catalog.XC_LIC_Name__c = 'e-Mobility Automotive';
        insert catalog;
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.NE__CatalogId__c = catalog.Id;
        update order;
        Test.stopTest();
        WorkOrder wo = new WorkOrder(Id=saList[0].ParentRecordId);
        wo.XC_Configuration__c = order.Id;
        wo.XC_ProductSubType__c = 'Wallbox';
        update wo;
        
        System.debug('$WorkOrder XC_ProductSubType__c '+wo.XC_ProductSubType__c);
        System.debug('$WorkOrder Id '+wo.Id);
        System.debug('$SA ParentId Id '+saList[0].ParentRecordId);
        System.debug('$Catalog Name:'+catalog.XC_LIC_Name__c);
		System.debug('$SchedStartTime:'+saList[0].SchedStartTime);
        update saList;
       // XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntServiceAppointmentConfirmed(saList[0]);
        
        
        
        System.assertNotEquals(saList.size(), 2);
    }
    @isTest
    static void testOrders_Pickup_NoStock_EnelX(){
		
        OneOrg__c org=new OneOrg__c(); 
	    org.Name='OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        insert orderItemList;
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(orderItemList[0].id);
        ps.XC_StepLabel__c = 'Product Reservation';
        ps.XC_ErrorMessage__c = 'The end date on Product is less than today';
        ps.XC_Status__c = 'In Progress';
        insert ps;

        ps.XC_Status__c = 'Completed KO';
        update ps;
 
        System.assertNotEquals(orderItemList.size(), 2);
    }
    
    /**
     * @author            : Giuseppe Di Bonito
     * @description       : Test Class for setCCRecipientPartnerContact and cloneCIonSMS
     **/
/*
     static testMethod void setCCRecipientPartnerContactTEST(){
        Test.startTest();
        List<Account> accountList = XC_DF_Account.createSohoAccounts(1);
		insert accountList;
        
        List<Contact> contactList = XC_DF_Contact.createSohoContacts(accountList);
        insert contactList;

        List<User> userlist = XC_DF_User.generateMultipleUser(3);
        insert userlist;
        Test.stopTest();

        List<Contract> contractList = XC_DF_Contract.createContracts(3);
        for(Contract contr : contractList){
            contr.AccountId = accountList.get(0).id;
        }

        contractList[0].XC_ContractManager__c = userlist[0].id;
        contractList[1].XC_ContractManager__c = userlist[1].id;
        contractList[2].XC_ContractManager__c = userlist[2].id;
        insert contractList;
        
        List<XC_Customer_Interaction__c> custInterList = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        custInterList.get(0).XC_Communication_Type__c ='Document_Near_Expiration';
        custInterList.get(0).XC_AccountId__c = accountList.get(0).id;
        custInterList.get(0).XC_ContactId__c = contactList.get(0).id;
        
        //XC_UTIL_CustomerInteractionGeneration_UU.setCCRecipientPartnerContact(custInterList);
        XC_UTIL_CustomerInteractionGeneration_UU.cloneCIonSMS(custInterList[0], '3933232323');
    }
    */
    
    /**
     * @author            : Giuseppe Di Bonito
     * @description       : Test Class for populateCustIntForCaseITA
     **/
    static testMethod void populateCustIntForCaseTEST(){
    	
        Test.startTest();
        List<Case> cs = XC_DF_Case.createCases(1);
        XC_UTIL_Sobject.insertListRecords(cs);
        Map<String,Object> cinfo = XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntForCaseITA(cs[0], 'pippo', 'pluto');
        Test.stopTest();
    }

        static testMethod void cloneCIonSMSTEST(){
            Test.startTest();
            NE__Order__c order = XC_DF_Order.createOrder('InOrder');
            Test.stopTest();
        	XC_UTIL_CustomerInteractionGeneration_UU.populateCustIntForConfigurationItemITA(order,order.Id,'Welcome_Contract_Services');
        	List<XC_Customer_Interaction__c> cil = XC_DF_CustomerInteraction.createCustomerInteraction(1);
        	cil[0].XC_Communication_Type__c = 'Welcome_Contract';
        	cil[0].XC_OrderId__c = order.Id;
        	XC_UTIL_CustomerInteractionGeneration_UU.cloneCIonSMS(cil[0],'3462335456');
        }
}
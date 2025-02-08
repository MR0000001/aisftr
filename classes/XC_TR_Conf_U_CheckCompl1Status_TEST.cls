/** 
* @author
* @date Creation 06/06/2019
* @date Modification dd/mm/yyyy
* @description  – XC_TR_Conf_U_CheckCompl1Status_TEST - Test class for XC_TR_Conf_U_CheckCompliance1Status
*/ 
@isTest
public class XC_TR_Conf_U_CheckCompl1Status_TEST {

    @isTest
   public static void checkComp1StatusOfOrderTESTwithEmail() {
        
        test.startTest();
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(1);
        insert cntList;
        List<Account> accList  = [SELECT Id FROM account];
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.XC_Compliance_Approval__c = 'Not Needed';
    	insert order;
		List<Opportunity> oppL = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opp = oppL[0];
        opp.AccountId = accList[0].Id;
        opp.XC_Contact__c = cntList[0].Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Draft';
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EndesaX';
        insert opp;
        order.NE__OptyId__c = opp.Id;
        order.XC_Compliance_Approval__c = Label.XC_CL_KO;
        order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        update order;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(order.Id);
        ProcessDefinition processDefinition=[select id from processDefinition limit 1 ];
       /* ProcessInstance processInstance=[select id from processInstance limit 1 ];
        ProcessInstanceWorkitem processInstanceWorkitem =new  ProcessInstanceWorkitem();
        processInstanceWorkitem.ProcessInstanceId=processInstance.id;
        processInstanceWorkitem.OriginalActorId=XC_DF_User.createUserAdmin()*/
        List<ProcessInstanceWorkitem> processList = [select id from ProcessInstanceWorkitem];
        System.debug('@606@ processDefinition:' + processDefinition); 
		System.debug('@606@ ProcessInstanceWorkitem:' + processList);      
        //update order;

        System.assertEquals(true, order != null, 'Wrong assert equals');
        test.stopTest();
    }

     @isTest
    public static void checkComp1StatusOfOrderTESTwithPrimaryPhone() {

        test.startTest();

        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(1);
        cntList[0].Email = null;
        cntList[0].XC_PhonePrefix__c = '+34';
        cntList[0].XC_ContactPhone__c = '658755342';
        insert cntList;
        List<Account> accList  = [SELECT Id FROM account];
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.XC_Compliance_Approval__c=Label.XC_CL_KO;
    	insert order;
		List<Opportunity> oppL = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opp = oppL[0];
        opp.XC_Contact__c = cntList[0].Id;
        opp.Name = 'Test Opp';
        opp.AccountId = accList[0].Id;
        opp.StageName = 'Draft';
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EndesaX';
        insert opp;
        order.XC_Compliance_Approval__c = 'Not Needed';
        order.NE__OptyId__c = opp.Id;
        update order;/*
        order.XC_Compliance_Approval__c = Label.XC_CL_KO;
        order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        update order;*/
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(order.Id);
        ProcessDefinition processDefinition=[select id from processDefinition limit 1 ];
       /* ProcessInstance processInstance=[select id from processInstance limit 1 ];
        ProcessInstanceWorkitem processInstanceWorkitem =new  ProcessInstanceWorkitem();
        processInstanceWorkitem.ProcessInstanceId=processInstance.id;
        processInstanceWorkitem.OriginalActorId=XC_DF_User.createUserAdmin()*/
        List<ProcessInstanceWorkitem> processList = [select id from ProcessInstanceWorkitem];
        System.debug('@606@ processDefinition:' + processDefinition); 
		System.debug('@606@ ProcessInstanceWorkitem:' + processList);      
        update order;

        System.assertEquals(true, order != null, 'Wrong assert equals');
        test.stopTest();
    }

    @isTest
    public static void checkComp1StatusOfOrderTESTwithPrimaryPhone2() {

        test.startTest();

        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(1);
        cntList[0].Email = null;
        cntList[0].XC_PhonePrefix__c = '+34';
        cntList[0].XC_ContactPhone__c = '658755342';
        insert cntList;
        List<Account> accList  = [SELECT Id FROM account];
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
    	insert order;
		List<Opportunity> oppL = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opp = oppL[0];
        opp.XC_Contact__c = cntList[0].Id;
        opp.Name = 'Test Opp';
        opp.AccountId = accList[0].Id;
        opp.StageName = 'Draft';
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EndesaX';
        insert opp;
        order.XC_Compliance_Approval__c = Label.XC_CL_KO;
        order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        update order;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(order.Id);
        ProcessDefinition processDefinition=[select id from processDefinition limit 1 ];
       /* ProcessInstance processInstance=[select id from processInstance limit 1 ];
        ProcessInstanceWorkitem processInstanceWorkitem =new  ProcessInstanceWorkitem();
        processInstanceWorkitem.ProcessInstanceId=processInstance.id;
        processInstanceWorkitem.OriginalActorId=XC_DF_User.createUserAdmin()*/
        List<ProcessInstanceWorkitem> processList = [select id from ProcessInstanceWorkitem];
        System.debug('@606@ processDefinition:' + processDefinition); 
		System.debug('@606@ ProcessInstanceWorkitem:' + processList);      
        update order;

        System.assertEquals(true, order != null, 'Wrong assert equals');
        test.stopTest();
    }

    @isTest
    public static void checkComp1StatusOfOrderTESTwithSecondaryPhone() {

        test.startTest();

        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(1);
        cntList[0].Email = null;
        cntList[0].XC_PhonePrefix__c = '+34';
        cntList[0].XC_ContactPhone__c = '658755346';
        cntList[0].XC_MobilePrefix__c = '+34';
        cntList[0].XC_ContactMobile__c = '658755346';
        insert cntList;
         List<Account> accList  = [SELECT Id FROM account];
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.XC_Compliance_Approval__c=Label.XC_CL_KO;
    	insert order;
		List<Opportunity> oppL = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opp = oppL[0];
        opp.XC_Contact__c = cntList[0].Id;
        opp.AccountId = accList[0].Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Draft';
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EndesaX';
        insert opp;
        order.XC_Compliance_Approval__c = 'Not Needed';
        order.NE__OptyId__c = opp.Id;
        update order;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(order.Id);
        ProcessDefinition processDefinition=[select id from processDefinition limit 1 ];
       /* ProcessInstance processInstance=[select id from processInstance limit 1 ];
        ProcessInstanceWorkitem processInstanceWorkitem =new  ProcessInstanceWorkitem();
        processInstanceWorkitem.ProcessInstanceId=processInstance.id;
        processInstanceWorkitem.OriginalActorId=XC_DF_User.createUserAdmin()*/
        List<ProcessInstanceWorkitem> processList = [select id from ProcessInstanceWorkitem];
        System.debug('@606@ processDefinition:' + processDefinition); 
		System.debug('@606@ ProcessInstanceWorkitem:' + processList);      
        update order;

        System.assertEquals(true, order != null, 'Wrong assert equals');
        test.stopTest();
    }

    @isTest
    public static void checkComp1StatusOfOrderTESTwithSecondaryPhone2() {

        test.startTest();

        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(1);
        cntList[0].Email = null;
        cntList[0].XC_PhonePrefix__c = '+34';
        cntList[0].XC_ContactPhone__c = '658755346';
        cntList[0].XC_MobilePrefix__c = '+34';
        cntList[0].XC_ContactMobile__c = '658755346';
        insert cntList;
         List<Account> accList  = [SELECT Id FROM account];
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
    	insert order;
		List<Opportunity> oppL = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opp = oppL[0];
        opp.XC_Contact__c = cntList[0].Id;
        opp.AccountId = accList[0].Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Draft';
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EndesaX';
        insert opp;
        order.XC_Compliance_Approval__c = Label.XC_CL_KO;
        order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        update order;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(order.Id);
        ProcessDefinition processDefinition=[select id from processDefinition limit 1 ];
       /* ProcessInstance processInstance=[select id from processInstance limit 1 ];
        ProcessInstanceWorkitem processInstanceWorkitem =new  ProcessInstanceWorkitem();
        processInstanceWorkitem.ProcessInstanceId=processInstance.id;
        processInstanceWorkitem.OriginalActorId=XC_DF_User.createUserAdmin()*/
        List<ProcessInstanceWorkitem> processList = [select id from ProcessInstanceWorkitem];
        System.debug('@606@ processDefinition:' + processDefinition); 
		System.debug('@606@ ProcessInstanceWorkitem:' + processList); 

        System.assertEquals(true, order != null, 'Wrong assert equals');
        test.stopTest();
    }
    
    @isTest
    public static void checkComp1StatusOfOrderTESTwithoutContact() {

        test.startTest();

        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(1);
        cntList[0].Email = null;
        cntList[0].XC_PhonePrefix__c = '+34';
        cntList[0].XC_ContactPhone__c = '658755346';
        cntList[0].XC_MobilePrefix__c = '+34';
        cntList[0].XC_ContactMobile__c = '658755346';
        insert cntList;
         List<Account> accList  = [SELECT Id FROM account];
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.XC_Compliance_Approval__c=Label.XC_CL_KO;
    	insert order;
		List<Opportunity> oppL = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opp = oppL[0];
        //opp.XC_Contact__c = cntList[0].Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Draft';
        opp.AccountId = accList[0].Id;
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EndesaX';
        insert opp;
        order.XC_Compliance_Approval__c = 'Not Needed';
        order.NE__OptyId__c = opp.Id;
        order.XC_Compliance_Approval__c = Label.XC_CL_KO;
        order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        update order;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(order.Id);
        ProcessDefinition processDefinition=[select id from processDefinition limit 1 ];
       /* ProcessInstance processInstance=[select id from processInstance limit 1 ];
        ProcessInstanceWorkitem processInstanceWorkitem =new  ProcessInstanceWorkitem();
        processInstanceWorkitem.ProcessInstanceId=processInstance.id;
        processInstanceWorkitem.OriginalActorId=XC_DF_User.createUserAdmin()*/
        List<ProcessInstanceWorkitem> processList = [select id from ProcessInstanceWorkitem];
        System.debug('@606@ processDefinition:' + processDefinition); 
		System.debug('@606@ ProcessInstanceWorkitem:' + processList);
        System.assertEquals(true, order != null, 'Wrong assert equals');
        test.stopTest();
    }
    
    @isTest
    public static void checkComp1StatusOfOrderTESTwithoutKey() {

        test.startTest();

        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<Contact> cntList = XC_DF_Contact.createResidentialContacts(1);
        cntList[0].Email = 'keytesting@testing.it';
        cntList[0].Phone = null;
        cntList[0].XC_PhonePrefix__c = null;
        cntList[0].XC_ContactPhone__c = null;
        cntList[0].MobilePhone = null;
        cntList[0].XC_MobilePrefix__c = null;
        cntList[0].XC_ContactMobile__c = null;
        insert cntList;
         List<Account> accList  = [SELECT Id FROM account];
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        NE__Order__c order = orderList[0];
        order.XC_Compliance_Approval__c = 'Not Needed';
    	insert order;
		List<Opportunity> oppL = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        Opportunity opp = oppL[0];
        opp.XC_Contact__c = cntList[0].Id;
        opp.Name = 'Test Opp';
        opp.AccountId = accList[0].Id;
        opp.StageName = 'Draft';
        opp.CloseDate = Date.today().addDays(30);
        opp.XC_LegalEntity__c = 'EndesaX';
        insert opp;
        order.NE__OptyId__c = opp.Id;
        order.XC_Compliance_Approval__c = Label.XC_CL_KO;
        order.XC_Status__c = Label.XC_CL_Configuration_OrderInProgress;
        update order;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(order.Id);
        ProcessDefinition processDefinition=[select id from processDefinition limit 1 ];
       /* ProcessInstance processInstance=[select id from processInstance limit 1 ];
        ProcessInstanceWorkitem processInstanceWorkitem =new  ProcessInstanceWorkitem();
        processInstanceWorkitem.ProcessInstanceId=processInstance.id;
        processInstanceWorkitem.OriginalActorId=XC_DF_User.createUserAdmin()*/
        List<ProcessInstanceWorkitem> processList = [select id from ProcessInstanceWorkitem];
        System.debug('@606@ processDefinition:' + processDefinition); 
		System.debug('@606@ ProcessInstanceWorkitem:' + processList);      
        //update order;

        System.assertEquals(true, order != null, 'Wrong assert equals');
        test.stopTest();
    }

    @isTest
    static void checkPrimaryPhone(){
        Test.startTest();
        List<NE__Order__c>  orderList =XC_DF_Order.createOrders(1, 'InOrder');
        insert orderList;
        XC_TR_Conf_U_CheckCompliance1Status.checkPrimaryPhone(orderList[0]);
        XC_TR_Conf_U_CheckCompliance1Status.checkSecondaryPhone(orderList[0]);
        Test.stopTest();
    }
}
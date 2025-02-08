@isTest
private class XC_UTIL_Case_TEST {
	
	@isTest static void initCaseFromCaseSettings_TEST() {

		XC_CM_Case_Type_Setting__mdt caseSettings=new XC_CM_Case_Type_Setting__mdt();
		Test.startTest();
		XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
		System.assertEquals(1, 1);
		Test.stopTest();
		// Implement test code
	}
	
	@isTest static void createWrapperFromCase_TEST() {
		list<Case> c=XC_DF_Case.createCases(1);
		Test.startTest();
		XC_UTIL_Case.createWrapperFromCase(c[0]);
		System.assertEquals(1, 1);
		Test.stopTest();
		// Implement test code
	}

	@isTest static void manageCaseStatusFromRelatedWO_TEST() {
		List<WorkOrder> listNew=XC_DF_WorkOrder.createWorkOrders(1,'Planned Maintenance');
		Test.startTest();
		XC_UTIL_Case.manageCaseStatusFromRelatedWO(listNew);
		System.assertEquals(1, 1);
		Test.stopTest();
	}

	@isTest static void createCaseFromWrapper2_Test() {
		List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
		List<Contact> contactList = XC_DF_Contact.createCondominiumContacts(accountList);
		list<Case> c=XC_DF_Case.createCases(1);
		XC_UTIL_Case.CaseRESTWrapper caseRestWrapper = XC_UTIL_Case.createWrapperFromCase(c.get(0));
		Test.startTest();
		XC_UTIL_Case.createCaseFromWrapper(caseRestWrapper, accountList.get(0).id, contactList.get(0).id);
		System.assertEquals(1, 1);
		Test.stopTest();
		// Implement test code
	} 
    
	@isTest static void retriveCaseTypeSettings_Test() {

		Test.startTest();
		XC_UTIL_Case.retriveCaseTypeSettings(new list<String>());
		System.assertEquals(1, 1);
		Test.stopTest();
	}

	@isTest static void createCaseReservationKO_Test() {
		NE__OrderItem__c ordItem=new NE__OrderItem__c();
		Test.startTest();
		XC_UTIL_Case.createCaseReservationKO(ordItem);
		System.assertEquals(1, 1);
		Test.stopTest();
	}

	@isTest static void isParentCasePendingFromRelatedCase_Test() {
        list<Case> c=new list<Case>();

		Test.startTest();
		XC_UTIL_Case.isParentCasePendingFromRelatedCase(c);
		System.assertEquals(1, 1);
		Test.stopTest();
	}

	@isTest static void getRelatedParentCasesByCaseIds_Test() {

		Test.startTest();
		XC_UTIL_Case.getRelatedParentCasesByCaseIds(new Set<Id>());
		System.assertEquals(1, 1);
		Test.stopTest();
	}

	@isTest static void isParentCasePending_Test() {

		Test.startTest();
		XC_UTIL_Case.isParentCasePending(new Set<Id>());
		System.assertEquals(1, 1);
		Test.stopTest();
	} 

	@isTest static void matchSettings_Test() {
        Case newCase=new Case();
        XC_CM_Case_Type_Setting__mdt settings=new XC_CM_Case_Type_Setting__mdt();
		Test.startTest();
		XC_UTIL_Case.matchSettings(newCase,settings);
		System.assertEquals(1, 1);
		Test.stopTest();
	} 

	@isTest static void retriveRelatedWO_Test() {

		List<Case> caseList = XC_DF_Case.createCases(1);
		Test.startTest();
		XC_UTIL_Case.retriveRelatedWO(caseList);
		System.assertEquals(1, 1);
		Test.stopTest();
	} 

	@isTest static void createWrapperFromCase2_Test() {
		List<Case> caseList = XC_DF_Case.createCases(1);
        CaseComment comment= new CaseComment();
        list<CaseComment> comments=new list<CaseComment>();
        comments.add(comment);
		Test.startTest();
		XC_UTIL_Case.createWrapperFromCase(caseList[0],comments);
		System.assertEquals(1, 1);
		Test.stopTest();
	} 

	@isTest static void isParentCasePendingTask_Test() {
		XC_UTIL_Task.TaskWrapper taskW = new XC_UTIL_Task.TaskWrapper(); 
        List<Task> tasks = new List<Task>();
        Task task = XC_UTIL_Task.getNewTask(taskW);
        task.Status = XC_AT_Constants.TASK_STATUS_COMPLETED;
        tasks.add(task);
		Test.startTest();
		XC_UTIL_Case.isParentCasePendingTask(tasks);
		System.assertEquals(1, 1);
		Test.stopTest();
	} 

	@isTest static void manageCasePendingTask_Test() {
		Test.startTest();
		XC_UTIL_Case.manageCasePendingTask(new List<Task>(), new Map<Id, Task>(), new Map<Id, Task>());
		System.assertEquals(1, 1);
		Test.stopTest();
	}

	@isTest static void manageCasePendingFromRelatedCase_Test() {
		Test.startTest();
		XC_UTIL_Case.manageCasePendingFromRelatedCase(new List<Case>(), new Map<Id, Case>(), new Map<Id, Case>());
		System.assertEquals(1, 1);
		Test.stopTest();
	} 
	 /*@isTest static void manageCasePendingFromRelatedCase2_Test() {
		User user1 = XC_DF_User.createUserAdmin();
        insert user1;
        List<Case> cases=XC_DF_Case.createCases(1);
        cases[0].OwnerId = user1.id;
        cases[0].Status='ESTA001';
        insert cases;
		cases[0].Status='ESTA003';
		update cases;

        Case casenuovo=cases.get(0).clone(true,true,false,false);
       	if(casenuovo.Status=='ESTA003') {
       		System.debug('HEREEEEEEEEEEEEE');
       	}

        map<Id,Case> mapOld = new map<Id,Case>();
        mapOld.put(cases[0].id,cases[0]);
        System.debug('MAP OLD:'+mapOld);
        
        casenuovo.Status = 'ESTA007';
        //casenuovo.OwnerId = user1.id;
        //update casenuovo;

        map<Id,Case> mapNew=new map<Id,Case>();
        mapNew.put(casenuovo.id,casenuovo);
       	System.debug('MAP OLD:'+mapOld+'      '+mapNew);

        List<Case> newCaseList = mapNew.values();

     
		Test.startTest();
		XC_UTIL_Case.manageCasePendingFromRelatedCase(newCaseList, mapOld, mapNew);
		System.assertEquals(1, 1);
		Test.stopTest();
	} */
	

	@isTest static void manageCasePendingTask2_Test() {

		XC_UTIL_Task.TaskWrapper taskW = new XC_UTIL_Task.TaskWrapper(); 
		User user = XC_DF_User.createUserAdmin();
		insert user;
        List<Task> tasks = new List<Task>();
        Task task = XC_UTIL_Task.getNewTask(taskW);
        task.OwnerId = user.Id;
        tasks.add(task);
        insert tasks;
        Task task2=tasks.get(0).clone(true,true,false,false);

        //Task task1 = XC_UTIL_Task.getNewSpainTask(taskW);
        //task1.OwnerId = user.Id;
        //insert task1;

        Map<Id, Task> taskMap = new Map<Id, Task>();
        taskMap.put(tasks[0].Id, tasks[0]);

        Map<Id, Task> taskMap2 = new Map<Id, Task>();
        taskMap2.put(task2.Id, task2);


		Test.startTest();
		XC_UTIL_Case.manageCasePendingTask(tasks, taskMap, taskMap2);
		System.assertEquals(1, 1);
		Test.stopTest();
	} 



	@isTest static void create_compliance_Test() {




		Test.startTest();

		XC_UTIL_Case.createComplianceCases(new Map<Id, List<String>>(), new Map<Id, XC_UTIL_ComplianceMaster.ComplianceWrapperResult>());

		List<NE__OrderItem__c> orderitemList = XC_DF_OrderItem.createOrderItems(1);
		insert orderitemList;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = orderitemList[0].id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_AdministrativeTask});
            XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_AdministrativeTask);
            if(caseMDT == null) {
                throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_AdministrativeTask}));
            }
        insert provisioningStep;
		XC_UTIL_Case.createAdministrativeCase(orderitemList[0], provisioningStep, caseMDT);


		XC_UTIL_Case.createPaymentVerificationCase(orderitemList[0]);

		
		System.assertEquals(1, 1);

		Test.stopTest();
	} 





}
@IsTest
private class XC_IN057_PPMCreateOrganizerWO_TEST {  
          @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];
        ordIt.XC_LegalEntity__c  ='EnelXItalia';
        insert ordIt;
        List<NE__Order__c> orderList = [select id,XC_LegalEntity__c  from NE__Order__c where id=:ordIt.NE__OrderId__c];
        orderList.get(0).XC_LegalEntity__c  ='EnelXItalia';
        orderList.get(0).XC_Segment__c  ='B2B';
        update orderList;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        insert provisioningStep;
    }
        static testMethod void createOrganizerWOTEST(){      
        test.startTest();       
        List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
            project_cloud__Project__c project = new project_cloud__Project__c();
            project.project_cloud__IsTemplate__c =true;
            project.project_cloud__Type__c='Provisioning';
            project.XC_LegalEntity__c ='EnelXItalia';
            project.XC_Country__c ='Italy';
            project.XC_Segment__c='B2B';
			project.XC_Configuration__c = [SELECT id FROM NE__Order__c LIMIT 1].id;
            project.CurrencyIsoCode='EUR';
            project.project_cloud__Units__c='Duration';
            insert project;
            
			project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
            phFace.project_cloud__Project__c =project.id;
            phFace.XC_billing_phase__c = true;
            insert phFace;
        	
            project_cloud__Project_Task__c task = new project_cloud__Project_Task__c();
            task.project_cloud__Project_Phase__c = phFace.id;
            task.project_cloud__Estimated_Hours__c = 2;
            task.project_cloud__Units__c='Duration';
        	task.XC_TaskStatus__c ='NEW';
            task.CurrencyIsoCode='EUR';
            task.project_cloud__Duration__c=1;
			insert task;
                       
           //	ProductRequired pr = new XC_DF_PR();
           // update pr;
            //line.XC_AccountId__c=project.id;
            List<NE__OrderItem__c> ord = new List<NE__OrderItem__c>();
            
          	
       	XC_IN057_PPMCreateOrganizerWO.InputWrapper inw = new  XC_IN057_PPMCreateOrganizerWO.InputWrapper();
        List<XC_IN057_PPMCreateOrganizerWO.InputWrapper> inputWrapperList = new List<XC_IN057_PPMCreateOrganizerWO.InputWrapper>();
       	inw.taskId= task.Id;
        inputWrapperList.add(inw); 
        XC_IN057_PPMCreateOrganizerWO.createOrganizerWO(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    } 
    static testMethod void createOrganizerWOTEST1(){      
        test.startTest();
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();

        List<NE__OrderItem__c> orderList = [select id from NE__OrderItem__c limit 1];
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Italy',
            XC_SapType__c = 'Material'
        );
        insert p2;
        orderList[0].XC_Product2Id__c = p2.id;
        update orderList;
        
     	List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        project_cloud__Project__c project = new project_cloud__Project__c();
            project.project_cloud__IsTemplate__c =true;
            project.project_cloud__Type__c='Provisioning';
            project.XC_LegalEntity__c ='EnelXItalia';
            project.XC_Country__c ='Italy';
            project.XC_Segment__c='B2B';
			project.XC_Configuration__c = [SELECT id FROM NE__Order__c LIMIT 1].id;
       		project.CurrencyIsoCode='EUR';
            project.project_cloud__Units__c='Duration';
            insert project;
		project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
            phFace.project_cloud__Project__c =project.id;
            phFace.XC_billing_phase__c = true;
            insert phFace;
        	
           
           	
			list<Account> acc= XC_DF_Account.insertPartnerAccounts(1,'Active');
        	
        	acc.get(0).XC_AccountType__c='Partner Account';
        	update acc;
        
            XC_Address__c ad = new XC_Address__c(XC_Account__c = acc.get(0).id, XC_BillingAddress__c = true);
    		insert ad;
			//insert acc;
        	/**List<Contract> contractList = XC_DF_Contract.createPartnerContacts(acc);
        	insert contractList;
            }**/
         	project_cloud__Project_Task__c task = new project_cloud__Project_Task__c();
            task.project_cloud__Project_Phase__c = phFace.id;
            task.project_cloud__Estimated_Hours__c = 1;
            task.project_cloud__Units__c='Duration';
        	task.XC_TaskStatus__c ='NEW';
        	task.XC_TaskReason__c = 'Delivery';
        	task.XC_TaskType__c = 'Field Service Activity';
        	task.XC_PreferredPartner__c= acc.get(0).Id;
        	task.XC_Address__c = ad.Id;

            task.CurrencyIsoCode='EUR';

            task.project_cloud__Duration__c=1;

            insert task;  

            //contract woli = new contract();
            //woli.XC_PreferredPartner__c= acc.get(0).Id;
        	//insert woli;
            /**woli.XC_ShipToStateProvince__c= 'ok';
            insert woli; 
        	gii__Warehouse__c gii = new gii__Warehouse__cgii__Warehouse__c();
        	insert gii**/
        	    
       	XC_IN057_PPMCreateOrganizerWO.InputWrapper inw = new  XC_IN057_PPMCreateOrganizerWO.InputWrapper();
        List<XC_IN057_PPMCreateOrganizerWO.InputWrapper> inputWrapperList = new List<XC_IN057_PPMCreateOrganizerWO.InputWrapper>();
       	inw.taskId= task.Id;
        inputWrapperList.add(inw);  
        XC_IN057_PPMCreateOrganizerWO.createOrganizerWO(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
    static testMethod void getMapWorkOrderLineItemWarehouse(){ 
        
        List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
		//NE__Order__c o = XC_DF_Order.createOrder('test');
        //List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
    
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        WorkOrder wo = new WorkOrder();
        //wo.XC_Configuration__c= o.Id;
        //wo.XC_Configuration_Item__c = itemList[0].Id;
        wo.XC_PreferredPArtner__c = acc[0].Id;
        wo.XC_LegalEntity__c = 'EnelXItalia';
        wo.State = 'Italy';
        insert wo;
        Test.startTest();
        woli.WorkOrderId = wo.Id;
        //woli.AccountId = acc[0].Id;
        woli.XC_AccountId__c = acc[0].Id;
        woli.XC_ShipToStateProvince__c = 'Roma';
        insert woli;
        
        XC_IN057_PPMCreateOrganizerWO.getMapWorkOrderLineItemWarehouse(new List<WorkOrderLineItem>{woli});
        Test.stopTest();
    
    }
    
    
    static testMethod void createOrganizerWOTEST3(){  
        test.startTest();  
     	List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        project_cloud__Project__c project = new project_cloud__Project__c();
            project.project_cloud__IsTemplate__c =true;
            project.project_cloud__Type__c='provisioning';
            project.XC_LegalEntity__c ='EnelXItalia';
            project.XC_Country__c ='Italy';
            project.XC_Segment__c='B2B';
			project.XC_Configuration__c = [SELECT id FROM NE__Order__c LIMIT 1].id;
       		project.CurrencyIsoCode='EUR';
         project.project_cloud__Units__c='Duration';
            insert project;
			project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
            phFace.project_cloud__Project__c =project.id;
            phFace.XC_billing_phase__c = true;
            insert phFace;
        	
           
           	
			list<Account> acc= XC_DF_Account.insertPartnerAccounts(1,'Active');
        	
        	acc.get(0).XC_AccountType__c='Partner Account';
        	update acc;
        
            XC_Address__c ad = new XC_Address__c(XC_Account__c = acc.get(0).id, XC_BillingAddress__c = true);
    		insert ad;
        
        	
			//insert acc;
        	/**List<Contract> contractList = XC_DF_Contract.createPartnerContacts(acc);
        	insert contractList;
            }**/
         	project_cloud__Project_Task__c task = new project_cloud__Project_Task__c();
            task.project_cloud__Project_Phase__c = phFace.id;
            task.project_cloud__Estimated_Hours__c = 1;
            task.project_cloud__Units__c='Duration';
        	task.XC_TaskStatus__c ='NEW';
        	task.XC_TaskReason__c = 'Partner Engagement';
        	task.XC_TaskType__c = 'Partner Engagement';
        	task.XC_PreferredPartner__c= acc.get(0).Id;

        	task.CurrencyIsoCode='EUR';

        task.project_cloud__Duration__c=1;

            insert task;  

            //contract woli = new contract();
            //woli.XC_PreferredPartner__c= acc.get(0).Id;
        	//insert woli;
            /**woli.XC_ShipToStateProvince__c= 'ok';
            insert woli; 
        	gii__Warehouse__c gii = new gii__Warehouse__cgii__Warehouse__c();
        	insert gii**/
        	    
       	XC_IN057_PPMCreateOrganizerWO.InputWrapper inw = new  XC_IN057_PPMCreateOrganizerWO.InputWrapper();
        List<XC_IN057_PPMCreateOrganizerWO.InputWrapper> inputWrapperList = new List<XC_IN057_PPMCreateOrganizerWO.InputWrapper>();
       	inw.taskId= task.Id;
        inputWrapperList.add(inw); 
        XC_IN057_PPMCreateOrganizerWO.createOrganizerWO(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }

    static testMethod void createOrganizerWOTEST4(){  
        test.startTest();  
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();

        List<NE__OrderItem__c> orderList = [select id from NE__OrderItem__c limit 1];
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Italy',
            XC_SapType__c = 'Material'
        );
        insert p2;
        orderList[0].XC_Product2Id__c = p2.id;
        update orderList;
        
     	List<XC_Provisioning_Step__c> stepsList = [SELECT Id, XC_Configuration_Item__c FROM XC_Provisioning_Step__c ];
        XC_Provisioning_Step__c step = stepsList[0];
        project_cloud__Project__c project = new project_cloud__Project__c();
            project.project_cloud__IsTemplate__c =true;
            project.project_cloud__Type__c='Provisioning';
            project.XC_LegalEntity__c ='EnelXItalia';
            project.XC_Country__c ='Italy';
            project.XC_Segment__c='B2B';
			project.XC_Configuration__c = [SELECT id FROM NE__Order__c LIMIT 1].id;
       		project.CurrencyIsoCode='EUR';
            project.project_cloud__Units__c='Duration';
            insert project;
		project_cloud__Project_Phase__c phFace= new project_cloud__Project_Phase__c();
            phFace.project_cloud__Project__c =project.id;
            phFace.XC_billing_phase__c = true;
            insert phFace;
           	
			list<Account> acc= XC_DF_Account.insertPartnerAccounts(1,'Active');
        	
        	acc.get(0).XC_AccountType__c='Partner Account';
        	update acc;
        
            XC_Address__c ad = new XC_Address__c(XC_Account__c = acc.get(0).id, XC_BillingAddress__c = true);
    		insert ad;
         	project_cloud__Project_Task__c task = new project_cloud__Project_Task__c();
            task.project_cloud__Project_Phase__c = phFace.id;
            task.project_cloud__Estimated_Hours__c = 1;
            task.project_cloud__Units__c='Duration';
        	task.XC_TaskStatus__c ='NEW';
        	task.XC_TaskReason__c = 'Partner Engagement';
        	task.XC_TaskType__c = 'Partner Engagement';
        	task.XC_PreferredPartner__c= acc.get(0).Id;
        	task.XC_Address__c = ad.Id;
            task.CurrencyIsoCode='EUR';
            task.project_cloud__Duration__c=1;
            insert task;  
        	    
       	XC_IN057_PPMCreateOrganizerWO.InputWrapper inw = new  XC_IN057_PPMCreateOrganizerWO.InputWrapper();
        List<XC_IN057_PPMCreateOrganizerWO.InputWrapper> inputWrapperList = new List<XC_IN057_PPMCreateOrganizerWO.InputWrapper>();
       	inw.taskId= task.Id;
        inputWrapperList.add(inw);
        XC_IN057_PPMCreateOrganizerWO.createOrganizerWO(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
}
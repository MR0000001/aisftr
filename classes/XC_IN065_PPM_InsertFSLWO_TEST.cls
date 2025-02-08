@isTest
public class XC_IN065_PPM_InsertFSLWO_TEST {
    @testSetup
    private static void setup() {

        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);
		order.XC_Segment__c = 'B2B';
        order.XC_Country__c = 'Italy';
        order.XC_LegalEntity__c = 'EnelXItalia';
        order.XC_CallType__c = 'Inbound Call';
        update order;
        
        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
	

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        item.NE__BaseOneTimeFee__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id
        FROM XC_BillingProfileLineItem__c
        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        if( listBillingProfiles[0].NE__Payment__c == null || listBillingProfiles[0].NE__Payment__c == ''){
            listBillingProfiles[0].NE__Payment__c = 'Bank Transfer';
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Bank Transfer';
            update listBillingProfiles[0];
        }
        if( item.XC_PaymentMethod__c == null || item.XC_PaymentMethod__c == ''){
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Bank Transfer';
        }

        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        update item;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item,
                Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel,
                'Payment');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        insert listAsset;
        
        
        XC_Milestone__c mile = new XC_Milestone__c();
        mile.XC_Rate__c = 100;
         mile.XC_StartDate__c = Date.today();
         mile.XC_OrderItem__c = item.Id;
        insert mile;
        
        
        //Project
		project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTest',XC_ConfigurationItem__c = item.id );
				
		insert p;

		//Create a new phase
		project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                                                                                     project_cloud__Project__c=p.id);
		insert ph;
                                                   
		//Created a Project Task
		project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Project Task Test',
		    	                                                                  project_cloud__Duration__c=1,
		    	                                                                  project_cloud__Project_Phase__c=ph.id,
		    	                                                                  //XC_TaskType__c=Constants.PPM_PROJECT_TASK_TYPE_BILLING,
		    	                                                                  //XC_TaskReason__c='Milestone',
		    	                                                                  XC_TaskStatus__c='New',
		    	                                                                  project_cloud__Autonomous_Start__c=system.today(), 
                                                                             	  project_cloud__Estimated_Hours__c = 1,
                                                                             	  XC_Milestone__c = mile.Id,
                                                                             	  XC_OrderItem__c = item.id
		    	                                                                  );
		    insert pt;
			/*pt.XC_TaskStatus__c = 'Planned';
        	update pt;
		    pt.XC_TaskStatus__c = 'Work in Progress';
        	update pt;*/
        
       		List<XC_Address__c> addList = XC_DF_Address.createAddress(accList);
        	insert addList;

    }
    
    @isTest
    static void methodTest(){
        XC_Address__c address = [SELECT id FROM XC_Address__c LIMIT 1];
        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c  
        LIMIT 1];
        
        ps.XC_TaskStatus__c = 'Planned';
        update ps;
        
        ps.XC_TaskStatus__c = 'Work In Progress';
        update ps;
        
        project_cloud__Project__c p = [SELECT Id,XC_Status__c
        FROM project_cloud__Project__c  
        LIMIT 1];
        
        p.XC_Status__c = 'Planned';
        update p;
        
        p.XC_Status__c = 'Work in Progress';
        update p;
        
        List<XC_IN065_PPM_InsertFSLWO.InputWrapper> inputWrapperList = new List<XC_IN065_PPM_InsertFSLWO.InputWrapper>();
        XC_IN065_PPM_InsertFSLWO.InputWrapper wr = new XC_IN065_PPM_InsertFSLWO.InputWrapper();
        wr.taskId = ps.Id;
        wr.DueDate              = Date.Today();
        wr.LegalEntity          = 'EnelXItalia';
        wr.ProjectTask          = ps.Id;
        wr.ToProject            = true;
        wr.Address 				= (String) address.id;

        inputWrapperList.add(wr);
        
        try{
        XC_IN065_PPM_InsertFSLWO.createWO(inputWrapperList);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
        
    @isTest
    static void methodTest2(){
        XC_Address__c address = [SELECT id FROM XC_Address__c LIMIT 1];
        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c  
        LIMIT 1];
        
        ps.XC_TaskStatus__c = 'Planned';
        update ps;
        
        ps.XC_TaskStatus__c = 'Work In Progress';
        update ps;
        
        project_cloud__Project__c p = [SELECT Id,XC_Status__c
        FROM project_cloud__Project__c  
        LIMIT 1];
        
        p.XC_Status__c = 'Planned';
        update p;
        
        p.XC_Status__c = 'Work in Progress';
        update p;
        
        List<XC_IN065_PPM_InsertFSLWO.InputWrapper> inputWrapperList = new List<XC_IN065_PPM_InsertFSLWO.InputWrapper>();
        XC_IN065_PPM_InsertFSLWO.InputWrapper wr = new XC_IN065_PPM_InsertFSLWO.InputWrapper();
        wr.taskId = ps.Id;
        wr.DueDate              = Date.Today();
        wr.LegalEntity          = 'EnelXItalia';
        wr.ProjectTask          = ps.Id;
        wr.ToProject            = true;
		wr.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wr.OwnerID = UserInfo.getUserId();
        wr.Address 				= (String) address.id;
        inputWrapperList.add(wr);
        
        try{
        XC_IN065_PPM_InsertFSLWO.createWO(inputWrapperList);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    
     @isTest
    static void methodTest3(){
        XC_Address__c address = [SELECT id FROM XC_Address__c LIMIT 1];
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Malfunctioning');
        workTypeToInsert.XC_LegalEntity__c='EnelXItalia';
        insert workTypeToInsert;
        project_cloud__Project_Task__c ps = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c  
        LIMIT 1];
        
        ps.XC_TaskStatus__c = 'Planned';
        update ps;
        
        ps.XC_TaskStatus__c = 'Work In Progress';
        update ps;
        
        project_cloud__Project__c p = [SELECT Id,XC_Status__c
        FROM project_cloud__Project__c  
        LIMIT 1];
        
        p.XC_Status__c = 'Planned';
        update p;
        
        p.XC_Status__c = 'Work in Progress';
        update p;
        
        List<XC_IN065_PPM_InsertFSLWO.InputWrapper> inputWrapperList = new List<XC_IN065_PPM_InsertFSLWO.InputWrapper>();
        XC_IN065_PPM_InsertFSLWO.InputWrapper wr = new XC_IN065_PPM_InsertFSLWO.InputWrapper();
        wr.taskId = ps.Id;
        wr.DueDate              = Date.Today();
        wr.LegalEntity          = 'EnelXItalia';
        wr.ProjectTask          = ps.Id;
        wr.ToProject            = true;
		wr.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        wr.OwnerID = UserInfo.getUserId();
        wr.WorkTypeCategory ='Malfunctioning';
        wr.Address 				= (String) address.id;
        inputWrapperList.add(wr);
        
        try{
        XC_IN065_PPM_InsertFSLWO.createWO(inputWrapperList);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}
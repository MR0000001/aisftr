/**
* @author dpalamides
* @date Creation 26/05/2020
* @date Modification dd/mm/yyyy
* @description  – XC_IN055_PTask_U_ManageInvoice_TEST - Test class for XC_IN055
*/ 
@isTest
public class XC_IN055_PTask_U_ManageInvoice_TEST {
/**
    * @author dpalamides
    * @date Creation 26/05/2020
    * @description insert records
    */ 
    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c ordIt = orderItemList[0];
        insert ordIt;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        Asset ast = assetList[0];
        ast.XC_Configuration_Item__c = ordIt.Id;
        insert ast;
        
        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;

        String orgId = UserInfo.getOrganizationId();
        List<XC_CM_ZuoraOAuth__mdt> zuoraList = [SELECT Id, XC_EntityId__c, XC_EntityName__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE '%Spain%'  AND XC_OrgId__c =: orgId];
        List<zqu__BillingEntity__c> billingEntityList = new List<zqu__BillingEntity__c>();
        Integer i = 1;
        for(XC_CM_ZuoraOAuth__mdt z : zuoraList){
            zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
            billingEntity.zqu__EntityID__c = z.XC_EntityId__c;
            billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50' + i;
            billingEntity.zqu__ZuoraID__c = '2000378' + i;
            billingEntity.zqu__EntityName__c = z.XC_EntityName__c;
            billingEntityList.add(billingEntity);
            i++;
        }
        insert billingEntityList;
         XC_DF_DataMap.createDataMap('Order2Zquote', billingEntityList[0]);
        
        XC_Milestone__c mile = new XC_Milestone__c();
        mile.XC_Rate__c = 100;
        mile.XC_StartDate__c = Date.today();
        mile.XC_OrderItem__c = ordIt.Id;
        insert mile;
        
        
        //Project
		project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTest',XC_ConfigurationItem__c = ordIt.id );
				
		insert p;

		//Create a new phase
		project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c(name='Phase Progetto di Test',
                                                                                     project_cloud__Project__c=p.id);
		insert ph;
                                                   
		//Created a Project Task
		project_cloud__Project_Task__c pt=new project_cloud__Project_Task__c(name='Project Task Test',
		    	                                                                  project_cloud__Duration__c=1,
		    	                                                                  project_cloud__Project_Phase__c=ph.id,
		    	                                                                  XC_TaskType__c=Constants.PPM_PROJECT_TASK_TYPE_BILLING,
		    	                                                                  XC_TaskReason__c='Milestone',
		    	                                                                  XC_TaskStatus__c='Work in Progress',//'New',
		    	                                                                  project_cloud__Autonomous_Start__c=system.today(), 
                                                                             	  project_cloud__Estimated_Hours__c = 1,
                                                                             	  XC_Milestone__c = mile.Id,
                                                                             	  XC_OrderItem__c = ordIt.id
		    	                                                                  );
		insert pt;
        
        
    }
    
    static testMethod void payAndBillTEST(){       
        List<project_cloud__Project_Task__c> stepsList = [SELECT Id, XC_Milestone__r.XC_OrderItem__c, XC_Milestone__r.XC_OrderItem__r.NE__OrderId__c
        FROM project_cloud__Project_Task__c
        LIMIT 1];
       
        project_cloud__Project_Task__c step = stepsList[0];
        
        NE__Order__c order = [SELECT Id, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c LIMIT 1];        
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.CreateZquoteFromDatamap('Order2Zquote', order.Id);
        zqu__Quote__c q = [select id from zqu__Quote__c limit 1];
        q.XC_Project_Task__c = step.id;
        update q;
        
        XC_IN055_Project_Task_U_ManageInvoice.InputWrapper inw = new XC_IN055_Project_Task_U_ManageInvoice.InputWrapper();
        List<XC_IN055_Project_Task_U_ManageInvoice.InputWrapper> inputWrapperList = new List<XC_IN055_Project_Task_U_ManageInvoice.InputWrapper>();
        inw.taskId = step.Id;
        inputWrapperList.add(inw);
        
        test.startTest();  
        XC_IN055_Project_Task_U_ManageInvoice.createInvoice(inputWrapperList);
        test.stopTest();
        System.assertEquals(1, stepsList.size());
    }
    
 	
}
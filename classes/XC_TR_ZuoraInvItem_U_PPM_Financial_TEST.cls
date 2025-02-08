/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 01/09/2020
* @date Modification dd/mm/yyyy
* @description 
*/
@isTest
public class XC_TR_ZuoraInvItem_U_PPM_Financial_TEST {

    public static testMethod void fillSubscriptionNum(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Zuora__ZInvoice__c zuoraZInvoice = new Zuora__ZInvoice__c();
        zuoraZInvoice.Zuora__Balance2__c = 3;
        insert zuoraZInvoice;
        
        project_cloud__Project_Task__c project = new project_cloud__Project_Task__c(XC_TaskReason__c = 'Recurring',
                                                                                    XC_TaskType__c = 'one shot'
                                                                                   );
        //Project
		project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTest');
				
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
		    	                                                                  XC_TaskStatus__c='Work in Progress',
		    	                                                                  project_cloud__Autonomous_Start__c=system.today(), 
                                                                             	  project_cloud__Estimated_Hours__c = 1
                                                           
		    	                                                                  );
        insert pt;
        zqu__quote__c quote = new zqu__quote__c(zqu__ZuoraSubscriptionID__c = '12345');
        insert quote;    
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '54321',
                                                                Zuora__PreviousSubscriptionId__c = '54321',
                                                                Zuora__External_Id__c = '56789',
                                                               	XC_ProjectTaskId__c = pt.Id );
        insert sub;
        
        List<Zuora__InvoiceItem__c> zList=new List<Zuora__InvoiceItem__c>();
        test.startTest();
        
        Zuora__InvoiceItem__c z = new Zuora__InvoiceItem__c();
        z.name='test';
        z.Zuora__Subscription__c=sub.id;
        z.Zuora__Invoice__c=zuoraZInvoice.id;
        z.Zuora__Charge_Date__c = Date.today();
        z.Zuora__Charge_Amount2__c = 444;
        insert z;
       
        test.stopTest();
        
  }
}
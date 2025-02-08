/*
* @author Nicola Arrigo -
* @date Creation 29/06/2020
* @date Modification 
* @description  XC_LCC188_ProjectMaintenanceService_Test
*/
@isTest
public with sharing class XC_LCC188_ProjectMaintenanceService_Test {
    @TestSetup 
    static void setup(){
    //Project
		    project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTestTemplate', 
	   	                         project_cloud__Type__c='Maintenance Plan',
	   	                         project_cloud__IsTemplate__c=true,
                                 XC_LegalEntity__c='Codensa',
                                 project_cloud__Units__c='Duration',
                                 XC_Country__c ='Colombia'
	   	                         );
			
	        insert p;   
     List<NE__Order__c> listOrders = XC_DF_Order.createOrders(1,'InOrder');
    listOrders[0].XC_Country__c = 'Colombia';
   // listOrders[0].XC_Project__c=p.id;
    insert listOrders;
    XC_UTIL_Contract.ContractIFWrapper cW = new XC_UTIL_Contract.ContractIFWrapper();
    XC_UTIL_Contract.createContracts(listOrders);
    Contract c=[select id,Account.XC_Country__c,XC_Project__c,ContractNumber  from contract limit 1];
    c.XC_Project__c=p.id;
    update c;
    date dStart=system.today();    
    date dEnd=dStart+1;    
    XC_ContractItem__c cli= new XC_ContractItem__c(
                                                     XC_Contract__c=c.id,
                                                     XC_ServiceFrequency__c=1,
                                                     XC_Service_Status__c='To Plan',
                                                     XC_Active__c=true,
                                                     XC_StartDate__c=dStart,
                                                     XC_EndDate__c=dEnd
                                                   );
    insert cli;       
       XC_ContractItem__c cli2= new XC_ContractItem__c(
                                                     XC_Contract__c=c.id,
                                                     XC_ServiceFrequency__c=100,
                                                     XC_Service_Status__c='To Plan',
                                                     XC_Active__c=true,
                                                     XC_StartDate__c=dStart,
                                                     XC_EndDate__c=dEnd
                                                   );
    insert cli2;            
    }
    @isTest
	static void createMainProject(){
           User itAdmin = XC_DF_User.createUserAdmin();
        itAdmin.XC_LegalEntity__c = 'EnelXItalia';
        itAdmin.XC_LegalEntities__c = 'EnelXItalia';
        insert itAdmin;
        System.runAs(itAdmin){
        List<XC_ContractItem__c> cli=[select id,XC_Contract__c,XC_ServiceFrequency__c,XC_EndDate__c,XC_StartDate__c,
                                XC_ServiceFirstExecution__c,XC_Service_Status__c,
                                XC_Active__c,Name,
                                (select id from Project_Tasks__r)
                                from XC_ContractItem__c];
         //string st=XC_LCC187_PPM_ContractMaintenanceService.createProject(c.id);  
        XC_LCC188_ProjectMaintenanceService.createMainProject(cli[0].id,cli[0].XC_StartDate__c);
        
       XC_LCC188_ProjectMaintenanceService.createMainProject(cli[1].id,cli[1].XC_StartDate__c);          
            
        }
                            
    }

}
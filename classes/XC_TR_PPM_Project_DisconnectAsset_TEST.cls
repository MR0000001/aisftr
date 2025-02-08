@IsTest
public class XC_TR_PPM_Project_DisconnectAsset_TEST {
    static testmethod void closedAsset(){
	  Test.startTest();
       List<Account> accountList = XC_DF_Account.createResidentialAccounts(1);
       insert accountList;
       List<Contract> con = XC_DF_Contract.createContracts(1);
       con[0].Status='Cancelled';
       List<Asset> ass =XC_DF_Asset.createAssets(1);
       ass[0].Status = 'Inactive';
       Ne__Order__c ord = new Ne__Order__c();
       ord.XC_Contract__c= con[0].id;
       insert ord;
       
       project_cloud__Project__c project = new project_cloud__Project__c();
       project.XC_Configuration__c=ord.Id;
       project.project_cloud__IsTemplate__c =true;
       project.project_cloud__Type__c='provisioning';
       project.XC_LegalEntity__c ='EnelX';
       project.XC_Country__c ='Chile';
       project.XC_Status__c = 'Assigned';
       insert project;
       project.XC_Status__c = 'Planned';
       update project;
       project.XC_Status__c = 'Work in Progress';
       update project;
       project.XC_Status__c = 'Closed';
       update project;	
       project_cloud__Project__c project1 = new project_cloud__Project__c();
       project1.project_cloud__IsTemplate__c =true;
       project1.project_cloud__Type__c='provisioning';
       project1.XC_LegalEntity__c ='EnelX';
       project1.XC_Country__c ='Chile';
       project1.XC_Status__c = 'Assigned';
       insert project1;  
       project.XC_Status__c = 'Planned';
       update project1;
       project.XC_Status__c = 'Work in Progress';
       update project1;
       project.XC_Status__c = 'Cancelled';
       update project1;       
       
       Map<id,project_cloud__Project__c> mapOld= new Map <id,project_cloud__Project__c>();
   	   Map<id,project_cloud__Project__c> mapNew= new Map <id,project_cloud__Project__c>();
       mapNew.put(project.id,project);
       mapOld.put(project.id,project1); 
       XC_TR_PPM_Project_DisconnectAsset.closedAsset(mapNew,mapOld);
       Test.stopTest();
    }   
}
/**
* @author Nicola Arrigo - narrigo
* @date Creation 18/05/2020
* @date Modification 15/05/2019
* @description class to generate Contract Maintenance Service Project
*/
public with sharing class XC_LCC187_PPM_ContractMaintenanceService {
    @AuraEnabled
    public static string createProject(string recordId){
      Contract c = new Contract();
       if(Schema.sObjectType.contract.isAccessible()) {
           c = [
                   select id,Account.XC_Country__c,XC_Project__c,ContractNumber,status,XC_LegalEntity__c,	XC_Segment__c
                   from contract
                   where id = :recordId
           ];
       } 
        //checking if a Project is just related to the Contract
       if(c.XC_Project__c!=null){
         return 'A project is just related';
       }/*else if(c.status!='Active'){ 
         return 'The Contract must be set to status Active to create a Project';
       }*/ //not to cancel the else if we wiil use it in another sprint 
        else{
         project_cloud__Project__c p=new project_cloud__Project__c(name='Maintenance Service Project Contract:'+' '+c.ContractNumber,
                                                                       project_cloud__Type__c='Maintenance Plan',
                                                                       ccpe_ocp__Account__c=c.AccountId,
                                                                       xc_country__c=c.Account.XC_Country__c,
                                                                       project_cloud__Units__c='Duration',
                                                                       XC_LegalEntity__c=c.XC_LegalEntity__c, 
                                                                       XC_Segment__c=c.XC_Segment__c 
                                                                      );                      
              if(Schema.sObjectType.project_cloud__Project__c.isCreateable()) {
                  insert p;
              }
              c.XC_Project__c =p.id;
               if(Schema.sObjectType.Contract.fields.XC_Project__c.isUpdateable()) {
                   update c;
               }
              return 'Project is created';
       }
             
             
        
      }
}
/**
* @author Andrea Di Cicco
* @date Creation  07/01/2020 
* @description XC_TR_Contract_U_PipelineAutomation_TEST test class 
*/
@isTest
public class XC_TR_Contract_U_PipelineAutomation_TEST {

    static testMethod  void manageStage (){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        test.startTest();
         User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u; 
        List<Contract> contractList = XC_DF_Contract.createContracts(2);
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        for(Opportunity opp : oppList){
            opp.XC_Segment__c ='B2B';
            opp.AccountId = accList.get(0).id;
            opp.StageName = 'Draft'; 
            opp.Name = 'TEST'; 
            opp.CloseDate =System.today(); 
        }
        insert oppList;
        Map<Id,Contract> mapOld = new Map<Id,Contract>();
        Map<Id,Contract> mapNew = new Map<Id,Contract>();
        
        for(Contract c : contractList){
            c.XC_Segment__c = 'B2B';
            //c.XC_LegalEntity__c = 'EnelXItalia';
            c.Opportunity__c = oppList.get(0).id;
         
            
        }
        	insert contractList;
        	contractList.get(0).XC_Signed__c= true;
        	contractList.get(1).XC_Signed__c= false;


            
            mapNew.put(contractList.get(0).id,contractList.get(0));
           
            mapOld.put(contractList.get(0).id,contractList.get(1));
          system.runAs(u){ 
        XC_TR_Contract_U_PipelineAutomation.manageStage(mapOld,mapNew);
          }
        test.stopTest();
        }  
}
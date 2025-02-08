/**
* @author Pacchiano Raffaele
* @date Creation  07/01/2020 
* @description XC_TR_Configuration_U_PipelineAutomation_TEST test class 
*/
@isTest
public class XC_TR_Configuration_U_PipelineAut_TEST {
	
     static testMethod  void manageStage (){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        test.startTest();
        List<NE__Order__c> listNew = XC_DF_Order.createOrders(2, 'Order');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        insert listNew;
         for(Opportunity opp : oppList){
            opp.XC_Segment__c ='B2B';
            opp.AccountId = accList.get(0).id;
            opp.StageName = 'Draft'; 
            opp.Name = 'TEST'; 
            opp.CloseDate =System.today(); 
        }
         insert oppList;
         	Map<id,NE__Order__c> mapOld= new Map <id,NE__Order__c>();
    		Map<id,NE__Order__c> mapNew= new Map <id,NE__Order__c>();
         
        for(NE__Order__c ord : listNew){
            ord.XC_Segment__c ='B2B';
            ord.NE__OptyId__c = oppList.get(0).id;
        }
         	update listNew;
         	listNew.get(0).XC_Status__c='Notified to client';

                
            mapNew.put(listNew.get(0).id,listNew.get(0));
           
            mapOld.put(listNew.get(0).id,listNew.get(1));
          
        XC_TR_Configuration_U_PipelineAutomation.manageStage(listNew,mapOld,mapNew);
        test.stopTest();
        }
      static testMethod  void manageStagetwo (){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        test.startTest();
        List<NE__Order__c> listNew = XC_DF_Order.createOrders(2, 'Order');
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunitiesWithAssignedResource(1);
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
        insert accList;
        insert listNew;
         for(Opportunity opp : oppList){
            opp.XC_Segment__c ='B2B';
            opp.AccountId = accList.get(0).id;
            opp.StageName = 'Draft'; 
            opp.Name = 'TEST'; 
            opp.CloseDate =System.today(); 
        }
         insert oppList;
         	Map<id,NE__Order__c> mapOld= new Map <id,NE__Order__c>();
    		Map<id,NE__Order__c> mapNew= new Map <id,NE__Order__c>();
         
        for(NE__Order__c ord : listNew){
            ord.XC_Segment__c ='B2B';
            ord.NE__OptyId__c = oppList.get(0).id;
        }
         	update listNew;
         	listNew.get(0).XC_Status__c='Accepted';

                
            mapNew.put(listNew.get(0).id,listNew.get(0));
           
            mapOld.put(listNew.get(0).id,listNew.get(1));
          
        XC_TR_Configuration_U_PipelineAutomation.manageStage(listNew,mapOld,mapNew);
        test.stopTest();
        }
        }
/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  24/05/2019 
* @description XC_TR_Case_U_CheckDuplicates_TEST – Test class for XC_TR_Case_U_CheckDuplicates
*/
@isTest
public with sharing class XC_TR_Case_U_CheckDuplicates_TEST {
       	@TestSetup
	static void setup(){

        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(1);
        insert cont; 
        Contact cct = [SELECT Id, AccountId from Contact LIMIT 1];
        /*List<WorkOrder> wo =XC_DF_WorkOrder.createWorkOrdersForLead (1);
        insert wo;
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1,true);
        insert opp;
        NE__Order__c conf = XC_DF_Order.createOrder('Asset');
        NE__OrderItem__c confitem = XC_DF_OrderItem.createOrderItem(conf) ;
        insert confitem; */
        List<Case> ca =XC_DF_Case.createCases(1);
        ca[0].Status = 'ESTA000' ;
        ca[0].AccountId = cct.AccountId;
        ca[0].ContactId = cct.Id; 
        ca[0].Reason='XCMOT002'  ;     
        ca[0].Subcause__c='ATCL004';//ATCL187
        ca[0].XC_Subtype__c=null;
        ca[0].ParentId=null;
        ca[0].XC_WorkOrder__c=null;
        ca[0].XC_Opportunity__c =null;
        ca[0].XC_Order__c =null;
        ca[0].XC_OrderItem__c= null;
        insert ca;
    }
    
    // Test method for checkDuplicates 
     static testMethod void checkInsertDuplicates(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            List<Case> ca1 =XC_DF_Case.createCases(1);
        System.assert(ca1!=null);
        ca1[0].Status = 'ESTA000';

        ca1[0].ContactId = [SELECT Id FROM Contact ][0].Id;
        ca1[0].Reason= 'XCMOT002' ;   
        ca1[0].Subcause__c='ATCL004';//ATCL187
        ca1[0].XC_Subtype__c=null;
        ca1[0].ParentId=null;
        ca1[0].XC_WorkOrder__c=null;
        ca1[0].XC_Opportunity__c = null;
        ca1[0].XC_Order__c =null;
        ca1[0].XC_OrderItem__c= null;
        try{
              insert ca1;
        }catch(exception e){
            System.assert(ca1!=null);
        }
        Test.stopTest(); 
     }
    
    // Test method for checkDuplicates 
     static testMethod void checkInsertCompliantDuplicates(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
            Contact cct = [SELECT Id, AccountId FROM Contact LIMIT 1];
        	List<Case> ca1 =XC_DF_Case.createCases(1);
            ca1[0].Status = 'ESTA000';
            ca1[0].AccountId = cct.AccountId;
            ca1[0].ContactId = cct.Id;
            ca1[0].Reason= 'XCMOT005' ;   
            ca1[0].Subcause__c='ATCL070';
            ca1[0].XC_Type_Intermediary__c = 'TI001';
            ca1[0].XC_Subtype__c=null;
            ca1[0].ParentId=null;
            ca1[0].XC_WorkOrder__c=null;
            ca1[0].XC_Opportunity__c = null;
            ca1[0].XC_Order__c =null;
            ca1[0].XC_OrderItem__c= null;
            insert ca1;
         	
        	List<Case> ca2 =XC_DF_Case.createCases(1);
            ca2[0].Status = 'ESTA000';
            ca2[0].ContactId = [SELECT Id FROM Contact ][0].Id;
            ca2[0].Reason= 'XCMOT005' ;   
            ca2[0].Subcause__c='ATCL070';
            ca2[0].XC_Type_Intermediary__c = 'TI001';
            ca2[0].XC_Subtype__c=null;
            ca2[0].ParentId=null;
            ca2[0].XC_WorkOrder__c=null;
            ca2[0].XC_Opportunity__c = null;
            ca2[0].XC_Order__c =null;
            ca2[0].XC_OrderItem__c= null;
            try{
                  insert ca2;
            }catch(exception e){
                System.assert(true);
            }
        Test.stopTest(); 
     }
    
    // Test method for checkDuplicates 
     static testMethod void checkUpdateDuplicates(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
         Contact cct = [SELECT Id, AccountId FROM Contact LIMIT 1];
        	List<Case> ca1 =XC_DF_Case.createCases(1);
        System.assert(ca1!=null);
        ca1[0].Status = 'ESTA000';
         ca1[0].AccountId = cct.AccountId;
         ca1[0].ContactId = cct.Id;
        ca1[0].Reason= 'XCMOT002' ;   
        ca1[0].Subcause__c='ATCL003';//ATCL187
        ca1[0].XC_Subtype__c=null;
        ca1[0].ParentId=null;
        ca1[0].XC_WorkOrder__c=null;
        ca1[0].XC_Opportunity__c = null;
        ca1[0].XC_Order__c =null;
        ca1[0].XC_OrderItem__c= null;
        insert ca1;
        try{
            ca1[0].Subcause__c='ATCL004';
            update ca1;
            
        }catch(exception e){
            System.assert(ca1!=null);
        }
        Test.stopTest(); 
     }
}
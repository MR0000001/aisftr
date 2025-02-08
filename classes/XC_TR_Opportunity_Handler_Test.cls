/**
* @author Nicola Arrigo - narrigo@deloitte.it  
* @date Creation  11/03/2020 
* @description XC_TR_Opportunity_Handler_Test – Test class for XC_TR_Opportunity_Handler
*/

@isTest
public with sharing class XC_TR_Opportunity_Handler_Test {
     /**
    * test trigger Opp create 
    */
    public static testMethod void testTrigger1(){
      	OneOrg__c org            = new OneOrg__c(); 
	    org.Name                 = 'OneOrg (User)';
	    org.XC_Spain_Triggers__c = true;
	    insert org; 
        List<Opportunity> oppList = XC_DF_Opportunity.createOpportunity(1, true);
        insert oppList;
       oppList[0].CloseDate = Date.newInstance(2031, 12, 31);
        update oppList;
        delete oppList;
       // undelete oppList[0];
    }

}
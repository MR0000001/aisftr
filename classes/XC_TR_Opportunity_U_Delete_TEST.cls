/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation  19/06/2019 
* @description XC_TR_Opportunity_U_Delete_TEST – Test to cover delete opportunity handler
*/ 
@isTest
public class XC_TR_Opportunity_U_Delete_TEST {
    
    @TestSetup
    private static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, true);
        insert o;
    }

    @isTest
    private static void deleteOpportunity() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            delete o;
        Test.stopTest();

        System.assert([SELECT Count() FROM Opportunity] == 0);
    }
    
    @isTest
    private static void undeleteOpportunity() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		delete o;
        
        Test.startTest();
            undelete o;
        Test.stopTest();

        System.assert([SELECT Count() FROM Opportunity] == 1);
    }

}
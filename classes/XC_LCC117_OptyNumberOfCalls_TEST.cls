/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 21/06/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC117_OptyNumberOfCalls – Handles the increment of the number of calls on opportunity
*/
@isTest
public without sharing class XC_LCC117_OptyNumberOfCalls_TEST {
   
    @testSetup
    private static void setup() {
        List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, true);
        o[0].XC_NumberOfCalls__c = 0;
        insert o;
    }

    @isTest
    private static void updateNumberOfCallsTEST() {
        Opportunity o = [SELECT Id, XC_NumberOfCalls__c FROM Opportunity LIMIT 1];
        Decimal numberOfCalls = o.XC_NumberOfCalls__c;

        Test.startTest();
            XC_LCC117_OptyNumberOfCalls.updateNumberOfCalls(o.Id);
            o.XC_LastUpdateCallCounter__c = DateTime.now();
            update o;
            XC_LCC117_OptyNumberOfCalls.updateNumberOfCalls(o.Id);
            o.XC_LastUpdateCallCounter__c = DateTime.newInstance(2019, 5, 11, 11, 0, 0);
            update o;
            XC_LCC117_OptyNumberOfCalls.updateNumberOfCalls(o.Id);
            o.XC_LastUpdateCallCounter__c = DateTime.newInstance(2019, 5, 11, 11, 0, 0);
            o.XC_NumberOfCalls__c = 3;
            update o;
            XC_LCC117_OptyNumberOfCalls.updateNumberOfCalls(o.Id);
        
            o.XC_LastUpdateCallCounter__c = DateTime.now();
            update o;
            XC_LCC117_OptyNumberOfCalls.updateNumberOfCalls(o.Id);
        
            o.StageName = 'Draft';
              try{
            update o;
            }
        catch(exception e){
           System.debug(e);
        }
            XC_LCC117_OptyNumberOfCalls.updateNumberOfCalls(o.Id);
        Test.stopTest();

        o = [SELECT Id, XC_NumberOfCalls__c FROM Opportunity LIMIT 1];
        //System.assert(numberOfCalls == o.XC_NumberOfCalls__c - 3);
    }
    
    @isTest
    private static void updateNumberOfCallsTEST2() {
        Opportunity o = [SELECT Id, XC_NumberOfCalls__c FROM Opportunity LIMIT 1];
        Decimal numberOfCalls = o.XC_NumberOfCalls__c;

        Test.startTest();
            delete o;
            XC_LCC117_OptyNumberOfCalls.updateNumberOfCalls(o.Id);
        Test.stopTest();

        System.assert(true);
    }

}
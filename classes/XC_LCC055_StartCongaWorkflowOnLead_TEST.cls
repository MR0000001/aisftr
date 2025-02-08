/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com 
* @Creation 20/05/2019
* @description Test Class for XC_LCC055_StartCongaWorkflowOnLead
*/
@isTest
private class XC_LCC055_StartCongaWorkflowOnLead_TEST {
    static testMethod void congaWorkflowGetStartedTest(){
        Test.startTest();
        List<Lead> l = XC_DF_Lead.createResidentialLeads(1);
        insert l;
        l[0].XC_StartCongaWorkflow__c =  false;
        update l;
        String recordIdLead = l[0].Id;
        XC_LCC055_StartCongaWorkflowOnLead.ResultWrapper wr = new XC_LCC055_StartCongaWorkflowOnLead.ResultWrapper();
        wr = XC_LCC055_StartCongaWorkflowOnLead.congaWorkflowGetStarted(recordIdLead);
        System.assert(wr.success);
        Test.stopTest();
    }
}
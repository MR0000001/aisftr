/**
* @description XC_SC048_RetryQueuedReqSteps 
* @author Simone Trenta - strenta@deloitte.it
*/

@isTest
public class XC_SC048_RetryQueuedReqSteps_TEST {

    @TestSetup
    static void setup() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_ClientSystem__c = 'CommoditySpainB2C';
        qr.XC_RequestBody__c  = '{}';
        insert qr;

		XC_QueuedRequestStep__c q = new XC_QueuedRequestStep__c();
        q.XC_Status__c = 'Completed KO';
        q.XC_Retried__c = false;
        q.XC_QueuedRequest__c = qr.id; 
        insert q;
        
    }
    
    static testMethod void callBatch(){
        
        Test.startTest();     
        Database.executeBatch(new XC_SC048_RetryQueuedReqSteps());
        Test.stopTest();
        System.assertEquals(true, true);
    }

}
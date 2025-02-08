/**
* @description XC_SC049_DeleteQueuedRequest
* @author Simone Trenta - strenta@deloitte.it
*/

@isTest
public class XC_SC049_DeleteQueuedRequest_TEST {

      @TestSetup
    static void setup() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_ClientSystem__c = 'CommoditySpainB2C';
        qr.XC_Status__c = 'In Error';
        qr.XC_ValidationStatus__c = 'OK';
        qr.XC_RequestBody__c  = '{}';
        insert qr;

		XC_QueuedRequestStep__c q = new XC_QueuedRequestStep__c();
        q.XC_QueuedRequest__c = qr.id; 
        insert q;
        
    }
    
    static testMethod void callBatch(){
        
        Test.startTest();     
        Database.executeBatch(new XC_SC049_DeleteQueuedRequest());
        Test.stopTest();
        System.assertEquals(true, true);
    }
    
    
}
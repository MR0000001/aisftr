/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  20/05/2019 
* @description XC_REST_VerifyPaymentMethods_TEST – Test class for XC_REST_VerifyPaymentMethods
*/
@isTest
public class XC_REST_VerifyPaymentMethods_TEST {
    
    //Test Method verifyPaymentMethod
    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
        Zuora_OAuth__c zws = new Zuora_OAuth__c();
        zws.EntityName__c = 'SPAIN';
        zws.Host__c = 'test_url';
        insert zws;
    }
    
    static testMethod void verifyPaymentMethodActive(){
         
        Test.startTest();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.Name = Label.XC_CL_VerifyPaymentMethods;
        ic.XC_interfaceName__c = Label.XC_CL_VerifyPaymentMethods;
        ic.XC_URL_Required__c = 'test'; 
        insert ic;
        
        Test.setMock(HttpCalloutMock.class, new XC_REST_VerifyPaymentMethods_Mock());
        
        ZuoraCallback callback;
        
        callback = new ZuoraCallback();
       	Id jobId = System.enqueueJob(callback);
        
        System.assertEquals(true, callback.result!=null);
        
        //XC_REST_VerifyPaymentMethods.WrapperResponse rw = XC_REST_VerifyPaymentMethods.verifyPaymentMethod('TEST', new XC_REST_VerifyPaymentMethods.WrapperRequest());
        
        
        Test.stopTest();
        
    }
    
    static testMethod void verifyPaymentMethodInActive(){
        
        Test.startTest();
        
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = false;
        ic.Name = Label.XC_CL_VerifyPaymentMethods;
        ic.XC_interfaceName__c = Label.XC_CL_VerifyPaymentMethods;
        insert ic;
        
        XC_REST_VerifyPaymentMethods.WrapperResponse rw = XC_REST_VerifyPaymentMethods.verifyPaymentMethod('TEST', new XC_REST_VerifyPaymentMethods.WrapperRequest());     
        System.assertEquals(true, rw!=null);
        
        Test.stopTest();
        
    }

    private class ZuoraCallback implements Queueable, Database.AllowsCallouts {
        
        XC_REST_VerifyPaymentMethods.WrapperResponse result = new XC_REST_VerifyPaymentMethods.WrapperResponse();
        
        /**
         * @description Execute Queuable
         * @param context - QueueableContext
         */
        public void execute(QueueableContext context) {

        	try {
				this.result = XC_REST_VerifyPaymentMethods.verifyPaymentMethod('TEST', new XC_REST_VerifyPaymentMethods.WrapperRequest());
            } catch (exception e){
            
        	}
        
        }
        
    }
    
}
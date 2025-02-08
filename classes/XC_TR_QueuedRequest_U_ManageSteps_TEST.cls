/**
 * @author              Luisana Rocco lrocco@deloitte.it
 * @date Creation       27/05/2021
 * @date Modification   
 * @description         test class for XC_TR_QueuedRequest_U_ManageSteps
 */
@isTest
public without sharing class XC_TR_QueuedRequest_U_ManageSteps_TEST {

    @isTest
    static void test1(){
    	List<XC_QueuedRequest__c> qrs = XC_DF_QueuedRequest.createQueuedRequest(2);
	 	XC_UTIL_QueuedRequest_W.WrapperRequest fullQRReqBody = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(qrs[1].XC_RequestBody__c, XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        fullQRReqBody.Order.OrderType = 'Energy Disconnect';
		qrs[1].XC_RequestBody__c = json.serialize(fullQRReqBody,true);
        qrs[1].XC_Status__c = 'Enqueued';
		insert qrs;

		qrs[1].XC_Status__c = 'In Progress';
		qrs[0].XC_ParentQueuedRequest__c = qrs[1].id;
		update qrs;

		system.debug('STEP'+ [select id, XC_StepLabel__c from XC_QueuedRequestStep__c where XC_QueuedRequest__c =:qrs[1].id]);
        
		Test.startTest();
		qrs[0].XC_Status__c = 'Completed';
		update qrs[0];
		Test.stopTest();
    }
}
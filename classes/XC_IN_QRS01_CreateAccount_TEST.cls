/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 07-13-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   07-13-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public class XC_IN_QRS01_CreateAccount_TEST {

    @TestSetup
    static void setup(){
        List<XC_QueuedRequest__c> qrList = XC_DF_QueuedRequest.createQueuedRequest(1);
        insert qrList;
    }

    @isTest
    static void testAccountCreation(){

        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS01_CreateAccount.InputWrapper iw = new XC_IN_QRS01_CreateAccount.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
            XC_IN_QRS01_CreateAccount.manageAccountCreation(new List<XC_IN_QRS01_CreateAccount.InputWrapper>{iw});
        Test.stopTest();

    }
    
    @isTest
    static void testAccountDuplication(){

        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS01_CreateAccount.InputWrapper iw = new XC_IN_QRS01_CreateAccount.InputWrapper();
        iw.stepId = qrs.Id;
        
        Test.startTest();
            XC_IN_QRS01_CreateAccount.manageAccountCreation(new List<XC_IN_QRS01_CreateAccount.InputWrapper>{iw});
            XC_IN_QRS01_CreateAccount.manageAccountCreation(new List<XC_IN_QRS01_CreateAccount.InputWrapper>{iw});
        Test.stopTest();

    } 

    @isTest
    static void testQueueableInvocation(){
        XC_QueuedRequestStep__c qrs = [SELECT ID FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS01_CreateAccount.InputWrapper iw = new XC_IN_QRS01_CreateAccount.InputWrapper();
        iw.stepId = qrs.Id;

        Test.startTest();
            XC_IN_QRS01_CreateAccount.executeAccountCreation(new List<XC_IN_QRS01_CreateAccount.InputWrapper>{iw});
        Test.stopTest();

    }

    @isTest
    static void testError(){

        System.Savepoint beforeInsertSavepoint;
        XC_QueuedRequestStep__c qrs = [SELECT ID,XC_QueuedRequest__c,XC_StepSequence__c FROM XC_QueuedRequestStep__c LIMIT 1];
        XC_IN_QRS01_CreateAccount.InputWrapper iw = new XC_IN_QRS01_CreateAccount.InputWrapper();
        iw.stepId = qrs.Id;
        XC_REST_Account_W.WrapperResponse wrResp = new XC_REST_Account_W.WrapperResponse();
        wrResp.Result = new XC_UTIL_Integration.Result();
        wrResp.Result.ErrorCode = '500';
        wrResp.Result.Message = 'TEST ERROR';

        Test.startTest();
            XC_IN_QRS01_CreateAccount.manageErrors(qrs,wrResp,/*new XC_REST_Account_W.WrapperRequest(),*/ beforeInsertSavepoint);
        Test.stopTest();
    }
  
    @isTest
    static void testcheckB2BAccountType(){

        XC_QueuedRequestStep__c qrs = [SELECT ID,XC_QueuedRequest__r.XC_RequestBody__c FROM XC_QueuedRequestStep__c LIMIT 1];
        Test.startTest();
            XC_IN_QRS01_CreateAccount.checkB2BAccountType(qrs);
        Test.stopTest();

    }
    
    
}
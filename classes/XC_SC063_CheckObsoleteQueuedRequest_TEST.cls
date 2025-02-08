/**
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 02/12/2021
 * @date Modification dd/mm/yyyy
 * @description XC_SC063_CheckObsoleteQueuedRequest_TEST – Test Class for XC_SC063_CheckObsoleteQueuedRequest
 */
@isTest
public class XC_SC063_CheckObsoleteQueuedRequest_TEST {

    @TestSetup
    static void insertRecords(){
        List<XC_QueuedRequest__c> queuedRequestList = XC_DF_QueuedRequest.createQueuedRequest(1);
        XC_QueuedRequest__c queuedRequest = queuedRequestList[0];
        insert queuedRequest;
        List<XC_QueuedRequestStep__c> qrsList = new List<XC_QueuedRequestStep__c>();
        XC_QueuedRequestStep__c qrs1 = new XC_QueuedRequestStep__c(); 
        XC_QueuedRequestStep__c qrs2 = new XC_QueuedRequestStep__c(); 
        qrs1.XC_QueuedRequest__c = queuedRequest.Id;
        qrs1.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        qrs1.XC_FlowAPIName__c = 'XC_FL_TEST1';
        qrs1.XC_StepSequence__c = 1;
        qrsList.add(qrs1);  
        qrs2.XC_QueuedRequest__c = queuedRequest.Id;
        qrs2.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        qrs2.XC_FlowAPIName__c = 'XC_FL_TEST2';
        qrs2.XC_StepSequence__c = 2;
        qrsList.add(qrs2);  
        insert qrsList;       
        System.debug('LIST qrsList--> ' + qrsList);
        List<XC_QueuedRequest__c> queuedRequestList2 = XC_DF_QueuedRequest.createQueuedRequest(1);
        XC_QueuedRequest__c queuedRequest2 = queuedRequestList2[0];
        insert queuedRequest2;
        List<XC_QueuedRequestStep__c> qrsList2 = new List<XC_QueuedRequestStep__c>(); 
        XC_QueuedRequestStep__c qrs3 = new XC_QueuedRequestStep__c(); 
        XC_QueuedRequestStep__c qrs4 = new XC_QueuedRequestStep__c(); 
        qrs3.XC_QueuedRequest__c = queuedRequest2.Id;
        qrs3.XC_Status__c = Label.XC_CL_Completed_Ok;
        qrs3.XC_FlowAPIName__c = 'XC_FL_TEST1';
        qrs3.XC_StepSequence__c = 1;
        qrsList2.add(qrs3);  
        qrs4.XC_QueuedRequest__c = queuedRequest2.Id;
        qrs4.XC_Status__c = Label.XC_CL_Completed_Ok;
        qrs4.XC_FlowAPIName__c = 'XC_FL_TEST2';
        qrs4.XC_StepSequence__c = 2;
        qrsList2.add(qrs4);  
        insert qrsList2;
        System.debug('LIST qrsList2--> ' + qrsList2);
        List<String> finalStatus = new List<String>{Label.XC_CL_Completed_Ok,Label.XC_CL_Step_CompletedKO };
        List<XC_QueuedRequestStep__c> qrsListQueried = new List<XC_QueuedRequestStep__c>([SELECT Id, Name, XC_Status__c FROM XC_QueuedRequestStep__c]);
        List<XC_QueuedRequestStep__c> qrsListQueriedBatch = new List<XC_QueuedRequestStep__c>([SELECT Id, Name, XC_Status__c FROM XC_QueuedRequestStep__c WHERE XC_Status__c IN: finalStatus ]);
        System.debug('LIST STEPS--> ' + qrsListQueried);
        System.debug('LIST STEPS BATC--> ' + qrsListQueriedBatch);
    }
    
    static testMethod void manageDuplicates(){  
        Test.startTest();
        Id batchJobId = Database.executeBatch(new XC_SC063_CheckObsoleteQueuedRequest(), 200);
        Test.stopTest();
    }
    
    static testMethod void errorLog(){  
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.errorObjectId = '';
        wr.errorMessage = 'Test Error';
        Test.startTest();
        XC_SC063_CheckObsoleteQueuedRequest.insertLogError(wr);
        Test.stopTest();
    }
}
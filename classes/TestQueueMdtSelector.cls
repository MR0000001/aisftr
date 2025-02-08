/**
 * Created by SNEKKANTI00 on 03/02/2021.
 */

@isTest
public with sharing class TestQueueMdtSelector {
    @isTest
    public static void queueMdtSelectorTest() {
        Test.startTest();
        QueueMdtSelector.getCallBackQueue();
        QueueMdtSelector.getAllQueues();
        Test.stopTest();
    }
}
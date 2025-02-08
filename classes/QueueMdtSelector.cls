public with sharing class QueueMdtSelector {
    public static List<Queue__mdt> getCallBackQueue() {
        List<Queue__mdt> queues = [SELECT DeveloperName, Label FROM Queue__mdt WHERE Call_Back__c = true];
        return queues;
    }
    public static List<Queue__mdt> getAllQueues() {
        List<Queue__mdt> queues = [SELECT DeveloperName, Label FROM Queue__mdt];
        return queues;
    }
}
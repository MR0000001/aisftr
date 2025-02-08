/**
 * Created by snekkanti002 on 02/08/2021.
 */

global without sharing class OpenDataCallout implements Schedulable {
    global static void execute(SchedulableContext ctx) {
        try {
            System.enqueueJob(new OpenDataCalloutQueueable());
            if(Test.isRunningTest()) {
                throw new AuraHandledException('in test');
            }
        } catch (Exception e) {
            ErrorLogEventHandler.standardExceptionLog('OpenDataCallout', 'execute', e);
        }
    }
}
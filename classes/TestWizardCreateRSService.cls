/**
 * Created by FMARCHEGIA00 on 01/04/2021.
 */

@IsTest
private class TestWizardCreateRSService {
    static testMethod void testBehavior() {
        Task task = new Task();
        insert task;
        List<Task> tasks = new List<Task>();
        tasks.add(task);
        Test.startTest();
        WizardCreateRSService.futureUpdateObjectFromWizardCreateRSService(tasks);
        Test.stopTest();
    }
}
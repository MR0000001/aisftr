/**
 * Created by FMARCHEGIA00 on 01/04/2021.
 */

@IsTest
private class TestUpdateTaskFromCTIService {
    static testMethod void testBehavior() {
        Task task = new Task();
        insert task;
        List<String> idLists = new List<String>();
        idLists.add(String.valueOf(task.Id));
        Test.startTest();
        UpdateTaskFromCTIService.futureUpdateObjectFromUpdateTaskFromCTIService(idLists);
        Test.stopTest();
    }
}
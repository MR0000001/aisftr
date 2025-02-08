/**
 * Created by SNEKKANTI00 on 16/12/2020.
 */

@IsTest
public with sharing class TestCaseManagementController {

   

    @IsTest
    private static void testCaseManagementController() {
        List<Group> groups = [SELECT DeveloperName, Name FROM Group];
        Group singleGroup = groups[0];
        String userRoleName = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'LeaderCC'].Name;

        Test.startTest();
        CaseManagementController.getCurrentUserRole();
        CaseManagementController.getQueueId(singleGroup.Name);
        CaseManagementController.getQueuesURP('test');
        CaseManagementController.getQueuesCaseManagement();
        CaseManagementController.getActionsCaseManagement(userRoleName);
        CaseManagementController.getReasonsCaseManagement(userRoleName, 'Passaggio alla coda URP');
        CaseManagementController.getModalitiesCaseManagement(userRoleName, 'Passaggio alla coda URP');
        CaseManagementController.queuesAreActive(singleGroup.Id, singleGroup.Name);
        CaseManagementController.getAllRolesMetadata();
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    private static void testCaseManagementControllerPostToChatter(){
        TestDataFactory.createCases();
        Case caseTest = [SELECT Id,CaseNumber FROM Case WHERE Type = 'URP' LIMIT 1];
        Group queue = [SELECT Id,Name FROM Group WHERE Name = 'U. COO BENESSERE ANIMALI' AND Type = 'Queue'];
        caseTest.OwnerId = queue.Id;
        Update caseTest;
        Test.startTest();
        CaseManagementController.postToChatter(caseTest.Id,caseTest.CaseNumber,queue.Id,queue.Name);
        Test.stopTest();
    }
    
}
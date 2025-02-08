/**
 * Created by FMARCHEGIA00 on 01/04/2021.
 */

@IsTest
private class TestFlowCreateSRI {
    static testMethod void testBehavior() {

        List<Account> accounts = TestDataFactory.createBusinessAccounts();
        List<Contact> contacts = TestDataFactory.createBusinessContacts(accounts);

        Profile p = [SELECT Id FROM Profile WHERE Name='Call Center'];
        User u = new User(Alias = 'standt', Email='testFlow@flow.it',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='testFlow@flow.it');
        insert u;

        system.runAs(u) {
            Task task = new Task();
            insert task;
            Service_Request__c serviceRequest = new Service_Request__c();
            serviceRequest.SR_Origin__c = 'Call Center';
            serviceRequest.CheckStatus__c = 'Chiusa';
            serviceRequest.Contact__c = null;
            serviceRequest.Call_Type_SR__c = 'Call type';
            serviceRequest.Customer_Phone_SR__c = 'Customer_Phone_SR__c';
            serviceRequest.Date_Time_SR__c = String.valueOf(System.now().date());
            serviceRequest.Duration_SR__c = 'Duration_SR__c';
            serviceRequest.Id_Phone_SR__c = '00000';
            serviceRequest.Key_IVR_SR__c = 'Key_IVR_SR__c';
            serviceRequest.Mystery_Call_Check__c = 'Mystery_Call_Check__c';
            serviceRequest.Name_IVR_SR__c = 'Name_IVR_SR__c';
            serviceRequest.RC_Phone_SR__c = '000000';
            serviceRequest.Subject_SR__c = 'Subject_SR__c';
            serviceRequest.Waiting_Time__c = 'Waiting_Time__c';
            serviceRequest.Contact__c = contacts[0].Id;
            serviceRequest.OwnerId = u.Id;
            insert serviceRequest;
            List<FlowCreateSRI.FlowInput> flowInputs = new List<FlowCreateSRI.FlowInput>();
            FlowCreateSRI.FlowInput flow = new FlowCreateSRI.FlowInput();
            flow.task = task;
            flow.serviceRequest = serviceRequest;
            flow.customSettingValueForTaskWhoId = u.Id;
            flow.customSettingValueForTaskWhoId = u.Id;
            flowInputs.add(flow);

            FlowCreateSRI.saveRecordByObject(flowInputs);
        }

    }
}
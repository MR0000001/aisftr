/**
 * Created by FMARCHEGIA00 on 01/04/2021.
 */

global class FlowCreateSRI {

    @InvocableMethod
    public static void saveRecordByObject(List<FlowInput> flowInputs) {
        system.debug('valori in input '+ flowInputs);
        for(FlowInput flow : flowInputs) {

            Service_Request__c serviceRequest = new Service_Request__c();
            serviceRequest.SR_Origin__c = 'Call Center';
            serviceRequest.CheckStatus__c = 'Chiusa';
            serviceRequest.Contact__c = flow.serviceRequest.Contact__c;
            serviceRequest.OwnerId = flow.serviceRequest.OwnerId;
            serviceRequest.Call_Type_SR__c = flow.serviceRequest.Call_Type_SR__c;
            serviceRequest.Customer_Phone_SR__c = flow.serviceRequest.Customer_Phone_SR__c;
            serviceRequest.Date_Time_SR__c = flow.serviceRequest.Date_Time_SR__c;
            serviceRequest.Duration_SR__c = flow.serviceRequest.Duration_SR__c;
            serviceRequest.Id_Phone_SR__c = flow.serviceRequest.Id_Phone_SR__c;
            serviceRequest.Key_IVR_SR__c = flow.serviceRequest.Key_IVR_SR__c;
            serviceRequest.Mystery_Call_Check__c = flow.serviceRequest.Mystery_Call_Check__c;
            serviceRequest.Name_IVR_SR__c = flow.serviceRequest.Name_IVR_SR__c;
            serviceRequest.RC_Phone_SR__c = flow.serviceRequest.RC_Phone_SR__c;
            serviceRequest.Subject_SR__c = flow.serviceRequest.Subject_SR__c;
            serviceRequest.Waiting_Time__c = flow.serviceRequest.Waiting_Time__c;

            Database.SaveResult result =  Database.insert(serviceRequest);
            system.debug('result -> ' + result);
            if ( result != null ) {
                FlowCreateSRIService.futureUpdateObjectFromFlowCreateSRI(flow.task.Id, result.getId(), flow.customSettingValueForTaskWhoId);
            } else {
                system.debug('Errore nel salvataggio di -> ' + flow.serviceRequest);
            }
        }
    }

    public class FlowInput {
        @InvocableVariable
        public Task task;

        @InvocableVariable
        public Service_Request__c serviceRequest;

        @InvocableVariable
        public String customSettingValueForTaskWhoId;
    }

}
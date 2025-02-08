public with sharing class CaseExtension {
    public String ServiceRequestId{get; set;}
    public CaseExtension(ApexPages.StandardController controller) {
        Case objCase = (Case)controller.getRecord();
        ServiceRequestId = objCase.Service_Request__c;

    }
}
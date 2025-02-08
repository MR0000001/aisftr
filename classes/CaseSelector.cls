public without sharing class CaseSelector {
    public static Case getCaseById(String caseId) {
        Case caseReturned = [SELECT Id,Start_Day_Access__c,Finish_Day_Access__c,CaseNumber,License_plate__c,Is_Person_Account_Account_on_Case__c, To_be_sent_Brogliaccio__c,Last_Batch_Date_Time__c, Brogliaccio_DescriptioError__c, Concession_Number__c,Concession_Municipality__c,ID_Comune__c,Account.FirstName,ContactPhone,ContactEmail,Case_Theme_Area__c,Street_Address__c, Number_Address__c, Letter_Address__c, CreatedDate, Description, Account.LastName, Status, Case_Action__c, Account.Fiscal_Code__pc, Account.IsPersonAccount, Contact.Fiscal_Code_contact__c, Strada_KO__c, Sub_Status__c, Integration_Update_From_WSO2__c, ExternalSystemId_AMALV__c, Case_Specification__c, Account.Name, ContactMobile, Geolocation__Latitude__s, Geolocation__Longitude__s, Subject, Sent_to_External__c, ExternalSystemId_Brogliaccio__c, All_Content_Versions_Integrated__c, checkAnonymous__c, Current_Queue__c, Comment_User__c, Brogliaccio_N_Attachment__c, Case_Business_Account__c  FROM Case WHERE Id =: caseId];

        return caseReturned;
    }

    public static Integer getCaseCounts(String query) {
        return Database.countQuery(query);
    }

    public static List<Case> getCasesByCaseIds(List<String> caseIds) {
        List<Case> cases = [SELECT ProtocolCFUser__c, Status, ID_Protocollo__c, CreatedDate, All_Content_Versions_Integrated_GED__c, ToBeSentGED__c, GEDCasePDF__c FROM Case WHERE Id IN: caseIds];

        return cases;
    }

    public static List<Case> getCasesBrogliaccioByCaseIds(List<String> caseIds) {
        List<Case> cases = [SELECT All_Content_Versions_Integrated__c FROM Case WHERE Id IN: caseIds];

        return cases;
    }

    public static List<Case> getCasesForPDFById(List<String> caseIds) {
        List<Case> cases = [SELECT CaseNumber, Type, Origin, ProtocolStructure__c, Account.Fiscal_Code__pc, Account.Name, ContactEmail, Street_Address__c, Number_Address__c, Letter_Address__c, Subject, Owner.Name, CreatedDate, CreatedBy.Name, LastModifiedBy.Name, Case_Business_Account__c FROM Case WHERE Id IN: caseIds];

        return cases;
    }

    public static List<Case> getCasesCreatedDateByCaseIds(List<String> caseIds) {
        return [SELECT CreatedDate FROM Case WHERE Id IN: caseIds];
    }

    public static List<Database.SaveResult> updateCases(List<Case> cases, Boolean allOrNone) {
        DebugService.printLimits('CaseSelector', 'updateCases', 'start');
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        try {
            results = Database.update(cases, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('CaseSelector', 'updateCases', e);
        }
        DebugService.printLimits('CaseSelector', 'updateCases', 'end');

        return results;
    }

    public static void deleteCases(List<Case> cases, Boolean allOrNone) {
        try {
            Database.DeleteResult[] results = Database.delete(cases, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            System.debug('Exception at CaseSelector.deleteCases: ' + e.getMessage());

            ErrorLogEventHandler.standardExceptionLog(e);
        }
    }

    public static Map<String, Case> getCasesForGedByIds(List<String> caseIds) {
        return new Map<String, Case>([SELECT ToBeSentGED__c, Protocol_Number__c, YearProtocol__c, ID_Protocollo__c, DateTimeProtocol__c, GEDCasePDF__c, Status, Sent_to_External__c, All_Content_Versions_Integrated_GED__c, Last_Batch_Date_Time__c, LastModifiedDate, COD_DOC__c, COD_SIS__c, DOC_LOGIC__c, ProtocolCFUser__c, Account.Gender__pc, Account.Name, Account.Fiscal_Code__pc, Account.PersonBirthdate, Account.PersonEmail, Account.PersonOtherStreet, Account.PersonOtherState, Account.PersonOtherPostalCode, Account.PersonOtherCity, Subject FROM Case WHERE Id IN: caseIds]);
    }
}
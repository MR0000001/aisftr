@isTest
public without sharing class XC_IN091_CheckQualityClosureRequest_TEST {
    @testSetup
    private static void testSetup() {
        XC_B2BG_QualityCheck__c qualityCheck = new XC_B2BG_QualityCheck__c();
        qualityCheck.XC_ReportDiSopralluogoRedattoIl__c = date.today();
        qualityCheck.XC_CheckDate__c = date.today();
        insert qualityCheck;
        XC_KPI_Quality_Check_Request__c request = new XC_KPI_Quality_Check_Request__c();
        request.XC_Country__c = 'Italy';
        request.XC_Quality_Check__c = qualityCheck.Id;
        insert request;
        XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense spl = new XC_UTIL_SafetyPointsLicenseManagement.SafetyPointsLicense('Italy', 'EnelSole', true, true, 50, 0, 5, 3, 3);
        XC_UTIL_SafetyPointsLicenseManagement.createNewSafetyPointsLicenseSettings(spl);
        List<XC_CS011_SafetyPointsLicenseSettings__c> qcLicenseSettings = XC_CS011_SafetyPointsLicenseSettings__c.getAll().values();
        qcLicenseSettings[0].XC_KPI_QualityCheck_Bonus__c = 6;
        qcLicenseSettings[0].XC_KPI_QualityCheck_Malus_Threshold__c = -15;
        qcLicenseSettings[0].XC_CheckQualityNullAccessMalus__c = -4;
        update qcLicenseSettings;
        XC_CS017_KPIQualityCheck__c qcSettings = new XC_CS017_KPIQualityCheck__c();
        qcSettings.Name = 'Italy_HighPriority';
        qcSettings.XC_FieldSet__c = 'XC_FS_HighPriorityQualityCheck';
        qcSettings.XC_Country__c = 'Italy';
        qcSettings.XC_Points__c = -4;
        qcSettings.XC_Priority__c = 'High';
        insert qcSettings;
    }
    @isTest
    static void computeKPIQualityCheckTest(){
        XC_KPI_Quality_Check_Request__c request = [SELECT Id,  XC_Request_Status__c, XC_Safety_Points__c, XC_Country__c FROM XC_KPI_Quality_Check_Request__c WHERE XC_Country__c != '' LIMIT 1];
        
        List<XC_IN091_CheckQualityClosureRequest.FlowInputs> inputs = new List<XC_IN091_CheckQualityClosureRequest.FlowInputs>();
        XC_IN091_CheckQualityClosureRequest.FlowInputs input = new XC_IN091_CheckQualityClosureRequest.FlowInputs();
        input.requestId = request.Id;
        inputs.add(input);

        Test.startTest();
        XC_IN091_CheckQualityClosureRequest.computeQualityCheckClosure(inputs);
        Test.stopTest();
        XC_KPI_Quality_Check_Request__c requestDB = [SELECT Id,  XC_Request_Status__c, XC_Safety_Points__c, XC_Country__c FROM XC_KPI_Quality_Check_Request__c WHERE XC_Country__c != '' LIMIT 1];
        System.assertEquals('In Progress', requestDB.XC_Request_Status__c);
        System.assertEquals(6, requestDB.XC_Safety_Points__c);
    }

}
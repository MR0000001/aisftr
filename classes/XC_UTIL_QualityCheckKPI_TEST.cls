@isTest
public class XC_UTIL_QualityCheckKPI_TEST {
    @TestSetup
   private static void getBonusMalusTest(){ 
          XC_B2BG_QualityCheck__c request = [SELECT Id,XC_CheckDate__c, XC_Country__c
                                             FROM XC_B2BG_QualityCheck__c 
                                             WHERE XC_Country__c != '' LIMIT 1];
       
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
   
        Test.startTest();
        XC_UTIL_QualityCheckKPI.getBonusMalus(request.Id, request.XC_Country__c);
        Test.stopTest();
       
    }

}
/**
 * @description       : utility class for XC_BA007_KPIGoodBehaviorBonus
 * @author            : rui.pedroteixeira@nttdata.com
 * @group             : 
 * @last modified on  : 21-06-2022
 * @last modified by  : rui.pedroteixeira@nttdata.com
**/
public without sharing class XC_BA007_KPIGoodBehaviorBonus_U {

    /**
    * @description method to get the countrys with KPI Good Behavior Bonus Enabled
    * @author rui.pedroteixeira@nttdata.com | 21-06-2022 
    * @return a Set of countrys
    **/
    public static Set<String> getCountrysWithKPIGoodBehaviorBonusEnabled(){
        Set<String> setCountrys = new Set<String>();
        List<XC_CS011_SafetyPointsLicenseSettings__c> lstSafetyPointsLicenseSettings = XC_CS011_SafetyPointsLicenseSettings__c.getAll().values();
        for (XC_CS011_SafetyPointsLicenseSettings__c safetyPointsLicenseSetting : lstSafetyPointsLicenseSettings) {
            if (safetyPointsLicenseSetting.XC_KPIGoodBehaviorBonusEnabled__c) {
                setCountrys.add(safetyPointsLicenseSetting.XC_Country__c);
            }
        }
        return setCountrys;
    }

    /**
    * @description method to get a map with Account Total QualityChecks
    * @author rui.pedroteixeira@nttdata.com | 21-06-2022 
    * @param setAccountsIds 
    * @return Return a map with accountid and a total of some fields are true.
    **/
    public static Map<Id, Map<String,Integer>> getAccountTotalQualityChecks(Set<Id> setAccountsIds){
        Set<Id> setRecordTypesId = getQualityCheckRecordTypesId();

        XC_CS016_KPIGoodBehavior__c  csKPIGoodBehavior = XC_CS016_KPIGoodBehavior__c.getOrgDefaults();
        Integer numberofDaystoCalculateBonus =  Integer.valueOf(csKPIGoodBehavior.XC_NumberofDaystoCalculateBonus__c);
        Date dateLessNumberofDaystoCalculateBonus = System.Today().addDays(-numberofDaystoCalculateBonus);

        Map<Id,Map<String,Integer>> mapAccountsTotalQualityChecks = new Map<Id,Map<String,Integer>>();
        Map<String,Integer> mapFieldsTotal = new Map<String,Integer>();

        for (XC_B2BG_QualityCheck__c qualityCheck : [SELECT Id,XC_ContractorCompany__c,XC_Over15__c,XC_StopWorkPolicy__c,XC_KPI_Serious_NonCompliance__c
                                                     FROM XC_B2BG_QualityCheck__c 
                                                     WHERE XC_ContractorCompany__c 
                                                     IN :setAccountsIds
                                                     AND RecordTypeId IN :setRecordTypesId
                                                     AND XC_Status__c = 'Validated'
                                                     AND LastModifiedDate <= TODAY AND LastModifiedDate >= :dateLessNumberofDaystoCalculateBonus]) {
           
            if (mapAccountsTotalQualityChecks.containsKey(qualityCheck.XC_ContractorCompany__c)) {
                mapFieldsTotal = mapAccountsTotalQualityChecks.get(QualityCheck.XC_ContractorCompany__c);

                Integer totalOver15 = mapFieldsTotal.get('XC_Over15__c');
                Integer totalSerious_NonCompliance = mapFieldsTotal.get('XC_KPI_Serious_NonCompliance__c');
                Integer totalStopWorkPolicy = mapFieldsTotal.get('XC_StopWorkPolicy__c');

                if (!String.isBlank(qualityCheck.XC_Over15__c)) {
                    totalOver15 = qualityCheck.XC_Over15__c == 'Yes' ? totalOver15+1 : totalOver15;
                    mapFieldsTotal.put('XC_Over15__c', totalOver15);
                }

                totalSerious_NonCompliance = qualityCheck.XC_KPI_Serious_NonCompliance__c  == true  ? totalSerious_NonCompliance+1 : totalSerious_NonCompliance;
                mapFieldsTotal.put('XC_KPI_Serious_NonCompliance__c', totalSerious_NonCompliance);

                totalStopWorkPolicy = qualityCheck.XC_StopWorkPolicy__c  == true  ? totalStopWorkPolicy+1 : totalStopWorkPolicy;
                mapFieldsTotal.put('XC_StopWorkPolicy__c', totalStopWorkPolicy);

                mapAccountsTotalQualityChecks.put(qualityCheck.XC_ContractorCompany__c, mapFieldsTotal);
            } else {
                mapFieldsTotal = new Map<String,Integer>();

                Integer totalOver15 = 0;
                Integer totalSerious_NonCompliance = 0;
                Integer totalStopWorkPolicy = 0;

                if (!String.isBlank(qualityCheck.XC_Over15__c)) {
                    totalOver15 = qualityCheck.XC_Over15__c == 'Yes' ? totalOver15+1 : totalOver15;
                    mapFieldsTotal.put('XC_Over15__c', totalOver15);
                }else {
                    mapFieldsTotal.put('XC_Over15__c', null);
                }

                totalSerious_NonCompliance = qualityCheck.XC_KPI_Serious_NonCompliance__c  == true ? totalSerious_NonCompliance+1 : totalSerious_NonCompliance;
                mapFieldsTotal.put('XC_KPI_Serious_NonCompliance__c', totalSerious_NonCompliance);

                totalStopWorkPolicy = qualityCheck.XC_StopWorkPolicy__c  == true  ? totalStopWorkPolicy+1 : totalStopWorkPolicy;
                mapFieldsTotal.put('XC_StopWorkPolicy__c', totalStopWorkPolicy);

                mapAccountsTotalQualityChecks.put(qualityCheck.XC_ContractorCompany__c, mapFieldsTotal);
            }
        }
        return mapAccountsTotalQualityChecks;
    }

    /**
    * @description method to get the RecordTypeId that contains Home
    * @author rui.pedroteixeira@nttdata.com | 21-06-2022 
    * @return a Set of RecordTypeIds
    **/
    public static Set<Id> getQualityCheckRecordTypesId(){
        Set<Id> setRecordTypesId = new Set<Id>();
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.XC_B2BG_QualityCheck__c.getRecordTypeInfosByName();

        for (String recordTypeInfo : recordTypes.keySet()) {
            if (recordTypeInfo.contains(' - Home')) {
                setRecordTypesId.add(recordTypes.get(recordTypeInfo).getRecordTypeId());
            }
        }
        return setRecordTypesId;
    }

    /**
    *@description It inserts one Good Behavior KPI Request record
    *@author Rui Teixeira - rui.pedroteixeira@nttdata.com 
    *@return Good Behavior Request
    **/
    public static XC_KPI_Good_Behavior_Request__c createKPIRequest() {
        XC_KPI_Good_Behavior_Request__c request = new XC_KPI_Good_Behavior_Request__c();
        request.XC_Request_Status__c = 'In Progress';
        request.XC_Request_Date__c = System.now();
        return request;
    }

    /**
    *@author Rui Teixeira - rui.pedroteixeira@nttdata.com
    *@description It inserts one Good Behavior KPI Detail record 
    *@param jobId Id of the master Request record
    *@param accountId Account Id for which the KPI is calculated
    *@return Good Behavior Request Detail to insert
    **/
    public static XC_KPI_Good_Behavior_Request_Detail__c createKPIDetail(Id requestId, Id accountId, Map<String,Integer> mapFieldsTotal) {
        XC_KPI_Good_Behavior_Request_Detail__c gbrd = new XC_KPI_Good_Behavior_Request_Detail__c();
        XC_KPI_Good_Behavior_Request__c request = [
            SELECT Id, XC_Request_Date__c
            FROM XC_KPI_Good_Behavior_Request__c
            WHERE Id = :requestId
            LIMIT 1
        ];
        gbrd.KPI_Good_Behavior_Request__c = requestId;
        gbrd.XC_Request_Date__c = request.XC_Request_Date__c;
        gbrd.XC_Account__c = accountId;
        gbrd.XC_Request_Date__c = System.now();
        gbrd.XC_Request_Status__c = 'Completed';
        gbrd.XC_Over15__c = mapFieldsTotal.get('XC_Over15__c');
        gbrd.XC_KPI_Serious_NonCompliance__c = mapFieldsTotal.get('XC_KPI_Serious_NonCompliance__c');
        gbrd.XC_StopWorkPolicy__c = mapFieldsTotal.get('XC_StopWorkPolicy__c');
        return gbrd;
    }

    /**
    *@author Rui Teixeira - rui.pedroteixeira@nttdata.com
    *@description It inserts one Good Behavior KPI Detail error record
    *@param jobId Id of the jobId
    *@param accountId Account Id for which the KPI is calculated
    *@param message error message
    *@return Good Behavior Request Detail error to insert
    **/
    public static XC_KPI_Good_Behavior_Request_Detail__c createKPIDetailError(Id requestId, Id accountId, String message) {
        XC_KPI_Good_Behavior_Request_Detail__c gbrd = new XC_KPI_Good_Behavior_Request_Detail__c();
        XC_KPI_Good_Behavior_Request__c request = [
            SELECT Id
            FROM XC_KPI_Good_Behavior_Request__c
            WHERE id = :requestId
            LIMIT 1
        ];
        gbrd.KPI_Good_Behavior_Request__c = requestId;
        gbrd.XC_Account__c = accountId;
        gbrd.XC_Request_Date__c = System.now();
        gbrd.XC_Request_Status__c = 'Error';
        gbrd.XC_Request_Details__c = message;
        return gbrd;
    }
}
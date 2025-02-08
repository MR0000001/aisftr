/**
 * Created by snekkanti002 on 03/08/2021.
 */

public without sharing class OpenDataService {
    public static Map<Integer, Map<String, String>> getIdQueryMap(List<OpenData_Setting__mdt> settings, Map<String, String> settingIdQueryMap) {
        Map<Integer, Map<String, String>> idSinglesMap = new Map<Integer, Map<String, String>>();

        for (OpenData_Setting__mdt setting : settings) {
            if (setting.Id_Query__c != null) {
                Map<String, String> queries = new Map<String, String>();

                queries.put('query', settingIdQueryMap.get(String.valueOf(setting.Id_Query__c)));
                queries.put('fileName', setting.FileName__c);

                idSinglesMap.put(Integer.valueOf(setting.Id_Query__c), queries);
            }
        }
        System.debug(idSinglesMap);
        System.debug(idSinglesMap.keySet());

        return idSinglesMap;
    }

    public static Map<Integer, List<OpenData_Setting__mdt>> getIdFieldsMap(List<OpenData_Setting__mdt> settings, Integer noOfQueries) {
        Map<Integer, List<OpenData_Setting__mdt>> idFieldsMap = new Map<Integer, List<OpenData_Setting__mdt>>();

        for (Integer i = 1; i <= noOfQueries; i++) {
            for (OpenData_Setting__mdt setting : settings) {
                if (setting.Ref_Id__c != null && setting.Ref_Id__c == i) {
                    if (!idFieldsMap.containsKey(i)) {
                        idFieldsMap.put(i, new List<OpenData_Setting__mdt>{
                                setting
                        });
                    } else {
                        List<OpenData_Setting__mdt> tmp = idFieldsMap.get(i);
                        tmp.add(setting);
                        idFieldsMap.put(i, tmp);
                    }
                }
            }
        }
        return idFieldsMap;
    }

    public static Map<String, String> getSettingIdQueryMap() {
        Map<String, String> settingIdQueryMap = new Map<String, String>();

        List<OpenData_Setting__mdt> openDataSettings = [
                SELECT Query__c, Id_Query__c FROM OpenData_Setting__mdt
                WHERE Id_Query__c != NULL
        ];

        for(OpenData_Setting__mdt openDataSetting : openDataSettings) {
            settingIdQueryMap.put(String.valueOf(openDataSetting.Id_Query__c), openDataSetting.Query__c);
        }

        return settingIdQueryMap;
    }

    public static List<String> createOpenDataLogs(Map<String, RequestOpenDataWebService.Esiti> outcomeIdOutcomeMap) {
        List<String> errorIds = new List<String>();

        List<Opendata_log__c> opendataLogs = new List<Opendata_log__c>();

        Map<String, OpenData_Setting__mdt> settings = OpenData_Setting__mdt.getAll();

        Map<String, String> settingIdQueryMap = getSettingIdQueryMap();

        errorIds.addAll(outcomeIdOutcomeMap.keySet());
        for(OpenData_Setting__mdt setting : settings.values()) {
            if(outcomeIdOutcomeMap.containsKey(String.valueOf(setting.Id_Query__c))) {
                errorIds.remove(errorIds.indexOf(String.valueOf(setting.Id_Query__c)));
                Opendata_log__c opendataLog = new Opendata_log__c();

                opendataLog.Datetime_Response__c = Datetime.now();
                opendataLog.Query__c = settingIdQueryMap.get(String.valueOf(setting.Id_Query__c));
                opendataLog.NumberOfCases__c = String.valueOf(CaseSelector.getCaseCounts(setting.Query_Count__c));
                opendataLog.isInsertDataSet__c = (outcomeIdOutcomeMap.get(String.valueOf(setting.Id_Query__c)).isInsertDataSet == null) ? false : outcomeIdOutcomeMap.get(String.valueOf(setting.Id_Query__c)).isInsertDataSet;

                if(outcomeIdOutcomeMap.get(String.valueOf(setting.Id_Query__c)).Esito.equalsIgnoreCase('1')) {
                    opendataLog.Result__c = true;
                    opendataLog.ErrorMessage__c = null;
                } else {
                    opendataLog.ErrorMessage__c = (outcomeIdOutcomeMap.get(String.valueOf(setting.Id_Query__c)).errorCode + ' ' + outcomeIdOutcomeMap.get(String.valueOf(setting.Id_Query__c)).errorMessage).abbreviate(Opendata_log__c.ErrorMessage__c.getDescribe().getLength());
                }
                opendataLogs.add(opendataLog);
            }
        }

        OpenDataSelector.insertOpenDataLogs(opendataLogs, false);

        return errorIds;
    }

    public static void insertOpenDataLogs(List<Opendata_log__c> opendataLogs, Boolean allOrNone) {
        if(opendataLogs != null && !opendataLogs.isEmpty()) {
            OpenDataSelector.insertOpenDataLogs(opendataLogs, allOrNone);
        }
    }
}
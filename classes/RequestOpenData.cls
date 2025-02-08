/**
 * Created by snekkanti002 on 02/08/2021.
 */

public without sharing class RequestOpenData {
    private static Map<Integer, String> monthsItalian = new Map<Integer, String>{2 => 'Gennaio', 3 => 'Febbraio', 4 => 'Marzo', 5 => 'Aprile', 6 => 'Maggio', 7 => 'Giugno', 8 => 'Luglio', 9 => 'Agosto', 10 => 'Settembre', 11 => 'Ottobre', 12 => 'Novembre', 1 => 'Dicembre'};

    public List<Query> queries;

    public class Query {
        public String id;
        public String query;
        public String fileName;
        public List<Field> fields;
    }

    public class Field {
        public String fieldName;
        public String id;
        public String type;
        public Info info;
    }

    public class Info {
        public String notes;
    }

    public RequestOpenData(Map<String, OpenData_Setting__mdt> settings, Map<String, String> settingIdQueryMap) {
        try {
            this.queries = new List<Query>();

            Map<Integer, Map<String, String>> idSinglesMap = OpenDataService.getIdQueryMap(settings.values(), settingIdQueryMap);

            Map<Integer, List<OpenData_Setting__mdt>> idFieldsMap = OpenDataService.getIdFieldsMap(settings.values(), idSinglesMap.size());

            System.debug('idSinglesMap -> ' + idSinglesMap);
            System.debug('idFieldsMap -> ' + idFieldsMap);

            for(Integer i=1; i<=idSinglesMap.size(); i++) {
                Query query = new Query();
                query.id = String.valueOf(i);
                query.query = idSinglesMap.get(i).get('query');
                query.fileName = idSinglesMap.get(i).get('fileName') + ' ' + monthsItalian.get(Datetime.now().month()) + '.csv';
                query.fields = new List<Field>();
                idFieldsMap.get(i).sort();
                for(OpenData_Setting__mdt singleData : idFieldsMap.get(i) ) {
                    System.debug(' -> ' + singleData.DeveloperName);
                }
                for(Integer j=0; j<idFieldsMap.get(i).size(); j++) {
                    Field field = new Field();
                    field.fieldName = idFieldsMap.get(i)[j].Field_Name__c;
                    field.id = idFieldsMap.get(i)[j].Id__c;
                    field.type = idFieldsMap.get(i)[j].Type__c;
                    field.info = new Info();
                    field.info.notes = idFieldsMap.get(i)[j].Notes__c;
                    query.fields.add(field);
                }
                this.queries.add(query);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('RequestOpenData', 'Constructor', e);
        }
    }
}
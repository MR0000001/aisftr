/**
 * Created by snekkanti002 on 16/09/2021.
 */

public without sharing class DebugService {

    public static void printLimits(String className, String methodName, String  position) {
        System.debug('Limits in Class: ' + className + '. Method: ' + methodName + '. Position: ' + position + '.\n' +
                'Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries() + '.\n' +
                'Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows() + '.\n' +
                'Queries Aggregate: ' + Limits.getAggregateQueries() + '/' + Limits.getLimitAggregateQueries() + '.\n' +
                'Sosl Queries: ' + Limits.getSoslQueries() + '/' + Limits.getLimitSoslQueries() + '.\n' +
                'Query Locator Rows: ' + Limits.getQueryLocatorRows() + '/' + Limits.getLimitQueryLocatorRows() + '.\n' +
                'Dml Statements: ' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements() + '.\n' +
                'Dml Rows: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows() + '.\n' +
                'Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() + '.\n' +
                'Cpu Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + '.\n' +
                'Callouts: ' + Limits.getCallouts() + '/' + Limits.getLimitCallouts() + '.\n' +
                'Queueable Jobs: ' + Limits.getQueueableJobs() + '/' + Limits.getLimitQueueableJobs() + '.\n');
    }

    public static void printException(String className, String methodName, Exception e) {
        System.debug('Exception in Class: ' + className + '. Method: ' + methodName + '.\n' +
                'Message: ' + e.getMessage() + '.\n' +
                'Cause: ' + e.getCause() + '.\n' +
                'Line Number: ' + e.getLineNumber() + '.\n' +
                'Exception Type: ' + e.getTypeName() + '.\n' +
                'Stack Trace: ' + e.getStackTraceString() + '.\n');
    }

    public static void printResponse(String className, String methodName, HttpResponse res) {
        if(res != null) {
            System.debug('Response in Class: ' + className + '. Method: ' + methodName + '.\n' +
                    'Status Code: ' + res.getStatusCode() + '.\n' +
                    'Status: ' + res.getStatus() + '.\n' +
                    'Body: ' + (String.isNotBlank(res.getBody()) ? res.getBody() + '.' : 'null.'));
            for(String k : res.getHeaderKeys()) {
                System.debug('Header ' + k + ': ' + res.getHeader(k) + '.');
            }
        } else {
            System.debug('Response is null');
        }
    }

    public static void printRequest(String className, String methodName, HttpRequest req) {
        if(req != null) {
            System.debug('Request in Class: ' + className + '. Method: ' + methodName + '.\n' +
                    'Http Method: ' + req.getMethod() + '.\n' +
                    'Endpoint: ' + req.getEndpoint() + '.\n' +
                    'Authorization: ' + req.getHeader('Authorization') + '.\n' +
                    'Content-Type: ' + req.getHeader('Content-Type') + '.\n' +
                    'Accept: ' + req.getHeader('Accept') + '.\n' +
                    'Body: ' + (String.isNotBlank(req.getBody()) ? req.getBody() + '.' : 'null.'));
        } else {
            System.debug('Request is null');
        }
    }

    public static void printList(String className, String methodName, String listName, List<Object> objects) {
        if (objects != null) {
            System.debug('List in Class: ' + className + '. Method: ' + methodName + '. List Name: ' + listName + '. Is list empty? ' + objects.isEmpty() + '. List size: ' + objects.size() + '. List values: ' + objects);
        } else {
            System.debug('List in Class: ' + className + '. Method: ' + methodName + '. List Name: ' + listName + '. List is null.');
        }
    }

    public static void printList(String className, String methodName, String listName, List<Object> objects, Boolean expandList) {
        if(objects != null) {
            System.debug('List in Class: ' + className + '. Method: ' + methodName + '. List Name: ' + listName + '. Is list empty? ' + objects.isEmpty() + '. List size: ' + objects.size());
            if(expandList && !objects.isEmpty()) {
                printListExpanded(objects);
            } else {
                System.debug('List values: ' + objects);
            }
        } else {
            System.debug('List in Class: ' + className + '. Method: ' + methodName + '. List Name: ' + listName + '. List is null.');
        }
    }

    public static void printListExpanded(List<Object> objects) {
        for(Integer i=0; i < objects.size(); i++) {
            System.debug('Element at index ' + i + ': ' + objects[i]);
        }
    }

    public static void printMapExpanded(List<List<Object>> objects) {
        for(Integer i=0; i < objects.size(); i++) {
            System.debug('Key\'s element at index ' + i + ': ' + objects[i]);
            for(Integer j=0; j < objects[i].size(); j++) {
                System.debug('Expanded element at index ' + j + ': ' + objects[i][j]);
            }
        }
    }

    public static void printMap(String className, String methodName, String mapName, List<Object> mapKeys, List<Object> mapValues, Boolean expandValues) {
        if(mapKeys != null) {
            System.debug('Map in Class: ' + className + '. Method: ' + methodName + '. Map Name: ' + mapName + '. Is Map empty? ' + mapKeys.isEmpty() + '. Map size: ' + mapKeys.size() + '. Map keys: ' + mapKeys);
            if(expandValues && !mapKeys.isEmpty()) {
                printListExpanded(mapValues);
            } else {
                System.debug('Map values: ' + mapValues);
            }
        } else {
            System.debug('Map in Class: ' + className + '. Method: ' + methodName + '. Map Name: ' + mapName + '. Map is null.');
        }
    }

    public static void printMap(String className, String methodName, String mapName, List<Object> mapKeys, List<List<Object>> mapValues, Boolean expandValues) {
        if(mapKeys != null) {
            System.debug('Map in Class: ' + className + '. Method: ' + methodName + '. Map Name: ' + mapName + '. Is Map empty? ' + mapKeys.isEmpty() + '. Map size: ' + mapKeys.size() + '. Map keys: ' + mapKeys);
            if(expandValues && !mapKeys.isEmpty()) {
                printMapExpanded(mapValues);
            }  else {
                System.debug('Map values: ' + mapValues);
            }
        } else  {
            System.debug('Map in Class: ' + className + '. Method: ' + methodName + '. Map Name: ' + mapName + '. Map is null.');
        }
    }

    public static void printDatabaseResults(String className, String methodName, String listName, List<Object> results) {
        System.debug('Database results in Class: ' + className + '. Method: ' + methodName + '. List: ' + listName + '.');
        if(results instanceof List<Database.SaveResult>) {
            List<Database.SaveResult> saveResults = (List<Database.SaveResult>) results;
            for(Database.SaveResult saveResult : saveResults) {
                System.debug('Save result is success: ' + saveResult.isSuccess() + '. Id: ' + saveResult.getId());
                if(!saveResult.isSuccess()) {
                    printListExpanded(saveResult.getErrors());
                }
            }
        } else if(results instanceof List<Database.UpsertResult>) {
            List<Database.UpsertResult> upsertResults = (List<Database.UpsertResult>) results;
            for(Database.UpsertResult upsertResult : upsertResults) {
                System.debug('Upsert result is success: ' + upsertResult.isSuccess() + '. Id: ' + upsertResult.getId());
                if(!upsertResult.isSuccess()) {
                    printListExpanded(upsertResult.getErrors());
                }
            }
        } else if(results instanceof List<Database.DeleteResult>) {
            List<Database.DeleteResult> deleteResults = (List<Database.DeleteResult>) results;
            for(Database.DeleteResult deleteResult : deleteResults) {
                System.debug('Delete result is success: ' + deleteResult.isSuccess() + '. Id: ' + deleteResult.getId());
                if (!deleteResult.isSuccess()) {
                    printListExpanded(deleteResult.getErrors());
                }
            }
        } else if(results instanceof List<Database.UndeleteResult>) {
            List<Database.UndeleteResult> undeleteResults = (List<Database.UndeleteResult>) results;
            for(Database.UndeleteResult undeleteResult : undeleteResults) {
                System.debug('Undelete result is success: ' + undeleteResult.isSuccess() + '. Id: ' + undeleteResult.getId());
                if (!undeleteResult.isSuccess()) {
                    printListExpanded(undeleteResult.getErrors());
                }
            }
        }
    }

    public static void printRestResponse(String className, String methodName, RestResponse res) {
        if(res != null) {
            System.debug('Rest response in Class: ' + className + '. Method: ' + methodName + '.\n' +
                    'Status Code: ' + res.statusCode + '.\n' +
                    'Body: ' + (String.isNotBlank(res.responseBody?.toString()) ? res.responseBody?.toString() + '.' : 'null.'));
            for(String k : res.headers.keySet()) {
                System.debug('Header ' + k + ': ' + res.headers.get(k) + '.');
            }
        } else {
            System.debug('Rest Response is null');
        }
    }
}
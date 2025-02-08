/**
 * Created by LCONATO00 on 08/10/2020.
 */

public with sharing class ErrorLogEventHandler {
    private final static Integer MAXLENGTH = 32768;
    private final static String exceptionLogType = 'Exception';
    private final static String infoLogType = 'Info';

    public static Error_Log_Event__e createEvent(Exception e){
        return initializeEvent(e, '', '', '',exceptionLogType);
    }

    public static Error_Log_Event__e createInfoEvent(Exception e){
        return initializeEvent(e, '', '', '',infoLogType);
    }

    public static Error_Log_Event__e createEvent(Exception e, String note){
        return initializeEvent(e, note, '', '',exceptionLogType);
    }

    public static Error_Log_Event__e createEvent(Exception e, String note, String request, String response){
        return initializeEvent(e, note, request, response,exceptionLogType);
    }

    public static Error_Log_Event__e createEvent(Exception e,String request, String response){
        return initializeEvent(e, '', request, response,exceptionLogType);
    }

    public static Error_Log_Event__e createEvent(String note){
        return initializeInfoLogEvent(note, '', '');
    }

    public static Error_Log_Event__e createEvent(String errorMessage, Boolean isError){
        return initializeLogEventWithBoolean(errorMessage, isError);
    }

    public static Error_Log_Event__e createEvent(String className, String methodName, String debugType, String message, String note){
        return initializeDebuggerEvent(className, methodName, debugType, message, note);
    }

    public static Error_Log_Event__e createEvent(String request, String response){
        return initializeInfoLogEvent('', request, response);
    }

    public static Error_Log_Event__e createEvent(String note, String request, String response){
        return initializeInfoLogEvent(note, request, response);
    }

    public static Error_Log_Event__e createEvent(List<Object> databaseResults){
        List<String> databaseErrors = new List<String>();
        List<DatabaseGenericResult> results = DatabaseGenericResult.resultsToGenericResults(databaseResults);

        for(DatabaseGenericResult res: results) {
            if(!res.isSuccess()) {
                databaseErrors.add(String.valueOf(res.getErrors()));
            }
        }

        if(!databaseErrors.isEmpty()) {
            try {   //exception type doesn't really matter, we just need a stack trace
                throw new MathException('');
            } catch(Exception e) {
                return initializeEvent(e, String.valueOf(databaseErrors),'','',exceptionLogType);
            }
        } else {
            return null;
        }
    }

    private static Error_Log_Event__e initializeInfoLogEvent(String note, String request, String response){
        try{//exception type doesn't really matter, we just need a stack trace
            throw new MathException(note);
        }
        catch(Exception e){
            return initializeInfoEvent(e, note, infoLogType);
        }
    }

    //prendiamo un booleano per decidere che tipo di log mostrare
    private static Error_Log_Event__e initializeLogEventWithBoolean(String message, Boolean isError){
        try{//exception type doesn't really matter, we just need a stack trace
            if (isError == true) {
                throw new DmlException(message);
            } else {
                throw new DmlException('Info Event');
            }
        }
        catch(Exception e){
            if (isError == true) {
                return initializeInfoEvent(e, 'Error Event', exceptionLogType);
            } else {
                return initializeInfoEvent(e, message, infoLogType);
            }
        }
    }

    //initializes all the record fields
    private static Error_Log_Event__e initializeEvent(Exception e,String note, String request, String response,String logType){
        String className;
        String methodName;

        List<String> namingInfo = extractNamingInfo(e);
        if (namingInfo.size() > 0) {
            className = namingInfo.get(0);
            if (namingInfo.size() > 1) {
                methodName = namingInfo.get(1);
            }
        }

        Error_Log_Event__e eventLog = new Error_Log_Event__e(User__c = UserInfo.getUserId(),
                Date__c = System.now(),
                Error_Message__c = e.getMessage(),
                Exception_Type__c = logType == exceptionLogType ? e.getTypeName() : null,
                Error_Row__c = String.valueOf(e.getLineNumber()),
                Stack_Trace__c = e.getStackTraceString(),
                Class_Name__c = className,
                Method_Name__c = methodName,
                Log_Typology__c = LogType,
                Note__c = note.abbreviate(MAXLENGTH));

        return eventLog;
    }

    //initializes all the record fields
    private static Error_Log_Event__e initializeInfoEvent(Exception e,String note, String logType){
        String className;
        String methodName;

        List<String> namingInfo = extractNamingInfo(e);
        if (namingInfo.size() > 0) {
            className = namingInfo.get(0);
            if (namingInfo.size() > 1) {
                methodName = namingInfo.get(1);
            }
        }

        Error_Log_Event__e eventLog = new Error_Log_Event__e(User__c = UserInfo.getUserId(),
                Date__c = System.now(),
                Error_Message__c = e.getMessage(),
                Exception_Type__c = logType,
                Stack_Trace__c = e.getStackTraceString(),
                Class_Name__c = className,
                Method_Name__c = methodName,
                Log_Typology__c = LogType,
                Note__c = note.abbreviate(MAXLENGTH));

        return eventLog;
    }

    //initializes all the record fields
    private static Error_Log_Event__e initializeDebuggerEvent(String className, String methodName, String debugType, String message, String note){

        Error_Log_Event__e eventLog = new Error_Log_Event__e(User__c = UserInfo.getUserId(),
                Date__c = System.now(),
                Error_Message__c = message,
                Exception_Type__c = debugType,
                Stack_Trace__c = 'Empty',
                Class_Name__c = className,
                Method_Name__c = methodName,
                Log_Typology__c = infoLogType,
                Note__c = note);

        return eventLog;
    }

    //returns a List of Strings where the first one is the className and the second one is the methodName
    private static List<String> extractNamingInfo(Exception e){
        String mainLine;

        List<String> traces = e.getStackTraceString().split('\n');
        for(String trace : traces){
            if(!trace.contains('Class.ErrorLogEventHandler.')){
                //first trace not containing 'Class.LogHandler.' string is the original class/method we are interested in
                mainLine = trace;
                break;
            }
        }
        System.debug(mainLine);

        List<String> namingInfo = mainLine.left(mainLine.indexOf(':')).split('\\.');
        if(namingInfo.size()>1){
            //classica stringa di stackTrace Class.nomeClasse.nomeMetodo
            namingInfo.remove(0); //remove 'Class' string;
        }
        else{
            /* stackTrace strano, metto questo pezzo per evitare che il codice si spacchi se mai si dovesse ottenere uno stackTrace del genere.
             * Se qualcuno riesce a ottenere un caso del genere me lo faccia sapere (per ora sono riuscito ad ottenerlo solo tramite
             * codice eseguito come anonymous block, che però è un caso particolare e out of scope per l' utilizzo dell' oggetto Log__c)
             */
            return 	new List<String>(2);
        }
        return namingInfo;
    }

    public static Exception standardExceptionLog(Exception e){
        if(Limits.getDMLStatements() < 100) {
            // breaking comment
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            Database.SaveResult results = EventBus.publish(errorEvent);
        }
        return e;
    }

    public static Exception standardExceptionLog(String className, String methodName, Exception e) {
        DebugService.printException(className, methodName, e);
        if(Limits.getDMLStatements() < 100) {
            // breaking comment
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            Database.SaveResult results = EventBus.publish(errorEvent);
        }
        return e;
    }

    public static Exception standardExceptionLogNote(Exception e, String note){
        if(Limits.getDMLStatements() < 100) {
            // breaking comment
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e, note);
            Database.SaveResult results = EventBus.publish(errorEvent);
        }
        return e;
    }

    public static void standardExceptionLogTestRethrow(Exception e){

        if(Limits.getDMLStatements() < 100){
            // breaking comment
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);
            Database.SaveResult results = EventBus.publish(errorEvent);

            if (Test.isRunningTest()) {
                throw e; //[FIX-2203]
            }
        }
    }

    public static void standardInfoLogTestRethrow(Exception e){

        if(Limits.getDMLStatements() < 100){
            // breaking comment
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            Database.SaveResult results = EventBus.publish(errorEvent);

            if (Test.isRunningTest()) {
                throw e; //[FIX-2203]
            }
        }
    }

    public static Database.SaveResult publishEventDMLSafe(Error_Log_Event__e errorEvent){

        if(Limits.getDMLStatements() < 100) {
            return EventBus.publish(errorEvent);
        }

        return null;
    }

    public static List<Database.SaveResult> publishEventsDMLSafe(List<Error_Log_Event__e> errorEvents){

        if(errorEvents != null && !errorEvents.isEmpty() && Limits.getDMLStatements() < 100) {
            return EventBus.publish(errorEvents);
        }

        return null;
    }

    public static void createErrorLogsFromFailedDML(List<Object> databaseResults) {
        Error_Log_Event__e errorLogEvent = createEvent(databaseResults);
        if(errorLogEvent != null) ErrorLogEventHandler.publishEventDMLSafe(errorLogEvent);
    }
}
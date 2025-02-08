/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 15/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_PlatformEvent – Util class for Platform Event
*/ 

public class XC_UTIL_PlatformEvent {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_PlatformEvent');
    @TestVisible private static Boolean throwExceptionInTest    = false;
    @TestVisible private static Boolean throwErrorInTest    = false;
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/04/2019
    * @date Modification dd/mm/yyyy
    * @description Given a list of Platform Events makes a publish of the list
    * @param eventToPublish - a sObject
    * @return wrapperList[0] - WrapperResult
    */ 
    public static XC_UTIL_Sobject.WrapperResult publishListEvent(sObject eventToPublish){
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = publishListEvents(new List<sObject>{eventToPublish});
        return wrapperList[0];
    }

    private static void checkIfTestClass(){
        if(Test.isRunningTest() && throwExceptionInTest) {
            throw new XC_Exception();
        }
    }
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/04/2019
    * @date Modification dd/mm/yyyy
    * @description Given a list of Platform Events makes a publish of the list
    * @param listEventToPublish - a list of sObject
    * @return wrapperList - List<WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> publishListEvents(List<sObject> listEventToPublish){
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        if(!listEventToPublish.isEmpty()){  
            try{
                checkIfTestClass();
                List<Database.SaveResult> srList = EventBus.publish(listEventToPublish);
                for (Database.SaveResult sr : srList) {
                    XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
                    if (sr.isSuccess()) {
                        wr.recordId = sr.getId();
                        wr.success = true;
                        wr.errorMessage = '';
                        // Operation was successful, so get the ID of the record that was processed
                        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully published event-> ' + wr);
                    }
                    if(!sr.isSuccess() || throwErrorInTest) {
                        List<String> listErrors = new List<String>();
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            listErrors.add(err.getMessage());     
                        }
                        wr.success = false;
                        wr.errorMessage = String.join(listErrors, '; ');
                    }
					XC_UTIL_Debug.debug(DEBUGACTIVE, 'All successfully published event--> ' + wr);
                    wrapperList.add(wr);
                }   
            } catch(Exception e) { 
                XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
                wr.success = false;
                wr.errorMessage = e.getMessage();
				XC_UTIL_Debug.debug(DEBUGACTIVE, '#Error message--> ' + wr.errorMessage);
                if(e.getTypeName().equals('System.DmlException')) {
                    wr.errorObjectId = e.getDmlId(0);
                    wr.errorMessage = e.getDmlMessage(0);
                    wr.errorfieldName = String.join(e.getDmlFieldNames(0), ';');
                }
                wrapperList.add(wr);
                XC_UTIL_ExceptionLog.insertExceptionLog(e);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '#### Errors ####-> ' + wr.errorMessage);
            } 
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### wrapperList ####-> ' + wrapperList);
        return wrapperList; 
    }
}
/**
* @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
* @date Creation 16/06/2019
* @date Modification dd/mm/yyyy
* @description This 
*/

public without sharing class Giic_ErrorLogsUtility {
    /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 16/06/2019
     * @description error logs wrapper
     */
    public class ErrorLogsWrapper{
        /*
        * @description userStory this is user story entry for error logs
        */
        public string userStory;
        /*
        * @description relatedToFieldAPi  field name for related error logs
        */
        public Map<String, object> relatedToFieldAPi;
        /*
        * @description errorCode  error code for error logs
        */
        public string errorCode;
        /*
        * @description errorMessage  error message 
        */
        public string errorMessage;
        /**
        * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
        * @date 16/06/2019
        * @description constructor for  ErrorLogsWrapper
        * @param userStory user story
        * @param relatedToFieldAPi realted object field
        * @param errorCode error code
        * @param errorMessage error message
        */
        public ErrorLogsWrapper(string userStory,Map<String, object> relatedToFieldAPi,string errorCode,
                               string errorMessage){
            this.userStory=userStory;
            this.relatedToFieldAPi=relatedToFieldAPi;
            this.errorCode=errorCode;
            this.errorMessage=errorMessage;
        }
    }
    /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 16/06/2019
     * @description return error logs object list 
     * @param objErrorLogsWrapper ErrorLogsWrapper object
     * @return List<giic_ErrorLog__c> error list
     */
    public static List<giic_ErrorLog__c> collectErrors(ErrorLogsWrapper objErrorLogsWrapper){
        List<giic_ErrorLog__c> lstErrors=new List<giic_ErrorLog__c>();
        giic_ErrorLog__c objErr= new giic_ErrorLog__c(
            Name = objErrorLogsWrapper.errorCode,
            giic_Process__c   = objErrorLogsWrapper.userStory,
            giic_ErrorDescription__c = objErrorLogsWrapper.errorMessage
        );
        for(String errFieldApi : objErrorLogsWrapper.relatedToFieldAPi.keySet()){
            String parentId =(string) objErrorLogsWrapper.relatedToFieldAPi.get(errFieldApi);  
            objErr.put(errFieldApi, parentId);
        }        
        lstErrors.add(objErr);
        return lstErrors;
    }
    /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 16/06/2019
     * @description insert error logs
     * @param lstErrors list of errors
     */
    public static void insertErrorLogs(List<giic_ErrorLog__c> lstErrors){
        if(Schema.sObjectType.giic_ErrorLog__c.isCreateable()){
            insert lstErrors;
        }
    }
    
     /**
     * @author Pradeep Kumar -  Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
     * @date 16/06/2019
     * @description insert error logs
     * @param lstErrors list of errors
     */
    public static void insertErrorLogs(List<giic_ErrorLog__c> lstErrors, String wrapList){
        for(giic_ErrorLog__c errorLog : lstErrors){
            errorLog.giic_IntegrationWrapper__c = wrapList;
        }
        XC_UTIL_SObject.insertListRecords(lstErrors);        
    }
    
     /**
     * @author Lorenzo Orlanducci -  Lorenzo.orlanducci@nttdata.com
     * @date 02/04/2020
     * @description insert error logs
     * @param e  error exception
     * @param className
     * @param className
     */
    public static void insertGloviaErrorLog(String className, Exception e, String wrapperSentInCall) {
        System.debug('In insertGloviaErrorLog');
       
		if(e.getTypeName().equals('System.DmlException')) {
            String process;
            if(e.getMessage().length() >= 254){
                process = (e.getMessage()).substring(0,253);
            }else{
                process = e.getMessage();
            }
            giic_ErrorLog__c objErr= new giic_ErrorLog__c(
            Name =  'Error on Object: '+e.getDmlId(0) +' field Name: '+String.join(e.getDmlFieldNames(0), ';'),
            giic_ClassMessage__c = className,
            giic_Process__c   = process,
            giic_IntegrationWrapper__c = wrapperSentInCall,
            giic_ErrorDescription__c = e.getDmlMessage(0)
        );
            XC_UTIL_SObject.insertRecord(objErr);  
        }
		 
        
    }
    
    
    
}
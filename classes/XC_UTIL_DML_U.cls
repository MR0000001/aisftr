/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 03/05/2019
* @description XC_UTIL_DML_U – Util class for DMLs
*/

public without sharing class XC_UTIL_DML_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_DML_U');
    @TestVisible private static Boolean failedInTest = false;

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description populateWrapperResultSuccessInsertUpdate – Populate fields of XC_UTIL_Sobject.WrapperResult for SUCCESS (insert/update)
    * @param srList - List<Database.SaveResult>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    
    public static List<XC_UTIL_Sobject.WrapperResult> populateWrapperResultSuccessInsertUpdate(List<Database.SaveResult> srList, List<sObject> listToUpdate){
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        
        for(Database.SaveResult sr : srList) {
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.recordId = sr.getId();
            if(!sr.isSuccess() || (Test.isRunningTest() && failedInTest)) {
                List<String> listErrors = new List<String>();
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    listErrors.add(err.getMessage());     
                }
                wr.success = false;
                wr.errorMessage = String.join(listErrors, '; ');
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Record fields that affected these errors-> ' + wr.errorMessage);
            }
            else { 
                wr.success = true;
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully inserted or updated record-> ' + wr);
            }
            wrapperList.add(wr);
        }  

        return wrapperList;
    } */ 
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 19/07/2019
    * @date Modification dd/mm/yyyy
    * @description populateWrapperResultSuccessInsertUpdateNew – Populate fields of XC_UTIL_Sobject.WrapperResult (insert/update)
    * @param srList - List<Database.SaveResult>
    * @param listToUpdate - List<sObject>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
     public static List<XC_UTIL_Sobject.WrapperResult> populateWrapperResultSuccessInsertUpdateNew(List<Database.SaveResult> srList, List<sObject> listToUpdate){
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        
        for(Integer i=0;i<srList.size();i++){
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.recordId = srList.get(i).getId();
            if(!srList.get(i).isSuccess() || (Test.isRunningTest() && failedInTest)) {
                List<String> listErrors = new List<String>();
                // Operation failed, so get all errors                
                for(Database.Error err : srList.get(i).getErrors()) {
                    listErrors.add(err.getMessage());     
                }
                wr.errorObjectId = listToUpdate.get(i).Id;
                wr.success = false;
                wr.errorMessage = String.join(listErrors, '; ');
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Record fields that affected these errors-> ' + wr.errorMessage);
            }
            else { 
                wr.success = true;
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully inserted or updated record-> ' + wr);
            }
            wrapperList.add(wr);
        }  

        return wrapperList;
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description populateWrapperResultSuccessUpsert – Populate fields of XC_UTIL_Sobject.WrapperResult for SUCCESS (upsert)
    * @param srList - List<Database.UpsertResult>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    /*public static List<XC_UTIL_Sobject.WrapperResult> populateWrapperResultSuccessUpsert(List<Database.UpsertResult> srList) {
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        
        for(Database.UpsertResult sr : srList) {
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            if(sr.isSuccess()) {
                wr.recordId = sr.getId();
                wr.success = true;
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully upsert record -> ' + wr);
            } else {
                List<String> listErrors = new List<String>();
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    listErrors.add(err.getMessage());     
                }
                wr.success = false;
                wr.errorMessage = String.join(listErrors, '; ');
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Record fields that affected these errors -> ' + wr.errorMessage);
            }
            wrapperList.add(wr);
        }  

        return wrapperList;
    }*/


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description populateWrapperResultSuccessDelete – Populate fields of XC_UTIL_Sobject.WrapperResult for SUCCESS (delete)
    * @param srList - List<Database.DeleteResult>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> populateWrapperResultSuccessDelete(List<Database.DeleteResult> srList) {
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();

        for(Database.DeleteResult dr : srList) {
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            if(!dr.isSuccess() || (Test.isRunningTest() && failedInTest)) {
                List<String> listErrors = new List<String>();               
                for(Database.Error err : dr.getErrors()) {
                    listErrors.add(err.getMessage()); 
                }
                wr.success = false;
                wr.errorMessage = String.join(listErrors, '; ');
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Record fields that affected these errors-> ' + wr.errorMessage);
            }
            else {
                wr.recordId = dr.getId();
                wr.success = true;
                // Operation was successful, so get the ID of the record that was processed
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Successfully deleted record-> ' + wr);
            } 
            wrapperList.add(wr);
        } 

        return wrapperList;
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description populateWrapperResultFail – Populate fields of XC_UTIL_Sobject.WrapperResult for FAIL
    * @param e - Exception
    * @return wr - XC_UTIL_Sobject.WrapperResult 
    */ 
    public static XC_UTIL_Sobject.WrapperResult populateWrapperResultFail(Exception e) {
        System.debug('In populateWrapperResultFail');
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.success = false;
        wr.errorMessage = e.getMessage();

        if(e.getTypeName().equals('System.DmlException')) {
            wr.errorObjectId = e.getDmlId(0);
            wr.errorMessage = e.getDmlMessage(0);
            wr.errorfieldName = String.join(e.getDmlFieldNames(0), ';');
        }

        XC_UTIL_ExceptionLog.insertExceptionLog(e);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### Errors ####-> ' + wr.errorMessage);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### ErrorField ####-> ' + wr.errorfieldName);
        return wr;
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description populateWrapperResultEmpty – Populate fields of XC_UTIL_Sobject.WrapperResult for EMPTY
    * @param message - String
    * @return wr - XC_UTIL_Sobject.WrapperResult 
    */ 
    public static XC_UTIL_Sobject.WrapperResult populateWrapperResultEmpty(String message) {
        XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
        wr.success = true;
        wr.errorMessage = message;
        return wr;
    }

}
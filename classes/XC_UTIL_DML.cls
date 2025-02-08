/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 14/03/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_DML – Util class for DMLs
*/
 
public inherited sharing class XC_UTIL_DML {

    //****************************************** CONSTANTS *********************************************
    public final static Boolean DEBUGACTIVE                     = XC_UTIL_Debug.isActive('XC_UTIL_DML');
    private final static String INSERTOP                        = 'insert';
    private final static String UPDATEOP                        = 'update';
    private final static String DELETEOP                        = 'delete';
    @TestVisible private static Boolean throwExceptionInTest    = false;
    //**************************************************************************************************

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description insertRecords – Insert records from List of sObject
    * @param listToInsertToCheck - List<sObject>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> insertRecords(List<sObject> listToInsertToCheck) {
        return insertRecords(listToInsertToCheck, true);  
    }
     /**
    * @author Nicola Arrigo - narrigo@deloitte.it
    * @date Creation 13/03/2020
    * @date Modification dd/mm/yyyy
    * @description insertRecords – Insert records from List of sObject
    * @param listToInsertToCheck - List<sObject>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> insertRecords(List<XC_Customer_Interaction__c> listToInsertToCheck) {
        return insertRecords(listToInsertToCheck, true);  
    }
     
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 20/03/2019
    * @date Modification dd/mm/yyyy
    * @description insertRecords – Insert records from List of sObject with option
    * @param listToInsertToCheck - List<sObject>
    * @param allOrNone - Boolean
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> insertRecords(List<sObject> listToInsertToCheck, Boolean allOrNone) {
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<sObject> listToInsert = checkData(listToInsertToCheck, INSERTOP); 
 
        if(!listToInsert.isEmpty()){
            try { 
                if(Test.isRunningTest() && throwExceptionInTest) {
                    throw new XC_Exception();
                }
                List<Database.SaveResult> srList = Database.insert(listToInsert, allOrNone);
                wrapperList = XC_UTIL_DML_U.populateWrapperResultSuccessInsertUpdateNew(srList, listToInsert);
            } catch(Exception e){
              wrapperList.add(XC_UTIL_DML_U.populateWrapperResultFail(e));
            }
        } else {
            wrapperList.add(XC_UTIL_DML_U.populateWrapperResultEmpty('No record to insert'));
        }
        return wrapperList;  
    }
     /**
    * @author Nicola Arrigo - narrigo@deloitte.com
    * @date Creation 12/03/2020
    * @date Modification dd/mm/yyyy
    * @description insertRecords – Insert records from List of Customer Interaction
    * @param listToInsertToCheck - List<XC_Customer_Interaction__c>
    * @param allOrNone - Boolean
    * @return  List<XC_UTIL_Sobject.WrapperResult>
    */ 
   
    public static List<XC_UTIL_Sobject.WrapperResult>  insertRecords(List<XC_Customer_Interaction__c> listToInsertToCheck, Boolean allOrNone){
        system.debug('@@@@@@@@@@Enter method for Customer Interaction NA');
        // List<string> leList=new list<string>();
         List<string> comTypeList=new List<string>();
         system.debug('size'+' '+listToInsertToCheck.size());
         for(XC_Customer_Interaction__c ci:listToInsertToCheck){
           // s=ci.XC_Communication_Type__c+'_'+ci.XC_LegalEntity__c;
          // leList.add(ci.XC_LegalEntity__c);
          system.debug('CommType'+' '+ci.XC_Communication_Type__c); 
         /* if (ci.XC_Communication_Type__c.length()>40){
                 comTypeList.add(string.valueof(ci.XC_Communication_Type__c).Substring(0,40));
             } else{
                 comTypeList.add(string.valueof(ci.XC_Communication_Type__c));
             }*/
             comTypeList.add(string.valueof(ci.XC_Communication_Type__c)); 
         }
         Map<string,XC_CM_CustomerInteractionActivation__mdt> mapTocheck=mapTocheck(comTypeList);
         List<XC_Customer_Interaction__c> listToBeInsertCheck=new List<XC_Customer_Interaction__c>();
         for(XC_Customer_Interaction__c ci:listToInsertToCheck){
            string le=String.isNotBlank(ci.XC_LegalEntity__c) ? string.valueof(ci.XC_LegalEntity__c) : 'EndesaX';
            string s='XC_'+le+'__c';
             if(mapTocheck.get(ci.XC_Communication_Type__c)!=null && ci.XC_LegalEntity__c!=null){  
                 XC_CM_CustomerInteractionActivation__mdt cm=mapTocheck.containsKey(ci.XC_Communication_Type__c) ? mapTocheck.get(ci.XC_Communication_Type__c) : null;
                 if(cm!= null && cm.get(s)==true && cm.get(s)!=null){ 
                    system.debug('LE Active'+' '+cm.get(s));
                     listToBeInsertCheck.add(ci);
                 } 
              }                 
             }
             system.debug('List CI TO BE INSERT'+' '+listToBeInsertCheck.size());
             List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
             List<sObject> listToInsert = checkData(listToBeInsertCheck, INSERTOP);
             if(!listToInsert.isEmpty()){
                 try { 
                     if(Test.isRunningTest() && throwExceptionInTest) {
                         throw new XC_Exception();
                     }
                     List<Database.SaveResult> srList = Database.insert(listToInsert, allOrNone);
                     wrapperList = XC_UTIL_DML_U.populateWrapperResultSuccessInsertUpdateNew(srList, listToInsert);
                 } catch(Exception e){
                   wrapperList.add(XC_UTIL_DML_U.populateWrapperResultFail(e));
                 }
             } else {
                 wrapperList.add(XC_UTIL_DML_U.populateWrapperResultEmpty('No record to insert'));
             }
             return wrapperList;  
         }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description updateRecords – Update records from List of sObject
    * @param listToUpdateToCheck - List<sObject>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> updateRecords(List<sObject> listToUpdateToCheck) { 
        return updateRecords(listToUpdateToCheck, true);  
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 20/03/2019
    * @date Modification dd/mm/yyyy
    * @description updateRecords – Update records from List of sObject with option
    * @param listToUpdateToCheck - List<sObject>
    * @param allOrNone - Boolean
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> updateRecords(List<sObject> listToUpdateToCheck, Boolean allOrNone) { 
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        List<sObject> listToUpdate = checkData(listToUpdateToCheck, UPDATEOP);

        if(!listToUpdate.isEmpty()){
            try{
                if(Test.isRunningTest() && throwExceptionInTest) {
                    throw new XC_Exception();
                }
                Id sobjectId = listToUpdateToCheck[0].Id;
                Schema.SObjectType token = sobjectId.getSObjectType();
                /*if(!token.getDescribe().isUpdateable()) {
                    XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
                    wr.success = false;
                    wr.errorMessage = 'You cannot update record for this object.';
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error for UPDATE ---> ' + wr);
                    wrapperList.add(wr);
                    return wrapperList;
                }*/
                List<Database.SaveResult> srList = Database.update(listToUpdate, allOrNone);
                wrapperList = XC_UTIL_DML_U.populateWrapperResultSuccessInsertUpdateNew(srList, listToUpdate);
            } catch(Exception e){
               wrapperList.add(XC_UTIL_DML_U.populateWrapperResultFail(e));
            }
        } else {
            wrapperList.add(XC_UTIL_DML_U.populateWrapperResultEmpty('No record to update'));
        }
        return wrapperList;  
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description deleteRecords – Delete records from List of sObject
    * @param listToDeleteToCheck - List<sObject>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */ 
    public static List<XC_UTIL_Sobject.WrapperResult> deleteRecords(List<sObject> listToDeleteToCheck){
        return deleteRecords(listToDeleteToCheck, true);
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 20/03/2019
    * @date Modification dd/mm/yyyy
    * @description deleteRecords – Delete records from List of sObject with option
    * @param listToDeleteToCheck - List<sObject>
    * @param allOrNone - Boolean
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> deleteRecords(List<sObject> listToDeleteToCheck, Boolean allOrNone){
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        List<sObject> listToDelete = checkData(listToDeleteToCheck, DELETEOP);

        if(!listToDelete.isEmpty()){
            try{
                if(Test.isRunningTest() && throwExceptionInTest) {
                    throw new XC_Exception();
                }
                Id sobjectId = listToDeleteToCheck[0].Id;
                Schema.SObjectType token = sobjectId.getSObjectType();
                /*if(!token.getDescribe().isDeletable()) {
                    XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
                    wr.success = false;
                    wr.errorMessage = 'You cannot delete record for this object.';
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error for DELETE ---> ' + wr);
                    wrapperList.add(wr);
                    return wrapperList;
                }*/
                List<Database.DeleteResult> drList = Database.delete(listToDelete, allOrNone);
                wrapperList = XC_UTIL_DML_U.populateWrapperResultSuccessDelete(drList);
            } catch(Exception e){
                wrapperList.add(XC_UTIL_DML_U.populateWrapperResultFail(e));
            } 
        } else {
            wrapperList.add(XC_UTIL_DML_U.populateWrapperResultEmpty('No record to delete'));
        }
        return wrapperList;
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/03/2019
    * @date Modification dd/mm/yyyy
    * @description deleteRecords – Upsert records from List of sObject
    * @param listToUpsert - List<sObject>
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */
    public static List<XC_UTIL_Sobject.WrapperResult> upsertRecords(List<sObject> listToUpsert) {

        List<XC_UTIL_Sobject.WrapperResult> listWr = new List<XC_UTIL_Sobject.WrapperResult>();
        List<sObject> listToUpdate = new List<sObject>();
        List<sObject> listToInsert = new List<sObject>();
        for(sObject o : listToUpsert) {
            if(String.isBlank(o.Id)) {
                listToInsert.add(o);
            } else {
                listToUpdate.add(o);
            }
        }
        if(!listToInsert.isEmpty()) {
            listWr.addAll(insertRecords(listToInsert, true));
        }
        if(!listToUpdate.isEmpty()) {
            listWr.addAll(updateRecords(listToUpdate, true));
        }
        return listWr;
    }


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 20/03/2019
    * @date Modification dd/mm/yyyy
    * @description deleteRecords – Upsert records from List of sObject with option
    * @param listToUpsert - List<sObject>
    * @param allOrNone - Boolean
    * @return wrapperList - List<XC_UTIL_Sobject.WrapperResult>
    */
    /*public static List<XC_UTIL_Sobject.WrapperResult> upsertRecords(List<sObject> listToUpsert, Boolean allOrNone) {
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>();
        if(!listToUpsert.isEmpty()){
            try{                
                List<Database.UpsertResult> srList = Database.upsert(listToUpsert, allOrNone);
                wrapperList = XC_UTIL_DML_U.populateWrapperResultSuccessUpsert(srList);
            } catch(Exception e){
                wrapperList.add(XC_UTIL_DML_U.populateWrapperResultFail(e));
            }
        } else {
            wrapperList.add(XC_UTIL_DML_U.populateWrapperResultEmpty('No record to upsert.'));
        }
        return wrapperList;  
    }*/ 


    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 14/03/2019
    * @date Modification dd/mm/yyyy
    * @description checkData – Get List of object to insert/update/delete
    * @param listToUpdateToCheck - List<sObject>
    * @param typeDML - String
    * @return listOK - List<sObject>
    */ 
    private static List<sObject> checkData(List<sObject> listToUpdateToCheck, String typeDML) {
        List<sObject> listOK = new List<sObject>();
        for(sObject sobjectToCheck : listToUpdateToCheck) {
            if(sobjectToCheck!= null) {
                if((typeDML.equals('update') || typeDML.equals('delete')) && sobjectToCheck.get('Id') != null) {
                    listOK.add(sobjectToCheck);
                } else if(typeDML.equals('insert') && sobjectToCheck.get('Id') == null) {
                    listOK.add(sobjectToCheck);
                }
            }
        }
        return listOK;
    }
    
     
    /**
    * @author Nicola Arrigo - narrigo@deloitte.com
    * @date Creation 12/03/2020
    * @date Modification dd/mm/yyyy
    * @description mapTocheck
    * @param comTypeList - List<string>
    * @return Map<string,XC_CM_CustomerInteractionActivation__mdt>
    */ 
     
    public static Map<string,XC_CM_CustomerInteractionActivation__mdt> mapTocheck(List<string> comTypeList){
          list<XC_CM_CustomerInteractionActivation__mdt> cmList=new list<XC_CM_CustomerInteractionActivation__mdt>();
          Map<string,XC_CM_CustomerInteractionActivation__mdt> mapTocheck=new Map<string,XC_CM_CustomerInteractionActivation__mdt>(); 
         /* if(Schema.sObjectType.XC_CM_CustomerInteractionActivation__mdt.isaccesible()){
            cmList=[select Id, DeveloperName,XC_Codensa__c, XC_EndesaX__c, XC_EnelDistributionChile__c, XC_EnelXChile__c, XC_EnelXItalia__c, XC_EnelXNorthAmericaInc__c, XC_EnelXRomania__c, XC_JuicenetLimited__c 
                 from XC_CM_CustomerInteractionActivation__mdt
                 where DeveloperName IN:comTypeList];  
          }*/
          if(Schema.sObjectType.XC_CM_CustomerInteractionActivation__mdt.isaccessible()){
            String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('XC_CM_CustomerInteractionActivation__mdt');
            query += ' FROM XC_CM_CustomerInteractionActivation__mdt ';
           	query += ' WHERE XC_CommunicationType__c IN:comTypeList';
            cmList = Database.query(query);
              System.debug('cmList' + cmList);
            /*cmList=[select Id,XC_CommunicationType__c, DeveloperName,XC_Codensa__c, XC_EndesaX__c, XC_EnelDistribution__c, XC_EnelX__c, XC_EnelXItalia__c, XC_EnelXNorthAmericaInc__c, XC_EnelXRomania__c, XC_JuicenetLimited__c 
            from XC_CM_CustomerInteractionActivation__mdt
             where XC_CommunicationType__c IN:comTypeList];  */
          }
          
           for(XC_CM_CustomerInteractionActivation__mdt cm:cmList){
            mapTocheck.put(cm.XC_CommunicationType__c,cm);    
           }
           return mapTocheck;        
      }
}
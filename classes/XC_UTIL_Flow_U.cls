/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 04/12/2020
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Flow - Util class for Flow methods
*/ 

public class XC_UTIL_Flow_U {
     public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Flow_U'); 
     /**
     * @description InputWrapper for Flow
     */
     public class InputWrapper{ 
          @Invocablevariable
          public String operationRecordToExecuteId;
          @Invocablevariable
          public String operationRecordsToEnqueueId;
     }

    /**
     * @author: Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to be used by Process Builder to launch flows after Platform Event reception
     * @param inputWrapperList Wrapper of parameters
    */
     @InvocableMethod 
     public static void executeFlowAndEnqueueSteps(List<InputWrapper> inputWrapperList){ 
          System.debug('inputWrapperList->' + inputWrapperList);  
          List<String> allOperationRecordIdList = new List<String>();
          for(InputWrapper wr : inputWrapperList){
               System.debug('operationRecordToExecuteId->' + wr.operationRecordToExecuteId);
               System.debug('operationRecordsToEnqueueId->' + wr.operationRecordsToEnqueueId);
               allOperationRecordIdList.add(wr.operationRecordToExecuteId); 
               if(!String.isBlank(wr.operationRecordsToEnqueueId)){
                    allOperationRecordIdList.addAll(wr.operationRecordsToEnqueueId.split(';;')); 
               } 
          }
          System.debug('allOperationRecordIdList->' + allOperationRecordIdList); 
          for(Integer i = 0; i<allOperationRecordIdList.size(); i++){
               if(String.isEmpty(allOperationRecordIdList[i])){
                    allOperationRecordIdList.remove(i);
               }
          }
          if(!allOperationRecordIdList.isEmpty()){
               String operationRecordId = allOperationRecordIdList[0];
               Integer index = operationRecordId.indexOf('#-#');
               String operation = operationRecordId.left(index);
               String recordId = operationRecordId.mid(index+3, 18);

               switch on operation {
                    when 'launchConga' {
                         NE__OrderItem__c oiToUpdate = new NE__OrderItem__c( Id = recordId, XC_StartCongaProcess__c = true);
                         XC_UTIL_Sobject.updateRecord(oiToUpdate);
                    }
                    when 'launchProvisioning' {
                         XC_UTIL_NextStepOrderToProvisioning.firstNextStep(recordId);
                    }
               }

               allOperationRecordIdList.remove(0);
               if(!allOperationRecordIdList.isEmpty()){  
                    insertGenericEvent(allOperationRecordIdList);
               }
          }
     }

     /**
     * @author: Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to be launch other events when needed
     * @param allOperationRecordIdList list of operation-recordIds
    */
     private static void insertGenericEvent(List<String> allOperationRecordIdList) {
          if(!allOperationRecordIdList.isEmpty()){
               String operationRecordId = allOperationRecordIdList[0];
               allOperationRecordIdList.remove(0);
               String operationIdListString = String.join(allOperationRecordIdList, ';;');
               if(!String.isBlank(operationRecordId)){ 
                    XC_UtilEvent__e event = new XC_UtilEvent__e();
                    event.XC_OperationRecordId__c = operationRecordId;
                    event.XC_OperationRecordIdList__c = operationIdListString;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'event->' + event);
                    XC_UTIL_PlatformEvent.publishListEvent(event);
               }
          }
     } 
}
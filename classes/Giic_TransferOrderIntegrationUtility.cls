/**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_TransferOrderIntegrationUtility - Transfer order receipt utility for integration
*/  
public without sharing class Giic_TransferOrderIntegrationUtility {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_TransferOrderIntegrationUtility');
    public static boolean isExecuteClearBackOrder=true;
    /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOGoodsReceipt – This method calls the glovia api for TO receipt
*@param toReceiptRequestWrapper-Giic_IntegrationWrapper.TOReceipt
*@return Giic_IntegrationWrapper.TOReceiptResponse
*/   
    public static Giic_IntegrationWrapper.TOReceiptResponse tOGoodsReceipt(Giic_IntegrationWrapper.TOReceipt toReceiptRequestWrapper){
        Map<String,Id> mapTOLidsVsLocId = new Map<String, Id>();
        List<string> lstErrorsTmp= new List<String>();
        list<giic_ErrorLog__c> lstErrorLogs=new list<giic_ErrorLog__c>();
        List<Giic_IntegrationWrapper.ErrorList> errlist = new List<Giic_IntegrationWrapper.ErrorList>();
        Set<Id> polId= new Set<Id>();
        gii.TransferOrderReceipt.TransferOrderReceiptsResult result;
        Giic_IntegrationWrapper.TOReceiptResponse responseTOReceipt = new Giic_IntegrationWrapper.TOReceiptResponse();
        Map<Id,Id> mapReceiptQueueLocation = new Map<ID, Id>();
        List<Giic_IntegrationWrapper.errorList> errorList = new List<Giic_IntegrationWrapper.errorList>();
        
        for(Giic_IntegrationWrapper.TOReceipetLine tolObj: toReceiptRequestWrapper.toReceiptLine){
            if(tolObj.location != null){
                mapTOLidsVsLocId.put(tolObj.tOLineID,tolObj.location);
            }
            polId.add(tolObj.tOLineID);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapTOLidsVsLocId-------'+mapTOLidsVsLocId);
        mapReceiptQueueLocation = createReceiptMap(toReceiptRequestWrapper,mapTOLidsVsLocId,polId);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapReceiptQueueLocation-------'+mapReceiptQueueLocation);
        
        if(mapReceiptQueueLocation != null && !mapReceiptQueueLocation.values().isEmpty()){
            XC_UTIL_Debug.debug(DEBUGACTIVE,'callReceiptCreationGloviaAPI-------');
            result = callReceiptCreationGloviaAPI(mapReceiptQueueLocation,toReceiptRequestWrapper);
        }
        else{
           XC_UTIL_Debug.debug(DEBUGACTIVE,'else-------');
            Giic_IntegrationWrapper.ErrorList err = new Giic_IntegrationWrapper.ErrorList();
            String error=System.Label.giic_TOIntegrationError;
            err.errorMsg = error;
            errlist.add(err);
        }
        
        // Exception Handling
        responseTOReceipt = handleExceptions(result,errlist,errorList);
        createErrorLogRecords(responseTOReceipt,toReceiptRequestWrapper);
        if(result!=null && result.listReceipt!=null && !result.listReceipt.isEmpty()){
            updateReceiptStatus(result,responseTOReceipt);   
        }
        return responseTOReceipt;
    }
  /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOGoodsReceipt – This method calls the glovia api for TO receipt
*@param toReceiptRequestWrapper-Giic_IntegrationWrapper.TOReceipt
*@param toReceiptRequestWrapper- Giic_IntegrationWrapper.TOReceipt 
*/      
    public static void createErrorLogRecords(Giic_IntegrationWrapper.TOReceiptResponse responseTOReceipt,Giic_IntegrationWrapper.TOReceipt toReceiptRequestWrapper){
        List<string> lstErrorsTmp= new List<String>();
        list<giic_ErrorLog__c> lstErrorLogs=new list<giic_ErrorLog__c>();
        if(responseTOReceipt!=null && responseTOReceipt.errorList != null && !responseTOReceipt.errorList.isEmpty()){
            for(Giic_IntegrationWrapper.ErrorList objError:responseTOReceipt.errorList){
                String error=objError.errorMsg;
                lstErrorsTmp.add(error);
            }
            lstErrorLogs.addall(Giic_ErrorLogsUtility.collectErrors(new Giic_ErrorLogsUtility.ErrorLogsWrapper('Transfer Order Receipt',new map<string,object>{'giic_TransferOrder__c'=> toReceiptRequestWrapper.transferOrderID},
                                                                                                               'Transfer Order Receipt Creation',string.join(lstErrorsTmp,'\'n\''))));
            Giic_ErrorLogsUtility.insertErrorLogs(lstErrorLogs);
        }
    }
  /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOGoodsReceipt – This method calls the glovia api for TO receipt
*@param result gii.TransferOrderReceipt.TransferOrderReceiptsResult 
*@param  errlist List<Giic_IntegrationWrapper.ErrorList> 
*@param errorList List<Giic_IntegrationWrapper.errorList> 
*@return Giic_IntegrationWrapper.TOReceiptResponse
*/    
    public static Giic_IntegrationWrapper.TOReceiptResponse handleExceptions(gii.TransferOrderReceipt.TransferOrderReceiptsResult result,
                                                                             List<Giic_IntegrationWrapper.ErrorList> errlist,List<Giic_IntegrationWrapper.errorList> errorList){
        Giic_IntegrationWrapper.TOReceiptResponse responseTOReceipt = new Giic_IntegrationWrapper.TOReceiptResponse();
        if (result != null && result.Exceptions != null && !result.Exceptions.isEmpty()) {
            List<String> errorMsgList = new List<String>();
            for(gii.TransferOrderReceipt.GOMException e : result.Exceptions) {
                Giic_IntegrationWrapper.errorList err = new Giic_IntegrationWrapper.errorList();
                err.errorMsg = e.getMessage();
                errorMsgList.add(e.getMessage()); 
                errorList.add(err);
            }
            if(errorList.size()>0){
                responseTOReceipt.isSuccess = false;
                responseTOReceipt.errorList = errorList;
                XC_UTIL_Debug.debug(DEBUGACTIVE,errorList);
                return null;
            }
            responseTOReceipt.errorList.addAll(errlist);
        }else{
            if(errlist != null && !errlist.isEmpty()){
                responseTOReceipt.errorList = errlist;
                responseTOReceipt.isSuccess = false;
            }else{
                responseTOReceipt.isSuccess = true;
            }
        }
        return responseTOReceipt;
    }
    /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOGoodsReceipt – This method calls the glovia api for TO receipt
*@param  toReceiptRequestWrapper Giic_IntegrationWrapper.TOReceipt 
*@param mapTOLidsVsLocId Map<String,Id> 
*@param polId Set<Id> 
*@return Map<Id,Id>
*/   
    public static Map<Id,Id> createReceiptMap(Giic_IntegrationWrapper.TOReceipt toReceiptRequestWrapper,Map<String,Id> mapTOLidsVsLocId, Set<Id> polId){
        Map<Id,Id> mapReceiptQueueLocation = new Map<ID, Id>();
        // Build map ReceiptQueue Id and Location id for transfer order receipt queues
        for (gii__ReceiptQueue__c receiptQueue : [Select Name, Id, gii__SalesOrderLine__r.gii__Status__c, gii__SalesOrder__c,gii__TransferOrder__c,
                                                  gii__InTransitWarehouse__r.gii__DefaultIssueLocation__c,gii__TransferOrderLine__c, gii__ShippedDate__c From gii__ReceiptQueue__c 
                                                  Where gii__TransferOrderLine__c =: polId AND gii__TransferOrderLine__r.gii__LineStatus__c != 'Received']) 
        {
            if(ReceiptQueue.gii__TransferOrder__c != null){
                if(mapTOLidsVsLocId.containsKey(receiptQueue.gii__TransferOrderLine__c)){
                    mapReceiptQueueLocation.put(receiptQueue.id, mapTOLidsVsLocId.get(receiptQueue.gii__TransferOrderLine__c));
                }else{
                    mapReceiptQueueLocation.put(receiptQueue.id, receiptQueue.gii__InTransitWarehouse__r.gii__DefaultIssueLocation__c);
                }
            }               
        }
        return mapReceiptQueueLocation;
    } 
    /**
* @author FirstName : Rishabh Bansal 
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOGoodsReceipt – This method calls the glovia api for TO receipt
*@param mapReceiptQueueLocation Map<Id,Id>  
*@param toReceiptRequestWrapper Giic_IntegrationWrapper.TOReceipt  
*@return gii.TransferOrderReceipt.TransferOrderReceiptsResult
*/   
    public static gii.TransferOrderReceipt.TransferOrderReceiptsResult callReceiptCreationGloviaAPI(Map<Id,Id> mapReceiptQueueLocation,Giic_IntegrationWrapper.TOReceipt toReceiptRequestWrapper){
        isExecuteClearBackOrder=false;
        // input object for receipt creation
        gii.TransferOrderReceipt.ReceiptCreationInput inputObj = new gii.TransferOrderReceipt.ReceiptCreationInput();
        // assign map of receipt queue id and location id
        inputObj.mapReceiptQueueLocation = mapReceiptQueueLocation;
        inputObj.ReceiptDate = toReceiptRequestWrapper.receiptDate;  //assign receipt date
        // output object for receipt creation
        gii.TransferOrderReceipt.TransferOrderReceiptsResult result = new gii.TransferOrderReceipt.TransferOrderReceiptsResult();
        // call the method to process the receipt queues
        result = gii.TransferOrderReceipt.getReceiptsforReceiptQueues(inputObj);
        // debug to print the result
        XC_UTIL_Debug.debug(DEBUGACTIVE,result);
        return result;
    }
    /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOGoodsReceipt – This method calls the glovia api for TO receipt
*@param result gii.TransferOrderReceipt.TransferOrderReceiptsResult  
*@param responseTOReceipt Giic_IntegrationWrapper.TOReceiptResponse  
*/   
    public static void updateReceiptStatus(gii.TransferOrderReceipt.TransferOrderReceiptsResult result,Giic_IntegrationWrapper.TOReceiptResponse responseTOReceipt){
        Map<Id,gii__Receipt__c> receiptMap;
        if(result != null && result.listReceipt != null && !result.listReceipt.isEmpty() && Schema.sObjectType.gii__Receipt__c.isQueryable()){
            receiptMap = new Map<Id,gii__Receipt__c>([SELECT Id,giic_IntegrationStatus__c FROM gii__Receipt__c WHERE ID IN: result.listReceipt]);
            for(gii__Receipt__c rcpt : receiptMap.values()){
                receiptMap.get(rcpt.Id).giic_IntegrationStatus__c = responseTOReceipt.isSuccess == true ? Label.giic_IntegrationStatusSuccess : Label.giic_IntegrationStatusFailure;            
                receiptMap.get(rcpt.Id).giic_IntegrationOperation__c=System.Label.giic_IntegrationOperationCreate;
                receiptMap.get(rcpt.Id).giic_TargetSystem__c='Glovia';
            }
            
            Giic_ReceiptUtility.clearBackOrderQtyOnPI(receiptMap.values());
            if(Schema.sObjectType.gii__Receipt__c.isUpdateable()){
                update receiptMap.values();    
            }
        }
    }
}
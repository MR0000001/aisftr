/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 22/10/2018
* @Modification : Pietro D Auria  - 22-11-2018
* @description XC_UTIL_IntegrationLog – Implementation of IntegrationLog class
*/

public without sharing class XC_UTIL_IntegrationLog {
      
	private XC_Integration_Log__c intLog;

	/** @description LogWrapper */
	public class LogWrapper {
		public String logTransactionID;
		public String logIntegrationName;
		public String logEndpoint;
		public String httpMethod;
		public String logMessage;
		public Boolean logIsSuccess;
		public Boolean insertLogging;
		public String accountDNI;
		public String accountID;
		public String orderID;
		public String workOrderID;
		public String productCode;
		public String clientSystem;
		public String serverSystem;
	}

	/** @description Costructor **/	     
	public XC_UTIL_IntegrationLog() {
		intLog = new XC_Integration_Log__c();
	}

	/**
	* @description Set TransictionID
	* @param logTransactionID
	**/	
	public void setTransactionID(String logTransactionID) {
		intLog.XC_Log_TransactionId__c = logTransactionID;
	} 

	/**
	* @description Set Http
	* @param httpMethod
	**/	
	public void setHttpMethod(String httpMethod) {
		intLog.XC_Log_HTTP_Method__c	= httpMethod;
	}

	
	/**
	* @description Set Header
	* @param header
	**/	
	public void setHeader(Map<String,String> headerMap) {

		String xSalesforceForwardedTo = headerMap.remove('X-Salesforce-Forwarded-To');
		String xSalesforceSIP = headerMap.remove('X-Salesforce-SIP');
		String xSalesforceVIP = headerMap.remove('X-Salesforce-VIP');
		String xPrettyPrint = headerMap.remove('X-PrettyPrint');
		String cacheControl = headerMap.remove('Cache-Control');
		String cipherSuite = headerMap.remove('CipherSuite');
		String connection = headerMap.remove('Connection');
		String userAgent = headerMap.remove('User-Agent');
		String accept = headerMap.remove('Accept');
		String host = headerMap.remove('Host');

		Integer headerLength = Schema.SObjectType.XC_Integration_Log__c.fields.XC_Log_Header__c.getLength();
		intLog.XC_Log_Header__c	= (JSON.Serialize(headerMap).length()>headerLength) ? JSON.Serialize(headerMap).substring(0, headerLength): JSON.Serialize(headerMap);
		intLog.XC_Log_ClientSystem__c = headerMap.get('ClientSystem');
		intLog.XC_Log_ServerSystem__c = headerMap.get('ServerSystem');
	}

	/**
	* @description Set Additional Informations
	* @param logWrapper
	**/	
	public void setAdditionalInformations(LogWrapper logWrapper) {
		intLog.XC_Log_AccountDNI__c	= logWrapper.accountDNI;
		intLog.XC_Log_AccountID__c = logWrapper.accountID;
		intLog.XC_Log_OrderID__c = logWrapper.orderID;
		intLog.XC_Log_WorkOrderID__c = logWrapper.workOrderID;
		intLog.XC_Log_ProductCode__c = logWrapper.productCode;
	}

	/**
	* @author Pietro D'Auria- pietro.dauria@nttdata.com
	* @description : Insert a IntegrationLog for Request of Inbound Service
	* @modification : Pietro D Auria  - 22-11-2018
	* @param logIntegrationName
	* @param logMessage
	**/	
	public void insertIntegReqInboundLog(String logIntegrationName, String logMessage) {
		intLog.XC_Log_TimestampReq__c	= datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
		intLog.XC_Log_Status__c         = '';
		intLog.XC_Log_EndPoint__c       = '';
		intLog.XC_Log_IsSuccess__c      = false;
		intLog.XC_Log_IntegrationName__c= logIntegrationName;
		intLog.XC_Log_IntegrationType__c= 'Inbound';
		intLog.XC_Log_Request__c        = logMessage;
	}

	/**
	* @description added queued request integration log management
	* @author Francesco Imperioli - fimperioli@deloitte.it | 16/6/2020 
	* @param logIntegrationName 
	* @param logMessage 
	* @param asyncQueuedRequestId 
	* @return void 
	**/
	public void insertIntegReqInboundLog(String logIntegrationName, String logMessage, String asyncQueuedRequestId){
		insertIntegReqInboundLog(logIntegrationName,logMessage);
		intLog.XC_QueuedRequest__c = asyncQueuedRequestId;
	}

	/**
	* @author Monica Cutillo - mcutillo@deloitte.it
	* @description : Insert a IntegrationLog for Response of Inbound Service
	* @param logStatus
	* @param logIsSuccess
	* @param logMessage
	* @param logError
	**/			
	public void insertIntegRespInboundLog(String logStatus, Boolean logIsSuccess, String logMessage, String logError) {
		
		List<XC_Integration_Log__c> integrationLogList = getIntegRespInboundLog(logStatus, logIsSuccess, logMessage, logError);
		
		List<XC_UTIL_Sobject.WrapperResult> wrapListResult= XC_UTIL_Sobject.insertListRecords(integrationLogList);
        
        for (XC_UTIL_Sobject.WrapperResult w : wrapListResult){
            if(!w.success){
                system.debug('log not inserted: '+w.errorMessage);
            } else {
                system.debug('log inserted: '+w.recordId);
            }
        }
	}

	/**
	* @author Pietro D'Auria- pietro.dauria@nttdata.com
	* @description : Get an IntegrationLog for Response of Inbound Service
	* @modification : Pietro D Auria  - 22-11-2018
	* @modification : Monica Cutillo  - 03-03-2020
	* @param logStatus
	* @param logIsSuccess
	* @param logMessage
	* @param logError
	* @return List<XC_Integration_Log__c> to insert
	**/			
	public List<XC_Integration_Log__c> getIntegRespInboundLog(String logStatus, Boolean logIsSuccess, String logMessage, String logError) {

		Integer responseLength = Schema.SObjectType.XC_Integration_Log__c.fields.XC_Log_Response__c.getLength();

		intLog.XC_Log_TimestampResp__c	= datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
		intLog.XC_Log_Status__c			= logStatus;
		intLog.XC_Log_IsSuccess__c		= logIsSuccess;
		intLog.XC_Log_Error__c			= logError;
		intLog.XC_Log_Response__c 		= (logMessage.length()>responseLength) ? logMessage.substring(0, responseLength) : logMessage;

		List<XC_Integration_Log__c> integrationLogList	= new List<XC_Integration_Log__c>();
		integrationLogList.add(intLog);
		return integrationLogList;
		/*List<XC_UTIL_Sobject.WrapperResult> wrapListResult= XC_UTIL_Sobject.insertListRecords(integrationLogList);
        
        for (XC_UTIL_Sobject.WrapperResult w : wrapListResult){
            if(!w.success){
                system.debug('log not inserted: '+w.errorMessage);
            } else {
                system.debug('log inserted: '+w.recordId);
            }
        }*/
	}

	/**
	* @author Federico Amici - federico.amici@nttdata.com
	* @description : Insert a IntegrationLog for Request of Outbound Service using wrapper
	* @param logWrapper
	**/	 
	public void insertIntegReqOutboundLog(LogWrapper logWrapper) {
		intLog.XC_Log_TimestampReq__c	= datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
		intLog.XC_Log_IntegrationName__c= logWrapper.logIntegrationName;

		if(logWrapper.httpMethod=='GET' && String.isNotBlank(logWrapper.logEndpoint)){
            List<String> data = logWrapper.logEndpoint.Split('\\?');
            if(data.size()>=1){
				intLog.XC_Log_EndPoint__c = (logWrapper.logEndpoint.Split('\\?'))[0];
            }
            if(data.size()>=2){
				intLog.XC_Log_Request__c = (logWrapper.logEndpoint.Split('\\?'))[1];
            }
		} else{	
			intLog.XC_Log_EndPoint__c		= logWrapper.logEndpoint;
			intLog.XC_Log_Request__c		= logWrapper.logMessage;//.substring(0, 131071);
		}
		intLog.XC_Log_TransactionId__c = logWrapper.logTransactionID;
		intLog.XC_Log_IntegrationType__c= 'Outbound';
		intLog.XC_Log_Status__c			= '';
		intLog.XC_Log_IsSuccess__c		= false;
		intLog.XC_Log_HTTP_Method__c    = logWrapper.httpMethod;

		intLog.XC_Log_ClientSystem__c = logWrapper.clientSystem;
		intLog.XC_Log_ServerSystem__c = logWrapper.serverSystem;

		setAdditionalInformations(logWrapper);
    }
       
	/**
	* @author Pietro D'Auria- pietro.dauria@nttdata.com
	* @description : Insert a IntegrationLog for Response of Outbound Service
	* @modification : Pietro D Auria  - 22-11-2018
	* @param logIsSuccess
	* @param logMessage
	* @param logStatus
	* @param logError
	**/
	public void insertIntegRespOutboundLog(Boolean logIsSuccess, String logMessage, String logStatus, String logError) {
		intLog.XC_Log_TimestampResp__c	= datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
		intLog.XC_Log_Status__c         = logStatus;
		intLog.XC_Log_IsSuccess__c      = logIsSuccess;
		intLog.XC_Log_Response__c       = logMessage;
		intLog.XC_Log_Error__c			= logError;

		List<XC_Integration_Log__c> integrationLogList = new List<XC_Integration_Log__c>();
		integrationLogList.add(intLog);
		List<XC_UTIL_Sobject.WrapperResult> wrapListResult= XC_UTIL_Sobject.insertListRecords(integrationLogList);
	}
       
	/**
	* @author Monica Cutillo - mcutillo@deloitte.it
	* @description : Insert a IntegrationLog for Response of Outbound Service
	* @modification : Pietro D Auria  - 22-11-2018
	* @param logIsSuccess
	* @param logMessage
	* @param logStatus
	* @param logError
	**/
	public List<XC_Integration_Log__c> getIntegRespOutboundLog(Boolean logIsSuccess, String logMessage, String logStatus, String logError) {
		intLog.XC_Log_TimestampResp__c	= datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
		intLog.XC_Log_Status__c         = logStatus;
		intLog.XC_Log_IsSuccess__c      = logIsSuccess;
		intLog.XC_Log_Response__c       = logMessage;
		intLog.XC_Log_Error__c			= logError;

		List<XC_Integration_Log__c> integrationLogList = new List<XC_Integration_Log__c>();
		integrationLogList.add(intLog);
		return integrationLogList;
	}

	/**
	* @author Marina Ciavarra - mciavarra@deloitte.it
	* @description : Get an IntegrationLog for Response of Inbound Service
	* @modification : 
	* @param logStatus
	* @param logIsSuccess
	* @param logMessage
	* @param logError
	**/
	public static void insertGenerateWorkOrderLog(String result, String recordId, String label) {
        
		XC_Integration_Log__c integrationLogsToInsert = new XC_Integration_Log__c();
        if(result.length() > 131000 ) {
			String subStr = result.subString(0, 131000);
			integrationLogsToInsert.XC_Log_Response__c = subStr.subString(0, subStr.lastIndexOf(' ')) + '...';
		} else {
			integrationLogsToInsert.XC_Log_Response__c = result;
		}
		integrationLogsToInsert.XC_Log_IntegrationName__c = label;
		integrationLogsToInsert.XC_Log_OrderID__c = recordId;
		integrationLogsToInsert.XC_Log_TimestampResp__c	= datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
		
		String valueInsertDML = (XC_CS_UtilityGlobalValues__c.getInstance('InsertLogsGenerateWO') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('InsertLogsGenerateWO').Value__c : 'false';
        String valueInsertDMLOK = (XC_CS_UtilityGlobalValues__c.getInstance('InsertLogsGenerateWO_OK') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('InsertLogsGenerateWO_OK').Value__c : 'false';
        if(valueInsertDML == 'true' && String.isNotBlank(integrationLogsToInsert.XC_Log_Response__c)) {
            if(valueInsertDMLOK == 'true') {
				XC_UTIL_Sobject.insertRecord(integrationLogsToInsert);
			} else if(integrationLogsToInsert.XC_Log_Response__c.startsWithIgnoreCase('Generic Error')) {
				XC_UTIL_Sobject.insertRecord(integrationLogsToInsert);
			}
        }
	}

}
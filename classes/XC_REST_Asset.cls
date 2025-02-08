/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com - Simone Trenta - strenta@deloitte.it
* @date Creation 18/12/2018 
* @description REST INTERFACE : ASSET Object
*/
@RestResource(urlMapping='/v1/Asset/*') 
global with sharing class XC_REST_Asset {
    
    private class WrapperCheckResInsert {
        public List<XC_UTIL_Sobject.WrapperResult> resInsertAsset;
        public XC_UTIL_IntegrationLog intLog; 
        public String msgResponse;
        public Map<Id, Asset> mapIAsset;
    }

    /**
     * @description Do get.
     */
    @HttpGet
    global static void doGet() {
        
        String requestURL = ''; 
        String msgResponse = '';
        String logError = ''; 
        
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        
        XC_REST_Asset_U.WrapperListAssetResponse wrResp = new XC_REST_Asset_U.WrapperListAssetResponse();
        
        Map<String, String> mapHeader = request.headers;
        
        try{
            intLog.insertIntegReqInboundLog('Asset', JSON.serialize(RestContext.request.params));
            intLog.setHeader(mapHeader); 
            intLog.setHttpMethod(request.httpMethod);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            
            XC_UTIL_Integration.WrapperResult resultWrapper = XC_UTIL_RESTInbound.checkObjectPermission('Asset', 'read');
            if(resultWrapper.errorFlag){
                wrResp.Result.Message = resultWrapper.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            }            
            
            resultWrapper = XC_REST_Asset_U.checkReadParams(request.params, mapHeader);
            if(resultWrapper.errorFlag) {
                wrResp.Result.Message = 'ERROR. ' + resultWrapper.errorMessage;
                wrResp.Result.ErrorCode = '400';
                return;

            } else {
                
                List<Asset> listAsset = XC_REST_Asset_U.readAsset(request.params);
                if(listAsset.size() > 0) {
                    wrResp.Result.Message = 'Operation completed successfully';
                    wrResp.Result.ErrorCode = '0';
                    wrResp.asset = XC_REST_Asset_U.createWrapperAsset(listAsset, mapHeader.get('ClientSystem'));

                } else {
                    wrResp.Result.Message = Label.XC_CL_AssetNotFound;
                    wrResp.Result.ErrorCode = '400';
                    //wrResp.Asset = new List<XC_UTIL_Asset.AssetRESTWrapper>();
                }
            }
        } catch(Exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
            
            //wrResp.Result.Message = 'err. '+logError; //debug
            
        } finally {
            msgResponse =  JSON.serialize(wrResp, true);
            msgResponse = msgResponse.replace('Currency_r','Currency');
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);  
        
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0') {
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper); 
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }  
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;  
        } 
    }
    
    
    /**
     * @description Do post.
     */
    @HttpPost
    global static void doPost() {
        
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Asset_U.WrapperAssetResponse wrResp = new XC_REST_Asset_U.WrapperAssetResponse();
        
        Map<String, String> mapHeader = request.headers;
        
        try{
            
            msgRequest = request.requestbody.tostring();
            msgRequest = msgRequest.replace('"Currency"','"currency_r"');
            XC_REST_Asset_U.WrapperAssetRequest wrReq = (XC_REST_Asset_U.WrapperAssetRequest) JSON.deserialize(msgRequest,XC_REST_Asset_U.WrapperAssetRequest.class);
            intLog.insertIntegReqInboundLog('Asset', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            XC_UTIL_Integration.WrapperResult checkResult = XC_UTIL_RESTInbound.checkObjectPermission('Asset', 'create');
            if(checkResult.errorFlag){
                wrResp.Result.Message = checkResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            } 
                        
            checkResult = XC_REST_Asset_UU.checkCreateParams(wrReq, mapHeader);
            if(checkResult.errorFlag) {
                wrResp.Result.Message = checkResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, checkResult.errorMessage); 
                return;

            }  else { 

                Map<String, String> mapParams = new Map<String, String>();
                mapParams.put('AccountID', wrReq.Account.AccountID);
                mapParams.put('PrimaryEmail', wrReq.Account.PrimaryEmail);
                mapParams.put('IdentityNumber', wrReq.Account.IdentityNumber);
                mapParams.put('UniqueID', wrReq.Account.UniqueID);
                mapParams.put('Method', 'POST');

                String accountId = XC_REST_Asset_U_D.getAccount(mapParams);

                if(accountId == Label.XC_CL_Account_MissingDocument){
                    wrResp.Result.Message = 'ERROR. ' + Label.XC_CL_Account_MissingDocument;
                    wrResp.Result.ErrorCode = '400';
                    intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, wrResp.Result.Message); 
                    return;
                }

                Asset res = XC_REST_Asset_U.createAsset(wrReq, accountId);
                XC_UTIL_Sobject.WrapperResult resInsertAsset = XC_UTIL_Sobject.insertRecord(res);
                if(!resInsertAsset.success) {
                    wrResp.Result.Message = 'INTERNAL ERROR';
                    wrResp.Result.ErrorCode = '500';
                    intLog.insertIntegRespInboundLog('500', false, msgResponse, resInsertAsset.errorMessage);  
                    return;
                }

                wrResp.asset = new XC_UTIL_Asset.AssetRESTWrapper();
                wrResp.asset.assetID = res.Id;
                wrResp.asset.assetName = res.Name;
                wrResp.asset.status = res.Status;
                wrResp.asset.accountID = res.AccountId;
                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0';
            }
        }
        catch(Exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';
            logError = 'INTERNAL ERROR: ' + e.getMessage() +'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
                    
            //wrResp.Result.Message = 'err. '+logError; //debug
       
        } finally {
            msgResponse =  JSON.serialize(wrResp, true);
            intLog.insertIntegRespInboundLog((wrResp.Result.ErrorCode=='0'?'200':wrResp.Result.ErrorCode), (wrResp.Result.ErrorCode=='0'?true:false), msgResponse, logError);
        
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0') {
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            } else {
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;     
        }
    }
    
    
    /**
     * @description Do put.
     */
    @HttpPut
    global static void doPut() {
        
        String msgRequest = ''; 
        String msgResponse = '';
        String logError = ''; 
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        RestRequest request = RestContext.request;
        XC_REST_Asset_U.WrapperAssetPUTResponse wrResp = new XC_REST_Asset_U.WrapperAssetPUTResponse();
        
        Map<String, String> mapHeader = request.headers;
        
        try{
            
            msgRequest = request.requestbody.tostring();
            msgRequest = msgRequest.replace('"Currency"','"currency_r"');
            XC_REST_Asset_U.WrapperAssetRequest wrReq = (XC_REST_Asset_U.WrapperAssetRequest) JSON.deserialize(msgRequest,XC_REST_Asset_U.WrapperAssetRequest.class);
            intLog.insertIntegReqInboundLog('Asset', msgRequest);
            intLog.setTransactionID(mapHeader.get('TransactionID'));
            intLog.setHttpMethod(request.httpMethod);
            
            XC_UTIL_Integration.WrapperResult checkResult = XC_UTIL_RESTInbound.checkObjectPermission('Asset', 'update');
            if(checkResult.errorFlag){
                wrResp.Result.Message = checkResult.errorMessage; 
                wrResp.Result.ErrorCode = '400';
                return; 
            } 
            
            checkResult = XC_REST_Asset_U.checkUpdateParams(wrReq, mapHeader);
            if(checkResult.errorFlag) {
                wrResp.Result.Message = checkResult.errorMessage;
                wrResp.Result.ErrorCode = '400';
                intLog.insertIntegRespInboundLog('400', false, msgResponse, checkResult.errorMessage); 
                return; 
 
            } else {

                wrResp.asset = new List<XC_UTIL_Asset.AssetRESTWrapper>();

                List<Asset> res = XC_REST_Asset_U.updateAsset(wrReq);
                if(res == null || res.size()==0) {
                    wrResp.Result.Message = Label.XC_CL_AssetNotFound;
                    wrResp.Result.ErrorCode = '400';
                    wrResp.Asset = null;
                    intLog.insertIntegRespInboundLog('400', false, msgResponse, Label.XC_CL_AssetNotFound);
                    return;
                }
                    
                Map<Id, Asset> mapIAsset = populateMapIAsset(res);

                List<XC_UTIL_Sobject.WrapperResult> resInsertAsset = XC_UTIL_Sobject.updateListrecords(res);
                WrapperCheckResInsert wrCheckRes = new WrapperCheckResInsert();
                wrCheckRes.intLog = intLog;
                wrCheckRes.mapIAsset = mapIAsset;
                wrCheckRes.msgResponse = msgResponse;
                wrCheckRes.resInsertAsset = resInsertAsset;

                checkResInsertAsset(wrCheckRes, wrResp);
                if(wrResp.Result.ErrorCode == '500') {
                    return;
                }
        
                wrResp.Result.Message = 'Operation completed successfully';
                wrResp.Result.ErrorCode = '0';
            }
  
        } catch(Exception e) {
            wrResp.Result.Message = 'INTERNAL ERROR';
            wrResp.Result.ErrorCode = '500';    
            wrResp.Asset = null;
            logError = 'Exception at row: ' + e.getLineNumber() + '  Exception message: ' + e.getMessage() + '  Stack Trace: ' + e.getStackTraceString();
        
        	//wrResp.Result.Message = 'err. '+logError; //debug
            
        } finally {
            msgResponse =  JSON.serialize(wrResp, true);
        
            XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
            restContextResponseWrapper.res = RestContext.response;
            restContextResponseWrapper.msgResponse = msgResponse;
            restContextResponseWrapper.mapHeader = mapHeader;
            if(wrResp.Result.ErrorCode == '0') {
                intLog.insertIntegRespInboundLog('200', true, msgResponse, logError);
                restContextResponseWrapper.errorCode = '200';
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            } else {
                intLog.insertIntegRespInboundLog(wrResp.Result.ErrorCode, false, msgResponse, logError);
                restContextResponseWrapper.errorCode = wrResp.Result.ErrorCode;
                XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
            }
            RestContext.response = restContextResponseWrapper.res;
            msgResponse = restContextResponseWrapper.msgResponse;
            mapHeader = restContextResponseWrapper.mapHeader;     
        }
    }

    private static void populateAssetWr(XC_UTIL_Asset.AssetRESTWrapper assetwr, Map<Id, Asset> mapIAsset, XC_UTIL_Sobject.WrapperResult insertResult) {
        assetwr.assetID = mapIAsset.get(insertResult.recordId).id;
        assetwr.assetName = mapIAsset.get(insertResult.recordId).Name;
        assetwr.status = mapIAsset.get(insertResult.recordId).Status;
        assetwr.accountID = mapIAsset.get(insertResult.recordId).AccountId;
    }

    private static void checkResInsertAsset(WrapperCheckResInsert wr, XC_REST_Asset_U.WrapperAssetPUTResponse wrResp) {
        XC_UTIL_Asset.AssetRESTWrapper assetwr;
        for(XC_UTIL_Sobject.WrapperResult insertResult : wr.resInsertAsset){
            assetwr = new XC_UTIL_Asset.AssetRESTWrapper();
            if(!insertResult.success){
                wrResp.Result.Message = 'INTERNAL ERROR';
                wrResp.Result.ErrorCode = '500';
                wrResp.Asset = null;
                wr.intLog.insertIntegRespInboundLog('500', false, wr.msgResponse, insertResult.errorMessage);
                return;
            } else {
                populateAssetWr(assetWr, wr.mapIAsset, insertResult);
                wrResp.asset.add(assetwr);
            }
        }    
    }

    private static Map<Id, Asset> populateMapIAsset(List<Asset> res) {
        
        Map<Id, Asset> mapIAsset = new Map<ID, Asset>();
        for(Asset asset: res){
            mapIAsset.put(asset.id, Asset);
        }
        return mapIAsset;
    }
}